typedef Json = Map<String, dynamic>;

abstract class Storage {
  Future<Json?> read();
  Future<void> write(Json data);
}
