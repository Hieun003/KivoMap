class PassagewayStoryState {
  const PassagewayStoryState({this.selectedChoiceId, this.showSuccess = false});

  final String? selectedChoiceId;
  final bool showSuccess;

  bool get hasAnswered => selectedChoiceId != null;

  PassagewayStoryState copyWith({String? selectedChoiceId, bool? showSuccess}) {
    return PassagewayStoryState(
      selectedChoiceId: selectedChoiceId ?? this.selectedChoiceId,
      showSuccess: showSuccess ?? this.showSuccess,
    );
  }
}
