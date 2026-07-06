enum HomeReviewBannerStatus { noWords, noDueReview, reviewDue }

class HomeDashboardState {
  const HomeDashboardState({
    required this.userName,
    required this.roleLabel,
    required this.energy,
    required this.maxEnergy,
    required this.streakDays,
    required this.bannerStatus,
    required this.categories,
    required this.contextSections,
  });

  final String userName;
  final String roleLabel;
  final int energy;
  final int maxEnergy;
  final int streakDays;
  final HomeReviewBannerStatus bannerStatus;
  final List<HomeCategoryChipData> categories;
  final List<HomeContextSectionData> contextSections;

  double get energyRatio => maxEnergy == 0 ? 0 : energy / maxEnergy;

  HomeDashboardState copyWith({
    List<HomeCategoryChipData>? categories,
    List<HomeContextSectionData>? contextSections,
  }) {
    return HomeDashboardState(
      userName: userName,
      roleLabel: roleLabel,
      energy: energy,
      maxEnergy: maxEnergy,
      streakDays: streakDays,
      bannerStatus: bannerStatus,
      categories: categories ?? this.categories,
      contextSections: contextSections ?? this.contextSections,
    );
  }
}

class HomeCategoryChipData {
  const HomeCategoryChipData({
    required this.label,
    required this.iconKey,
    this.isSelected = false,
  });

  final String label;
  final String iconKey;
  final bool isSelected;

  HomeCategoryChipData copyWith({bool? isSelected}) {
    return HomeCategoryChipData(
      label: label,
      iconKey: iconKey,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class HomeContextSectionData {
  const HomeContextSectionData({
    required this.title,
    required this.iconKey,
    required this.accentColor,
    required this.items,
  });

  final String title;
  final String iconKey;
  final HomeAccentColor accentColor;
  final List<HomeContextTopicData> items;

  HomeContextSectionData copyWith({List<HomeContextTopicData>? items}) {
    return HomeContextSectionData(
      title: title,
      iconKey: iconKey,
      accentColor: accentColor,
      items: items ?? this.items,
    );
  }
}

class HomeContextTopicData {
  const HomeContextTopicData({
    required this.clusterId,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.learnedCount,
    required this.totalCount,
    required this.accentColor,
  });

  final String clusterId;
  final String title;
  final String subtitle;
  final String iconKey;
  final int learnedCount;
  final int totalCount;
  final HomeAccentColor accentColor;
}

enum HomeAccentColor { blue, orange, pink, green, purple }
