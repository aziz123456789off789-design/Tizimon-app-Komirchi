import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'storage.dart';
export 'storage.dart';
part 'coal_store.dart';

String money(num value) => value.round().toString().replaceAllMapped(
  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
  (m) => '${m[1]} ',
);
String dateLabel(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
String timeLabel(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

class ShopStore extends ChangeNotifier {
  ShopStore(this.storage);
  final Storage storage;
  Json _data = emptyData();
  bool busy = false;
  static Json emptyData() => {
    'version': 1,
    'products': <Json>[],
    'customers': <Json>[],
    'sales': <Json>[],
    'entries': <Json>[],
  };
  List<Json> get products => (_data['products'] as List).cast<Json>();
  List<Json> get customers => (_data['customers'] as List).cast<Json>();
  List<Json> get sales => (_data['sales'] as List).cast<Json>();
  List<Json> get entries => (_data['entries'] as List).cast<Json>();
  int get cash => entries
      .where((e) => e['method'] == 'Naqd')
      .fold(0, (s, e) => s + (e['amount'] as int));
  int get card => entries
      .where((e) => e['method'] == 'Karta')
      .fold(0, (s, e) => s + (e['amount'] as int));
  int get debt => customers.fold(0, (s, e) => s + (e['debt'] as int));
  List<Json> get todaySales => sales
      .where(
        (s) =>
            dateLabel(DateTime.parse(s['date'])) == dateLabel(DateTime.now()),
      )
      .toList();
  String id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> load() async {
    final data = await storage.read();
    if (data != null) {
      if (data['version'] != 1 ||
          ![
            'products',
            'customers',
            'sales',
            'entries',
          ].every((k) => data[k] is List)) {
        throw const FormatException('Ma’lumot formati noto‘g‘ri');
      }
      _data = data;
    }
    notifyListeners();
  }

  Future<void> _commit(void Function(Json) change) async {
    if (busy) throw StateError('Oldingi amal tugashini kuting.');
    busy = true;
    notifyListeners();
    try {
      final next = jsonDecode(jsonEncode(_data)) as Json;
      change(next);
      await storage.write(next);
      _data = next;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> saveProduct({
    String? productId,
    required String name,
    required String category,
    required String barcode,
    required int price,
    required int cost,
    required int stock,
    required int minimum,
  }) => _commit((d) {
    if (name.trim().isEmpty ||
        price <= 0 ||
        cost < 0 ||
        stock < 0 ||
        minimum < 0) {
      throw StateError('Mahsulot ma’lumotlarini tekshiring.');
    }
    final items = (d['products'] as List).cast<Json>();
    if (barcode.isNotEmpty &&
        items.any((p) => p['barcode'] == barcode && p['id'] != productId)) {
      throw StateError('Bu shtrix-kod boshqa mahsulotga tegishli.');
    }
    final product = <String, dynamic>{
      'id': productId ?? id(),
      'name': name.trim(),
      'category': category,
      'barcode': barcode,
      'price': price,
      'cost': cost,
      'stock': stock,
      'minimum': minimum,
    };
    final index = items.indexWhere((p) => p['id'] == productId);
    if (index < 0) {
      items.add(product);
    } else {
      items[index] = product;
    }
  });

  Future<void> addStock(String productId, int quantity) => _commit((d) {
    if (quantity <= 0) throw StateError('Miqdor noldan katta bo‘lsin.');
    final p = (d['products'] as List).cast<Json>().firstWhere(
      (p) => p['id'] == productId,
    );
    p['stock'] = (p['stock'] as int) + quantity;
  });

  Future<void> addCustomer(String name, String phone) => _commit((d) {
    if (name.trim().isEmpty) throw StateError('Mijoz ismini kiriting.');
    (d['customers'] as List).add({
      'id': id(),
      'name': name.trim(),
      'phone': phone.trim(),
      'debt': 0,
    });
  });

  Future<void> cashEntry(int amount, String note, String method) =>
      _commit((d) {
        if (amount == 0 ||
            note.trim().isEmpty ||
            !['Naqd', 'Karta'].contains(method)) {
          throw StateError('Summa va izohni tekshiring.');
        }
        final balance = method == 'Naqd' ? cash : card;
        if (amount < 0 && balance + amount < 0) {
          throw StateError('Hisobda yetarli mablag‘ yo‘q.');
        }
        (d['entries'] as List).add({
          'id': id(),
          'date': DateTime.now().toIso8601String(),
          'amount': amount,
          'note': note.trim(),
          'method': method,
        });
      });

  Future<void> repay(String customerId, int amount, String method) =>
      _commit((d) {
        final c = (d['customers'] as List).cast<Json>().firstWhere(
          (c) => c['id'] == customerId,
        );
        if (amount <= 0 ||
            amount > c['debt'] ||
            !['Naqd', 'Karta'].contains(method)) {
          throw StateError('To‘lov qarzdan oshmasligi kerak.');
        }
        c['debt'] = (c['debt'] as int) - amount;
        (d['entries'] as List).add({
          'id': id(),
          'date': DateTime.now().toIso8601String(),
          'amount': amount,
          'note': '${c['name']} — qarz to‘lovi',
          'method': method,
        });
      });

  Future<Json> checkout(
    Map<String, int> cart,
    String method,
    String? customerId,
    int discount,
  ) async {
    late Json receipt;
    await _commit((d) {
      if (cart.isEmpty) throw StateError('Savat bo‘sh.');
      if (!['Naqd', 'Karta', 'Nasiya'].contains(method)) {
        throw StateError('To‘lov turini tanlang.');
      }
      final people = (d['customers'] as List).cast<Json>();
      final customer = customerId == null
          ? null
          : people.firstWhere((c) => c['id'] == customerId);
      if (method == 'Nasiya' && customer == null) {
        throw StateError('Nasiya uchun mijozni tanlang.');
      }
      final lines = <Json>[];
      var total = 0;
      for (final item in cart.entries) {
        final p = (d['products'] as List).cast<Json>().firstWhere(
          (p) => p['id'] == item.key,
        );
        if (item.value <= 0 || item.value > p['stock']) {
          throw StateError('${p['name']}: omborda yetarli mahsulot yo‘q.');
        }
        total += (p['price'] as int) * item.value;
        p['stock'] = (p['stock'] as int) - item.value;
        lines.add({
          'name': p['name'],
          'price': p['price'],
          'quantity': item.value,
        });
      }
      if (discount < 0 || discount >= total) {
        throw StateError('Chegirma jami summadan kichik bo‘lsin.');
      }
      total -= discount;
      final saleId = id();
      receipt = {
        'id': saleId,
        'number': (d['sales'] as List).length + 1,
        'date': DateTime.now().toIso8601String(),
        'lines': lines,
        'total': total,
        'discount': discount,
        'method': method,
        'customer': customer?['name'] ?? 'Oddiy xaridor',
        'customerId': customerId,
      };
      (d['sales'] as List).add(receipt);
      if (method == 'Nasiya') {
        customer!['debt'] = (customer['debt'] as int) + total;
      } else {
        (d['entries'] as List).add({
          'id': saleId,
          'date': receipt['date'],
          'amount': total,
          'note': 'Sotuv #${receipt['number']}',
          'method': method,
        });
      }
    });
    return receipt;
  }

  Future<void> seedDemo() => _commit((d) {
    if (products.isNotEmpty ||
        customers.isNotEmpty ||
        sales.isNotEmpty ||
        entries.isNotEmpty) {
      throw StateError('Namuna faqat bo‘sh do‘konga qo‘shiladi.');
    }
    final sample = [
      ['Oliy navli un', 'Oziq-ovqat', 18000, 14000, 48, 10],
      ['Lazer guruch', 'Oziq-ovqat', 24000, 19000, 32, 8],
      ['Kungaboqar yog‘i', 'Oziq-ovqat', 22000, 18000, 24, 5],
      ['Shakar · 1 kg', 'Oziq-ovqat', 14000, 11000, 6, 10],
      ['Coca-Cola · 1.5 l', 'Ichimliklar', 14000, 10000, 36, 8],
      ['Suv · 1 l', 'Ichimliklar', 4000, 2500, 60, 12],
      ['Ko‘k choy · 100 g', 'Oziq-ovqat', 12000, 9000, 18, 5],
      ['Sut · 1 l', 'Sut mahsulotlari', 12000, 9500, 4, 6],
      ['Qaymoq · 200 g', 'Sut mahsulotlari', 18000, 14000, 12, 4],
      ['Kir sovun', 'Uy-ro‘zg‘or', 7000, 4500, 20, 5],
    ];
    d['products'] = List.generate(
      sample.length,
      (i) => {
        'id': 'demo-$i',
        'name': sample[i][0],
        'category': sample[i][1],
        'price': sample[i][2],
        'cost': sample[i][3],
        'stock': sample[i][4],
        'minimum': sample[i][5],
        'barcode': '478000000${i.toString().padLeft(4, '0')}',
      },
    );
    d['customers'] = [
      {
        'id': 'customer-1',
        'name': 'Azizbek Karimov',
        'phone': '+998 90 123 45 67',
        'debt': 0,
      },
      {
        'id': 'customer-2',
        'name': 'Malika Sobirova',
        'phone': '+998 91 765 43 21',
        'debt': 0,
      },
    ];
  });
}
