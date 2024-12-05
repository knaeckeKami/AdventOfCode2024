import 'dart:io';
import 'package:collection/collection.dart';

void main() {
  final file = File('input05.txt');

  final lines = file.readAsLinesSync();

  final [rawRules, rawUpdates] = lines.splitBefore((line) => line.isEmpty).toList();

  final rules = rawRules.map(parseBefore).toList();

  final updates = rawUpdates.skip(1).map(parseUpdate).toList();

  int lineNum = 0;

  final updateStates = updates
      .map((update) => UpdateStates(
            update,
            lineNum++,
          ))
      .toList();

  print(rules);

  print(updates);

  for (final update in updateStates) {
    print(update);
  }

  final validStates = updateStates
      .where((state) => state.states.every((state) => validateUpdateState(state, rules)))
      .toList();

  for (final state in validStates) {
    print(state);
  }

  final middleNums = validStates.map(middleNum).toList();

  print(middleNums);

  final sum = updateStates
      .where((state) => state.states.any((state) => !validateUpdateState(state, rules)))
      .map((state) =>
          Ordering.createFromRules(rules, state.states.map((state) => state.value).toList()))
      .map(middleNumFromOrdering)
      .sum;

  print(sum);
}

/// a rule that states that the first value must come before the second value
class BeforeRule {
  int before;
  int after;

  BeforeRule(this.before, this.after);

  @override
  String toString() => 'Before($before, $after)';
}

class Ordering {
  final List<int> order;

  final Map<int, List<int>> beforeMap;

  Ordering._(this.order, this.beforeMap);

  factory Ordering.createFromRules(List<BeforeRule> rules, List<int> values) {
    rules =
        rules.where((rule) => values.contains(rule.before) && values.contains(rule.after)).toList();

    final set = rules.fold<Set<int>>({}, (set, rule) {
      set.add(rule.before);
      set.add(rule.after);
      return set;
    });

    final roots = <int>{};

    // find any values which do not have any values that must come before them
    for (final value in set) {
      final beforeValues =
          rules.where((rule) => rule.before == value).map((rule) => rule.before).toList();
      if (beforeValues.isEmpty) {
        roots.add(value);
      }
    }

    print('Roots: $roots');

    assert(roots.length == 1, 'Invalid roots: $roots');

    final root = roots.first;

    final Map<int, List<int>> beforeMap = {};

    beforeMap[root] = [];

    for (final rule in rules) {
      if (!beforeMap.containsKey(rule.before)) {
        beforeMap[rule.before] = [];
      }
      beforeMap[rule.before]!.add(rule.after);
    }

    print('Before map: $beforeMap');

    final ordering = <int>[];

    for (final value in beforeMap.entries
        .sortedBy<num>((entry) => entry.value.length)
        .map((entry) => entry.key)) {
      ordering.add(value);
    }

    return Ordering._(ordering, beforeMap);
  }

  @override
  String toString() {
    return order.join(',');
  }
}

BeforeRule parseBefore(String line) {
  final parts = line.split('|');

  assert(parts.length == 2, 'Invalid line: $line');

  final first = int.parse(parts[0].trim());
  final second = int.parse(parts[1].trim());

  return BeforeRule(first, second);
}

class Update {
  final List<int> positions;

  const Update(this.positions);

  @override
  String toString() => 'Update($positions)';
}

class UpdateStates {
  final int lineNum;

  late final List<UpdateState> states;

  UpdateStates(Update update, this.lineNum) {
    states = [];
    final beforeList = <int>[];
    final afterList = List.of(update.positions.skip(1));

    for (final position in update.positions) {
      states.add(UpdateState(position, List.of(beforeList), List.of(afterList)));
      beforeList.add(position);
      if (afterList.isNotEmpty) {
        afterList.removeAt(0);
      }
    }
  }

  @override
  String toString() => 'UpdateStates($lineNum, $states)';
}

Update parseUpdate(String line) {
  final parts = line.split(',');

  final positions = parts.map(int.parse).toList();

  return Update(positions);
}

class UpdateState {
  final int value;

  final List<int> beforeValues;

  final List<int> afterValues;

  UpdateState(this.value, this.beforeValues, this.afterValues);

  @override
  String toString() => 'UpdateState($value, $beforeValues, $afterValues)';
}

bool validateUpdateState(UpdateState state, List<BeforeRule> rules) {
  for (final after in state.afterValues) {
    final violatedRule =
        rules.firstWhereOrNull((rule) => rule.before == after && rule.after == state.value);

    if (violatedRule != null) {
      return false;
    }
  }

  return true;
}

int middleNum(UpdateStates states) {
  final vals = states.states.map((state) => state.value).toList();

  final middle = vals[vals.length ~/ 2];

  return middle;
}

int middleNumFromOrdering(Ordering ordering) {
  final vals = ordering.order;

  final middle = vals[vals.length ~/ 2];

  return middle;
}
