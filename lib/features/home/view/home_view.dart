import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/home_view_model.dart';
import '../view_model/home_view_state.dart';
import '../widgets/home_category_filter_bar.dart';
import '../widgets/home_context_map_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_review_banner.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: KivoGradients.lightBackground),
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const _HomeLoadingState();
          }

          final errorMessage = controller.errorMessage.value;
          if (errorMessage != null) {
            return _HomeErrorState(
              message: errorMessage,
              onRetry: controller.refresh,
            );
          }

          final dashboardState = controller.state.value;
          if (dashboardState == null) {
            return _HomeEmptyState(onRetry: controller.refresh);
          }

          return _HomeDashboardContent(
            state: dashboardState,
            onStartLearning: controller.startLearning,
            onStartReview: controller.startReview,
            onCategorySelected: controller.selectCategory,
            onTopicSelected: controller.openTopic,
          );
        }),
      ),
    );
  }
}

class _HomeDashboardContent extends StatelessWidget {
  const _HomeDashboardContent({
    required this.state,
    required this.onStartLearning,
    required this.onStartReview,
    required this.onCategorySelected,
    required this.onTopicSelected,
  });

  final HomeDashboardState state;
  final VoidCallback onStartLearning;
  final VoidCallback onStartReview;
  final ValueChanged<HomeCategoryChipData> onCategorySelected;
  final ValueChanged<HomeContextTopicData> onTopicSelected;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            KivoScale.w(24),
            KivoScale.h(18),
            KivoScale.w(24),
            KivoScale.h(135),
          ),
          sliver: SliverList.list(
            children: [
              HomeHeader(
                userName: state.userName,
                roleLabel: state.roleLabel,
                energy: state.energy,
                maxEnergy: state.maxEnergy,
                energyRatio: state.energyRatio,
                streakDays: state.streakDays,
              ),
              SizedBox(height: KivoScale.h(45)),
              HomeReviewBanner(
                status: state.bannerStatus,
                onStartLearning: onStartLearning,
                onStartReview: onStartReview,
              ),
              SizedBox(height: KivoScale.h(50)),
              HomeCategoryFilterBar(
                categories: state.categories,
                onSelected: onCategorySelected,
              ),
              SizedBox(height: KivoScale.h(32)),
              const _SectionTitle(),
              SizedBox(height: KivoScale.h(16)),
              if (state.contextSections.isEmpty)
                const _NoContextSectionsState()
              else
                for (final section in state.contextSections) ...[
                  HomeContextMapSection(
                    section: section,
                    onTopicSelected: onTopicSelected,
                  ),
                  SizedBox(height: KivoScale.h(22)),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NoContextSectionsState extends StatelessWidget {
  const _NoContextSectionsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: KivoScale.w(24),
        vertical: KivoScale.h(26),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(215),
        borderRadius: BorderRadius.circular(KivoScale.r(24)),
        border: Border.all(color: KivoColors.lightBorder.withAlpha(140)),
      ),
      child: Text(
        'Khu vực này đang được Kivo chuẩn bị. Hãy quay lại sau nhé!',
        textAlign: TextAlign.center,
        style: KivoTextStyles.body.copyWith(
          color: KivoColors.secondaryText,
          fontSize: KivoScale.sp(16, min: 12),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          KivoImagePaths.contextMap,
          width: KivoScale.w(100),
          height: KivoScale.w(150),
        ),
        SizedBox(width: KivoScale.w(12)),
        Expanded(
          child: Text(
            'Bản Đồ Ngữ Cảnh',
            style: KivoTextStyles.sectionTitle.copyWith(
              fontSize: KivoScale.sp(30, min: 21),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

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
            Text('Đang mở bản đồ...', style: KivoTextStyles.body),
          ],
        ),
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _HomeMessageState(
      title: 'Chưa có dữ liệu trang chủ',
      message: 'Hãy thử tải lại để Kivo dựng bản đồ học tập cho bạn.',
      buttonLabel: 'Tải lại',
      onPressed: onRetry,
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _HomeMessageState(
      title: 'Kivo bị lạc nhịp',
      message: message,
      buttonLabel: 'Thử lại',
      onPressed: onRetry,
    );
  }
}

class _HomeMessageState extends StatelessWidget {
  const _HomeMessageState({
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
