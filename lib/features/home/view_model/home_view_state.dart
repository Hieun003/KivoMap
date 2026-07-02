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

  static const HomeDashboardState sampleReviewDue = HomeDashboardState(
    userName: 'Explorer',
    roleLabel: 'Explorer',
    energy: 24,
    maxEnergy: 50,
    streakDays: 7,
    bannerStatus: HomeReviewBannerStatus.reviewDue,
    categories: [
      HomeCategoryChipData(
        label: 'Tất cả',
        iconKey: 'default',
        isSelected: true,
      ),
      HomeCategoryChipData(label: 'Đời Xê Dịch', iconKey: 'airport'),
      HomeCategoryChipData(label: 'Sống Sành Điệu', iconKey: 'restaurant'),
      HomeCategoryChipData(label: 'Công Sở', iconKey: 'office'),
      HomeCategoryChipData(label: 'Lối Đi Bí Mật', iconKey: 'secret_path'),
    ],
    contextSections: [
      HomeContextSectionData(
        title: 'Đời Xê Dịch',
        iconKey: 'airport',
        accentColor: HomeAccentColor.blue,
        items: [
          HomeContextTopicData(
            clusterId: 'cluster_airport_checkin',
            title: 'Thủ tục Sân Bay',
            subtitle: '(Airport Check-in)',
            iconKey: 'airport_check_in',
            learnedCount: 2,
            totalCount: 4,
            accentColor: HomeAccentColor.blue,
          ),
          HomeContextTopicData(
            clusterId: 'cluster_hotel_booking',
            title: 'Đặt phòng Khách Sạn',
            subtitle: '(Hotel Booking)',
            iconKey: 'hotel_booking',
            learnedCount: 1,
            totalCount: 4,
            accentColor: HomeAccentColor.orange,
          ),
          HomeContextTopicData(
            clusterId: 'cluster_train_station',
            title: 'Ga Tàu',
            subtitle: '(Train Station)',
            iconKey: 'train_station',
            learnedCount: 2,
            totalCount: 4,
            accentColor: HomeAccentColor.pink,
          ),
        ],
      ),
      HomeContextSectionData(
        title: 'Sống Sành Điệu',
        iconKey: 'restaurant',
        accentColor: HomeAccentColor.green,
        items: [
          HomeContextTopicData(
            clusterId: 'cluster_ordering_food',
            title: 'Gọi món Nhà Hàng',
            subtitle: '(Ordering Food)',
            iconKey: 'ordering_food',
            learnedCount: 3,
            totalCount: 6,
            accentColor: HomeAccentColor.green,
          ),
          HomeContextTopicData(
            clusterId: 'cluster_shopping',
            title: 'Mua Sắm',
            subtitle: '(Shopping)',
            iconKey: 'shopping',
            learnedCount: 2,
            totalCount: 4,
            accentColor: HomeAccentColor.purple,
          ),
        ],
      ),
      HomeContextSectionData(
        title: 'Lối Đi Bí Mật',
        iconKey: 'secret_path',
        accentColor: HomeAccentColor.purple,
        items: [
          HomeContextTopicData(
            clusterId: 'cluster_secret_path',
            title: 'Cánh Cửa Bí Mật',
            subtitle: '(Secret Passage)',
            iconKey: 'secret_path',
            learnedCount: 0,
            totalCount: 5,
            accentColor: HomeAccentColor.purple,
          ),
        ],
      ),
    ],
  );
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
