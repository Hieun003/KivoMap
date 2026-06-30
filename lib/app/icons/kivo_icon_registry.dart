import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum KivoIconTone { regular, bold, fill, duotone }

typedef _PhosphorFactory = IconData Function(PhosphorIconsStyle style);

abstract final class KivoIconRegistry {
  static IconData topic(
    String? key, {
    KivoIconTone tone = KivoIconTone.duotone,
  }) {
    return _resolve(_topicIcons, key, tone);
  }

  static IconData vocabulary(
    String? key, {
    KivoIconTone tone = KivoIconTone.duotone,
  }) {
    return _resolve(_vocabularyIcons, key, tone);
  }

  static IconData system(
    String? key, {
    KivoIconTone tone = KivoIconTone.duotone,
  }) {
    return _resolve(_systemIcons, key, tone);
  }

  static IconData reward(
    String? key, {
    KivoIconTone tone = KivoIconTone.duotone,
  }) {
    return _resolve(_rewardIcons, key, tone);
  }

  static IconData _resolve(
    Map<String, _PhosphorFactory> registry,
    String? key,
    KivoIconTone tone,
  ) {
    final normalizedKey = _normalize(key);
    final icon = registry[normalizedKey] ?? registry['default']!;

    return icon(_toPhosphorStyle(tone));
  }

  static String _normalize(String? key) {
    return (key ?? 'default').trim().toLowerCase().replaceAll(
      RegExp(r'[\s-]+'),
      '_',
    );
  }

  static PhosphorIconsStyle _toPhosphorStyle(KivoIconTone tone) {
    return switch (tone) {
      KivoIconTone.regular => PhosphorIconsStyle.regular,
      KivoIconTone.bold => PhosphorIconsStyle.bold,
      KivoIconTone.fill => PhosphorIconsStyle.fill,
      KivoIconTone.duotone => PhosphorIconsStyle.duotone,
    };
  }

  static final Map<String, _PhosphorFactory> _topicIcons = {
    'airport': PhosphorIcons.airplaneTilt,
    'airport_check_in': PhosphorIcons.airplaneTilt,
    'flight_takeoff': PhosphorIcons.airplaneTakeoff,
    'travel': PhosphorIcons.airplaneTilt,
    'hotel': PhosphorIcons.bed,
    'hotel_booking': PhosphorIcons.bed,
    'train': PhosphorIcons.train,
    'train_station': PhosphorIcons.train,
    'restaurant': PhosphorIcons.forkKnife,
    'ordering_food': PhosphorIcons.forkKnife,
    'shopping': PhosphorIcons.shoppingBag,
    'work': PhosphorIcons.briefcase,
    'office': PhosphorIcons.briefcase,
    'transport': PhosphorIcons.bus,
    'default': PhosphorIcons.mapTrifold,
  };

  static final Map<String, _PhosphorFactory> _vocabularyIcons = {
    'passport': PhosphorIcons.identificationCard,
    'identity': PhosphorIcons.identificationCard,
    'identity_document': PhosphorIcons.identificationCard,
    'boarding_pass': PhosphorIcons.ticket,
    'ticket': PhosphorIcons.ticket,
    'mobile_ticket': PhosphorIcons.deviceMobile,
    'gate': PhosphorIcons.signpost,
    'terminal': PhosphorIcons.buildings,
    'flight': PhosphorIcons.airplaneTakeoff,
    'luggage': PhosphorIcons.suitcaseRolling,
    'baggage_claim': PhosphorIcons.suitcaseRolling,
    'check_in_counter': PhosphorIcons.storefront,
    'check_in_desk': PhosphorIcons.storefront,
    'counter': PhosphorIcons.storefront,
    'security_check': PhosphorIcons.shieldCheck,
    'security_gate': PhosphorIcons.shieldCheck,
    'security_officer': PhosphorIcons.userFocus,
    'security_line': PhosphorIcons.queue,
    'customs': PhosphorIcons.bank,
    'immigration': PhosphorIcons.identificationCard,
    'immigration_officer': PhosphorIcons.users,
    'duty_free': PhosphorIcons.shoppingBagOpen,
    'sim_card': PhosphorIcons.simCard,
    'car_rental': PhosphorIcons.car,
    'delay': PhosphorIcons.clock,
    'show': PhosphorIcons.eye,
    'queue': PhosphorIcons.queue,
    'default': PhosphorIcons.bookOpenText,
  };

  static final Map<String, _PhosphorFactory> _systemIcons = {
    'back': PhosphorIcons.arrowLeft,
    'close': PhosphorIcons.xCircle,
    'play': PhosphorIcons.play,
    'audio': PhosphorIcons.speakerHigh,
    'listen': PhosphorIcons.speakerHigh,
    'microphone': PhosphorIcons.microphone,
    'shadowing': PhosphorIcons.microphone,
    'success': PhosphorIcons.checkCircle,
    'failed': PhosphorIcons.xCircle,
    'locked': PhosphorIcons.lockKey,
    'map': PhosphorIcons.mapTrifold,
    'discover': PhosphorIcons.compass,
    'review': PhosphorIcons.cards,
    'progress': PhosphorIcons.path,
    'profile': PhosphorIcons.userCircle,
    'translation': PhosphorIcons.translate,
    'dialogue': PhosphorIcons.chatsCircle,
    'default': PhosphorIcons.sparkle,
  };

  static final Map<String, _PhosphorFactory> _rewardIcons = {
    'stamina': PhosphorIcons.lightning,
    'energy': PhosphorIcons.lightning,
    'streak': PhosphorIcons.fire,
    'trophy': PhosphorIcons.trophy,
    'gift': PhosphorIcons.gift,
    'star': PhosphorIcons.star,
    'diamond': PhosphorIcons.diamond,
    'crystal': PhosphorIcons.diamond,
    'default': PhosphorIcons.starFour,
  };
}
