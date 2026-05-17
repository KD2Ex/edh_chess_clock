import 'package:edh_chess_clock/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('active player timer advances and passes clockwise', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EdhChessClockApp());

    expect(find.text('P1'), findsOneWidget);
    expect(find.text('P2'), findsOneWidget);
    expect(find.text('15:00'), findsNWidgets(4));

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('14:59'), findsOneWidget);
    expect(find.text('15:00'), findsNWidgets(3));

    await tester.tap(find.byKey(const ValueKey('player-1-timer')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('14:59'), findsNWidgets(2));
    expect(find.text('15:00'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Reset clocks'));
    await tester.pump();

    expect(find.text('15:00'), findsNWidgets(4));
  });
}
