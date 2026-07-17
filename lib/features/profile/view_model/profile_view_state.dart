class ProfileViewState {
  const ProfileViewState({
    required this.displayName,
    required this.profileDescription,
    required this.avatarPath,
    required this.energy,
    required this.maxEnergy,
    required this.streakDays,
    required this.unlockedWordCount,
    required this.discoveredContextCount,
    required this.dueReviewCount,
    required this.nextAction,
    required this.recentActivities,
  });
  final String displayName;
  final String profileDescription;
  final String avatarPath;
  final int energy;
  final int maxEnergy;
  final int streakDays;
  final int unlockedWordCount;
  final int discoveredContextCount;
  final int dueReviewCount;
  final ProfileNextAction nextAction;
  final List<ProfileRecentActivity> recentActivities;
  double get energyRatio => maxEnergy == 0 ? 0 : (energy / maxEnergy).clamp(0, 1).toDouble();
}
enum ProfileNextAction { review, discover }
enum ProfileActivityType { learned, reviewed, discovered }
class ProfileRecentActivity {
  const ProfileRecentActivity({required this.title, required this.occurredAt, required this.type});
  final String title;
  final DateTime occurredAt;
  final ProfileActivityType type;
}
