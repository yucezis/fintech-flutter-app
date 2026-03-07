import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_model.dart';
import '../data/transaction_service.dart';
import '../../categories/data/category_service.dart';
import '../../categories/data/category_model.dart';
import '../../../core/utils/auth_utils.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const AddTransactionSheet({super.key, required this.onSaved});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  static const _bg       = Color(0xFF0D0F14);
  static const _surface  = Color(0xFF161A23);
  static const _border   = Color(0xFF252B3A);
  static const _accentBlue = Color(0xFF4F8EF7);
  static const _accentMint = Color(0xFF00C896);
  static const _accentRose = Color(0xFFFF5B6E);
  static const _textPrimary   = Color(0xFFEEF0F6);
  static const _textSecondary = Color(0xFF6B7591);

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isIncome = false;
  bool _isLoading = false;
  String? _selectedCategoryId;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryService().getCategories(
      type: _isIncome ? 'income' : 'expense',
    );
    setState(() => _categories = cats);
  }

  Future<void> _save() async {
    if (_amountController.text.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tutar ve kategori seç')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = await AuthUtils.getUserId() ?? '';

      await TransactionService().addTransaction(
        TransactionModel(
          id: '',  
          categoryId: _selectedCategoryId!,
          amount: double.parse(_amountController.text),
          description: _descriptionController.text,
          date: DateTime.now(),
          type: _isIncome ? '0' : '1',
        ),
      );
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İşlem kaydedilemedi')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPadding),
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Yeni İşlem',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                _ToggleButton(
                  label: 'Gider',
                  icon: Icons.arrow_upward_rounded,
                  isSelected: !_isIncome,
                  color: _accentRose,
                  onTap: () {
                    setState(() {
                      _isIncome = false;
                      _selectedCategoryId = null;
                    });
                    _loadCategories();
                  },
                ),
                _ToggleButton(
                  label: 'Gelir',
                  icon: Icons.arrow_downward_rounded,
                  isSelected: _isIncome,
                  color: _accentMint,
                  onTap: () {
                    setState(() {
                      _isIncome = true;
                      _selectedCategoryId = null;
                    });
                    _loadCategories();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _InputField(
            controller: _amountController,
            label: 'Tutar (₺)',
            keyboardType: TextInputType.number,
            prefix: '₺',
          ),
          const SizedBox(height: 12),

          _InputField(
            controller: _descriptionController,
            label: 'Açıklama (opsiyonel)',
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategoryId,
                hint: Text(
                  'Kategori seç',
                  style: TextStyle(color: _textSecondary, fontSize: 14),
                ),
                dropdownColor: _surface,
                style: const TextStyle(color: _textPrimary, fontSize: 14),
                isExpanded: true,
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
            ),
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: _isLoading ? null : _save,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F8EF7), Color(0xFF7B6CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Kaydet',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.4) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? color : const Color(0xFF6B7591)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : const Color(0xFF6B7591),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? prefix;

  const _InputField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.prefix,
  });

  static const _surface  = Color(0xFF161A23);
  static const _border   = Color(0xFF252B3A);
  static const _textPrimary   = Color(0xFFEEF0F6);
  static const _textSecondary = Color(0xFF6B7591);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 13),
        prefixText: prefix,
        prefixStyle: const TextStyle(color: _textSecondary),
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4F8EF7)),
        ),
      ),
    );
  }
}