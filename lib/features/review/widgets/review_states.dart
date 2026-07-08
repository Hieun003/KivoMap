import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/review_view_state.dart';

class ReviewCompleteState extends StatelessWidget {
  const ReviewCompleteState({
    required this.state,
    required this.onBack,
    super.key,
  });

  final ReviewSessionState state;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _ReviewStateShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            KivoIconRegistry.reward('star', tone: KivoIconTone.fill),
            color: KivoColors.warningGold,
            size: KivoScale.w(136),
          ),
          SizedBox(height: KivoScale.h(32)),
          Text(
            'Review hoàn tất',
            textAlign: TextAlign.center,
            style: KivoTextStyles.sectionTitle.copyWith(
              color: KivoColors.inkText,
              fontSize: KivoScale.sp(48, min: 29),
            ),
          ),
          SizedBox(height: KivoScale.h(20)),
          Text(
            '${state.vocabularyWord} / ${state.vocabularyMeaning} - '
            '${state.correctCount}/${state.totalCount} câu đúng',
            textAlign: TextAlign.center,
            style: KivoTextStyles.body.copyWith(
              color: KivoColors.secondaryText,
              fontSize: KivoScale.sp(27, min: 17),
              height: 1.35,
            ),
          ),
          SizedBox(height: KivoScale.h(46)),
          _ReviewStateButton(label: 'Quay lại', onPressed: onBack),
        ],
      ),
    );
  }
}

class ReviewLoadingState extends StatelessWidget {
  const ReviewLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: KivoColors.kivoTeal),
    );
  }
}

class ReviewMessageState extends StatelessWidget {
  const ReviewMessageState({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
    super.key,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _ReviewStateShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            KivoIconRegistry.system('review', tone: KivoIconTone.duotone),
            color: KivoColors.kivoTeal,
            size: KivoScale.w(128),
          ),
          SizedBox(height: KivoScale.h(30)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: KivoTextStyles.sectionTitle.copyWith(
              color: KivoColors.inkText,
              fontSize: KivoScale.sp(44, min: 27),
            ),
          ),
          SizedBox(height: KivoScale.h(20)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: KivoTextStyles.body.copyWith(
              color: KivoColors.secondaryText,
              fontSize: KivoScale.sp(26, min: 17),
              height: 1.35,
            ),
          ),
          SizedBox(height: KivoScale.h(44)),
          _ReviewStateButton(label: buttonLabel, onPressed: onPressed),
        ],
      ),
    );
  }
}

class _ReviewStateShell extends StatelessWidget {
  const _ReviewStateShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: KivoScale.w(30),
          vertical: KivoScale.h(28),
        ),
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: KivoScale.w(780)),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: KivoScale.w(62),
                vertical: KivoScale.h(68),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(KivoScale.r(42)),
                border: Border.all(
                  color: KivoColors.kivoTeal.withAlpha(145),
                  width: KivoScale.w(4),
                ),
                boxShadow: KivoShadows.raised,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewStateButton extends StatelessWidget {
  const _ReviewStateButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: KivoScale.h(94),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: KivoColors.kivoTeal,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: KivoColors.tealShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KivoScale.r(34)),
            side: BorderSide(color: Colors.white, width: KivoScale.w(4)),
          ),
          textStyle: KivoTextStyles.cardTitle.copyWith(
            fontSize: KivoScale.sp(30, min: 19),
            fontWeight: FontWeight.w900,
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
