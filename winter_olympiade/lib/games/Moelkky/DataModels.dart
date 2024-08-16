class Player {
  String name;
  List<int> scores;

  Player({required this.name}) : scores = [0];
}

class Turn {
  List<int> knockedPins;
  int turnScore;

  Turn({required this.knockedPins, required this.turnScore});
}

class MoelkkyGame {
List<Player> players;
int currentPlayerIndex;
final int targetScore;

MoelkkyGame({
  required this.players,
  this.currentPlayerIndex = 0,
  this.targetScore = 50,
});

void nextTurn() => currentPlayerIndex = (currentPlayerIndex + 1) % players.length;

void calculateTurnScore(Turn turn) {
  if (turn.knockedPins.length == 1) {
    turn.turnScore = turn.knockedPins[0];
  } else {
    turn.turnScore = turn.knockedPins.length;
  }
}

void updatePlayerScore(Player player, int score) {
  int newScore = player.scores.last + score;

  if (newScore > targetScore) {
    newScore = 25;
  }

  player.scores.add(newScore);
}

void checkWinCondition() {
  for (Player player in players) {
    if (player.scores.last == targetScore) {
      print("${player.name} wins!");
    }
  }
}
}