import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

const _hostname = 'localhost';
const _port = 8080;

void main(List<String> args) async {
  var app = Router();

  app.post('/create/level', (Request request) async {
    var data = await request.readAsString();
    print('request: $data');
    var level = Level.fromJson(data);
    print('save file');
    await level.saveFile();
    print('file saved');
    return Response.ok(null);
  });

  app.get('/level/<id>', (Request request, String id) async {
    var level = await Level.fromFile(int.parse(id));
    return Response.ok(level.toJson());
  });

  await io.serve(app, _hostname, _port);
}

class Level {
  List<List<String>> Tubes;
  Level({
    required this.Tubes,
  });

  static Future<Level> fromFile(int id) async {
    var file = File('levels/match-$id.json');
    var data = await file.readAsString();
    return Level.fromJson(data);
  }

  static Future<bool> exists(int id) async {
    var file = File('levels/match-$id.json');
    return file.exists();
  }

  Future<void> saveFile() async {
    var id = await nextLevel();
    var file = File('levels/match-$id.json');
    await file.writeAsString(toJson());
  }

  Map<String, dynamic> toMap() {
    return {
      'Tubes': Tubes,
    };
  }

  factory Level.fromMap(Map<String, dynamic> map) {
    return Level(
      Tubes: List<List<String>>.from(
        map['Tubes']?.map((x) => List<String>.from(x)),
      ),
    );
  }

  String toJson() => json.encode(Tubes);

  factory Level.fromJson(String source) => Level(
        Tubes: List<List<String>>.from(
          json.decode(source).map((x) => List<String>.from(x)),
        ),
      );

  static Future<int> nextLevel() async {
    var index = 1;
    while (true) {
      if (!(await Level.exists(index))) {
        print('Next level: $index');
        return index;
      }
      index++;
      if (index > 500) return 0;
    }
  }
}
