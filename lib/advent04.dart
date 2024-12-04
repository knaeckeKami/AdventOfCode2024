import 'dart:io';

void main() {
  final inputFile = File('input04.txt');
  final lines = inputFile.readAsLinesSync();

  const word = "XMAS";
  final reversedWord = word.split('').reversed.join();

  final (forwardCount, reversedCount) = countForwardBackWards(lines, word, reversedWord);

  final rotated = rotate90Deg(lines);

  final (forwardCountRotated, reversedCountRotated) =
      countForwardBackWards(rotated, word, reversedWord);

  print(forwardCount + reversedCount + forwardCountRotated + reversedCountRotated);

  final table = toTable(lines);

  int diagonalCount = countDiagonal(table, word);
  int diagonalCountReversed = countDiagonal(table, reversedWord);

  int rotatedDiagonalCount = countDiagonal(toTable(rotated), word);
  int rotatedDiagonalCountReversed = countDiagonal(toTable(rotated), reversedWord);

  print(forwardCount +
      reversedCount +
      forwardCountRotated +
      reversedCountRotated +
      diagonalCount +
      diagonalCountReversed +
      rotatedDiagonalCount +
      rotatedDiagonalCountReversed);

  print(countMasSam(table));
}

(int, int) countForwardBackWards(List<String> lines, String word, String reversedWord) {
  int forwardCount = 0;
  int reversedCount = 0;

  for (final line in lines) {
    forwardCount += line.split(word).length - 1;
    reversedCount += line.split(reversedWord).length - 1;
  }

  return (forwardCount, reversedCount);
}

List<List<String>> toTable(List<String> lines) {
  final table = <List<String>>[];

  for (final line in lines) {
    table.add(line.split(''));
  }
  final length = table[0].length;

  for (final row in table) {
    assert(row.length == length);
    for (final cell in row) {
      assert(cell.length == 1);
    }
  }

  return table;
}

int countDiagonal(List<List<String>> table, String word) {
  int count = 0;

  for (var i = 0; i < table.length; i++) {
    for (var j = 0; j < table[i].length; j++) {
      if (i + word.length <= table.length && j + word.length <= table[i].length) {
        final diagonal = <String>[];

        for (var k = 0; k < word.length; k++) {
          diagonal.add(table[i + k][j + k]);
        }

        if (diagonal.join() == word) {
          count++;
        }
      }
    }
  }

  return count;
}

List<String> rotate90Deg(List<String> list) {
  final rotated = <String>[];

  for (var i = 0; i < list.length; i++) {
    final sb = StringBuffer();

    for (var j = list.length - 1; j >= 0; j--) {
      sb.write(list[j][i]);
    }

    rotated.add(sb.toString());
  }

  return rotated;
}

int countMasSam(List<List<String>> table) {
  /// find SAM OR MAS, diagonally,
  /// occuring in an X
  /// like this
  /// M.S
  /// .A.
  /// S.M
  const mas = ['M', 'A', 'S'];
  const sam = ['S', 'A', 'M'];

  int count = 0;

  for (var i = 0; i < table.length; i++) {
    for (var j = 0; j < table[i].length; j++) {
      if (i + 2 < table.length && j + 2 < table[i].length) {
        final diagonal = <String>[];

        for (var k = 0; k < 3; k++) {
          diagonal.add(table[i + k][j + k]);
        }

        if (diagonal.join() == mas.join() || diagonal.join() == sam.join()) {
          final diagonal2 = <String>[];
          // need to check the other diagonal
          for (var k = 0; k < 3; k++) {
            diagonal2.add(table[i + k][j + 2 - k]);
          }
          if (diagonal2.join() == mas.join() || diagonal2.join() == sam.join()) {
            count++;
          }
        }
      }
    }
  }

  return count;
}
