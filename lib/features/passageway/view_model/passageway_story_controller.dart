import '../model/passageway_story_stage.dart';
import 'passageway_story_state.dart';

class PassagewayStoryController {
  PassagewayStoryController({required this.stage})
    : _state = const PassagewayStoryState() {
    final correctChoiceCount = stage.choices
        .where((choice) => choice.isCorrect)
        .length;
    if (stage.choices.isEmpty || correctChoiceCount != 1) {
      throw ArgumentError.value(
        stage.choices,
        'stage.choices',
        'A passageway stage must have exactly one correct choice.',
      );
    }
  }

  final PassagewayStoryStage stage;
  PassagewayStoryState _state;

  PassagewayStoryState get state => _state;

  PassagewayChoice? get selectedChoice {
    final selectedChoiceId = _state.selectedChoiceId;
    return selectedChoiceId == null ? null : stage.choiceById(selectedChoiceId);
  }

  PassagewayChoice? selectChoice(String choiceId) {
    if (_state.hasAnswered) {
      return null;
    }

    final choice = stage.choiceById(choiceId);
    if (choice == null) {
      throw ArgumentError.value(choiceId, 'choiceId', 'Unknown choice.');
    }

    _state = _state.copyWith(selectedChoiceId: choice.id);
    return choice;
  }

  void revealSuccess() {
    if (selectedChoice?.isCorrect != true) {
      return;
    }
    _state = _state.copyWith(showSuccess: true);
  }
}
