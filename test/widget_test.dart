import 'package:flutter_test/flutter_test.dart';

import 'package:whats_app_minimen/main.dart';

void main() {
  testWidgets('app launches and shows login screen', (tester) async {
    await tester.pumpWidget(const WhatsAppMiniApp());

    expect(find.text('واتساب مصغر'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });
}

