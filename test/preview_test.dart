import 'dart:io';
import 'dart:ui' as ui;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dokon/main.dart';
import 'package:dokon/store.dart';

import 'store_test.dart' show MemoryStorage;

void main() {
  testWidgets('Capture desktop and phone layouts', (tester) async {
    if (!const bool.fromEnvironment('CAPTURE')) return;
    final font = File('C:/Windows/Fonts/segoeui.ttf');
    await tester.runAsync(() async {
      if (await font.exists()) {
        final loader = FontLoader('Segoe UI');
        loader.addFont(
          Future.value(ByteData.sublistView(await font.readAsBytes())),
        );
        await loader.load();
      }
      final icons = FontLoader('MaterialIcons');
      icons.addFont(
        Future.value(
          ByteData.sublistView(
            await File(
              '.tools/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
            ).readAsBytes(),
          ),
        ),
      );
      await icons.load();
    });
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = ShopStore(MemoryStorage());
    await store.saveCoal('Angren', 'Mahalliy');
    final boundary = GlobalKey();
    tester.view.physicalSize = const Size(1440, 960);
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: ShopApp(store: store),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> capture(String filename) async {
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await render.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('artifacts').create(recursive: true);
        await File(
          'artifacts/$filename.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('desktop');
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    await capture('phone');
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Sotuv'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Angren'));
    await tester.pumpAndSettle();
    await capture('phone_modal');
    expect(tester.takeException(), isNull);
  });
}
