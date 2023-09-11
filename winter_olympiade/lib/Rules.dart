import 'package:flutter/material.dart';


import 'package:olympiade/utils/Soundboard.dart';
class GameRule {
  final String name;
  final List<String> rules;

  GameRule(this.name, this.rules);
}

final List<GameRule> gameRules = [
  GameRule('Allgemeines, Alkohol', [
    'Gespielt wird in Zweierteams. Es ist nicht erlaubt, dass ein Teampartner aussetzt!',
    'Ist es Zeit, um zu wechseln und ein Ende des Spiels ist nicht in Sicht, wird das Spiel entweder als Unentschieden gewertet (Darts, nicht Jenga!) oder das Team gewinnt, das punktemäßig vorne liegt (Bierpong, Kicker, Billard, Kubb).',
    'Bei einer Rundenzeit von nur 10 Minuten darf nicht getrödelt werden. Insbesondere bei Bierpong und Tischkicker muss das Spiel zügig begonnen und durchgeführt werden. Bei Meinungsverschiedenheiten, die sich nicht mithilfe des nachstehenden Regelwerks ausräumen lassen, muss sich schnell geeinigt werden. Wir haben nicht viel Zeit!',
    'Sollte am Ende das Gesamtergebnis nicht eindeutig sein, wird der Gesamtsieg/die Gesamtplatzierung mittels Gummischuss auf die Nase des Holzhampelmanns in der Küche entschieden. Wer die Nase zuerst trifft, ohne dass der Gegner trifft, gewinnt.',
    'Es muss fleißig getrunken werden. Wer nichts oder nicht ausreichend getrunken hat, wird disqualifiziert!',
  ]),
  GameRule('Kicker', [
    '• Ein Spiel geht bis 10 Punkte.',
    '• Das Durchdrehen der Kickerstangen (Trillern) ist verboten.',
    '• Verlässt der Ball das Spielfeld wird er an der nächstgelegenen Ecke zurück ins Spiel gebracht. Passiert dies in der Mitte des Tischs, wird er in der Mitte neu eingeworfen',
    '• Nach einem erzielten Tor darf der Ball von dem Team in der Mitte eingeworfen werden, das nicht gepunktet hat.',
    '• Ein Torwart-Tor zählt nicht doppelt.',
  ]),
  GameRule('Darts', [
    '• Gespielt wird ein klassisches Dartsspiel 501.',
    '• Das Spiel muss nicht mit einem Double beendet werden.',
    '• Es wird sich im Team abgewechselt; die Reihenfolge darf nicht geändert werden.',
    '• Das Spiel endet Unentschieden, wenn bei Rundenwechsel kein Sieger feststeht.',
  ]),
  GameRule('Billard', [
    'Es ist eng. Damit muss jeder leben. Bitte passt auf Queues und das Klavier auf! Im Team wird sich jeweils abgewechselt. Die Reihenfolge darf nicht geändert werden.',
    '• Die Kugeln werden wie gezeigt aufgebaut. Die oberste Kugel liegt dabei auf der Markierung.',
    '• Die weiße Kugel wird von der Kopflinie aus gespielt (waagerechte Linie durch den markierten Punkt).',
    '• Vor einem Stoß muss die Kugel angesagt werden, die gelocht werden soll. Ein Ansagen der richtigen Tasche ist nur bei der schwarzen Acht nötig.',
    '• Bei einem Foul darf der Gegner die weiße Kugel frei auf dem Tisch platzieren (Ball-in-Hand).',
    '• Wird eine gegnerische Kugel gelocht, ohne dass ein Foul begangen wird, kommt der Gegner an die Reihe. Dieser hat dann jedoch kein Ball-in-Hand!',
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
    'Gespielt wird mit sechs Bechern. Die letzten drei Becher befinden sich jeweils an der hinteren Kante des Tisches, die anderen beiden pyramidenförmig davor. Im Sinne der Spielfähigkeit der Kontrahenten sind die Becher nur mit Wasser gefüllt. Es darf dennoch ausgiebig getrunken werden!',
    '• Die Ellenbogen müssen hinter dem Tisch bleiben. Ist dies nicht der Fall, ist der Wurf zwar getan, jedoch ungültig.',
    '• Ist der Ball bereits einmal auf der Platte aufgekommen, kann er weggeschlagen werden. Trifft ein so gespielter Ball dennoch, müssen zwei Becher vom Tisch. Diesen darf das getroffene Team wählen.',
    '• Das Herauspusten des Balls ist nicht erlaubt.',
    '• Treffen beide Spieler in einen Becher, erhalten diese die Bälle zurück. Wird derselbe Becher getroffen, kommt ein zusätzlicher Becher weg (nicht alle drumherum!).',
    '• Steht ein Becher allein, darf je Spieler einmal pro Spiel „Island“ gerufen werden. Trifft er den angesagten Becher, muss ein extra Becher weggestellt werden. Wird ein anderer Becher getroffen, zählt dieser Wurf nicht.',
    '• Kommt ein Ball über die Hälfte des Tisches zurück und gelingt es dem diesseitigen Team, den Ball zu erlangen, darf dieses einen zusätzlichen Trick-Shot-Wurf ausführen.',
    '• Die Becher dürfen einmal pro Spiel umgestellt werden',
    '• Es gibt keinen Nachwurf!',
  ]),
  GameRule('Kubb', [
    '• Der Aufbau erfolgt so wie auf dem Bild. Ziel des Spiels ist es, mit den Wurfstöcken alle Kubbs in der gegnerischen Hälfte umzuwerfen. Gelingt dies, darf - für den Sieg - der König umgeworfen werden.',
    '• Wurde ein Kubb im eigenen Feld umgeworfen, muss dieser Kubb vor den eigenen Wurfstabwürfen in das gegnerische Feld geworfen werden. Wenn ein Kubb nicht im gegnerischen Feld liegen bleibt, darf der Wurf einmal wiederholt werden. Beim zweiten Fehlversuch darf der Gegner den Kubb selbst platzieren. Diese Kubbs müssen vor einem Wurf auf die Linienkubbs umgeworfen werden.',
    '• Trifft man mit einem geworfenen Kubb einen schon im Feld liegenden Kubb ("Feldkubb"; gemeint sind nicht die Linienkubbs des Gegners), werden die Kubbs gestapelt. Es ist auch möglich, dass man in den ersten beiden Würfen zwei Kubbs weit auseinander wirft, dann aber mit dem dritten Wurf die beiden Kubbs berührt. Dann werden alle Kubbs aufeinandergestapelt. Gestapelt wird durch den Gegner. Dieser darf dabei wählen, welchen Kubb er als Basis nimmt; an diesem Ort entsteht dann der Turm. Der Basiskubb wird dabei an dem Ort aufgestellt, wo er liegen bleibt. Beim Aufstellen darf dieser in jede Richtung aufgeklappt werden.',
    '• Hat man alle zuvor gefallenen Kubbs geworfen, muss man sie umwerfen, bevor man die Linienkubbs des Gegners umwerfen darf. Fällt ein Linienkubb bevor nicht alle Feldkubbs umgeworfen wurden, wird dieser wieder aufgestellt.',
    '• Fällt ein Feldkubb nach einem Wurfstabwurf, wird der jeweilige Feldkubb aus dem Spiel entfernt.',
    '• Hat es ein Spieler nicht geschafft, alle Feldkubbs umzuwerfen, darf der Gegner bis auf die Höhe des jeweiligen Feldkubbs vorrücken und seine nächsten Wurfstabwürfe von dort ausführen. Umgefallene Kubbs müssen weiterhin von der Basislinie geworfen werden.',
    '• Wird der König umgeworfen bevor alle gegnerischen Kubbs umgeworfen wurden, gilt das Spiel als verloren.',
    '• Hat man alle gegnerischen Kubbs umgeworfen, darf man auf den König werfen. Dieser Wurf muss jedoch rückwärts durch die eigenen Beine erfolgen.',
    '• Der Wurfstabwurf darf nur unter Schulterhöhe erfolgen. Der Wurfstab darf sich dabei nur vertikal drehen. Ein waagerecht rotierender Wurf ("Helikopterwurf") und waagerechte Würfe an sich sind verboten.',
    '• Fallen die Kubbs durch Eigenverschulden, gelten sie als vom Gegner umgeworfen.',
  ]),
  GameRule('Jenga', [
    'Gespielt wird mit Schachuhr. Der Boden ist uneben und leicht zu erschüttern. Damit muss jeder klarkommen.',
    'Der Boden um den Turm herum soll mit Decken ausgelegt werden, um den Boden zu schützen.',
    'Gespielt wird mit vier Minuten pro Spieler.',
    'Nach dem Spiel müssen der Turm wieder aufgebaut und die Decken wieder hingelegt werden. Beim Wiederaufbau des Turms ist zu beachten, dass die Ausrichtung der Steine übereinstimmt. Die breitere Seite muss nach oben zeigen.',
    '• Es muss ein Stein aus dem Turm gezogen werden und oben auf dem Turm platziert werden.',
    '• Es darf nur mit einer Hand gespielt werden!',
    '• Ein Stein darf erst aus dem Turm gezogen werden, wenn mindestens drei Steine über ihm liegen.',
    '• Es ist legitim, sich für einen anderen Stein zu entscheiden. Jedoch muss ein vorher herausgezogener Stein zunächst wieder in den Stapel zurückgeschoben werden.',
    '• Das Spiel ist verloren, wenn...',
    '   - die Zeit eines Spielers abläuft',
    '   - der Turm umfällt, während die eigene Zeit noch läuft.',
  ]),
  GameRule('Bewertung', [
    'Nach jedem Spiel wird das Ergebnis durch die beiden Teams in der ausgehängten Wertungstabelle festgehalten und in der App eingetragen (1 für Sieg; 0 für Niederlage; ½ für Unentschieden) -> Disziplin-Punkte.',
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
      body: ListView(
        children: <Widget>[
          // Button hier einfügen
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FilledButton.tonal(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SoundBoard()),
                );
              },
              child: const Text(
                'Soundeffekte Beispiele',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          // ExpansionTiles hier einfügen
          ...gameRules.map((ruleItem) {
            return ExpansionTile(
              title: Text(ruleItem.name),
              children: <Widget>[
                if (ruleItem.name == 'Billard')
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Image.asset('assets/billardaufbau.png'),
                  ),
                if (ruleItem.name == 'Kubb')
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Image.asset('assets/kubbaufbau.png'),
                  ),
                ...ruleItem.rules.map((rule) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: Text(rule),
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

