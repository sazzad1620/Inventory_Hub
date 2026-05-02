import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/language_cubit.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final selectedCode = context.watch<LanguageCubit>().state.languageCode;
    final borderRadius = BorderRadius.circular(999);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: const Color(0xFF10B981)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOption(
            label: 'English',
            selected: selectedCode == 'en',
            compact: compact,
            onTap: () => context.read<LanguageCubit>().setLanguage('en'),
          ),
          const SizedBox(width: 3),
          _LanguageOption(
            label: 'বাংলা',
            selected: selectedCode == 'bn',
            compact: compact,
            onTap: () => context.read<LanguageCubit>().setLanguage('bn'),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 6 : 7,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? const Color(0xFF10B981).withValues(alpha: 0.20) : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF34D399) : const Color(0xFF9CA3AF),
            fontSize: compact ? 12 : 13,
            height: 1,
          ),
        ),
      ),
    );
  }
}
