import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class PrescriptionStorageService {
  static final PrescriptionStorageService instance =
      PrescriptionStorageService._internal();
  PrescriptionStorageService._internal();

  Future<String> saveToDevice(Uint8List bytes, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final safeName = _sanitize(filename);
    final file = File('${dir.path}/prescriptions/$safeName');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<String?> uploadToCloud(Uint8List bytes, String filename) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (_) {
      return null; // Firebase not configured
    }

    final safeName = _sanitize(filename);
    final ref = FirebaseStorage.instance
        .ref()
        .child('prescriptions')
        .child('${DateTime.now().millisecondsSinceEpoch}_$safeName');

    final task = await ref.putData(
      bytes,
      SettableMetadata(contentType: _contentTypeFor(filename)),
    );
    return task.ref.getDownloadURL();
  }

  String _sanitize(String name) {
    return name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  String _contentTypeFor(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    return 'application/octet-stream';
  }
}
