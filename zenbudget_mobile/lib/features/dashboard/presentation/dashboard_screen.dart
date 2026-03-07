import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../data/dashboard_service.dart';
import '../../auth/data/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _bg            = Color(0xFF0D0F14);
  //static const _surface       = Color(0xFF161A23);
  static const _surfaceAlt    = Color(0xFF1E2330);
  static const _border        = Color(0xFF252B3A);
  static const _accentBlue    = Color(0xFF4F8EF7);
  //static const _accentMint    = Color(0xFF00C896);
  //static const _accentRose    = Color(0xFFFF5B6E);
  //static const _accentAmber   = Color(0xFFFFB347);
  static const _textPrimary   = Color(0xFFEEF0F6);
  static const _textSecondary = Color(0xFF6B7591);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("🚨 DashboardScreen çizildi!");
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: dashboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _accentBlue),
        ),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.refresh(dashboardProvider.future),
        ),
        data: (summary) => RefreshIndicator(
          color: _accentBlue,
          backgroundColor: _surfaceAlt,
          onRefresh: () => ref.refresh(dashboardProvider.future),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 310,
                pinned: true,
                backgroundColor: _bg,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: _HeroBand(summary: summary),
                  collapseMode: CollapseMode.pin,
                ),
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_accentBlue, Color(0xFF7B6CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Zen',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Budget',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _accentBlue,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: _textSecondary,
                      size: 18,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final service = ref.read(authServiceProvider);
                      await service.logout();
                      if (context.mounted) context.go('/login');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: _textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
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
                              color: _textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Tümünü Gör →',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _accentBlue,
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

      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_accentBlue, Color(0xFF7B6CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _accentBlue.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('İşlem ekleme yakında!'),
                  backgroundColor: _surfaceAlt,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Icon(Icons.add_rounded,
                color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}

class _HeroBand extends StatelessWidget {
  final DashboardSummary summary;
  const _HeroBand({required this.summary});

  static const _bg          = Color(0xFF0D0F14);
  //static const _surface     = Color(0xFF161A23);
  //static const _border      = Color(0xFF252B3A);
  static const _accentBlue  = Color(0xFF4F8EF7);
  static const _accentMint  = Color(0xFF00C896);
  static const _accentRose  = Color(0xFFFF5B6E);
  static const _textPrimary   = Color(0xFFEEF0F6);
  static const _textSecondary = Color(0xFF6B7591);

  @override
  Widget build(BuildContext context) {
    final isPositive = summary.netBalance >= 0;

    return Stack(
      children: [
        Container(color: _bg),

        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 260,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accentBlue.withOpacity(0.12),
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
              const SizedBox(height: 88),

              Text(
                'Toplam Bakiye',
                style: TextStyle(
                  fontSize: 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '₺${summary.netBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: isPositive ? _textPrimary : _accentRose,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 6),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? _accentMint : _accentRose)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isPositive ? _accentMint : _accentRose)
                        .withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 12,
                      color: isPositive ? _accentMint : _accentRose,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPositive ? 'Pozitif bakiye' : 'Negatif bakiye',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? _accentMint : _accentRose,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Gelir',
                        amount: summary.totalIncome,
                        icon: Icons.arrow_downward_rounded,
                        color: _accentMint,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Gider',
                        amount: summary.totalExpense,
                        icon: Icons.arrow_upward_rounded,
                        color: _accentRose,
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

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  static const _surface       = Color(0xFF161A23);
  static const _border        = Color(0xFF252B3A);
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
              color: color.withOpacity(0.1),
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

class _QuickActions extends StatelessWidget {
  static const _accentBlue  = Color(0xFF4F8EF7);
  static const _accentMint  = Color(0xFF00C896);
  static const _accentRose  = Color(0xFFFF5B6E);
  static const _accentAmber = Color(0xFFFFB347);
  static const _surface     = Color(0xFF161A23);
  static const _border      = Color(0xFF252B3A);
  static const _textSecondary = Color(0xFF6B7591);

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add_rounded,        'Ekle',     _accentRose),
      (Icons.swap_horiz_rounded, 'Transfer', _accentBlue),
      (Icons.bar_chart_rounded,  'Rapor',    _accentMint),
      (Icons.category_rounded,   'Kategori', _accentAmber),
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _textSecondary,
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

  static const _surface       = Color(0xFF161A23);
  static const _border        = Color(0xFF252B3A);
  static const _accentMint    = Color(0xFF00C896);
  static const _accentRose    = Color(0xFFFF5B6E);
  static const _textPrimary   = Color(0xFFEEF0F6);
  static const _textSecondary = Color(0xFF6B7591);

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
    }
    return Icons.receipt_long_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _isIncome ? _accentMint : _accentRose;
    final amountStr =
        '${_isIncome ? '+' : '-'}₺${_amount.abs().toStringAsFixed(2)}';

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
                  _title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
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

  static const _accentBlue    = Color(0xFF4F8EF7);
  //static const _border        = Color(0xFF252B3A);
  static const _textPrimary   = Color(0xFFEEF0F6);
  static const _textSecondary = Color(0xFF6B7591);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _accentBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _accentBlue.withOpacity(0.15)),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 32,
              color: _accentBlue.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz bir işlem yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sağ alttaki + butonuna basarak\nilk işlemini ekleyebilirsin.',
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

  static const _accentBlue    = Color(0xFF4F8EF7);
  static const _accentRose    = Color(0xFFFF5B6E);
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
                border:
                    Border.all(color: _accentRose.withOpacity(0.2)),
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
                    colors: [_accentBlue, Color(0xFF7B6CF6)],
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