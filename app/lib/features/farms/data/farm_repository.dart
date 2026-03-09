import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/database.dart';

class FarmRepository {
  final FarraxDatabase _db;
  static const String _activeFarmKey = 'active_farm_id';

  FarmRepository(this._db);

  Stream<List<Farm>> watchAllFarms() =>
      (_db.select(_db.farms)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<Farm?> getFarmById(String id) =>
      (_db.select(_db.farms)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Farm?> getActiveFarm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = prefs.getString(_activeFarmKey);
    if (id == null) return null;
    return getFarmById(id);
  }

  Future<void> setActiveFarm(String farmId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeFarmKey, farmId);
  }

  Future<void> addFarm(FarmsCompanion farm) =>
      _db.into(_db.farms).insert(farm);

  Future<void> updateFarm(FarmsCompanion farm) =>
      (_db.update(_db.farms)..where((t) => t.id.equals(farm.id.value))).write(farm);

  Future<bool> hasFarms() async {
    final Expression<int> count = _db.farms.id.count();
    final query = _db.selectOnly(_db.farms)..addColumns([count]);
    final TypedResult row = await query.getSingle();
    return (row.read(count) ?? 0) > 0;
  }
}
