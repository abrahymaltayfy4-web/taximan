import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/account_repository.dart';

// تصدير AccountData ليستطيع الـ View استخدامه بدون استيراد Repository مباشرة
export '../repositories/account_repository.dart' show AccountData;

// States
abstract class AccountState extends Equatable {
  const AccountState();
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final AccountData data;
  const AccountLoaded(this.data);
  @override
  List<Object?> get props => [data.totalCommissionOwed, data.totalPaid];
}

class AccountError extends AccountState {
  final String message;
  const AccountError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class AccountCubit extends Cubit<AccountState> {
  final AccountRepository _repository;

  AccountCubit(this._repository) : super(AccountInitial());

  Future<void> loadAccount() async {
    emit(AccountLoading());
    final result = await _repository.getAccountData();
    result.when(
      success: (data) => emit(AccountLoaded(data)),
      failure: (f) => emit(AccountError(f.message)),
    );
  }
}
