class Achievement {
  final String image;
  final String title;
  final String description;
  bool hidden;
  bool isCompleted;
  bool isDisabled;

  Achievement({
    required this.image,
    required this.title,
    required this.description,
    this.hidden = false,
    this.isCompleted = false,
    this.isDisabled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'hidden': hidden,
      'isDisabled': isDisabled,
    };
  }

  static Achievement fromJson(Map<String, dynamic> json) {
    return Achievement(
      image: json['image'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      hidden: json['hidden'] ?? false,
      isDisabled: json['isDisabled'] ?? false,
    );
  }
}

// Note: When changing the title or order please also adjust he eventFlag
final List<Achievement> defaultAchievements = [
  Achievement(
    image: "assets/icon/play_store_512.png",
    title: "Nerd",
    description: "Die Jagd beginnt!",
    isCompleted: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie2.PNG',
    title: 'First Blood!',
    description: 'Gewinne in der ersten Runde',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie3.PNG',
    title: 'Oh no, the perfect score!',
    description: 'Verliere deine erste Disziplin',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie4.PNG',
    title: 'Ein erster Schritt zum Sieg',
    description: 'Schlage den ersten Gegner',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie5.PNG',
    title: 'Diesmal nicht!',
    description: 'Besiege einen der Sieger der Vorjahre',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie6.PNG',
    title: 'Win Streak!',
    description: 'Gewinne drei Disziplinen hintereinander',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie7.PNG',
    title: 'Gotta Catch \'Em All',
    description: 'Gewinne in jeder Disziplin mindestens einmal',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie8.PNG',
    title: 'Mr. Consistent',
    description: 'Sei in jeder Disziplin unter den Top 3',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie9.PNG',
    title: 'Winner Winner Chicken Dinner',
    description: 'Gewinne das Event',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie10.PNG',
    title: 'Ruhige Hände',
    description: 'Gewinne in Jenga',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie11.PNG',
    title: 'Holzfäller!',
    description: 'Gewinne in Kubb',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie12.PNG',
    title: 'Einloch-Experte',
    description: 'Gewinne in Billard',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie13.PNG',
    title: 'Ab in den Ally Pally!',
    description: 'Gewinne in Darts',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie14.PNG',
    title: 'Noch nüchtern? Die Gegner nicht mehr!',
    description: 'Gewinne in Bierpong',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie15.PNG',
    title: 'Meeessssiiii!',
    description: 'Gewinne in Kicker',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie16.PNG',
    title: 'Mein Teampartner ist schuld!',
    description: 'Verliere in jeder Disziplin mindestens einmal',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie17.PNG',
    title: 'Comeback?',
    description: 'Gewinne nachdem du mind. 3 mal verloren hast',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie18.PNG',
    title: 'Nicht aufzuhalten!',
    description: 'Gewinne in einer Disziplin gegen alle anderen',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie19.PNG',
    title: 'Kanonenfutter',
    description: 'Verliere in einer Disziplin gegen alle anderen',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie20.PNG',
    title: 'Ungespielt Moment',
    description: 'Gewinne fünf Disziplinen hintereinander',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie21.PNG',
    title: 'Hochstapler',
    description: 'Gewinne oder verliere ein Jengaspiel auf Zeit',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie22.PNG',
    title: 'Halbzeit!',
    description: 'Halte bis zur Pause durch',
  ),
  Achievement(
    image: 'assets/achievements/Folie23.PNG',
    title: 'Schreiberling',
    description: 'Trage die Ergebnisse ein',
  ),
  Achievement(
    image: 'assets/achievements/Folie24.PNG',
    title: 'Kurzer Prozess',
    description: 'Trage die Ergebnisse schon nach 5 min ein',
    isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie25.PNG',
    title: 'Chess GM',
    description: 'Gewinne Jenga mit über 2:30 Restzeit',
    //isDisabled: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie26.PNG',
    title: 'Sehr photogen!',
    description: 'Mache ein Foto von dir',
  ),
  Achievement(
    image: 'assets/achievements/Folie27.PNG',
    title: 'Umgekehrte Psychologie',
    description: 'Werfe eine Triple 1',
  ),
  Achievement(
    image: 'assets/achievements/Folie28.PNG',
    title: 'Mehr geht nicht!',
    description: 'Werfe eine Triple 20',
  ),
  Achievement(
    image: 'assets/achievements/Folie29.PNG',
    title: 'Bullseye!',
    description: 'Werfe ein double oder single Bullseye',
  ),
  Achievement(
    image: 'assets/achievements/Folie30.PNG',
    title: 'Verlaufen?',
    description: 'Verbringe mindestens 1 Minute im Laufplan-Screen',
  ),
  Achievement(
    image: 'assets/achievements/Folie31.PNG',
    title: 'Nimm es ganz genau!',
    description: 'Schaue in den Regeln nach',
    hidden: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie32.PNG',
    title: 'Bücherwurm',
    description: 'Lies dir alle Regeln durch',
    hidden: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie33.PNG',
    title: 'Flappy Chick',
    description: 'Erreiche 10 Punkte in Flappy Bird',
  ),
  Achievement(
    image: 'assets/achievements/Folie34.PNG',
    title: 'Flappy Eagle',
    description: 'Erreiche 50 Punkte in Flappy Bird',
    hidden: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie35.PNG',
    title: 'Gomme Mode',
    description: 'Spiele einen Soundeffekt ab',
  ),
  Achievement(
    image: 'assets/achievements/Folie36.PNG',
    title: 'Annoying Bastard',
    description: 'Spiele alle Soundeffekte ab',
    hidden: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie37.PNG',
    title: 'Lass es regnen',
    description: 'Löse einen Konfettiregen aus',
  ),
  Achievement(
    image: 'assets/achievements/Folie38.PNG',
    title: 'Regenschauer',
    description: 'Löse 3 mal den Konfettiregen aus',
  ),
  Achievement(
    image: 'assets/achievements/Folie39.PNG',
    title: 'Taifun',
    description: 'Löse 10 mal den Konfettiregen aus',
    hidden: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie40.PNG',
    title: 'Cookie Clicker',
    description: 'Löse 100 mal den Konfettiregen aus',
    hidden: true,
  ),
  Achievement(
    image: 'assets/achievements/Folie41.PNG',
    title: 'Coole Socke!',
    description: 'Füge deinem Namen mindestens zwei „X“ hinzu',
  ),
  Achievement(
    image: 'assets/achievements/Folie42.PNG',
    title: 'Barista',
    description: 'Spendiere dem Dev einen Kaffee',
  ),
];
