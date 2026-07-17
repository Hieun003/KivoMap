import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/treasure_view_model.dart';
import '../view_model/treasure_view_state.dart';

class TreasureView extends GetView<TreasureViewModel> {
  const TreasureView({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: KivoGradients.lightBackground),
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) return const _TreasureLoadingState();
          final error = controller.errorMessage.value;
          if (error != null) return _TreasureMessageState(message: error);

          final state = controller.state.value;
          final items = controller.filteredItems;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              KivoScale.w(24),
              KivoScale.h(26),
              KivoScale.w(24),
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Kho B\u00e1u C\u1ee7a B\u1ea1n',
                        style: KivoTextStyles.screenTitle.copyWith(
                          color: KivoColors.coffeeText,
                          fontSize: KivoScale.sp(34, min: 25),
                        ),
                      ),
                    ),
                    Container(
                      width: KivoScale.w(46),
                      height: KivoScale.w(46),
                      padding: EdgeInsets.all(KivoScale.w(5)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFD765), Color(0xFFFFAE18)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFAE18).withAlpha(80),
                            blurRadius: KivoScale.w(8),
                            offset: Offset(0, KivoScale.h(3)),
                          ),
                        ],
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFEAA5),
                            width: KivoScale.w(1.5),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.star_rounded,
                            size: KivoScale.w(23),
                            color: const Color(0xFFFF9D00),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: KivoScale.h(6)),
                Text(
                  'N\u01a1i l\u01b0u tr\u1eef c\u00e1c t\u1eeb ng\u1eef v\u00e0 b\u1ed1i c\u1ea3nh b\u1ea1n \u0111\u00e3 chinh ph\u1ee5c.',
                  style: KivoTextStyles.body.copyWith(
                    color: KivoColors.secondaryText,
                    fontSize: KivoScale.sp(16, min: 13),
                  ),
                ),
                SizedBox(height: KivoScale.h(22)),
                _TreasureSearchField(onChanged: controller.updateSearch),
                SizedBox(height: KivoScale.h(18)),
                Expanded(
                  child: state == null || state.items.isEmpty
                      ? const _TreasureMessageState(
                          message:
                              'Kho b\u00e1u \u0111ang tr\u1ed1ng. H\u00e3y ho\u00e0n th\u00e0nh m\u1ed9t t\u1eeb \u0111\u1ec3 l\u01b0u n\u00f3 t\u1ea1i \u0111\u00e2y nh\u00e9!',
                        )
                      : items.isEmpty
                      ? const _TreasureMessageState(
                          message:
                              'Kh\u00f4ng t\u00ecm th\u1ea5y t\u1eeb ph\u00f9 h\u1ee3p trong Kho b\u00e1u.',
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(bottom: KivoScale.h(24)),
                          itemCount: items.length,
                          separatorBuilder: (_, index) =>
                              SizedBox(height: KivoScale.h(16)),
                          itemBuilder: (_, index) {
                            final item = items[index];
                            return GestureDetector(
                              onTap: () => controller.openVocabulary(item),
                              child: _TreasureVocabularyCard(item: item),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TreasureSearchField extends StatelessWidget {
  const _TreasureSearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText:
            'T\u00ecm ki\u1ebfm t\u1eeb ng\u1eef \u0111\u00e3 m\u1edf kh\u00f3a...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: KivoScale.h(17)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KivoScale.r(18)),
          borderSide: BorderSide(color: KivoColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KivoScale.r(18)),
          borderSide: BorderSide(color: KivoColors.lightBorder),
        ),
      ),
    );
  }
}

class _TreasureVocabularyCard extends StatelessWidget {
  const _TreasureVocabularyCard({required this.item});

  final TreasureVocabulary item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KivoScale.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: KivoRadii.largeCard,
        border: Border.all(color: KivoColors.lightBorder),
        boxShadow: KivoShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: KivoScale.w(78),
            height: KivoScale.w(78),
            decoration: BoxDecoration(
              color: KivoColors.kivoTeal.withAlpha(28),
              borderRadius: BorderRadius.circular(KivoScale.r(18)),
            ),
            child: Icon(
              KivoIconRegistry.vocabulary(item.iconKey),
              size: KivoScale.w(42),
              color: KivoColors.kivoTeal,
            ),
          ),
          SizedBox(width: KivoScale.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.word,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KivoTextStyles.cardTitle.copyWith(
                    color: KivoColors.coffeeText,
                    fontSize: KivoScale.sp(22, min: 17),
                  ),
                ),
                if (item.partOfSpeech.isNotEmpty) ...[
                  SizedBox(height: KivoScale.h(2)),
                  Text(
                    '(${item.partOfSpeech})',
                    style: KivoTextStyles.body.copyWith(
                      color: KivoColors.secondaryText,
                      fontStyle: FontStyle.italic,
                      fontSize: KivoScale.sp(13, min: 11),
                    ),
                  ),
                ],
                SizedBox(height: KivoScale.h(4)),
                Text(
                  item.meaning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KivoTextStyles.body.copyWith(
                    color: KivoColors.secondaryText,
                    fontSize: KivoScale.sp(16, min: 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: KivoScale.w(8)),
          _ContextBadge(label: item.contextProgressLabel),
        ],
      ),
    );
  }
}

class _ContextBadge extends StatelessWidget {
  const _ContextBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: KivoScale.w(10),
        vertical: KivoScale.h(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7E8),
        borderRadius: BorderRadius.circular(KivoScale.r(14)),
      ),
      child: Text(
        label,
        style: KivoTextStyles.body.copyWith(
          color: const Color(0xFF128331),
          fontWeight: FontWeight.w800,
          fontSize: KivoScale.sp(13, min: 10),
        ),
      ),
    );
  }
}

class _TreasureLoadingState extends StatelessWidget {
  const _TreasureLoadingState();

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: KivoColors.kivoTeal),
  );
}

class _TreasureMessageState extends StatelessWidget {
  const _TreasureMessageState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(KivoScale.w(28)),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: KivoTextStyles.body.copyWith(color: KivoColors.secondaryText),
      ),
    ),
  );
}
