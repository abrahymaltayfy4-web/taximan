import 'package:equatable/equatable.dart';

enum AccountTransactionType { commission, other }

/// حركة مالية في كشف الحساب
class AccountTransaction extends Equatable {
  final String id;
  final AccountTransactionType type;
  final double amount;
  final String note;
  final double rideFare;
  final DateTime createdAt;

  const AccountTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.note,
    required this.rideFare,
    required this.createdAt,
  });

  bool get isCommission => type == AccountTransactionType.commission;

  @override
  List<Object?> get props => [id, type, amount, note, rideFare, createdAt];
}

/// كشف حساب الكابتن: المستحقات + المدفوع + الحركات (الأحدث أولاً)
class AccountStatement extends Equatable {
  final double totalCommissionOwed;
  final double totalPaid;
  final List<AccountTransaction> transactions;

  const AccountStatement({
    required this.totalCommissionOwed,
    required this.totalPaid,
    required this.transactions,
  });

  @override
  List<Object?> get props => [totalCommissionOwed, totalPaid, transactions];
}
