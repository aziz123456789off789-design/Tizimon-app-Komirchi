part of 'store.dart';

extension CoalStore on ShopStore {
  List<Json> get coal => products
      .where(
        (p) => p['coal'] == true || !(p['id'] as String).startsWith('demo-'),
      )
      .toList();
  List<String> get groups => {
    ...((_data['groups'] as List?) ?? []).cast<String>(),
    ...coal.map((p) => p['category'] as String),
  }.toList();
  Future<void> saveCoal(String name, String group, [String? productId]) =>
      _commit((d) {
        name = name.trim();
        group = group.trim();
        if (name.isEmpty || group.isEmpty)
          throw StateError('Nom va kategoriyani kiriting.');
        final list = d['products'] as List;
        final existing = list.indexWhere((p) => p['id'] == productId);
        final item = {
          'id': productId ?? id(),
          'name': name,
          'category': group,
          'coal': true,
        };
        if (existing < 0) {
          list.add(item);
        } else {
          list[existing] = item;
        }
        d['groups'] = {...groups, group}.toList();
      });
  Future<Json> sellCoal(
    Json product,
    double quantity,
    String unit,
    int price,
    String method,
    String name,
    String phone, {
    String? customerId,
  }) async {
    late Json receipt;
    await _commit((d) {
      phone = phone.replaceAll(RegExp(r'[\s()\-]'), '');
      if (phone.length == 9 && !phone.startsWith('+')) phone = '+998$phone';
      if (phone.length == 12 && phone.startsWith('998')) phone = '+$phone';
      if (phone.isNotEmpty && !RegExp(r'^\+?\d{7,15}$').hasMatch(phone))
        throw StateError('Telefon raqamini tekshiring.');
      if (!quantity.isFinite ||
          quantity <= 0 ||
          price <= 0 ||
          !['kg', 'tonna'].contains(unit) ||
          !['Naqd', 'Karta', 'Qarz'].contains(method))
        throw StateError('Miqdor va narxni tekshiring.');
      final total = (quantity * price).round();
      if (total <= 0) throw StateError('Jami summa musbat bo‘lishi kerak.');
      if (method == 'Qarz' && (name.trim().isEmpty || phone.isEmpty))
        throw StateError('Qarz uchun mijoz ismi va telefoni kerak.');
      final people = (d['customers'] as List).cast<Json>();
      Json? customer;
      if (phone.isNotEmpty || name.trim().isNotEmpty) {
        customer = customerId != null
            ? people.firstWhere((c) => c['id'] == customerId)
            : people
                  .where(
                    (c) =>
                        phone.isNotEmpty &&
                        (c['phone'] as String).replaceAll(
                              RegExp(r'[\s()\-]'),
                              '',
                            ) ==
                            phone,
                  )
                  .firstOrNull;
        if (customer == null) {
          customer = {
            'id': id(),
            'name': name.trim().isEmpty ? phone : name.trim(),
            'phone': phone,
            'debt': 0,
          };
          people.add(customer);
        } else if (customerId != null && phone.isNotEmpty) {
          customer['phone'] = phone;
        }
      }
      final when = DateTime.now().toIso8601String();
      receipt = {
        'id': id(),
        'number': (d['sales'] as List).length + 1,
        'date': when,
        'customer': customer?['name'] ?? 'Oddiy xaridor',
        'customerId': customer?['id'],
        'phone': phone,
        'method': method,
        'total': total,
        'discount': 0,
        'lines': [
          {
            'name': product['name'],
            'quantity': quantity,
            'unit': unit,
            'price': price,
          },
        ],
      };
      (d['sales'] as List).add(receipt);
      if (method == 'Qarz') {
        customer!['debt'] = (customer['debt'] as int) + total;
      } else {
        (d['entries'] as List).add({
          'id': receipt['id'],
          'date': when,
          'amount': total,
          'note': 'Sotuv #${receipt['number']}',
          'method': method,
        });
      }
    });
    return receipt;
  }
}
