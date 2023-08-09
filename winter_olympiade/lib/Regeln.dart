import 'package:flutter/material.dart';

class GameRule {
  final String name;
  final List<String> rules;

  GameRule(this.name, this.rules);
}

final List<GameRule> gameRules = [
  GameRule('Allgemeines', [
    'Gespielt wird in Zweierteams. Es ist nicht erlaubt, dass ein Teampartner aussetzt!',
    'Es wird gewechselt, wenn der Gong geschlagen wird. Wird der Gong geschlagen und ein Ende des Spiels ist nicht in Sicht, wird das Spiel entweder als Unentschieden gewertet (Darts) oder das Team gewinnt, das punktemäßig vorne liegt (Bierpong, Kicker, Billard).',
    'Bei einer Rundenzeit von nur 10 Minuten darf nicht getrödelt werden. Insbesondere bei Bierpong und Tischkicker muss das Spiel zügig begonnen und durchgeführt werden. Bei Meinungsverschiedenheiten, die sich nicht mithilfe des nachstehenden Regelwerks ausräumen lassen, muss sich schnell geeinigt werden. Wir haben nicht viel Zeit!',
    'Es beginnt immer das Team, dessen Nummer es anzeigt. Ist keine Nummer gegeben, muss sich so geeinigt werden.',
  ]),
  GameRule('Kicker', [
    '• Ein Spiel geht bis 10 Punkte.',
    '• Das Durchdrehen der Kickerstangen (Trillern) ist verboten.',
    '• Verlässt der Ball das Spielfeld wird er an der nächstgelegenen Ecke zurück ins Spiel gebracht. Passiert dies in der Mitte des Tischs, wird er in der Mitte neu eingeworfen',
    '• Nach einem erzielten Tor darf der Ball von dem Team in der Mitte eingeworfen werden, das nicht gepunktet hat.',
    '• Ein Torwart-Tor zählt nicht doppelt.',
  ]),
  GameRule('Darts', [
    '• Gespielt wird ein klassisches Dartsspiel 301.',
    '• Das Spiel muss nicht mit einem Double beendet werden.',
    '• Es wird sich im Team abgewechselt; die Reihenfolge darf nicht geändert werden.',
    '• Das Spiel endet Unentschieden, wenn bei Gongschlag kein Sieger feststeht.',
  ]),
  GameRule('Billard', [
    'Es ist eng. Damit muss jeder leben. Bitte passt auf Queues und das Klavier auf! Im Team wird sich jeweils abgewechselt. Die Reihenfolge darf nicht geändert werden.',
    '• Die Kugeln werden wie gezeigt aufgebaut. Die oberste Kugel liegt dabei auf der Markierung.',
    '• Die weiße Kugel wird von der Kopflinie aus gespielt (waagerechte Linie durch den markierten Punkt).',
    '• Vor einem Stoß muss die Kugel angesagt werden, die gelocht werden soll. Ein Ansagen der richtigen Tasche ist nur bei der schwarzen Acht nötig.',
    '• Bei einem Foul darf der Gegner die weiße Kugel frei auf dem Tisch platzieren (Ball-in-Hand).',
    '• Wird eine gegnerische Kugel gelocht, ohne dass ein Foul begangen wird, kommt der Gegner ans Spiel. Dieser hat dann jedoch kein Ball-in-Hand!',
    '• Ein Foul liegt vor, wenn...',
    '   - Die weiße Kugel keine andere Kugel berührt.',
    '   - Die weiße Kugel zuerst auf eine gegnerische (oder schwarze) Kugel trifft.',
    '   - Die weiße Kugel in eine Tasche fällt.',
    '   - Eine Kugel mit etwas anderem als der Queue-Spitze berührt wird.',
    '   - Die weiße Kugel zweimal berührt wird.',
    '   - Eine Kugel beim Stoß noch in Bewegung ist.',
    '   - Nicht mindestens ein Bein auf dem Boden ist.',
    '   - Eine Kugel vom Tisch springt (Kugel wird dann auf dem Punkt neu eingesetzt).',
    '   - (Die weiße Kugel zwar eine eigene Kugel trifft, danach aber weder eine Bande berührt, noch eine eigene Kugel versenkt wird.)',
    '• Das Spiel ist verloren, wenn...',
    '   - Die schwarze Kugel in Verbindung mit einem Foul gelocht wird.',
    '   - Die schwarze Kugel gelocht wird, obwohl noch eigene Kugeln zu lochen sind.',
    '   - Die Acht in eine andere Tasche gespielt wurde als angesagt wurde.',
  ]),
  GameRule('Bierpong', [
    'Gespielt wird mit sechs Bechern. Im Sinne der Spielfähigkeit der Kontrahenten sind die Becher nur mit Wasser gefüllt. Es darf dennoch ausgiebig getrunken werden!',
    '• Die Ellenbogen müssen hinter dem Tisch bleiben. Ist dies nicht der Fall, ist der Wurf zwar getan, jedoch ungültig.',
    '• Ist der Ball bereits einmal auf der Platte aufgekommen, kann er weggeschlagen werden. Trifft ein so gespielter Ball dennoch, müssen zwei Becher vom Tisch. Diesen darf das getroffene Team wählen.',
    '• Das Herauspusten des Balls ist nicht erlaubt.',
    '• Treffen beide Spieler in einen Becher, erhalten diese die Bälle zurück. Wird derselbe Becher getroffen, kommt ein zusätzlicher Becher weg (nicht alle drumherum!).',
    '• Steht ein Becher allein, darf je Spieler einmal pro Spiel „Island“ gerufen werden. Trifft er den angesagten Becher, muss ein extra Becher weggestellt werden. Wird ein anderer Becher getroffen, zählt dieser Wurf nicht.',
    '• Kommt ein Ball über die Hälfte des Tisches zurück und gelingt es dem diesseitigen Team, den Ball zu erlangen, darf dieses einen zusätzlichen Trick-Shot-Wurf ausführen.',
    '• Es gibt keinen Nachwurf!',
  ]),
  GameRule('Kubb', [
    '• Wer als Team zuerst im Ziel angekommen ist, gewinnt. Gespielt wird immer in denselben Autos...',
    '• Jeder Spieler darf nur sein eigenes Auto fahren. Es werden immer dieselben beiden Strecken gefahren...',
    '• Nach dem Spiel müssen die Strecken neu ausgewählt werden, sodass sofort wieder losgespielt werden kann.',
  ]),
  GameRule('Jenga', [
    'Gespielt wird mit Schachuhr. Der Boden ist uneben und leicht zu erschüttern. Damit muss jeder klarkommen.',
    'Der Boden um den Turm herum soll mit Decken ausgelegt werden, um den Boden zu schützen.',
    'Gespielt wird mit vier Minuten pro Spieler. Nach dem Spiel müssen der Turm wieder aufgebaut, die Decken wieder hingelegt und die Schachuhr zurückgesetzt werden.',
    '• Es muss ein Stein aus dem Turm gezogen werden und oben auf den Turm platziert werden.',
    '• Es darf nur mit einer Hand gespielt werden!',
    '• Ein Stein darf erst aus dem Turm gezogen werden, wenn mindestens drei Steine über ihm liegen.',
    '• Es ist legitim, sich für einen anderen Stein zu entscheiden. Jedoch muss ein vorher herausgezogener Stein zunächst wieder in den Stapel zurückgeschoben werden.',
    '• Das Spiel ist verloren, wenn...',
    '   - die Zeit eines Spielers abläuft',
    '   - der Turm umfällt, während die eigene Zeit noch läuft.',
  ]),
  GameRule('Bewertung', [
    'Nach jedem Spiel wird das Ergebnis durch die beiden Teams in der ausgehängten Wertungstabelle festgehalten (1 für Sieg; 0 für Niederlage; ½ für Unentschieden) -> Disziplin-Punkte.',
    'Am Ende des Abends werden die Punkte pro Disziplin zusammengezählt und die Gesamtpunktzahl wird ermittelt. Pro Disziplin werden dabei 1-6 Gesamtpunkte vergeben; also maximal 21 Gesamtpunkte. Bei gleich vielen Disziplin-Punkten wird der Durchschnitt der entsprechenden Gesamtpunkte gebildet und auf die Spieler aufgeteilt.',
    'Beispiel: Haben drei Teams dieselbe Anzahl von Disziplin-Punkten, z.B. 2,5 Punkte, und belegen die anderen Teams die Plätze 1, 2 und 6 (es bleiben also 3-5) übrig, steht jedem der drei Teams dieselbe Punktzahl zu. Für die Plätze 3-5 sind 12 Gesamtpunkte zu vergeben. 12 Gesamtpunkte (3 + 4 + 5 = 12) aufgeteilt auf 3 Teams ergibt demnach 4 Gesamtpunkte pro Team. Die Gesamtpunkteverteilung in diesem Beispiel ist also: 6, 4, 4, 4, 2, 1 (= 21).',
  ]),
];

class RulesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regeln'),
      ),
      body: ListView.builder(
        itemCount: gameRules.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(gameRules[index].name),
            children: gameRules[index].rules.map((rule) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: Text(rule),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
