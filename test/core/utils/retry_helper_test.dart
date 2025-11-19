import 'package:flutter_test/flutter_test.dart';
import 'package:envie2sortir/core/utils/retry_helper.dart';

void main() {
  group('RetryHelper', () {
    test('retry should succeed on first attempt', () async {
      int attempts = 0;
      final result = await RetryHelper.retry(
        operation: () async {
          attempts++;
          return 'success';
        },
        maxRetries: 3,
      );

      expect(result, 'success');
      expect(attempts, 1);
    });

    test('retry should succeed after retries', () async {
      int attempts = 0;
      final result = await RetryHelper.retry(
        operation: () async {
          attempts++;
          if (attempts < 2) {
            throw Exception('Error');
          }
          return 'success';
        },
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 10),
      );

      expect(result, 'success');
      expect(attempts, 2);
    });

    test('retry should throw after max retries', () async {
      int attempts = 0;
      
      expect(
        () => RetryHelper.retry(
          operation: () async {
            attempts++;
            throw Exception('Error');
          },
          maxRetries: 3,
          initialDelay: const Duration(milliseconds: 10),
        ),
        throwsException,
      );

      expect(attempts, 3);
    });

    test('retry should respect shouldRetry callback', () async {
      int attempts = 0;
      
      expect(
        () => RetryHelper.retry(
          operation: () async {
            attempts++;
            throw Exception('Non-retryable error');
          },
          maxRetries: 3,
          initialDelay: const Duration(milliseconds: 10),
          shouldRetry: (error) => false,
        ),
        throwsException,
      );

      expect(attempts, 1);
    });

    test('retryWithProgress should call onRetry callback', () async {
      int attempts = 0;
      int retryCallbacks = 0;

      final result = await RetryHelper.retryWithProgress(
        operation: () async {
          attempts++;
          if (attempts < 2) {
            throw Exception('Error');
          }
          return 'success';
        },
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 10),
        onRetry: (attempt, maxRetries) {
          retryCallbacks++;
        },
      );

      expect(result, 'success');
      expect(attempts, 2);
      expect(retryCallbacks, 1);
    });
  });
}

