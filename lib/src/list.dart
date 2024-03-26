// TODO Create a proper grid type.
import 'dart:core';

extension ListListExt on List<List<double>> {
  ({double min, double max}) get minMax {
    if (isEmpty) {
      throw StateError('List is empty');
    }

    if (this[0].isEmpty) {
      throw StateError('First row is empty');
    }

    var min = this[0][0];
    var max = min;

    for (int i = 0; i < length; i++) {
      final row = this[i];
      for (int j = 0; j < row.length; j++) {
        if (row[j] < min) {
          min = row[j];
        } else if (row[j] > max) {
          max = row[j];
        }
      }
    }

    return (min: min, max: max);
  }
}

extension ListExt on List<double> {
  ({double min, double max}) get minMax {
    if (isEmpty) {
      throw StateError('List is empty');
    }

    var min = this[0];
    var max = min;

    for (int i = 1; i < length; i++) {
      if (this[i] < min) {
        min = this[i];
      } else if (this[i] > max) {
        max = this[i];
      }
    }

    return (min: min, max: max);
  }
}

extension ListExt2<T> on List<T> {
  /// Remove all the elements in [removed] from [this].
  // TODO Find a more dart way of doing this.
  List<T> removeAll(List<T> removed) {
    for (int i = 0; i < removed.length; i++) {
      remove(removed[i]);
    }
    return this;
  }
}
