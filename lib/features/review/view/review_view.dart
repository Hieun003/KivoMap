import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/review_view_model.dart';
import '../widgets/review_content.dart';
import '../widgets/review_states.dart';

class ReviewView extends GetView<ReviewViewModel> {
  const ReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: KivoGradients.lightBackground,
        ),
        child: SafeArea(bottom: true, child: Obx(() => _buildBody())),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const ReviewLoadingState();
    }

    final errorMessage = controller.errorMessage.value;
    if (errorMessage != null) {
      return ReviewMessageState(
        title: 'Chưa mở được Review',
        message: errorMessage,
        buttonLabel: 'Thử lại',
        onPressed: controller.refresh,
      );
    }

    final reviewState = controller.state.value;
    if (reviewState == null) {
      return ReviewMessageState(
        title: 'Chưa có từ đến hạn',
        message: 'Kivo chưa tìm thấy từ vựng cần ôn tập lúc này.',
        buttonLabel: 'Quay lại',
        onPressed: controller.goBack,
      );
    }

    if (reviewState.isComplete) {
      return ReviewCompleteState(state: reviewState, onBack: controller.goBack);
    }

    return ReviewContent(
      state: reviewState,
      onBack: controller.goBack,
      onOptionSelected: controller.selectOption,
      onContinue: controller.continueReview,
    );
  }
}
