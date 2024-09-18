import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playStartSound() async {
    _audioPlayer.setVolume(5.0);
    await _audioPlayer.setAsset('assets/audio/gamestart.wav');
    _audioPlayer.play();
  }

  Future<void> playWhooshSound() async {
    _audioPlayer.setVolume(5.0);
    await _audioPlayer.setAsset('assets/audio/whoosh.mp3');
    _audioPlayer.play();
  }

  Future<void> playWhistleSound() async {
    _audioPlayer.setVolume(5.0);
    await _audioPlayer.setAsset('assets/audio/whistle.mp3');
    _audioPlayer.play();
  }

  Future<void> playSiuuuSound() async {
    _audioPlayer.setVolume(5.0);
    await _audioPlayer.setAsset('assets/audio/siuuu.mp3');
    _audioPlayer.play();
  }

  Future<void> playVillagerSound() async {
    _audioPlayer.setVolume(5.0);
    await _audioPlayer.setAsset('assets/audio/villager.mp3');
    _audioPlayer.play();
  }

  Future<void> playYeetSound() async {
    _audioPlayer.setVolume(5.0);
    await _audioPlayer.setAsset('assets/audio/yeet.mp3');
    _audioPlayer.play();
  }

  Future<void> playGongAkkuratSound() async {
    _audioPlayer.setVolume(5.0);
    await _audioPlayer.setAsset('assets/audio/gongakkurat.mp3');
    _audioPlayer.play();
  }

  Future<void> playAlarmSound() async {
    _audioPlayer.setVolume(5.0);
    await _audioPlayer.setAsset('assets/audio/alarm.mp3');
    _audioPlayer.play();
  }
}