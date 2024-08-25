import 'package:audioplayers/audioplayers.dart';

Future<void> playStartSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("gamestart.wav"));
}

Future<void> playWhooshSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("whoosh.mp3"));
}

Future<void> playWhistleSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("whistle.mp3"));
}

Future<void> playSiuuuSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("siuuu.mp3"));
}

Future<void> playVillagerSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("villager.mp3"));
}

Future<void> playYeetSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("yeet.mp3"));
}



Future<void> playgongakkuratSound() async {
  final player = AudioPlayer();
  player.setVolume(5.0);
  player.play(AssetSource("gongakkurat.mp3"));
}