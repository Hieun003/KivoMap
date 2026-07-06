import 'package:flutter/material.dart';

import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';

class DiscoveryLoadingState extends StatelessWidget {
  const DiscoveryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(KivoScale.w(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: KivoColors.targetPurple),
            SizedBox(height: KivoScale.h(16)),
            Text(
              '\u0110ang m\u1edf Ma tr\u1eadn Kh\u00e1m ph\u00e1...',
              style: KivoTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}
