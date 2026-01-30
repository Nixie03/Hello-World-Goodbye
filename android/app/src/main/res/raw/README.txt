Place your custom notification audio files here (Android expects them in res/raw):

- Recommended names used by the app: chime.wav, soft_bell.wav
- For Android notification raw resources, the file name is referenced without extension in code (e.g., RawResourceAndroidNotificationSound('chime')).
- The `tools/generate_ringtones.dart` script will generate short sample .wav tones and place them here and in `assets/ringtones/`.
- Replace these placeholder files with other short .ogg/.mp3/.wav files (mono, ~1-3 seconds) for best results.

Tip: After adding files here, rebuild the app so Android includes them in the APK.