import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivo_map/features/home/view_model/home_view_state.dart';
import 'package:kivo_map/features/home/widgets/home_review_banner.dart';
import 'package:kivo_map/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows home dashboard', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('24/50'), findsOneWidget);
  });

  testWidgets('home dashboard balances on narrow screens', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('24/50'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
