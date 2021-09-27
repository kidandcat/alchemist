import 'dart:async';
import 'dart:convert';

import 'package:alchemist/Level.dart';
import 'package:alchemist/Movement.dart';
import 'package:alchemist/Tube.dart';
import 'package:alchemist/constants.dart';
import 'package:alchemist/utils.dart';

class Path {
  List<Movement> movements = [];
  Path({
    List<Movement>? movements,
  }) : movements = movements ?? [];

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

  factory Path.fromMap(List<dynamic> data) {
    return Path(
      movements: data.map((m) => Movement.fromMap(m)).toList(),
    );
  }

  List<dynamic> toList() => movements.map((x) => x.toMap()).toList();

  String toJson() => json.encode(movements);

  factory Path.fromJson(String source) => Path.fromMap(json.decode(source));
}
