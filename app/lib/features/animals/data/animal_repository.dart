import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class AnimalRepository {
  final FarraxDatabase _db;

  AnimalRepository(this._db);

  // ─── Animals ──────────────────────────────────────────────────────────────

  Stream<List<Animal>> watchAllAnimals() =>
      (_db.select(_db.animals)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<List<Animal>> watchAnimalsFiltered({
    String? search,
    String? sex,
    bool? activeOnly,
  }) =>
      (_db.select(_db.animals)
        ..where((tbl) {
          Expression<bool> expr = const Constant(true);
          if (search != null && search.isNotEmpty) {
            expr = expr &
                (tbl.tagNumber.contains(search.toUpperCase()) |
                    tbl.breed.contains(search));
          }
          if (sex != null) {
            expr = expr & tbl.sex.equals(sex);
          }
          if (activeOnly == true) {
            expr = expr & tbl.isActive.equals(true);
          }
          return expr;
        })
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<List<Animal>> watchRecentAnimals({int limit = 5}) =>
      (_db.select(_db.animals)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(limit))
          .watch();

  Stream<Animal?> watchAnimal(String id) =>
      (_db.select(_db.animals)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<Animal?> findByTagNumber(String tagNumber) =>
      (_db.select(_db.animals)
            ..where((t) => t.tagNumber.equals(tagNumber)))
          .getSingleOrNull();

  Future<void> addAnimal(AnimalsCompanion animal) =>
      _db.into(_db.animals).insert(animal);

  Future<void> updateAnimal(AnimalsCompanion animal) =>
      (_db.update(_db.animals)
            ..where((t) => t.id.equals(animal.id.value)))
          .write(animal);

  Future<int> countAnimals() async {
    final Expression<int> count = _db.animals.id.count();
    final query = _db.selectOnly(_db.animals)..addColumns([count]);
    final TypedResult row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> countBirthsThisMonth() async {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(now.year, now.month);
    final DateTime end = DateTime(now.year, now.month + 1);
    final Expression<int> count = _db.birthEvents.id.count();
    final query = _db.selectOnly(_db.birthEvents)
      ..addColumns([count])
      ..where(
        _db.birthEvents.eventDate.isBiggerOrEqualValue(start) &
            _db.birthEvents.eventDate.isSmallerThanValue(end),
      );
    final TypedResult row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> countMovementsThisMonth() async {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(now.year, now.month);
    final DateTime end = DateTime(now.year, now.month + 1);
    final Expression<int> count = _db.movementEvents.id.count();
    final query = _db.selectOnly(_db.movementEvents)
      ..addColumns([count])
      ..where(
        _db.movementEvents.eventDate.isBiggerOrEqualValue(start) &
            _db.movementEvents.eventDate.isSmallerThanValue(end),
      );
    final TypedResult row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  // ─── Events ───────────────────────────────────────────────────────────────

  Stream<List<BirthEvent>> watchBirthEvents(String animalId) =>
      (_db.select(_db.birthEvents)
        ..where((t) => t.animalId.equals(animalId))
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .watch();

  Stream<List<MovementEvent>> watchMovementEvents(String animalId) =>
      (_db.select(_db.movementEvents)
        ..where((t) => t.animalId.equals(animalId))
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .watch();

  Stream<List<MedicineEvent>> watchMedicineEvents(String animalId) =>
      (_db.select(_db.medicineEvents)
        ..where((t) => t.animalId.equals(animalId))
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .watch();

  Stream<List<DeathEvent>> watchDeathEvents(String animalId) =>
      (_db.select(_db.deathEvents)
        ..where((t) => t.animalId.equals(animalId)))
          .watch();

  Stream<List<TbTestEvent>> watchTbTestEvents(String animalId) =>
      (_db.select(_db.tbTestEvents)
        ..where((t) => t.animalId.equals(animalId))
        ..orderBy([(t) => OrderingTerm.desc(t.testDate)]))
          .watch();

  Stream<List<HealthEvent>> watchHealthEvents(String animalId) =>
      (_db.select(_db.healthEvents)
        ..where((t) => t.animalId.equals(animalId))
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .watch();
}
