import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_model.dart';
import '../data/transaction_service.dart';

final transactionServiceProvider = Provider((ref) => TransactionService());

class TransactionNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() async {
    return ref.read(transactionServiceProvider).getTransactions();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final success = await ref.read(transactionServiceProvider).addTransaction(transaction);
    if (success) {
      ref.invalidateSelf();
    }
  }

  Future<void> deleteTransaction(String id) async {
    final success = await ref.read(transactionServiceProvider).deleteTransaction(id);
    if (success) {
      ref.invalidateSelf();
    }
  }
}

final transactionsProvider = AsyncNotifierProvider<TransactionNotifier, List<TransactionModel>>(() {
  return TransactionNotifier();
});