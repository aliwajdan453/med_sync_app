import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/core/widgets/app_text_field.dart';

void main() {
  testWidgets('moves focus with text input next action', (tester) async {
    final firstFocus = FocusNode();
    final secondFocus = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppTextField(
                label: 'Email',
                controller: TextEditingController(),
                focusNode: firstFocus,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                onSubmitted: (_) => secondFocus.requestFocus(),
              ),
              AppTextField(
                label: 'Password',
                controller: TextEditingController(),
                focusNode: secondFocus,
                textInputAction: TextInputAction.done,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
              ),
            ],
          ),
        ),
      ),
    );

    firstFocus.requestFocus();
    await tester.pump();
    expect(firstFocus.hasFocus, isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(secondFocus.hasFocus, isTrue);
  });

  testWidgets('shows label and readable error text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            label: 'Email',
            controller: TextEditingController(),
            errorText: 'Enter a valid email address.',
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('shows validator errors from enclosing form', (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: AppTextField(
              label: 'Email',
              controller: TextEditingController(),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your email.' : null,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Enter your email.'), findsNothing);

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Enter your email.'), findsOneWidget);
  });
}
