import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/animals/presentation/screens/add_animal_screen.dart';
import '../../features/animals/presentation/screens/animal_detail_screen.dart';
import '../../features/animals/presentation/screens/animals_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/farms/presentation/screens/onboarding_screen.dart';
import '../../features/health/presentation/screens/add_health_event_screen.dart';
import '../../features/health/presentation/screens/add_medicine_screen.dart';
import '../../features/health/presentation/screens/add_tb_test_screen.dart';
import '../../features/health/presentation/screens/health_screen.dart';
import '../../features/health/presentation/screens/medicine_cabinet_screen.dart';
import '../../features/movements/presentation/screens/add_movement_screen.dart';
import '../../features/movements/presentation/screens/movements_screen.dart';
import '../../features/records/presentation/screens/add_birth_screen.dart';
import '../../features/records/presentation/screens/add_death_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/scanner/presentation/screens/ble_connect_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/widgets/home_shell.dart';

part 'router.g.dart';

class AppRoutes {
  static const welcome = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const animals = '/animals';
  static const health = '/health';
  static const movements = '/movements';
  static const scannerBle = '/scanner/ble';
  static const settings = '/settings';
  static const reports = '/reports';
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
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
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
                    initialTagNumber: extra?['tagNumber'] as String?,
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
            path: AppRoutes.health,
            builder: (context, state) => const HealthScreen(),
            routes: [
              GoRoute(
                path: 'medicine/add',
                builder: (context, state) {
                  final String? tag = state.uri.queryParameters['tag'];
                  return AddMedicineScreen(initialAnimalTag: tag);
                },
              ),
              GoRoute(
                path: 'medicine/cabinet',
                builder: (context, state) => const MedicineCabinetScreen(),
              ),
              GoRoute(
                path: 'tb/add',
                builder: (context, state) {
                  final String? tag = state.uri.queryParameters['tag'];
                  return AddTbTestScreen(initialAnimalTag: tag);
                },
              ),
              GoRoute(
                path: 'event/add',
                builder: (context, state) {
                  final String? tag = state.uri.queryParameters['tag'];
                  return AddHealthEventScreen(initialAnimalTag: tag);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.movements,
            builder: (context, state) => const MovementsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) {
                  final String? tag = state.uri.queryParameters['tag'];
                  return AddMovementScreen(initialTag: tag);
                },
              ),
            ],
          ),
        ],
      ),
      // Records routes (launched from animal detail, outside shell)
      GoRoute(
        path: '/records/birth/add',
        builder: (context, state) {
          final String? tag = state.uri.queryParameters['tag'];
          return AddBirthScreen(initialAnimalTag: tag);
        },
      ),
      GoRoute(
        path: '/records/death/add',
        builder: (context, state) {
          final String? tag = state.uri.queryParameters['tag'];
          return AddDeathScreen(initialAnimalTag: tag);
        },
      ),
      GoRoute(
        path: AppRoutes.scannerBle,
        builder: (context, state) => const BleConnectScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (context, state) => const ReportsScreen(),
      ),
    ],
  );
}
