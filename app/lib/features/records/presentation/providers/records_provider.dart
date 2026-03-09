import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/birth_repository.dart';
import '../../data/death_repository.dart';
import '../../data/movement_repository.dart';

part 'records_provider.g.dart';

@Riverpod(keepAlive: true)
BirthRepository birthRepository(BirthRepositoryRef ref) =>
    BirthRepository(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
DeathRepository deathRepository(DeathRepositoryRef ref) =>
    DeathRepository(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
MovementRepository movementRepository(MovementRepositoryRef ref) =>
    MovementRepository(ref.watch(databaseProvider));
