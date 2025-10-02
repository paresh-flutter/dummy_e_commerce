import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user.dart';
import '../services/authentication_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthenticationService _authService;

  AuthCubit(this._authService) : super(AuthInitial()) {
    checkAuthStatus();
  }

  // Check authentication status on app start
  Future<void> checkAuthStatus() async {
    try {
      emit(AuthLoading());
      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to check authentication status: ${e.toString()}'));
    }
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.login(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString().replaceAll('Exception: ', '')}'));
    }
  }

  // Register with email and password
  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.register(email, password, name);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Registration failed: ${e.toString().replaceAll('Exception: ', '')}'));
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _authService.resetPassword(email);
      emit(AuthPasswordResetSent(email));
    } catch (e) {
      emit(AuthError('Failed to send password reset email: ${e.toString().replaceAll('Exception: ', '')}'));
    }
  }

  // Logout user
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(const AuthUnauthenticated(message: 'Successfully logged out'));
    } catch (e) {
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }
  
  // Check if user is authenticated
  bool get isAuthenticated => state is AuthAuthenticated;

  // Get current user
  UserModel? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  // Clear error state
  void clearError() {
    if (state is AuthError) {
      emit(AuthUnauthenticated());
    }
  }
}
