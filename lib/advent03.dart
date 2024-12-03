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

final doo = pp.string('do()');
final dont = pp.string('don\'t()');
final digit = pp.digit().repeat(1, 3).map((value) => int.parse(value.join()));
final mulExpr = pp.string('mul') & pp.char('(') & digit & pp.char(',') & digit & pp.char(')');

final mulExprParser = mulExpr.map((value) {
  final a = value[2] as int;
  final b = value[4] as int;
  return MulExpr(a, b);
});
final doParser = doo.map((value) => Do());
final dontParser = dont.map((value) => Dont());
final exprParser = (mulExprParser | doParser | dontParser).cast<Expr>();
