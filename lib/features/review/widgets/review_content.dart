import 'package:flutter/material.dart';

import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/review_view_state.dart';
import 'review_header.dart';
import 'review_option_grid.dart';
import 'review_question_card.dart';

class ReviewContent extends StatelessWidget {
  const ReviewContent({
    required this.state,
    required this.onBack,
    required this.onOptionSelected,
    required this.onContinue,
    super.key,
  });

  final ReviewSessionState state;
  final VoidCallback onBack;
  final ValueChanged<ReviewAnswerOptionData> onOptionSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;
    final progress =
        (state.currentQuestionIndex + (state.hasSelection ? 1 : 0)) /
        state.totalCount;

    return Column(
      children: [
        ReviewHeader(state: state, progress: progress, onBack: onBack),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  KivoScale.w(52),
                  KivoScale.h(84),
                  KivoScale.w(52),
                  KivoScale.h(34),
                ),
                sliver: SliverList.list(
                  children: [
                    ReviewQuestionCard(question: question),
                    SizedBox(height: KivoScale.h(54)),
                    ReviewOptionGrid(
                      question: question,
                      selectedOptionId: state.selectedOptionId,
                      onOptionSelected: onOptionSelected,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _ReviewContinueAction(state: state, onContinue: onContinue),
      ],
    );
  }
}

class _ReviewContinueAction extends StatelessWidget {
  const _ReviewContinueAction({required this.state, required this.onContinue});

  final ReviewSessionState state;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: KivoDurations.fast,
      child: state.hasSelection
          ? Padding(
              key: const ValueKey('continue'),
              padding: EdgeInsets.fromLTRB(
                KivoScale.w(34),
                KivoScale.h(18),
                KivoScale.w(34),
                KivoScale.h(34),
              ),
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: KivoScale.w(790)),
                  child: SizedBox(
                    width: double.infinity,
                    height: KivoScale.h(104),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KivoColors.actionOrange,
                        foregroundColor: Colors.white,
                        elevation: 10,
                        shadowColor: KivoColors.orangeShadow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KivoScale.r(36)),
                          side: BorderSide(
                            color: Colors.white,
                            width: KivoScale.w(4),
                          ),
                        ),
                        textStyle: KivoTextStyles.cardTitle.copyWith(
                          fontSize: KivoScale.sp(32, min: 20),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onPressed: onContinue,
                      child: Text(_buttonLabel),
                    ),
                  ),
                ),
              ),
            )
          : SizedBox(key: const ValueKey('empty'), height: KivoScale.h(150)),
    );
  }

  String get _buttonLabel {
    final isLastQuestion =
        state.currentQuestionIndex == state.questions.length - 1;
    return isLastQuestion ? 'Hoàn tất' : 'Tiếp tục';
  }
}
