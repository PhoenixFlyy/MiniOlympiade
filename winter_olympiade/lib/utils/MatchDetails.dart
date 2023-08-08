class MatchDetails {
  final String opponent;
  final int discipline;

  MatchDetails({required this.opponent, required this.discipline});
}
class Break {
   int roundNumber;  // nach welcher Runde die Pause beginnt
   int duration;     // Dauer der Pause in Minuten

  Break({required this.roundNumber, required this.duration});
}