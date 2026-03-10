import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/providers/locale_provider.dart';
import '../../features/animals/presentation/providers/animal_provider.dart';
import '../../features/scanner/presentation/providers/scanner_provider.dart';
import '../../features/scanner/presentation/widgets/scan_input_sheet.dart';

class HomeShell extends ConsumerWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  static const List<String> _routes = [
    '/home',
    '/animals',
    '/health',
    '/movements',
  ];

  int _currentIndex(BuildContext context) {
    final String path = GoRouterState.of(context).uri.path;
    final int i = _routes.indexWhere((r) => path.startsWith(r));
    return i < 0 ? 0 : i;
  }

  void _openScanner(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanInputSheet(
        tagHandler: ref.read(tagHandlerProvider),
        outerContext: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int idx = _currentIndex(context);
    final String? connectedName = ref.watch(connectedDeviceNameProvider);
    final AppL10n l10n = AppL10n(ref.watch(appLocaleProvider));

    // Trigger auto-reconnect once on startup
    ref.watch(bleAutoReconnectProvider);

    // Listen for BLE tag notifications and handle them immediately
    ref.listen(bleTagStreamProvider, (_, AsyncValue<String> next) {
      next.whenData((String tag) {
        ref.read(tagHandlerProvider).handleTag(tag, context);
      });
    });

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (int i) {
          if (i == 4) {
            _openScanner(context, ref);
          } else {
            context.go(_routes[i]);
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1A7A3C).withValues(alpha: 0.12),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded, color: Color(0xFF1A7A3C)),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pets_outlined),
            selectedIcon: const Icon(Icons.pets_rounded, color: Color(0xFF1A7A3C)),
            label: l10n.navHerd,
          ),
          NavigationDestination(
            icon: const Icon(Icons.medical_services_outlined),
            selectedIcon: const Icon(Icons.medical_services_rounded,
                color: Color(0xFF1A7A3C)),
            label: l10n.navHealth,
          ),
          NavigationDestination(
            icon: const Icon(Icons.swap_horiz_outlined),
            selectedIcon: const Icon(Icons.swap_horiz_rounded,
                color: Color(0xFF1A7A3C)),
            label: l10n.navMovements,
          ),
          NavigationDestination(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.qr_code_scanner_rounded),
                if (connectedName != null)
                  Positioned(
                    top: -2, right: -2,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A7A3C),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: l10n.navScanner,
          ),
        ],
      ),
    );
  }
}
