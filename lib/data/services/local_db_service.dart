import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/family_model.dart';
import '../models/resident_model.dart';

class LocalDbService {
  static const String _familiesBoxName = 'sipen_go_families_box';
  static const String _residentsBoxName = 'sipen_go_residents_box';
  static const String _pendingSyncBoxName = 'sipen_go_pending_sync_box';

  static late Box<String> _familiesBox;
  static late Box<String> _residentsBox;
  static late Box<Map> _pendingSyncBox;

  /// Initializes Hive and opens all boxes.
  static Future<void> init() async {
    await Hive.initFlutter();
    
    _familiesBox = await Hive.openBox<String>(_familiesBoxName);
    _residentsBox = await Hive.openBox<String>(_residentsBoxName);
    _pendingSyncBox = await Hive.openBox<Map>(_pendingSyncBoxName);
  }

  // --- FAMILIES CACHE ---

  /// Caches the list of all families in Hive as a JSON string.
  static Future<void> cacheFamilies(List<FamilyModel> families) async {
    final List<Map<String, dynamic>> jsonList = families.map((f) => f.toJson()).toList();
    await _familiesBox.put('all_families', jsonEncode(jsonList));
  }

  /// Gets the cached list of families. Returns empty list if none cached.
  static List<FamilyModel> getCachedFamilies() {
    final String? jsonStr = _familiesBox.get('all_families');
    if (jsonStr == null) return [];
    
    try {
      final List<dynamic> decodedList = jsonDecode(jsonStr);
      return decodedList.map((item) => FamilyModel.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      // ignore: avoid_print
      print('LocalDbService: Error parsing cached families: $e');
      return [];
    }
  }

  /// Caches a single family by its ID.
  static Future<void> cacheFamily(FamilyModel family) async {
    await _familiesBox.put('family_${family.id}', jsonEncode(family.toJson()));
  }

  /// Gets a single cached family by its ID.
  static FamilyModel? getCachedFamily(String id) {
    final String? jsonStr = _familiesBox.get('family_$id');
    if (jsonStr == null) return null;
    
    try {
      return FamilyModel.fromJson(Map<String, dynamic>.from(jsonDecode(jsonStr)));
    } catch (e) {
      return null;
    }
  }

  // --- RESIDENTS CACHE ---

  /// Caches the residents of a family by the family ID.
  static Future<void> cacheResidents(String familyId, List<ResidentModel> residents) async {
    final List<Map<String, dynamic>> jsonList = residents.map((r) => r.toJson()).toList();
    await _residentsBox.put('residents_$familyId', jsonEncode(jsonList));
  }

  /// Gets the cached residents of a family.
  static List<ResidentModel> getCachedResidents(String familyId) {
    final String? jsonStr = _residentsBox.get('residents_$familyId');
    if (jsonStr == null) return [];
    
    try {
      final List<dynamic> decodedList = jsonDecode(jsonStr);
      return decodedList.map((item) => ResidentModel.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      // ignore: avoid_print
      print('LocalDbService: Error parsing cached residents: $e');
      return [];
    }
  }

  /// Caches all residents in the database.
  static Future<void> cacheAllResidents(List<ResidentModel> residents) async {
    final List<Map<String, dynamic>> jsonList = residents.map((r) => r.toJson()).toList();
    await _residentsBox.put('all_residents', jsonEncode(jsonList));
  }

  /// Gets all cached residents.
  static List<ResidentModel> getCachedAllResidents() {
    final String? jsonStr = _residentsBox.get('all_residents');
    if (jsonStr == null) return [];
    
    try {
      final List<dynamic> decodedList = jsonDecode(jsonStr);
      return decodedList.map((item) => ResidentModel.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return [];
    }
  }

  // --- PENDING SYNC QUEUE ---

  /// Queues a write operation to be synchronized later when connection returns.
  /// [operationType] can be: 'create_family', 'update_family', 'delete_family',
  /// 'create_resident', 'update_resident', 'delete_resident'.
  static Future<void> queueSyncOperation({
    required String operationType,
    required String modelType, // 'family' or 'resident'
    required Map<String, dynamic> data,
    String? targetId,
  }) async {
    final op = {
      'timestamp': DateTime.now().toIso8601String(),
      'operationType': operationType,
      'modelType': modelType,
      'data': data,
      'targetId': targetId,
    };
    
    final id = DateTime.now().millisecondsSinceEpoch;
    await _pendingSyncBox.put(id, op);
  }

  /// Gets all pending sync operations in chronological order.
  static Map<dynamic, Map<String, dynamic>> getPendingOperations() {
    final Map<dynamic, Map<String, dynamic>> result = {};
    for (var key in _pendingSyncBox.keys) {
      final val = _pendingSyncBox.get(key);
      if (val != null) {
        result[key] = Map<String, dynamic>.from(val);
      }
    }
    return result;
  }

  /// Removes a synchronized operation from the pending box.
  static Future<void> removePendingOperation(dynamic key) async {
    await _pendingSyncBox.delete(key);
  }

  /// Checks if there are any pending sync operations.
  static bool hasPendingOperations() {
    return _pendingSyncBox.isNotEmpty;
  }

  /// Clears all local caches (useful on logout / reset).
  static Future<void> clearAll() async {
    await _familiesBox.clear();
    await _residentsBox.clear();
    await _pendingSyncBox.clear();
  }
}
