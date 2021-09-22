import 'dart:convert';

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
