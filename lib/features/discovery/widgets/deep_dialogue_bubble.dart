import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../../../data/tts_service.dart';
import '../view_model/discovery_view_state.dart';
import 'keyword_rich_text.dart';

class DeepDialogueBubble extends StatefulWidget {
  const DeepDialogueBubble({
    super.key,
    required this.line,
    required this.alignRight,
    required this.keywords,
  });

  final DiscoveryDialogueLine line;
  final bool alignRight;
  final List<String> keywords;

  @override
  State<DeepDialogueBubble> createState() => _DeepDialogueBubbleState();
}

class _DeepDialogueBubbleState extends State<DeepDialogueBubble> {
  bool _showTranslation = false;
  bool _speaking = false;

  Future<void> _onSpeak() async {
    if (_speaking) {
      await TtsService.instance.stop();
      setState(() => _speaking = false);
      return;
    }
    setState(() => _speaking = true);
    // Guest (trái, người hỏi): pitch cao hơn – giọng nhẹ, thắc mắc
    // Host (phải, người trả lời): pitch thấp hơn – giọng trầm, tự tin
    final pitch = widget.alignRight ? 0.82 : 1.12;
    await TtsService.instance.speak(widget.line.text, pitch: pitch);
    if (mounted) setState(() => _speaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = widget.alignRight
        ? const Color(0xFFEAF5FF)
        : Colors.white.withAlpha(238);
    final borderColor = widget.alignRight
        ? const Color(0xFF9BC9FF)
        : const Color(0xFFE4D7C9);
    final speakerColor = widget.alignRight
        ? const Color(0xFF125AD8)
        : const Color(0xFF0E61D7);

    return Padding(
      padding: EdgeInsets.only(bottom: KivoScale.h(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: widget.alignRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!widget.alignRight) const _SpeakerAvatar(iconKey: 'profile'),
          if (!widget.alignRight) SizedBox(width: KivoScale.w(8)),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: KivoScale.w(292).clamp(248, 420),
              ),
              padding: EdgeInsets.all(KivoScale.w(16)),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(KivoScale.r(18)),
                border: Border.all(color: borderColor),
                boxShadow: KivoShadows.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.line.speaker,
                    style: KivoTextStyles.caption.copyWith(
                      color: speakerColor,
                      fontSize: KivoScale.sp(13.5, min: 11),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: KivoScale.h(8)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: KeywordRichText(
                          text: widget.line.text,
                          keywords: widget.keywords,
                          fontSize: KivoScale.sp(15.5, min: 12.5),
                        ),
                      ),
                      SizedBox(width: KivoScale.w(8)),
                      _SmallRoundIconButton(
                        icon: KivoIconRegistry.system(
                          _speaking ? 'close' : 'audio',
                          tone: KivoIconTone.fill,
                        ),
                        color: _speaking
                            ? KivoColors.targetPurple
                            : const Color(0xFF2D8CFF),
                        onPressed: _onSpeak,
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: KivoScale.h(10)),
                    child: const _DashedDivider(color: Color(0xFFDCCBB8)),
                  ),
                  GestureDetector(
                    onTap: widget.line.translation.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _showTranslation = !_showTranslation;
                            });
                          },
                    child: Row(
                      children: [
                        Icon(
                          _showTranslation
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: KivoColors.coffeeText,
                          size: KivoScale.w(22).clamp(18, 26),
                        ),
                        SizedBox(width: KivoScale.w(8)),
                        Text(
                          'Hi\u1ec7n b\u1ea3n d\u1ecbch',
                          style: KivoTextStyles.body.copyWith(
                            color: KivoColors.coffeeText,
                            fontSize: KivoScale.sp(14, min: 12),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showTranslation &&
                      widget.line.translation.isNotEmpty) ...[
                    SizedBox(height: KivoScale.h(8)),
                    Text(
                      widget.line.translation,
                      style: KivoTextStyles.body.copyWith(
                        color: KivoColors.secondaryText,
                        fontSize: KivoScale.sp(13.5, min: 11.5),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (widget.alignRight) SizedBox(width: KivoScale.w(8)),
          if (widget.alignRight)
            const _SpeakerAvatar(iconKey: 'immigration_officer'),
        ],
      ),
    );
  }
}

class _SpeakerAvatar extends StatelessWidget {
  const _SpeakerAvatar({required this.iconKey});

  final String iconKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: KivoScale.w(48).clamp(38, 58),
      height: KivoScale.w(48).clamp(38, 58),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE6D9CB)),
        boxShadow: KivoShadows.soft,
      ),
      child: Icon(
        KivoIconRegistry.vocabulary(iconKey, tone: KivoIconTone.duotone),
        color: KivoColors.actionOrange,
        size: KivoScale.w(27).clamp(21, 34),
      ),
    );
  }
}

class _SmallRoundIconButton extends StatelessWidget {
  const _SmallRoundIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: KivoScale.w(32).clamp(28, 38),
        height: KivoScale.w(32).clamp(28, 38),
        decoration: BoxDecoration(
          color: color.withAlpha(32),
          shape: BoxShape.circle,
          border: Border.all(color: color.withAlpha(130)),
        ),
        child: Icon(icon, color: color, size: KivoScale.w(19).clamp(16, 23)),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
