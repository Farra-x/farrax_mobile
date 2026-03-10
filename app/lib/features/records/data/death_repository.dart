import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class DeathRepository {
  final FarraxDatabase _db;
  DeathRepository(this._db);

  Future<void> addDeathEvent(DeathEventsCompanion event) =>
      _db.into(_db.deathEvents).insert(event);

  Stream<List<DeathEvent>> watchDeathsForAnimal(String animalId) =>
      (_db.select(_db.deathEvents)
        ..where((t) => t.animalId.equals(animalId))
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .watch();
}
