import 'package:flutter/material.dart';

// Helper extension for reshaping lists, common in TFLite input/output.
extension ReshapeList<T> on List<T> {
  List<dynamic> reshape(List<int> shape) {
    if (shape.isEmpty) return this;

    List<T> flatList = List<T>.from(this);

    List<dynamic> reshape(List<T> list, List<int> currentShape) {
      if (currentShape.length == 1) {
        return List<T>.from(list.take(currentShape[0]));
      }
      List<dynamic> result = [];
      int nextDimSize = currentShape.length > 1 && currentShape[0] != 0 ? list.length ~/ currentShape[0] : list.length;
      if (currentShape[0] == 0) {
          return [];
      }

      for (int i = 0; i < currentShape[0]; i++) {
        if (list.length < (i + 1) * nextDimSize && currentShape.length > 1) {
            debugPrint("Warning: Not enough elements for full reshape, check dimensions and list size.");
            break;
        }
        result.add(reshape(list.sublist(i * nextDimSize, (i + 1) * nextDimSize), currentShape.sublist(1)));
      }
      return result;
    }
    return reshape(flatList, shape);
  }
} 