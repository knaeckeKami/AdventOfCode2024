import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'dart:math';

void main() {
  final file = File('input07.txt');

  final lines = file.readAsLinesSync();

  final calibrations = lines.map((line) {
    final parts = line.split(':');
    final value = int.parse(parts[0]);

    final values = parts[1].trim().split(' ').map(int.parse).toList();
    return Calibration(value, Uint64List.fromList(values));
  }).toList();

  final validTestSum = calibrations.where(canFindValidConfiguratinon).map((e) => e.value).sum;

  print(validTestSum);
}

class Calibration {
  final int value;

  final Uint64List values;

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
    final digits = log(b) ~/ ln10 + 1;

    return (a * pow(10, digits) + b).toInt();
  }
}

List<BinaryOperation> possibleOperations() => const [
      AddOperation(),
      MultiplyOperation(),
      ConcatOperation(),
    ];

bool canFindValidConfiguratinon(Calibration calibration) {
  final testValue = calibration.value;

  final values = calibration.values;

  final acc = values.first;

  return _canFindValidConfiguration(testValue, acc, values, 1);
}

bool _canFindValidConfiguration(int testValue, int acc, Uint64List list, int index) {
  if (list.length == index) {
    return acc == testValue;
  }

  for (final operation in possibleOperations()) {
    final nextValue = list[index];

    final newAcc = operation.eval(acc, nextValue);

    if (_canFindValidConfiguration(testValue, newAcc, list, index + 1)) {
      return true;
    }
  }

  return false;
}
