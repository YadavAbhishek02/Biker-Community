// This is a basic Flutter widget test.


import 'package:flutter_test/flutter_test.dart';
import 'package:biker_community/core/injection_container.dart' as di;
import 'package:biker_community/main.dart';
import 'package:biker_community/features/auth/domain/repositories/auth_repository.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize DI for testing
    await di.sl.reset();
    await di.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const BikerCommunityApp());

    // Wait for everything to settle
    await tester.pumpAndSettle();
    
    // Check that we find the app
    expect(find.byType(BikerCommunityApp), findsOneWidget);
  });
}
