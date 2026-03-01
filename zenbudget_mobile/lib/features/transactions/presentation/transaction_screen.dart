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
  // ── Renk paleti ──────────────────────────────────────────────
  static const _red      = Color(0xFFE63946);
  static const _green    = Color(0xFF2EC071);
  static const _cream    = Color(0xFFF1FAEE);
  static const _cerulean = Color(0xFF457B9D);
  static const _frost    = Color(0xFFA8DADC);
  static const _ink      = Color(0xFF0A131F);

  String _selectedFilter = 'Bu Ay';
  final _filters = ['Tümü', 'Bu Ay', 'Geçen Ay'];

  // ── Filtreleme ────────────────────────────────────────────────
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

  // ── Özet hesapla ──────────────────────────────────────────────
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
      backgroundColor: _cream,
      body: transactionsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _cerulean)),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.refresh(transactionsProvider.future),
        ),
        data: (all) {
          final transactions = _applyFilter(all);
          final summary = _calcSummary(transactions);

          return RefreshIndicator(
            color: _cerulean,
            onRefresh: () async => ref.refresh(transactionsProvider.future),
            child: CustomScrollView(
              slivers: [
                // ── Hero AppBar ─────────────────────────────
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: _cerulean,
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
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search_rounded,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 4),
                  ],
                ),

                // ── Filtre chips ────────────────────────────
                SliverToBoxAdapter(
                  child: _FilterBar(
                    filters: _filters,
                    selected: _selectedFilter,
                    onSelected: (f) => setState(() => _selectedFilter = f),
                  ),
                ),

                // ── Liste ───────────────────────────────────
                if (transactions.isEmpty)
                  const SliverFillRemaining(
                    child: _EmptyState(),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                        16, 8, 16, bottomPadding + 80),
                    sliver: _TransactionSliver(
                        transactions: transactions),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Hero band ──────────────────────────────────────────────────
class _TransactionHero extends StatelessWidget {
  final String filter;
  final double income;
  final double expense;

  const _TransactionHero({
    required this.filter,
    required this.income,
    required this.expense,
  });

  static const _cerulean = Color(0xFF457B9D);
  static const _ink      = Color(0xFF0A131F);
  static const _cream    = Color(0xFFF1FAEE);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: _cerulean),

        // Dekoratif daireler
        Positioned(
          top: -40, right: -40,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
        ),
        Positioned(
          bottom: 40, left: -20,
          child: Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _ink.withOpacity(0.07),
            ),
          ),
        ),

        // Özet kartı
        Positioned(
          left: 20, right: 20, bottom: 28,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'GELİR',
                    amount: income,
                    icon: Icons.arrow_downward_rounded,
                    color: const Color(0xFF2EC071),
                  ),
                ),
                Container(
                  width: 1, height: 36,
                  color: Colors.white.withOpacity(0.2),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'GİDER',
                    amount: expense,
                    icon: Icons.arrow_upward_rounded,
                    color: const Color(0xFFE63946),
                  ),
                ),
                Container(
                  width: 1, height: 36,
                  color: Colors.white.withOpacity(0.2),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'NET',
                    amount: income - expense,
                    icon: Icons.account_balance_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Dalga
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: ClipPath(
            clipper: _WaveClipper(),
            child: Container(height: 28, color: _cream),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withOpacity(0.65),
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '₺${amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  static const _cerulean = Color(0xFF457B9D);
  static const _ink      = Color(0xFF0A131F);
  static const _cream    = Color(0xFFF1FAEE);

  const _FilterBar({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                  color: isSelected ? _cerulean : _cream,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? _cerulean
                        : _ink.withOpacity(0.08),
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
                        : _ink.withOpacity(0.5),
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

// ── İşlem listesi (tarihe göre gruplu) ────────────────────────
class _TransactionSliver extends StatelessWidget {
  final List<TransactionModel> transactions;
  const _TransactionSliver({required this.transactions});

  // Tarihe göre grupla
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

    // Toplam sliver item sayısı: her grup = 1 header + N tile
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

// ── Tarih başlığı ──────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  static const _ink = Color(0xFF0A131F);
  static const _cerulean = Color(0xFF457B9D);

  String get _display {
    final now = DateTime.now();
    final today = DateFormat('dd MMMM yyyy', 'tr').format(now);
    final yesterday =
        DateFormat('dd MMMM yyyy', 'tr').format(now.subtract(const Duration(days: 1)));
    if (label == today) return 'Bugün';
    if (label == yesterday) return 'Dün';
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Row(
        children: [
          Container(
            width: 4, height: 14,
            decoration: BoxDecoration(
              color: _cerulean,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _display,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _ink.withOpacity(0.5),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── İşlem tile ────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  const _TransactionTile({required this.tx});

  static const _red      = Color(0xFFE63946);
  static const _green    = Color(0xFF2EC071);
  static const _ink      = Color(0xFF0A131F);

  bool get _isIncome =>
      tx.type.toLowerCase() == 'income' || tx.type == '0';

  IconData get _icon {
    final cat = (tx.categoryName ?? '').toLowerCase();
    if (cat.contains('yemek') || cat.contains('food') || cat.contains('restoran')) {
      return Icons.restaurant_rounded;
    } else if (cat.contains('ulaşım') || cat.contains('transport') || cat.contains('araba')) {
      return Icons.directions_car_rounded;
    } else if (cat.contains('alışveriş') || cat.contains('shop') || cat.contains('market')) {
      return Icons.shopping_bag_rounded;
    } else if (cat.contains('sağlık') || cat.contains('health') || cat.contains('ilaç')) {
      return Icons.favorite_rounded;
    } else if (cat.contains('eğitim') || cat.contains('education') || cat.contains('kurs')) {
      return Icons.school_rounded;
    } else if (cat.contains('eğlence') || cat.contains('entertainment')) {
      return Icons.movie_rounded;
    } else if (cat.contains('fatura') || cat.contains('bill') || cat.contains('elektrik')) {
      return Icons.receipt_rounded;
    } else if (_isIncome) {
      return Icons.account_balance_rounded;
    }
    return Icons.receipt_long_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _isIncome ? _green : _red;
    final amountStr =
        '${_isIncome ? '+' : '-'}₺${tx.amount.toStringAsFixed(2)}';
    final timeStr = DateFormat('HH:mm').format(tx.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ink.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: _ink.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
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
                    color: _ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  tx.description.isNotEmpty ? tx.description : timeStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: _ink.withOpacity(0.4),
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
                style: TextStyle(
                  fontSize: 11,
                  color: _ink.withOpacity(0.3),
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

  static const _cerulean = Color(0xFF457B9D);
  static const _ink      = Color(0xFF0A131F);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: _cerulean.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 36,
              color: _cerulean.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'İşlem bulunamadı',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _ink.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bu dönemde henüz işlem yok.\nYeni işlem eklemek için + butonuna bas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _ink.withOpacity(0.35),
              height: 1.5,
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

  static const _red      = Color(0xFFE63946);
  static const _cerulean = Color(0xFF457B9D);
  static const _ink      = Color(0xFF0A131F);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: _red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: _red, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _ink.withOpacity(0.45),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _cerulean,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.25, 0,
      size.width * 0.5, size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height,
      size.width, size.height * 0.25,
    );
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper _) => false;
}