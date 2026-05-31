import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class NetworkResilience {
  /// Runs an asynchronous action and automatically retries it if a transient network error occurs.
  /// Uses an Exponential Backoff strategy to dynamically increase wait time between attempts.
  static Future<T> runWithRetry<T>(
    Future<T> Function() action, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.5,
    void Function(int attempt, dynamic error)? onRetry,
  }) async {
    int attempt = 1;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await action();
      } catch (e) {
        final isNetwork = _isTransientNetworkError(e);
        
        if (!isNetwork || attempt >= maxAttempts) {
          rethrow; // Rethrow immediately if not a transient network issue or attempts exhausted
        }

        if (onRetry != null) {
          onRetry(attempt, e);
        }

        // ignore: avoid_print
        print('NetworkResilience: Attempt $attempt failed with network error ($e). Retrying in ${delay.inMilliseconds}ms...');

        await Future.delayed(delay);
        
        attempt++;
        delay = Duration(milliseconds: (delay.inMilliseconds * backoffMultiplier).round());
      }
    }
  }

  /// Inspects the exception type and error message to determine if it is a transient network failure.
  static bool _isTransientNetworkError(dynamic error) {
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is HandshakeException) return true;
    
    // Inspect Supabase specific Postgrest exceptions
    if (error is PostgrestException) {
      final code = error.code;
      // 502 (Bad Gateway), 503 (Service Unavailable), 504 (Gateway Timeout)
      if (code == '502' || code == '503' || code == '504') return true;
      
      final msg = error.message.toLowerCase();
      if (msg.contains('timeout') || msg.contains('connection') || msg.contains('network')) {
        return true;
      }
    }
    
    // Inspect text representation for generic network messages
    final errMsg = error.toString().toLowerCase();
    if (errMsg.contains('socketexception') || 
        errMsg.contains('timeout') || 
        errMsg.contains('connection failed') || 
        errMsg.contains('network_error') ||
        errMsg.contains('failed to connect')) {
      return true;
    }
    
    return false;
  }
}
