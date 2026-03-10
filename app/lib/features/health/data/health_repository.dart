import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class HealthRepository {
  final FarraxDatabase _db;
  HealthRepository(this._db);

  Future<void> addTbTest(TbTestEventsCompanion event) =>
      _db.into(_db.tbTestEvents).insert(event);

  Future<void> addHealthEvent(HealthEventsCompanion event) =>
      _db.into(_db.healthEvents).insert(event);

  Stream<List<TbTestEvent>> watchTbTestsForAnimal(String animalId) =>
      (_db.select(_db.tbTestEvents)
        ..where((t) => t.animalId.equals(animalId))
        ..orderBy([(t) => OrderingTerm.desc(t.testDate)]))
          .watch();

  Stream<List<HealthEvent>> watchHealthEventsForAnimal(String animalId) =>
      (_db.select(_db.healthEvents)
        ..where((t) => t.animalId.equals(animalId))
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .watch();

  Stream<List<TbTestEvent>> watchAllTbTests() =>
      (_db.select(_db.tbTestEvents)
        ..orderBy([(t) => OrderingTerm.desc(t.testDate)]))
          .watch();

  Stream<List<HealthEvent>> watchAllHealthEvents() =>
      (_db.select(_db.healthEvents)
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .watch();
}
