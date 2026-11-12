import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/repositories/client_auth_repository_contract.dart';

abstract class ClientAuthState extends Equatable {
  const ClientAuthState();
  @override
  List<Object?> get props => [];
}

class ClientAuthInitial extends ClientAuthState {}

class ClientAuthLoading extends ClientAuthState {}

class ClientAuthenticated extends ClientAuthState {
  final String uid;
  const ClientAuthenticated(this.uid);
  @override
  List<Object?> get props => [uid];
}

class ClientAuthError extends ClientAuthState {
  final String message;
  const ClientAuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class ClientAuthCubit extends Cubit<ClientAuthState> {
  final ClientAuthRepositoryContract _authRepository;

  ClientAuthCubit(this._authRepository) : super(ClientAuthInitial());

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    emit(ClientAuthLoading());
    try {
      final uid = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      if (uid != null) {
        emit(ClientAuthenticated(uid));
      }
    } catch (e) {
      emit(ClientAuthError(e.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(ClientAuthLoading());
    try {
      final uid = await _authRepository.signIn(
        email: email,
        password: password,
      );
      if (uid != null) {
        emit(ClientAuthenticated(uid));
      }
    } catch (e) {
      emit(ClientAuthError(e.toString()));
    }
  }
}
