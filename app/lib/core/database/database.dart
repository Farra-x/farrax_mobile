import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ─── Tables ───────────────────────────────────────────────────────────────

class Farms extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get name => text()();
  TextColumn get herdNumber => text()();
  TextColumn get address => text().nullable()();
  TextColumn get country => text().withDefault(const Constant('IE'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

class Animals extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get farmId => text().nullable().references(Farms, #id)();
  TextColumn get tagNumber => text().withLength(min: 5, max: 20)();
  TextColumn get sex => text().withLength(min: 1, max: 1)();
  TextColumn get breed => text().withLength(min: 2, max: 50)();
  DateTimeColumn get dateOfBirth => dateTime()();
  TextColumn get damTagNumber => text().nullable()();
  TextColumn get sireTagNumber => text().nullable()();
  TextColumn get herdNumber => text()();
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
  TextColumn get farmId => text().nullable().references(Farms, #id)();
  TextColumn get damTagNumber => text().nullable()();
  TextColumn get sireTagNumber => text().nullable()();
  IntColumn get calvingDifficulty => integer().nullable()();
  RealColumn get birthWeight => real().nullable()();
  BoolColumn get isAssisted => boolean().withDefault(const Constant(false))();
  BoolColumn get isStillborn => boolean().withDefault(const Constant(false))();
  BoolColumn get vetAttended => boolean().withDefault(const Constant(false))();
  BoolColumn get colostrumFed => boolean().withDefault(const Constant(false))();
  BoolColumn get isTwin => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get eventDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class DeathEvents extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get animalId => text().references(Animals, #id)();
  TextColumn get farmId => text().nullable().references(Farms, #id)();
  DateTimeColumn get eventDate => dateTime()();
  TextColumn get causeOfDeath => text().nullable()();
  TextColumn get disposalMethod => text().nullable()();
  RealColumn get slaughterWeight => real().nullable()();
  BoolColumn get tagReturned => boolean().withDefault(const Constant(false))();
  BoolColumn get vetConfirmed => boolean().withDefault(const Constant(false))();
  BoolColumn get authoritiesNotified => boolean().withDefault(const Constant(false))();
  IntColumn get ageAtDeath => integer().nullable()();
  RealColumn get estimatedValue => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class MovementEvents extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get animalId => text().references(Animals, #id)();
  TextColumn get farmId => text().nullable().references(Farms, #id)();
  TextColumn get batchId => text().nullable()();
  TextColumn get movementType => text()(); // 'in' or 'out'
  DateTimeColumn get eventDate => dateTime()();
  TextColumn get originFarmName => text().nullable()();
  TextColumn get destinationFarmName => text().nullable()();
  TextColumn get destinationHerdNumber => text().nullable()();
  TextColumn get transportCompany => text().nullable()();
  TextColumn get vehicleRegistration => text().nullable()();
  RealColumn get distanceKm => real().nullable()();
  TextColumn get movementDocNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class MedicineEvents extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get animalId => text().references(Animals, #id)();
  TextColumn get farmId => text().nullable().references(Farms, #id)();
  TextColumn get drugName => text()();
  TextColumn get batchNumber => text().nullable()();
  RealColumn get doseGiven => real().nullable()();
  TextColumn get doseUnit => text().nullable()();
  TextColumn get route => text().nullable()();
  IntColumn get withdrawalMeatDays => integer().nullable()();
  IntColumn get withdrawalMilkDays => integer().nullable()();
  DateTimeColumn get meatClearDate => dateTime().nullable()();
  DateTimeColumn get milkClearDate => dateTime().nullable()();
  TextColumn get treatedBy => text().nullable()();
  TextColumn get vetName => text().nullable()();
  TextColumn get diagnosis => text().nullable()();
  TextColumn get medicineCabinetItemId => text().nullable()();
  DateTimeColumn get eventDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class TbTestEvents extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get animalId => text().references(Animals, #id)();
  TextColumn get farmId => text().nullable().references(Farms, #id)();
  DateTimeColumn get testDate => dateTime()();
  TextColumn get vetName => text().nullable()();
  TextColumn get vetNumber => text().nullable()();
  TextColumn get testType => text()(); // 'herd' or 'individual'
  TextColumn get result => text()(); // 'clear/reactor/inconclusive'
  DateTimeColumn get nextTestDueDate => dateTime().nullable()();
  BoolColumn get isRestricted => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MedicineCabinetItem')
class MedicineCabinet extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get farmId => text().nullable().references(Farms, #id)();
  TextColumn get drugName => text()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  TextColumn get batchNumber => text().nullable()();
  TextColumn get supplier => text().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  RealColumn get stockUnits => real().nullable()();
  TextColumn get stockUnitType => text().nullable()();
  RealColumn get lowStockThreshold => real().nullable()();
  IntColumn get withdrawalMeatDays => integer().nullable()();
  IntColumn get withdrawalMilkDays => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class HealthEvents extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get animalId => text().references(Animals, #id)();
  TextColumn get farmId => text().nullable().references(Farms, #id)();
  TextColumn get eventType => text()(); // bvd/vaccination/bcs/weight/pregnancy/fertility
  DateTimeColumn get eventDate => dateTime()();
  TextColumn get result => text().nullable()();
  RealColumn get value => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get vetName => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get syncedToServer => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppNotification')
class Notifications extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get farmId => text().nullable().references(Farms, #id)();
  TextColumn get animalId => text().nullable().references(Animals, #id)();
  TextColumn get type => text()(); // withdrawal/tb_due/birthday/movement/medicine_restock
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get dueDate => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Farms,
  Animals,
  BirthEvents,
  DeathEvents,
  MovementEvents,
  MedicineEvents,
  TbTestEvents,
  MedicineCabinet,
  HealthEvents,
  Notifications,
])
class FarraxDatabase extends _$FarraxDatabase {
  FarraxDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      for (final TableInfo<Table, dynamic> tbl in allTables.toList().reversed) {
        await m.deleteTable(tbl.actualTableName);
      }
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
