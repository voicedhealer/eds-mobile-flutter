import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envie2sortir/main.dart';

void main() {
  testWidgets('App launch smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We need to wrap the app in a ProviderScope because the app uses Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: Envie2SortirApp(),
      ),
    );

    // Verify that the app builds without crashing.
    // We can check for the title text which should be present on the home screen.
    // Note: Since we use a custom font, we might need to load it for tests, 
    // but finding text usually works regardless of font loading in widget tests 
    // unless we are doing golden tests.
    
    // Wait for any animations or async data
    await tester.pumpAndSettle();
    
    // Check if "Envie2Sortir" title is present
    expect(find.text('Envie2Sortir'), findsOneWidget);
  });
}
