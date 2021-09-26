import 'dart:convert';

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

  factory Tube.fromMap(List<dynamic> dots) {
    var d = List<String>.from(dots);
    return Tube(dots: d);
  }

  String toJson() => json.encode(toMap());

  factory Tube.fromJson(String source) => Tube.fromMap(json.decode(source));

  @override
  String toString() => 'Tube($dots)';
}
