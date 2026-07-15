part of 'secret_passage_story_view.dart';

class _StoryTextPanel extends StatefulWidget {
  const _StoryTextPanel({
    super.key,
    required this.scale,
    required this.text,
    required this.startTypewriter,
  });

  final double scale;
  final String text;
  final bool startTypewriter;

  @override
  State<_StoryTextPanel> createState() => _StoryTextPanelState();
}

class _StoryTextPanelState extends State<_StoryTextPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _typewriterController;
  late Animation<int> _characterCount;

  bool get isAnimating => _typewriterController.isAnimating;

  void skipTypewriter() {
    if (_typewriterController.isAnimating) {
      _typewriterController.value = 1.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _typewriterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _characterCount = StepTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(parent: _typewriterController, curve: Curves.linear),
    );

    if (widget.startTypewriter) {
      _typewriterController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _StoryTextPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text ||
        (widget.startTypewriter && !oldWidget.startTypewriter)) {
      _typewriterController.reset();
      _characterCount = StepTween(begin: 0, end: widget.text.length).animate(
        CurvedAnimation(parent: _typewriterController, curve: Curves.linear),
      );
      if (widget.startTypewriter) {
        _typewriterController.forward();
      }
    }
  }

  @override
  void dispose() {
    _typewriterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: KivoColors.darkPanel,
        borderRadius: BorderRadius.circular(28 * widget.scale),
        border: Border.all(
          color: KivoColors.runeGold.withAlpha(74),
          width: 1.35 * widget.scale,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(66),
            blurRadius: 26 * widget.scale,
            offset: Offset(0, 14 * widget.scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          44 * widget.scale,
          38 * widget.scale,
          44 * widget.scale,
          28 * widget.scale,
        ),
        child: Column(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _characterCount,
                builder: (context, child) {
                  final textToShow = widget.text.substring(
                    0,
                    _characterCount.value,
                  );
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 690 * widget.scale,
                      child: Text(
                        textToShow,
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.noScaling,
                        style: KivoTextStyles.darkBody.copyWith(
                          color: Colors.white,
                          fontSize: 33 * widget.scale,
                          height: 1.34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 25 * widget.scale),
            _StoryDivider(scale: widget.scale),
          ],
        ),
      ),
    );
  }
}

class _StoryDivider extends StatelessWidget {
  const _StoryDivider({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _DividerLine(scale: scale)),
        Transform.rotate(
          angle: 0.785398,
          child: Container(
            width: 19 * scale,
            height: 19 * scale,
            margin: EdgeInsets.symmetric(horizontal: 12 * scale),
            decoration: BoxDecoration(
              border: Border.all(color: KivoColors.kivoTeal, width: 3 * scale),
              shape: BoxShape.rectangle,
            ),
          ),
        ),
        Expanded(child: _DividerLine(scale: scale, reverse: true)),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine({required this.scale, this.reverse = false});

  final double scale;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final children = [
      Container(
        width: 7 * scale,
        height: 7 * scale,
        decoration: const BoxDecoration(
          color: KivoColors.kivoTeal,
          shape: BoxShape.circle,
        ),
      ),
      Expanded(
        child: Container(height: 2 * scale, color: KivoColors.kivoTeal),
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: reverse ? children.reversed.toList() : children,
    );
  }
}
