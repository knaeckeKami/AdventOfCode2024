import 'dart:io';

import 'package:collection/collection.dart';

void main() {
  final inputFile = File('input.txt');

  final lines = inputFile.readAsLinesSync();

  final Iterable<(String, String)> numbers = lines.map(
    (e) {
      List<String> parts = e.split(' ');
      return (
        parts[0],
        parts[parts.length - 1],
      );
    },
  );

  final Iterable<(int, int)> parsedNums = numbers.map(
    (e) => (
      int.parse(e.$1),
      int.parse(e.$2),
    ),
  );

  final firstRow = parsedNums.map((e) => e.$1).sortedBy<num>((e) => e).toList();

  final secondRow = parsedNums.map((e) => e.$2).sortedBy<num>((e) => e).toList();

  final pairs = [for (var i = 0; i < firstRow.length; i++) (firstRow[i], secondRow[i])];

  print(pairs);

  final diffsSum = pairs.map((e) => (e.$1 - e.$2).abs()).sum;

  //print('');
  //print(diffsSum);

  final Map<int, int> counts = {};

  for (final entry in secondRow) {
    counts.update(entry, (value) => value + 1, ifAbsent: () => 1);
  }

  final simScores = [for (final num in firstRow) num * (counts[num] ?? 0)];

  print(simScores);

  print(simScores.sum);
}
