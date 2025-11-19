import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

bool _isInitialized = false;

Future<void> initSupabase() async {
  print('🔧 Début de l\'initialisation de Supabase...');
  
  // Vérifier que dotenv est chargé
  final allKeys = dotenv.env.keys.toList();
  print('📋 Variables d\'environnement chargées: ${allKeys.length}');
  print('   Clés disponibles: ${allKeys.join(", ")}');
  
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  print('🔍 Vérification des credentials:');
  print('   SUPABASE_URL: ${supabaseUrl.isNotEmpty ? "✅ (${supabaseUrl.length} caractères)" : "❌ VIDE"}');
  print('   SUPABASE_ANON_KEY: ${supabaseAnonKey.isNotEmpty ? "✅ (${supabaseAnonKey.length} caractères)" : "❌ VIDE"}');
  
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    print('⚠️ Warning: Supabase credentials not found in .env file.');
    print('   SUPABASE_URL vide: ${supabaseUrl.isEmpty}');
    print('   SUPABASE_ANON_KEY vide: ${supabaseAnonKey.isEmpty}');
    print('   Please create a .env file with SUPABASE_URL and SUPABASE_ANON_KEY.');
    print('   The app will continue but authentication features may not work.');
    // Utiliser des valeurs par défaut pour permettre le développement
    // En production, cela devrait être une erreur fatale
    _isInitialized = false;
    return;
  }
  
  try {
    print('🚀 Initialisation de Supabase...');
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
    print('   Anon Key: ${supabaseAnonKey.substring(0, 20)}...');
  } catch (e, stackTrace) {
    print('❌ Erreur lors de l\'initialisation de Supabase: $e');
    print('   Stack trace: $stackTrace');
    _isInitialized = false;
  }
}

SupabaseClient? get supabase {
  if (!_isInitialized) {
    return null;
  }
  try {
    return Supabase.instance.client;
  } catch (e) {
    print('⚠️ Erreur lors de l\'accès à Supabase: $e');
    return null;
  }
}

