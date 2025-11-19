import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:envie2sortir/core/utils/network_utils.dart';

void main() {
  group('NetworkUtils', () {
    test('isNetworkError should detect connection timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(NetworkUtils.isNetworkError(error), true);
    });

    test('isNetworkError should detect receive timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );

      expect(NetworkUtils.isNetworkError(error), true);
    });

    test('isAuthError should detect 401 error', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      expect(NetworkUtils.isAuthError(error), true);
    });

    test('isAuthError should detect 403 error', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 403,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      expect(NetworkUtils.isAuthError(error), true);
    });

    test('isNotFoundError should detect 404 error', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      expect(NetworkUtils.isNotFoundError(error), true);
    });

    test('isServerError should detect 500 error', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      expect(NetworkUtils.isServerError(error), true);
    });

    test('isServerError should detect 503 error', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 503,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      expect(NetworkUtils.isServerError(error), true);
    });

    test('getErrorMessage should return network error message', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final message = NetworkUtils.getErrorMessage(error);
      expect(message, contains('connexion'));
    });

    test('getErrorMessage should return auth error message', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      final message = NetworkUtils.getErrorMessage(error);
      expect(message, contains('connecté'));
    });

    test('isRetryable should return true for network errors', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(NetworkUtils.isRetryable(error), true);
    });

    test('isRetryable should return true for server errors', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      expect(NetworkUtils.isRetryable(error), true);
    });

    test('isRetryable should return false for auth errors', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
        ),
      );

      expect(NetworkUtils.isRetryable(error), false);
    });
  });
}

