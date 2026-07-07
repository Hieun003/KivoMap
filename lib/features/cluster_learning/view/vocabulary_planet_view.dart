import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/vocabulary_planet_view_model.dart';
import '../view_model/vocabulary_planet_view_state.dart';
import '../widgets/vocabulary_planet_node_map.dart';
import '../widgets/vocabulary_planet_summary_card.dart';

class VocabularyPlanetView extends GetView<VocabularyPlanetViewModel> {
  const VocabularyPlanetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: KivoGradients.lightBackground,
        ),
        child: SafeArea(
          bottom: false,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const _VocabularyPlanetLoadingState();
            }

            final errorMessage = controller.errorMessage.value;
            if (errorMessage != null) {
              return _VocabularyPlanetMessageState(
                title: 'Kivo chưa tìm thấy hành tinh',
                message: errorMessage,
                buttonLabel: 'Thử lại',
                onPressed: controller.refresh,
              );
            }

            final planetState = controller.state.value;
            if (planetState == null) {
              return _VocabularyPlanetMessageState(
                title: 'Chưa có từ vựng',
                message: 'Cụm học này đang được Kivo chuẩn bị.',
                buttonLabel: 'Quay lại',
                onPressed: controller.goBack,
              );
            }

            return _VocabularyPlanetContent(
              state: planetState,
              onBack: controller.goBack,
              onNodeSelected: controller.selectNode,
            );
          }),
        ),
      ),
    );
  }
}

class _VocabularyPlanetContent extends StatelessWidget {
  const _VocabularyPlanetContent({
    required this.state,
    required this.onBack,
    required this.onNodeSelected,
  });

  final VocabularyPlanetState state;
  final VoidCallback onBack;
  final ValueChanged<VocabularyPlanetNodeData> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            KivoScale.w(14),
            KivoScale.h(10),
            KivoScale.w(14),
            KivoScale.h(42),
          ),
          sliver: SliverList.list(
            children: [
              _VocabularyPlanetHeader(
                title: state.title,
                subtitle: state.subtitle,
                onBack: onBack,
              ),
              SizedBox(height: KivoScale.h(16)),
              VocabularyPlanetSummaryCard(state: state),
              SizedBox(height: KivoScale.h(18)),
              VocabularyPlanetNodeMap(
                nodes: state.nodes,
                progressRatio: state.progressRatio,
                onNodeSelected: onNodeSelected,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VocabularyPlanetHeader extends StatelessWidget {
  const _VocabularyPlanetHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _BackButton(onPressed: onBack),
        SizedBox(height: KivoScale.h(10)),
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: KivoTextStyles.display.copyWith(
                    fontSize: KivoScale.sp(34, min: 24),
                    color: KivoColors.coffeeText,
                    height: 1.04,
                  ),
                ),
              ),
              SizedBox(height: KivoScale.h(5)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: KivoTextStyles.cardTitle.copyWith(
                    color: KivoColors.secondaryText,
                    fontSize: KivoScale.sp(20, min: 15),
                    height: 1.08,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = KivoScale.w(44).clamp(42, 54).toDouble();

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(235),
          borderRadius: BorderRadius.circular(KivoScale.r(12)),
          border: Border.all(color: KivoColors.keywordOrange.withAlpha(52)),
          boxShadow: [
            BoxShadow(
              color: KivoColors.orangeShadow.withAlpha(48),
              blurRadius: KivoScale.r(10),
              offset: Offset(0, KivoScale.h(5)),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          KivoIconRegistry.system('back', tone: KivoIconTone.bold),
          color: KivoColors.coffeeText,
          size: size * 0.52,
        ),
      ),
    );
  }
}

class _VocabularyPlanetLoadingState extends StatelessWidget {
  const _VocabularyPlanetLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(KivoScale.w(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: KivoColors.kivoTeal),
            SizedBox(height: KivoScale.h(16)),
            Text('Đang mở hành tinh từ vựng...', style: KivoTextStyles.body),
          ],
        ),
      ),
    );
  }
}

class _VocabularyPlanetMessageState extends StatelessWidget {
  const _VocabularyPlanetMessageState({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(KivoScale.w(30)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(KivoScale.w(24)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(KivoScale.r(28)),
            border: Border.all(color: KivoColors.lightBorder),
            boxShadow: KivoShadows.soft,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: KivoTextStyles.sectionTitle.copyWith(
                  fontSize: KivoScale.sp(24, min: 18),
                ),
              ),
              SizedBox(height: KivoScale.h(10)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: KivoTextStyles.body.copyWith(
                  fontSize: KivoScale.sp(16, min: 12),
                ),
              ),
              SizedBox(height: KivoScale.h(18)),
              FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
