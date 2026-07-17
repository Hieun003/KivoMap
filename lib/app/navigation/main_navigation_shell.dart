import 'package:flutter/material.dart';

import '../../features/home/view/home_view.dart';
import '../../features/treasure/view/treasure_view.dart';
import '../bindings/treasure_binding.dart';
import '../assets/image_paths.dart';
import '../icons/kivo_icon_registry.dart';
import '../routes/app_routes.dart';
import '../theme/kivo_theme_tokens.dart';
import '../widgets/kivo_bottom_nav.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  static const List<KivoBottomNavItem> _items = [
    KivoBottomNavItem(
      label: 'Khám phá',
      iconKey: 'discover',
      semanticLabel: 'Mở tab Khám phá',
    ),
    KivoBottomNavItem(
      label: 'Kho báu',
      iconKey: 'treasure',
      semanticLabel: 'Mở tab Kho báu',
    ),
    KivoBottomNavItem(
      label: 'Hồ sơ',
      iconKey: 'profile',
      semanticLabel: 'Mở tab Hồ sơ',
    ),
  ];

  static const List<String> _routes = [
    AppRoutes.home,
    AppRoutes.treasure,
    AppRoutes.profile,
  ];

  @override
  void initState() {
    super.initState();
    TreasureBinding().dependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeView(),
          TreasureView(),
          _NavigationTabPlaceholder(
            title: 'Hồ sơ',
            subtitle: 'Thông tin năng lượng, streak và tiến độ cá nhân.',
            mascotPath: KivoImagePaths.kivoHome,
            iconKey: 'profile',
          ),
        ],
      ),
      bottomNavigationBar: KivoBottomNav(
        items: _items,
        currentIndex: _currentIndex,
        onSelected: _selectTab,
      ),
    );
  }

  void _selectTab(int index) {
    if (index == _currentIndex) {
      return;
    }

    setState(() => _currentIndex = index);
  }

  String get currentRoute => _routes[_currentIndex];
}

class _NavigationTabPlaceholder extends StatelessWidget {
  const _NavigationTabPlaceholder({
    required this.title,
    required this.subtitle,
    required this.mascotPath,
    required this.iconKey,
  });

  final String title;
  final String subtitle;
  final String mascotPath;
  final String iconKey;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: KivoGradients.lightBackground),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(KivoSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: KivoSpacing.xl),
              Row(
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(KivoRadii.xl),
                      border: Border.all(
                        color: KivoColors.kivoTeal.withAlpha(54),
                      ),
                      boxShadow: KivoShadows.soft,
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      mascotPath,
                      width: 58,
                      height: 58,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        KivoIconRegistry.system(iconKey),
                        size: 34,
                        color: KivoColors.kivoTeal,
                      ),
                    ),
                  ),
                  const SizedBox(width: KivoSpacing.md),
                  Expanded(
                    child: Text(title, style: KivoTextStyles.screenTitle),
                  ),
                ],
              ),
              const SizedBox(height: KivoSpacing.xxl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(KivoSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: KivoRadii.largeCard,
                  border: Border.all(color: KivoColors.lightBorder),
                  boxShadow: KivoShadows.soft,
                ),
                child: Text(subtitle, style: KivoTextStyles.body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
