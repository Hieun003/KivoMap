import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/assets/image_paths.dart';
import '../../../app/theme/kivo_theme_tokens.dart';
import '../data/passageway_story_catalog.dart';
import '../model/passageway_story_stage.dart';
import '../view_model/passageway_story_controller.dart';
import 'passageway_cave_list_view.dart';

class PassagewayStoryView extends StatefulWidget {
  const PassagewayStoryView({
    super.key,
    required this.stageNumber,
    required this.stageName,
  });

  // The scene keeps the original visual proportions, but can grow vertically
  // when a stage contains longer dialogue or answers.
  static const double sourceWidth = 852;
  static const double sourceHeight = 1540;
  static const double sourceAspectRatio = sourceHeight / sourceWidth;

  final int stageNumber;
  final String stageName;

  @override
  State<PassagewayStoryView> createState() => _PassagewayStoryViewState();
}

class _PassagewayStoryViewState extends State<PassagewayStoryView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late PassagewayStoryController _storyController;
  int _currentStageIndex = 0;
  late int _currentStageNumber;
  late String _currentStageName;
  Timer? _autoProceedTimer;
  int _secondsRemaining = 5;

  @override
  void initState() {
    super.initState();
    _currentStageNumber = widget.stageNumber;
    _currentStageName = widget.stageName;
    _storyController = PassagewayStoryController(
      stage: PassagewayStoryCatalog.resolve(
        stageNumber: _currentStageNumber,
        stageName: _currentStageName,
        stageIndex: _currentStageIndex,
      ),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _autoProceedTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _saveProgress(int completedStageNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUnlocked = prefs.getInt('kivo.passageway.unlocked_index') ?? 1;
      if (completedStageNumber >= currentUnlocked) {
        await prefs.setInt('kivo.passageway.unlocked_index', completedStageNumber + 1);
      }
    } catch (e) {
      Get.log('Error saving passageway progress: $e');
    }
  }

  Future<void> _saveProgressAndGoBack() async {
    _autoProceedTimer?.cancel();
    await _saveProgress(_currentStageNumber);
    Get.back(); // Close screen
  }

  void _startAutoProceedTimer() {
    _autoProceedTimer?.cancel();
    setState(() {
      _secondsRemaining = 5;
    });

    final stageNames = PassagewayCaveListView.stageNames;
    final hasNextCombo = _currentStageNumber < stageNames.length;
    if (!hasNextCombo) {
      return;
    }

    _autoProceedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          timer.cancel();
          _proceedToNextCombo();
        }
      });
    });
  }

  Future<void> _proceedToNextCombo() async {
    _autoProceedTimer?.cancel();
    await _saveProgress(_currentStageNumber);

    final nextStageNumber = _currentStageNumber + 1;
    final stageNames = PassagewayCaveListView.stageNames;

    if (nextStageNumber <= stageNames.length) {
      setState(() {
        _currentStageNumber = nextStageNumber;
        _currentStageName = stageNames[nextStageNumber - 1];
        _currentStageIndex = 0;
        _storyController = PassagewayStoryController(
          stage: PassagewayStoryCatalog.resolve(
            stageNumber: _currentStageNumber,
            stageName: _currentStageName,
            stageIndex: _currentStageIndex,
          ),
        );
      });
    } else {
      Get.back();
    }
  }

  void _onOptionSelected(PassagewayChoice choice) {
    final selectedChoice = _storyController.selectChoice(choice.id);
    if (selectedChoice == null) {
      return;
    }
    setState(() {});

    if (selectedChoice.isCorrect) {
      final nextStageIndex = _currentStageIndex + 1;
      final hasNextStage = PassagewayStoryCatalog.hasStage(
        stageNumber: _currentStageNumber,
        stageName: _currentStageName,
        stageIndex: nextStageIndex,
      );

      if (hasNextStage) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _currentStageIndex = nextStageIndex;
              _storyController = PassagewayStoryController(
                stage: PassagewayStoryCatalog.resolve(
                  stageNumber: _currentStageNumber,
                  stageName: _currentStageName,
                  stageIndex: _currentStageIndex,
                ),
              );
            });
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _storyController.revealSuccess();
            });
            _startAutoProceedTimer();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF021C20),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sceneWidth = constraints.maxWidth.clamp(
              0.0,
              PassagewayStoryView.sourceWidth,
            );
            final sceneHeight =
                sceneWidth * PassagewayStoryView.sourceAspectRatio;
            final scale = sceneWidth / PassagewayStoryView.sourceWidth;

            return Stack(
              children: [
                const Positioned.fill(child: _Backdrop()),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: sceneHeight),
                      child: SizedBox(
                        width: sceneWidth,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 80 * scale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 42 * scale),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 36 * scale,
                                ),
                                child: _buildTopBar(scale),
                              ),
                              SizedBox(height: 44 * scale),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 37 * scale,
                                ),
                                child: _buildDialoguePanel(scale),
                              ),
                              SizedBox(height: 16 * scale),
                              _buildMascotSection(scale),
                              Transform.translate(
                                offset: Offset(0, -110 * scale),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 37 * scale,
                                  ),
                                  child: _buildAnswerChoices(scale),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_storyController.state.showSuccess)
                  Positioned.fill(child: _buildSuccessOverlay(scale)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(double scale) {
    return SizedBox(
      height: 44 * scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back Button (Simple gold arrow)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: Get.back,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: const Color(0xFFFCDD8F),
                size: 44 * scale,
              ),
            ),
          ),

          // Centered Progress Dots Stack
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dot 1
              Container(
                width: 22 * scale,
                height: 22 * scale,
                decoration: BoxDecoration(
                  color: _currentStageIndex >= 0 ? KivoColors.glowMint : null,
                  shape: BoxShape.circle,
                  border: _currentStageIndex < 0
                      ? Border.all(color: KivoColors.glowMint.withAlpha(120), width: 2.5 * scale)
                      : null,
                  boxShadow: _currentStageIndex == 0
                      ? [
                          BoxShadow(
                            color: KivoColors.glowMint.withAlpha(200),
                            blurRadius: 12 * scale,
                            spreadRadius: 2 * scale,
                          ),
                        ]
                      : null,
                ),
              ),

              // Line 1
              Container(
                width: 60 * scale,
                height: 2.5 * scale,
                color: KivoColors.glowMint.withAlpha(_currentStageIndex >= 1 ? 180 : 120),
              ),

              // Dot 2
              Container(
                width: 22 * scale,
                height: 22 * scale,
                decoration: BoxDecoration(
                  color: _currentStageIndex >= 1 ? KivoColors.glowMint : null,
                  shape: BoxShape.circle,
                  border: _currentStageIndex < 1
                      ? Border.all(color: KivoColors.glowMint.withAlpha(120), width: 2.5 * scale)
                      : null,
                  boxShadow: _currentStageIndex == 1
                      ? [
                          BoxShadow(
                            color: KivoColors.glowMint.withAlpha(200),
                            blurRadius: 12 * scale,
                            spreadRadius: 2 * scale,
                          ),
                        ]
                      : null,
                ),
              ),

              // Line 2
              Container(
                width: 60 * scale,
                height: 2.5 * scale,
                color: KivoColors.glowMint.withAlpha(_currentStageIndex >= 2 ? 180 : 60),
              ),

              // Dot 3
              Container(
                width: 22 * scale,
                height: 22 * scale,
                decoration: BoxDecoration(
                  color: _currentStageIndex >= 2 ? KivoColors.glowMint : null,
                  shape: BoxShape.circle,
                  border: _currentStageIndex < 2
                      ? Border.all(color: KivoColors.glowMint.withAlpha(60), width: 2.5 * scale)
                      : null,
                  boxShadow: _currentStageIndex == 2
                      ? [
                          BoxShadow(
                            color: KivoColors.glowMint.withAlpha(200),
                            blurRadius: 12 * scale,
                            spreadRadius: 2 * scale,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialoguePanel(double scale) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Outer border container
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 420 * scale),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xEC03161A),
              borderRadius: BorderRadius.circular(28 * scale),
              border: Border.all(
                color: KivoColors.glowMint.withAlpha(160),
                width: 1.5 * scale,
              ),
            ),
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                // Inner content container
                Container(
                  padding: EdgeInsets.only(
                    left: 36 * scale,
                    right: 36 * scale,
                    top: 48 * scale,
                    bottom: 32 * scale,
                  ),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Kivo Speech
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${_storyController.stage.guideName}: ',
                              style: KivoTextStyles.darkAccent.copyWith(
                                fontSize: 24 * scale,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: _storyController.stage.introLead,
                              style: KivoTextStyles.darkBody.copyWith(
                                fontSize: 24 * scale,
                                color: KivoColors.cream,
                              ),
                            ),
                            TextSpan(
                              text: _storyController.stage.introHighlight,
                              style: KivoTextStyles.darkAccent.copyWith(
                                fontSize: 24 * scale,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: _storyController.stage.introTail,
                              style: KivoTextStyles.darkBody.copyWith(
                                fontSize: 24 * scale,
                                color: KivoColors.cream,
                              ),
                            ),
                          ],
                        ),
                        textScaler: _textScaler(context),
                      ),

                      SizedBox(height: 20 * scale),

                      // Premium Custom Divider 1
                      _DialogueDivider(scale: scale),

                      SizedBox(height: 20 * scale),

                      // 2. Guard Dialogue Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // The asset name is historical; it contains the guard portrait.
                          SizedBox(
                            width: 76 * scale,
                            height: 76 * scale,
                            child: Image.asset(
                              KivoImagePaths.magicSpark3,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          SizedBox(width: 24 * scale),

                          // Guard Speech Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _storyController.stage.guardName,
                                  style: KivoTextStyles.darkBody.copyWith(
                                    fontSize: 18 * scale,
                                    color: KivoColors.cream.withAlpha(160),
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textScaler: _textScaler(context),
                                ),
                                SizedBox(height: 4 * scale),
                                Text(
                                  _storyController.stage.guardDialogue,
                                  style: KivoTextStyles.darkBody.copyWith(
                                    fontSize: 24 * scale,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textScaler: _textScaler(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20 * scale),

                      // Premium Custom Divider 2
                      _DialogueDivider(scale: scale),

                      SizedBox(height: 20 * scale),

                      // 3. Question Prompt Row
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.spiral(PhosphorIconsStyle.duotone),
                            color: KivoColors.glowMint,
                            size: 32 * scale,
                          ),
                          SizedBox(width: 16 * scale),
                          Expanded(
                            child: Text(
                              _storyController.stage.prompt,
                              style: KivoTextStyles.darkAccent.copyWith(
                                fontSize: 22 * scale,
                                color: KivoColors.cream,
                                fontWeight: FontWeight.w900,
                              ),
                              softWrap: true,
                              textScaler: _textScaler(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Subtle Corner Ornaments
                Positioned(
                  left: 6 * scale,
                  top: 6 * scale,
                  child: _CornerOrnament(scale: scale),
                ),
                Positioned(
                  right: 6 * scale,
                  top: 6 * scale,
                  child: _CornerOrnament(scale: scale),
                ),
                Positioned(
                  left: 6 * scale,
                  bottom: 6 * scale,
                  child: _CornerOrnament(scale: scale),
                ),
                Positioned(
                  right: 6 * scale,
                  bottom: 6 * scale,
                  child: _CornerOrnament(scale: scale),
                ),
              ],
            ),
          ),
        ),

        // Top Emblem Badge Swirl
        Positioned(
          top: -13 * scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Wing lines
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32 * scale,
                    height: 1.5 * scale,
                    color: KivoColors.glowMint.withAlpha(120),
                  ),
                  SizedBox(width: 64 * scale),
                  Container(
                    width: 32 * scale,
                    height: 1.5 * scale,
                    color: KivoColors.glowMint.withAlpha(120),
                  ),
                ],
              ),

              // Inner Swirl Icon
              Icon(
                PhosphorIcons.spinnerGap(PhosphorIconsStyle.bold),
                color: KivoColors.glowMint,
                size: 26 * scale,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMascotSection(double scale) {
    final selectedChoice = _storyController.selectedChoice;
    final mascotImagePath = selectedChoice == null
        ? KivoImagePaths.kivoStoryTeller
        : selectedChoice.isCorrect
        ? KivoImagePaths.kivoAnswerCorrect
        : KivoImagePaths.kivoAnswerWrong;

    return Center(
      child: SizedBox(
        width: 720 * scale,
        height: 640 * scale,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Glowing background aura behind Mascot
            Positioned(
              top: 70 * scale,
              child: Container(
                width: 470 * scale,
                height: 470 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      KivoColors.glowMint.withAlpha(80),
                      KivoColors.kivoTeal.withAlpha(30),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // 2. Magical Rune Base Pedestal (Drawn on floor)
            Positioned(
              bottom: 0,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(560 * scale, 140 * scale),
                    painter: _MagicRunePainter(
                      scale: scale,
                      pulse: _pulseController.value,
                    ),
                  );
                },
              ),
            ),

            // 3. Mascot Kivo Image
            Positioned(
              top: 20 * scale,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.84,
                  child: Image.asset(
                    mascotImagePath,
                    width: 720 * scale,
                    height: 720 * scale,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),

            // 4. Sparkle Dots
            _SparkDot(left: 70, top: 70, size: 6, scale: scale),
            _SparkDot(left: 590, top: 150, size: 5, scale: scale),
            _SparkDot(left: 35, top: 330, size: 5, scale: scale),
            _SparkDot(left: 625, top: 390, size: 6, scale: scale),
            _SparkDot(left: 130, top: 540, size: 4, scale: scale),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerChoices(double scale) {
    final choices = _storyController.stage.choices;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(choices.length, (index) {
        final choice = choices[index];
        final state = _storyController.state;

        return _AnswerChoiceCard(
          label: choice.label,
          text: choice.text,
          isCorrect: choice.isCorrect,
          isSelected: state.selectedChoiceId == choice.id,
          hasAnswered: state.hasAnswered,
          scaleFactor: scale,
          onTap: () => _onOptionSelected(choice),
        );
      }),
    );
  }

  Widget _buildSuccessOverlay(double scale) {
    return Container(
      color: Colors.black.withAlpha(209),
      alignment: Alignment.center,
      child: Container(
        width: 680 * scale,
        padding: EdgeInsets.all(42 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFF041B1F),
          borderRadius: BorderRadius.circular(32 * scale),
          border: Border.all(color: KivoColors.glowMint, width: 1.8 * scale),
          boxShadow: [
            BoxShadow(
              color: KivoColors.glowMint.withAlpha(80),
              blurRadius: 40 * scale,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy / Achievement Icon
            Container(
              width: 130 * scale,
              height: 130 * scale,
              decoration: const BoxDecoration(
                color: Color(0x1A2CE7D2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                color: KivoColors.glowMint,
                size: 72 * scale,
              ),
            ),
            SizedBox(height: 28 * scale),

            // Title
            Text(
              _storyController.stage.successTitle,
              textAlign: TextAlign.center,
              style: KivoTextStyles.darkAccent.copyWith(
                fontSize: 34 * scale,
                fontWeight: FontWeight.w900,
              ),
              textScaler: _textScaler(context),
            ),
            SizedBox(height: 18 * scale),

            // Description
            Text(
              _storyController.stage.successDescription,
              textAlign: TextAlign.center,
              style: KivoTextStyles.darkBody.copyWith(
                fontSize: 20 * scale,
                color: KivoColors.cream.withAlpha(200),
                fontWeight: FontWeight.w600,
              ),
              textScaler: _textScaler(context),
            ),
            SizedBox(height: 36 * scale),

            // Action Buttons
            Builder(
              builder: (context) {
                final stageNames = PassagewayCaveListView.stageNames;
                final hasNextCombo = _currentStageNumber < stageNames.length;

                if (hasNextCombo) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Proceed to next combo button (with countdown)
                      SizedBox(
                        width: double.infinity,
                        height: 90 * scale,
                        child: FilledButton(
                          onPressed: _proceedToNextCombo,
                          style: FilledButton.styleFrom(
                            backgroundColor: KivoColors.glowMint,
                            foregroundColor: const Color(0xFF001E24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22 * scale),
                            ),
                            textStyle: TextStyle(
                              fontFamily: KivoTextStyles.fontFamily,
                              fontSize: 28 * scale,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          child: Text(
                            'Tiếp tục màn kế (${_secondsRemaining}s)',
                            textScaler: _textScaler(context),
                          ),
                        ),
                      ),
                      SizedBox(height: 18 * scale),
                      // Back to Map button
                      SizedBox(
                        width: double.infinity,
                        height: 90 * scale,
                        child: OutlinedButton(
                          onPressed: _saveProgressAndGoBack,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: KivoColors.glowMint.withAlpha(120), width: 1.8 * scale),
                            foregroundColor: KivoColors.glowMint,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22 * scale),
                            ),
                            textStyle: TextStyle(
                              fontFamily: KivoTextStyles.fontFamily,
                              fontSize: 28 * scale,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          child: Text(
                            'Quay lại Bản đồ',
                            textScaler: _textScaler(context),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // No more combos, just back to map
                  return SizedBox(
                    width: double.infinity,
                    height: 90 * scale,
                    child: FilledButton(
                      onPressed: _saveProgressAndGoBack,
                      style: FilledButton.styleFrom(
                        backgroundColor: KivoColors.glowMint,
                        foregroundColor: const Color(0xFF001E24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22 * scale),
                        ),
                        textStyle: TextStyle(
                          fontFamily: KivoTextStyles.fontFamily,
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      child: Text(
                        'Quay lại Bản đồ',
                        textScaler: _textScaler(context),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  TextScaler _textScaler(BuildContext context) {
    return MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2);
  }
}

class _AnswerChoiceCard extends StatefulWidget {
  final String label;
  final String text;
  final bool isCorrect;
  final bool isSelected;
  final bool hasAnswered;
  final VoidCallback onTap;
  final double scaleFactor;

  const _AnswerChoiceCard({
    required this.label,
    required this.text,
    required this.isCorrect,
    required this.isSelected,
    required this.hasAnswered,
    required this.onTap,
    required this.scaleFactor,
  });

  @override
  State<_AnswerChoiceCard> createState() => _AnswerChoiceCardState();
}

class _AnswerChoiceCardState extends State<_AnswerChoiceCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scaleFactor;
    final isCorrect = widget.isCorrect;
    final isSelected = widget.isSelected;
    final hasAnswered = widget.hasAnswered;
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: 1.2);

    Color cardColor = KivoColors.cream;
    Color borderColor = const Color(0xFFC4B287);
    Color textColor = const Color(0xFF3E311A);
    Color medallionBg = const Color(0xFF021B1F);
    Color medallionBorder = KivoColors.runeGold;
    Color letterColor = KivoColors.runeGold;

    if (hasAnswered) {
      if (isCorrect) {
        cardColor = const Color(0xFFE2F3E7);
        borderColor = Colors.green.shade600;
        textColor = Colors.green.shade900;
        medallionBg = Colors.green.shade900;
        medallionBorder = Colors.green.shade400;
        letterColor = Colors.white;
      } else if (isSelected) {
        cardColor = const Color(0xFFFDECEE);
        borderColor = Colors.red.shade600;
        textColor = Colors.red.shade900;
        medallionBg = Colors.red.shade900;
        medallionBorder = Colors.red.shade400;
        letterColor = Colors.white;
      } else {
        cardColor = KivoColors.cream.withAlpha(120);
        borderColor = const Color(0xFFC4B287).withAlpha(120);
        textColor = const Color(0xFF3E311A).withAlpha(120);
        medallionBg = const Color(0xFF021B1F).withAlpha(120);
        medallionBorder = KivoColors.runeGold.withAlpha(120);
        letterColor = KivoColors.runeGold.withAlpha(120);
      }
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: EdgeInsets.only(bottom: 18 * scale),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24 * scale),
            border: Border.all(
              color: borderColor,
              width: isSelected || (hasAnswered && isCorrect)
                  ? 2.8 * scale
                  : 1.6 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(14),
                blurRadius: 10 * scale,
                offset: Offset(0, 5 * scale),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 104 * scale),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24 * scale,
                vertical: 20 * scale,
              ),
              child: Row(
                children: [
                  // Medallion with 4 spikes (Compass style)
                  SizedBox(
                    width: 64 * scale,
                    height: 64 * scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Spikes (Rotated square)
                        Transform.rotate(
                          angle: math.pi / 4,
                          child: Container(
                            width: 44 * scale,
                            height: 44 * scale,
                            decoration: BoxDecoration(
                              color: medallionBorder,
                              borderRadius: BorderRadius.circular(4 * scale),
                            ),
                          ),
                        ),
                        // Inner circle
                        Container(
                          width: 52 * scale,
                          height: 52 * scale,
                          decoration: BoxDecoration(
                            color: medallionBg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: medallionBorder.withAlpha(150),
                              width: 1.5 * scale,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.label,
                            style: TextStyle(
                              fontFamily: KivoTextStyles.fontFamily,
                              fontSize: 24 * scale,
                              color: letterColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24 * scale),

                  // Text content
                  Expanded(
                    child: Text(
                      widget.text,
                      softWrap: true,
                      textScaler: textScaler,
                      style: TextStyle(
                        fontFamily: KivoTextStyles.fontFamily,
                        fontSize: 22 * scale,
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogueDivider extends StatelessWidget {
  final double scale;
  const _DialogueDivider({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left horizontal fade line
        Container(
          width: 140 * scale,
          height: 1.2 * scale,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, KivoColors.glowMint.withAlpha(100)],
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        // Left dot
        Container(
          width: 4 * scale,
          height: 4 * scale,
          decoration: const BoxDecoration(
            color: KivoColors.glowMint,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8 * scale),
        // Center diamond shape
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 8 * scale,
            height: 8 * scale,
            color: KivoColors.glowMint,
          ),
        ),
        SizedBox(width: 8 * scale),
        // Right dot
        Container(
          width: 4 * scale,
          height: 4 * scale,
          decoration: const BoxDecoration(
            color: KivoColors.glowMint,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8 * scale),
        // Right horizontal fade line
        Container(
          width: 140 * scale,
          height: 1.2 * scale,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [KivoColors.glowMint.withAlpha(100), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

class _CornerOrnament extends StatelessWidget {
  final double scale;
  const _CornerOrnament({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 6 * scale,
        height: 6 * scale,
        color: KivoColors.glowMint.withAlpha(160),
      ),
    );
  }
}

class _MagicRunePainter extends CustomPainter {
  final double scale;
  final double pulse;

  _MagicRunePainter({required this.scale, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintGlow = Paint()
      ..color = KivoColors.glowMint.withAlpha((40 + pulse * 30).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10 * scale
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * scale);

    final paintSolid = Paint()
      ..color = KivoColors.glowMint.withAlpha((180 + pulse * 75).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * scale;

    final paintDashed = Paint()
      ..color = KivoColors.glowMint.withAlpha((100 + pulse * 60).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * scale;

    final rectOuter = Rect.fromCenter(
      center: center,
      width: 320 * scale,
      height: 80 * scale,
    );
    final rectInner = Rect.fromCenter(
      center: center,
      width: 240 * scale,
      height: 60 * scale,
    );
    final rectCore = Rect.fromCenter(
      center: center,
      width: 160 * scale,
      height: 40 * scale,
    );

    // 1. Draw Glow
    canvas.drawOval(rectOuter, paintGlow);

    // 2. Draw Outer Ellipse
    canvas.drawOval(rectOuter, paintSolid);

    // 3. Draw Inner Ellipse
    canvas.drawOval(rectInner, paintSolid);

    // 4. Draw Core Ellipse
    canvas.drawOval(rectCore, paintDashed);

    // 5. Draw Intersecting Lines (magic patterns)
    final pathLines = Path();
    // Horizontal line
    pathLines.moveTo(center.dx - 160 * scale, center.dy);
    pathLines.lineTo(center.dx + 160 * scale, center.dy);
    // Diagonals inside inner ellipse
    pathLines.moveTo(
      center.dx - 120 * scale * 0.7,
      center.dy - 30 * scale * 0.7,
    );
    pathLines.lineTo(
      center.dx + 120 * scale * 0.7,
      center.dy + 30 * scale * 0.7,
    );
    pathLines.moveTo(
      center.dx - 120 * scale * 0.7,
      center.dy + 30 * scale * 0.7,
    );
    pathLines.lineTo(
      center.dx + 120 * scale * 0.7,
      center.dy - 30 * scale * 0.7,
    );

    canvas.drawPath(pathLines, paintDashed);

    // 6. Draw Rune Dots
    final angles = [0, 45, 90, 135, 180, 225, 270, 315];
    for (final angle in angles) {
      final rad = angle * math.pi / 180;
      final x = center.dx + (160 * scale) * math.cos(rad);
      final y = center.dy + (40 * scale) * math.sin(rad);

      final diamondPath = Path()
        ..moveTo(x, y - 4 * scale)
        ..lineTo(x + 4 * scale, y)
        ..lineTo(x, y + 4 * scale)
        ..lineTo(x - 4 * scale, y)
        ..close();

      canvas.drawPath(diamondPath, paintSolid);
    }
  }

  @override
  bool shouldRepaint(covariant _MagicRunePainter oldDelegate) {
    return oldDelegate.pulse != pulse || oldDelegate.scale != scale;
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: Color(0xFF021C20));
  }
}

class _SparkDot extends StatelessWidget {
  const _SparkDot({
    required this.left,
    required this.top,
    required this.size,
    required this.scale,
  });

  final double left;
  final double top;
  final double size;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left * scale,
      top: top * scale,
      width: size * scale,
      height: size * scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: KivoColors.glowMint,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: KivoColors.glowMint.withAlpha(180),
              blurRadius: 8 * scale,
              spreadRadius: 1 * scale,
            ),
          ],
        ),
      ),
    );
  }
}
