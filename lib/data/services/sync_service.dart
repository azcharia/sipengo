import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_db_service.dart';
import 'supabase_service.dart';

class SyncService {
  static bool _isSyncing = false;

  /// Trigger background synchronization of pending operations.
  /// Automatically runs in a non-blocking queue.
  static Future<void> syncPendingOperations() async {
    if (_isSyncing) return;
    if (!LocalDbService.hasPendingOperations()) return;

    _isSyncing = true;
    // ignore: avoid_print
    print('SyncService: Starting synchronization of pending offline operations...');

    final pendingOps = LocalDbService.getPendingOperations();
    final sortedKeys = pendingOps.keys.toList()..sort();

    for (var key in sortedKeys) {
      final op = pendingOps[key]!;
      final operationType = op['operationType'] as String;
      final modelType = op['modelType'] as String;
      final data = Map<String, dynamic>.from(op['data'] as Map);
      final targetId = op['targetId'] as String?;

      try {
        if (modelType == 'family') {
          await _syncFamilyOperation(operationType, data, targetId);
        } else if (modelType == 'resident') {
          await _syncResidentOperation(operationType, data, targetId);
        }

        // Successfully synced, remove from queue
        await LocalDbService.removePendingOperation(key);
        // ignore: avoid_print
        print('SyncService: Successfully synchronized pending operation with key: $key ($operationType)');
      } catch (e) {
        final isNetwork = _isTransientNetworkError(e);
        if (isNetwork) {
          // ignore: avoid_print
          print('SyncService: Network error detected during sync ($e). Pausing synchronization.');
          break; // Stop processing queue, wait for next network restoration
        } else {
          // Critical constraint/data corruption error: Quarantining this operation to prevent blocking the queue
          // ignore: avoid_print
          print('SyncService: Critical error during sync ($e) for key $key. Quarantining task.');
          await LocalDbService.removePendingOperation(key);
        }
      }
    }

    _isSyncing = false;
    // ignore: avoid_print
    print('SyncService: Synchronization finished.');
  }

  static Future<void> _syncFamilyOperation(String operationType, Map<String, dynamic> data, String? targetId) async {
    switch (operationType) {
      case 'create_family':
        await SupabaseService.families.insert(data);
        break;
      case 'update_family':
        if (targetId == null) throw Exception('Missing family ID for update');
        await SupabaseService.families.update(data).eq('id', targetId);
        break;
      case 'delete_family':
        if (targetId == null) throw Exception('Missing family ID for delete');
        await SupabaseService.families.delete().eq('id', targetId);
        break;
      default:
        throw Exception('Unknown family operation type: $operationType');
    }
  }

  static Future<void> _syncResidentOperation(String operationType, Map<String, dynamic> data, String? targetId) async {
    switch (operationType) {
      case 'create_resident':
        await SupabaseService.residents.insert(data);
        break;
      case 'update_resident':
        if (targetId == null) throw Exception('Missing resident ID for update');
        await SupabaseService.residents.update(data).eq('id', targetId);
        break;
      case 'delete_resident':
        if (targetId == null) throw Exception('Missing resident ID for delete');
        await SupabaseService.residents.delete().eq('id', targetId);
        break;
      default:
        throw Exception('Unknown resident operation type: $operationType');
    }
  }

  /// Re-inspect network failure for sync task
  static bool _isTransientNetworkError(dynamic error) {
    final errMsg = error.toString().toLowerCase();
    return errMsg.contains('socketexception') || 
           errMsg.contains('timeout') || 
           errMsg.contains('connection failed') || 
           errMsg.contains('network_error') ||
           errMsg.contains('failed to connect') ||
           (error is PostgrestException && (error.code == '502' || error.code == '503' || error.code == '504'));
  }
}
