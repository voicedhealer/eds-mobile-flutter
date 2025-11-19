import 'package:flutter/material.dart';
import 'network_utils.dart';

class ErrorHandler {
  static void showError(BuildContext context, dynamic error) {
    final message = NetworkUtils.getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: NetworkUtils.isRetryable(error)
            ? SnackBarAction(
                label: 'Réessayer',
                textColor: Colors.white,
                onPressed: () {
                  // L'action de retry doit être gérée par le widget parent
                },
              )
            : SnackBarAction(
                label: 'Fermer',
                textColor: Colors.white,
                onPressed: () {},
              ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

