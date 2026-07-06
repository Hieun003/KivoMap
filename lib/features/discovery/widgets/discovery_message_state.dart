import 'package:flutter/material.dart';

import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';

class DiscoveryMessageState extends StatelessWidget {
  const DiscoveryMessageState({
    super.key,
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
