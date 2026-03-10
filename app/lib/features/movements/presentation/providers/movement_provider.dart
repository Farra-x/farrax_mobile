import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/movement_repository.dart';

part 'movement_provider.g.dart';

@Riverpod(keepAlive: true)
MovementRepository movementRepositoryFeature(MovementRepositoryFeatureRef ref) =>
    MovementRepository(ref.watch(databaseProvider));

@riverpod
Stream<List<MovementEvent>> allMovements(AllMovementsRef ref) =>
    ref.watch(movementRepositoryFeatureProvider).watchAllMovements();

enum MovementsFilter { all, inbound, outbound, thisMonth }

@riverpod
class MovementsFilterNotifier extends _$MovementsFilterNotifier {
  @override
  MovementsFilter build() => MovementsFilter.all;
  void set(MovementsFilter f) => state = f;
}

@riverpod
Stream<List<MovementEvent>> filteredMovements(FilteredMovementsRef ref) {
  final MovementsFilter filter = ref.watch(movementsFilterNotifierProvider);
  final AsyncValue<List<MovementEvent>> allAsync = ref.watch(allMovementsProvider);

  return allAsync.when(
    data: (List<MovementEvent> all) {
      final DateTime now = DateTime.now();
      final DateTime startOfMonth = DateTime(now.year, now.month);
      List<MovementEvent> result;
      switch (filter) {
        case MovementsFilter.inbound:
          result = all.where((e) => e.movementType == 'in').toList();
        case MovementsFilter.outbound:
          result = all.where((e) => e.movementType == 'out').toList();
        case MovementsFilter.thisMonth:
          result = all
              .where((e) => e.eventDate.isAfter(startOfMonth) ||
                  e.eventDate.isAtSameMomentAs(startOfMonth))
              .toList();
        case MovementsFilter.all:
          result = all;
      }
      return Stream.value(result);
    },
    loading: () => const Stream.empty(),
    error: (Object e, _) => Stream.error(e),
  );
}
