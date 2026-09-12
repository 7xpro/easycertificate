import 'package:flutter_test/flutter_test.dart';

import 'package:easycertificate/app/app.dart';

void main() {
  testWidgets('application bootstraps successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CertificateApp());
    await tester.pump();

    expect(find.byType(CertificateApp), findsOneWidget);
  });
}
