part of 'main.dart';

mixin CoalScreens on State<ShopHome> {
  ShopStore get store;
  int get page;
  String get query;
  Widget searchField(String hint);
  void notice(String text);
  void history();
  void showReceipt(Json receipt);
  Widget cashPage();
  Widget customersPage();
  Future<void> customerDialog();
  void navigate(int page);
  static const names = ['Hisobotlar', 'Sotuv', 'Ombor', 'Kassa', 'Mijozlar'];
  static const symbols = [
    Icons.insights,
    Icons.point_of_sale,
    Icons.warehouse_outlined,
    Icons.wallet_outlined,
    Icons.people_outline,
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 72,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/tizimon.png', width: 48, height: 48),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tizimon',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.8,
                  color: ink,
                ),
              ),
              Text(
                'Xo‘jalar ko‘mir ombori',
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Sotuvlar tarixi',
          onPressed: history,
          icon: const Icon(Icons.history),
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  names[page],
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: switch (page) {
                    0 => reports(),
                    1 || 2 => catalog(),
                    3 => cashPage(),
                    _ => customersPage(),
                  },
                ),
                if (page == 2 || page == 4)
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    onPressed: page == 2 ? () => editCoal() : customerDialog,
                    label: Text(
                      page == 2 ? 'Mahsulot qo‘shish' : 'Mijoz qo‘shish',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE2E9FF),
      selectedIndex: page,
      onDestinationSelected: navigate,
      destinations: List.generate(
        5,
        (i) => NavigationDestination(icon: Icon(symbols[i]), label: names[i]),
      ),
    ),
  );
  Widget reports() {
    final now = DateTime.now();
    int sum(bool Function(DateTime) matches) => store.sales
        .where((s) => matches(DateTime.parse(s['date']).toLocal()))
        .fold(0, (n, s) => n + (s['total'] as int));
    final amounts = [
      sum((_) => true),
      sum((d) => d.year == now.year && d.month == now.month),
      sum((d) => d.year == now.year),
    ];
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF203781), green],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white70,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Umumiy savdo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '${money(amounts.first)} so‘m',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 1; i < 3; i++)
          Card(
            color: i == 0 ? green : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFEBEFFF),
                    child: Icon(
                      i == 1 ? Icons.calendar_month_outlined : Icons.date_range,
                      color: green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ['Umumiy savdo', 'Oylik savdo', 'Yillik savdo'][i],
                          style: TextStyle(
                            color: i == 0 ? Colors.white70 : muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${money(amounts[i])} so‘m',
                          style: TextStyle(
                            color: i == 0 ? Colors.white : ink,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: history,
          icon: const Icon(Icons.receipt_long),
          label: const Text('Sotuvlar tarixi'),
        ),
      ],
    );
  }

  Widget catalog() {
    final products = store.coal
        .where(
          (p) => '${p['name']} ${p['category']}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    return Column(
      children: [
        searchField('Ko‘mir nomi yoki kategoriya'),
        const SizedBox(height: 12),
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundColor: Color(0xFFE5EBFF),
                        child: Icon(
                          Icons.terrain_outlined,
                          color: green,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        query.isEmpty
                            ? 'Ko‘mir katalogi bo‘sh'
                            : 'Mahsulot topilmadi',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () => editCoal(),
                        child: const Text('Ko‘mir turini qo‘shish'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.terrain)),
                        title: Text(p['name']),
                        subtitle: Text(p['category']),
                        trailing: Icon(
                          page == 2 ? Icons.edit_outlined : Icons.chevron_right,
                        ),
                        onTap: () => page == 2 ? editCoal(p) : saleForm(p),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> editCoal([Json? product]) async {
    var name = product?['name'] as String? ?? '';
    String? group = product?['category'];
    var newGroup = '';
    var creating = store.groups.isEmpty;
    await editor(
      product == null ? 'Yangi ko‘mir turi' : 'Ko‘mir turini tahrirlash',
      Icons.terrain,
      (update) => [
        input('Mahsulot nomi', (v) => name = v, initial: name),
        if (!creating)
          DropdownButtonFormField<String>(
            initialValue: group,
            decoration: const InputDecoration(labelText: 'Kategoriya'),
            items: store.groups
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => update(() => group = v),
          ),
        if (creating) input('Yangi kategoriya nomi', (v) => newGroup = v),
        if (store.groups.isNotEmpty)
          TextButton.icon(
            onPressed: () => update(() => creating = !creating),
            icon: const Icon(Icons.category_outlined),
            label: Text(
              creating
                  ? 'Saqlangan kategoriyalardan tanlash'
                  : 'Yangi kategoriya yaratish',
            ),
          ),
      ],
      (sms) async {
        await store.saveCoal(
          name,
          creating ? newGroup : group ?? '',
          product?['id'],
        );
      },
    );
  }

  Widget input(
    String label,
    ValueChanged<String> change, {
    String initial = '',
    TextInputType? keyboard,
  }) => TextFormField(
    key: ValueKey(label),
    initialValue: initial,
    onChanged: change,
    keyboardType: keyboard,
    decoration: InputDecoration(labelText: label),
  );
  Future<void> editor(
    String title,
    IconData icon,
    List<Widget> Function(StateSetter) fields,
    Future<void> Function(bool) save, {
    bool sms = false,
  }) async {
    var saving = false;
    String? error;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) {
          Future<void> submit(bool message) async {
            if (saving) return;
            update(() => saving = true);
            try {
              await save(message);
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (e) {
              if (ctx.mounted)
                update(() {
                  error = e is StateError
                      ? e.message
                      : 'Saqlashda xatolik yuz berdi.';
                  saving = false;
                });
            }
          }

          return PopScope(
            canPop: !saving,
            child: AlertDialog(
              icon: Icon(icon, color: green),
              title: Text(title),
              scrollable: true,
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final w in fields(update))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: w,
                      ),
                    if (error != null)
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton(
                          onPressed: saving ? null : () => submit(false),
                          child: const Text('Saqlash'),
                        ),
                        if (sms)
                          OutlinedButton(
                            onPressed: saving ? null : () => submit(true),
                            child: const Text('Saqlash va xabar yuborish'),
                          ),
                      ],
                    ),
                    TextButton(
                      onPressed: saving ? null : () => Navigator.pop(ctx),
                      child: const Text('Bekor qilish'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> saleForm(Json product) async {
    var quantity = '',
        price = '',
        unit = 'kg',
        method = 'Naqd',
        name = '',
        phone = '';
    Json? receipt;
    String? customerId;
    var send = false;
    await editor(
      product['name'],
      Icons.point_of_sale,
      (update) => [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'kg', label: Text('Kilogramm')),
            ButtonSegment(value: 'tonna', label: Text('Tonna')),
          ],
          selected: {unit},
          onSelectionChanged: (v) => update(() => unit = v.first),
        ),
        input(
          'Miqdor',
          (v) => update(() => quantity = v),
          keyboard: const TextInputType.numberWithOptions(decimal: true),
        ),
        TextFormField(
          onChanged: (v) => update(() => price = v),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: '1 $unit narxi, so‘m'),
        ),
        Text(
          'Jami: ${money((double.tryParse(quantity.replaceAll(',', '.')) ?? 0) * (int.tryParse(price) ?? 0))} so‘m',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        DropdownButtonFormField<String>(
          initialValue: method,
          decoration: const InputDecoration(labelText: 'To‘lov usuli'),
          items: [
            'Naqd',
            'Karta',
            'Qarz',
          ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (m) => update(() => method = m!),
        ),
        _CustomerFields(
          customers: store.customers,
          changed: (id, currentName, number) {
            customerId = id;
            name = currentName;
            phone = number;
          },
        ),
      ],
      (message) async {
        if (message && phone.trim().isEmpty)
          throw StateError('SMS uchun telefon raqamini kiriting.');
        receipt = await store.sellCoal(
          product,
          double.tryParse(quantity.replaceAll(',', '.')) ?? 0,
          unit,
          int.tryParse(price) ?? 0,
          method,
          name,
          phone,
          customerId: customerId,
        );
        send = message;
      },
      sms: true,
    );
    if (receipt == null || !mounted) return;
    if (send) await compose(receipt!);
    if (mounted) showReceipt(receipt!);
  }

  Future<void> compose(Json sale) async {
    try {
      await const MethodChannel('uz.dokon/sms').invokeMethod('compose', {
        'phone': sale['phone'],
        'body': coalReceipt(sale),
      });
    } catch (_) {
      if (mounted)
        notice(
          'Savdo saqlandi. SMS oynasi ochilmadi. Chekdan qayta urinishingiz mumkin.',
        );
    }
  }
}

class _CustomerFields extends StatefulWidget {
  const _CustomerFields({required this.customers, required this.changed});
  final List<Json> customers;
  final void Function(String?, String, String) changed;
  @override
  State<_CustomerFields> createState() => _CustomerFieldsState();
}

class _CustomerFieldsState extends State<_CustomerFields> {
  final name = TextEditingController();
  final phone = TextEditingController();
  String? selected;
  void publish() => widget.changed(selected, name.text, phone.text);
  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefix = name.text.trim().toLowerCase();
    final matches = widget.customers
        .where((c) => (c['name'] as String).toLowerCase().startsWith(prefix))
        .toList();
    return Column(
      children: [
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Mijoz ismi'),
          onChanged: (_) {
            setState(() {
              if (selected != null) phone.clear();
              selected = null;
            });
            publish();
          },
        ),
        if (selected == null && prefix.isNotEmpty && matches.isNotEmpty)
          SizedBox(
            height: matches.length < 3 ? matches.length * 76.0 : 180,
            child: ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: matches.length,
              itemBuilder: (_, i) {
                final c = matches[i];
                return ListTile(
                  title: Text(c['name']),
                  subtitle: Text(c['phone']),
                  onTap: () {
                    setState(() {
                      selected = c['id'];
                      name.text = c['name'];
                      phone.text = c['phone'];
                    });
                    publish();
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Telefon raqami'),
          onChanged: (_) => publish(),
        ),
      ],
    );
  }
}

String coalReceipt(Json s) {
  final how = switch (s['method']) {
    'Qarz' || 'Nasiya' => 'qarzga',
    'Karta' => 'karta orqali',
    _ => 'naqd pulga',
  };
  final date = DateTime.parse(s['date']);
  return 'Assalomu alaykum, hurmatli mijoz! Siz Xo‘jalar ko‘mir omboridan $how mahsulot oldingiz.\nChek #${s['number']} · ${dateLabel(date)} ${timeLabel(date)}\nMijoz: ${s['customer']}\n${(s['lines'] as List).map((l) => "${l['name']}: ${l['quantity']} ${l['unit'] ?? 'dona'} × ${money(l['price'])} so‘m").join('\n')}\nJami: ${money(s['total'])} so‘m\nTo‘lov: ${s['method']}';
}
