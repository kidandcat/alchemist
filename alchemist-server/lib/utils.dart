import 'dart:math';

final random = Random();
int next(int min, int max) => min + random.nextInt(max - min);
