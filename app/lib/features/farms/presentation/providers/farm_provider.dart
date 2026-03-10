import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/farm_repository.dart';

part 'farm_provider.g.dart';

@Riverpod(keepAlive: true)
FarmRepository farmRepository(FarmRepositoryRef ref) =>
    FarmRepository(ref.watch(databaseProvider));

@riverpod
Future<Farm?> activeFarm(ActiveFarmRef ref) =>
    ref.watch(farmRepositoryProvider).getActiveFarm();

@riverpod
Stream<List<Farm>> allFarms(AllFarmsRef ref) =>
    ref.watch(farmRepositoryProvider).watchAllFarms();

@riverpod
Future<bool> hasFarms(HasFarmsRef ref) =>
    ref.watch(farmRepositoryProvider).hasFarms();
