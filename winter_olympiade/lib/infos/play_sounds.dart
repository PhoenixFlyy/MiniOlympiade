import 'package:audioplayers/audioplayers.dart';

Future<void> playStartSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("audio/gamestart.wav"));
}

Future<void> playWhooshSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("audio/whoosh.mp3"));
}

Future<void> playWhistleSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("audio/whistle.mp3"));
}

Future<void> playSiuuuSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("audio/siuuu.mp3"));
}

Future<void> playVillagerSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("audio/villager.mp3"));
}

Future<void> playYeetSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("audio/yeet.mp3"));
}

Future<void> playgongakkuratSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("audio/gongakkurat.mp3"));
}

Future<void> playAlarmSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource('audio/alarm.mp3'));
}