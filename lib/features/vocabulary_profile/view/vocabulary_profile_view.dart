import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/vocabulary_profile_view_model.dart';
import '../view_model/vocabulary_profile_view_state.dart';

class VocabularyProfileView extends GetView<VocabularyProfileViewModel> {
  const VocabularyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: KivoColors.kivoTeal),
            );
          }
          final error = controller.errorMessage.value;
          final state = controller.state.value;
          if (error != null || state == null) {
            return _ErrorState(
              message:
                  error ?? 'Kh\u00f4ng t\u00ecm th\u1ea5y t\u1eeb v\u1ef1ng.',
              onBack: controller.goBack,
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              KivoScale.w(20),
              KivoScale.h(16),
              KivoScale.w(20),
              KivoScale.h(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(onBack: controller.goBack),
                SizedBox(height: KivoScale.h(22)),
                _VocabularyHero(
                  state: state,
                  onPlay: controller.playPronunciation,
                ),
                SizedBox(height: KivoScale.h(24)),
                _ContextSectionHeader(state: state),
                SizedBox(height: KivoScale.h(14)),
                for (var index = 0; index < state.contexts.length; index++) ...[
                  _ContextCard(
                    contextData: state.contexts[index],
                    iconKey: state.iconKey,
                  ),
                  if (index != state.contexts.length - 1)
                    SizedBox(height: KivoScale.h(12)),
                ],
                SizedBox(height: KivoScale.h(24)),
                _DiscoveryPrompt(onTap: controller.continueDiscovery),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final backButtonSize = KivoScale.w(44).clamp(42, 54).toDouble();

    return SizedBox(
      height: backButtonSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: 'Quay l\u1ea1i',
              child: Material(
                color: Colors.white.withAlpha(235),
                borderRadius: BorderRadius.circular(KivoScale.r(12)),
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(KivoScale.r(12)),
                  child: Container(
                    width: backButtonSize,
                    height: backButtonSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(KivoScale.r(12)),
                      border: Border.all(
                        color: KivoColors.keywordOrange.withAlpha(52),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: KivoColors.orangeShadow.withAlpha(48),
                          blurRadius: KivoScale.r(10),
                          offset: Offset(0, KivoScale.h(5)),
                        ),
                      ],
                    ),
                    child: Icon(
                      KivoIconRegistry.system('back', tone: KivoIconTone.bold),
                      color: KivoColors.coffeeText,
                      size: backButtonSize * 0.52,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: backButtonSize + KivoScale.w(12),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'H\u1ed3 S\u01a1 C\u1ed5 Ng\u1eef',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: KivoTextStyles.screenTitle.copyWith(
                    color: KivoColors.coffeeText,
                    fontSize: KivoScale.sp(28, min: 21),
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

class _VocabularyHero extends StatelessWidget {
  const _VocabularyHero({required this.state, required this.onPlay});

  final VocabularyProfileState state;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KivoScale.w(22)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBF1), Color(0xFFFFF8E8)],
        ),
        borderRadius: BorderRadius.circular(KivoScale.r(28)),
        border: Border.all(color: const Color(0xFFF1D99B)),
      ),
      child: Row(
        children: [
          Container(
            width: KivoScale.w(112),
            height: KivoScale.w(112),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5FF),
              borderRadius: BorderRadius.circular(KivoScale.r(24)),
            ),
            child: Icon(
              KivoIconRegistry.vocabulary(state.iconKey),
              size: KivoScale.w(70),
              color: const Color(0xFF0E75C9),
            ),
          ),
          SizedBox(width: KivoScale.w(20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.word,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: KivoTextStyles.display.copyWith(
                    color: KivoColors.coffeeText,
                    fontSize: KivoScale.sp(42, min: 28),
                    height: 1.05,
                  ),
                ),
                SizedBox(height: KivoScale.h(8)),
                Text.rich(
                  TextSpan(
                    text: state.meaning,
                    children: [
                      TextSpan(
                        text: '  (${state.partOfSpeech})',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: KivoTextStyles.body.copyWith(
                    color: KivoColors.secondaryText,
                    fontSize: KivoScale.sp(19, min: 14),
                  ),
                ),
                if (state.pronunciation.isNotEmpty) ...[
                  SizedBox(height: KivoScale.h(5)),
                  Text(
                    state.pronunciation,
                    style: KivoTextStyles.body.copyWith(
                      color: KivoColors.secondaryText,
                      fontSize: KivoScale.sp(14, min: 11),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: KivoScale.w(10)),
          InkWell(
            onTap: onPlay,
            customBorder: const CircleBorder(),
            child: Container(
              width: KivoScale.w(54),
              height: KivoScale.w(54),
              decoration: const BoxDecoration(
                color: Color(0xFF14BED1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: KivoScale.w(29),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextSectionHeader extends StatelessWidget {
  const _ContextSectionHeader({required this.state});

  final VocabularyProfileState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: KivoScale.w(48),
          height: KivoScale.w(48),
          decoration: const BoxDecoration(
            color: Color(0xFFEAF6FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.map_outlined, color: Color(0xFF0E75A8)),
        ),
        SizedBox(width: KivoScale.w(12)),
        Expanded(
          child: Text(
            'B\u1ea3n \u0110\u1ed3 Ng\u1eef C\u1ea3nh T\u00edch L\u0169y',
            style: KivoTextStyles.sectionTitle.copyWith(
              color: KivoColors.coffeeText,
              fontSize: KivoScale.sp(24, min: 18),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: KivoScale.w(12),
            vertical: KivoScale.h(8),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F7FB),
            borderRadius: BorderRadius.circular(KivoScale.r(16)),
          ),
          child: Text(
            '(${state.unlockedContextCount}/${state.totalContextCount})',
            style: KivoTextStyles.body.copyWith(
              color: const Color(0xFF06769F),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.contextData, required this.iconKey});

  final VocabularyProfileContext contextData;
  final String iconKey;

  @override
  Widget build(BuildContext context) {
    final unlocked = contextData.isUnlocked;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: unlocked ? 1 : 0.58,
      child: Container(
        padding: EdgeInsets.all(KivoScale.w(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(KivoScale.r(20)),
          border: Border.all(color: KivoColors.lightBorder),
          boxShadow: unlocked ? KivoShadows.soft : null,
        ),
        child: Row(
          children: [
            Container(
              width: KivoScale.w(42),
              height: KivoScale.w(42),
              decoration: BoxDecoration(
                color: unlocked
                    ? const Color(0xFFE9F8E2)
                    : const Color(0xFFECEFF1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                unlocked ? Icons.check_rounded : Icons.lock_outline_rounded,
                color: unlocked
                    ? const Color(0xFF159B38)
                    : const Color(0xFF667078),
                size: KivoScale.w(24),
              ),
            ),
            SizedBox(width: KivoScale.w(14)),
            Container(
              width: KivoScale.w(58),
              height: KivoScale.w(58),
              decoration: BoxDecoration(
                color: unlocked
                    ? const Color(0xFFF2F8FD)
                    : const Color(0xFFF1F2F3),
                borderRadius: BorderRadius.circular(KivoScale.r(14)),
              ),
              child: Icon(
                KivoIconRegistry.vocabulary(iconKey),
                color: unlocked
                    ? const Color(0xFF137AC3)
                    : const Color(0xFF7B858C),
                size: KivoScale.w(34),
              ),
            ),
            SizedBox(width: KivoScale.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contextData.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KivoTextStyles.cardTitle.copyWith(
                      color: unlocked
                          ? KivoColors.coffeeText
                          : KivoColors.secondaryText,
                      fontSize: KivoScale.sp(20, min: 15),
                    ),
                  ),
                  SizedBox(height: KivoScale.h(3)),
                  Text(
                    unlocked
                        ? contextData.translation
                        : 'Ch\u01b0a m\u1edf kh\u00f3a - H\u00e3y s\u0103n t\u00ecm tr\u00ean KivoMap',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KivoTextStyles.body.copyWith(
                      color: KivoColors.secondaryText,
                      fontSize: KivoScale.sp(13, min: 10),
                      fontStyle: unlocked ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryPrompt extends StatelessWidget {
  const _DiscoveryPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KivoScale.r(22)),
      child: Container(
        padding: EdgeInsets.all(KivoScale.w(20)),
        decoration: BoxDecoration(
          color: const Color(0xFFF4FAFF),
          borderRadius: BorderRadius.circular(KivoScale.r(22)),
          border: Border.all(color: const Color(0xFFB9E0FA)),
        ),
        child: Row(
          children: [
            Container(
              width: KivoScale.w(64),
              height: KivoScale.w(64),
              decoration: const BoxDecoration(
                color: Color(0xFFE3F4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.explore_rounded,
                color: Color(0xFF0B80CE),
                size: 38,
              ),
            ),
            SizedBox(width: KivoScale.w(18)),
            Expanded(
              child: Text(
                'H\u00e3y quay l\u1ea1i Ma tr\u1eadn Kh\u00e1m ph\u00e1 \u0111\u1ec3 ti\u1ebfp t\u1ee5c k\u00edch ho\u1ea1t c\u00e1c b\u1ed1i c\u1ea3nh c\u00f2n l\u1ea1i!',
                style: KivoTextStyles.body.copyWith(
                  color: KivoColors.coffeeText,
                  fontSize: KivoScale.sp(16, min: 12),
                  height: 1.45,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF0B80CE),
              size: KivoScale.w(26),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(KivoScale.w(28)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: KivoScale.h(16)),
            FilledButton(onPressed: onBack, child: const Text('Quay l\u1ea1i')),
          ],
        ),
      ),
    );
  }
}
