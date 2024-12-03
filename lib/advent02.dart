import 'dart:io';

void main() {
  File inputFile = File('input02.txt');

  List<String> lines = inputFile.readAsLinesSync();

  List<List<int>> numbers = lines.map(parseLine).toList();

  List<bool> valids = numbers.map(validateWithOneAllowedFailure).toList();

  print(valids.where((e) => e).length);

  for (var i = 0; i < numbers.length; i++) {
    print("${numbers[i]}->${validateWithOneAllowedFailure(numbers[i])}");
  }
}

List<int> parseLine(String line) {
  return line.split(' ').map(int.parse).toList();
}

bool validate(List<int> nums) {
  if (nums.isEmpty || nums.length == 1) {
    return true;
  }

  int lastDiff = nums[1] - nums[0];

  if (lastDiff == 0) {
    return false;
  }

  if (lastDiff.abs() > 3) {
    return false;
  }

  for (var i = 1; i < nums.length - 1; i++) {
    int diff = nums[i + 1] - nums[i];
    if (diff == 0) {
      return false;
    }
    if (diff.abs() > 3) {
      return false;
    }
    final ok = diff.isNegative == lastDiff.isNegative;

    if (!ok) {
      return false;
    }
    lastDiff = diff;
  }
  return true;
}

bool validateWithOneAllowedFailure(List<int> nums) {
  if (validate(nums)) {
    return true;
  }

  for (var i = 0; i < nums.length; i++) {
    List<int> copy = List.from(nums);
    copy.removeAt(i);
    if (validate(copy)) {
      return true;
    }
  }

  return false;
}
