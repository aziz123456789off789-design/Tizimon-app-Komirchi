// Keep compatibility with Flutter 3.35+, before the Material package split.
// ignore: deprecated_member_use
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'store.dart';
part 'coal_screen.dart';

const ink = Color(0xFF1C1C1E);
const green = Color(0xFF007AFF);
const muted = Color(0xFF8E8E93);
const canvas = Color(0xFFF2F2F7);
const line = Color(0xFFE5E5EA);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final store = ShopStore(await openStorage());
    await store.load();
    runApp(ShopApp(store: store));
  } catch (_) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder_off_outlined, size: 48),
                  const SizedBox(height: 20),
                  const Text(
                    'Ma’lumotlarni ochib bo‘lmadi. Fayllaringiz saqlanib qolgan. Ilovani qayta ochib ko‘ring.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: main,
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key, required this.store});
  final ShopStore store;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Tizimon',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        primary: green,
        surface: Colors.white,
      ),
      fontFamily: 'Segoe UI',
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: line),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 29,
          fontWeight: FontWeight.w700,
          color: ink,
          letterSpacing: -1,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: ink),
        bodySmall: TextStyle(fontSize: 12, color: muted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: canvas,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          side: const BorderSide(color: line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: line, space: 1),
    ),
    home: ShopHome(store: store),
  );
}

class ShopHome extends StatefulWidget {
  const ShopHome({super.key, required this.store});
  final ShopStore store;
  @override
  State<ShopHome> createState() => _ShopHomeState();
}

class _ShopHomeState extends State<ShopHome> with CoalScreens {
  ShopStore get store => widget.store;
  int page = 0;
  String query = '';
  final search = TextEditingController();
  @override
  void initState() {
    super.initState();
    store.addListener(refresh);
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    store.removeListener(refresh);
    search.dispose();

    super.dispose();
  }

  void navigate(int value) => setState(() {
    page = value;
    query = '';
    search.clear();
  });
  void notice(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );
  Future<bool> act(Future<void> Function() action, [String? message]) async {
    try {
      await action();
      if (mounted && message != null) notice(message);
      return true;
    } on StateError catch (e) {
      if (mounted) notice(e.message);
    } catch (_) {
      if (mounted) notice('Saqlab bo‘lmadi. Qayta urinib ko‘ring.');
    }
    return false;
  }

  Widget searchField(String hint) => TextField(
    controller: search,
    onChanged: (s) => setState(() => query = s),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: muted),
      prefixIcon: const Icon(Icons.search, size: 22, color: muted),
      suffixIcon: query.isEmpty
          ? null
          : IconButton(
              onPressed: () => setState(() {
                search.clear();
                query = '';
              }),
              icon: const Icon(Icons.close, size: 18),
            ),
    ),
  );
  Widget metric(String title, String value, IconData icon, Color color) =>
      panel(
        Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: muted, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 9),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
        ),
      );
  Widget panel(Widget child) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: line),
    ),
    child: child,
  );
  Widget badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );
  Widget empty(String title, String description, IconData icon) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: canvas,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: muted),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: muted, height: 1.5),
          ),
        ],
      ),
    ),
  );
  Widget stats(List<Widget> items) => LayoutBuilder(
    builder: (context, c) => c.maxWidth < 650
        ? SizedBox(
            height: 105,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: items
                  .map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(width: 230, child: w),
                    ),
                  )
                  .toList(),
            ),
          )
        : Row(
            children: items
                .map(
                  (w) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: w == items.last ? 0 : 12),
                      child: w,
                    ),
                  ),
                )
                .toList(),
          ),
  );

  Widget cashPage() => Column(
    children: [
      stats([
        metric(
          'Naqd pul',
          '${money(store.cash)} so‘m',
          Icons.payments_outlined,
          green,
        ),
        metric(
          'Karta hisobi',
          '${money(store.card)} so‘m',
          Icons.credit_card,
          const Color(0xFF688CB5),
        ),
        metric(
          'Mijozlar qarzi',
          '${money(store.debt)} so‘m',
          Icons.schedule,
          const Color(0xFFC68B34),
        ),
      ]),
      const SizedBox(height: 20),
      Row(
        children: [
          const Expanded(
            child: Text(
              'Pul harakati',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => cashDialog(false),
            icon: const Icon(Icons.north_east, size: 16),
            label: const Text('Chiqim'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => cashDialog(true),
            icon: const Icon(Icons.south_west, size: 16),
            label: const Text('Kirim'),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Expanded(
        child: store.entries.isEmpty
            ? empty(
                'Hozircha pul harakati yo‘q',
                'Sotuvlar va kassa amallari shu yerda ko‘rinadi.',
                Icons.account_balance_wallet_outlined,
              )
            : panel(
                ListView.separated(
                  itemCount: store.entries.length,
                  separatorBuilder: (_, i) => const Divider(),
                  itemBuilder: (_, i) {
                    final e = store.entries.reversed.elementAt(i);
                    final positive = e['amount'] > 0;
                    final date = DateTime.parse(e['date']);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: positive
                            ? const Color(0xFFE9EEFF)
                            : const Color(0xFFFBEFE9),
                        child: Icon(
                          positive ? Icons.south_west : Icons.north_east,
                          color: positive ? green : Colors.deepOrange,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        e['note'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        '${dateLabel(date)} · ${timeLabel(date)} · ${e['method']}',
                        style: const TextStyle(fontSize: 11, color: muted),
                      ),
                      trailing: Text(
                        '${positive ? '+' : '−'}${money((e['amount'] as int).abs())}\nso‘m',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: positive ? green : Colors.deepOrange,
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    ],
  );

  Widget customersPage() {
    final people = store.customers
        .where(
          (c) => '${c['name']} ${c['phone']}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    return Column(
      children: [
        stats([
          metric(
            'Jami mijozlar',
            '${store.customers.length} ta',
            Icons.people_outline,
            green,
          ),
          metric(
            'Qarzdor mijozlar',
            '${store.customers.where((c) => c['debt'] > 0).length} ta',
            Icons.person_outline,
            const Color(0xFF688CB5),
          ),
          metric(
            'Jami qarzdorlik',
            '${money(store.debt)} so‘m',
            Icons.schedule,
            const Color(0xFFC68B34),
          ),
        ]),
        const SizedBox(height: 18),
        searchField('Ism yoki telefon orqali qidirish'),
        const SizedBox(height: 16),
        Expanded(
          child: people.isEmpty
              ? empty(
                  'Mijozlar topilmadi',
                  'Yuqoridagi + tugmasi orqali mijoz qo‘shing.',
                  Icons.people_outline,
                )
              : panel(
                  ListView.separated(
                    itemCount: people.length,
                    separatorBuilder: (_, i) => const Divider(),
                    itemBuilder: (_, i) {
                      final c = people[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE9EEFF),
                          child: Text(
                            (c['name'] as String).substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(
                          c['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          c['phone'].isEmpty
                              ? 'Telefon kiritilmagan'
                              : c['phone'],
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                        trailing: c['debt'] > 0
                            ? TextButton(
                                onPressed: () => repaymentDialog(c),
                                child: Text(
                                  '${money(c['debt'])} so‘m\nQarzni to‘lash',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFB87830),
                                  ),
                                ),
                              )
                            : badge('Qarz yo‘q', green),
                        onTap: () => customerDetails(c),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> formDialog(
    String title,
    List<Widget> fields,
    Future<void> Function() save,
  ) async {
    final form = GlobalKey<FormState>();
    bool saving = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, update) => PopScope(
          canPop: !saving,
          child: AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 420,
              child: Form(
                key: form,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: fields
                        .map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: w,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Bekor qilish'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!form.currentState!.validate()) return;
                        update(() => saving = true);
                        final ok = await act(save);
                        if (!dialogContext.mounted) return;
                        if (ok) {
                          Navigator.pop(dialogContext);
                        } else {
                          update(() => saving = false);
                        }
                      },
                child: Text(saving ? 'Saqlanmoqda...' : 'Saqlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget field(
    TextEditingController controller,
    String label, {
    bool numeric = false,
    bool optional = false,
    bool positive = false,
  }) => TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    keyboardType: numeric ? TextInputType.number : TextInputType.text,
    inputFormatters: numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
    validator: (v) {
      if (v == null || v.trim().isEmpty) {
        return optional ? null : 'Maydonni to‘ldiring';
      }
      if (numeric &&
          (int.tryParse(v) == null || int.parse(v) < (positive ? 1 : 0))) {
        return 'To‘g‘ri miqdor kiriting';
      }
      return null;
    },
  );

  Future<void> customerDialog() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    await formDialog('Yangi mijoz', [
      field(name, 'Ism va familiya'),
      field(phone, 'Telefon raqami (ixtiyoriy)', optional: true),
    ], () => store.addCustomer(name.text, phone.text));
    await Future<void>.delayed(const Duration(milliseconds: 350));
    name.dispose();
    phone.dispose();
  }

  Future<void> cashDialog(bool income) async {
    final amount = TextEditingController();
    final note = TextEditingController();
    var method = 'Naqd';
    await formDialog(
      income ? 'Kassaga kirim' : 'Kassadan chiqim',
      [
        field(amount, 'Summa, so‘m', numeric: true, positive: true),
        field(note, 'Izoh'),
        methodField((v) => method = v),
      ],
      () => store.cashEntry(
        int.parse(amount.text) * (income ? 1 : -1),
        note.text,
        method,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
    amount.dispose();
    note.dispose();
  }

  Widget methodField(ValueChanged<String> onChanged) =>
      DropdownButtonFormField<String>(
        initialValue: 'Naqd',
        decoration: const InputDecoration(labelText: 'To‘lov turi'),
        items: [
          'Naqd',
          'Karta',
        ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: (v) => onChanged(v!),
      );
  Future<void> repaymentDialog(Json c) async {
    final amount = TextEditingController(text: c['debt'].toString());
    var method = 'Naqd';
    await formDialog('Qarzni qabul qilish', [
      Text('${c['name']}\nQarz: ${money(c['debt'])} so‘m'),
      field(amount, 'To‘lov, so‘m', numeric: true, positive: true),
      methodField((v) => method = v),
    ], () => store.repay(c['id'], int.parse(amount.text), method));
    await Future<void>.delayed(const Duration(milliseconds: 350));
    amount.dispose();
  }

  void customerDetails(Json c) {
    final sales = store.sales.where((s) => s['customerId'] == c['id']).toList();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(c['name']),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Telefon: ${c['phone']}'),
                const SizedBox(height: 10),
                Text('Qarz: ${money(c['debt'])} so‘m'),
                const SizedBox(height: 20),
                const Text(
                  'Xaridlar tarixi',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                if (sales.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Hozircha xaridlar yo‘q.'),
                  ),
                ...sales.reversed.map(
                  (s) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Chek #${s['number']} · ${money(s['total'])} so‘m',
                    ),
                    subtitle: Text(
                      '${dateLabel(DateTime.parse(s['date']))} · ${s['method']}',
                    ),
                    onTap: () => showReceipt(s),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void history() => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Sotuvlar tarixi'),
      content: SizedBox(
        width: 500,
        height: 420,
        child: store.sales.isEmpty
            ? empty(
                'Sotuvlar hali yo‘q',
                'Yakunlangan savdolar shu yerda saqlanadi.',
                Icons.receipt_long_outlined,
              )
            : ListView.separated(
                itemCount: store.sales.length,
                separatorBuilder: (_, i) => const Divider(),
                itemBuilder: (_, i) {
                  final s = store.sales.reversed.elementAt(i);
                  return ListTile(
                    title: Text(
                      'Chek #${s['number']} · ${money(s['total'])} so‘m',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${dateLabel(DateTime.parse(s['date']))} · ${timeLabel(DateTime.parse(s['date']))}\n${s['customer']} · ${s['method']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showReceipt(s),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Yopish'),
        ),
      ],
    ),
  );
  void showReceipt(Json s) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: green),
          const SizedBox(width: 10),
          Text('Chek #${s['number']}'),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: SelectableText(
            coalReceipt(s),
            style: const TextStyle(height: 1.8, fontSize: 14),
          ),
        ),
      ),
      actions: [
        if ((s['phone'] ?? '').isNotEmpty)
          TextButton(
            onPressed: () => compose(s),
            child: const Text('SMS yuborish'),
          ),
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: coalReceipt(s)));
            if (mounted) notice('Chek nusxalandi.');
          },
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Nusxalash'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Tayyor'),
        ),
      ],
    ),
  );
}
