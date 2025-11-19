import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

bool _isInitialized = false;

Future<void> initSupabase() async {
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    print('Warning: Supabase credentials not found in .env file.');
    print('Please create a .env file with SUPABASE_URL and SUPABASE_ANON_KEY.');
    print('The app will continue but authentication features may not work.');
    // Utiliser des valeurs par défaut pour permettre le développement
    // En production, cela devrait être une erreur fatale
    return;
  }
  
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce, // Sécurité renforcée
      ),
    );
    _isInitialized = true;
    print('✅ Supabase initialisé avec succès');
    print('   URL: $supabaseUrl');
  } catch (e) {
    print('❌ Erreur lors de l\'initialisation de Supabase: $e');
    _isInitialized = false;
  }
}

SupabaseClient? get supabase {
  if (!_isInitialized) {
    try {
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }
  return Supabase.instance.client;
}

