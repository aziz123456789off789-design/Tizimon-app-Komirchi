import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'storage_base.dart';

Future<Storage> openStorage() async {
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  return FileStorage(File('${dir.path}/dokon.json'));
}

class FileStorage implements Storage {
  FileStorage(this.file);
  final File file;
  @override
  Future<Json?> read() async {
    if (!await file.exists()) return null;
    return jsonDecode(await file.readAsString()) as Json;
  }

  @override
  Future<void> write(Json data) async {
    final pending = File('${file.path}.pending');
    await pending.writeAsString(jsonEncode(data), flush: true);
    if (await file.exists()) await file.copy('${file.path}.backup');
    await pending.rename(file.path);
  }
}
