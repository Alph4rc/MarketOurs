import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/components/auto_sized_page_view.dart';

Widget _section(List<double> heights) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final height in heights)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(height: height, color: const Color(0xFFEEEEEE)),
        ),
    ],
  );
}

void main() {
  testWidgets('sizes to the tallest page so switching tabs cannot overflow', (
    tester,
  ) async {
    final controller = PageController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      CupertinoApp(
        home: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  AutoSizedPageView(
                    controller: controller,
                    children: [
                      _section(const [119, 119, 119]),
                      _section(const [50]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(AutoSizedPageView)).height, 393);
    expect(tester.takeException(), isNull);

    controller.animateToPage(
      1,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(AutoSizedPageView)).height, 393);
    expect(tester.takeException(), isNull);

    controller.animateToPage(
      0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(AutoSizedPageView)).height, 393);
    expect(tester.takeException(), isNull);
  });

  testWidgets('re-measures when page content grows', (tester) async {
    final controller = PageController();
    addTearDown(controller.dispose);

    Widget build(List<double> heights) {
      return CupertinoApp(
        home: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  AutoSizedPageView(
                    controller: controller,
                    children: [
                      _section(heights),
                      _section(const [50]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    await tester.pumpWidget(build(const []));
    await tester.pumpAndSettle();
    // The tallest page is the 50px placeholder plus its 12px padding.
    expect(tester.getSize(find.byType(AutoSizedPageView)).height, 62);

    await tester.pumpWidget(build(const [119, 119]));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(AutoSizedPageView)).height, 262);
    expect(tester.takeException(), isNull);
  });
}
