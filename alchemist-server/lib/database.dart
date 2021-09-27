import 'package:redis/redis.dart';

class Database {
  RedisConnection _conn = RedisConnection();
  Command? cmd;

  Database() {
    initialize();
  }

  Future<void> initialize() async {
    cmd = await _conn.connect('localhost', 6379);
    print('Redis ready');
  }

  Future<String?> read(String key) async {
    var res = await cmd?.send_object(["GET", key]);
    if (res != null) return res as String;
  }

  Future<void> write(String key, String value) async {
    await cmd?.send_object(["SET", key, value]);
  }

  Future<void> deleteBatch(String pattern) async {
    var keys = await cmd?.send_object(["KEYS", pattern]);
    if (keys != null && keys.length > 0) {
      await cmd?.send_object(["DEL", ...keys]);
    }
  }

  Future<void> increase(String key) async {
    await cmd?.send_object(["INCR", key]);
  }
}
