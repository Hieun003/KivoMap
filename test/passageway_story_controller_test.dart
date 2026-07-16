import 'package:flutter_test/flutter_test.dart';
import 'package:kivo_map/features/passageway/data/passageway_story_catalog.dart';
import 'package:kivo_map/features/passageway/model/passageway_story_stage.dart';
import 'package:kivo_map/features/passageway/view_model/passageway_story_controller.dart';

void main() {
  late PassagewayStoryStage stage;

  setUp(() {
    stage = PassagewayStoryCatalog.resolve(
      stageNumber: 2,
      stageName: 'Ben Chim Sat',
    );
  });

  test('catalog creates a stage with exactly one correct choice', () {
    expect(stage.number, 2);
    expect(stage.name, 'Ben Chim Sat');
    expect(stage.choices, hasLength(3));
    expect(stage.choices.where((choice) => choice.isCorrect), hasLength(1));
  });

  test('incorrect choice is recorded and locks later selections', () {
    final controller = PassagewayStoryController(stage: stage);

    final selected = controller.selectChoice('question-rule');
    final secondSelection = controller.selectChoice('discard-bottle');

    expect(selected, isNotNull);
    expect(selected!.isCorrect, isFalse);
    expect(controller.state.selectedChoiceId, 'question-rule');
    expect(controller.state.hasAnswered, isTrue);
    expect(controller.state.showSuccess, isFalse);
    expect(secondSelection, isNull);
  });

  test('success can only be revealed after the correct choice', () {
    final controller = PassagewayStoryController(stage: stage);

    controller.revealSuccess();
    expect(controller.state.showSuccess, isFalse);

    final selected = controller.selectChoice('discard-bottle');
    controller.revealSuccess();

    expect(selected, isNotNull);
    expect(selected!.isCorrect, isTrue);
    expect(controller.selectedChoice?.id, 'discard-bottle');
    expect(controller.state.showSuccess, isTrue);
  });

  test('unknown choice id is rejected', () {
    final controller = PassagewayStoryController(stage: stage);

    expect(
      () => controller.selectChoice('missing-choice'),
      throwsArgumentError,
    );
  });
}
