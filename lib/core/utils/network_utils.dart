import 'package:dio/dio.dart';

class NetworkUtils {
  /// Vérifie si l'erreur est due à un problème de réseau
  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown;
    }
    return false;
  }

  /// Vérifie si l'erreur est due à un problème d'authentification
  static bool isAuthError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 401 ||
          error.response?.statusCode == 403;
    }
    return false;
  }

  /// Vérifie si l'erreur est due à une ressource non trouvée
  static bool isNotFoundError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 404;
    }
    return false;
  }

  /// Vérifie si l'erreur est due à un problème serveur
  static bool isServerError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      return statusCode != null && statusCode >= 500 && statusCode < 600;
    }
    return false;
  }

  /// Retourne un message d'erreur convivial pour l'utilisateur
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (isNetworkError(error)) {
        return 'Problème de connexion. Vérifiez votre connexion internet.';
      }
      if (isAuthError(error)) {
        return 'Vous devez être connecté pour accéder à cette ressource.';
      }
      if (isNotFoundError(error)) {
        return 'Ressource non trouvée.';
      }
      if (isServerError(error)) {
        return 'Erreur serveur. Veuillez réessayer plus tard.';
      }
      return error.response?.data?['message'] ?? 
             error.message ?? 
             'Une erreur est survenue.';
    }
    return error.toString();
  }

  /// Vérifie si une erreur peut être réessayée
  static bool isRetryable(dynamic error) {
    return isNetworkError(error) || isServerError(error);
  }
}

