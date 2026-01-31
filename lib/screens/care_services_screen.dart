import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/places_service.dart';
import 'doctor_directory_screen.dart';
import '../services/prescription_storage_service.dart';

class CareServicesScreen extends StatefulWidget {
  const CareServicesScreen({super.key});

  @override
  State<CareServicesScreen> createState() => _CareServicesScreenState();
}

class _CareServicesScreenState extends State<CareServicesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _selectedHospital = 'Select a nearby hospital';
  String _paymentMethod = 'Card';
  String _deliverySpeed = 'Standard';
  String? _prescriptionName;
  String? _localPrescriptionPath;
  String? _cloudPrescriptionUrl;
  bool _uploadingPrescription = false;
  String? _doctorAvailability;
  String? _hospitalAvailability;
  bool _checkingDoctor = false;
  bool _checkingHospital = false;
  final TextEditingController _hospitalSearchController =
      TextEditingController();
  bool _searchingHospitals = false;
  String? _hospitalSearchError;
  List<PlaceHospital> _hospitalResults = [];

  final List<String> _hospitals = [
    'Select a nearby hospital',
    'City General Hospital',
    'St. Mary Clinic',
    'Green Valley Health Center',
    'Riverbend Medical',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hospitalSearchController.dispose();
    super.dispose();
  }

  Future<void> _checkDoctorAvailability() async {
    setState(() => _checkingDoctor = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final available = Random().nextBool();
    if (!mounted) return;
    setState(() {
      _checkingDoctor = false;
      _doctorAvailability = available
          ? 'Doctor available now'
          : 'No doctor available right now';
    });
  }

  Future<void> _checkHospitalAvailability() async {
    setState(() => _checkingHospital = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final available = Random().nextBool();
    if (!mounted) return;
    setState(() {
      _checkingHospital = false;
      _hospitalAvailability = available
          ? 'Appointments available today'
          : 'No appointment slots available today';
    });
  }

  Future<void> _searchHospitals() async {
    final query = _hospitalSearchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searchingHospitals = true;
      _hospitalSearchError = null;
      _hospitalResults = [];
    });

    final results = await PlacesService().searchHospitals(
      query: 'hospital in $query',
    );

    if (!mounted) return;
    setState(() {
      _searchingHospitals = false;
      _hospitalResults = results;
      if (PlacesService.apiKey == 'YOUR_GOOGLE_PLACES_API_KEY') {
        _hospitalSearchError =
            'Add your Google Places API key to enable search.';
      } else if (results.isEmpty) {
        _hospitalSearchError = 'No hospitals found. Try another location.';
      }
    });
  }

  Future<void> _pickPrescription() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    setState(() {
      _prescriptionName = file.name;
      _localPrescriptionPath = null;
      _cloudPrescriptionUrl = null;
      _uploadingPrescription = true;
    });

    final localPath = await PrescriptionStorageService.instance.saveToDevice(
      bytes,
      file.name,
    );
    final cloudUrl = await PrescriptionStorageService.instance.uploadToCloud(
      bytes,
      file.name,
    );

    if (!mounted) return;
    setState(() {
      _localPrescriptionPath = localPath;
      _cloudPrescriptionUrl = cloudUrl;
      _uploadingPrescription = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cloudUrl == null
              ? 'Saved locally. Cloud not configured.'
              : 'Saved locally and uploaded to cloud.',
          style: GoogleFonts.plusJakartaSans(),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
    );
  }

  Widget _infoNote(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Care Services',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Consult'),
            Tab(text: 'Hospital'),
            Tab(text: 'Delivery'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConsultTab(),
          _buildHospitalTab(),
          _buildDeliveryTab(),
        ],
      ),
    );
  }

  Widget _buildConsultTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Online Consultation'),
          const SizedBox(height: 10),
          Text(
            'Connect with a licensed clinician for guidance and non‑emergency concerns.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Describe your concern',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _sectionTitle('Doctor Availability'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _doctorAvailability == null
                            ? Icons.help_outline_rounded
                            : (_doctorAvailability!.contains('available')
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded),
                        size: 16,
                        color: _doctorAvailability == null
                            ? const Color(0xFF94A3B8)
                            : (_doctorAvailability!.contains('available')
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _doctorAvailability ?? 'Not checked yet',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _checkingDoctor ? null : _checkDoctorAvailability,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(_checkingDoctor ? 'Checking...' : 'Check'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionTitle('Payment Method'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            items: [
              'Card',
              'Mobile Money',
              'Insurance',
            ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _paymentMethod = v ?? 'Card'),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.video_call_rounded),
              label: const Text('Start Consultation'),
            ),
          ),
          const SizedBox(height: 12),
          _infoNote(
            'For emergencies, contact local emergency services or visit a hospital immediately.',
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Nearby Hospital'),
          const SizedBox(height: 8),
          TextField(
            controller: _hospitalSearchController,
            decoration: InputDecoration(
              labelText: 'City or area (e.g., Quezon City, Cebu)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _searchingHospitals ? null : _searchHospitals,
                  icon: const Icon(Icons.search_rounded),
                  label: Text(_searchingHospitals ? 'Searching...' : 'Search'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_hospitalSearchError != null)
            Text(
              _hospitalSearchError!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFFEF4444),
              ),
            )
          else if (_hospitalResults.isNotEmpty)
            Column(
              children: _hospitalResults.map((h) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
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
                          Icons.local_hospital_rounded,
                          color: Color(0xFF6366F1),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              h.address,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            if (h.rating != null)
                              Text(
                                'Rating: ${h.rating!.toStringAsFixed(1)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            if (h.openNow != null)
                              Text(
                                h.openNow! ? 'Open now' : 'Closed',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: h.openNow!
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DoctorDirectoryScreen(
                                      hospitalName: h.name,
                                    ),
                                  ),
                                ),
                                child: const Text('View doctors'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Text(
              'Search to see nearby hospitals.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedHospital,
            items: _hospitals
                .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                .toList(),
            onChanged: (v) =>
                setState(() => _selectedHospital = v ?? _hospitals.first),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Hospital Availability'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _hospitalAvailability == null
                            ? Icons.help_outline_rounded
                            : (_hospitalAvailability!.contains('available')
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded),
                        size: 16,
                        color: _hospitalAvailability == null
                            ? const Color(0xFF94A3B8)
                            : (_hospitalAvailability!.contains('available')
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _hospitalAvailability ?? 'Not checked yet',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _checkingHospital
                    ? null
                    : _checkHospitalAvailability,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(_checkingHospital ? 'Checking...' : 'Check'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionTitle('Visit Type'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.local_hospital_rounded),
                  label: const Text('Walk‑in'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.schedule_rounded),
                  label: const Text('Book'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionTitle('Payment Method'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            items: [
              'Card',
              'Mobile Money',
              'Insurance',
            ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _paymentMethod = v ?? 'Card'),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _infoNote(
            'This is a booking request only. The hospital will confirm availability.',
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Medication Delivery'),
          const SizedBox(height: 8),
          Text(
            'Order medication online for door‑to‑door delivery.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Medication name(s)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Delivery speed'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _deliverySpeed,
            items: [
              'Standard',
              'Same‑day',
              'Express',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _deliverySpeed = v ?? 'Standard'),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Prescription'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickPrescription,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Upload prescription (scan/photo)'),
          ),
          if (_prescriptionName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _prescriptionName!,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _uploadingPrescription
                      ? Icons.cloud_upload_rounded
                      : (_cloudPrescriptionUrl == null
                            ? Icons.cloud_off_rounded
                            : Icons.cloud_done_rounded),
                  size: 16,
                  color: _cloudPrescriptionUrl == null
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _uploadingPrescription
                        ? 'Uploading to cloud...'
                        : (_cloudPrescriptionUrl == null
                              ? 'Saved on device only (cloud not configured)'
                              : 'Saved to device and cloud'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            if (_localPrescriptionPath != null) ...[
              const SizedBox(height: 6),
              Text(
                'Device: $_localPrescriptionPath',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
          const SizedBox(height: 8),
          Text(
            'You can upload a prescription or a paper scan (PDF/JPG/PNG).',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Payment Method'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            items: [
              'Card',
              'Mobile Money',
              'Insurance',
            ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _paymentMethod = v ?? 'Card'),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.local_shipping_rounded),
              label: const Text('Place Delivery Order'),
            ),
          ),
          const SizedBox(height: 12),
          _infoNote(
            'Delivery availability depends on your location and pharmacy policies.',
          ),
        ],
      ),
    );
  }
}
