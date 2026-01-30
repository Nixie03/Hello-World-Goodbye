import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// Simple WAV generator: 16-bit PCM, mono
List<int> generateSineWav(double freqHz, double seconds, int sampleRate) {
  final totalSamples = (sampleRate * seconds).toInt();
  final bytesPerSample = 2; // 16-bit
  final data = Int16List(totalSamples);
  for (var i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final amplitude = 0.7 * 32767; // 70% volume
    final sample = (amplitude * sin(2 * pi * freqHz * t)).toInt();
    data[i] = sample;
  }

  final byteData = ByteData(44 + totalSamples * bytesPerSample);
  // RIFF header
  byteData.setUint8(0, 'R'.codeUnitAt(0));
  byteData.setUint8(1, 'I'.codeUnitAt(0));
  byteData.setUint8(2, 'F'.codeUnitAt(0));
  byteData.setUint8(3, 'F'.codeUnitAt(0));
  byteData.setUint32(4, 36 + totalSamples * bytesPerSample, Endian.little); // file size
  byteData.setUint8(8, 'W'.codeUnitAt(0));
  byteData.setUint8(9, 'A'.codeUnitAt(0));
  byteData.setUint8(10, 'V'.codeUnitAt(0));
  byteData.setUint8(11, 'E'.codeUnitAt(0));

  // fmt chunk
  byteData.setUint8(12, 'f'.codeUnitAt(0));
  byteData.setUint8(13, 'm'.codeUnitAt(0));
  byteData.setUint8(14, 't'.codeUnitAt(0));
  byteData.setUint8(15, ' '.codeUnitAt(0));
  byteData.setUint32(16, 16, Endian.little); // fmt chunk size
  byteData.setUint16(20, 1, Endian.little); // PCM
  byteData.setUint16(22, 1, Endian.little); // channels
  byteData.setUint32(24, sampleRate, Endian.little); // sample rate
  byteData.setUint32(28, sampleRate * bytesPerSample, Endian.little); // byte rate
  byteData.setUint16(32, bytesPerSample, Endian.little); // block align
  byteData.setUint16(34, 16, Endian.little); // bits per sample

  // data chunk header
  byteData.setUint8(36, 'd'.codeUnitAt(0));
  byteData.setUint8(37, 'a'.codeUnitAt(0));
  byteData.setUint8(38, 't'.codeUnitAt(0));
  byteData.setUint8(39, 'a'.codeUnitAt(0));
  byteData.setUint32(40, totalSamples * bytesPerSample, Endian.little);

  // PCM samples
  var offset = 44;
  for (var i = 0; i < totalSamples; i++) {
    byteData.setInt16(offset, data[i], Endian.little);
    offset += 2;
  }

  return byteData.buffer.asUint8List();
}

Future<void> writeFile(String path, List<int> bytes) async {
  final file = File(path);
  await file.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
  print('Wrote: $path');
}

Future<void> main() async {
  const sampleRate = 44100;
  const duration = 1.2; // seconds

  final chime = generateSineWav(880.0, duration, sampleRate);
  final softBell = generateSineWav(660.0, duration, sampleRate);

  // Fade envelope small to make nicer
  // (Not strictly necessary for such short tones)

  final assetsDir = Directory('assets/ringtones');
  if (!assetsDir.existsSync()) assetsDir.createSync(recursive: true);

  await writeFile('assets/ringtones/chime.wav', chime);
  await writeFile('assets/ringtones/soft_bell.wav', softBell);

  // Android raw
  final androidRaw = Directory('android/app/src/main/res/raw');
  if (!androidRaw.existsSync()) androidRaw.createSync(recursive: true);
  await writeFile('android/app/src/main/res/raw/chime.wav', chime);
  await writeFile('android/app/src/main/res/raw/soft_bell.wav', softBell);

  // iOS Runner bundle directory (place files; adding to Xcode project may be required)
  final iosRunner = Directory('ios/Runner');
  if (!iosRunner.existsSync()) iosRunner.createSync(recursive: true);
  await writeFile('ios/Runner/chime.wav', chime);
  await writeFile('ios/Runner/soft_bell.wav', softBell);

  print('Ringtones generated successfully.');
}
