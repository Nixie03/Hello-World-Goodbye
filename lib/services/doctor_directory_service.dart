import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorProfile {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final bool available;

  DoctorProfile({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.available,
  });

  DoctorProfile copyWith({
    String? id,
    String? name,
    String? specialty,
    String? hospital,
    bool? available,
  }) {
    return DoctorProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      hospital: hospital ?? this.hospital,
      available: available ?? this.available,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'hospital': hospital,
      'available': available,
    };
  }

  static DoctorProfile fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      hospital: json['hospital'] as String,
      available: json['available'] as bool? ?? false,
    );
  }
}

class DoctorDirectoryService {
  static final DoctorDirectoryService instance = DoctorDirectoryService._();
  DoctorDirectoryService._();

  static const String _storageKey = 'doctor_directory_v1';

  Future<List<DoctorProfile>> getAllDoctors() async {
    await _ensureSeeded();
    return _loadDoctors();
  }

  Future<List<DoctorProfile>> getDoctorsForHospital(String hospital) async {
    final all = await getAllDoctors();
    return all
        .where((d) => d.hospital.toLowerCase() == hospital.toLowerCase())
        .toList();
  }

  Future<void> addDoctor(DoctorProfile doctor) async {
    final all = await getAllDoctors();
    all.add(doctor);
    await _saveDoctors(all);
  }

  Future<void> updateDoctor(DoctorProfile updated) async {
    final all = await getAllDoctors();
    final index = all.indexWhere((d) => d.id == updated.id);
    if (index >= 0) {
      all[index] = updated;
      await _saveDoctors(all);
    }
  }

  Future<void> deleteDoctor(String id) async {
    final all = await getAllDoctors();
    all.removeWhere((d) => d.id == id);
    await _saveDoctors(all);
  }

  Future<bool> syncToCloud() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final all = await getAllDoctors();
      final payload = jsonEncode(all.map((e) => e.toJson()).toList());
      final ref = FirebaseStorage.instance
          .ref()
          .child('doctor_directory')
          .child('directory_v1.json');
      await ref.putString(
        payload,
        format: PutStringFormat.raw,
        metadata: SettableMetadata(contentType: 'application/json'),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> syncFromCloud() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final ref = FirebaseStorage.instance
          .ref()
          .child('doctor_directory')
          .child('directory_v1.json');
      final data = await ref.getData(5 * 1024 * 1024);
      if (data == null) return false;
      final decoded = jsonDecode(utf8.decode(data)) as List<dynamic>;
      final doctors = decoded
          .map((e) => DoctorProfile.fromJson(e as Map<String, dynamic>))
          .toList();
      await _saveDoctors(doctors);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _ensureSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) return;

    final seed = [
      DoctorProfile(
        id: 'doc-001',
        name: 'Dr. Maria Santos',
        specialty: 'Internal Medicine',
        hospital: 'City General Hospital',
        available: true,
      ),
      DoctorProfile(
        id: 'doc-002',
        name: 'Dr. Paolo Reyes',
        specialty: 'Cardiology',
        hospital: 'City General Hospital',
        available: false,
      ),
      DoctorProfile(
        id: 'doc-003',
        name: 'Dr. Angela Cruz',
        specialty: 'Family Medicine',
        hospital: 'St. Mary Clinic',
        available: true,
      ),
      DoctorProfile(
        id: 'doc-004',
        name: 'Dr. Ramon Dela Rosa',
        specialty: 'Pulmonology',
        hospital: 'Green Valley Health Center',
        available: true,
      ),
      DoctorProfile(
        id: 'doc-005',
        name: 'Dr. Liza Navarro',
        specialty: 'Endocrinology',
        hospital: 'Riverbend Medical',
        available: false,
      ),
    ];

    await _saveDoctors(seed);
  }

  Future<List<DoctorProfile>> _loadDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => DoctorProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveDoctors(List<DoctorProfile> doctors) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(doctors.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
