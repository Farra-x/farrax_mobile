import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

class MedicineRepository {
  final FarraxDatabase _db;
  MedicineRepository(this._db);

  Future<void> addTreatment(MedicineEventsCompanion event) =>
      _db.into(_db.medicineEvents).insert(event);

  Stream<List<MedicineCabinetItem>> watchCabinet() =>
      (_db.select(_db.medicineCabinet)
        ..orderBy([(t) => OrderingTerm.asc(t.drugName)]))
          .watch();

  Future<void> addToCabinet(MedicineCabinetCompanion item) =>
      _db.into(_db.medicineCabinet).insert(item);

  Future<void> updateCabinetItem(MedicineCabinetCompanion item) =>
      (_db.update(_db.medicineCabinet)
            ..where((t) => t.id.equals(item.id.value)))
          .write(item);

  Stream<List<MedicineEvent>> watchTreatmentsForAnimal(String animalId) =>
      (_db.select(_db.medicineEvents)
        ..where((t) => t.animalId.equals(animalId))
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .watch();

  Stream<List<MedicineEvent>> watchAllTreatments() =>
      (_db.select(_db.medicineEvents)
        ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
          .watch();

  static List<String> preloadedDrugNames() => const [
        'Nuflor',
        'Metacam',
        'Dectomax',
        'Ivomec',
        'Draxxin',
        'Excenel',
        'Engemycin',
        'Noromycin',
        'Alamycin',
        'Terramycin',
        'Pen & Strep',
        'Depocillin',
        'Duplocillin',
        'Baytril',
        'Marbocyl',
        'Advocin',
        'Betamox',
        'Synulox',
        'Convenia',
        'Therios',
        'Dexadreson',
        'Rapidexon',
        'Solu-Delta-Cortef',
        'Finadyne',
        'Kinetic',
        'Tolfine',
        'Rheumocam',
        'Loxicom',
        'Meloxidyl',
        'Bursolin',
      ];
}
