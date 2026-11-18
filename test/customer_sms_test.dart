// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dokon/main.dart';
import 'package:dokon/store.dart';
import 'store_test.dart' show MemoryStorage;

void main() {
  testWidgets('Select a saved name prefix and address SMS to that customer', (t) async {
    final disk = MemoryStorage();
    final original = ShopStore(disk);
    await original.saveCoal('Angren', 'Mahalliy');
    await original.sellCoal(original.coal.first, 1, 'kg', 500, 'Naqd', 'Muhammadziyo', '901234567');
    final store = ShopStore(disk);
    await store.load();
    MethodCall? sms;
    const channel = MethodChannel('uz.dokon/sms');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async { sms = call; return null; });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await t.pumpWidget(ShopApp(store: store));
    await t.tap(find.text('Sotuv')); await t.pumpAndSettle();
    await t.tap(find.text('Angren')); await t.pumpAndSettle();
    Finder field(String label) => find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == label);
    await t.enterText(field('Miqdor'), '2');
    await t.enterText(field('1 kg narxi, so‘m'), '600');
    await t.ensureVisible(field('Mijoz ismi'));
    await t.enterText(field('Mijoz ismi'), 'm'); await t.pumpAndSettle();
    await t.ensureVisible(find.text('Muhammadziyo'));
    await t.tap(find.text('Muhammadziyo')); await t.pumpAndSettle();
    expect(t.widget<TextField>(field('Telefon raqami')).controller!.text, '+998901234567');
    final save = find.text('Saqlash va xabar yuborish');
    await t.ensureVisible(save); await t.tap(save); await t.pumpAndSettle();
    expect(sms?.arguments['phone'], '+998901234567');
    expect(store.customers.length, 1);
    expect(store.sales.last['customerId'], store.customers.single['id']);
  });

  test('debtSmsText contains customer name, date, debt amount, and payment request', () {
    final customer = {
      'id': 'cust-1',
      'name': 'Muhammadziyo',
      'phone': '+998901234567',
      'debt': 800000,
    };
    final sales = [
      {
        'id': 'sale-1',
        'number': 1,
        'date': '2026-11-18T10:30:00.000',
        'customer': 'Muhammadziyo',
        'customerId': 'cust-1',
        'phone': '+998901234567',
        'method': 'Qarz',
        'total': 800000,
        'lines': [],
      }
    ];
    final text = debtSmsText(customer, sales);
    expect(text, contains("Assalomu alaykum, Muhammadziyo!"));
    expect(text, contains("Dokon: Xo'jalar"));
    expect(text, contains("2026.11.18 kuni 800 000 so'm qarz olgansiz."));
    expect(text, contains("To'lashingizni so'raymiz."));
    expect(text, contains("Jami qarzingiz: 800 000 so'm."));
  });

  testWidgets('Go to Customers, select debt and send reminder SMS', (t) async {
    final disk = MemoryStorage();
    final store = ShopStore(disk);
    await store.saveCoal('Qorako‘l', 'Import');
    await store.sellCoal(store.coal.first, 1, 'tonna', 1200000, 'Qarz', 'Olimjon', '919876543');

    MethodCall? sms;
    const channel = MethodChannel('uz.dokon/sms');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async { sms = call; return 'SENT_DIRECT'; });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    await t.pumpWidget(ShopApp(store: store));
    await t.tap(find.text('Mijozlar'));
    await t.pumpAndSettle();

    // Verify debtor customer is visible
    expect(find.text('Olimjon'), findsOneWidget);
    expect(find.textContaining('1 200 000'), findsWidgets);

    // Tap the SMS reminder icon button
    final smsBtn = find.byTooltip('SMS eslatma yuborish');
    expect(smsBtn, findsOneWidget);
    await t.tap(smsBtn);
    await t.pumpAndSettle();

    // Verify SMS reminder dialog is displayed
    expect(find.text('Qarz haqida SMS eslatma'), findsOneWidget);
    expect(find.textContaining('qarz olgansiz'), findsOneWidget);
    expect(find.textContaining("To'lashingizni so'raymiz"), findsOneWidget);

    // Tap "SMS eslatma yuborish" button inside dialog
    final sendBtn = find.widgetWithText(FilledButton, 'SMS eslatma yuborish');
    expect(sendBtn, findsOneWidget);
    await t.tap(sendBtn);
    await t.pumpAndSettle();

    expect(sms?.arguments['phone'], '+998919876543');
    expect(sms?.arguments['body'], contains("qarz olgansiz"));
    expect(sms?.arguments['body'], contains("To'lashingizni so'raymiz"));
  });

  testWidgets('Delete customer from list with confirmation dialog', (t) async {
    final disk = MemoryStorage();
    final store = ShopStore(disk);
    await store.addCustomer('Rustamjon', '931234567');
    expect(store.customers.length, 1);

    await t.pumpWidget(ShopApp(store: store));
    await t.tap(find.text('Mijozlar'));
    await t.pumpAndSettle();

    expect(find.text('Rustamjon'), findsOneWidget);

    // Tap delete button in customer row
    final deleteBtn = find.byTooltip('Mijozni o‘chirish');
    expect(deleteBtn, findsOneWidget);
    await t.tap(deleteBtn);
    await t.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Mijozni o‘chirish'), findsWidgets);
    expect(find.textContaining('Rustamjon'), findsWidgets);

    // Tap "O‘chirish" in dialog
    final confirmBtn = find.widgetWithText(FilledButton, 'O‘chirish');
    await t.tap(confirmBtn);
    await t.pumpAndSettle();

    expect(store.customers.isEmpty, isTrue);
    expect(find.text('Rustamjon'), findsNothing);
  });

  testWidgets('Direct SMS shows centered iOS HUD', (t) async {
    final disk = MemoryStorage();
    final original = ShopStore(disk);
    await original.saveCoal('Beshbuloq', 'Mahalliy');
    await original.sellCoal(original.coal.first, 1, 'kg', 500, 'Naqd', 'Nodirbek', '901112233');
    final store = ShopStore(disk);
    await store.load();

    const channel = MethodChannel('uz.dokon/sms');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async => 'SENT_DIRECT');
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    await t.pumpWidget(ShopApp(store: store));
    await t.tap(find.text('Sotuv'));
    await t.pumpAndSettle();

    await t.tap(find.text('Beshbuloq'));
    await t.pumpAndSettle();

    Finder field(String label) => find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == label);
    await t.enterText(field('Miqdor'), '1');
    await t.enterText(field('1 kg narxi, so‘m'), '500');
    await t.ensureVisible(field('Mijoz ismi'));
    await t.enterText(field('Mijoz ismi'), 'N');
    await t.pumpAndSettle();
    await t.tap(find.text('Nodirbek'));
    await t.pumpAndSettle();

    final save = find.text('Saqlash va xabar yuborish');
    await t.ensureVisible(save);
    await t.tap(save);
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));

    // Verify Centered HUD is displayed on screen
    expect(find.byType(CenterHud), findsOneWidget);
    expect(find.text('SMS Yuborildi'), findsOneWidget);
    expect(find.text('Mijozga to‘g‘ridan-to‘g‘ri yuborildi!'), findsOneWidget);

    // Tap to dismiss
    await t.tap(find.byType(CenterHud));
    await t.pumpAndSettle();
    expect(find.byType(CenterHud), findsNothing);
  });
}
