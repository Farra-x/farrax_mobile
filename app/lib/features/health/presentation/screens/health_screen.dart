import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
import '../providers/health_provider.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F5),
        appBar: AppBar(
          title: const Text('Health'),
          backgroundColor: const Color(0xFF1A7A3C),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xCCFFFFFF),
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Cabinet'),
              Tab(text: 'TB Tests'),
              Tab(text: 'Alerts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(),
            _MedicineCabinetTab(),
            _TbTestingTab(),
            _AlertsTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<HealthEvent>> healthAsync =
        ref.watch(allHealthEventsProvider);

    return healthAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Color(0xFF1A7A3C))),
      error: (Object e, _) => Center(child: Text('Error: $e')),
      data: (List<HealthEvent> events) {
        if (events.isEmpty) {
          return _EmptyState(
            icon: Icons.favorite_rounded,
            message: 'No health events recorded',
            onAdd: () => context.push('/health/event/add'),
            addLabel: 'Add Health Event',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, int i) => _HealthEventTile(event: events[i]),
        );
      },
    );
  }
}

class _HealthEventTile extends StatelessWidget {
  final HealthEvent event;
  const _HealthEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFF0D6EAF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.health_and_safety_rounded,
                color: Color(0xFF0D6EAF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventType,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D1F14)),
                ),
                Text(
                  event.animalId,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('dd MMM yy').format(event.eventDate),
            style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
          ),
        ],
      ),
    );
  }
}

// ─── Medicine Cabinet Tab ─────────────────────────────────────────────────────

class _MedicineCabinetTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<MedicineCabinetItem>> cabinetAsync =
        ref.watch(medicineCabinetProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_health_medicine',
        onPressed: () => context.push('/health/medicine/add'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: cabinetAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A7A3C))),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (List<MedicineCabinetItem> items) {
          if (items.isEmpty) {
            return _EmptyState(
              icon: Icons.medication_rounded,
              message: 'Medicine cabinet is empty',
              onAdd: () => context.push('/health/medicine/add'),
              addLabel: 'Add Medicine',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, int i) => _CabinetTile(item: items[i]),
          );
        },
      ),
    );
  }
}

class _CabinetTile extends StatelessWidget {
  final MedicineCabinetItem item;
  const _CabinetTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = item.lowStockThreshold != null &&
        item.stockUnits != null &&
        item.stockUnits! <= item.lowStockThreshold!;

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
              color: const Color(0xFF0D6EAF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medication_rounded,
                color: Color(0xFF0D6EAF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.drugName,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D1F14)),
                ),
                Row(
                  children: [
                    if (item.stockUnits != null)
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
                ),
                if (item.expiryDate != null)
                  Text(
                    'Exp: ${DateFormat('dd/MM/yyyy').format(item.expiryDate!)}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFFAAAAAA)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TB Testing Tab ───────────────────────────────────────────────────────────

class _TbTestingTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<TbTestEvent>> tbAsync =
        ref.watch(allTbTestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_health_tb',
        onPressed: () => context.push('/health/tb/add'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: tbAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A7A3C))),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (List<TbTestEvent> tests) {
          if (tests.isEmpty) {
            return _EmptyState(
              icon: Icons.biotech_rounded,
              message: 'No TB tests recorded',
              onAdd: () => context.push('/health/tb/add'),
              addLabel: 'Add TB Test',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, int i) => _TbTestTile(test: tests[i]),
          );
        },
      ),
    );
  }
}

class _TbTestTile extends StatelessWidget {
  final TbTestEvent test;
  const _TbTestTile({required this.test});

  Color _resultColor(String result) {
    switch (result.toLowerCase()) {
      case 'clear':
        return const Color(0xFF1A7A3C);
      case 'reactor':
        return Colors.red;
      default:
        return const Color(0xFFF0A500);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color resultColor = _resultColor(test.result);
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
              color: resultColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.biotech_rounded, color: resultColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      test.animalId,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace'),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: resultColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        test.result.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                if (test.vetName != null)
                  Text(
                    'Vet: ${test.vetName}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF888888)),
                  ),
              ],
            ),
          ),
          Text(
            DateFormat('dd MMM yy').format(test.testDate),
            style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
          ),
        ],
      ),
    );
  }
}

// ─── Alerts Tab ───────────────────────────────────────────────────────────────

class _AlertsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AppNotification>> notifAsync =
        ref.watch(unreadNotificationsProvider);

    return notifAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A7A3C))),
      error: (Object e, _) => Center(child: Text('Error: $e')),
      data: (List<AppNotification> notifications) {
        if (notifications.isEmpty) {
          return const _EmptyState(
            icon: Icons.notifications_none_rounded,
            message: 'No unread alerts',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, int i) => _NotificationTile(
            notification: notifications[i],
            onMarkRead: () => ref
                .read(notificationRepositoryProvider)
                .markAsRead(notifications[i].id),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onMarkRead;
  const _NotificationTile(
      {required this.notification, required this.onMarkRead});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onMarkRead,
      child: Container(
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
                color: const Color(0xFFF0A500).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_rounded,
                  color: Color(0xFFF0A500), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D1F14)),
                  ),
                  Text(
                    notification.body,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF888888)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              DateFormat('dd MMM').format(notification.dueDate),
              style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onAdd;
  final String? addLabel;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.onAdd,
    this.addLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style:
                const TextStyle(color: Color(0xFF888888), fontSize: 16),
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A7A3C),
                foregroundColor: Colors.white,
              ),
              child: Text(addLabel ?? 'Add'),
            ),
          ],
        ],
      ),
    );
  }
}
