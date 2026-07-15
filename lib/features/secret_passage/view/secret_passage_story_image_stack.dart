part of 'secret_passage_story_view.dart';

extension _SecretPassageStoryImageStack on _SecretPassageStoryViewState {
  Widget _buildImageStack() {
    final showBossTransition =
        _revealController.isAnimating || _currentStoryIndex == 2;
    final page = SecretPassageStoryContent.pages[_currentStoryIndex];

    return Stack(
      fit: StackFit.expand,
      children: [
        if (showBossTransition)
          Image.asset(
            KivoImagePaths.cavePillars,
            key: const ValueKey('secret-story-bg-pillars'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          )
        else
          Image.asset(
            page.imagePath,
            key: ValueKey('secret-story-cave-$_currentStoryIndex'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        if (showBossTransition)
          AnimatedBuilder(
            animation: _revealController,
            builder: (context, child) {
              final progress = _revealAnimation.value;
              final bossProgress = Curves.easeOutCubic.transform(
                ((progress - 0.72) / 0.28).clamp(0.0, 1.0),
              );

              if (bossProgress <= 0) return const SizedBox.shrink();

              return Opacity(
                opacity: bossProgress,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: const [
                        Colors.white,
                        Colors.white,
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: [
                        0.0,
                        bossProgress.clamp(0.0, 1.0),
                        (bossProgress + 0.22).clamp(0.0, 1.0),
                        1.0,
                      ],
                    ).createShader(rect);
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        left: 229 * widget.scale,
                        top: 135 * widget.scale,
                        width: 320 * widget.scale,
                        height: 320 * widget.scale,
                        child: ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (rect) {
                            return const RadialGradient(
                              center: Alignment(0.0, -0.25),
                              radius: 0.70,
                              colors: [
                                Colors.white,
                                Colors.transparent,
                              ],
                              stops: [0.45, 1.0],
                            ).createShader(rect);
                          },
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Color(0x8804262D),
                              BlendMode.srcATop,
                            ),
                            child: Image.asset(
                              KivoImagePaths.luciferShadow,
                              key: const ValueKey(
                                'secret-story-boss-lucifer',
                              ),
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        if (showBossTransition)
          IgnorePointer(
            child: ClipPath(
              clipper: _MiddlePillarClipper(),
              child: Image.asset(
                KivoImagePaths.cavePillars,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        if (showBossTransition)
          AnimatedBuilder(
            animation: Listenable.merge([
              _revealController,
              _btnPulseController,
            ]),
            builder: (context, child) {
              final progress = _revealAnimation.value;
              return CustomPaint(
                painter: _EnergyLinkPainter(
                  progress: progress,
                  pulse: _btnPulseController.value,
                ),
              );
            },
          ),
        if (_currentStoryIndex == 1 && _pulseController.value > 0)
          IgnorePointer(
            child: Opacity(
              opacity: _pulseAnimation.value,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x6665FBE8),
                  backgroundBlendMode: BlendMode.colorBurn,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
