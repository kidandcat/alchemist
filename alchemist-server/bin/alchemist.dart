import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

final _random = Random();
int next(int min, int max) => min + _random.nextInt(max - min);

const colors = [
  'Purple',
  'Blue',
  'Red',
  'Green',
  'Yellow',
  'DarkBlue',
  'Grey',
  'Lime',
  'Orange',
  'Pink',
];

const maxMovements = 200;
const maxMiliseconds = 10;

var total = 0;

const _hostname = 'localhost';
const _port = 8080;

void main() async {
  await regenerate();
}

void server() async {
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

  app.get('/levels', (Request request) async {
    var nextLevel = await Level.nextLevel();
    return Response.ok('${nextLevel - 1}');
  });

  app.get('/level/<id>', (Request request, String id) async {
    var level = await Level.fromFile(int.parse(id));
    return Response.ok(level.toJson());
  });

  await io.serve(app, _hostname, _port);
}

Future<void> regenerate() async {
  var dir = Directory('levels');
  if (await dir.exists()) await dir.delete(recursive: true);
  await dir.create();
  print('-Regenerating');
  total = 250;
  await createLevels(10, 3, 1);
  await createLevels(10, 4, 1);
  await createLevels(10, 5, 1);
  await createLevels(20, 6, 2);
  await createLevels(20, 7, 2);
  await createLevels(30, 8, 2);
  await createLevels(50, 9, 2);
  await createLevels(50, 10, 2);
  await createLevels(50, 10, 2);
  print('-Regeneration finished');
}

var levelsCounter = 0;

Future<void> createLevels(int levels, int colorTubes, int emptyTubes) async {
  for (var i = 0; i < levels; i++) {
    print('-- $i/$levels   total: $levelsCounter/$total');
    await createLevel(colorTubes, emptyTubes);
    levelsCounter++;
  }
}

Future<void> createLevel(int colorTubes, int emptyTubes) async {
  var level = Level(colorTubes: colorTubes, emptyTubes: emptyTubes);
  var success = await level.calculateAndSave();
  if (!success) {
    return createLevel(colorTubes, emptyTubes);
  }
}

class Level {
  late List<Tube> tubes;
  List<Path> paths = [];

  Level({
    List<Tube>? tubes,
    List<Path>? paths,
    int? emptyTubes,
    int? colorTubes,
    int clutterIterations = 100,
  }) {
    if (tubes == null) {
      this.tubes = [];
    }
    if (paths == null) {
      this.paths = [];
    }

    if (emptyTubes != null && colorTubes != null) {
      for (var i = 0; i < emptyTubes; i++) {
        addEmptyTube();
      }
      for (var i = 0; i < colorTubes; i++) {
        addTube(colors[i]);
      }
      clutter(clutterIterations);
    }
  }

  Future<bool> calculateAndSave() async {
    var success = await findPaths(5);
    if (!success) return false;
    await saveFile();
    return true;
  }

  List<Tube> getTubes() => tubes.map<Tube>((t) => Tube.clone(t)).toList();

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
      'tubes': tubes.map((x) => x.toMap()).toList(),
      'paths': paths.map((x) => x.toList()).toList(),
    };
  }

  factory Level.fromMap(Map<String, dynamic> map) {
    return Level(
      tubes: List<Tube>.from(map['Tubes']?.map((x) => Tube.fromMap(x))),
      paths: List<Path>.from(map['Paths']?.map((x) => Path.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Level.fromJson(String source) => Level.fromMap(json.decode(source));

  static Future<int> nextLevel() async {
    var index = 1;
    while (true) {
      if (!(await Level.exists(index))) {
        return index;
      }
      index++;
      if (index > 500) return 0;
    }
  }

  static bool isDone(List<Tube> tubes) {
    var done = tubes.every((x) => x.isDone() || x.isEmpty());
    return done;
  }

  static int tubesDone(List<Tube> tubes) {
    var dones = 0;
    for (var tube in tubes) {
      if (tube.isDone()) dones++;
    }
    return dones;
  }

  // add empty tube
  void addEmptyTube() {
    tubes.add(Tube());
  }

  // add colored tube
  void addTube(String color) {
    tubes.add(Tube(color: color));
  }

  // clutter tubes
  void clutter(int repeat) {
    for (var i = 0; i < repeat; i++) {
      for (var tube in tubes) {
        var randomTube = tubes[next(0, tubes.length)];
        var take = _random.nextBool();
        if (take) {
          var dot = randomTube.getDot();
          if (dot != null) {
            if (tube.addDot(dot)) {
              randomTube.removeLast();
            }
          }
        } else {
          var dot = tube.getDot();
          if (dot != null) {
            if (randomTube.addDot(dot)) {
              tube.removeLast();
            }
          }
        }
      }
    }
  }

  Future<bool> findPaths(int number) async {
    var maxTries = 25;
    while (number > 0) {
      maxTries--;
      var path = Path();
      var tubes = await path.calculatePath(this);
      if (isDone(tubes)) {
        paths.add(path);
        number--;
      } else {
        if (maxTries < 1) return false;
      }
    }
    return true;
  }

  @override
  String toString() => 'Level($tubes)';
}

class Tube {
  late List<String> dots;

  Tube({String? color, List<String>? dots}) {
    if (color == null) {
      if (dots != null) {
        this.dots = dots;
      } else {
        this.dots = <String>[];
      }
    } else {
      this.dots = <String>[color, color, color, color];
    }
  }

  Tube.clone(Tube tube) : this(dots: List<String>.from(tube.dots));

  bool addDot(String color) {
    if (dots.length == 4) return false;
    dots.add(color);
    return true;
  }

  bool addDotValidating(String color) {
    if (dots.length == 4) return false;
    if (dots.isNotEmpty && dots.last != color) return false;
    dots.add(color);
    return true;
  }

  String? getDot() {
    if (dots.isEmpty) return null;
    return dots.last;
  }

  void removeLast() {
    if (dots.isEmpty) return;
    dots.removeAt(dots.length - 1);
  }

  bool isDone() {
    if (dots.length != 4) return false;
    return dots.every((x) => x == dots.first);
  }

  bool isEmpty() {
    return dots.isEmpty;
  }

  List<String> toMap() {
    return dots;
  }

  factory Tube.fromMap(List<String> dots) {
    return Tube(dots: dots);
  }

  String toJson() => json.encode(toMap());

  factory Tube.fromJson(String source) => Tube.fromMap(json.decode(source));

  @override
  String toString() => 'Tube($dots)';
}

class Path {
  late List<Movement> movements;
  Path({
    movements,
  }) {
    if (movements == null) {
      this.movements = [];
    }
  }

  Future<List<Tube>> calculatePath(Level level) async {
    var tubes = level.getTubes();
    var timer = Timer.periodic(Duration(microseconds: 1), (timer) {
      if (Level.isDone(tubes)) {
        timer.cancel();
      }
      var tube1Index = next(0, tubes.length);
      var tube2Index = next(0, tubes.length);
      var randomTube1 = tubes[tube1Index];
      var randomTube2 = tubes[tube2Index];
      var dot = randomTube2.getDot();
      if (dot != null) {
        var movement = Movement(from: tube2Index, to: tube1Index);
        if (randomTube1 != randomTube2 &&
            !randomTube2.isEmpty() &&
            !randomTube1.isDone() &&
            !randomTube2.isDone() &&
            (movements.isEmpty || !movement.isOpposite(movements.last)) &&
            randomTube1.addDotValidating(dot)) {
          randomTube2.removeLast();
          movements.add(Movement(from: tube2Index, to: tube1Index));
        }
      }
      if (movements.length > maxMovements) {
        timer.cancel();
      }
    });
    var miliseconds = 0;
    while (miliseconds < maxMiliseconds) {
      await Future.delayed(Duration(milliseconds: 10));
      miliseconds += 10;
      if (!timer.isActive) return tubes;
    }
    if (timer.isActive) timer.cancel();
    return tubes;
  }

  @override
  String toString() => 'Path(movements: $movements)';

  factory Path.fromMap(Map<String, dynamic> map) {
    return Path(
      movements: List<Movement>.from(map['movements'] as List<dynamic>),
    );
  }

  List<dynamic> toList() => movements.map((x) => x.toMap()).toList();

  String toJson() => json.encode(movements);

  factory Path.fromJson(String source) => Path.fromMap(json.decode(source));
}

class Movement {
  int from;
  int to;
  Movement({
    required this.from,
    required this.to,
  });

  bool isOpposite(Movement m2) {
    return from == m2.to && to == m2.from;
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
    };
  }

  factory Movement.fromMap(Map<String, dynamic> map) {
    return Movement(
      from: map['from'],
      to: map['to'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Movement.fromJson(String source) =>
      Movement.fromMap(json.decode(source));

  @override
  String toString() => 'Movement(from: $from, to: $to)';
}
