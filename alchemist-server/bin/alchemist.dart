import 'dart:async';
import 'dart:io';

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

  app.post('/levels/resolve/<id>', (Request request, String id) {
    return Response.ok('100');
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
    files[i] = File('levels/match-$i.json').readAsStringSync();
  }
  return files;
}
