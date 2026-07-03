import 'package:flutter/widgets.dart';

import '../../../app/theme/kivo_theme_tokens.dart';

enum DiscoveryContextStatus { discovered, available, locked }

enum DiscoveryChipTone { language, action, target, context }

class DiscoveryMatrixState {
  const DiscoveryMatrixState({
    required this.clusterId,
    required this.vocabularyId,
    required this.title,
    required this.subtitle,
    required this.root,
    required this.contexts,
    required this.englishChunks,
    required this.vietnameseChunks,
  });

  final String clusterId;
  final String vocabularyId;
  final String title;
  final String subtitle;
  final DiscoveryRootNode root;
  final List<DiscoveryContextNode> contexts;
  final List<DiscoverySentenceChunk> englishChunks;
  final List<DiscoverySentenceChunk> vietnameseChunks;

  DiscoveryContextNode? get activeContext {
    for (final context in contexts) {
      if (context.status == DiscoveryContextStatus.discovered) {
        return context;
      }
    }
    return contexts.isEmpty ? null : contexts.first;
  }

  static const DiscoveryMatrixState passportDemo = DiscoveryMatrixState(
    clusterId: 'cluster_airport_checkin',
    vocabularyId: 'vocab_passport',
    title: 'Ma tr\u1eadn Kh\u00e1m ph\u00e1',
    subtitle: '(Discover Matrix)',
    root: DiscoveryRootNode(
      label: 'Passport',
      iconKey: 'passport',
      accentColor: KivoColors.targetPurple,
    ),
    contexts: [
      DiscoveryContextNode(
        id: 'link_passport_checkin',
        order: 1,
        title: 'Check-in',
        translation: 'Nh\u1eadn ph\u00f2ng',
        iconKey: 'hotel',
        alignment: Alignment(-0.66, -0.70),
        status: DiscoveryContextStatus.discovered,
        sentence: 'You need to show your passport at the check-in desk.',
        dialogue: [
          DiscoveryDialogueLine(
            speaker: 'Agent',
            text: 'May I see your passport, please?',
          ),
          DiscoveryDialogueLine(speaker: 'Traveler', text: 'Sure, here it is.'),
        ],
        tip:
            'At check-in, passport is usually requested before baggage handling.',
      ),
      DiscoveryContextNode(
        id: 'link_passport_immigration',
        order: 2,
        title: 'Immigration',
        translation: 'Di tr\u00fa',
        iconKey: 'immigration',
        alignment: Alignment(0.72, 0.08),
        status: DiscoveryContextStatus.available,
        sentence: 'Immigration officers compare your passport with your visa.',
        dialogue: [
          DiscoveryDialogueLine(
            speaker: 'Officer',
            text: 'Please place your passport on the scanner.',
          ),
          DiscoveryDialogueLine(
            speaker: 'Traveler',
            text: 'Do you need my boarding pass too?',
          ),
        ],
        tip:
            'Immigration commonly appears with officer, visa, stamp, and arrival.',
      ),
      DiscoveryContextNode(
        id: 'link_passport_duty_free',
        order: 3,
        title: 'Duty-free',
        translation: 'Mi\u1ec5n thu\u1ebf',
        iconKey: 'duty_free',
        alignment: Alignment(0.50, 0.72),
        status: DiscoveryContextStatus.available,
        sentence: 'Some duty-free shops ask for your passport at checkout.',
        dialogue: [
          DiscoveryDialogueLine(
            speaker: 'Cashier',
            text: 'Can I scan your passport for this purchase?',
          ),
          DiscoveryDialogueLine(speaker: 'Traveler', text: 'Yes, one second.'),
        ],
        tip: 'Duty-free purchases may require a passport or boarding pass.',
      ),
      DiscoveryContextNode(
        id: 'link_passport_car_rental',
        order: 4,
        title: 'Car Rental',
        translation: 'Thu\u00ea xe',
        iconKey: 'car_rental',
        alignment: Alignment(-0.62, 0.72),
        status: DiscoveryContextStatus.available,
        sentence: 'The car rental desk may copy your passport and license.',
        dialogue: [
          DiscoveryDialogueLine(
            speaker: 'Staff',
            text: 'I need your passport and driving license.',
          ),
          DiscoveryDialogueLine(
            speaker: 'Traveler',
            text: 'Here are both documents.',
          ),
        ],
        tip:
            'For car rental abroad, passport often appears together with license.',
      ),
      DiscoveryContextNode(
        id: 'link_passport_sim_setup',
        order: 5,
        title: 'SIM Setup',
        translation: '\u0110\u0103ng k\u00fd SIM',
        iconKey: 'sim_card',
        alignment: Alignment(0.66, -0.70),
        status: DiscoveryContextStatus.locked,
        sentence: 'A SIM shop may register your passport before activation.',
        dialogue: [
          DiscoveryDialogueLine(
            speaker: 'Staff',
            text: 'We need your passport to register this SIM.',
          ),
          DiscoveryDialogueLine(
            speaker: 'Traveler',
            text: 'Is a photo enough?',
          ),
        ],
        tip:
            'SIM registration rules vary by country, but ID documents are common.',
      ),
    ],
    englishChunks: [
      DiscoverySentenceChunk('EN', DiscoveryChipTone.language),
      DiscoverySentenceChunk('You need to', DiscoveryChipTone.context),
      DiscoverySentenceChunk('show', DiscoveryChipTone.action),
      DiscoverySentenceChunk('your', DiscoveryChipTone.context),
      DiscoverySentenceChunk('passport', DiscoveryChipTone.target),
      DiscoverySentenceChunk('at the', DiscoveryChipTone.context),
      DiscoverySentenceChunk('check-in desk.', DiscoveryChipTone.context),
    ],
    vietnameseChunks: [
      DiscoverySentenceChunk('VI', DiscoveryChipTone.language),
      DiscoverySentenceChunk('(B\u1ea1n c\u1ea7n', DiscoveryChipTone.context),
      DiscoverySentenceChunk('xu\u1ea5t tr\u00ecnh', DiscoveryChipTone.action),
      DiscoverySentenceChunk('h\u1ed9 chi\u1ebfu', DiscoveryChipTone.target),
      DiscoverySentenceChunk('t\u1ea1i', DiscoveryChipTone.context),
      DiscoverySentenceChunk(
        'qu\u1ea7y l\u00e0m th\u1ee7 t\u1ee5c nh\u1eadn ph\u00f2ng',
        DiscoveryChipTone.context,
      ),
      DiscoverySentenceChunk(')', DiscoveryChipTone.context),
    ],
  );
}

class DiscoveryRootNode {
  const DiscoveryRootNode({
    required this.label,
    required this.iconKey,
    required this.accentColor,
  });

  final String label;
  final String iconKey;
  final Color accentColor;
}

class DiscoveryContextNode {
  const DiscoveryContextNode({
    required this.id,
    required this.order,
    required this.title,
    required this.translation,
    required this.iconKey,
    required this.alignment,
    required this.status,
    required this.sentence,
    required this.dialogue,
    required this.tip,
  });

  final String id;
  final int order;
  final String title;
  final String translation;
  final String iconKey;
  final Alignment alignment;
  final DiscoveryContextStatus status;
  final String sentence;
  final List<DiscoveryDialogueLine> dialogue;
  final String tip;

  bool get isUnlocked => status != DiscoveryContextStatus.locked;
  bool get isDiscovered => status == DiscoveryContextStatus.discovered;
}

class DiscoveryDialogueLine {
  const DiscoveryDialogueLine({required this.speaker, required this.text});

  final String speaker;
  final String text;
}

class DiscoverySentenceChunk {
  const DiscoverySentenceChunk(this.text, this.tone);

  final String text;
  final DiscoveryChipTone tone;
}

class DiscoveryChipPalette {
  const DiscoveryChipPalette({
    required this.text,
    required this.surface,
    required this.border,
    required this.shadow,
  });

  final Color text;
  final Color surface;
  final Color border;
  final Color shadow;

  static DiscoveryChipPalette fromTone(DiscoveryChipTone tone) {
    return switch (tone) {
      DiscoveryChipTone.language => const DiscoveryChipPalette(
        text: KivoColors.deepTeal,
        surface: KivoColors.softMintCard,
        border: KivoColors.kivoTeal,
        shadow: KivoColors.tealShadow,
      ),
      DiscoveryChipTone.action => const DiscoveryChipPalette(
        text: Color(0xFF9A3D02),
        surface: KivoColors.softOrangeCard,
        border: KivoColors.keywordOrange,
        shadow: KivoColors.orangeShadow,
      ),
      DiscoveryChipTone.target => const DiscoveryChipPalette(
        text: KivoColors.targetPurple,
        surface: Color(0xFFF1E9FF),
        border: Color(0xFFB99CFF),
        shadow: Color(0x557646FF),
      ),
      DiscoveryChipTone.context => const DiscoveryChipPalette(
        text: Color(0xFF0D5B20),
        surface: Color(0xFFF1FFE7),
        border: Color(0xFFA9D879),
        shadow: Color(0x446CCB4B),
      ),
    };
  }
}
