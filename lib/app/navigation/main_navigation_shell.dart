import 'package:flutter/material.dart';

import '../../features/home/view/home_view.dart';
import '../../features/profile/view/profile_view.dart';
import '../../features/treasure/view/treasure_view.dart';
import '../bindings/home_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/treasure_binding.dart';
import '../routes/app_routes.dart';
import '../widgets/kivo_bottom_nav.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

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
    _currentIndex = widget.initialIndex.clamp(0, 2);
    HomeBinding().dependencies();
    TreasureBinding().dependencies();
    ProfileBinding().dependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [HomeView(), TreasureView(), ProfileView()],
      ),
      bottomNavigationBar: KivoBottomNav(
        items: _items,
        currentIndex: _currentIndex,
        onSelected: _selectTab,
        compact: _currentIndex == 2,
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
