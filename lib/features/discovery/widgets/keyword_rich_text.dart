import 'package:flutter/material.dart';

import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';

class KeywordMatch {
  const KeywordMatch({
    required this.start,
    required this.end,
    required this.isTarget,
  });

  final int start;
  final int end;
  final bool isTarget;
}

class KeywordRichText extends StatelessWidget {
  const KeywordRichText({
    super.key,
    required this.text,
    required this.keywords,
    required this.fontSize,
  });

  final String text;
  final List<String> keywords;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final baseStyle = KivoTextStyles.body.copyWith(
      color: KivoColors.inkText,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.45,
    );
    final spans = <InlineSpan>[];
    var cursor = 0;

    while (cursor < text.length) {
      final match = _nextKeywordMatch(text, keywords, cursor);
      if (match == null) {
        spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
        break;
      }

      if (match.start > cursor) {
        spans.add(
          TextSpan(text: text.substring(cursor, match.start), style: baseStyle),
        );
      }

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: KivoScale.w(2)),
            padding: EdgeInsets.symmetric(
              horizontal: KivoScale.w(7),
              vertical: KivoScale.h(2),
            ),
            decoration: BoxDecoration(
              color: match.isTarget
                  ? const Color(0xFFF1E9FF)
                  : KivoColors.softOrangeCard,
              borderRadius: BorderRadius.circular(KivoScale.r(7)),
              border: Border.all(
                color: match.isTarget
                    ? const Color(0xFFB99CFF)
                    : KivoColors.keywordOrange,
              ),
            ),
            child: Text(
              text.substring(match.start, match.end),
              style: KivoTextStyles.body.copyWith(
                color: match.isTarget
                    ? KivoColors.targetPurple
                    : const Color(0xFFB05200),
                fontSize: fontSize * 0.94,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
          ),
        ),
      );
      cursor = match.end;
    }

    return RichText(text: TextSpan(children: spans));
  }

  KeywordMatch? _nextKeywordMatch(
    String source,
    List<String> candidates,
    int start,
  ) {
    final lowerSource = source.toLowerCase();
    KeywordMatch? bestMatch;
    for (final rawKeyword in candidates) {
      final keyword = rawKeyword.trim();
      if (keyword.length < 2) continue;
      final index = lowerSource.indexOf(keyword.toLowerCase(), start);
      if (index < 0) continue;
      final match = KeywordMatch(
        start: index,
        end: index + keyword.length,
        isTarget: candidates.take(2).contains(rawKeyword),
      );
      if (bestMatch == null ||
          match.start < bestMatch.start ||
          (match.start == bestMatch.start && match.end > bestMatch.end)) {
        bestMatch = match;
      }
    }
    return bestMatch;
  }
}
