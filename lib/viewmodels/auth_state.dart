part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// Initial authentication state
class AuthInitial extends AuthState {}

/// Authentication is in progress (loading)
class AuthLoading extends AuthState {}

/// User is successfully authenticated
class AuthAuthenticated extends AuthState {
  final UserModel user;
  
  const AuthAuthenticated(this.user);
  
  @override
  List<Object?> get props => [user];
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  final String? message;
  
  const AuthUnauthenticated({this.message});
  
  @override
  List<Object?> get props => [message];
}

/// Authentication error state
class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Password reset email has been sent
class AuthPasswordResetSent extends AuthState {
  final String email;
  
  const AuthPasswordResetSent(this.email);
  
  @override
  List<Object?> get props => [email];
}
