import '../../../app/assets/image_paths.dart';

class SecretPassageStoryPage {
  const SecretPassageStoryPage({required this.imagePath, required this.text});

  final String imagePath;
  final String text;
}

abstract final class SecretPassageStoryContent {
  static const List<SecretPassageStoryPage> pages = [
    SecretPassageStoryPage(
      imagePath: KivoImagePaths.caveIntro,
      text:
          'B\u01b0\u1edbc qua phi\u1ebfn \u0111\u00e1 c\u1ed5, b\u1ea1n l\u1ea1c v\u00e0o\n'
          'M\u1eadt \u0110\u1ea1o Ng\u00f4n Ng\u1eef \u2013 n\u01a1i l\u01b0u gi\u1eef\n'
          'k\u00fd \u1ee9c h\u00e0ng ng\u00e0n n\u0103m c\u1ee7a\n'
          'v\u01b0\u01a1ng qu\u1ed1c Kivo...',
    ),
    SecretPassageStoryPage(
      imagePath: KivoImagePaths.cavePillars,
      text:
          'N\u01a1i \u0111\u00e2y, nh\u1eefng d\u00f2ng n\u0103ng l\u01b0\u1ee3ng\n'
          'th\u1ec3 l\u1ef1c qu\u00fd gi\u00e1 \u0111\u00e3 b\u1ecb phong \u1ea5n b\u1edf\n'
          'c\u00e1c th\u1eed th\u00e1ch giao ti\u1ebfp c\u1ed5 \u0111\u1ea1i.',
    ),
    SecretPassageStoryPage(
      imagePath: KivoImagePaths.luciferShadow,
      text:
          'Th\u1ea7n Tri Th\u1ee9c \u0111\u00e3 \u0111\u1ee3i s\u1eb5n. Ch\u1ec9 c\u00f3\n'
          'nh\u1eefng nh\u00e0 th\u00e1m hi\u1ec3m ph\u1ea3n x\u1ea1\n'
          'ti\u1ebfng Anh xu\u1ea5t s\u1eafc m\u1edbi c\u00f3 th\u1ec3\n'
          'gi\u1ea3i m\u00e3 c\u00e2u \u0111\u1ed1 \u0111\u1ec3 n\u1ea1p \u0111\u1ea7y th\u1ec3 l\u1ef1c.',
    ),
  ];
}
