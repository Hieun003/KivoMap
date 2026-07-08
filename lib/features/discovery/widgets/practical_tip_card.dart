import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import 'keyword_rich_text.dart';

class PracticalTipCard extends StatelessWidget {
  const PracticalTipCard({
    super.key,
    required this.tip,
    required this.tipEn,
    required this.keywords,
  });

  final String tip;
  final String tipEn;
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
                if (tipEn.isNotEmpty) ...[
                  SizedBox(height: KivoScale.h(8)),
                  KeywordRichText(
                    text: tipEn,
                    keywords: keywords,
                    fontSize: KivoScale.sp(14.5, min: 12),
                  ),
                ],
                if (tip.isNotEmpty && tip != tipEn) ...[
                  SizedBox(height: KivoScale.h(6)),
                  const Divider(color: Color(0x33FFB000), height: 1),
                  SizedBox(height: KivoScale.h(6)),
                  Text(
                    tip,
                    style: KivoTextStyles.body.copyWith(
                      color: KivoColors.secondaryText,
                      fontSize: KivoScale.sp(13.5, min: 11),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
