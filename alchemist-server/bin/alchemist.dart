import 'dart:async';
import 'dart:io';

import 'package:alchemist/generator.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  await gen();
  var app = Router();

  app.get('/levels/count', (Request request) {
    return Response.ok('100');
  });

  app.get('/levels/<id>', (Request request, String id) async {
    return Response.ok(await File('levels/match-$id.json').readAsString());
  });

  var server = await io.serve(app, 'localhost', 8080);
  print('Server running on localhost:${server.port}');

  Timer(Duration(hours: 1), () {
    gen();
  });
  print('Timer ready');
}

Future<void> gen() async {
  var file = File('last.gen');
  if (await file.exists()) {
    var lastTxt = await File('last.gen').readAsString();
    var last = DateTime.parse(lastTxt);
    if (last.day == DateTime.now().day) {
      return;
    }
  }
  await regenerate();
  await file.writeAsString(DateTime.now().toIso8601String());
}
