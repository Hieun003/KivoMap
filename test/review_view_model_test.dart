import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kivo_map/data/kivo_seed_data.dart';
import 'package:kivo_map/data/energy_service.dart';
import 'package:kivo_map/app/responsive/kivo_scale.dart';
import 'package:kivo_map/data/vocabulary_learning_service.dart';
import 'package:kivo_map/features/review/view/review_view.dart';
import 'package:kivo_map/features/review/view_model/review_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    if (Get.isRegistered<EnergyService>()) {
      Get.find<EnergyService>().dispose();
    }
    Get.reset();
  });
  ReviewViewModel createController(VocabularyLearningService service) {
    final energyService = EnergyService();
    addTearDown(energyService.dispose);
    return ReviewViewModel(
      learningService: service,
      energyService: energyService,
    );
  }

  test(
    'builds a seeded review session with shuffled context questions',
    () async {
      final service = VocabularyLearningService();
      final controller = createController(service);

      await controller.load();

      final state = controller.state.value;
      expect(state, isNotNull);
      expect(state!.questions, hasLength(3));

      for (final question in state.questions) {
        expect(question.options, hasLength(4));
        expect(
          question.options.any(
            (option) => option.id == question.correctOptionId,
          ),
          isTrue,
        );
        expect(
          question.segments.map((segment) => segment.text).join(),
          contains('[ ? ]'),
        );
      }
    },
  );

  test('uses answer options from the current vocabulary cluster', () async {
    final service = VocabularyLearningService();
    final controller = createController(service);

    await controller.load();

    final state = controller.state.value!;
    final currentVocabulary = seedVocabularies.firstWhere(
      (item) => item['id'] == state.vocabularyId,
    );
    final clusterId = currentVocabulary['clusterId'];
    final clusterVocabularyIds = seedVocabularies
        .where((item) => item['clusterId'] == clusterId)
        .map((item) => item['id'])
        .toSet();

    for (final question in state.questions) {
      expect(
        question.options.every(
          (option) => clusterVocabularyIds.contains(option.id),
        ),
        isTrue,
      );
    }
  });

  test('records three attempts and completes local repetition state', () async {
    final service = VocabularyLearningService();
    final controller = createController(service);

    await controller.load();

    for (var i = 0; i < 3; i++) {
      final state = controller.state.value!;
      final correctOption = state.currentQuestion.options.firstWhere(
        (option) => option.id == state.currentQuestion.correctOptionId,
      );
      controller.selectOption(correctOption);
      await controller.continueReview();
    }

    final completedState = controller.state.value!;
    expect(completedState.isComplete, isTrue);
    expect(completedState.correctCount, 3);

    final repetitionStates = service.repetitionStatesFor([
      completedState.vocabularyId,
    ]);
    final repetition = repetitionStates[completedState.vocabularyId];
    expect(repetition, isNotNull);
    expect(repetition!.reviewCount, 1);
    expect(repetition.masteryLevel, 2);
    expect(repetition.intervalDays, 3);
  });

  test('continues with the next due vocabulary before completing', () async {
    final service = VocabularyLearningService();
    final firstVocabularyId = seedVocabularies[0]['id']!.toString();
    final secondVocabularyId = seedVocabularies[1]['id']!.toString();
    final now = DateTime.now();

    await service.completeVocabularyLearning(
      vocabularyId: firstVocabularyId,
      completedAt: now.subtract(const Duration(minutes: 35)),
    );
    await service.completeVocabularyLearning(
      vocabularyId: secondVocabularyId,
      completedAt: now.subtract(const Duration(minutes: 34)),
    );

    final controller = createController(service);
    await controller.load();

    expect(controller.state.value!.vocabularyId, firstVocabularyId);

    for (var i = 0; i < 3; i++) {
      final state = controller.state.value!;
      final correctOption = state.currentQuestion.options.firstWhere(
        (option) => option.id == state.currentQuestion.correctOptionId,
      );
      controller.selectOption(correctOption);
      await controller.continueReview();
    }

    final nextState = controller.state.value!;
    expect(nextState.isComplete, isFalse);
    expect(nextState.vocabularyId, secondVocabularyId);
    expect(nextState.currentQuestionIndex, 0);
    expect(nextState.correctCount, 0);
  });
  testWidgets('reveals Vietnamese meaning only after selecting an answer', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(KivoScale.designSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final service = VocabularyLearningService();
    final energyService = EnergyService();
    final controller = ReviewViewModel(
      learningService: service,
      energyService: energyService,
    );
    Get.put<ReviewViewModel>(controller);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: KivoScale.designSize,
        minTextAdapt: true,
        builder: (context, child) {
          return const GetMaterialApp(home: ReviewView());
        },
      ),
    );
    await tester.pumpAndSettle();

    final state = controller.state.value!;
    final correctOption = state.currentQuestion.options.firstWhere(
      (option) => option.id == state.currentQuestion.correctOptionId,
    );

    expect(
      find.text('${correctOption.word} / ${correctOption.meaning}'),
      findsNothing,
    );
    await tester.tap(find.text(correctOption.word));
    await tester.pumpAndSettle();

    expect(
      find.text('${correctOption.word} / ${correctOption.meaning}'),
      findsOneWidget,
    );
    energyService.dispose();
  });
}
