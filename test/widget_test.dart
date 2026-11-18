import 'package:flutter_test/flutter_test.dart';
import 'package:dokon/main.dart';
import 'package:dokon/store.dart';
import 'store_test.dart' show MemoryStorage;
void main(){
 testWidgets('Reports first and coal catalog available', (tester)async{
 final store=ShopStore(MemoryStorage());
 await store.saveCoal('Angren','Mahalliy');
 await tester.pumpWidget(ShopApp(store:store));
 expect(find.text('Umumiy savdo'),findsOneWidget);
 expect(find.text('Oylik savdo'),findsOneWidget);
 await tester.tap(find.text('Sotuv'));await tester.pumpAndSettle();
 await tester.tap(find.text('Angren'));await tester.pumpAndSettle();
 expect(find.text('Saqlash va xabar yuborish'),findsOneWidget);
 });
 test('Fractional coal sale, debt, receipt and persisted category',()async{
 final disk=MemoryStorage();final store=ShopStore(disk);
 await store.saveCoal('Angren','Mahalliy');
 final s=await store.sellCoal(store.coal.first,1.25,'tonna',800000,'Qarz','Ali','901234567');
 expect(store.debt,1000000);expect(store.cash,0);
 expect(coalReceipt(s),contains('1.25 tonna'));expect(s['phone'],'+998901234567');
 final restored=ShopStore(disk);await restored.load();expect(restored.groups,['Mahalliy']);
 await restored.sellCoal(restored.coal.first,2000,'kg',800,'Naqd','','');
 expect(restored.cash,1600000);expect(restored.sales.length,2);
 });
}
