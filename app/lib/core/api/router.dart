import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';

part 'router.g.dart';

class AppRoutes {
  static const welcome = '/';
  static const home = '/home';
  static const animals = '/animals';
  static const records = '/records';
  static const health = '/health';
  static const movements = '/movements';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.animals,
            builder: (context, state) => const AnimalsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddAnimalScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => AnimalDetailScreen(
                  animalId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.records,
            builder: (context, state) => const RecordsScreen(),
          ),
          GoRoute(
            path: AppRoutes.health,
            builder: (context, state) => const HealthScreen(),
          ),
          GoRoute(
            path: AppRoutes.movements,
            builder: (context, state) => const MovementsScreen(),
          ),
        ],
      ),
    ],
  );
}

// Placeholder screens — to be replaced as features are built out
class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});
  @override
  Widget build(BuildContext context) => child;
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Dashboard')));
}

class AnimalsScreen extends StatelessWidget {
  const AnimalsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Animals')));
}

class AddAnimalScreen extends StatelessWidget {
  const AddAnimalScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Add Animal')));
}

class AnimalDetailScreen extends StatelessWidget {
  final String animalId;
  const AnimalDetailScreen({super.key, required this.animalId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Animal $animalId')));
}

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Records')));
}

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Health')));
}

class MovementsScreen extends StatelessWidget {
  const MovementsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Movements')));
}
