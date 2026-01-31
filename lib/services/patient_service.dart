import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Patient {
  final String id;
  final String name;
  final String? email;

  Patient({required this.id, required this.name, this.email});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String?,
  );
}

class PatientService {
  static final PatientService instance = PatientService._();
  PatientService._();

  static const _keyPatients = 'doctor_patients';
  final _uuid = const Uuid();

  Future<List<Patient>> getPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyPatients) ?? [];
    return list
        .map(
          (item) => Patient.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<Patient> addPatient({required String name, String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    final patients = await getPatients();
    final patient = Patient(id: _uuid.v4(), name: name, email: email);
    patients.add(patient);
    await _savePatients(prefs, patients);
    return patient;
  }

  Future<void> updatePatient(Patient updated) async {
    final prefs = await SharedPreferences.getInstance();
    final patients = await getPatients();
    final index = patients.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      patients[index] = updated;
      await _savePatients(prefs, patients);
    }
  }

  Future<void> deletePatient(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final patients = await getPatients();
    patients.removeWhere((p) => p.id == id);
    await _savePatients(prefs, patients);
  }

  Future<void> _savePatients(
    SharedPreferences prefs,
    List<Patient> patients,
  ) async {
    final encoded = patients.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_keyPatients, encoded);
  }
}
