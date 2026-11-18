// Keep compatibility with Flutter 3.35+, before the Material package split.
// ignore: deprecated_member_use
import 'dart:async';
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
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: line, width: 0.8),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: ink,
          letterSpacing: -0.4,
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
        fillColor: const Color(0xFFF2F2F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: green, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: green,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          side: const BorderSide(color: line, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: line, space: 1, thickness: 0.5),
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

  OverlayEntry? _hudEntry;

  @override
  void dispose() {
    if (_hudEntry?.mounted ?? false) {
      _hudEntry?.remove();
    }
    _hudEntry = null;
    store.removeListener(refresh);
    search.dispose();
    super.dispose();
  }

  @override
  void navigate(int value) => setState(() {
    page = value;
    query = '';
    search.clear();
  });

  @override
  void showCenterNotice(
    String message, {
    String? title,
    IconData? icon,
    Color? color,
  }) {
    if (_hudEntry?.mounted ?? false) {
      _hudEntry?.remove();
    }
    _hudEntry = null;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    _hudEntry = OverlayEntry(
      builder: (ctx) => CenterHud(
        message: message,
        title: title ?? 'SMS Yuborildi',
        icon: icon ?? Icons.mark_email_read_rounded,
        color: color ?? const Color(0xFF34C759),
        onDismiss: () {
          if (_hudEntry?.mounted ?? false) {
            _hudEntry?.remove();
          }
          _hudEntry = null;
        },
      ),
    );
    overlay.insert(_hudEntry!);
  }

  @override
  void notice(String text) {
    if (text.toLowerCase().contains('yuborildi') || text.toLowerCase().contains('sms')) {
      showCenterNotice(
        text,
        title: text.toLowerCase().contains('eslatma')
            ? 'SMS Eslatma Yuborildi'
            : (text.toLowerCase().contains('sms') ? 'SMS Yuborildi' : 'Muvaffaqiyatli'),
        icon: text.toLowerCase().contains('xato') || text.toLowerCase().contains('bo‘lmadi')
            ? Icons.error_outline_rounded
            : Icons.mark_email_read_rounded,
        color: text.toLowerCase().contains('xato') || text.toLowerCase().contains('bo‘lmadi')
            ? Colors.red
            : const Color(0xFF34C759),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

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
      hintStyle: const TextStyle(fontSize: 14, color: muted),
      fillColor: const Color(0xFFE5E5EA),
      filled: true,
      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: green, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      suffixIcon: query.isEmpty
          ? null
          : IconButton(
              onPressed: () => setState(() {
                search.clear();
                query = '';
              }),
              icon: const Icon(Icons.cancel_rounded, size: 18, color: muted),
            ),
    ),
  );

  Widget metric(String title, String value, IconData icon, Color color, [String? subValue]) =>
      panel(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: color == green ? ink : color,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    if (subValue != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subValue,
                        style: const TextStyle(fontSize: 11, color: muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
        ),
      );

  Widget panel(Widget child) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: line, width: 0.8),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );

  Widget badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );

  Widget empty(String title, String description, IconData icon) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: muted),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ink),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: muted, height: 1.4),
          ),
        ],
      ),
    ),
  );

  Widget stats(List<Widget> items) => LayoutBuilder(
    builder: (context, c) => c.maxWidth < 650
        ? SizedBox(
            height: 100,
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
          store.cash >= 1000000 ? formatMln(store.cash) : '${money(store.cash)} so‘m',
          Icons.payments_rounded,
          const Color(0xFF34C759),
          store.cash >= 1000000 ? '${money(store.cash)} so‘m' : null,
        ),
        metric(
          'Karta hisobi',
          store.card >= 1000000 ? formatMln(store.card) : '${money(store.card)} so‘m',
          Icons.credit_card_rounded,
          green,
          store.card >= 1000000 ? '${money(store.card)} so‘m' : null,
        ),
        metric(
          'Mijozlar qarzi',
          store.debt >= 1000000 ? formatMln(store.debt) : '${money(store.debt)} so‘m',
          Icons.schedule_rounded,
          const Color(0xFFFF9500),
          store.debt >= 1000000 ? '${money(store.debt)} so‘m' : null,
        ),
      ]),
      const SizedBox(height: 18),
      Row(
        children: [
          const Expanded(
            child: Text(
              'Pul harakati',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => cashDialog(false),
            icon: const Icon(Icons.arrow_upward_rounded, size: 16),
            label: const Text('Chiqim'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => cashDialog(true),
            icon: const Icon(Icons.arrow_downward_rounded, size: 16),
            label: const Text('Kirim'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
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
                        vertical: 6,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: positive
                              ? const Color(0xFFEBF9EE)
                              : const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          positive
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: positive
                              ? const Color(0xFF34C759)
                              : const Color(0xFFFF3B30),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        e['note'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: ink,
                        ),
                      ),
                      subtitle: Text(
                        '${dateLabel(date)} · ${timeLabel(date)} · ${e['method']}',
                        style: const TextStyle(fontSize: 12, color: muted),
                      ),
                      trailing: Text(
                        '${positive ? '+' : '−'}${money((e['amount'] as int).abs())}\nso‘m',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: positive
                              ? const Color(0xFF34C759)
                              : const Color(0xFFFF3B30),
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
            Icons.people_alt_rounded,
            green,
          ),
          metric(
            'Qarzdor mijozlar',
            '${store.customers.where((c) => c['debt'] > 0).length} ta',
            Icons.person_rounded,
            const Color(0xFFFF9500),
          ),
          metric(
            'Jami qarzdorlik',
            store.debt >= 1000000 ? formatMln(store.debt) : '${money(store.debt)} so‘m',
            Icons.schedule_rounded,
            const Color(0xFFFF3B30),
            store.debt >= 1000000 ? '${money(store.debt)} so‘m' : null,
          ),
        ]),
        const SizedBox(height: 16),
        searchField('Ism yoki telefon orqali qidirish'),
        const SizedBox(height: 14),
        Expanded(
          child: people.isEmpty
              ? empty(
                  'Mijozlar topilmadi',
                  'Pastdagi + tugmasi orqali mijoz qo‘shing.',
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
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF3FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            (c['name'] as String).substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: green,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        title: Text(
                          c['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: ink,
                          ),
                        ),
                        subtitle: Text(
                          c['phone'].isEmpty
                              ? 'Telefon kiritilmagan'
                              : c['phone'],
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                        trailing: c['debt'] > 0
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'SMS eslatma yuborish',
                                    icon: const Icon(Icons.sms_outlined, color: green, size: 22),
                                    onPressed: () => debtSmsDialog(c),
                                  ),
                                  TextButton(
                                    onPressed: () => debtOptionsDialog(c),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      backgroundColor: const Color(0xFFFFF4E5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: Text(
                                      c['debt'] >= 1000000
                                          ? '${formatMln(c['debt'])}\n${money(c['debt'])} so‘m'
                                          : '${money(c['debt'])} so‘m\nQarzni to‘lash',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFE65100),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  badge('Qarz yo‘q', const Color(0xFF34C759)),
                                  IconButton(
                                    tooltip: 'Mijozni o‘chirish',
                                    icon: const Icon(Icons.delete_outline_rounded, color: muted, size: 20),
                                    onPressed: () => confirmDeleteCustomer(c),
                                  ),
                                ],
                              ),
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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, update) => PopScope(
          canPop: !saving,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.9,
              maxWidth: 560,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(dialogContext).width > 600
                  ? (MediaQuery.sizeOf(dialogContext).width - 560) / 2
                  : 0,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.viewInsetsOf(dialogContext).bottom + 20,
            ),
            child: Form(
              key: form,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D1D6),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                        IconButton(
                          onPressed: saving ? null : () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close_rounded, color: muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...fields.map(
                      (w) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: w,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                      style: FilledButton.styleFrom(
                        backgroundColor: green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        saving ? 'Saqlanmoqda...' : 'Saqlash',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: saving ? null : () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        foregroundColor: muted,
                      ),
                      child: const Text('Bekor qilish'),
                    ),
                  ],
                ),
              ),
            ),
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
    decoration: InputDecoration(
      labelText: label,
      fillColor: const Color(0xFFF2F2F7),
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: line, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: green, width: 1.5),
      ),
    ),
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
        decoration: InputDecoration(
          labelText: 'To‘lov turi',
          fillColor: const Color(0xFFF2F2F7),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: line, width: 0.8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: green, width: 1.5),
          ),
        ),
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
      Text('${c['name']}\nQarz: ${money(c['debt'])} so‘m', style: const TextStyle(fontWeight: FontWeight.w600)),
      field(amount, 'To‘lov, so‘m', numeric: true, positive: true),
      methodField((v) => method = v),
      const SizedBox(height: 6),
      Center(
        child: TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            debtSmsDialog(c);
          },
          icon: const Icon(Icons.sms_outlined, size: 16),
          label: const Text('Qarz haqida SMS eslatma yuborish'),
          style: TextButton.styleFrom(foregroundColor: green),
        ),
      ),
    ], () => store.repay(c['id'], int.parse(amount.text), method));
    await Future<void>.delayed(const Duration(milliseconds: 350));
    amount.dispose();
  }

  Future<void> debtOptionsDialog(Json c) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(ctx).width > 600
              ? (MediaQuery.sizeOf(ctx).width - 560) / 2
              : 0,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['name'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Qarz: ${money(c['debt'])} so‘m',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFF9500)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: muted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Material(
              color: const Color(0xFFF2F8FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFCCE4FF)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sms_rounded, color: Colors.white, size: 20),
                ),
                title: const Text('SMS eslatma yuborish', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: ink)),
                subtitle: const Text('Qarz olingan sana va to‘lash so‘rovi bilan SMS yuborish', style: TextStyle(fontSize: 12, color: muted)),
                trailing: const Icon(Icons.chevron_right_rounded, color: muted),
                onTap: () {
                  Navigator.pop(ctx);
                  debtSmsDialog(c);
                },
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: const Color(0xFFF0FDF4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFBBF7D0)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.payments_rounded, color: Colors.white, size: 20),
                ),
                title: const Text('Qarzni to‘lash (To‘lov olish)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: ink)),
                subtitle: const Text('Mijoz to‘lagan summani qabul qilish va balansdan ayirish', style: TextStyle(fontSize: 12, color: muted)),
                trailing: const Icon(Icons.chevron_right_rounded, color: muted),
                onTap: () {
                  Navigator.pop(ctx);
                  repaymentDialog(c);
                },
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: const Color(0xFFFFF5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFFFD1D1)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                ),
                title: const Text('Mijozni o‘chirish', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFFFF3B30))),
                subtitle: const Text('Mijozni ro‘yxatdan butunlay o‘chirib tashlash', style: TextStyle(fontSize: 12, color: muted)),
                trailing: const Icon(Icons.chevron_right_rounded, color: muted),
                onTap: () {
                  Navigator.pop(ctx);
                  confirmDeleteCustomer(c);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> confirmDeleteCustomer(Json c, {bool fromDetails = false}) async {
    final debt = c['debt'] as int? ?? 0;
    final message = debt > 0
        ? '${c['name']} mijozida ${money(debt)} so‘m qarz mavjud.\n\nHaqiqatan ham bu mijozni o‘chirmoqchimisiz?'
        : 'Haqiqatan ham "${c['name']}" mijozini o‘chirmoqchimisiz?';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF3B30), size: 26),
            SizedBox(width: 10),
            Text('Mijozni o‘chirish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx, false),
            child: const Text('Bekor qilish', style: TextStyle(color: muted, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dlgCtx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('O‘chirish', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (fromDetails && mounted) {
        Navigator.pop(context);
      }
      await store.deleteCustomer(c['id']);
      if (mounted) {
        notice('${c['name']} muvaffaqiyatli o‘chirildi.');
      }
    }
  }

  Future<void> debtSmsDialog(Json c) async {
    final phoneCtrl = TextEditingController(text: c['phone'] ?? '');
    final bodyCtrl = TextEditingController(text: debtSmsText(c, store.sales));
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.9,
            maxWidth: 560,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(ctx).width > 600
                ? (MediaQuery.sizeOf(ctx).width - 560) / 2
                : 0,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.viewInsetsOf(ctx).bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D1D6),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F1FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sms_rounded, color: green, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Qarz haqida SMS eslatma',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: muted),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: canvas,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: line),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['name'],
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: ink),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Qarzdorlik miqdori:',
                              style: TextStyle(fontSize: 12, color: muted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${money(c['debt'])} so‘m',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF9500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mijoz telefon raqami',
                    hintText: '+998901234567',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    filled: true,
                    fillColor: canvas,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: green, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'SMS xabari matni',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: canvas,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: green, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () async {
                    var phone = phoneCtrl.text.trim();
                    if (phone.isEmpty) {
                      notice('Telefon raqamini kiriting.');
                      return;
                    }
                    if (phone.length == 9 && !phone.startsWith('+')) {
                      phone = '+998$phone';
                    }
                    Navigator.pop(ctx);
                    try {
                      final res = await const MethodChannel('uz.dokon/sms').invokeMethod<String>('compose', {
                        'phone': phone,
                        'body': bodyCtrl.text.trim(),
                      });
                      if (mounted && res == 'SENT_DIRECT') {
                        showCenterNotice(
                          'Mijozga to‘g‘ridan-to‘g‘ri yuborildi!',
                          title: 'SMS Eslatma Yuborildi',
                          icon: Icons.mark_email_read_rounded,
                          color: const Color(0xFF34C759),
                        );
                      } else if (mounted) {
                        showCenterNotice(
                          'SMS yuborish ilovasi ochildi.',
                          title: 'SMS Ilovasi',
                          icon: Icons.sms_rounded,
                          color: green,
                        );
                      }
                    } catch (_) {
                      if (mounted) notice('SMS eslatma yuborib bo‘lmadi.');
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'SMS eslatma yuborish',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: bodyCtrl.text.trim()));
                    if (mounted) notice('SMS matni nusxalandi.');
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('SMS matnini nusxalash'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    phoneCtrl.dispose();
    bodyCtrl.dispose();
  }

  void customerDetails(Json c) {
    final sales = store.sales.where((s) => s['customerId'] == c['id']).toList();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
          maxWidth: 560,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(ctx).width > 600
              ? (MediaQuery.sizeOf(ctx).width - 560) / 2
              : 0,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    c['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Mijozni o‘chirish',
                  onPressed: () => confirmDeleteCustomer(c, fromDetails: true),
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF3B30)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: muted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: canvas,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: line),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Telefon:', style: TextStyle(color: muted, fontSize: 13)),
                      Text(
                        c['phone'].isEmpty ? 'Kiritilmagan' : c['phone'],
                        style: const TextStyle(fontWeight: FontWeight.w600, color: ink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Qarz:', style: TextStyle(color: muted, fontSize: 13)),
                      Text(
                        c['debt'] >= 1000000
                            ? '${formatMln(c['debt'])} (${money(c['debt'])} so‘m)'
                            : '${money(c['debt'])} so‘m',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c['debt'] > 0 ? const Color(0xFFFF9500) : const Color(0xFF34C759),
                        ),
                      ),
                    ],
                  ),
                  if (c['debt'] > 0) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              debtSmsDialog(c);
                            },
                            icon: const Icon(Icons.sms_rounded, size: 16),
                            label: const Text('SMS eslatma', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE5F1FF),
                              foregroundColor: green,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              repaymentDialog(c);
                            },
                            icon: const Icon(Icons.payments_rounded, size: 16),
                            label: const Text('Qarzni to‘lash', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF34C759),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Xaridlar tarixi',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ink),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: sales.isEmpty
                  ? const Center(
                      child: Text('Hozircha xaridlar yo‘q.', style: TextStyle(color: muted)),
                    )
                  : ListView.separated(
                      itemCount: sales.length,
                      separatorBuilder: (_, i) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final s = sales.reversed.elementAt(i);
                        final date = DateTime.parse(s['date']);
                        final formattedDate =
                            '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                        final lines = (s['lines'] as List?) ?? [];
                        final productName = lines.isNotEmpty
                            ? '${lines.first['name']}${lines.first['quantity'] != null ? ' (${lines.first['quantity']} ${lines.first['unit'] ?? ''})' : ''}'
                            : 'Ko‘mir';
                        return Material(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: line),
                          ),
                          child: InkWell(
                            onTap: () => showReceipt(s),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productName,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: ink),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$formattedDate · ${s['method']}',
                                          style: const TextStyle(fontSize: 12, color: muted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${money(s['total'])} so‘m',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: green),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right_rounded, color: muted, size: 18),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => confirmDeleteCustomer(c, fromDetails: true),
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFF3B30)),
              label: const Text(
                'Mijozni o‘chirish',
                style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFFD1D1)),
                backgroundColor: const Color(0xFFFFF5F5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void history() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
        maxWidth: 560,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(ctx).width > 600
            ? (MediaQuery.sizeOf(ctx).width - 560) / 2
            : 0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sotuvlar tarixi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close_rounded, color: muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: store.sales.isEmpty
                ? empty(
                    'Sotuvlar hali yo‘q',
                    'Yakunlangan savdolar shu yerda saqlanadi.',
                    Icons.receipt_long_outlined,
                  )
                : ListView.separated(
                    itemCount: store.sales.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final s = store.sales.reversed.elementAt(i);
                      final date = DateTime.parse(s['date']);
                      final formattedDate =
                          '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                      final lines = (s['lines'] as List?) ?? [];
                      final productName = lines.isNotEmpty
                          ? '${lines.first['name']}${lines.first['quantity'] != null ? ' (${lines.first['quantity']} ${lines.first['unit'] ?? 'dona'})' : ''}'
                          : 'Ko‘mir mahsuloti';

                      return Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: line, width: 0.8),
                        ),
                        child: InkWell(
                          onTap: () => showReceipt(s),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        productName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: ink,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          s['total'] >= 1000000 ? formatMln(s['total']) : '${money(s['total'])} so‘m',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: green,
                                          ),
                                        ),
                                        if (s['total'] >= 1000000)
                                          Text(
                                            '${money(s['total'])} so‘m',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: muted,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person_rounded, size: 16, color: muted),
                                    const SizedBox(width: 6),
                                    Text(
                                      s['customer'] ?? 'Oddiy xaridor',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: ink,
                                      ),
                                    ),
                                    const Spacer(),
                                    badge(
                                      s['method'] ?? 'Naqd',
                                      s['method'] == 'Qarz'
                                          ? const Color(0xFFFF9500)
                                          : const Color(0xFF34C759),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Divider(height: 1),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time_rounded, size: 15, color: muted),
                                        const SizedBox(width: 5),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                            color: muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Chek #${s['number']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: muted,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.chevron_right_rounded, size: 18, color: muted),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );

  void showReceipt(Json s) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
        maxWidth: 560,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(ctx).width > 600
            ? (MediaQuery.sizeOf(ctx).width - 560) / 2
            : 0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF34C759), size: 24),
                const SizedBox(width: 10),
                Text(
                  'Chek #${s['number']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: muted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: canvas,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: line),
              ),
              child: SelectableText(
                coalReceipt(s),
                style: const TextStyle(height: 1.8, fontSize: 13.5, color: ink),
              ),
            ),
            const SizedBox(height: 16),
            if ((s['phone'] ?? '').isNotEmpty) ...[
              FilledButton.icon(
                onPressed: () => compose(s),
                icon: const Icon(Icons.sms_outlined, size: 18),
                label: const Text('SMS yuborish'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE5F1FF),
                  foregroundColor: green,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 10),
            ],
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: coalReceipt(s)));
                if (mounted) notice('Chek nusxalandi.');
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Nusxalash'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Tayyor'),
            ),
          ],
        ),
      ),
    ),
  );
}

class CenterHud extends StatefulWidget {
  const CenterHud({
    super.key,
    required this.message,
    this.title = 'SMS Yuborildi',
    this.icon = Icons.mark_email_read_rounded,
    this.color = const Color(0xFF34C759),
    required this.onDismiss,
    this.duration = const Duration(milliseconds: 2400),
  });

  final String message;
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onDismiss;
  final Duration duration;

  @override
  State<CenterHud> createState() => _CenterHudState();
}

class _CenterHudState extends State<CenterHud>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted || _dismissing) return;
    _dismissing = true;
    _timer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          color: Colors.black.withValues(alpha: 0.28),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ScaleTransition(
            scale: _scale,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: const Color(0xFFE5E5EA),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 36,
                        spreadRadius: 2,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF1C1C1E),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF636366),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded, size: 15, color: widget.color),
                              const SizedBox(width: 5),
                              Text(
                                'Yuborildi',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: widget.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
