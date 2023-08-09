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
