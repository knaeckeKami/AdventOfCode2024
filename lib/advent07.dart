import 'dart:io';
import 'package:collection/collection.dart';

void main() {
  final file = File('input07.txt');

  final lines = file.readAsLinesSync();

  final calibrations = lines.map((line) {
    final parts = line.split(':');
    final value = int.parse(parts[0]);

    final values = parts[1].trim().split(' ').map(int.parse).toList();
    return Calibration(value, values);
  }).toList();

  final validTestSum = calibrations.where(canFindValidConfiguratinon).map((e) => e.value).sum;

  print(validTestSum);
}

class Calibration {
  final int value;

  final List<int> values;

  const Calibration(this.value, this.values);

  @override
  String toString() {
    return 'Calibration{value: $value, values: $values}';
  }
}

sealed class BinaryOperation {
  const BinaryOperation();

  int eval(int a, int b);
}

class AddOperation extends BinaryOperation {
  const AddOperation();

  @override
  int eval(int a, int b) {
    return a + b;
  }
}

class MultiplyOperation extends BinaryOperation {
  const MultiplyOperation();

  @override
  int eval(int a, int b) {
    return a * b;
  }
}

class ConcatOperation extends BinaryOperation {
  const ConcatOperation();

  @override
  int eval(int a, int b) {
    return int.parse('$a$b');
  }
}

List<BinaryOperation> possibleOperations() => const [
      AddOperation(),
      MultiplyOperation(),
      ConcatOperation(),
    ];

bool canFindValidConfiguratinon(Calibration calibration) {
  final testValue = calibration.value;

  final [acc, ...rest] = calibration.values;

  return _canFindValidConfiguration(testValue, acc, rest);
}

bool _canFindValidConfiguration(int testValue, int acc, List<int> rest) {
  if (rest.isEmpty) {
    return acc == testValue;
  }

  for (final operation in possibleOperations()) {
    final nextValue = rest.first;
    final nextRest = rest.skip(1).toList();

    final newAcc = operation.eval(acc, nextValue);

    if (_canFindValidConfiguration(testValue, newAcc, nextRest)) {
      return true;
    }
  }

  return false;
}
