import 'dart:math';

class KNN {
  final int k;
  late List<List<double>> X_train;
  late List<int> y_train;

  KNN(this.k);

  void fit(List<List<double>> X, List<int> y) {
    X_train = X;
    y_train = y;
  }

  int predict(List<double> X) {
    final List<double> distances = [];
    for (final List<double> x_train in X_train) {
      double distance = 0.0;
      for (int i = 0; i < X.length; i++) {
        distance += pow(X[i] - x_train[i], 2);
      }
      distances.add(sqrt(distance));
    }

    List<int> kIndices = List<int>.generate(X_train.length, (i) => i)
      ..sort((a, b) => distances[a].compareTo(distances[b]));

    kIndices = kIndices.sublist(0, k);

    final List<int> kNearestLabels = kIndices.map((i) => y_train[i]).toList();

    final Map<int, int> labelCounts = {};
    for (final int label in kNearestLabels) {
      labelCounts[label] = (labelCounts[label] ?? 0) + 1;
    }

    int mostCommonLabel = kNearestLabels[0];
    int mostCommonCount = 0;

    labelCounts.forEach((label, count) {
      if (count > mostCommonCount) {
        mostCommonLabel = label;
        mostCommonCount = count;
      }
    });

    return mostCommonLabel;
  }
}
