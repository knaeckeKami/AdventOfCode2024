import 'dart:io';

void main() async {
  final file = File('input08.txt');

  final lines = file.readAsLinesSync();

  final fieldLines = lines.map((line) => line.split('').map(Field.parse).toList()).toList();

  final fields = Fields(fieldLines);

  final antiNodePositions = fields.getAntiNodePositions();

  final uniqueAnitNodePositions = antiNodePositions.map((e) => (e.$2, e.$3)).toSet();

  print(fields.printWithAnitNodePositions());

  print(uniqueAnitNodePositions.length);
}

final identiferRegex = RegExp(r'[a-zA-Z0-9]');

Map<String, List<(int, int)>> extractAntennaPositions(List<List<Field>> fields) {
  final antennaPositions = <String, List<(int, int)>>{};

  for (var y = 0; y < fields.length; y++) {
    for (var x = 0; x < fields[y].length; x++) {
      final field = fields[y][x];

      if (field case AntennaField(:final antennaId)) {
        antennaPositions.putIfAbsent(antennaId, () => []).add((x, y));
      }
    }
  }

  return antennaPositions;
}

class Fields {
  final List<List<Field>> fields;

  final Map<String, List<(int, int)>> antennaPositions;

  final int width;
  final int height;

  Fields(List<List<Field>> fields)
      : assert(fields.isNotEmpty),
        assert(fields.first.isNotEmpty),
        assert(fields.every((row) => row.length == fields.first.length)),
        fields = List.of(fields.map((row) => List.of(row))),
        antennaPositions = extractAntennaPositions(fields),
        width = fields.first.length,
        height = fields.length;

  @override
  String toString() {
    return fields.map((row) => row.map((field) => field.toString()).join()).join('\n');
  }

  String printWithAnitNodePositions() {
    final copyField = Fields(fields);

    for (final (_, x, y) in getAntiNodePositions()) {
      copyField.fields[y][x] = AnitNodeField();
    }

    return copyField.toString();
  }

  List<(String, int, int)> getAntiNodePositions() {
    final antiNodePositions = <(String, int, int)>[];

    for (final id in antennaPositions.keys) {
      final antennas = antennaPositions[id]!;
      for (int i = 0; i < antennas.length; i++) {
        final (x, y) = antennas[i];

        for (int j = i + 1; j < antennas.length; j++) {
          final (x2, y2) = antennas[j];

          antiNodePositions.add((id, x, y));
          antiNodePositions.add((id, x2, y2));

          final (deltaX, deltaY) = (x2 - x, y2 - y);

          var (currentX, currentY) = (x, y);

          do {
            currentX += deltaX;
            currentY += deltaY;

            if ((currentX < 0 || currentX >= width || currentY < 0 || currentY >= height)) {
              break;
            }

            antiNodePositions.add((id, currentX, currentY));
          } while (true);

          (currentX, currentY) = (x, y);

          do {
            currentX -= deltaX;
            currentY -= deltaY;

            if ((currentX < 0 || currentX >= width || currentY < 0 || currentY >= height) ||
                (currentX == x2 && currentY == y2)) {
              break;
            }

            antiNodePositions.add((id, currentX, currentY));
          } while (true);
        }
      }
    }
    return antiNodePositions;
  }
}

sealed class Field {
  const Field();

  factory Field.parse(String value) {
    return switch (value) {
      '.' || '#' => const EmptyField(),
      final id when identiferRegex.hasMatch(id) => AntennaField(id),
      _ => throw ArgumentError('Invalid field value: $value'),
    };
  }

  @override
  String toString() {
    return switch (this) {
      EmptyField() => '.',
      AntennaField(antennaId: final id) => id,
      AnitNodeField() => '#',
    };
  }
}

class EmptyField extends Field {
  const EmptyField();
}

class AntennaField extends Field {
  final String antennaId;
  const AntennaField(this.antennaId);
}

class AnitNodeField extends Field {
  const AnitNodeField();
}
