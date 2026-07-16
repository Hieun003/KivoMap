import '../../../data/kivo_seed_data.dart';
import '../model/passageway_story_stage.dart';

abstract final class PassagewayStoryCatalog {
  static String _normalize(String str) {
    return str
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[ÌÍỊỈĨ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll(RegExp(r'[ỲÝỴỶỸ]'), 'y')
        .replaceAll(RegExp(r'[đ]'), 'd')
        .replaceAll(RegExp(r'[Đ]'), 'd')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static String? _findComboId(int stageNumber, String stageName) {
    final normName = _normalize(stageName);
    for (final combo in seedPassagewayCombos) {
      final comboId = combo['id']?.toString() ?? '';
      final title = combo['title']?.toString() ?? '';
      if (_normalize(title).contains(normName) || _normalize(comboId).contains(normName)) {
        return comboId;
      }
    }
    // Fallback if no direct match by name
    if (stageNumber == 1) {
      return 'combo_quan_nuoc_dang';
    } else {
      return 'combo_ben_chim_sat';
    }
  }

  static bool hasStage({
    required int stageNumber,
    required String stageName,
    required int stageIndex,
  }) {
    final comboId = _findComboId(stageNumber, stageName);
    if (comboId == null) return false;
    for (final stage in seedPassagewayStages) {
      if (stage['comboId'] == comboId && stage['stageIndex'] == stageIndex) {
        return true;
      }
    }
    return false;
  }

  static PassagewayStoryStage resolve({
    required int stageNumber,
    required String stageName,
    int stageIndex = 0,
  }) {
    final matchedComboId = _findComboId(stageNumber, stageName);

    // Find the stage with target stageIndex for this combo
    Map<String, Object?>? matchedStage;
    for (final stage in seedPassagewayStages) {
      if (stage['comboId'] == matchedComboId && stage['stageIndex'] == stageIndex) {
        matchedStage = stage;
        break;
      }
    }

    // Fallback to any stage in the combo if specified index not found
    if (matchedStage == null) {
      for (final stage in seedPassagewayStages) {
        if (stage['comboId'] == matchedComboId) {
          matchedStage = stage;
          break;
        }
      }
    }

    // Fallback to first stage in seed data
    matchedStage ??= seedPassagewayStages.first;

    final correctIndex = matchedStage['correctIndex'] as int? ?? 0;
    final choicesList = matchedStage['choices'] as List? ?? [];
    final List<PassagewayChoice> parsedChoices = [];

    for (int i = 0; i < choicesList.length; i++) {
      final choiceMap = choicesList[i];
      if (choiceMap is Map) {
        parsedChoices.add(
          PassagewayChoice(
            id: choiceMap['id']?.toString() ?? '',
            label: choiceMap['label']?.toString() ?? '',
            text: choiceMap['text']?.toString() ?? '',
            isCorrect: i == correctIndex,
          ),
        );
      }
    }

    return PassagewayStoryStage(
      number: stageNumber,
      name: stageName,
      guideName: matchedStage['guideName']?.toString() ?? 'Kivo',
      introLead: matchedStage['introLead']?.toString() ?? '',
      introHighlight: matchedStage['introHighlight']?.toString() ?? '',
      introTail: matchedStage['introTail']?.toString() ?? '',
      guardName: matchedStage['guardName']?.toString() ?? '',
      guardDialogue: matchedStage['guardDialogue']?.toString() ?? '',
      prompt: matchedStage['prompt']?.toString() ?? '',
      choices: parsedChoices,
      successTitle: matchedStage['successTitle']?.toString() ?? '',
      successDescription: matchedStage['successDescription']?.toString() ?? '',
      completionLabel: matchedStage['completionLabel']?.toString() ?? 'Tiếp tục',
    );
  }
}
