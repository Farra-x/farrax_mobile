import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/database.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../farms/presentation/providers/farm_provider.dart';
import '../../../scanner/presentation/providers/scanner_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Farm?> farmAsync = ref.watch(activeFarmProvider);
    final String? connectedName = ref.watch(connectedDeviceNameProvider);
    final Locale locale = ref.watch(appLocaleProvider);
    final AppL10n l10n = AppL10n(locale);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Farm Profile ─────────────────────────────────────────────
          _SectionTitle(l10n.farmProfile),
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
                    title: Text(farm?.name ?? l10n.noFarmSetUp),
                    subtitle: farm != null
                        ? Text('${farm.herdNumber} · ${farm.country}')
                        : null,
                    trailing: TextButton(
                      onPressed: () =>
                          context.push('/settings/farm/edit'),
                      child: Text(l10n.edit),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.add_rounded,
                        color: Color(0xFF1A7A3C)),
                    title: Text(l10n.addNewFarm),
                    onTap: () => context.push('/onboarding'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Preferences ─────────────────────────────────────────────
          _SectionTitle(l10n.preferences),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.straighten_rounded),
                  title: Text(l10n.units),
                  trailing: _UnitsToggle(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(l10n.language),
                  trailing: _LanguageToggle(locale: locale, ref: ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Scanner ─────────────────────────────────────────────────
          _SectionTitle(l10n.scanner),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bluetooth_rounded,
                      color: Color(0xFF1A7A3C)),
                  title: Text(connectedName ?? l10n.notConnected),
                  subtitle: Text(l10n.eidReader),
                  trailing: connectedName != null
                      ? TextButton(
                          onPressed: () => ref
                              .read(scannerServiceProvider)
                              .disconnectDevice(),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red),
                          child: Text(l10n.disconnect),
                        )
                      : TextButton(
                          onPressed: () =>
                              context.push('/scanner/ble'),
                          child: Text(l10n.connect),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── About ────────────────────────────────────────────────────
          _SectionTitle(l10n.about),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_rounded,
                      color: Color(0xFF1A7A3C)),
                  title: Text(l10n.version),
                  trailing: const Text('1.0.0 (Beta)',
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
                  title: Text(l10n.privacyPolicy),
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

// ─── Language Toggle ──────────────────────────────────────────────────────────

class _LanguageToggle extends StatelessWidget {
  final Locale locale;
  final WidgetRef ref;
  const _LanguageToggle({required this.locale, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LangChip(
          label: AppL10n.english,
          selected: locale.languageCode == 'en',
          onTap: () => ref
              .read(appLocaleProvider.notifier)
              .setLocale(const Locale('en')),
        ),
        const SizedBox(width: 4),
        _LangChip(
          label: AppL10n.gaeilge,
          selected: locale.languageCode == 'ga',
          onTap: () => ref
              .read(appLocaleProvider.notifier)
              .setLocale(const Locale('ga')),
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A7A3C) : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}

// ─── Units Toggle ─────────────────────────────────────────────────────────────

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
