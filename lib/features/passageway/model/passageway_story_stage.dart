class PassagewayChoice {
  const PassagewayChoice({
    required this.id,
    required this.label,
    required this.text,
    required this.isCorrect,
  });

  final String id;
  final String label;
  final String text;
  final bool isCorrect;
}

class PassagewayStoryStage {
  const PassagewayStoryStage({
    required this.number,
    required this.name,
    required this.guideName,
    required this.introLead,
    required this.introHighlight,
    required this.introTail,
    required this.guardName,
    required this.guardDialogue,
    required this.prompt,
    required this.choices,
    required this.successTitle,
    required this.successDescription,
    required this.completionLabel,
  });

  final int number;
  final String name;
  final String guideName;
  final String introLead;
  final String introHighlight;
  final String introTail;
  final String guardName;
  final String guardDialogue;
  final String prompt;
  final List<PassagewayChoice> choices;
  final String successTitle;
  final String successDescription;
  final String completionLabel;

  PassagewayChoice? choiceById(String id) {
    for (final choice in choices) {
      if (choice.id == id) {
        return choice;
      }
    }
    return null;
  }
}
