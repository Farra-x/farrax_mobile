import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../farms/presentation/providers/farm_provider.dart';
import '../../../scanner/presentation/providers/scanner_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Farm?> farmAsync = ref.watch(activeFarmProvider);
    final ThemeMode themeMode = ref.watch(themeMode_Provider);
    final String? connectedName = ref.watch(connectedDeviceNameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Farm Profile ─────────────────────────────────────────────
          const _SectionTitle('Farm Profile'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: farmAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
              error: (_, __) => const ListTile(
                  title: Text('Error loading farm')),
              data: (Farm? farm) => Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_rounded,
                        color: Color(0xFF1A7A3C)),
                    title: Text(farm?.name ?? 'No farm set up'),
                    subtitle: farm != null
                        ? Text('${farm.herdNumber} · ${farm.country}')
                        : null,
                    trailing: TextButton(
                      onPressed: () =>
                          context.push('/settings/farm/edit'),
                      child: const Text('Edit'),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.add_rounded,
                        color: Color(0xFF1A7A3C)),
                    title: const Text('Add New Farm'),
                    onTap: () => context.push('/onboarding'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Preferences ─────────────────────────────────────────────
          const _SectionTitle('Preferences'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_rounded),
                  title: const Text('Dark Mode'),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (bool v) => ref
                      .read(themeMode_Provider.notifier)
                      .setMode(v ? ThemeMode.dark : ThemeMode.light),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.straighten_rounded),
                  title: const Text('Units'),
                  trailing: _UnitsToggle(),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.language_rounded),
                  title: Text('Language'),
                  trailing: Text('English',
                      style: TextStyle(color: Color(0xFF888888))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Scanner ─────────────────────────────────────────────────
          const _SectionTitle('Scanner'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bluetooth_rounded,
                      color: Color(0xFF1A7A3C)),
                  title: Text(connectedName ?? 'Not connected'),
                  subtitle: const Text('EID Reader'),
                  trailing: connectedName != null
                      ? TextButton(
                          onPressed: () => ref
                              .read(scannerServiceProvider)
                              .disconnectDevice(),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red),
                          child: const Text('Disconnect'),
                        )
                      : TextButton(
                          onPressed: () =>
                              context.push('/scanner/ble'),
                          child: const Text('Connect'),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── About ────────────────────────────────────────────────────
          const _SectionTitle('About'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_rounded,
                      color: Color(0xFF1A7A3C)),
                  title: Text('Version'),
                  trailing: Text('1.0.0 (Beta)',
                      style: TextStyle(color: Color(0xFF888888))),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.language_rounded,
                      color: Color(0xFF1A7A3C)),
                  title: Text('Website'),
                  trailing: Text('farrax.com',
                      style: TextStyle(color: Color(0xFF1A7A3C))),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_rounded,
                      color: Color(0xFF1A7A3C)),
                  title: const Text('Privacy Policy'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF888888),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _UnitsToggle extends ConsumerStatefulWidget {
  @override
  ConsumerState<_UnitsToggle> createState() => _UnitsToggleState();
}

class _UnitsToggleState extends ConsumerState<_UnitsToggle> {
  String _units = 'metric';

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _units = prefs.getString('units') ?? 'metric');
  }

  Future<void> _setUnits(String units) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('units', units);
    setState(() => _units = units);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['metric', 'imperial'].map((String u) {
        final bool sel = _units == u;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: GestureDetector(
            onTap: () => _setUnits(u),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: sel
                    ? const Color(0xFF1A7A3C)
                    : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                u == 'metric' ? 'Metric' : 'Imperial',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : const Color(0xFF555555),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
