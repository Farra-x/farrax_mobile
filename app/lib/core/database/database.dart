import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ─── Tables ───────────────────────────────────────────────────────────────

class Animals extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();         // UUID
  TextColumn get tagNumber => text().withLength(min: 5, max: 20)();   // IE141123456789
  TextColumn get sex => text().withLength(min: 1, max: 1)();          // M / F
  TextColumn get breed => text().withLength(min: 2, max: 50)();
  DateTimeColumn get dateOfBirth => dateTime()();
  TextColumn get damTagNumber => text().nullable()();
  TextColumn get sireTagNumber => text().nullable()();
  TextColumn get herdNumber => text()();                               // BTE herd number
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class BirthEvents extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get animalId => text().references(Animals, #id)();
  DateTimeColumn get birthDate => dateTime()();
  IntColumn get difficultyScore => integer().withDefault(const Constant(1))(); // 1-5
  BoolColumn get vetInvolved => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DeathEvents extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get animalId => text().references(Animals, #id)();
  DateTimeColumn get deathDate => dateTime()();
  TextColumn get cause => text().nullable()();
  TextColumn get disposalMethod => text().nullable()(); // knackery / slaughter / etc.
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MovementEvents extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get animalId => text().references(Animals, #id)();
  TextColumn get direction => text()();                        // IN / OUT
  DateTimeColumn get movementDate => dateTime()();
  TextColumn get fromHerdNumber => text().nullable()();
  TextColumn get toHerdNumber => text().nullable()();
  TextColumn get reason => text().nullable()();               // sale / purchase / agistment
  BoolColumn get reportedToAim => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MedicineEvents extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get animalId => text().references(Animals, #id)();
  TextColumn get medicineName => text()();
  TextColumn get batchNumber => text().nullable()();
  RealColumn get dosage => real()();
  TextColumn get dosageUnit => text()();                      // ml / mg / tablets
  TextColumn get route => text()();                          // oral / injection / topical
  DateTimeColumn get administeredDate => dateTime()();
  IntColumn get withdrawalDays => integer().withDefault(const Constant(0))();
  DateTimeColumn get withdrawalEndDate => dateTime().nullable()();
  TextColumn get administeredBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TbTests extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get animalId => text().references(Animals, #id)();
  DateTimeColumn get testDate => dateTime()();
  TextColumn get result => text()();                         // PASS / FAIL / INCONCLUSIVE
  TextColumn get vetName => text().nullable()();
  DateTimeColumn get nextTestDue => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Database ─────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Animals,
  BirthEvents,
  DeathEvents,
  MovementEvents,
  MedicineEvents,
  TbTests,
])
class FarraxDatabase extends _$FarraxDatabase {
  FarraxDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'farrax.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
