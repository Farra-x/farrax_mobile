import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/services/tag_handler.dart';
import '../../data/animal_repository.dart';

part 'animal_provider.g.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
AnimalRepository animalRepository(AnimalRepositoryRef ref) =>
    AnimalRepository(ref.watch(databaseProvider));

// ─── Tag Handler ──────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
TagHandler tagHandler(TagHandlerRef ref) =>
    TagHandler(ref.watch(databaseProvider));

// ─── Filter State ─────────────────────────────────────────────────────────────

enum AnimalFilterOption { all, active, male, female }

@riverpod
class AnimalListFilter extends _$AnimalListFilter {
  @override
  AnimalFilterOption build() => AnimalFilterOption.all;
  void set(AnimalFilterOption f) => state = f;
}

@riverpod
class AnimalSearchQuery extends _$AnimalSearchQuery {
  @override
  String build() => '';
  void set(String q) => state = q;
}

// ─── Animal Lists ─────────────────────────────────────────────────────────────

@riverpod
Stream<List<Animal>> filteredAnimals(FilteredAnimalsRef ref) {
  final AnimalFilterOption filter = ref.watch(animalListFilterProvider);
  final String search = ref.watch(animalSearchQueryProvider);
  final AnimalRepository repo = ref.watch(animalRepositoryProvider);

  String? sex;
  bool? activeOnly;
  switch (filter) {
    case AnimalFilterOption.male:
      sex = 'M';
    case AnimalFilterOption.female:
      sex = 'F';
    case AnimalFilterOption.active:
      activeOnly = true;
    case AnimalFilterOption.all:
      break;
  }

  return repo.watchAnimalsFiltered(
    search: search.isEmpty ? null : search,
    sex: sex,
    activeOnly: activeOnly,
  );
}

@riverpod
Stream<List<Animal>> recentAnimals(RecentAnimalsRef ref) =>
    ref.watch(animalRepositoryProvider).watchRecentAnimals();

@riverpod
Stream<List<Animal>> allAnimals(AllAnimalsRef ref) =>
    ref.watch(animalRepositoryProvider).watchAnimalsFiltered();

// ─── Single Animal ────────────────────────────────────────────────────────────

@riverpod
Stream<Animal?> animalDetail(AnimalDetailRef ref, String id) =>
    ref.watch(animalRepositoryProvider).watchAnimal(id);

@riverpod
Stream<List<BirthEvent>> animalBirthEvents(
        AnimalBirthEventsRef ref, String animalId) =>
    ref.watch(animalRepositoryProvider).watchBirthEvents(animalId);

@riverpod
Stream<List<MovementEvent>> animalMovementEvents(
        AnimalMovementEventsRef ref, String animalId) =>
    ref.watch(animalRepositoryProvider).watchMovementEvents(animalId);

@riverpod
Stream<List<MedicineEvent>> animalMedicineEvents(
        AnimalMedicineEventsRef ref, String animalId) =>
    ref.watch(animalRepositoryProvider).watchMedicineEvents(animalId);

@riverpod
Stream<List<DeathEvent>> animalDeathEvents(
        AnimalDeathEventsRef ref, String animalId) =>
    ref.watch(animalRepositoryProvider).watchDeathEvents(animalId);

@riverpod
Stream<List<TbTestEvent>> animalTbTestEvents(
        AnimalTbTestEventsRef ref, String animalId) =>
    ref.watch(animalRepositoryProvider).watchTbTestEvents(animalId);

@riverpod
Stream<List<HealthEvent>> animalHealthEvents(
        AnimalHealthEventsRef ref, String animalId) =>
    ref.watch(animalRepositoryProvider).watchHealthEvents(animalId);

// ─── Dashboard Stats ──────────────────────────────────────────────────────────

class DashboardStats {
  final int totalAnimals;
  final int birthsThisMonth;
  final int movementsThisMonth;
  final int pendingAlerts;

  const DashboardStats({
    required this.totalAnimals,
    required this.birthsThisMonth,
    required this.movementsThisMonth,
    required this.pendingAlerts,
  });
}

@riverpod
Future<DashboardStats> dashboardStats(DashboardStatsRef ref) async {
  final AnimalRepository repo = ref.watch(animalRepositoryProvider);
  final int total = await repo.countAnimals();
  final int births = await repo.countBirthsThisMonth();
  final int movements = await repo.countMovementsThisMonth();
  return DashboardStats(
    totalAnimals: total,
    birthsThisMonth: births,
    movementsThisMonth: movements,
    pendingAlerts: 0,
  );
}
