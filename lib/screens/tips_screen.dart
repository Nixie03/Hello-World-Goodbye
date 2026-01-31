import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/dose_history_service.dart';
import '../services/health_library_service.dart';
import '../services/health_online_service.dart';
import '../services/medication_service.dart';
import '../services/online_service.dart';

class TipsScreen extends StatefulWidget {
  final Future<void> Function()? onAccept;
  final bool required;
  final String? initialQuery;
  const TipsScreen({
    super.key,
    this.onAccept,
    this.required = false,
    this.initialQuery,
  });

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  bool _agreedToTerms = false;
  bool _isOnline = false;
  final TextEditingController _healthSearchController = TextEditingController();
  List<HealthLibraryEntry> _healthResults = [];
  List<OnlineHealthResult> _onlineResults = [];
  bool _isSearchingOnline = false;
  String? _onlineError;

  void _showTerms(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please read these terms before using MedAlert+.',
                style: GoogleFonts.plusJakartaSans(),
              ),
              const SizedBox(height: 16),
              Text(
                'Privacy & Data',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All your medication data, reminders, and settings are stored locally on your device. Nothing is sent to external servers.',
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'How It Works',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'MedAlert+ schedules reminders based on priority and time. Notifications require permission to work properly.',
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'Important Disclaimer',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This app is a reminder tool only. Follow your doctor\'s medication instructions. If you have medical questions, consult a healthcare professional.',
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'By using MedAlert+, you accept these terms and understand how the app works.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkOnlineStatus();
    final initial = widget.initialQuery?.trim() ?? '';
    if (initial.isNotEmpty) {
      _healthSearchController.text = initial;
      _healthResults = HealthLibraryService.instance.search(initial);
    }
    _healthSearchController.addListener(() {
      final query = _healthSearchController.text;
      setState(() {
        _healthResults = HealthLibraryService.instance.search(query);
        _onlineResults = [];
        _onlineError = null;
      });
    });
  }

  @override
  void dispose() {
    _healthSearchController.dispose();
    super.dispose();
  }

  Future<void> _checkOnlineStatus() async {
    final online = await OnlineService().isOnline();
    if (mounted) {
      setState(() => _isOnline = online);
    }
  }

  Future<void> _searchOnline(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    if (!_isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You are offline. Turn on internet to search online.',
            style: GoogleFonts.plusJakartaSans(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSearchingOnline = true;
      _onlineError = null;
    });

    try {
      final results = await OnlineHealthService.instance.search(q);
      if (!mounted) return;
      setState(() => _onlineResults = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _onlineError = 'Unable to fetch online sources.');
    } finally {
      if (mounted) {
        setState(() => _isSearchingOnline = false);
      }
    }
  }

  void _showAlgorithmInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.science_rounded,
                color: Color(0xFF6366F1),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'How It Works',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Smart Scheduling',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your reminders are automatically organized by:',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('Priority (1-5)'),
                    _buildBullet('Scheduled time'),
                    _buildBullet('Repeat patterns'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF6366F1),
            ),
          ),
          Expanded(
            child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    final date =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  Widget _buildHealthEntryCard(HealthLibraryEntry entry) {
    final isMedication = entry.type == 'medication';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (isMedication
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF10B981))
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isMedication
                      ? Icons.medication_rounded
                      : Icons.health_and_safety_rounded,
                  color: isMedication
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF10B981),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      entry.category,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.definition,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF334155),
            ),
          ),
          if (entry.symptoms.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Symptoms',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ...entry.symptoms.map(
              (s) => Text(
                '• $s',
                style: GoogleFonts.plusJakartaSans(fontSize: 12),
              ),
            ),
          ],
          if (entry.uses.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Uses',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ...entry.uses.map(
              (u) => Text(
                '• $u',
                style: GoogleFonts.plusJakartaSans(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOnlineResultCard(OnlineHealthResult entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.public_rounded,
                  color: Color(0xFF0EA5E9),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      entry.source,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.snippet,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _accept() async {
    if (widget.required && !_agreedToTerms) return;
    if (widget.onAccept != null) await widget.onAccept!();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !widget.required,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'Tips & Help',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.medication_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Welcome to MedAlert+',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your personal medication reminder assistant',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Start Guide
              Text(
                'Quick Start Guide',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              _buildGuideStep(
                Icons.add_rounded,
                'Add Reminder',
                'Tap the + button to create your first medication reminder',
              ),
              _buildGuideStep(
                Icons.priority_high_rounded,
                'Set Priority',
                'Choose priority 1-5 (1 = highest, life-critical medications)',
              ),
              _buildGuideStep(
                Icons.schedule_rounded,
                'Configure Schedule',
                'Set time, repeat pattern, snooze duration, and ringtone',
              ),
              _buildGuideStep(
                Icons.notifications_active_rounded,
                'Enable Notifications',
                'Allow notifications when prompted for alerts to work',
              ),
              _buildGuideStep(
                Icons.edit_rounded,
                'Manage Reminders',
                'Edit, delete, or mute reminders as your schedule changes',
              ),
              const SizedBox(height: 24),

              // Pro Tips
              Text(
                'Pro Tips',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              _buildTip(
                Icons.timer_rounded,
                'Keep ringtones short (1–3 seconds) for better user experience',
              ),
              _buildTip(
                Icons.repeat_rounded,
                'Use "Daily" repeat for regular medications',
              ),
              _buildTip(
                Icons.snooze_rounded,
                'Set appropriate snooze intervals (5-15 minutes recommended)',
              ),
              _buildTip(
                Icons.schedule_rounded,
                'Press "Schedule" button to see prioritized order',
              ),
              const SizedBox(height: 24),

              // Health Insights
              Text(
                'Your Meds & Timing',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<DoseLog>>(
                future: DoseHistoryService.instance.getDoseHistory(),
                builder: (context, snapshot) {
                  final history = snapshot.data ?? [];
                  final reminders = MedicationService.instance.reminders;

                  if (reminders.isEmpty) {
                    return Text(
                      'Add reminders to see personalized timing tips here.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    );
                  }

                  return Column(
                    children: reminders.map((r) {
                      final logs = history
                          .where((log) => log.reminderId == r.id && log.taken)
                          .toList();
                      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                      final lastTaken = logs.isNotEmpty
                          ? _formatDateTime(logs.first.timestamp)
                          : 'No log yet';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.medication_rounded,
                                color: Color(0xFF6366F1),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Last taken: $lastTaken',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Health Library
              Text(
                'Health Library',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _healthSearchController,
                decoration: InputDecoration(
                  hintText: 'Search a disease, condition, or medication',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.public_rounded),
                    tooltip: 'Search online',
                    onPressed: () =>
                        _searchOnline(_healthSearchController.text),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    _isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    size: 16,
                    color: const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isOnline
                        ? 'Online search available'
                        : 'Offline: local results only',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_healthResults.isEmpty)
                Text(
                  'Type a search to see definitions and uses.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                )
              else
                Column(
                  children: _healthResults.map(_buildHealthEntryCard).toList(),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Online Results',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _isSearchingOnline
                        ? null
                        : () => _searchOnline(_healthSearchController.text),
                    icon: const Icon(Icons.public_rounded, size: 16),
                    label: const Text('Fetch'),
                  ),
                ],
              ),
              if (_isSearchingOnline)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Fetching from MedlinePlus and OpenFDA...',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_onlineError != null)
                Text(
                  _onlineError!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFFEF4444),
                  ),
                )
              else if (_onlineResults.isEmpty)
                Text(
                  'Tap Fetch to load online sources.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                )
              else
                Column(
                  children: _onlineResults.map(_buildOnlineResultCard).toList(),
                ),
              const SizedBox(height: 12),
              Container(
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
                        'Definitions are for general information only. Always consult your doctor or pharmacist for medical advice.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Terms & Conditions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_rounded,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Important',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This app is a reminder tool only. Always follow your doctor\'s instructions.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    if (widget.required)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _agreedToTerms,
                                onChanged: (val) => setState(
                                  () => _agreedToTerms = val ?? false,
                                ),
                                activeColor: const Color(0xFF6366F1),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _showTerms(context),
                                  child: Text(
                                    'I agree to the Terms & Conditions',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: const Color(0xFF6366F1),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _agreedToTerms ? _accept : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                disabledBackgroundColor: const Color(
                                  0xFFCBD5E1,
                                ),
                              ),
                              child: Text(
                                'Continue',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  color: _agreedToTerms
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showTerms(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            disabledBackgroundColor: const Color(0xFFCBD5E1),
                          ),
                          child: Text(
                            'View Full Terms',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Footer
              Center(
                child: Text(
                  'Reopen this screen anytime from the help icon (?) in the app bar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideStep(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF8B5CF6)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
