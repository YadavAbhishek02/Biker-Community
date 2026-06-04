import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biker_community/features/auth/domain/models/user_model.dart';
import 'package:biker_community/features/auth/domain/repositories/auth_repository.dart';
import 'package:biker_community/core/services/notification_service.dart';
import 'package:biker_community/core/injection_container.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    checkAuthStatus();
  }

  void _uploadFcmToken() {
    try {
      sl<NotificationService>().uploadToken();
    } catch (e) {
      // Ignore if service not ready
    }
  }

  Future<void> checkAuthStatus() async {
    final isAuthenticated = await _authRepository.isAuthenticated();
    if (isAuthenticated) {
      try {
        final user = await _authRepository.getProfile();
        emit(AuthAuthenticated(user));
        _uploadFcmToken();
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.login(email, password);
      emit(AuthAuthenticated(result['user']));
      _uploadFcmToken();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(UserModel user, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(user, password);
      await login(user.email, password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
