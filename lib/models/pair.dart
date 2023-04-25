import 'dart:core';

class Pair<T1, T2> {
  final T1 item1;
  final T2 item2;

  Pair({
    required this.item1,
    required this.item2,
  });

  factory Pair.fromJson(Map<String, dynamic> json) {
    return Pair(
      item1: json['item1'],
      item2: json['item2'],
    );
  }
}