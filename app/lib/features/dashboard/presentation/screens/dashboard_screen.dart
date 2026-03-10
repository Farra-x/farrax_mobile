import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../../scanner/presentation/providers/scanner_provider.dart';
import '../../../scanner/presentation/widgets/scan_input_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting(AppL10n l10n) {
    final int hour = DateTime.now().hour;
    if (hour < 12) return '${l10n.goodMorning}, ${l10n.farmer}';
    if (hour < 17) return '${l10n.goodAfternoon}, ${l10n.farmer}';
    return '${l10n.goodEvening}, ${l10n.farmer}';
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
    final AsyncValue<DashboardStats> stats = ref.watch(dashboardStatsProvider);
    final AsyncValue<List<Animal>> recent = ref.watch(recentAnimalsProvider);
    final String? connectedName = ref.watch(connectedDeviceNameProvider);
    final Locale locale = ref.watch(appLocaleProvider);
    final AppL10n l10n = AppL10n(locale);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      drawer: const _AppDrawer(),
      body: RefreshIndicator(
        color: const Color(0xFF1A7A3C),
        onRefresh: () => ref.refresh(dashboardStatsProvider.future),
        child: CustomScrollView(
          slivers: [
            // ── App Bar ───────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFF1A7A3C),
              foregroundColor: Colors.white,
              expandedHeight: 110,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () => _openScanner(context, ref),
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  tooltip: 'Scan Tag',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.fromLTRB(72, 0, 56, 14),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(l10n),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (connectedName != null)
                      Row(
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6EE7A0),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            connectedName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xCCFFFFFF),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        l10n.noReaderConnected,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0x99FFFFFF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── Stats Row ───────────────────────────────────────────
                  SizedBox(
                    height: 100,
                    child: stats.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF1A7A3C)),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (DashboardStats s) => ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _StatCard(
                            label: l10n.totalAnimals,
                            value: '${s.totalAnimals}',
                            icon: Icons.pets_rounded,
                            color: const Color(0xFF1A7A3C),
                          ),
                          _StatCard(
                            label: l10n.birthsMonth,
                            value: '${s.birthsThisMonth}',
                            icon: Icons.child_care_rounded,
                            color: const Color(0xFF0D6EAF),
                          ),
                          _StatCard(
                            label: l10n.navMovements,
                            value: '${s.movementsThisMonth}',
                            icon: Icons.swap_horiz_rounded,
                            color: const Color(0xFFF0A500),
                          ),
                          _StatCard(
                            label: l10n.healthAlerts,
                            value: '${s.pendingAlerts}',
                            icon: Icons.notification_important_rounded,
                            color: Colors.red[400]!,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Quick Actions ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      l10n.quickActions,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1F14),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _ActionTile(
                          icon: Icons.add_circle_outline_rounded,
                          label: l10n.registerCalf,
                          color: const Color(0xFF1A7A3C),
                          onTap: () => context.push('/animals/add'),
                        ),
                        _ActionTile(
                          icon: Icons.swap_horiz_rounded,
                          label: l10n.recordMovement,
                          color: const Color(0xFFF0A500),
                          onTap: () => context.push('/movements/add'),
                        ),
                        _ActionTile(
                          icon: Icons.medical_services_rounded,
                          label: l10n.healthEvent,
                          color: const Color(0xFF0D6EAF),
                          onTap: () => context.push('/health/add'),
                        ),
                        _ActionTile(
                          icon: Icons.qr_code_scanner_rounded,
                          label: l10n.scanTagLabel,
                          color: const Color(0xFF333333),
                          onTap: () => _openScanner(context, ref),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Recent Activity ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      l10n.recentActivity,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1F14),
                      ),
                    ),
                  ),
                  recent.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF1A7A3C))),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (List<Animal> animals) => animals.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.pets_outlined,
                                      size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.noActivityYet,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF555555),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.registerFirstAnimalHint,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () =>
                                        context.push('/animals/add'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A7A3C),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: Text(l10n.registerFirstAnimal),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                            itemCount: animals.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, int i) {
                              final Animal a = animals[i];
                              return _RecentAnimalTile(
                                animal: a,
                                onTap: () =>
                                    context.push('/animals/${a.id}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Action Tile ──────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Recent Animal Tile ───────────────────────────────────────────────────────

class _RecentAnimalTile extends ConsumerWidget {
  final Animal animal;
  final VoidCallback onTap;

  const _RecentAnimalTile({required this.animal, required this.onTap});

  String _age(DateTime dob) {
    final int days = DateTime.now().difference(dob).inDays;
    if (days < 30) return '$days days';
    if (days < 365) return '${(days / 30).floor()} months';
    return '${(days / 365).floor()}y';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n(ref.watch(appLocaleProvider));
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A7A3C).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  animal.sex == 'M'
                      ? Icons.male_rounded
                      : Icons.female_rounded,
                  color: const Color(0xFF1A7A3C),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.tagNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1F14),
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      '${animal.breed} · ${_age(animal.dateOfBirth)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: animal.isActive
                      ? const Color(0xFF1A7A3C).withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  animal.isActive ? l10n.active : l10n.inactive,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: animal.isActive
                        ? const Color(0xFF1A7A3C)
                        : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFCCCCCC), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── App Drawer ───────────────────────────────────────────────────────────────

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer();

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => Consumer(
        builder: (_, WidgetRef dRef, __) {
          final Locale locale = dRef.watch(appLocaleProvider);
          final AppL10n l10n = AppL10n(locale);
          return AlertDialog(
            title: Text(
              l10n.language,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text(AppL10n.english),
                  value: 'en',
                  groupValue: locale.languageCode,
                  activeColor: const Color(0xFF1A7A3C),
                  onChanged: (_) {
                    dRef
                        .read(appLocaleProvider.notifier)
                        .setLocale(const Locale('en'));
                    Navigator.pop(ctx);
                  },
                ),
                RadioListTile<String>(
                  title: const Text(AppL10n.gaeilge),
                  value: 'ga',
                  groupValue: locale.languageCode,
                  activeColor: const Color(0xFF1A7A3C),
                  onChanged: (_) {
                    dRef
                        .read(appLocaleProvider.notifier)
                        .setLocale(const Locale('ga'));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  AppL10n(locale).cancel,
                  style: const TextStyle(color: Color(0xFF888888)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale locale = ref.watch(appLocaleProvider);
    final AppL10n l10n = AppL10n(locale);
    final String langName =
        locale.languageCode == 'ga' ? AppL10n.gaeilge : AppL10n.english;

    return Drawer(
      child: Column(
        children: [
          // ── Profile Header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(color: Color(0xFF1A7A3C)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Farmer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Farrax Account',
                  style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
                ),
              ],
            ),
          ),

          // ── Menu items ──────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded,
                      color: Color(0xFF1A7A3C)),
                  title: Text(
                    l10n.language,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    langName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF888888),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFCCCCCC)),
                  onTap: () => _showLanguageDialog(context, ref),
                ),
              ],
            ),
          ),

          // ── Settings pinned at bottom ───────────────────────────────────
          const Divider(height: 1),
          ListTile(
            leading:
                const Icon(Icons.settings_outlined, color: Color(0xFF888888)),
            title: Text(
              l10n.settings,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/settings');
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
