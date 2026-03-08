import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
import '../providers/animal_provider.dart';

class AnimalDetailScreen extends ConsumerWidget {
  final String animalId;
  const AnimalDetailScreen({super.key, required this.animalId});

  String _age(DateTime dob) {
    final int days = DateTime.now().difference(dob).inDays;
    if (days < 30) return '$days days';
    if (days < 365) return '${(days / 30).floor()} months';
    final int years = (days / 365).floor();
    final int months = ((days % 365) / 30).floor();
    return months > 0 ? '${years}y ${months}m' : '${years}y';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Animal?> animalAsync =
        ref.watch(animalDetailProvider(animalId));

    return animalAsync.when(
      loading: () => const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFF1A7A3C))),
      ),
      error: (Object e, _) => Scaffold(
        appBar: AppBar(title: const Text('Animal')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (Animal? animal) {
        if (animal == null) {
          return Scaffold(
            appBar: AppBar(),
            body:
                const Center(child: Text('Animal not found')),
          );
        }
        return _AnimalDetailView(
            animal: animal, age: _age(animal.dateOfBirth));
      },
    );
  }
}

// ─── Detail View ──────────────────────────────────────────────────────────────

class _AnimalDetailView extends ConsumerWidget {
  final Animal animal;
  final String age;
  const _AnimalDetailView({required this.animal, required this.age});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BirthEvent>> births =
        ref.watch(animalBirthEventsProvider(animal.id));
    final AsyncValue<List<MovementEvent>> movements =
        ref.watch(animalMovementEventsProvider(animal.id));
    final AsyncValue<List<MedicineEvent>> medicines =
        ref.watch(animalMedicineEventsProvider(animal.id));
    final AsyncValue<List<DeathEvent>> deaths =
        ref.watch(animalDeathEventsProvider(animal.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF1A7A3C),
            foregroundColor: Colors.white,
            expandedHeight: 120,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.tagNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'monospace',
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${animal.breed} · ${animal.sex == 'M' ? 'Male' : 'Female'} · $age',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xCCFFFFFF),
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
                const SizedBox(height: 16),

                // ── Header Card ────────────────────────────────────────
                _Card(
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.tag_rounded,
                        label: 'Tag',
                        value: animal.tagNumber,
                        mono: true,
                      ),
                      _InfoRow(
                        icon: Icons.pets_rounded,
                        label: 'Breed',
                        value: animal.breed,
                      ),
                      _InfoRow(
                        icon: animal.sex == 'M'
                            ? Icons.male_rounded
                            : Icons.female_rounded,
                        label: 'Sex',
                        value: animal.sex == 'M' ? 'Male' : 'Female',
                      ),
                      _InfoRow(
                        icon: Icons.cake_rounded,
                        label: 'Date of Birth',
                        value: DateFormat('dd MMM yyyy')
                            .format(animal.dateOfBirth),
                      ),
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Age',
                        value: age,
                      ),
                      _InfoRow(
                        icon: Icons.home_rounded,
                        label: 'Herd No.',
                        value: animal.herdNumber,
                      ),
                      if (animal.damTagNumber != null)
                        _InfoRow(
                          icon: Icons.female_rounded,
                          label: 'Dam Tag',
                          value: animal.damTagNumber!,
                          mono: true,
                        ),
                      if (animal.sireTagNumber != null)
                        _InfoRow(
                          icon: Icons.male_rounded,
                          label: 'Sire Tag',
                          value: animal.sireTagNumber!,
                          mono: true,
                        ),
                      _InfoRow(
                        icon: Icons.circle,
                        label: 'Status',
                        value: animal.isActive ? 'Active' : 'Inactive',
                        valueColor: animal.isActive
                            ? const Color(0xFF1A7A3C)
                            : Colors.grey,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Action Buttons ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _ActionButton(
                        icon: Icons.swap_horiz_rounded,
                        label: 'Movement',
                        color: const Color(0xFFF0A500),
                        onTap: () => context
                            .push('/movements/add?animalId=${animal.id}'),
                      ),
                      const SizedBox(width: 10),
                      _ActionButton(
                        icon: Icons.medical_services_rounded,
                        label: 'Health',
                        color: const Color(0xFF0D6EAF),
                        onTap: () => context
                            .push('/health/add?animalId=${animal.id}'),
                      ),
                      const SizedBox(width: 10),
                      _ActionButton(
                        icon: Icons.edit_rounded,
                        label: 'Edit',
                        color: const Color(0xFF555555),
                        onTap: () =>
                            context.push('/animals/${animal.id}/edit'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Event Timeline ─────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'Event Timeline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D1F14),
                    ),
                  ),
                ),

                _TimelineSection(
                  births: births,
                  movements: movements,
                  medicines: medicines,
                  deaths: deaths,
                  animalDob: animal.dateOfBirth,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Timeline ─────────────────────────────────────────────────────────────────

class _TimelineSection extends StatelessWidget {
  final AsyncValue<List<BirthEvent>> births;
  final AsyncValue<List<MovementEvent>> movements;
  final AsyncValue<List<MedicineEvent>> medicines;
  final AsyncValue<List<DeathEvent>> deaths;
  final DateTime animalDob;

  const _TimelineSection({
    required this.births,
    required this.movements,
    required this.medicines,
    required this.deaths,
    required this.animalDob,
  });

  @override
  Widget build(BuildContext context) {
    final List<_TimelineItem> items = [];

    // Add birth events
    births.whenData((List<BirthEvent> list) {
      for (final BirthEvent e in list) {
        items.add(_TimelineItem(
          date: e.birthDate,
          icon: Icons.child_care_rounded,
          color: const Color(0xFF1A7A3C),
          title: 'Birth Recorded',
          subtitle: 'Difficulty: ${e.difficultyScore}/5'
              '${e.vetInvolved ? ' · Vet involved' : ''}',
        ));
      }
    });

    // Add movement events
    movements.whenData((List<MovementEvent> list) {
      for (final MovementEvent e in list) {
        items.add(_TimelineItem(
          date: e.movementDate,
          icon: Icons.swap_horiz_rounded,
          color: const Color(0xFFF0A500),
          title: 'Movement ${e.direction}',
          subtitle: [
            if (e.fromHerdNumber != null) 'From: ${e.fromHerdNumber}',
            if (e.toHerdNumber != null) 'To: ${e.toHerdNumber}',
            if (e.reason != null) e.reason!,
          ].join(' · '),
        ));
      }
    });

    // Add medicine events
    medicines.whenData((List<MedicineEvent> list) {
      for (final MedicineEvent e in list) {
        items.add(_TimelineItem(
          date: e.administeredDate,
          icon: Icons.medical_services_rounded,
          color: const Color(0xFF0D6EAF),
          title: e.medicineName,
          subtitle:
              '${e.dosage}${e.dosageUnit} · ${e.route}',
        ));
      }
    });

    // Add death events
    deaths.whenData((List<DeathEvent> list) {
      for (final DeathEvent e in list) {
        items.add(_TimelineItem(
          date: e.deathDate,
          icon: Icons.cancel_rounded,
          color: Colors.red,
          title: 'Death / Disposal',
          subtitle: [
            if (e.cause != null) e.cause!,
            if (e.disposalMethod != null) e.disposalMethod!,
          ].join(' · '),
        ));
      }
    });

    // Sort newest first
    items.sort((a, b) => b.date.compareTo(a.date));

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: _Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(Icons.history_rounded,
                    size: 40, color: Colors.grey[300]),
                const SizedBox(height: 8),
                const Text(
                  'No events recorded yet',
                  style: TextStyle(
                      color: Color(0xFF888888), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _Card(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, int i) => _TimelineTile(item: items[i]),
        ),
      ),
    );
  }
}

class _TimelineItem {
  final DateTime date;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _TimelineItem({
    required this.date,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

class _TimelineTile extends StatelessWidget {
  final _TimelineItem item;
  const _TimelineTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1F14),
                  ),
                ),
                if (item.subtitle.isNotEmpty)
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            DateFormat('dd MMM yy').format(item.date),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFAAAAAA),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool mono;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon,
              size: 16, color: const Color(0xFF1A7A3C).withValues(alpha: 0.7)),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF0D1F14),
                fontFamily: mono ? 'monospace' : null,
                letterSpacing: mono ? 0.5 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
