import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/animals/presentation/screens/add_animal_screen.dart';
import '../../features/animals/presentation/screens/animal_detail_screen.dart';
import '../../features/animals/presentation/screens/animals_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/scanner/presentation/screens/ble_connect_screen.dart';
import '../../shared/widgets/home_shell.dart';

part 'router.g.dart';

class AppRoutes {
  static const welcome = '/';
  static const home = '/home';
  static const animals = '/animals';
  static const records = '/records';
  static const health = '/health';
  static const movements = '/movements';
  static const scannerBle = '/scanner/ble';
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
                builder: (context, state) {
                  final Map<String, dynamic>? extra =
                      state.extra as Map<String, dynamic>?;
                  return AddAnimalScreen(
                    initialTagNumber:
                        extra?['tagNumber'] as String?,
                  );
                },
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
            builder: (context, state) => const _PlaceholderScreen(title: 'Records'),
          ),
          GoRoute(
            path: AppRoutes.health,
            builder: (context, state) => const _PlaceholderScreen(title: 'Health'),
          ),
          GoRoute(
            path: AppRoutes.movements,
            builder: (context, state) => const _PlaceholderScreen(title: 'Movements'),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.scannerBle,
        builder: (context, state) => const BleConnectScreen(),
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: const Color(0xFF1A7A3C),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            '$title — coming soon',
            style: const TextStyle(color: Color(0xFF888888)),
          ),
        ),
      );
}
