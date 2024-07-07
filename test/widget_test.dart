// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lines_top_mobile/main.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    var path = await getApplicationDocumentsDirectory();
  File _fileFirstBuild = File('$path/firstBuild.txt');
  bool isFirst = await _fileFirstBuild.exists();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(isFirstBuild: isFirst,));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
