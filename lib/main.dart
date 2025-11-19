import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'config/theme.dart';
import 'config/supabase_config.dart';
import 'features/search/screens/home_screen.dart';
import 'features/search/screens/search_results_screen.dart';
import 'features/establishments/screens/establishment_detail_screen.dart';
import 'features/events/screens/events_list_screen.dart';
import 'features/favorites/screens/favorites_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/map/screens/map_screen.dart';
import 'features/events/screens/event_detail_screen.dart';
import 'core/providers/establishment_provider.dart' as providers;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Gestion globale des erreurs Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack: ${details.stack}');
  };
  
  // Charger les variables d'environnement (si le fichier existe)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Le fichier .env n'existe pas, utiliser des valeurs par défaut
    print('Warning: .env file not found. Using default values.');
  }
  
  // Initialiser Supabase
  try {
    await initSupabase();
  } catch (e) {
    print('Error initializing Supabase: $e');
    // Continuer même si Supabase échoue
  }
  
  runApp(
    const ProviderScope(
      child: Envie2SortirApp(),
    ),
  );
}

class Envie2SortirApp extends StatelessWidget {
  const Envie2SortirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Envie2Sortir',
      theme: appTheme,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final envie = state.uri.queryParameters['envie'] ?? '';
        final ville = state.uri.queryParameters['ville'];
        return SearchResultsScreen(
          envie: envie,
          ville: ville,
        );
      },
    ),
    GoRoute(
      path: '/establishment/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return _EstablishmentDetailRoute(slug: slug);
      },
    ),
    GoRoute(
      path: '/events',
      builder: (context, state) {
        final city = state.uri.queryParameters['city'];
        return EventsListScreen(city: city);
      },
    ),
    GoRoute(
      path: '/event/:id',
      builder: (context, state) {
        final eventId = state.pathParameters['id']!;
        return _EventDetailRoute(eventId: eventId);
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) {
        final envie = state.uri.queryParameters['envie'];
        final ville = state.uri.queryParameters['ville'];
        return MapScreen(
          envie: envie,
          ville: ville,
        );
      },
    ),
  ],
);

// Widget temporaire pour charger l'établissement depuis le provider
class _EstablishmentDetailRoute extends ConsumerWidget {
  final String slug;

  const _EstablishmentDetailRoute({required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final establishmentAsync = ref.watch(providers.establishmentBySlugProvider(slug));

    return establishmentAsync.when(
      data: (establishment) {
        if (establishment == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Établissement introuvable')),
            body: const Center(child: Text('Cet établissement n\'existe pas')),
          );
        }
        return EstablishmentDetailScreen(establishment: establishment);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }
}

// Widget pour charger l'événement depuis le provider
class _EventDetailRoute extends ConsumerWidget {
  final String eventId;

  const _EventDetailRoute({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(providers.eventByIdProvider(eventId));

    return eventAsync.when(
      data: (event) {
        if (event == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Événement introuvable')),
            body: const Center(child: Text('Cet événement n\'existe pas')),
          );
        }
        return EventDetailScreen(event: event);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }
}

