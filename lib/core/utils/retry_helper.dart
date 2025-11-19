import 'dart:async';

/// Helper pour réessayer une opération avec backoff exponentiel
class RetryHelper {
  /// Exécute une fonction avec retry automatique
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempt++;
        
        // Si c'est la dernière tentative ou qu'on ne doit pas réessayer
        if (attempt >= maxRetries || 
            (shouldRetry != null && !shouldRetry(error))) {
          rethrow;
        }

        // Attendre avant de réessayer avec backoff exponentiel
        await Future.delayed(delay);
        delay = Duration(milliseconds: delay.inMilliseconds * 2);
      }
    }

    throw Exception('Max retries reached');
  }

  /// Exécute une fonction avec retry et callback de progression
  static Future<T> retryWithProgress<T>({
    required Future<T> Function() operation,
    required void Function(int attempt, int maxRetries) onRetry,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempt++;
        
        if (attempt >= maxRetries || 
            (shouldRetry != null && !shouldRetry(error))) {
          rethrow;
        }

        onRetry(attempt, maxRetries);
        await Future.delayed(delay);
        delay = Duration(milliseconds: delay.inMilliseconds * 2);
      }
    }

    throw Exception('Max retries reached');
  }
}

