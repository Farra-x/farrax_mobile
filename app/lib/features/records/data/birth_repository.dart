import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class BirthRepository {
  final FarraxDatabase _db;
  BirthRepository(this._db);

  Future<void> addBirthEvent(BirthEventsCompanion event) =>
      _db.into(_db.birthEvents).insert(event);

  Stream<List<BirthEvent>> watchBirthsForAnimal(String animalId) =>
      (_db.select(_db.birthEvents)
        ..where((t) => t.animalId.equals(animalId))
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .watch();

  Future<int> countBirthsThisMonth() async {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(now.year, now.month);
    final DateTime end = DateTime(now.year, now.month + 1);
    final Expression<int> count = _db.birthEvents.id.count();
    final query = _db.selectOnly(_db.birthEvents)
      ..addColumns([count])
      ..where(_db.birthEvents.eventDate.isBiggerOrEqualValue(start) &
          _db.birthEvents.eventDate.isSmallerThanValue(end));
    final TypedResult row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
