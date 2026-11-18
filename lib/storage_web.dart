import 'dart:convert';

import 'package:web/web.dart' as web;

import 'storage_base.dart';

Future<Storage> openStorage() async => BrowserStorage();

class BrowserStorage implements Storage {
  static const key = 'dokon.shop.v1';
  @override
  Future<Json?> read() async {
    final raw = web.window.localStorage.getItem(key);
    return raw == null ? null : jsonDecode(raw) as Json;
  }

  @override
  Future<void> write(Json data) async {
    web.window.localStorage.setItem(key, jsonEncode(data));
  }
}
