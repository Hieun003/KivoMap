import 'package:flutter/material.dart';

import '../../../app/icons/kivo_icon_registry.dart';
import '../../../app/responsive/kivo_scale.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../../../data/tts_service.dart';
import '../view_model/discovery_view_state.dart';
import 'deep_dialogue_bubble.dart';
import 'practical_tip_card.dart';

class DiscoveryContextBottomSheet extends StatefulWidget {
  const DiscoveryContextBottomSheet({
    super.key,
    required this.rootNode,
    required this.contextNode,
    required this.onUnderstood,
    this.actionLabel,
  });

  final DiscoveryRootNode rootNode;
  final DiscoveryContextNode contextNode;
  final VoidCallback onUnderstood;
  final String? actionLabel;

  @override
  State<DiscoveryContextBottomSheet> createState() => _DiscoveryContextBottomSheetState();
}

class _DiscoveryContextBottomSheetState extends State<DiscoveryContextBottomSheet> {
  int? _selectedAnswerIndex;
  late List<_QuizOption> _shuffledOptions;
  bool _isQuizActive = false;

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  @override
  void didUpdateWidget(covariant DiscoveryContextBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contextNode.id != widget.contextNode.id) {
      _initQuiz();
    }
  }

  void _initQuiz() {
    _selectedAnswerIndex = null;
    final node = widget.contextNode;

    final canShow = node.dialogue.length >= 2 &&
        node.wrongChoices.isNotEmpty &&
        node.wrongChoicesVi.isNotEmpty;

    if (!canShow) {
      _shuffledOptions = [];
      _isQuizActive = false;
      return;
    }

    final correctOpt = _QuizOption(
      text: node.dialogue[1].text.replaceAll('**', ''),
      translation: node.dialogue[1].translation.replaceAll('**', ''),
      isCorrect: true,
    );

    final options = <_QuizOption>[correctOpt];
    for (var i = 0; i < node.wrongChoices.length; i++) {
      final text = node.wrongChoices[i].replaceAll('**', '');
      final translation = i < node.wrongChoicesVi.length
          ? node.wrongChoicesVi[i].replaceAll('**', '')
          : '';
      options.add(_QuizOption(
        text: text,
        translation: translation,
        isCorrect: false,
      ));
    }

    options.shuffle();
    _shuffledOptions = options;
    _isQuizActive = true;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final panelHeight = screenHeight * 0.88;
    final keywords = _deepContextKeywords;

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: panelHeight,
          width: double.infinity,
          margin: EdgeInsets.only(top: KivoScale.h(24)),
          decoration: BoxDecoration(
            color: KivoColors.lightSurface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(KivoScale.r(28)),
            ),
            boxShadow: KivoShadows.raised,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              KivoScale.w(22),
              KivoScale.h(14),
              KivoScale.w(22),
              KivoScale.h(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: KivoScale.w(46).clamp(40, 54)),
                    const _SheetHandle(),
                    _DeepContextCloseButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: KivoScale.h(18)),
                _DeepContextHeader(
                  rootNode: widget.rootNode,
                  contextNode: widget.contextNode,
                ),
                SizedBox(height: KivoScale.h(22)),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DeepContextLearningStack(
                        rootNode: widget.rootNode,
                        contextNode: widget.contextNode,
                      ),
                      SizedBox(height: KivoScale.h(18)),
                    ],
                  ),
                  crossFadeState: (!_isQuizActive || _selectedAnswerIndex != null)
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                if (!_isQuizActive) ...[
                  for (var i = 0; i < widget.contextNode.dialogue.length; i += 1)
                    DeepDialogueBubble(
                      line: widget.contextNode.dialogue[i],
                      alignRight: i.isOdd,
                      keywords: keywords,
                    ),
                ] else ...[
                  DeepDialogueBubble(
                    line: widget.contextNode.dialogue[0],
                    alignRight: false,
                    keywords: keywords,
                  ),
                  _QuizBlock(
                    options: _shuffledOptions,
                    selectedAnswerIndex: _selectedAnswerIndex,
                    onSelect: (index) {
                      setState(() {
                        _selectedAnswerIndex = index;
                      });
                      TtsService.instance.speak(
                        _shuffledOptions[index].text,
                        pitch: 0.82,
                      );
                    },
                    speaker: widget.contextNode.dialogue[1].speaker,
                  ),
                ],
                if (widget.contextNode.dialogue.isEmpty)
                  DeepDialogueBubble(
                    line: DiscoveryDialogueLine(
                      speaker: widget.contextNode.title,
                      text: widget.contextNode.sentence,
                      translation: widget.contextNode.sentenceVi,
                    ),
                    alignRight: false,
                    keywords: keywords,
                  ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: EdgeInsets.only(top: KivoScale.h(6)),
                    child: PracticalTipCard(
                      tip: widget.contextNode.tip,
                      tipEn: widget.contextNode.tipEn,
                      keywords: keywords,
                    ),
                  ),
                  crossFadeState: (!_isQuizActive || _selectedAnswerIndex != null)
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                SizedBox(height: KivoScale.h(18)),
                _UnderstoodButton(
                  label: widget.actionLabel ??
                      '\u0110\u00e3 hi\u1ec3u li\u00ean k\u1ebft n\u00e0y \u{1F44D}',
                  onPressed: (_isQuizActive && _selectedAnswerIndex == null)
                      ? null
                      : widget.onUnderstood,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> get _deepContextKeywords {
    return {
      widget.rootNode.label,
      widget.rootNode.translation,
      widget.contextNode.title,
      widget.contextNode.translation,
      for (final chunk in widget.contextNode.englishChunks)
        if (chunk.tone == DiscoveryChipTone.target ||
            chunk.tone == DiscoveryChipTone.action)
          chunk.text.trim(),
      for (final chunk in widget.contextNode.vietnameseChunks)
        if (chunk.tone == DiscoveryChipTone.target ||
            chunk.tone == DiscoveryChipTone.action)
          chunk.text.trim(),
    }.where((keyword) => keyword.isNotEmpty).toList(growable: false);
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: KivoScale.w(46).clamp(38, 56),
      height: KivoScale.h(5).clamp(4, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD8C8B7),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _DeepContextHeader extends StatelessWidget {
  const _DeepContextHeader({required this.rootNode, required this.contextNode});

  final DiscoveryRootNode rootNode;
  final DiscoveryContextNode contextNode;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: KivoScale.w(96).clamp(78, 118),
          height: KivoScale.w(96).clamp(78, 118),
          decoration: BoxDecoration(
            color: KivoColors.softOrangeCard,
            borderRadius: BorderRadius.circular(KivoScale.r(22)),
            border: Border.all(color: KivoColors.keywordOrange.withAlpha(140)),
            boxShadow: KivoShadows.soft,
          ),
          child: Icon(
            KivoIconRegistry.vocabulary(
              contextNode.iconKey,
              tone: KivoIconTone.duotone,
            ),
            color: KivoColors.actionOrange,
            size: KivoScale.w(52).clamp(42, 64),
          ),
        ),
        SizedBox(width: KivoScale.w(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: KivoTextStyles.body.copyWith(
                    color: KivoColors.coffeeText,
                    fontSize: KivoScale.sp(14.5, min: 12),
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    const TextSpan(
                      text: 'T\u1eeb kh\u00f3a c\u1ed1t l\u00f5i: ',
                    ),
                    TextSpan(
                      text: rootNode.label,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              SizedBox(height: KivoScale.h(8)),
              Text(
                contextNode.translation.isEmpty
                    ? contextNode.title
                    : '${contextNode.title} (${contextNode.translation})',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: KivoTextStyles.display.copyWith(
                  color: KivoColors.coffeeText,
                  fontSize: KivoScale.sp(27, min: 20),
                  height: 1.08,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeepContextCloseButton extends StatelessWidget {
  const _DeepContextCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: KivoScale.w(46).clamp(40, 54),
        height: KivoScale.w(46).clamp(40, 54),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(242),
          borderRadius: BorderRadius.circular(KivoScale.r(16)),
          border: Border.all(color: KivoColors.lightBorder),
          boxShadow: KivoShadows.soft,
        ),
        child: Icon(
          KivoIconRegistry.system('close', tone: KivoIconTone.bold),
          color: KivoColors.coffeeText,
          size: KivoScale.w(26).clamp(22, 32),
        ),
      ),
    );
  }
}

class _DeepContextLearningStack extends StatelessWidget {
  const _DeepContextLearningStack({
    required this.rootNode,
    required this.contextNode,
  });

  final DiscoveryRootNode rootNode;
  final DiscoveryContextNode contextNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EnglishContextBlock(
          chunks: contextNode.englishChunks,
          sentence: contextNode.sentence,
        ),
        SizedBox(height: KivoScale.h(12)),
        _MiniVocabCardRow(rootNode: rootNode, contextNode: contextNode),
        SizedBox(height: KivoScale.h(12)),
        _VietnameseContextBlock(text: contextNode.sentenceVi),
      ],
    );
  }
}

class _EnglishContextBlock extends StatefulWidget {
  const _EnglishContextBlock({
    required this.chunks,
    required this.sentence,
  });

  final List<DiscoverySentenceChunk> chunks;
  final String sentence;

  @override
  State<_EnglishContextBlock> createState() => _EnglishContextBlockState();
}

class _EnglishContextBlockState extends State<_EnglishContextBlock> {
  bool _speaking = false;

  Future<void> _onSpeak() async {
    if (_speaking) {
      await TtsService.instance.stop();
      setState(() => _speaking = false);
      return;
    }
    setState(() => _speaking = true);
    await TtsService.instance.speak(widget.sentence);
    if (mounted) setState(() => _speaking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            KivoScale.w(16),
            KivoScale.h(16),
            KivoScale.w(52),
            KivoScale.h(16),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(238),
            borderRadius: BorderRadius.circular(KivoScale.r(18)),
            border: Border.all(color: const Color(0xFFE4D7C9)),
            boxShadow: KivoShadows.soft,
          ),
          child: _ContextChunkRichText(
            chunks: widget.chunks,
            fontSize: KivoScale.sp(16, min: 13),
          ),
        ),
        Positioned(
          top: KivoScale.h(8),
          right: KivoScale.w(8),
          child: GestureDetector(
            onTap: _onSpeak,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: KivoScale.w(38).clamp(34, 44),
              height: KivoScale.w(38).clamp(34, 44),
              decoration: BoxDecoration(
                color: _speaking
                    ? KivoColors.targetPurple.withAlpha(30)
                    : const Color(0xFFF3EDE6),
                borderRadius: BorderRadius.circular(KivoScale.r(12)),
                border: Border.all(
                  color: _speaking
                      ? KivoColors.targetPurple.withAlpha(120)
                      : const Color(0xFFE4D7C9),
                ),
              ),
              child: Icon(
                _speaking
                    ? KivoIconRegistry.system('close', tone: KivoIconTone.bold)
                    : KivoIconRegistry.system('audio', tone: KivoIconTone.bold),
                color: _speaking
                    ? KivoColors.targetPurple
                    : KivoColors.secondaryText,
                size: KivoScale.w(20).clamp(18, 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContextChunkRichText extends StatelessWidget {
  const _ContextChunkRichText({required this.chunks, required this.fontSize});

  final List<DiscoverySentenceChunk> chunks;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final baseStyle = KivoTextStyles.body.copyWith(
      color: KivoColors.inkText,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.48,
    );

    return RichText(
      text: TextSpan(
        children: [
          for (final chunk in chunks)
            if (chunk.tone != DiscoveryChipTone.language)
              TextSpan(
                text: chunk.text,
                style: baseStyle.copyWith(
                  color: switch (chunk.tone) {
                    DiscoveryChipTone.target => KivoColors.targetPurple,
                    DiscoveryChipTone.action => const Color(0xFFB05200),
                    _ => KivoColors.inkText,
                  },
                  fontWeight: chunk.tone == DiscoveryChipTone.context
                      ? FontWeight.w600
                      : FontWeight.w900,
                ),
              ),
        ],
      ),
    );
  }
}

class _MiniVocabCardRow extends StatelessWidget {
  const _MiniVocabCardRow({required this.rootNode, required this.contextNode});

  final DiscoveryRootNode rootNode;
  final DiscoveryContextNode contextNode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = ((constraints.maxWidth - KivoScale.w(10)) / 2)
            .clamp(128.0, 220.0)
            .toDouble();

        return Wrap(
          spacing: KivoScale.w(10),
          runSpacing: KivoScale.h(10),
          alignment: WrapAlignment.center,
          children: [
            _MiniVocabCard(
              width: cardWidth,
              label: rootNode.label,
              meaning: rootNode.translation,
              tone: DiscoveryChipTone.target,
            ),
            _MiniVocabCard(
              width: cardWidth,
              label: contextNode.title,
              meaning: contextNode.translation,
              tone: DiscoveryChipTone.action,
            ),
          ],
        );
      },
    );
  }
}

class _MiniVocabCard extends StatelessWidget {
  const _MiniVocabCard({
    required this.width,
    required this.label,
    required this.meaning,
    required this.tone,
  });

  final double width;
  final String label;
  final String meaning;
  final DiscoveryChipTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = DiscoveryChipPalette.fromTone(tone);

    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: KivoScale.w(12),
        vertical: KivoScale.h(10),
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(KivoScale.r(12)),
        border: Border.all(color: palette.border.withAlpha(210)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withAlpha(36),
            blurRadius: KivoScale.r(10),
            offset: Offset(0, KivoScale.h(4)),
          ),
        ],
      ),
      child: Text(
        meaning.isEmpty ? label : '$label = $meaning',
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: KivoTextStyles.body.copyWith(
          color: palette.text,
          fontSize: KivoScale.sp(13.5, min: 11),
          fontWeight: FontWeight.w900,
          height: 1.2,
        ),
      ),
    );
  }
}

class _VietnameseContextBlock extends StatelessWidget {
  const _VietnameseContextBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: KivoTextStyles.body.copyWith(
        color: KivoColors.secondaryText,
        fontSize: KivoScale.sp(14.5, min: 12),
        fontWeight: FontWeight.w600,
        height: 1.42,
      ),
    );
  }
}

class _QuizOption {
  final String text;
  final String translation;
  final bool isCorrect;

  _QuizOption({
    required this.text,
    required this.translation,
    required this.isCorrect,
  });
}

class _QuizOptionWidget extends StatelessWidget {
  const _QuizOptionWidget({
    required this.option,
    required this.isAnswered,
    required this.isSelected,
    required this.onTap,
  });

  final _QuizOption option;
  final bool isAnswered;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color surfaceColor = Colors.white;
    Color borderColor = const Color(0xFFE4D7C9);
    Color textColor = KivoColors.coffeeText;
    double opacity = 1.0;

    if (isAnswered) {
      if (option.isCorrect) {
        surfaceColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF81C784);
        textColor = const Color(0xFF2E7D32);
      } else if (isSelected) {
        surfaceColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFE57373);
        textColor = const Color(0xFFC62828);
      } else {
        surfaceColor = const Color(0xFFF9F7F4);
        borderColor = const Color(0xFFEBE3DB);
        textColor = KivoColors.secondaryText.withAlpha(153);
        opacity = 0.7;
      }
    } else {
      if (isSelected) {
        surfaceColor = KivoColors.targetPurple.withAlpha(20);
        borderColor = KivoColors.targetPurple;
      }
    }

    return GestureDetector(
      onTap: isAnswered ? null : onTap,
      child: Opacity(
        opacity: opacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          margin: EdgeInsets.only(bottom: KivoScale.h(10)),
          padding: EdgeInsets.symmetric(
            horizontal: KivoScale.w(16),
            vertical: KivoScale.h(14),
          ),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(KivoScale.r(14)),
            border: Border.all(
              color: borderColor,
              width: isSelected || (isAnswered && option.isCorrect) ? 1.8 : 1.2,
            ),
            boxShadow: isAnswered ? null : KivoShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      option.text,
                      style: KivoTextStyles.body.copyWith(
                        color: textColor,
                        fontSize: KivoScale.sp(15, min: 12),
                        fontWeight: option.isCorrect && isAnswered
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isAnswered) ...[
                    SizedBox(width: KivoScale.w(8)),
                    if (option.isCorrect)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF2E7D32),
                        size: 20,
                      )
                    else if (isSelected)
                      const Icon(
                        Icons.cancel_rounded,
                        color: Color(0xFFC62828),
                        size: 20,
                      ),
                  ],
                ],
              ),
              if (isAnswered && option.translation.isNotEmpty) ...[
                SizedBox(height: KivoScale.h(6)),
                Text(
                  option.translation,
                  style: KivoTextStyles.body.copyWith(
                    color: option.isCorrect
                        ? const Color(0xFF4CAF50).withAlpha(216)
                        : (isSelected
                            ? const Color(0xFFD32F2F).withAlpha(204)
                            : KivoColors.secondaryText.withAlpha(127)),
                    fontSize: KivoScale.sp(13, min: 10.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizBlock extends StatelessWidget {
  const _QuizBlock({
    required this.options,
    required this.selectedAnswerIndex,
    required this.onSelect,
    required this.speaker,
  });

  final List<_QuizOption> options;
  final int? selectedAnswerIndex;
  final ValueChanged<int> onSelect;
  final String speaker;

  @override
  Widget build(BuildContext context) {
    final isAnswered = selectedAnswerIndex != null;

    return Container(
      margin: EdgeInsets.only(bottom: KivoScale.h(16)),
      padding: EdgeInsets.all(KivoScale.w(18)),
      decoration: BoxDecoration(
        color: const Color(0xFFF3ECE4).withAlpha(127),
        borderRadius: BorderRadius.circular(KivoScale.r(22)),
        border: Border.all(color: const Color(0xFFE6D9CB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: KivoScale.w(8),
                  vertical: KivoScale.h(3),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0C4A8),
                  borderRadius: BorderRadius.circular(KivoScale.r(8)),
                ),
                child: Text(
                  speaker,
                  style: KivoTextStyles.caption.copyWith(
                    color: KivoColors.coffeeText,
                    fontWeight: FontWeight.w800,
                    fontSize: KivoScale.sp(11.5, min: 9.5),
                  ),
                ),
              ),
              SizedBox(width: KivoScale.w(8)),
              Text(
                'tr\u1ea3 l\u1eddi th\u1ebf n\u00e0o cho t\u1ef1 nhi\u00ean? \ud83e\udd14',
                style: KivoTextStyles.body.copyWith(
                  color: KivoColors.secondaryText,
                  fontWeight: FontWeight.w700,
                  fontSize: KivoScale.sp(13.5, min: 11),
                ),
              ),
            ],
          ),
          SizedBox(height: KivoScale.h(14)),
          ...List.generate(options.length, (index) {
            final option = options[index];
            return _QuizOptionWidget(
              option: option,
              isAnswered: isAnswered,
              isSelected: selectedAnswerIndex == index,
              onTap: () => onSelect(index),
            );
          }),
        ],
      ),
    );
  }
}

class _UnderstoodButton extends StatelessWidget {
  const _UnderstoodButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.45,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: KivoScale.h(14)),
          decoration: BoxDecoration(
            gradient: isEnabled ? KivoGradients.orangeButton : null,
            color: isEnabled ? null : KivoColors.disabledText.withAlpha(76),
            borderRadius: BorderRadius.circular(KivoScale.r(25)),
            border: Border.all(
              color: isEnabled ? const Color(0xFFFFB14D) : KivoColors.lightBorder,
              width: 1.5,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFFD95300).withAlpha(190),
                      blurRadius: 0,
                      offset: Offset(0, KivoScale.h(7)),
                    ),
                    ...KivoShadows.orangeGlow,
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: KivoTextStyles.cta.copyWith(
              fontSize: KivoScale.sp(26, min: 20),
              color: isEnabled ? Colors.white : KivoColors.disabledText,
              shadows: isEnabled
                  ? const [
                      Shadow(color: Color(0x663A1608), offset: Offset(0, 2)),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
