import '../model/passageway_story_stage.dart';

abstract final class PassagewayStoryCatalog {
  static PassagewayStoryStage resolve({
    required int stageNumber,
    required String stageName,
  }) {
    return PassagewayStoryStage(
      number: stageNumber,
      name: stageName,
      guideName: 'Kivo',
      introLead:
          '\u2018H\u00e3y nh\u1eafm m\u1eaft l\u1ea1i... Ta s\u1ebd \u0111\u01b0a ng\u01b0\u01a1i v\u00e0o ',
      introHighlight: '\u1ea2o c\u1ea3nh B\u1ebfn Chim S\u1eaft',
      introTail: '!\u2018',
      guardName: 'T\u00ean l\u00ednh canh g\u1eaft l\u1edbn:',
      guardDialogue:
          '\u2018Hey! You cannot bring this bottle through security!\u2019',
      prompt:
          'Ng\u01b0\u01a1i ch\u1ecdn kh\u1ea9u ch\u00fa n\u00e0o \u0111\u1ec3 \u0111\u00e1p l\u1ea1i?',
      choices: const [
        PassagewayChoice(
          id: 'discard-bottle',
          label: 'A.',
          text: 'Oh, sorry! I will throw it away right now.',
          isCorrect: true,
        ),
        PassagewayChoice(
          id: 'question-rule',
          label: 'B.',
          text:
              'Really? It\u2019s just a water bottle. What\u2019s the problem?',
          isCorrect: false,
        ),
        PassagewayChoice(
          id: 'request-exception',
          label: 'C.',
          text: 'I understand the rule, but could you make an exception?',
          isCorrect: false,
        ),
      ],
      successTitle: 'Kh\u1ea9u ch\u00fa ch\u00ednh x\u00e1c!',
      successDescription:
          'B\u1ea1n \u0111\u00e3 \u0111\u00e1p l\u1ea1i t\u00ean l\u00ednh canh an ninh m\u1ed9t c\u00e1ch '
          'l\u1ecbch s\u1ef1 \u0111\u1ec3 gi\u1ea3i quy\u1ebft t\u00ecnh hu\u1ed1ng v\u00e0 b\u1eaft \u0111\u1ea7u b\u01b0\u1edbc '
          'qua B\u1ebfn Chim S\u1eaft th\u00e0nh c\u00f4ng.',
      completionLabel: 'Quay l\u1ea1i B\u1ea3n \u0111\u1ed3',
    );
  }
}
