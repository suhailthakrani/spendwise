import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/theme/app_colors.dart';
import 'package:spendwise/core/theme/app_theme.dart';
import 'package:spendwise/core/widgets/app_confirm_dialog.dart';

void main() {
  testWidgets('destructive confirm uses left copy and right actions',
      (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showAppConfirmDialog(
                  context: context,
                  title: 'Are you sure delete this file?',
                  message: "If you delete the file you can't recover it.",
                  confirmLabel: 'Delete',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure delete this file?'), findsOneWidget);
    expect(
      find.text("If you delete the file you can't recover it."),
      findsOneWidget,
    );
    expect(find.byTooltip('Close'), findsOneWidget);

    final title =
        tester.getTopLeft(find.text('Are you sure delete this file?'));
    final message = tester.getTopLeft(
      find.text("If you delete the file you can't recover it."),
    );
    final close = tester.getTopRight(find.byTooltip('Close'));
    expect(title.dx, message.dx);
    expect(title.dx, lessThan(close.dx));

    final cancel = tester.getCenter(find.text('Cancel'));
    final confirm = tester.getCenter(find.text('Delete'));
    expect(confirm.dx, greaterThan(cancel.dx));
    expect(confirm.dy, closeTo(cancel.dy, 1));

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Delete'),
    );
    expect(
      button.style?.backgroundColor?.resolve(const <WidgetState>{}),
      AppColors.error,
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('close and cancel dismiss without confirming', (tester) async {
    bool? result = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showAppConfirmDialog(
                  context: context,
                  title: 'Log out?',
                  message: 'You can sign in again later.',
                  confirmLabel: 'Log out',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('primary confirms keep the brand action color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                showAppConfirmDialog(
                  context: context,
                  title: 'Leave SpendWise?',
                  message: 'Your data stays on this device.',
                  confirmLabel: 'Leave',
                  cancelLabel: 'Stay',
                  tone: AppConfirmTone.primary,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Leave'),
    );
    expect(
      button.style?.backgroundColor?.resolve(const <WidgetState>{}),
      AppColors.primary,
    );
  });
}
