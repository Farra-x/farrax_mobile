import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';

class MovementRepository {
  final FarraxDatabase _db;
  MovementRepository(this._db);

  Future<void> addMovementEvent(MovementEventsCompanion event) =>
      _db.into(_db.movementEvents).insert(event);

  Future<void> addBatchMovement(
      List<String> animalIds, MovementEventsCompanion template) async {
    final String batchId = const Uuid().v4();
    for (final String animalId in animalIds) {
      await _db.into(_db.movementEvents).insert(
            template.copyWith(
              id: Value(const Uuid().v4()),
              animalId: Value(animalId),
              batchId: Value(batchId),
            ),
          );
    }
  }

  Stream<List<MovementEvent>> watchMovementsForAnimal(String animalId) =>
      (_db.select(_db.movementEvents)
        ..where((t) => t.animalId.equals(animalId))
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .watch();

  Stream<List<MovementEvent>> watchAllMovements() =>
      (_db.select(_db.movementEvents)
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .watch();

  Future<int> countMovementsThisMonth() async {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(now.year, now.month);
    final DateTime end = DateTime(now.year, now.month + 1);
    final Expression<int> count = _db.movementEvents.id.count();
    final query = _db.selectOnly(_db.movementEvents)
      ..addColumns([count])
      ..where(_db.movementEvents.eventDate.isBiggerOrEqualValue(start) &
          _db.movementEvents.eventDate.isSmallerThanValue(end));
    final TypedResult row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
