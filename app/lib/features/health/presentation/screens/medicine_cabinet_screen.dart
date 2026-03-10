import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
import '../providers/health_provider.dart';

class MedicineCabinetScreen extends ConsumerWidget {
  const MedicineCabinetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<MedicineCabinetItem>> cabinetAsync =
        ref.watch(medicineCabinetProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Medicine Cabinet'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Medicine',
            onPressed: () => context.push('/health/medicine/add'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_medicine_cabinet',
        onPressed: () => context.push('/health/medicine/add'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: cabinetAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A7A3C)),
        ),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (List<MedicineCabinetItem> items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication_rounded,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Medicine cabinet is empty',
                    style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add medicines to track stock\nand withdrawal periods.',
                    style: TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 13,
                        height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/health/medicine/add'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Medicine'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A7A3C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }

          // Summary row
          final int lowStock = items
              .where((MedicineCabinetItem i) =>
                  i.lowStockThreshold != null &&
                  i.stockUnits != null &&
                  i.stockUnits! <= i.lowStockThreshold!)
              .length;

          return Column(
            children: [
              // Summary banner
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    _SummaryChip(
                      label: '${items.length}',
                      sublabel: 'medicines',
                      color: const Color(0xFF1A7A3C),
                      icon: Icons.medication_rounded,
                    ),
                    const SizedBox(width: 16),
                    if (lowStock > 0)
                      _SummaryChip(
                        label: '$lowStock',
                        sublabel: 'low stock',
                        color: Colors.orange,
                        icon: Icons.warning_amber_rounded,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, int i) =>
                      _MedicineTile(item: items[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final IconData icon;

  const _SummaryChip({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            '$label $sublabel',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineTile extends StatelessWidget {
  final MedicineCabinetItem item;
  const _MedicineTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = item.lowStockThreshold != null &&
        item.stockUnits != null &&
        item.stockUnits! <= item.lowStockThreshold!;

    final bool isExpiringSoon = item.expiryDate != null &&
        item.expiryDate!.isBefore(
            DateTime.now().add(const Duration(days: 30)));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLowStock
              ? Colors.orange.withValues(alpha: 0.4)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0D6EAF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication_rounded,
                color: Color(0xFF0D6EAF), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.drugName,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D1F14)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.stockUnits != null) ...[
                      Text(
                        'Stock: ${item.stockUnits} ${item.stockUnitType ?? ''}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888)),
                      ),
                      if (isLowStock) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Low Stock',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
                if (item.expiryDate != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: 12,
                        color: isExpiringSoon
                            ? Colors.red
                            : const Color(0xFFAAAAAA),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Exp: ${DateFormat('dd/MM/yyyy').format(item.expiryDate!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isExpiringSoon
                              ? Colors.red
                              : const Color(0xFFAAAAAA),
                          fontWeight: isExpiringSoon
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
                if (item.withdrawalMeatDays != null ||
                    item.withdrawalMilkDays != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (item.withdrawalMeatDays != null)
                        'Meat: ${item.withdrawalMeatDays}d',
                      if (item.withdrawalMilkDays != null)
                        'Milk: ${item.withdrawalMilkDays}d',
                    ].join('  '),
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFFAAAAAA)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
