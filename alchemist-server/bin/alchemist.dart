import 'dart:async';
import 'dart:io';

import 'package:alchemist/Level.dart';
import 'package:alchemist/Path.dart';
import 'package:alchemist/generator.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  var files = await gen();
  var app = Router();

  app.get('/levels/count', (Request request) {
    return Response.ok('100');
  });

  app.post('/levels/resolve/<id>', (Request request, String id) async {
    print('Resolve $id');
    if (files[id] == null) return Response.notFound(null);
    var body = await request.readAsString();
    print('Resolve body $body');
    var level = Level.fromJson(files[id]!);
    var path = Path.fromJson(body);
    if (await level.resolve(path)) {
      return Response.ok('OK');
    }
    return Response.ok('KO');
  });

  app.get('/levels/<id>', (Request request, String id) async {
    return Response.ok(files[int.parse(id)]);
  });

  var server = await io.serve(app, 'localhost', 8080);
  print('Server running on localhost:${server.port}');

  Timer(Duration(hours: 1), () async {
    files = await gen();
  });
  print('Timer ready');
}

Future<Map<int, String>> gen() async {
  var file = File('last.gen');
  if (await file.exists()) {
    var lastTxt = await File('last.gen').readAsString();
    var last = DateTime.parse(lastTxt);
    if (last.day != DateTime.now().day) {
      await regenerate();
      await file.writeAsString(DateTime.now().toIso8601String());
    }
  }
  Map<int, String> files = {};
  for (var i = 1; i <= 100; i++) {
    files[i] = await File('levels/match-$i.json').readAsString();
  }
  return files;
}
