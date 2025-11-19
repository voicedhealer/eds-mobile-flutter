import 'package:flutter/material.dart';

class AuthRequiredDialog extends StatelessWidget {
  final String action;
  final VoidCallback? onLoginPressed;

  const AuthRequiredDialog({
    super.key,
    required this.action,
    this.onLoginPressed,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String action,
    VoidCallback? onLoginPressed,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AuthRequiredDialog(
        action: action,
        onLoginPressed: onLoginPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Connexion requise'),
      content: Text(
        'Vous devez être connecté pour $action. Souhaitez-vous vous connecter ?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            if (onLoginPressed != null) {
              onLoginPressed!();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF751F),
          ),
          child: const Text('Se connecter'),
        ),
      ],
    );
  }
}

