import 'dart:io';

import 'package:alchemist/Level.dart';

var levelsCounter = 0;

Future<void> regenerate() async {
  var dir = Directory('levels');
  if (await dir.exists()) await dir.delete(recursive: true);
  await dir.create();
  await createLevels(10, 3, 1);
  await createLevels(10, 4, 1);
  await createLevels(10, 5, 1);
  await createLevels(10, 6, 2);
  await createLevels(10, 7, 2);
  await createLevels(10, 8, 2);
  await createLevels(10, 9, 2);
  await createLevels(10, 10, 2);
  await createLevels(10, 10, 2);
  await createLevels(10, 10, 2);
}

Future<void> createLevels(int levels, int colorTubes, int emptyTubes) async {
  for (var i = 0; i < levels; i++) {
    print('-- $colorTubes:$emptyTubes   total: $levelsCounter/100');
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
