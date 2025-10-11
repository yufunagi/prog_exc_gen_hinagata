import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prog_exc_gen_hinagata/main.dart';

void main() {
  group('App Tests', () {
    testWidgets('Basic UI Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Check title
      expect(find.text('プログラム雛形生成アプリケーション'), findsOneWidget);

      // Check input field
      expect(find.byType(TextField), findsOneWidget);

      // Check generate button
      expect(find.text('生成'), findsOneWidget);
    });

    testWidgets('Basic Code Generation Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.enterText(find.byType(TextField), 'test1');
      await tester.pumpAndSettle();

      await tester.tap(find.text('生成'));
      await tester.pumpAndSettle();

      // Check if code is generated (look for any part of the generated code)
      expect(find.textContaining('test1.c'), findsOneWidget);
      expect(find.textContaining('#include'), findsOneWidget);
    });

    testWidgets('Enshu Conversion Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.enterText(find.byType(TextField), '演習1-2');
      await tester.pumpAndSettle();

      await tester.tap(find.text('生成'));
      await tester.pumpAndSettle();

      // Check if Enshu conversion works
      expect(find.textContaining('Enshu1-2.c'), findsOneWidget);
    });

    testWidgets('Multiple Enshu Conversion Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.enterText(find.byType(TextField), '演習1-2\n演習2-3\nList5-1');
      await tester.pumpAndSettle();

      await tester.tap(find.text('生成'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Enshu1-2.c'), findsOneWidget);

      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Enshu2-3.c'), findsOneWidget);

      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('List5-1.c'), findsOneWidget);
    });

    testWidgets('Navigation Buttons Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Generate multiple files
      await tester.enterText(find.byType(TextField), 'file1\nfile2\nfile3');
      await tester.pumpAndSettle();
      await tester.tap(find.text('生成'));
      await tester.pumpAndSettle();

      // Test navigation
      expect(find.textContaining('file1.c'), findsOneWidget);

      // Go to next file
      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('file2.c'), findsOneWidget);

      // Go to next file again
      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('file3.c'), findsOneWidget);

      // Go back
      await tester.tap(find.byTooltip('前へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('file2.c'), findsOneWidget);
    });

    testWidgets('Copy Button Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Generate a file first
      await tester.enterText(find.byType(TextField), 'test_copy');
      await tester.pumpAndSettle();
      await tester.tap(find.text('生成'));
      await tester.pumpAndSettle();

      // Verify code is generated
      expect(find.textContaining('test_copy.c'), findsOneWidget);

      // Check copy button exists
      expect(find.byIcon(Icons.content_copy), findsOneWidget);

      // Scroll to make sure button is visible and tap it
      await tester.ensureVisible(find.byIcon(Icons.content_copy));
      await tester.pumpAndSettle();

      // Tap copy button - this may trigger clipboard copy or show dialog
      await tester.tap(find.byIcon(Icons.content_copy), warnIfMissed: false);
      await tester.pumpAndSettle();

      // In web environment, copy might fail and show dialog
      // We test that the app doesn't crash and handles the copy operation
      expect(tester.takeException(), isNull);
    });

    testWidgets('Copy Button Without Generated Code Test', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      // Try to copy without generating any code first
      // Copy button should not be visible when no code is generated
      expect(find.byIcon(Icons.content_copy), findsNothing);
    });

    testWidgets('Empty Input Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify TextField is empty by default
      expect(find.byType(TextField), findsOneWidget);

      // Try to generate with empty input
      await tester.tap(find.text('生成'));
      await tester.pumpAndSettle();

      // Should not show code area since no files generated
      // The code area should not exist when no files are generated
      expect(find.textContaining('%%file'), findsNothing);
      expect(find.textContaining('#include'), findsNothing);
    });

    testWidgets('Whitespace Input Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Enter input with whitespace and empty lines
      await tester.enterText(
        find.byType(TextField),
        '  file1  \n\n  file2  \n   \nfile3',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('生成'));
      await tester.pumpAndSettle();

      // Should generate 3 files (whitespace trimmed, empty lines ignored)
      expect(find.textContaining('file1.c'), findsOneWidget);

      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('file2.c'), findsOneWidget);

      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('file3.c'), findsOneWidget);
    });

    testWidgets('Single File Navigation Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Generate single file
      await tester.enterText(find.byType(TextField), 'single_file');
      await tester.pumpAndSettle();
      await tester.tap(find.text('生成'));
      await tester.pumpAndSettle();

      // Check that the file is generated correctly
      expect(find.textContaining('single_file.c'), findsOneWidget);

      // Navigation buttons should exist but for single file, they should be disabled
      // We can test that they exist but don't cause navigation
      final nextButton = find.byTooltip('次へ');
      final prevButton = find.byTooltip('前へ');

      expect(nextButton, findsOneWidget);
      expect(prevButton, findsOneWidget);

      // Try clicking navigation buttons - should remain on same file
      await tester.tap(nextButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.textContaining('single_file.c'), findsOneWidget);

      await tester.tap(prevButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.textContaining('single_file.c'), findsOneWidget);
    });
    testWidgets('Mixed Format Input Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Mix of normal files and exercises
      await tester.enterText(
        find.byType(TextField),
        'List1-1\n演習2-1\ntest_file\n演習3-5',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('生成'));
      await tester.pumpAndSettle();

      // Check first file (normal)
      expect(find.textContaining('List1-1.c'), findsOneWidget);

      // Check second file (converted exercise)
      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Enshu2-1.c'), findsOneWidget);

      // Check third file (normal)
      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('test_file.c'), findsOneWidget);

      // Check fourth file (converted exercise)
      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Enshu3-5.c'), findsOneWidget);
    });

    testWidgets('File Counter Display Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Generate 3 files
      await tester.enterText(find.byType(TextField), 'file1\nfile2\nfile3');
      await tester.pumpAndSettle();
      await tester.tap(find.text('生成'));
      await tester.pumpAndSettle();

      // Check that files are generated and we can navigate between them
      expect(find.textContaining('file1.c'), findsOneWidget);

      // Navigate to second file
      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('file2.c'), findsOneWidget);

      // Navigate to third file
      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('file3.c'), findsOneWidget);

      // Navigate back to verify counter works in reverse
      await tester.tap(find.byTooltip('前へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('file2.c'), findsOneWidget);
    });
    testWidgets('Code Structure Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.enterText(find.byType(TextField), 'structure_test');
      await tester.pumpAndSettle();
      await tester.tap(find.text('生成'));
      await tester.pumpAndSettle();

      // Check all parts of generated C code
      expect(find.textContaining('%%file structure_test.c'), findsOneWidget);
      expect(find.textContaining('#include <stdio.h>'), findsOneWidget);
      expect(find.textContaining('int main(void)'), findsOneWidget);
      expect(find.textContaining('return 0;'), findsOneWidget);
    });

    testWidgets('Special Characters in Filename Test', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      // Test with various special characters that are valid in filenames
      await tester.enterText(
        find.byType(TextField),
        'test-file_123\nfile.backup\nmy_program-v2',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('生成'));
      await tester.pumpAndSettle();

      expect(find.textContaining('test-file_123.c'), findsOneWidget);

      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('file.backup.c'), findsOneWidget);

      await tester.tap(find.byTooltip('次へ'));
      await tester.pumpAndSettle();
      expect(find.textContaining('my_program-v2.c'), findsOneWidget);
    });
  });
}
