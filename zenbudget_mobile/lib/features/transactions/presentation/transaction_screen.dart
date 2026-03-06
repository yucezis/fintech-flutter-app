import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../data/transaction_model.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  static const _bg         = Color(0xFF0D0F14);       
  //static const _surface    = Color(0xFF161A23);      
  static const _surfaceAlt = Color(0xFF1E2330);     
  static const _border     = Color(0xFF252B3A);      
  static const _accentBlue = Color(0xFF4F8EF7);       
  //static const _accentMint = Color(0xFF00C896);     
  //static const _accentRose = Color(0xFFFF5B6E);      
  static const _textPrimary   = Color(0xFFEEF0F6);
  static const _textSecondary = Color(0xFF6B7591);
  //static const _textTertiary  = Color(0xFF3E4660);

  String _selectedFilter = 'Bu Ay';
  final _filters = ['Tümü', 'Bu Ay', 'Geçen Ay'];

  List<TransactionModel> _applyFilter(List<TransactionModel> all) {
    final now = DateTime.now();
    return all.where((tx) {
      if (_selectedFilter == 'Bu Ay') {
        return tx.date.year == now.year && tx.date.month == now.month;
      } else if (_selectedFilter == 'Geçen Ay') {
        final last = DateTime(now.year, now.month - 1);
        return tx.date.year == last.year && tx.date.month == last.month;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  ({double income, double expense}) _calcSummary(List<TransactionModel> txs) {
    double income = 0, expense = 0;
    for (final tx in txs) {
      final isIncome =
          tx.type.toLowerCase() == 'income' || tx.type == '0';
      if (isIncome) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    return (income: income, expense: expense);
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bg,
      body: transactionsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: _accentBlue)),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.refresh(transactionsProvider.future),
        ),
        data: (all) {
          final transactions = _applyFilter(all);
          final summary = _calcSummary(transactions);

          return RefreshIndicator(
            color: _accentBlue,
            backgroundColor: _surfaceAlt,
            onRefresh: () async => ref.refresh(transactionsProvider.future),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: _bg,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: _TransactionHero(
                      filter: _selectedFilter,
                      income: summary.income,
                      expense: summary.expense,
                    ),
                  ),
                  title: const Text(
                    'İşlemler',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                      fontSize: 17,
                      letterSpacing: -0.3,
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: const Icon(Icons.search_rounded,
                          color: _textSecondary, size: 18),
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: _FilterBar(
                    filters: _filters,
                    selected: _selectedFilter,
                    onSelected: (f) => setState(() => _selectedFilter = f),
                  ),
                ),

                if (transactions.isEmpty)
                  const SliverFillRemaining(child: _EmptyState())
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                        16, 8, 16, bottomPadding + 80),
                    sliver: _TransactionSliver(transactions: transactions),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TransactionHero extends StatelessWidget {
  final String filter;
  final double income;
  final double expense;

  const _TransactionHero({
    required this.filter,
    required this.income,
    required this.expense,
  });

  static const _bg         = Color(0xFF0D0F14);
  //static const _surface    = Color(0xFF161A23);
  static const _surfaceAlt = Color(0xFF1E2330);
  static const _border     = Color(0xFF252B3A);
  //static const _accentBlue = Color(0xFF4F8EF7);
  static const _accentMint = Color(0xFF00C896);
  static const _accentRose = Color(0xFFFF5B6E);
  //static const _textPrimary   = Color(0xFFEEF0F6);
  static const _textSecondary = Color(0xFF6B7591);

  @override
  Widget build(BuildContext context) {
    final net = income - expense;
    final isPositive = net >= 0;

    return Stack(
      children: [
        Container(color: _bg),

        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isPositive ? _accentMint : _accentRose)
                        .withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: Column(
            children: [
              const SizedBox(height: 80),
              Text(
                'Net Bakiye',
                style: TextStyle(
                  fontSize: 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${isPositive ? '+' : ''}₺${net.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: isPositive ? _accentMint : _accentRose,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                ),
                child: Text(
                  filter,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Gelir',
                        amount: income,
                        icon: Icons.arrow_downward_rounded,
                        color: _accentMint,
                        bgColor: _accentMint.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Gider',
                        amount: expense,
                        icon: Icons.arrow_upward_rounded,
                        color: _accentRose,
                        bgColor: _accentRose.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  static const _surface = Color(0xFF161A23);
  static const _border  = Color(0xFF252B3A);
  static const _textPrimary   = Color(0xFFEEF0F6);
  static const _textSecondary = Color(0xFF6B7591);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₺${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterBar({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  static const _bg         = Color(0xFF0D0F14);
  static const _surface    = Color(0xFF161A23);
  static const _border     = Color(0xFF252B3A);
  //static const _accentBlue = Color(0xFF4F8EF7);
  static const _textSecondary = Color(0xFF6B7591);
  //static const _textPrimary   = Color(0xFFEEF0F6);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: filters.map((f) {
          final isSelected = selected == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF4F8EF7), Color(0xFF7B6CF6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: isSelected ? null : _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? Colors.transparent : _border,
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : _textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TransactionSliver extends StatelessWidget {
  final List<TransactionModel> transactions;
  const _TransactionSliver({required this.transactions});

  Map<String, List<TransactionModel>> _group() {
    final map = <String, List<TransactionModel>>{};
    for (final tx in transactions) {
      final key = DateFormat('dd MMMM yyyy', 'tr').format(tx.date);
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _group();
    final keys = grouped.keys.toList();

    final items = <Widget>[];
    for (final key in keys) {
      items.add(_DateHeader(label: key));
      for (final tx in grouped[key]!) {
        items.add(_TransactionTile(tx: tx));
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => items[index],
        childCount: items.length,
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  static const _textSecondary = Color(0xFF6B7591);
  static const _textTertiary  = Color(0xFF3E4660);
  //static const _accentBlue    = Color(0xFF4F8EF7);

  String get _display {
    final now = DateTime.now();
    final today = DateFormat('dd MMMM yyyy', 'tr').format(now);
    final yesterday = DateFormat('dd MMMM yyyy', 'tr')
        .format(now.subtract(const Duration(days: 1)));
    if (label == today) return 'Bugün';
    if (label == yesterday) return 'Dün';
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 2),
      child: Row(
        children: [
          Text(
            _display,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: _textTertiary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  const _TransactionTile({required this.tx});

  static const _surface    = Color(0xFF161A23);
  static const _border     = Color(0xFF252B3A);
  static const _accentMint = Color(0xFF00C896);
  static const _accentRose = Color(0xFFFF5B6E);
  static const _textPrimary   = Color(0xFFEEF0F6);
  static const _textSecondary = Color(0xFF6B7591);

  bool get _isIncome =>
      tx.type.toLowerCase() == 'income' || tx.type == '0';

  IconData get _icon {
    final cat = (tx.categoryName ?? '').toLowerCase();
    if (cat.contains('yemek') ||
        cat.contains('food') ||
        cat.contains('restoran')) return Icons.restaurant_rounded;
    if (cat.contains('ulaşım') ||
        cat.contains('transport') ||
        cat.contains('araba')) return Icons.directions_car_rounded;
    if (cat.contains('alışveriş') ||
        cat.contains('shop') ||
        cat.contains('market')) return Icons.shopping_bag_rounded;
    if (cat.contains('sağlık') ||
        cat.contains('health') ||
        cat.contains('ilaç')) return Icons.favorite_rounded;
    if (cat.contains('eğitim') ||
        cat.contains('education') ||
        cat.contains('kurs')) return Icons.school_rounded;
    if (cat.contains('eğlence') ||
        cat.contains('entertainment')) return Icons.movie_rounded;
    if (cat.contains('fatura') ||
        cat.contains('bill') ||
        cat.contains('elektrik')) return Icons.receipt_rounded;
    if (_isIncome) return Icons.account_balance_rounded;
    return Icons.receipt_long_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _isIncome ? _accentMint : _accentRose;
    final amountStr =
        '${_isIncome ? '+' : '-'}₺${tx.amount.toStringAsFixed(2)}';
    final timeStr = DateFormat('HH:mm').format(tx.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(_icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.categoryName ?? 'Kategorisiz',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  tx.description.isNotEmpty
                      ? tx.description
                      : timeStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountStr,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 11,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  //static const _surfaceAlt    = Color(0xFF1E2330);
  static const _accentBlue    = Color(0xFF4F8EF7);
  static const _textPrimary   = Color(0xFFEEF0F6);
  static const _textSecondary = Color(0xFF6B7591);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _accentBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: _accentBlue.withOpacity(0.15)),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 32,
              color: _accentBlue.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'İşlem bulunamadı',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bu dönemde henüz işlem yok.\nYeni işlem eklemek için + butonuna bas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  static const _accentRose    = Color(0xFFFF5B6E);
  //static const _accentBlue    = Color(0xFF4F8EF7);
  //static const _surface       = Color(0xFF161A23);
  //static const _border        = Color(0xFF252B3A);
  static const _textPrimary   = Color(0xFFEEF0F6);
  static const _textSecondary = Color(0xFF6B7591);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _accentRose.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: _accentRose.withOpacity(0.2)),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: _accentRose, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F8EF7), Color(0xFF7B6CF6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Tekrar Dene',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}