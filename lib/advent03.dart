import 'dart:io';
import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart' as pp;

void main() {
  final inputFile = File('input03.txt');
  final lines = inputFile.readAsStringSync();
  final matches = exprParser.allMatches(lines, overlapping: false).toList();
  bool enable = true;
  final multiplicationResults = <int>[];

  for (final match in matches) {
    switch (match) {
      case Do():
        enable = true;
      case Dont():
        enable = false;
      case MulExpr(:final a, :final b):
        if (enable) {
          multiplicationResults.add(a * b);
        }
    }
  }

  print(multiplicationResults.sum);
}

sealed class Expr {
  const Expr();
}

class MulExpr extends Expr {
  final int a;
  final int b;

  const MulExpr(this.a, this.b);
}

class Do extends Expr {
  const Do();
}

class Dont extends Expr {
  const Dont();
}

final doo = pp.string('do()').map((value) => Do());
final dont = pp.string('don\'t()').map((value) => Dont());
final digit = pp.digit().repeat(1, 3).map((value) => int.parse(value.join()));
final mulExpr = (pp.string('mul(') & digit & pp.char(',') & digit & pp.char(')')).map(toMulExpr);

MulExpr toMulExpr(List<dynamic> value) {
  final a = value[1] as int; // 0 is the string 'mul(', 1 is the 1st digit
  final b = value[3] as int; // 2 is the string ',', 3 is the 2nd digit
  return MulExpr(a, b);
}

final exprParser = (mulExpr | doo | dont).cast<Expr>();
