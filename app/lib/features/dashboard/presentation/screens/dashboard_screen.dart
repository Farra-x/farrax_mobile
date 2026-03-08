import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../../scanner/presentation/providers/scanner_provider.dart';
import '../../../scanner/presentation/widgets/scan_input_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, Farmer';
    if (hour < 17) return 'Good afternoon, Farmer';
    return 'Good evening, Farmer';
  }

  void _openScanner(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanInputSheet(tagHandler: ref.read(tagHandlerProvider)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardStats> stats = ref.watch(dashboardStatsProvider);
    final AsyncValue<List<Animal>> recent = ref.watch(recentAnimalsProvider);
    final String? connectedName = ref.watch(connectedDeviceNameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
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
                    const EdgeInsets.fromLTRB(20, 0, 20, 14),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
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
                      const Text(
                        'No reader connected',
                        style: TextStyle(
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
                            label: 'Total Animals',
                            value: '${s.totalAnimals}',
                            icon: Icons.pets_rounded,
                            color: const Color(0xFF1A7A3C),
                          ),
                          _StatCard(
                            label: 'Births (month)',
                            value: '${s.birthsThisMonth}',
                            icon: Icons.child_care_rounded,
                            color: const Color(0xFF0D6EAF),
                          ),
                          _StatCard(
                            label: 'Movements',
                            value: '${s.movementsThisMonth}',
                            icon: Icons.swap_horiz_rounded,
                            color: const Color(0xFFF0A500),
                          ),
                          _StatCard(
                            label: 'Health Alerts',
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      'Quick Actions',
                      style: TextStyle(
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
                          label: 'Register Calf',
                          color: const Color(0xFF1A7A3C),
                          onTap: () => context.push('/animals/add'),
                        ),
                        _ActionTile(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Record Movement',
                          color: const Color(0xFFF0A500),
                          onTap: () => context.push('/movements/add'),
                        ),
                        _ActionTile(
                          icon: Icons.medical_services_rounded,
                          label: 'Health Event',
                          color: const Color(0xFF0D6EAF),
                          onTap: () => context.push('/health/add'),
                        ),
                        _ActionTile(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Scan Tag',
                          color: const Color(0xFF333333),
                          onTap: () => _openScanner(context, ref),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Recent Activity ──────────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      'Recent Activity',
                      style: TextStyle(
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
                                  const Text(
                                    'No activity yet.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF555555),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Register your first animal to get started.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
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
                                    child: const Text('Register First Animal'),
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
      padding: const EdgeInsets.all(16),
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

class _RecentAnimalTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                  animal.isActive ? 'Active' : 'Inactive',
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
