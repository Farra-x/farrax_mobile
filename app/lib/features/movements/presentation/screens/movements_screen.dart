import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
import '../providers/movement_provider.dart';

class MovementsScreen extends ConsumerWidget {
  const MovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MovementsFilter filter =
        ref.watch(movementsFilterNotifierProvider);
    final AsyncValue<List<MovementEvent>> movementsAsync =
        ref.watch(filteredMovementsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Movements'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_movements',
        onPressed: () => context.push('/movements/add'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: filter == MovementsFilter.all,
                  onTap: () => ref
                      .read(movementsFilterNotifierProvider.notifier)
                      .set(MovementsFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'In',
                  isSelected: filter == MovementsFilter.inbound,
                  onTap: () => ref
                      .read(movementsFilterNotifierProvider.notifier)
                      .set(MovementsFilter.inbound),
                  color: const Color(0xFF1A7A3C),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Out',
                  isSelected: filter == MovementsFilter.outbound,
                  onTap: () => ref
                      .read(movementsFilterNotifierProvider.notifier)
                      .set(MovementsFilter.outbound),
                  color: const Color(0xFFF0A500),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'This Month',
                  isSelected: filter == MovementsFilter.thisMonth,
                  onTap: () => ref
                      .read(movementsFilterNotifierProvider.notifier)
                      .set(MovementsFilter.thisMonth),
                ),
              ],
            ),
          ),

          Expanded(
            child: movementsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A7A3C)),
              ),
              error: (Object e, _) =>
                  Center(child: Text('Error: $e')),
              data: (List<MovementEvent> movements) {
                if (movements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swap_horiz_rounded,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'No movements recorded',
                          style: TextStyle(
                              color: Color(0xFF888888), fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => context.push('/movements/add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A7A3C),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Record Movement'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: movements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, int i) =>
                      _MovementTile(movement: movements[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = color ?? const Color(0xFF1A7A3C);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFDDDDDD),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final MovementEvent movement;
  const _MovementTile({required this.movement});

  @override
  Widget build(BuildContext context) {
    final bool isIn = movement.movementType == 'in';
    final Color badgeColor =
        isIn ? const Color(0xFF1A7A3C) : const Color(0xFFF0A500);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: badgeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      movement.animalId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1F14),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isIn ? 'IN' : 'OUT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  movement.destinationFarmName ??
                      movement.originFarmName ??
                      'Unknown farm',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('dd MMM yy').format(movement.eventDate),
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
