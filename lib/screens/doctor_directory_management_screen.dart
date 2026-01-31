import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../services/doctor_directory_service.dart';

class DoctorDirectoryManagementScreen extends StatefulWidget {
  const DoctorDirectoryManagementScreen({super.key});

  @override
  State<DoctorDirectoryManagementScreen> createState() =>
      _DoctorDirectoryManagementScreenState();
}

class _DoctorDirectoryManagementScreenState
    extends State<DoctorDirectoryManagementScreen> {
  late Future<List<DoctorProfile>> _doctorsFuture;
  bool _checkingAccess = true;
  bool _isVerifiedDoctor = false;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = DoctorDirectoryService.instance.getAllDoctors();
    _loadAccess();
  }

  Future<void> _loadAccess() async {
    final info = await AuthService.instance.getUserInfo();
    final role = info['role'] ?? 'client';
    final license = info['license'] ?? '';
    if (!mounted) return;
    setState(() {
      _isVerifiedDoctor = role == 'doctor' && license.trim().isNotEmpty;
      _checkingAccess = false;
    });
  }

  void _refresh() {
    setState(() {
      _doctorsFuture = DoctorDirectoryService.instance.getAllDoctors();
    });
  }

  Future<void> _syncFromCloud() async {
    final success = await DoctorDirectoryService.instance.syncFromCloud();
    if (!mounted) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Directory synced from cloud.'
              : 'Cloud sync failed. Check Firebase config.',
          style: GoogleFonts.plusJakartaSans(),
        ),
      ),
    );
  }

  Future<void> _syncToCloud() async {
    final success = await DoctorDirectoryService.instance.syncToCloud();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Directory uploaded to cloud.'
              : 'Cloud upload failed. Check Firebase config.',
          style: GoogleFonts.plusJakartaSans(),
        ),
      ),
    );
  }

  Future<void> _showDoctorForm({DoctorProfile? doctor}) async {
    final nameController = TextEditingController(text: doctor?.name ?? '');
    final specialtyController = TextEditingController(
      text: doctor?.specialty ?? '',
    );
    final hospitalController = TextEditingController(
      text: doctor?.hospital ?? '',
    );
    bool available = doctor?.available ?? true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor == null ? 'Add doctor' : 'Edit doctor',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: specialtyController,
                    decoration: const InputDecoration(
                      labelText: 'Specialty',
                      prefixIcon: Icon(Icons.medical_services_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: hospitalController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital or clinic',
                      prefixIcon: Icon(Icons.local_hospital_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    value: available,
                    onChanged: (value) =>
                        setSheetState(() => available = value),
                    title: Text(
                      'Available for consult',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final specialty = specialtyController.text.trim();
                        final hospital = hospitalController.text.trim();

                        if (name.isEmpty ||
                            specialty.isEmpty ||
                            hospital.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please fill out all fields.',
                                style: GoogleFonts.plusJakartaSans(),
                              ),
                            ),
                          );
                          return;
                        }

                        final service = DoctorDirectoryService.instance;
                        if (doctor == null) {
                          final newDoctor = DoctorProfile(
                            id: 'doc-${DateTime.now().millisecondsSinceEpoch.toString()}',
                            name: name,
                            specialty: specialty,
                            hospital: hospital,
                            available: available,
                          );
                          await service.addDoctor(newDoctor);
                        } else {
                          await service.updateDoctor(
                            doctor.copyWith(
                              name: name,
                              specialty: specialty,
                              hospital: hospital,
                              available: available,
                            ),
                          );
                        }

                        if (!mounted) return;
                        Navigator.of(context).pop();
                        _refresh();
                      },
                      child: Text(
                        doctor == null ? 'Add doctor' : 'Save changes',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(DoctorProfile doctor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove doctor',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Remove ${doctor.name} from the directory?',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DoctorDirectoryService.instance.deleteDoctor(doctor.id);
      if (!mounted) return;
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Doctor directory',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        actions: _checkingAccess
            ? []
            : [
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _refresh,
                ),
                if (_isVerifiedDoctor) ...[
                  IconButton(
                    tooltip: 'Sync from cloud',
                    icon: const Icon(Icons.cloud_download_rounded),
                    onPressed: _syncFromCloud,
                  ),
                  IconButton(
                    tooltip: 'Upload to cloud',
                    icon: const Icon(Icons.cloud_upload_rounded),
                    onPressed: _syncToCloud,
                  ),
                ],
              ],
      ),
      floatingActionButton: _checkingAccess || !_isVerifiedDoctor
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showDoctorForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add doctor'),
            ),
      body: _checkingAccess
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            )
          : !_isVerifiedDoctor
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF6366F1),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Verified doctors only',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add or edit directory entries is only available to doctor accounts with a license number on file.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : FutureBuilder<List<DoctorProfile>>(
              future: _doctorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                    ),
                  );
                }

                final doctors = snapshot.data ?? [];
                if (doctors.isEmpty) {
                  return Center(
                    child: Text(
                      'No doctors added yet.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final d = doctors[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF6366F1),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${d.specialty} • ${d.hospital}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  d.available
                                      ? 'Available for consult'
                                      : 'Not available right now',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: d.available
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit_rounded),
                            onPressed: () => _showDoctorForm(doctor: d),
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: const Color(0xFFEF4444),
                            onPressed: () => _confirmDelete(d),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
