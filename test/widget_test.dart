import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kivo_map/data/energy_service.dart';
import 'package:kivo_map/features/home/view_model/home_view_state.dart';
import 'package:kivo_map/features/home/widgets/home_review_banner.dart';
import 'package:kivo_map/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  void disposeEnergyTimer() {
    if (Get.isRegistered<EnergyService>()) {
      Get.find<EnergyService>().dispose();
    }
  }

  tearDown(() {
    if (Get.isRegistered<EnergyService>()) {
      Get.find<EnergyService>().dispose();
    }
    Get.reset();
  });

  testWidgets('shows home dashboard', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('50/50'), findsOneWidget);
    disposeEnergyTimer();
  });

  testWidgets('home dashboard balances on narrow screens', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('50/50'), findsOneWidget);
    expect(tester.takeException(), isNull);
    disposeEnergyTimer();
  });

  testWidgets('filters context map by category', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-category-restaurant')),
      220,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('home-category-restaurant')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('home-topic-coffee_shop')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home-topic-hotel')), findsNothing);
    disposeEnergyTimer();
  });
  testWidgets('shows secret passage category on home', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-category-restaurant')),
      220,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.drag(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.right,
      ),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-category-secret_path')));
    await tester.pumpAndSettle();

    expect(find.text('L\u1ed1i \u0111i b\u00ed m\u1eadt'), findsWidgets);
    expect(
      find.byKey(const ValueKey('home-topic-secret_path')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home-topic-coffee_shop')), findsNothing);
    disposeEnergyTimer();
  });
  testWidgets('opens secret passage intro from secret topic', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-category-restaurant')),
      220,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.drag(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.right,
      ),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-category-secret_path')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-topic-secret_path')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('secret-passage-stone-prompt')),
      findsOneWidget,
    );
    disposeEnergyTimer();
  });
  testWidgets('opens secret passage story after breaking stone', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-category-restaurant')),
      220,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.drag(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.right,
      ),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-category-secret_path')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-topic-secret_path')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('secret-passage-stone')),
      180,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('secret-passage-stone')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2800));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('secret-story-cave-0')), findsOneWidget);
    expect(find.text('B\u1ecf qua'), findsOneWidget);
    expect(find.byKey(const ValueKey('secret-story-next')), findsOneWidget);
    disposeEnergyTimer();
  });
  testWidgets('opens vocabulary planet from seed topic', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-topic-coffee_shop')),
      220,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('home-topic-coffee_shop')));
    await tester.pumpAndSettle();
    expect(find.text('0 / 6'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('vocabulary-node-vocab_spill')),
      findsOneWidget,
    );
    disposeEnergyTimer();
  });
  testWidgets('shows empty knowledge banner state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeReviewBanner(status: HomeReviewBannerStatus.noWords),
        ),
      ),
    );

    expect(find.byType(HomeReviewBanner), findsOneWidget);
    expect(tester.takeException(), isNull);
    disposeEnergyTimer();
  });

  testWidgets('disables review banner when nothing is due', (tester) async {
    var wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeReviewBanner(
            status: HomeReviewBannerStatus.noDueReview,
            onStartReview: () => wasTapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell).first);
    expect(wasTapped, isFalse);
  });
}
