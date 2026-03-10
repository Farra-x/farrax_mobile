import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'database.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
FarraxDatabase database(DatabaseRef ref) {
  final FarraxDatabase db = FarraxDatabase();
  ref.onDispose(db.close);
  return db;
}
