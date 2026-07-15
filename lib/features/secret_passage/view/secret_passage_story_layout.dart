part of 'secret_passage_story_view.dart';

class _StoryBackdrop extends StatelessWidget {
  const _StoryBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.05,
          colors: [Color(0xFF06333A), Color(0xFF02282F), Color(0xFF001C22)],
          stops: [0, 0.55, 1],
        ),
      ),
    );
  }
}

class _PositionedSource extends StatelessWidget {
  const _PositionedSource({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.scale,
    required this.child,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left * scale,
      top: top * scale,
      width: width * scale,
      height: height * scale,
      child: child,
    );
  }
}

class _MiddlePillarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.18, size.height);
    path.lineTo(size.width * 0.28, size.height * 0.70);
    path.lineTo(size.width * 0.32, size.height * 0.70);
    path.lineTo(size.width * 0.35, size.height * 0.42);
    path.lineTo(size.width * 0.65, size.height * 0.42);
    path.lineTo(size.width * 0.68, size.height * 0.70);
    path.lineTo(size.width * 0.72, size.height * 0.70);
    path.lineTo(size.width * 0.82, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
