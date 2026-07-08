import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _correctPlayer = AudioPlayer();
  static final AudioPlayer _wrongPlayer = AudioPlayer();
  static final AudioPlayer _victoryPlayer = AudioPlayer();
  static final AudioPlayer _clickPlayer = AudioPlayer();

  static bool isMuted = false;

  static Future<void> playCorrect() async {
    if (isMuted) return;
    try {
      await _correctPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      print('Erreur audio correct: $e');
    }
  }

  static Future<void> playWrong() async {
    if (isMuted) return;
    try {
      await _wrongPlayer.play(AssetSource('sounds/wrong.mp3'));
    } catch (e) {
      print('Erreur audio wrong: $e');
    }
  }

  static Future<void> playVictory() async {
    if (isMuted) return;
    try {
      await _victoryPlayer.play(AssetSource('sounds/victory.mp3'));
    } catch (e) {
      print('Erreur audio victory: $e');
    }
  }

  static Future<void> playClick() async {
    if (isMuted) return;
    try {
      await _clickPlayer.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      print('Erreur audio click: $e');
    }
  }

  static void toggleMute() {
    isMuted = !isMuted;
  }
}