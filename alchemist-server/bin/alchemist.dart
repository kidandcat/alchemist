import 'dart:async';
import 'dart:io';

import 'package:alchemist/Level.dart';
import 'package:alchemist/Path.dart';
import 'package:alchemist/database.dart';
import 'package:alchemist/generator.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  var app = Router();
  var db = Database();
  var files = await gen(db);

  app.get('/levels/count', (Request request) {
    print('GET levels count');
    return Response.ok('100');
  });

  app.post('/levels/resolve/<id>', (Request request, String idparam) async {
    print('POST levels resolve');
    var token = request.headers['Authorization'];
    if (token == null) return Response.notFound('Not Authorized');
    var id = int.parse(idparam);
    if (!files.containsKey(id)) return Response.notFound('Level $id not found');
    var completed = await db.read('$token-levels_completed');
    if (completed != null) {
      if (int.parse(completed) >= id)
        return Response.notFound('Level $id already completed');
    }
    var body = await request.readAsString();
    var level = Level.fromJson(files[id]!);
    var path = Path.fromJson(body);
    if (await level.resolve(path)) {
      await db.increase('$token-coins');
      await db.write('$token-levels_completed', '$id');
      return Response.ok('OK');
    }
    return Response.ok('KO');
  });

  app.get('/coins', (Request request) async {
    print('GET coins');
    var token = request.headers['Authorization'];
    if (token == null) return Response.notFound('Not Authorized');
    var coins = await db.read('$token-coins');
    return Response.ok(coins ?? '0');
  });

  app.get('/levels/<id>', (Request request, String id) async {
    try {
      return Response.ok(files[int.parse(id)]);
    } catch (e, s) {
      print('GET level $id ERROR $e $s');
      return Response.internalServerError(body: '$e $s');
    }
  });

  var server = await io.serve(app, 'localhost', 8081);
  print('Server running on localhost:${server.port}');

  Timer.periodic(Duration(hours: 1), (_) async {
    files = await gen(db);
  });
  print('Timer ready');
}

Future<Map<int, String>> gen(Database db) async {
  print('- - - - - - - - - - - - - - - - -');
  print('Gen() called');
  var file = File('last.gen');
  if (await file.exists()) {
    var lastTxt = await File('last.gen').readAsString();
    var last = DateTime.parse(lastTxt);
    if (last.day != DateTime.now().day) {
      await regenerate();
      await file.writeAsString(DateTime.now().toIso8601String());
      await db.deleteBatch('*levels_completed');
    }
  }
  Map<int, String> files = {};
  print('Caching levels');
  for (var i = 1; i <= 100; i++) {
    files[i] = await File('levels/match-$i.json').readAsString();
  }
  print('Get() done');
  return files;
}
