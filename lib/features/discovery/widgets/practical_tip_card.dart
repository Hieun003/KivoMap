import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import 'keyword_rich_text.dart';

class PracticalTipCard extends StatelessWidget {
  const PracticalTipCard({
    super.key,
    required this.tip,
    required this.keywords,
  });

  final String tip;
  final List<String> keywords;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KivoScale.w(18)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1C7),
        borderRadius: BorderRadius.circular(KivoScale.r(18)),
        border: Border.all(color: const Color(0xFFFFCA55)),
        boxShadow: KivoShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            KivoIconRegistry.system('default', tone: KivoIconTone.fill),
            color: const Color(0xFFFFB000),
            size: KivoScale.w(44).clamp(34, 54),
          ),
          SizedBox(width: KivoScale.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'M\u1eb9o b\u1ecf t\u00fai th\u1ef1c t\u1ebf:',
                  style: KivoTextStyles.cardTitle.copyWith(
                    color: KivoColors.coffeeText,
                    fontSize: KivoScale.sp(18, min: 15),
                  ),
                ),
                SizedBox(height: KivoScale.h(8)),
                KeywordRichText(
                  text: tip,
                  keywords: keywords,
                  fontSize: KivoScale.sp(14.5, min: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
