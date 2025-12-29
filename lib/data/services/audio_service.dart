import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playShakeMusic() async {
    if (_isPlaying) return;

    try {
      _isPlaying = true;
      await _audioPlayer.play(AssetSource('audio/music.mp3'));
      
      // Reset flag when playback completes
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
      // Silently fail if audio file doesn't exist or can't be played
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
