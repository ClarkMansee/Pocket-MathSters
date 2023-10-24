import 'dart:math';

class SARSAAgent {
  Map<String, Map<String, double>> Q = {};
  double alpha;
  double gamma;
  double epsilon;
  String? state;
  String? action;

  SARSAAgent({this.alpha = 0.1, this.gamma = 0.9, this.epsilon = 0.1});

  String chooseAction(String state) {
    if (Random().nextDouble() < 0.4) {
      // 60% chance
      return 'wrong';
    } else {
      return 'right';
    }
  }

  void update(String state, String action, double reward, String nextState, String nextAction) {
    Q[state] ??= {'right': 0.0, 'wrong': 0.0};
    Q[nextState] ??= {'right': 0.0, 'wrong': 0.0};
    Q[state]![action] = Q[state]![action]! + alpha * (reward + gamma * Q[nextState]![nextAction]! - Q[state]![action]!);
  }

  void setStateAction(String state, String action) {
    this.state = state;
    this.action = action;
  }

  String chooseNextDifficulty(String currentDifficulty, String action) {
    print(action);
    List<String> difficulties = ['easy', 'medium', 'hard'];
    Map<String, double> deductedQValues = {};

    // Calculate deducted Q-values
    for (var difficulty in difficulties) {
      double rightQValue = Q[difficulty]?['right'] ?? 0.0;
      double wrongQValue = (Q[difficulty]?['wrong'] ?? 0.0).abs();
      deductedQValues[difficulty] = rightQValue - wrongQValue;
    }

    // Find difficulty with the highest right and deducted Q-values
    String maxRightDifficulty = difficulties.reduce((value, element) =>
      (Q[value]?['right'] ?? 0.0) > (Q[element]?['right'] ?? 0.0) ? value : element);
    String maxDeductedDifficulty = difficulties.reduce((value, element) =>
      deductedQValues[value]! > deductedQValues[element]! ? value : element);

    print("curr: $currentDifficulty");
    print("dedu: $maxDeductedDifficulty");
    print("right: $maxRightDifficulty");

    // Determine next difficulty based on given conditions
    int nextDifficultyIndex;
    if (maxRightDifficulty == maxDeductedDifficulty) {
      if (currentDifficulty == maxRightDifficulty) {
        nextDifficultyIndex = min(difficulties.indexOf(currentDifficulty) + 1, difficulties.length - 1);
      } else {
        nextDifficultyIndex = difficulties.indexOf(maxRightDifficulty);
      }
    } else if (currentDifficulty == maxRightDifficulty) {
      if (currentDifficulty == maxDeductedDifficulty) {
        // Ask a higher difficulty question if possible
        nextDifficultyIndex = min(difficulties.indexOf(currentDifficulty) + 1, difficulties.length - 1);
      } else {
        // Ask a lower difficulty question if possible
        nextDifficultyIndex = max(difficulties.indexOf(currentDifficulty) - 1, 0);
      }
    } else if (currentDifficulty == maxDeductedDifficulty) {
      // Ask same difficulty question
      nextDifficultyIndex = difficulties.indexOf(currentDifficulty);
    } else {
      // Ask a lower difficulty question if possible
      nextDifficultyIndex = max(difficulties.indexOf(currentDifficulty) - 1, 0);
    }

    print(nextDifficultyIndex);
    return difficulties[nextDifficultyIndex];
  }
}

void main() {
  var agent = SARSAAgent();
  int counter = 0;
  String state = 'easy';
  String action = agent.chooseAction(state);
  // Rest of your implementation logic
}