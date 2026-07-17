import 'package:flutter_test/flutter_test.dart';
import 'package:kivo_map/features/profile/view_model/profile_view_state.dart';

void main() {
  const emptyActivities = <ProfileRecentActivity>[];

  test('calculates a clamped energy ratio', () {
    const state = ProfileViewState(
      displayName: 'Explorer Nguyễn',
      profileDescription: 'Học tiếng Anh qua ngữ cảnh thực tế',
      avatarPath: 'asset/mascot/kivo_explorer.png',
      energy: 62,
      maxEnergy: 50,
      streakDays: 7,
      unlockedWordCount: 45,
      discoveredContextCount: 5,
      dueReviewCount: 2,
      nextAction: ProfileNextAction.review,
      recentActivities: emptyActivities,
    );

    expect(state.energyRatio, 1);
  });

  test('returns zero energy ratio when maximum energy is zero', () {
    const state = ProfileViewState(
      displayName: 'Explorer Nguyễn',
      profileDescription: 'Học tiếng Anh qua ngữ cảnh thực tế',
      avatarPath: 'asset/mascot/kivo_explorer.png',
      energy: 0,
      maxEnergy: 0,
      streakDays: 0,
      unlockedWordCount: 0,
      discoveredContextCount: 0,
      dueReviewCount: 0,
      nextAction: ProfileNextAction.discover,
      recentActivities: emptyActivities,
    );

    expect(state.energyRatio, 0);
  });
}
