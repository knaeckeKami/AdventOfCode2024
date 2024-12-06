import 'dart:io';
import 'package:collection/collection.dart';

void main() {
  final file = File('input06.txt');

  final lines = file.readAsLinesSync();

  final gameTable =
      GameTable(lines.map((line) => line.split('').map(parseInputChar).toList()).toList());

  print(gameTable);

  print('');

  final copyGameTable = gameTable.copy();

  do {
    final result = copyGameTable.nextState();

    if (result == NextStateResult.exit) {
      break;
    }

    if (result == NextStateResult.loop) {
      break;
    }
  } while (true);

  print(copyGameTable);

  print(copyGameTable.countVisited());

  final rowCount = gameTable.rowCount;

  final colCount = gameTable.colCount;

  int loopCount = 0;

  for (var i = 0; i < rowCount; i++) {
    print('---------- Checking $i, ----------------\n');

    for (var j = 0; j < colCount; j++) {
      if (gameTable.get(i, j) case EmptyField()) {
        final copyGame = gameTable.copy();

        copyGame.set(i, j, const ObstacleField());

        do {
          final result = copyGame.nextState();
          //print(result);
          if (result == NextStateResult.exit) {
            //print('Exit $loopCount');
            break;
          }

          if (result == NextStateResult.loop) {
            print('Loop $loopCount');
            loopCount++;
            break;
          }
        } while (true);
      } else {
        //print('Not empty, was ${gameTable.get(i, j)}');
        //assert(gameTable.get(i, j) is! VisitedField);
      }
    }
  }

  print(loopCount);
}

GameField parseInputChar(String char) {
  return switch (char) {
    '.' => const EmptyField(),
    'v' => const GuardField(Direction.down, null),
    '^' => const GuardField(Direction.up, null),
    '<' => const GuardField(Direction.left, null),
    '>' => const GuardField(Direction.right, null),
    '#' => const ObstacleField(),
    _ => throw ArgumentError('Invalid char: $char'),
  };
}

enum Direction {
  up,
  down,
  left,
  right;

  Direction turnRight() {
    return switch (this) {
      up => right,
      right => down,
      down => left,
      left => up,
    };
  }
}

sealed class GameField {
  const GameField();

  GameField visit(Direction direction);
}

class EmptyField extends GameField {
  const EmptyField();

  @override
  String toString() => '.';

  @override
  GameField visit(Direction direction) {
    return GuardField(direction, null);
  }
}

class VisitedField extends GameField {
  late final Set<Direction> directions;

  VisitedField({required Set<Direction> directions}) {
    this.directions = Set.unmodifiable(directions);
  }

  @override
  String toString() => 'X';

  @override
  GameField visit(Direction direction) {
    return GuardField(direction, this);
  }
}

class GuardField extends GameField {
  final Direction direction;

  final VisitedField? before;

  const GuardField(this.direction, this.before);

  @override
  String toString() {
    return switch (direction) {
      Direction.up => '^',
      Direction.down => 'v',
      Direction.left => '<',
      Direction.right => '>',
    };
  }

  @override
  GameField visit(Direction direction) {
    throw StateError('Cannot visit guard');
  }
}

class ObstacleField extends GameField {
  const ObstacleField();

  @override
  String toString() => '#';

  @override
  GameField visit(Direction direction) {
    throw StateError('Cannot visit obstacle');
  }
}

class GameTable {
  final List<List<GameField>> table;

  GameTable(this.table)
      : assert(table.isNotEmpty),
        assert(table.every((row) => row.length == table[0].length));

  GameField get(int row, int col) {
    return table[row][col];
  }

  void set(int row, int col, GameField field) {
    table[row][col] = field;
  }

  int get rowCount => table.length;

  int get colCount => table[0].length;

  NextStateResult nextState() {
    (int, int, Direction, VisitedField?)? guardsPosition;

    out:
    for (var i = 0; i < rowCount; i++) {
      for (var j = 0; j < colCount; j++) {
        final field = get(i, j);

        if (field case GuardField(:final direction, :final before)) {
          guardsPosition = (i, j, direction, before);
          break out;
        }
      }
    }

    if (guardsPosition == null) {
      throw StateError('No guards found');
    }

    final (row, col, direction, before) = guardsPosition;

    final int nextRow;
    final int nextCol;

    switch (direction) {
      case Direction.up:
        nextRow = row - 1;
        nextCol = col;
        break;
      case Direction.down:
        nextRow = row + 1;
        nextCol = col;
        break;
      case Direction.left:
        nextRow = row;
        nextCol = col - 1;
        break;
      case Direction.right:
        nextRow = row;
        nextCol = col + 1;
        break;
    }

    if (nextRow < 0 || nextRow >= rowCount || nextCol < 0 || nextCol >= colCount) {
      set(
          row,
          col,
          VisitedField(directions: {
            direction,
            ...?before?.directions,
          }));
      return NextStateResult.exit;
    }

    final nextField = get(nextRow, nextCol);

    if (nextField case ObstacleField()) {
      set(
          row,
          col,
          GuardField(direction.turnRight(),
              VisitedField(directions: {direction, ...?before?.directions})));
      return NextStateResult.turn;
    } else {
      /*if (get(nextRow, nextCol) case VisitedField(directions: final newDirs)
          when newDirs.contains(direction)) {
        return NextStateResult.loop;
      }

      set(row, col, VisitedField(directions: {direction, ...?before?.directions}));

      final previousField = get(nextRow, nextCol);

      set(
        nextRow,
        nextCol,
        GuardField(
          direction,
          switch (previousField) {
            VisitedField() => previousField,
            _ => null,
          },
        ),
      ); */

      final previousField = get(nextRow, nextCol);

      if (previousField is VisitedField && previousField.directions.contains(direction)) {
        return NextStateResult.loop;
      }

      final nextNextField = nextField.visit(direction);

      set(nextRow, nextCol, nextNextField);

      set(
        row,
        col,
        before ?? VisitedField(directions: {direction}),
      );

      return NextStateResult.moved;
    }
  }

  @override
  String toString() {
    return table.map((row) => row.join()).join('\n');
  }

  int countVisited() {
    return table.expand((row) => row).whereType<VisitedField>().length;
  }

  GameTable copy() {
    return GameTable(table.map((row) => row.map((field) => field).toList()).toList());
  }
}

enum NextStateResult { exit, loop, moved, turn }
