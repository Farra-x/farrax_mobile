import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class NotificationRepository {
  final FarraxDatabase _db;
  NotificationRepository(this._db);

  Stream<List<AppNotification>> watchUnreadNotifications() =>
      (_db.select(_db.notifications)
        ..where((t) => t.isRead.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .watch();

  Future<void> addNotification(NotificationsCompanion n) =>
      _db.into(_db.notifications).insert(n);

  Future<void> markAsRead(String id) =>
      (_db.update(_db.notifications)..where((t) => t.id.equals(id)))
          .write(const NotificationsCompanion(isRead: Value(true)));

  Future<int> countUnread() async {
    final Expression<int> count = _db.notifications.id.count();
    final query = _db.selectOnly(_db.notifications)
      ..addColumns([count])
      ..where(_db.notifications.isRead.equals(false));
    final TypedResult row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
