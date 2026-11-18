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
}
