// lib/features/client_auth/cubit/client_auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taxi_client_manual/features/auth/repositories/client_auth_repository.dart';


abstract class ClientAuthState extends Equatable {
  const ClientAuthState();
  @override
  List<Object?> get props => [];
}

class ClientAuthInitial extends ClientAuthState {}
class ClientAuthLoading extends ClientAuthState {}
class ClientAuthenticated extends ClientAuthState {
  final User user;
  const ClientAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class ClientAuthError extends ClientAuthState {
  final String message;
  const ClientAuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class ClientAuthCubit extends Cubit<ClientAuthState> {
  final ClientAuthRepository _authRepository;

  ClientAuthCubit(this._authRepository) : super(ClientAuthInitial());

  // تنفيذ عملية التسجيل
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    emit(ClientAuthLoading());
    try {
      User? user = await _authRepository.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      if (user != null) {
        emit(ClientAuthenticated(user));
      }
    } catch (e) {
      emit(ClientAuthError(e.toString()));
    }
  }

  // تنفيذ عملية تسجيل الدخول
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(ClientAuthLoading());
    try {
      User? user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        emit(ClientAuthenticated(user));
      }
    } catch (e) {
      emit(ClientAuthError(e.toString()));
    }
  }
}