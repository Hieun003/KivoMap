import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../view_model/secret_passage_story_view_state.dart';

part 'secret_passage_story_effects.dart';
part 'secret_passage_story_image_stack.dart';
part 'secret_passage_story_layout.dart';
part 'secret_passage_story_text_panel.dart';

class SecretPassageStoryView extends StatefulWidget {
  const SecretPassageStoryView({
    super.key,
    required this.scale,
    required this.startTypewriter,
  });

  final double scale;
  final bool startTypewriter;

  @override
  State<SecretPassageStoryView> createState() => _SecretPassageStoryViewState();
}

class _SecretPassageStoryViewState extends State<SecretPassageStoryView>
    with TickerProviderStateMixin {
  int _currentStoryIndex = 0;
  final GlobalKey<_StoryTextPanelState> _textPanelKey =
      GlobalKey<_StoryTextPanelState>();

  late final AnimationController _pageController;
  late final AnimationController _pulseController;
  late final AnimationController _shakeController;
  late final AnimationController _revealController;
  late final AnimationController _btnPulseController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _shakeAnimationX;
  late final Animation<double> _shakeAnimationY;
  late final Animation<double> _revealAnimation;
  late final Animation<double> _btnPulseAnimation;

  bool _typingActive = false;

  @override
  void initState() {
    super.initState();
    _typingActive = widget.startTypewriter;

    // Zoom transitions
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Stone pillars glow transitions
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Earth shake transition (t = 300ms)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Linear reveal sweep transition (t = 800ms)
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Challenge button pulse breathing
    _btnPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
    ]).animate(_pageController);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 40,
      ),
    ]).animate(_pageController);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 0.28).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Vibration translation arrays
    _shakeAnimationX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 4.5), weight: 10),
      TweenSequenceItem(
        tween: Tween<double>(begin: 4.5, end: -4.5),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -4.5, end: 3.5),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 3.5, end: -3.5),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -3.5, end: 2.0),
        weight: 20,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 2.0, end: 0.0), weight: 10),
    ]).animate(_shakeController);

    _shakeAnimationY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -3.5),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -3.5, end: 4.5),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 4.5, end: -2.5),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -2.5, end: 3.5),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 3.5, end: -1.0),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -1.0, end: 0.0),
        weight: 10,
      ),
    ]).animate(_shakeController);

    // Linear reveal stops sweep mapping
    _revealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeInOut),
    );

    _btnPulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _btnPulseController, curve: Curves.easeInOut),
    );

    _pageController.addListener(_onPageTransitionProgress);
  }

  @override
  void didUpdateWidget(covariant SecretPassageStoryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startTypewriter && !oldWidget.startTypewriter) {
      setState(() {
        _typingActive = true;
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageTransitionProgress);
    _pageController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _revealController.dispose();
    _btnPulseController.dispose();
    super.dispose();
  }

  void _onPageTransitionProgress() {
    if (_pageController.value >= 0.6 && _currentStoryIndex == 0) {
      setState(() {
        _currentStoryIndex = 1;
      });
    }
  }

  Future<void> _nextStoryPage() async {
    if (_pageController.isAnimating ||
        _pulseController.isAnimating ||
        _revealController.isAnimating ||
        _shakeController.isAnimating) {
      return;
    }

    // RPG Dialog Skip check: If typing is active and not fully finished, skip it
    final textPanel = _textPanelKey.currentState;
    if (textPanel != null && textPanel.isAnimating) {
      textPanel.skipTypewriter();
      return;
    }

    if (_currentStoryIndex == 0) {
      setState(() {
        _typingActive = false;
      });

      await _pageController.forward(from: 0);

      setState(() {
        _typingActive = true;
      });

      // Run stone pulse asynchronously to prevent button blocking
      _pulseController.forward(from: 0).then((_) {
        _pulseController.reverse().then((_) {
          _pulseController.forward().then((_) {
            _pulseController.reverse();
          });
        });
      });
    } else if (_currentStoryIndex == 1) {
      setState(() {
        _typingActive = false;
      });

      // Trigger shake overlay in parallel
      _shakeController.forward(from: 0);

      // Sweep the lightning shader mask
      await _revealController.forward(from: 0);

      // Only switch page index to 3 (ThĂ„â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă‚Â¢Ä‚Â¢Ă¢â‚¬ÂĂ‚Â¬Ä‚â€Ă‚ÂÄ‚â€Ă¢â‚¬ÂÄ‚â€Ă‚Â¢Ă„â€Ă‚Â¢Ä‚Â¢Ă¢â€Â¬Ă‚ÂÄ‚â€Ă‚Â¬Ă„â€Ă¢â‚¬ÂÄ‚â€Ă‚ÂĂ„â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă‚Â¢Ä‚Â¢Ă¢â‚¬ÂĂ‚Â¬Ä‚â€Ă‚ÂÄ‚â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă¢â‚¬ÂÄ‚â€Ă‚Â¡Ä‚â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă‚Â¢Ä‚Â¢Ă¢â‚¬ÂĂ‚Â¬Ä‚â€Ă‚ÂÄ‚â€Ă¢â‚¬ÂÄ‚â€Ă‚Â¢Ă„â€Ă‚Â¢Ä‚Â¢Ă¢â€Â¬Ă‚ÂÄ‚â€Ă‚Â¬Ă„â€Ă¢â‚¬ÂÄ‚â€Ă‚ÂĂ„â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă‚Â¢Ä‚Â¢Ă¢â‚¬ÂĂ‚Â¬Ä‚â€Ă‚ÂÄ‚â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă¢â‚¬ÂÄ‚â€Ă‚ÂºÄ‚â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă‚Â¢Ä‚Â¢Ă¢â‚¬ÂĂ‚Â¬Ä‚â€Ă‚ÂÄ‚â€Ă¢â‚¬ÂÄ‚â€Ă‚Â¢Ă„â€Ă‚Â¢Ä‚Â¢Ă¢â€Â¬Ă‚ÂÄ‚â€Ă‚Â¬Ă„â€Ă¢â‚¬ÂÄ‚â€Ă‚ÂĂ„â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă‚Â¢Ä‚Â¢Ă¢â‚¬ÂĂ‚Â¬Ä‚â€Ă‚ÂÄ‚â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă¢â‚¬ÂÄ‚â€Ă‚Â§n Tri ThĂ„â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă‚Â¢Ä‚Â¢Ă¢â‚¬ÂĂ‚Â¬Ä‚â€Ă‚ÂÄ‚â€Ă¢â‚¬ÂÄ‚â€Ă‚Â¢Ă„â€Ă‚Â¢Ä‚Â¢Ă¢â€Â¬Ă‚ÂÄ‚â€Ă‚Â¬Ă„â€Ă¢â‚¬ÂÄ‚â€Ă‚ÂĂ„â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă‚Â¢Ä‚Â¢Ă¢â‚¬ÂĂ‚Â¬Ä‚â€Ă‚ÂÄ‚â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă¢â‚¬ÂÄ‚â€Ă‚Â¡Ä‚â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă‚Â¢Ä‚Â¢Ă¢â‚¬ÂĂ‚Â¬Ä‚â€Ă‚ÂÄ‚â€Ă¢â‚¬ÂÄ‚â€Ă‚Â¢Ă„â€Ă‚Â¢Ä‚Â¢Ă¢â€Â¬Ă‚ÂÄ‚â€Ă‚Â¬Ă„â€Ă¢â‚¬ÂÄ‚â€Ă‚ÂĂ„â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă‚Â¢Ä‚Â¢Ă¢â‚¬ÂĂ‚Â¬Ä‚â€Ă‚ÂÄ‚â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă¢â‚¬ÂÄ‚â€Ă‚Â»Ä‚â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă‚Â¢Ä‚Â¢Ă¢â‚¬ÂĂ‚Â¬Ä‚â€Ă‚ÂÄ‚â€Ă¢â‚¬ÂÄ‚â€Ă‚Â¢Ă„â€Ă‚Â¢Ä‚Â¢Ă¢â€Â¬Ă‚ÂÄ‚â€Ă‚Â¬Ă„â€Ă¢â‚¬ÂÄ‚â€Ă‚ÂĂ„â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă‚Â¢Ä‚Â¢Ă¢â‚¬ÂĂ‚Â¬Ä‚â€Ă‚ÂÄ‚â€Ă¢â‚¬ÂÄ‚Â¢Ă¢â€Â¬Ă‚ÂĂ„â€Ă¢â‚¬ÂÄ‚â€Ă‚Â©c) once reveal and shake are 100% completed
      setState(() {
        _currentStoryIndex = 2;
        _typingActive = true;
      });

      _btnPulseController.repeat(reverse: true);
    } else {
      Get.offNamed<void>(AppRoutes.passageway);
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = SecretPassageStoryContent.pages[_currentStoryIndex];
    final isTransitioning = _pageController.isAnimating;

    return Stack(
      children: [
        const Positioned.fill(child: _StoryBackdrop()),
        _PositionedSource(
          left: 694,
          top: 70,
          width: 122,
          height: 64,
          scale: widget.scale,
          child: TextButton(
            key: const ValueKey('secret-story-skip'),
            onPressed: Get.back<void>,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: KivoColors.glowMint,
              textStyle: KivoTextStyles.darkAccent.copyWith(
                fontSize: 32 * widget.scale,
                height: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('B\u1ecf qua', textScaler: TextScaler.noScaling),
          ),
        ),
        _PositionedSource(
          left: 37,
          top: 224,
          width: 778,
          height: 923,
          scale: widget.scale,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pageController, _shakeController]),
            builder: (context, child) {
              final double currentScale = isTransitioning
                  ? _scaleAnimation.value
                  : 1.0;
              final double currentOpacity = isTransitioning
                  ? _opacityAnimation.value
                  : 1.0;

              final double offsetX = _shakeController.isAnimating
                  ? _shakeAnimationX.value
                  : 0.0;
              final double offsetY = _shakeController.isAnimating
                  ? _shakeAnimationY.value
                  : 0.0;

              return Opacity(
                opacity: currentOpacity,
                child: Transform.translate(
                  offset: Offset(offsetX, offsetY),
                  child: Transform.scale(
                    scale: currentScale,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28 * widget.scale),
                        border: Border.all(
                          color: KivoColors.runeGold.withAlpha(92),
                          width: 1.35 * widget.scale,
                        ),
                      ),
                      child: _buildImageStack(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _PositionedSource(
          left: 37,
          top: 1180,
          width: 778,
          height: 343,
          scale: widget.scale,
          child: _StoryTextPanel(
            key: _textPanelKey,
            scale: widget.scale,
            text: page.text,
            startTypewriter: _typingActive,
          ),
        ),
        _PositionedSource(
          left: 37,
          top: 1580,
          width: 778,
          height: 160,
          scale: widget.scale,
          child: AnimatedBuilder(
            animation: _btnPulseController,
            builder: (context, child) {
              final double scaleValue = (_currentStoryIndex == 2)
                  ? _btnPulseAnimation.value
                  : 1.0;
              return Transform.scale(
                scale: scaleValue,
                child: FilledButton(
                  key: const ValueKey('secret-story-next'),
                  onPressed: _nextStoryPage,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: KivoColors.warmCard,
                    foregroundColor: KivoColors.coffeeText,
                    elevation: 5,
                    shadowColor: Colors.black.withAlpha(72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(29 * widget.scale),
                      side: BorderSide(
                        color: KivoColors.cream.withAlpha(210),
                        width: 1.2 * widget.scale,
                      ),
                    ),
                    textStyle: KivoTextStyles.display.copyWith(
                      fontSize: 52 * widget.scale,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  child: Text(
                    (_currentStoryIndex == 2)
                        ? 'B\u1eaft \u0111\u1ea7u th\u00e1ch th\u1ee9c'
                        : 'Ti\u1ebfp theo',
                    textScaler: TextScaler.noScaling,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
