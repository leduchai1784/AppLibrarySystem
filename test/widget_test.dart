// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:library_system/main.dart';

void main() {
  testWidgets('App loads and shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LibrarySystemApp());

    await tester.pumpAndSettle();

    expect(find.text('Library System'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
