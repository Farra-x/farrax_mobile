import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

enum AuthState { guest, authenticated }

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() => AuthState.guest;
}
