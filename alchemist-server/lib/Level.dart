import 'dart:convert';
import 'dart:io';

import 'package:alchemist/Path.dart';
import 'package:alchemist/Tube.dart';
import 'package:alchemist/constants.dart';
import 'package:alchemist/utils.dart';

class Level {
  List<Tube> tubes = [];
  List<Path> paths = [];

  Level({
    List<Tube>? tubes,
    List<Path>? paths,
    int? emptyTubes,
    int? colorTubes,
    int clutterIterations = 100,
  }) {
    this.tubes = tubes ?? [];
    this.paths = paths ?? [];

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
    paths = []; // Empty paths, we don't want to save them
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
      tubes: List<Tube>.from(map['tubes']?.map((x) => Tube.fromMap(x))),
      paths: List<Path>.from(map['paths']?.map((x) => Path.fromMap(x))),
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
        var take = random.nextBool();
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

  Future<bool> resolve(Path path) async {
    var tubes = getTubes();
    for (var move in path.movements) {
      var dot = tubes[move.from].getDot();
      if (dot == null) return false;
      var ok = tubes[move.to].addDotValidating(dot);
      if (!ok) return false;
      tubes[move.from].removeLast();
    }
    return Level.isDone(tubes);
  }

  @override
  String toString() => 'Level($tubes)';
}
