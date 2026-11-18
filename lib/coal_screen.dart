part of 'main.dart';

mixin CoalScreens on State<ShopHome> {
  ShopStore get store;
  int get page;
  String get query;
  Widget searchField(String hint);
  void notice(String text);
  void showCenterNotice(
    String message, {
    String? title,
    IconData? icon,
    Color? color,
  });
  void history();
  void showReceipt(Json receipt);
  Widget cashPage();
  Widget customersPage();
  Future<void> customerDialog();
  void navigate(int page);
  Widget badge(String label, Color color);
  Widget empty(String title, String description, IconData icon);

  static const names = ['Hisobotlar', 'Sotuv', 'Ombor', 'Kassa', 'Mijozlar'];
  static const symbols = [
    Icons.bar_chart_outlined,
    Icons.point_of_sale_outlined,
    Icons.inventory_2_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.people_outline_rounded,
  ];
  static const activeSymbols = [
    Icons.bar_chart_rounded,
    Icons.point_of_sale_rounded,
    Icons.inventory_2_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.people_alt_rounded,
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBody: false,
    appBar: AppBar(
      toolbarHeight: 64,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0.8),
        child: Divider(height: 0.8, thickness: 0.8, color: line),
      ),
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/tizimon.png', width: 38, height: 38),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  names[page],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Xo‘jalar ko‘mir ombori',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (page == 2) ...[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => editCoal(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Qo‘shish', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              style: FilledButton.styleFrom(
                backgroundColor: green,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ] else if (page == 4) ...[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: customerDialog,
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Qo‘shish', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              style: FilledButton.styleFrom(
                backgroundColor: green,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Sotuvlar tarixi',
              onPressed: history,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_rounded, color: ink, size: 20),
              ),
            ),
          ),
        ],
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: switch (page) {
              0 => reports(),
              1 || 2 => catalog(),
              3 => cashPage(),
              _ => customersPage(),
            },
          ),
        ),
      ),
    ),
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5EA), width: 0.8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(5, (i) {
              final selected = page == i;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    navigate(i);
                  },
                  splashColor: green.withOpacity(0.08),
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: selected ? green.withOpacity(0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          selected ? activeSymbols[i] : symbols[i],
                          color: selected ? green : const Color(0xFF8E8E93),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        names[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? green : const Color(0xFF8E8E93),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    ),
  );

  Widget reports() {
    final now = DateTime.now();

    final todaySalesList = store.sales.where((s) {
      final d = DateTime.parse(s['date']).toLocal();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    final monthSalesList = store.sales.where((s) {
      final d = DateTime.parse(s['date']).toLocal();
      return d.year == now.year && d.month == now.month;
    }).toList();

    final yearSalesList = store.sales.where((s) {
      final d = DateTime.parse(s['date']).toLocal();
      return d.year == now.year;
    }).toList();

    final todaySales = todaySalesList.fold(0, (n, s) => n + (s['total'] as int));
    final totalSales = store.sales.fold(0, (n, s) => n + (s['total'] as int));
    final monthlySales = monthSalesList.fold(0, (n, s) => n + (s['total'] as int));
    final yearlySales = yearSalesList.fold(0, (n, s) => n + (s['total'] as int));
    final todayCount = todaySalesList.length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Hero Card: Bugungi savdo
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => showAnalytics(
              title: 'Bugungi savdo analitikasi',
              subtitle: '${dateLabel(now)} holatiga ko‘ra',
              sales: todaySalesList,
            ),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF007AFF), Color(0xFF0051C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x38007AFF),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.today_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Flexible(
                              child: Text(
                                'Bugungi savdo',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$todayCount ta sotuv',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      todaySales >= 1000000 ? formatMln(todaySales) : '${money(todaySales)} so‘m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  if (todaySales >= 1000000) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${money(todaySales)} so‘m',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${dateLabel(now)} holatiga ko‘ra',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Aniq analitika',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withOpacity(0.95),
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _reportCard(
          title: 'Umumiy savdo',
          amount: totalSales,
          icon: Icons.all_inclusive_rounded,
          iconColor: const Color(0xFF007AFF),
          iconBg: const Color(0xFFEAF2FF),
          onTap: () => showAnalytics(
            title: 'Umumiy savdo analitikasi',
            subtitle: 'Barcha davrlar bo‘yicha to‘liq hisobot',
            sales: store.sales,
          ),
        ),
        const SizedBox(height: 10),
        _reportCard(
          title: 'Oylik savdo',
          amount: monthlySales,
          icon: Icons.calendar_month_rounded,
          iconColor: const Color(0xFF5856D6),
          iconBg: const Color(0xFFF0EFFF),
          onTap: () => showAnalytics(
            title: 'Oylik savdo analitikasi',
            subtitle: '${now.year}-yil ${now.month}-oy hisoboti',
            sales: monthSalesList,
          ),
        ),
        const SizedBox(height: 10),
        _reportCard(
          title: 'Yillik savdo',
          amount: yearlySales,
          icon: Icons.date_range_rounded,
          iconColor: const Color(0xFF34C759),
          iconBg: const Color(0xFFEBF9EE),
          onTap: () => showAnalytics(
            title: 'Yillik savdo analitikasi',
            subtitle: '${now.year}-yil hisoboti',
            sales: yearSalesList,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sotuvlar tarixi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            TextButton.icon(
              onPressed: history,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Barchasi'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: history,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: line),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFFFF9500),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sotuvlar tarixi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Barcha cheklar, mahsulot va mijozlar',
                          style: TextStyle(fontSize: 12, color: muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: muted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _reportCard({
    required String title,
    required num amount,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    VoidCallback? onTap,
  }) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: line),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Analitika >',
                        style: TextStyle(
                          color: green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      amount >= 1000000 ? formatMln(amount) : '${money(amount)} so‘m',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ink,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (amount >= 1000000) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${money(amount)} so‘m',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void showAnalytics({
    required String title,
    required String subtitle,
    required List<Json> sales,
  }) {
    final total = sales.fold(0, (n, s) => n + (s['total'] as int));
    final count = sales.length;
    final avg = count > 0 ? (total / count).round() : 0;

    final cashSales = sales.where((s) => s['method'] == 'Naqd').toList();
    final cardSales = sales.where((s) => s['method'] == 'Karta').toList();
    final debtSales = sales.where((s) => s['method'] == 'Qarz').toList();

    final cashTotal = cashSales.fold(0, (n, s) => n + (s['total'] as int));
    final cardTotal = cardSales.fold(0, (n, s) => n + (s['total'] as int));
    final debtTotal = debtSales.fold(0, (n, s) => n + (s['total'] as int));

    final Map<String, (double, String, int)> productsMap = {};
    for (final s in sales) {
      final lines = (s['lines'] as List?) ?? [];
      for (final l in lines) {
        final name = l['name'] as String? ?? 'Ko‘mir';
        final qty = (l['quantity'] as num?)?.toDouble() ?? 0.0;
        final unit = l['unit'] as String? ?? 'kg';
        final price = (l['price'] as num?)?.toInt() ?? 0;
        final lineTotal = (qty * price).round();

        final current = productsMap[name];
        if (current == null) {
          productsMap[name] = (qty, unit, lineTotal);
        } else {
          productsMap[name] = (current.$1 + qty, unit, current.$3 + lineTotal);
        }
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.9,
          maxWidth: 600,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(ctx).width > 600
              ? (MediaQuery.sizeOf(ctx).width - 600) / 2
              : 0,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
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
                    color: const Color(0xFFEBF3FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: green, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: muted),
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
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF0051C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jami tushum',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            total >= 1000000 ? formatMln(total) : '${money(total)} so‘m',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                        if (total >= 1000000) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${money(total)} so‘m',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count ta savdo',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'O‘rtacha: ${money(avg)} so‘m',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'To‘lov usullari tahlili',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink),
                  ),
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: line, width: 0.8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _paymentRow('Naqd', cashTotal, cashSales.length, total, const Color(0xFF34C759)),
                          const Divider(height: 20),
                          _paymentRow('Karta', cardTotal, cardSales.length, total, const Color(0xFF007AFF)),
                          const Divider(height: 20),
                          _paymentRow('Qarz', debtTotal, debtSales.length, total, const Color(0xFFFF9500)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (productsMap.isNotEmpty) ...[
                    const Text(
                      'Mahsulotlar bo‘yicha sotuv hajmi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink),
                    ),
                    const SizedBox(height: 10),
                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: line, width: 0.8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: productsMap.entries.map((e) {
                            final name = e.key;
                            final (qty, unit, prodTotal) = e.value;
                            final qtyStr = qty.truncateToDouble() == qty ? qty.toInt().toString() : qty.toStringAsFixed(2);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F2F7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.terrain_rounded, size: 20, color: green),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: ink)),
                                        Text('$qtyStr $unit sotildi', style: const TextStyle(fontSize: 12, color: muted)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        prodTotal >= 1000000 ? formatMln(prodTotal) : '${money(prodTotal)} so‘m',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: green),
                                      ),
                                      if (prodTotal >= 1000000)
                                        Text('${money(prodTotal)} so‘m', style: const TextStyle(fontSize: 11, color: muted)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  Text(
                    'Cheklar ro‘yxati (${sales.length} ta)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink),
                  ),
                  const SizedBox(height: 10),
                  if (sales.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('Bu davrda savdolar mavjud emas.', style: TextStyle(color: muted)),
                      ),
                    )
                  else
                    ...sales.reversed.map((s) {
                      final date = DateTime.parse(s['date']);
                      final formattedDate =
                          '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                      final lines = (s['lines'] as List?) ?? [];
                      final productName = lines.isNotEmpty
                          ? '${lines.first['name']}${lines.first['quantity'] != null ? ' (${lines.first['quantity']} ${lines.first['unit'] ?? 'dona'})' : ''}'
                          : 'Ko‘mir';
                      final totalAmount = s['total'] as int? ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: line, width: 0.8),
                          ),
                          child: InkWell(
                            onTap: () => showReceipt(s),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(productName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: ink)),
                                        const SizedBox(height: 2),
                                        Text('${s['customer']} · $formattedDate', style: const TextStyle(fontSize: 11.5, color: muted)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        totalAmount >= 1000000 ? formatMln(totalAmount) : '${money(totalAmount)} so‘m',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: green),
                                      ),
                                      badge(s['method'] ?? 'Naqd', s['method'] == 'Qarz' ? const Color(0xFFFF9500) : const Color(0xFF34C759)),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right_rounded, color: muted, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentRow(String name, int amount, int count, int grandTotal, Color color) {
    final pct = grandTotal > 0 ? (amount / grandTotal * 100).round() : 0;
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: ink)),
            const SizedBox(width: 6),
            Text('($count ta)', style: const TextStyle(fontSize: 12, color: muted)),
            const Spacer(),
            Text(
              amount >= 1000000 ? formatMln(amount) : '${money(amount)} so‘m',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: ink),
            ),
            const SizedBox(width: 6),
            Text('$pct%', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: grandTotal > 0 ? amount / grandTotal : 0,
            backgroundColor: const Color(0xFFF2F2F7),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
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
        searchField(page == 1 ? 'Sotuv uchun ko‘mir nomini qidiring' : 'Ko‘mir nomi yoki kategoriya'),
        const SizedBox(height: 12),
        Expanded(
          child: products.isEmpty
              ? empty(
                  query.isEmpty ? 'Ko‘mir katalogi bo‘sh' : 'Mahsulot topilmadi',
                  page == 1 ? 'Oldin Ombor bo‘limidan mahsulot qo‘shing.' : 'Yuqoridagi + tugmasi orqali yangi tur qo‘shing.',
                  Icons.terrain_outlined,
                )
              : ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: line, width: 0.8),
                      ),
                      child: InkWell(
                        onTap: () => page == 2 ? editCoal(p) : saleForm(p),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: page == 1 ? const Color(0xFFEBF3FF) : const Color(0xFFF2F2F7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.terrain_rounded,
                                  color: page == 1 ? green : ink,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: ink,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: canvas,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        p['category'],
                                        style: const TextStyle(fontSize: 11.5, color: muted, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (page == 1) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: green,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'Sotish',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                const Icon(Icons.edit_outlined, color: muted, size: 20),
                              ],
                            ],
                          ),
                        ),
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
      Icons.terrain_rounded,
      (update) => [
        input('Mahsulot nomi', (v) => name = v, initial: name),
        if (!creating)
          DropdownButtonFormField<String>(
            initialValue: group,
            decoration: InputDecoration(
              labelText: 'Kategoriya',
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
            items: store.groups
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => update(() => group = v),
          ),
        if (creating) input('Yangi kategoriya nomi', (v) => newGroup = v),
        if (store.groups.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => update(() => creating = !creating),
              icon: const Icon(Icons.category_outlined, size: 18),
              label: Text(
                creating
                    ? 'Saqlangan kategoriyalardan tanlash'
                    : 'Yangi kategoriya yaratish',
                style: const TextStyle(fontSize: 13),
              ),
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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) {
          Future<void> submit(bool message) async {
            if (saving) return;
            update(() => saving = true);
            try {
              await save(message);
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (e) {
              if (ctx.mounted) {
                update(() {
                  error = e is StateError
                      ? e.message
                      : 'Saqlashda xatolik yuz berdi.';
                  saving = false;
                });
              }
            }
          }

          return PopScope(
            canPop: !saving,
            child: Container(
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
                            color: const Color(0xFFEBF3FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: green, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: saving ? null : () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, color: muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    for (final w in fields(update))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: w,
                      ),
                    if (error != null) ...[
                      Text(
                        error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 6),
                    if (sms) ...[
                      FilledButton.icon(
                        onPressed: saving ? null : () => submit(true),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          'Saqlash va xabar yuborish',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: saving ? null : () => submit(false),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          saving ? 'Saqlanmoqda...' : 'Saqlash (xabar yubormaslik)',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ] else ...[
                      FilledButton(
                        onPressed: saving ? null : () => submit(false),
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
                    ],
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: saving ? null : () => Navigator.pop(ctx),
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
      Icons.point_of_sale_rounded,
      (update) {
        final q = double.tryParse(quantity.replaceAll(',', '.')) ?? 0;
        final p = int.tryParse(price) ?? 0;
        final total = (q * p).round();
        return [
          // iOS Segmented Control: Kilogramm / Tonna (never wraps!)
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEF0),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => update(() => unit = 'kg'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: unit == 'kg' ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: unit == 'kg'
                            ? const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Kilogramm',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              unit == 'kg' ? FontWeight.w600 : FontWeight.w500,
                          color: unit == 'kg' ? ink : muted,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => update(() => unit = 'tonna'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: unit == 'tonna' ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: unit == 'tonna'
                            ? const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Tonna',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              unit == 'tonna' ? FontWeight.w600 : FontWeight.w500,
                          color: unit == 'tonna' ? ink : muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          input(
            'Miqdor',
            (v) => update(() => quantity = v),
            keyboard: const TextInputType.numberWithOptions(decimal: true),
          ),
          TextFormField(
            onChanged: (v) => update(() => price = v),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '1 $unit narxi, so‘m',
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
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD6E4FF)),
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                total >= 1000000
                    ? 'Jami: ${formatMln(total)} (${money(total)} so‘m)'
                    : 'Jami: ${money(total)} so‘m',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: method,
            decoration: InputDecoration(
              labelText: 'To‘lov usuli',
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
        ];
      },
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
      final res = await const MethodChannel('uz.dokon/sms').invokeMethod<String>('compose', {
        'phone': sale['phone'],
        'body': coalReceipt(sale),
      });
      if (mounted && res == 'SENT_DIRECT') {
        showCenterNotice(
          'Mijozga to‘g‘ridan-to‘g‘ri yuborildi!',
          title: 'SMS Yuborildi',
          icon: Icons.mark_email_read_rounded,
          color: const Color(0xFF34C759),
        );
      }
    } catch (_) {
      if (mounted)
        notice(
          'Savdo saqlandi. SMS yuborilmadi. Chekdan qayta urinishingiz mumkin.',
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
          decoration: InputDecoration(
            labelText: 'Mijoz ismi',
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
          onChanged: (_) {
            setState(() {
              if (selected != null) phone.clear();
              selected = null;
            });
            publish();
          },
        ),
        if (selected == null && prefix.isNotEmpty && matches.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: matches.length < 3 ? matches.length * 64.0 : 180,
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: line),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                shrinkWrap: true,
                primary: false,
                separatorBuilder: (_, i) => const Divider(height: 1),
                itemCount: matches.length,
                itemBuilder: (_, i) {
                  final c = matches[i];
                  return ListTile(
                    title: Text(
                      c['name'],
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      c['phone'],
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
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
          ),
        const SizedBox(height: 12),
        TextField(
          controller: phone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Telefon raqami',
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
          onChanged: (_) => publish(),
        ),
      ],
    );
  }
}

String coalReceipt(Json s) {
  final date = DateTime.parse(s['date']);
  final formattedDate =
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  final lines = (s['lines'] as List)
      .map((l) => "${l['name']}: ${l['quantity']} ${l['unit'] ?? 'dona'} * ${money(l['price'])} so'm")
      .join('\n');
  return "Assalomu alaykum\nDokon: Xo'jalar\nVaqti: $formattedDate\nMijoz: ${s['customer']}\n$lines\nJami: ${money(s['total'])} so'm\nTo'lov: ${s['method']}\nChek #${s['number']}";
}

String debtSmsText(Json customer, List<Json> allSales) {
  final name = (customer['name'] as String? ?? 'Mijoz').trim();
  final debt = customer['debt'] as int? ?? 0;
  final debtSales = allSales.where((s) {
    final matchesId = s['customerId'] != null && s['customerId'] == customer['id'];
    final matchesPhone = (customer['phone'] as String? ?? '').isNotEmpty && s['phone'] == customer['phone'];
    final matchesName = s['customer'] == customer['name'];
    return (matchesId || matchesPhone || matchesName) && s['method'] == 'Qarz';
  }).toList();

  String debtLine;
  if (debtSales.isNotEmpty) {
    final lastSale = debtSales.last;
    final d = DateTime.tryParse(lastSale['date'] ?? '') ?? DateTime.now();
    final dateStr = '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
    final saleAmount = lastSale['total'] ?? debt;
    debtLine = "Siz $dateStr kuni ${money(saleAmount)} so'm qarz olgansiz.";
  } else {
    final now = DateTime.now();
    final dateStr = '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
    debtLine = "Siz $dateStr kuni qarz olgansiz.";
  }

  return "Assalomu alaykum, $name!\n"
      "Dokon: Xo'jalar\n"
      "$debtLine\n"
      "To'lashingizni so'raymiz.\n"
      "Jami qarzingiz: ${money(debt)} so'm.";
}

