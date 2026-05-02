import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/language_cubit.dart';
import '../../../product/domain/entities/product_item.dart';
import '../bloc/product_bloc.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});

  final ProductItem? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  static const String _newCategoryValue = '__new_category__';
  static const List<String> _unitOptions = ['Unit', 'KG', 'Liter', 'Pack', 'Dozen', 'Piece'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _buying;
  late final TextEditingController _selling;
  late final TextEditingController _stock;
  late final TextEditingController _newCategory;
  late String _selectedUnit;
  String? _selectedCategory;
  bool _awaitingActionResult = false;

  bool get _isEdit => widget.product != null;

  String _unitLabel(String unit, bool isBn) {
    if (!isBn) return unit;
    switch (unit) {
      case 'KG':
        return 'কেজি';
      case 'Liter':
        return 'লিটার';
      case 'Pack':
        return 'প্যাকেট';
      case 'Dozen':
        return 'ডজন';
      case 'Piece':
        return 'পিস';
      default:
        return 'ইউনিট';
    }
  }

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _buying = TextEditingController(text: p?.buyingPrice.toStringAsFixed(2) ?? '');
    _selling = TextEditingController(text: p?.sellingPrice.toStringAsFixed(2) ?? '');
    _stock = TextEditingController(text: p?.stock.toString() ?? '');
    _newCategory = TextEditingController();
    _selectedUnit = p?.unit.isNotEmpty == true ? p!.unit : 'Unit';
    _selectedCategory = p?.categoryName;
  }

  @override
  void dispose() {
    _name.dispose();
    _buying.dispose();
    _selling.dispose();
    _stock.dispose();
    _newCategory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (_, locale) {
        final t = AppStrings.values[locale.languageCode]!;
        final isBn = locale.languageCode == 'bn';
        final state = context.watch<ProductBloc>().state;
        final existingCategories = [...state.categories];
        final editCategory = widget.product?.categoryName;
        if (editCategory != null &&
            editCategory.isNotEmpty &&
            !existingCategories.contains(editCategory)) {
          existingCategories.add(editCategory);
          existingCategories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        }
        return BlocListener<ProductBloc, ProductState>(
          listenWhen: (_, current) => _awaitingActionResult,
          listener: (context, state) {
            if (state.error != null) {
              setState(() => _awaitingActionResult = false);
              final msg = isBn ? 'অপারেশন ব্যর্থ হয়েছে' : 'Operation failed';
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              return;
            }

            if (state.status == ProductStatus.loaded) {
              setState(() => _awaitingActionResult = false);
              if (mounted) Navigator.pop(context);
            }
          },
          child: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A0A0A), Color(0xFF121212), Color(0xFF1A1A1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212).withValues(alpha: 0.95),
                      border: const Border(bottom: BorderSide(color: Color(0xFF2B2B2B))),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            _isEdit ? t['editProduct']! : t['addProduct']!,
                            style: const TextStyle(fontSize: 22, color: Colors.white, height: 1.2),
                          ),
                        ),
                        if (_isEdit)
                          IconButton(
                            onPressed: _delete,
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
                        children: [
                          if (_isEdit) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A).withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF2B2B2B)),
                              ),
                              child: Column(
                                children: [
                                  _MetaRow(label: 'Product ID', value: '#${widget.product!.id}', mono: true),
                                  const SizedBox(height: 8),
                                  _MetaRow(
                                    label: t['created']!,
                                    value: _formatDateTime(widget.product!.createdAt, isBn),
                                  ),
                                  const SizedBox(height: 8),
                                  _MetaRow(
                                    label: t['updated']!,
                                    value: _formatDateTime(widget.product!.updatedAt, isBn),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                          _FieldLabel(text: t['productName']!),
                          TextFormField(
                            controller: _name,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: isBn ? 'যেমন, বাসমতি চাল' : 'e.g., Basmati Rice',
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? t['requiredField'] : null,
                          ),
                          const SizedBox(height: 12),
                          _FieldLabel(text: '${t['category']} (${t['optional']})'),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory == _newCategoryValue ? _newCategoryValue : _selectedCategory,
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  t['noCategory']!,
                                  style: const TextStyle(color: Color(0xFF9CA3AF)),
                                ),
                              ),
                              ...existingCategories.map(
                                (c) => DropdownMenuItem<String>(
                                  value: c,
                                  child: Text(c),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: _newCategoryValue,
                                child: Text(isBn ? 'নতুন ক্যাটাগরি...' : 'Add new category...'),
                              ),
                            ],
                            dropdownColor: const Color(0xFF1A1A1A),
                            style: const TextStyle(color: Colors.white),
                            iconEnabledColor: const Color(0xFF9CA3AF),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                                if (value != _newCategoryValue) {
                                  _newCategory.clear();
                                }
                              });
                            },
                          ),
                          if (_selectedCategory == _newCategoryValue) ...[
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _newCategory,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(hintText: t['categoryHint']),
                              validator: (v) {
                                if (_selectedCategory != _newCategoryValue) return null;
                                return (v == null || v.trim().isEmpty) ? t['requiredField'] : null;
                              },
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(text: '${t['buyingPrice']} (৳)'),
                                    TextFormField(
                                      controller: _buying,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                      ],
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(hintText: '0.00'),
                                      validator: (v) => double.tryParse(v ?? '') == null ? t['invalidValue'] : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(text: '${t['sellingPrice']} (৳)'),
                                    TextFormField(
                                      controller: _selling,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                      ],
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(hintText: '0.00'),
                                      validator: (v) => double.tryParse(v ?? '') == null ? t['invalidValue'] : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(text: _isEdit ? (isBn ? 'বর্তমান স্টক' : 'Current Stock') : (isBn ? 'স্টক লেভেল' : 'Stock Level')),
                                    TextFormField(
                                      controller: _stock,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(hintText: '0'),
                                      validator: (v) => int.tryParse(v ?? '') == null ? t['invalidValue'] : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(text: t['unit']!),
                                    DropdownButtonFormField<String>(
                                      initialValue: _unitOptions.contains(_selectedUnit) ? _selectedUnit : 'Unit',
                                      items: _unitOptions
                                          .map(
                                            (u) => DropdownMenuItem<String>(
                                              value: u,
                                              child: Text(_unitLabel(u, isBn)),
                                            ),
                                          )
                                          .toList(),
                                      dropdownColor: const Color(0xFF1A1A1A),
                                      style: const TextStyle(color: Colors.white),
                                      iconEnabledColor: const Color(0xFF9CA3AF),
                                      onChanged: (value) => setState(() => _selectedUnit = value ?? 'Unit'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00121212), Color(0xFF121212), Color(0xFF121212)],
                        ),
                      ),
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _awaitingActionResult ? null : _submit,
                          child: _awaitingActionResult
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(_isEdit ? t['save']! : t['addProduct']!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (_awaitingActionResult || !_formKey.currentState!.validate()) return;
    final categoryName =
        _selectedCategory == _newCategoryValue ? _newCategory.text.trim() : _selectedCategory?.trim();
    setState(() => _awaitingActionResult = true);
    if (_isEdit) {
      context.read<ProductBloc>().add(
            ProductUpdated(
              id: widget.product!.id,
              name: _name.text.trim(),
              buyingPrice: double.parse(_buying.text),
              sellingPrice: double.parse(_selling.text),
              stock: int.parse(_stock.text),
              unit: _selectedUnit,
              categoryName: categoryName?.isEmpty == true ? null : categoryName,
            ),
          );
    } else {
      context.read<ProductBloc>().add(
            ProductAdded(
              name: _name.text.trim(),
              buyingPrice: double.parse(_buying.text),
              sellingPrice: double.parse(_selling.text),
              stock: int.parse(_stock.text),
              unit: _selectedUnit,
              categoryName: categoryName?.isEmpty == true ? null : categoryName,
            ),
          );
    }
  }

  void _delete() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final isBn = context.read<LanguageCubit>().state.languageCode == 'bn';
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(isBn ? 'পণ্য মুছুন' : 'Delete Product'),
          content: Text(isBn ? 'আপনি কি নিশ্চিত?' : 'Are you sure you want to delete this product?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isBn ? 'না' : 'Cancel')),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _awaitingActionResult = true);
                context.read<ProductBloc>().add(ProductDeleted(widget.product!.id));
              },
              child: Text(isBn ? 'মুছুন' : 'Delete'),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime date, bool isBn) {
    final locale = isBn ? 'bn_BD' : 'en_US';
    return DateFormat('MMM d, y • hh:mm a', locale).format(date);
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label:', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: mono ? const Color(0xFF34D399) : const Color(0xFFD1D5DB),
              fontSize: 13,
              fontFamily: mono ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
      ),
    );
  }
}
