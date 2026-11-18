import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:dokon/store.dart';

class MemoryStorage implements Storage {
  Json? data;
  bool fail = false;
  @override
  Future<Json?> read() async =>
      data == null ? null : jsonDecode(jsonEncode(data)) as Json;
  @override
  Future<void> write(Json next) async {
    if (fail) throw const FileSystemException('Disk full');
    data = jsonDecode(jsonEncode(next)) as Json;
  }
}

void main() {
  late MemoryStorage disk;
  late ShopStore store;
  setUp(() async {
    disk = MemoryStorage();
    store = ShopStore(disk);
    await store.seedDemo();
  });

  test(
    'Cash sale changes stock and ledger once, snapshots receipt prices',
    () async {
      final receipt = await store.checkout({'demo-0': 2}, 'Naqd', null, 1000);
      expect(receipt['total'], 35000);
      expect(store.products.first['stock'], 46);
      expect(store.cash, 35000);
      expect(store.sales.length, 1);
      expect(store.entries.length, 1);
      final reloaded = ShopStore(disk);
      await reloaded.load();
      expect(reloaded.cash, 35000);
      expect(reloaded.products.first['stock'], 46);
    },
  );

  test(
    'Credit sale and partial repayment preserve debt and separate card from cash',
    () async {
      await store.checkout({'demo-0': 2}, 'Nasiya', 'customer-1', 0);
      expect(store.debt, 36000);
      expect(store.cash, 0);
      await store.repay('customer-1', 16000, 'Karta');
      expect(store.debt, 20000);
      expect(store.card, 16000);
      expect(store.cash, 0);
      await expectLater(
        store.repay('customer-1', 20001, 'Naqd'),
        throwsStateError,
      );
      expect(store.debt, 20000);
    },
  );

  test('Invalid sale never partially reduces stock', () async {
    await expectLater(
      store.checkout({'demo-0': 1, 'demo-1': 999}, 'Naqd', null, 0),
      throwsStateError,
    );
    expect(store.products.first['stock'], 48);
    expect(store.sales, isEmpty);
    await expectLater(
      store.checkout({'demo-0': 1}, 'Nasiya', null, 0),
      throwsStateError,
    );
    await expectLater(
      store.checkout({'demo-0': 1}, 'Naqd', null, 18000),
      throwsStateError,
    );
    expect(store.products.first['stock'], 48);
    expect(store.entries, isEmpty);
  });

  test('Failed persistence rolls back sale, debt and stock', () async {
    disk.fail = true;
    await expectLater(
      store.checkout({'demo-0': 2}, 'Nasiya', 'customer-1', 0),
      throwsA(isA<FileSystemException>()),
    );
    expect(store.products.first['stock'], 48);
    expect(store.debt, 0);
    expect(store.sales, isEmpty);
    expect(store.busy, false);
  });

  test('No overdraft and inventory arrival updates quantity', () async {
    await expectLater(
      store.cashEntry(-100, 'Xarajat', 'Naqd'),
      throwsStateError,
    );
    await store.cashEntry(100000, 'Boshlang‘ich qoldiq', 'Naqd');
    await store.cashEntry(-12000, 'Transport', 'Naqd');
    expect(store.cash, 88000);
    await store.addStock('demo-0', 10);
    expect(store.products.first['stock'], 58);
  });

  test(
    'File storage replaces snapshots and preserves previous backup',
    () async {
      final dir = await Directory.systemTemp.createTemp('dokon-test-');
      addTearDown(() => dir.delete(recursive: true));
      final storage = FileStorage(File('${dir.path}/data.json'));
      await storage.write({'version': 1, 'value': 1});
      await storage.write({'version': 1, 'value': 2});
      expect((await storage.read())!['value'], 2);
      expect(
        jsonDecode(
          await File('${dir.path}/data.json.backup').readAsString(),
        )['value'],
        1,
      );
    },
  );

  test('deleteCustomer removes customer from list and persists change', () async {
    expect(store.customers.length, 2);
    await store.deleteCustomer('customer-1');
    expect(store.customers.length, 1);
    expect(store.customers.any((c) => c['id'] == 'customer-1'), isFalse);
    final reloaded = ShopStore(disk);
    await reloaded.load();
    expect(reloaded.customers.length, 1);
    expect(reloaded.customers.any((c) => c['id'] == 'customer-1'), isFalse);
  });
}
