// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kimiflash/http/api/auth_api.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref as ProviderContainer?);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authApiProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi _authApi;

  AuthNotifier(this._authApi) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    state = AuthLoading();
    try {
      final response = await _authApi.login(username, password);

      // 类型安全检查
      if (response.data is! Map<String, dynamic>) {
        throw TypeError();
      }

      state = response.success
          ? AuthAuthenticated(response.data as Map<String, dynamic>)
          : AuthError(response.message ?? 'Login failed');

    } on TypeError {
      state = AuthError('Invalid server response format');
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> userData;
  AuthAuthenticated(this.userData);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// 扩展AuthState类实现maybeMap方法
extension AuthStateX on AuthState {
  R maybeMap<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(Map<String, dynamic> data) authenticated,
    required R Function(String message) error,
  }) {
    print('Current state: $runtimeType');
    if (this is AuthInitial) {
      print('Handling AuthInitial');
      return initial();
    }
    if (this is AuthLoading) {
      print('Handling AuthLoading');
      return loading();
    }
    if (this is AuthAuthenticated) {
      print('Handling AuthAuthenticated');
      return authenticated((this as AuthAuthenticated).userData);
    }
    if (this is AuthError) {
      print('Handling AuthError');
      return error((this as AuthError).message);
    }
    return throw UnsupportedError('Unsupported state: $runtimeType');
  }
}
