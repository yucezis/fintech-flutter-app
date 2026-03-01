import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../data/dashboard_service.dart';
import '../../auth/data/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _red      = Color(0xFFE63946);
  static const _cream    = Color(0xFFF1FAEE);
  static const _frost    = Color(0xFFA8DADC);
  static const _cerulean = Color(0xFF457B9D);
  static const _ink      = Color(0xFF0A131F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: _cream,
      body: dashboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _cerulean),
        ),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.refresh(dashboardProvider.future),
        ),
        data: (summary) => RefreshIndicator(
          color: _cerulean,
          onRefresh: () => ref.refresh(dashboardProvider.future),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: _cerulean,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: _HeroBand(summary: summary),
                  collapseMode: CollapseMode.pin,
                ),
                title: Row(
                  children: [
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: _cerulean, size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Zen',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Budget',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _frost,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      final service = ref.read(authServiceProvider);
                      await service.logout();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QuickActions(),
                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Son İşlemler',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                              letterSpacing: -0.4,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: _cerulean,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Tümünü Gör →',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              if (summary.recentTransactions.isEmpty)
                const SliverToBoxAdapter(child: _EmptyTransactions())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _TransactionTile(
                        data: summary.recentTransactions[index],
                      ),
                      childCount: summary.recentTransactions.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _red,
        elevation: 6,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('İşlem ekleme yakında!'),
              backgroundColor: _cerulean,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _HeroBand extends StatelessWidget {
  final DashboardSummary summary;
  const _HeroBand({required this.summary});

  static const _cerulean = Color(0xFF457B9D);
  static const _ink      = Color(0xFF0A131F);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: _cerulean),

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
          bottom: 60, left: -20,
          child: Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _ink.withOpacity(0.07),
            ),
          ),
        ),

        Positioned(
          left: 24, right: 24, bottom: 32,
          child: _SummaryCard(
            income: summary.totalIncome,
            expense: summary.totalExpense,
            balance: summary.netBalance,
          ),
        ),

        Positioned(
          bottom: 0, left: 0, right: 0,
          child: ClipPath(
            clipper: _WaveClipper(),
            child: Container(
              height: 32,
              color: const Color(0xFFF1FAEE),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;

  const _SummaryCard({
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOPLAM BAKİYE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₺${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'GELİR',
                  amount: income,
                  isIncome: true,
                ),
              ),
              Container(
                width: 1, height: 32,
                color: Colors.white.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _StatChip(
                  label: 'GİDER',
                  amount: expense,
                  isIncome: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final double amount;
  final bool isIncome;

  const _StatChip({
    required this.label,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isIncome
                  ? const Color(0xFF2EC071)
                  : const Color(0xFFE63946),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '₺${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  static const _cerulean = Color(0xFF457B9D);
  static const _red      = Color(0xFFE63946);
  static const _ink      = Color(0xFF0A131F);

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add_rounded,          'Ekle',     _red),
      (Icons.swap_horiz_rounded,   'Transfer', _cerulean),
      (Icons.bar_chart_rounded,    'Rapor',    const Color(0xFF2EC071)),
      (Icons.category_rounded,     'Kategori', const Color(0xFFFF9F1C)),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        final (icon, label, color) = a;
        return GestureDetector(
          onTap: () {},
          child: Column(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _ink.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final dynamic data;
  const _TransactionTile({required this.data});

  static const _ink      = Color(0xFF0A131F);
  //static const _cerulean = Color(0xFF457B9D);
  static const _red      = Color(0xFFE63946);

  String get _title =>
      (data['title'] ?? data['description'] ?? data['name'] ?? 'İşlem')
          .toString();

  String get _category =>
      (data['category'] ?? data['type'] ?? '').toString();

  double get _amount =>
      (data['amount'] as num?)?.toDouble() ??
      (data['value'] as num?)?.toDouble() ??
      0.0;

  bool get _isIncome =>
      data['isIncome'] == true ||
      data['type'] == 'income' ||
      _amount > 0 && data['isIncome'] != false;

  String get _date {
    final raw = data['date'] ?? data['createdAt'] ?? data['transactionDate'];
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString());
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }

  IconData get _icon {
    final cat = _category.toLowerCase();
    if (cat.contains('food') || cat.contains('yemek')) {
      return Icons.restaurant_rounded;
    } else if (cat.contains('transport') || cat.contains('ulaşım')) {
      return Icons.directions_car_rounded;
    } else if (cat.contains('shop') || cat.contains('alışveriş')) {
      return Icons.shopping_bag_rounded;
    } else if (cat.contains('health') || cat.contains('sağlık')) {
      return Icons.favorite_rounded;
    } else if (cat.contains('income') || cat.contains('gelir')) {
      return Icons.account_balance_rounded;
    } else {
      return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _isIncome ? const Color(0xFF2EC071) : _red;
    final amountStr =
        '${_isIncome ? '+' : '-'}₺${_amount.abs().toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ink.withOpacity(0.05), width: 1),
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
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_category.isNotEmpty || _date.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    [_category, _date]
                        .where((s) => s.isNotEmpty)
                        .join(' · '),
                    style: TextStyle(
                      fontSize: 12,
                      color: _ink.withOpacity(0.4),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          Text(
            amountStr,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF457B9D).withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 36,
              color: const Color(0xFF457B9D).withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz bir işlem yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0A131F).withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sağ alttaki + butonuna basarak\nilk işlemini ekleyebilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF0A131F).withOpacity(0.35),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hata ekranı ───────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

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
                color: const Color(0xFFE63946).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE63946), size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A131F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF0A131F).withOpacity(0.45),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF457B9D),
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