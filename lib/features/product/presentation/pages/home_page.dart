import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/language_cubit.dart';
import '../../domain/entities/product_item.dart';
import '../bloc/product_bloc.dart';
import 'product_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.onSignOut,
    super.key,
  });

  final VoidCallback onSignOut;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductsLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (_, locale) {
        final t = AppStrings.values[locale.languageCode]!;
        return Scaffold(
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
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212).withValues(alpha: 0.95),
                      border: const Border(bottom: BorderSide(color: Color(0xFF2B2B2B))),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t['inventory']!,
                                style: const TextStyle(fontSize: 30, color: Colors.white),
                              ),
                            ),
                            IconButton(
                              onPressed: () => context.read<LanguageCubit>().toggleLanguage(),
                              icon: const Icon(Icons.language, color: Color(0xFF9CA3AF)),
                            ),
                            IconButton(
                              onPressed: widget.onSignOut,
                              icon: const Icon(Icons.logout, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (v) => setState(() => _query = v),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                            hintText: t['search'],
                            hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (_, state) {
                        if (state.status == ProductStatus.loading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (state.status == ProductStatus.failure) {
                          return Center(
                            child: Text(
                              t['operationFailed'] ?? 'Operation failed',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          );
                        }

                        final list = state.products.where((p) {
                          final q = _query.toLowerCase();
                          return p.name.toLowerCase().contains(q) || p.id.toString().contains(q);
                        }).toList();
                        if (list.isEmpty) {
                          return Center(child: Text(t['noProducts']!, style: const TextStyle(color: Color(0xFF9CA3AF))));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 100),
                          itemCount: list.length,
                          itemBuilder: (_, i) => _ProductTile(product: list[i], t: t),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: SizedBox(
            width: MediaQuery.of(context).size.width - 28,
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormPage())),
              label: Text(t['addProduct']!),
              icon: const Icon(Icons.add),
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.t});

  final ProductItem product;
  final Map<String, String> t;

  @override
  Widget build(BuildContext context) {
    final code = context.watch<LanguageCubit>().state.languageCode;
    final locale = code == 'bn' ? 'bn_BD' : 'en_US';
    final formatter = DateFormat('MMM d', locale);
    final updatedText = formatter.format(product.updatedAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF1E1E1E)],
              ),
              border: Border.all(color: const Color(0xFF2B2B2B)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF10B981).withValues(alpha: 0.12),
                                  const Color(0xFF10B981).withValues(alpha: 0.06),
                                ],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Color(0xFF34D399),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (product.stock < 5) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                                        ),
                                        child: Text(
                                          t['lowStock']!,
                                          style: const TextStyle(
                                            color: Color(0xFFFBBF24),
                                            fontSize: 11,
                                            height: 1.1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '৳${product.sellingPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.stock.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 22, height: 1),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t['units']!,
                          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  color: const Color(0xFF2B2B2B),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'ID: #${product.id}',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '${t['updated']}: $updatedText',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
