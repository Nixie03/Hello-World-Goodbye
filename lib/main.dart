import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'priority_scheduler.dart';
import 'services/medication_service.dart';
import 'services/auth_service.dart';
import 'services/online_service.dart';
import 'services/health_suggestions_service.dart';
import 'services/health_library_service.dart';
import 'services/ads_service.dart';
import 'services/dose_history_service.dart';
import 'services/patient_service.dart';
import 'screens/alert_settings.dart';
import 'screens/tips_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/care_services_screen.dart';
import 'screens/patient_management_screen.dart';
import 'screens/doctor_directory_management_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

// Use the singleton instance throughout the app

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedAlert+',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF8B5CF6),
          surface: Colors.white,
          background: const Color(0xFFF8FAFC),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
          displayLarge: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
          displayMedium: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
          displaySmall: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          headlineMedium: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
          titleLarge: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
          titleMedium: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF334155),
          ),
          bodyLarge: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF475569),
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
          labelLarge: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
          ),
          color: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          surfaceTintColor: Colors.transparent,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
            side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/home': (context) => const MyHomePage(title: 'MedAlert+'),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/care': (context) => const CareServicesScreen(),
        '/patients': (context) => const PatientManagementScreen(),
        '/doctor-directory-manage': (context) =>
            const DoctorDirectoryManagementScreen(),
      },
    );
  }
}

// AuthGate checks authentication status and routes accordingly
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.instance.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
          );
        }

        final isLoggedIn = snapshot.data ?? false;

        if (isLoggedIn) {
          return const MyHomePage(title: 'MedAlert+');
        } else {
          // Check if account exists to decide between login/register
          return FutureBuilder<bool>(
            future: AuthService.instance.hasAccount(),
            builder: (context, accountSnapshot) {
              if (accountSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFFF8FAFC),
                  body: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                    ),
                  ),
                );
              }

              final hasAccount = accountSnapshot.data ?? false;
              return hasAccount ? const LoginScreen() : const RegisterScreen();
            },
          );
        }
      },
    );
  }
}

class _SpeechParseResult {
  final String name;
  final DateTime? time;

  const _SpeechParseResult({required this.name, this.time});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MedicationService _service = MedicationService.instance;
  final DoseHistoryService _historyService = DoseHistoryService.instance;
  final PatientService _patientService = PatientService.instance;
  List<Reminder> get _reminders => _service.reminders;
  List<Reminder> get _scheduled => _service.scheduled;
  bool _isOnline = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  String? _speechError;
  bool _preferOfflineSpeech = false;
  final TextEditingController _frontSearchController = TextEditingController();
  final List<String> _ringtones = [
    'default',
    'chime.wav',
    'soft_bell.wav',
    'silent',
  ];
  String _userRole = 'client';
  List<Patient> _patients = [];

  @override
  void initState() {
    super.initState();
    _service.addListener(() => setState(() {}));

    _initSpeech();
    _loadUserRole();
    _loadPatients();

    // Check online status
    _checkOnlineStatus();

    // Show onboarding tips on first run
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final seen = await _service.onboardingSeen();
      if (!seen && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TipsScreen(
              required: true,
              onAccept: () async {
                await _service.setOnboardingSeen(true);
              },
            ),
          ),
        );
      }
    });
  }

  Future<void> _checkOnlineStatus() async {
    final isOnline = await OnlineService().isOnline();
    if (mounted) {
      setState(() => _isOnline = isOnline);
    }
  }

  Future<void> _loadUserRole() async {
    final role = await AuthService.instance.getUserRole();
    if (mounted) {
      setState(() => _userRole = role);
    }
  }

  Future<void> _loadPatients() async {
    final list = await _patientService.getPatients();
    if (mounted) {
      setState(() => _patients = list);
    }
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (mounted && status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _speechError = error.errorMsg;
            _isListening = false;
          });
        }
      },
    );

    if (mounted) {
      setState(() => _speechAvailable = available);
    }
  }

  void _showHealthTipsDialog() {
    final suggestionsService = HealthSuggestionsService();
    final reminders = _reminders;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Daily Health Tip',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: FutureBuilder<List<DoseLog>>(
            future: _historyService.getDoseHistory(),
            builder: (context, snapshot) {
              final history = snapshot.data ?? [];
              final matched = _matchSuggestionsForReminders(
                reminders,
                suggestionsService,
              );
              final suggestions = matched.isNotEmpty
                  ? matched
                  : [suggestionsService.getRandomSuggestion()];

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Medications',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (reminders.isEmpty)
                    Text(
                      'Add reminders to get personalized health tips.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    )
                  else
                    ...reminders.map((r) {
                      final logs =
                          history
                              .where(
                                (log) => log.reminderId == r.id && log.taken,
                              )
                              .toList()
                            ..sort(
                              (a, b) => b.timestamp.compareTo(a.timestamp),
                            );
                      final lastTaken = logs.isNotEmpty
                          ? _formatDateTime(logs.first.timestamp)
                          : 'No log yet';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.medication_rounded,
                              size: 16,
                              color: Color(0xFF6366F1),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${r.name} • Last taken: $lastTaken',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                  Text(
                    'Suggested Info',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...suggestions.map((suggestion) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          suggestion.category,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          suggestion.description,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Symptoms:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...suggestion.symptoms.map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    s,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Recommended Actions:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...suggestion.treatments.map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    t,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tips are informational only. Always consult your doctor or pharmacist.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAdsDialog() {
    final ads = AdsService().getMultipleRandomAds(2);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Icons.campaign_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Featured',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...ads.map(
                (ad) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAdCard(ad),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _service.removeListener(() {});
    _speech.stop();
    _frontSearchController.dispose();
    super.dispose();
  }

  Future<void> _showAddReminderDialog({Reminder? editReminder}) async {
    final mode = editReminder == null ? 'add' : 'edit';
    final nameController = TextEditingController(
      text: editReminder?.name ?? '',
    );
    Patient? selectedPatient = _patients.isNotEmpty ? _patients.first : null;
    DateTime selectedDate =
        editReminder?.time ?? DateTime.now().add(const Duration(minutes: 5));
    int selectedPriority = editReminder?.priority ?? 1;
    bool muted = editReminder?.muted ?? false;
    String repeat = editReminder?.repeat ?? 'none';
    int snoozeMinutes = editReminder?.snoozeMinutes ?? 0;
    String ringtone = editReminder?.ringtone ?? 'default';
    String speechPreview = '';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  mode == 'edit' ? Icons.edit_rounded : Icons.add_rounded,
                  color: const Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                mode == 'edit' ? 'Edit Reminder' : 'Add Reminder',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Medication Name',
                          labelStyle: GoogleFonts.plusJakartaSans(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF6366F1),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          prefixIcon: const Icon(
                            Icons.medication_rounded,
                            color: Color(0xFF6366F1),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildCircleIconButton(
                              icon: _isListening
                                  ? Icons.mic_rounded
                                  : Icons.mic_none_rounded,
                              color: _isListening
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF6366F1),
                              background: _isListening
                                  ? const Color(0xFF10B981).withOpacity(0.15)
                                  : const Color(0xFF6366F1).withOpacity(0.1),
                              tooltip: _isListening
                                  ? 'Stop listening'
                                  : 'Use voice input',
                              onPressed: () async {
                                if (!_speechAvailable) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Speech recognition not available on this device.',
                                        style: GoogleFonts.plusJakartaSans(),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                if (_isListening) {
                                  await _speech.stop();
                                  setState(() => _isListening = false);
                                  setStateDialog(() {});
                                  return;
                                }

                                setState(() {
                                  _isListening = true;
                                  _speechError = null;
                                  speechPreview = '';
                                });
                                setStateDialog(() {});

                                await _speech.listen(
                                  onResult: (result) {
                                    setState(
                                      () => speechPreview =
                                          result.recognizedWords,
                                    );
                                    setStateDialog(() {});
                                    if (result.finalResult) {
                                      final parsed = _parseSpeechToReminder(
                                        result.recognizedWords,
                                        DateTime.now(),
                                      );
                                      nameController.text = parsed.name;
                                      if (parsed.time != null) {
                                        selectedDate = parsed.time!;
                                      }
                                      setState(() => _isListening = false);
                                      setStateDialog(() {});
                                    }
                                  },
                                  listenFor: const Duration(seconds: 8),
                                  pauseFor: const Duration(seconds: 2),
                                  partialResults: true,
                                  onDevice: _preferOfflineSpeech,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isListening
                                  ? Icons.hearing_rounded
                                  : Icons.record_voice_over_rounded,
                              size: 18,
                              color: _isListening
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _speechError ??
                                    (speechPreview.isEmpty
                                        ? 'Tap the mic and say: "Remind me to take aspirin at 8 PM"'
                                        : speechPreview),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              color: Color(0xFF64748B),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Offline speech (if available)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Uses on-device speech when supported. Otherwise it may fall back to online.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _preferOfflineSpeech,
                              onChanged: (value) {
                                setState(() => _preferOfflineSpeech = value);
                                setStateDialog(() {});
                              },
                              activeThumbColor: const Color(0xFF10B981),
                            ),
                          ],
                        ),
                      ),
                      if (_userRole == 'doctor') ...[
                        const SizedBox(height: 16),
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
                                    Icons.person_rounded,
                                    color: Color(0xFF6366F1),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Patient Account',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<Patient>(
                                initialValue: selectedPatient,
                                decoration: InputDecoration(
                                  labelText: 'Select patient',
                                  labelStyle: GoogleFonts.plusJakartaSans(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6366F1),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                ),
                                items: _patients
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(p.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) => setStateDialog(
                                  () => selectedPatient = value,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () async {
                                    final nameController =
                                        TextEditingController();
                                    final emailController =
                                        TextEditingController();
                                    final created = await showDialog<Patient>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: Text(
                                          'Add Patient',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: nameController,
                                              decoration: InputDecoration(
                                                labelText: 'Patient Name',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            TextField(
                                              controller: emailController,
                                              decoration: InputDecoration(
                                                labelText: 'Email (optional)',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(c).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final name = nameController.text
                                                  .trim();
                                              if (name.isEmpty) return;
                                              final patient =
                                                  await _patientService
                                                      .addPatient(
                                                        name: name,
                                                        email: emailController
                                                            .text
                                                            .trim(),
                                                      );
                                              if (c.mounted) {
                                                Navigator.of(c).pop(patient);
                                              }
                                            },
                                            child: const Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (created != null) {
                                      setState(() {
                                        _patients = [..._patients, created];
                                      });
                                      setStateDialog(
                                        () => selectedPatient = created,
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.person_add_alt_rounded,
                                  ),
                                  label: const Text('Add patient'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Schedule:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 1),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (d == null) return;
                                final t = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                    selectedDate,
                                  ),
                                );
                                if (t == null) return;
                                setStateDialog(() {
                                  selectedDate = DateTime(
                                    d.year,
                                    d.month,
                                    d.day,
                                    t.hour,
                                    t.minute,
                                  );
                                });
                              },
                              icon: const Icon(Icons.event_rounded),
                              label: Text(
                                '${selectedDate.toLocal()}'.split('.').first,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.priority_high_rounded,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Priority:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: selectedPriority,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: List.generate(5, (i) => i + 1)
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p,
                                        child: Text('Priority $p'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => selectedPriority = v ?? 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.repeat_rounded,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Repeat:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: repeat,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: ['none', 'daily', 'weekly']
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s.toUpperCase()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => repeat = v ?? 'none'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.snooze_rounded,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Snooze (min):',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue: snoozeMinutes.toString(),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (v) => setState(
                                  () => snoozeMinutes = int.tryParse(v) ?? 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.music_note_rounded,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Sound:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: ringtone,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: ['default', 'silent']
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s.toUpperCase()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => ringtone = v ?? 'default'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_active_rounded,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Status:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: !muted,
                              onChanged: (v) => setState(() => muted = !v),
                              activeThumbColor: const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              muted ? 'Muted' : 'Active',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: muted
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _speech.stop();
                if (mounted) {
                  setState(() => _isListening = false);
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final patientName = selectedPatient?.name ?? '';
                final displayName =
                    (_userRole == 'doctor' && patientName.isNotEmpty)
                    ? '$patientName: $name'
                    : name;
                final r = Reminder(
                  id: mode == 'edit' ? editReminder!.id : '',
                  name: displayName,
                  time: selectedDate,
                  priority: selectedPriority,
                  muted: muted,
                  repeat: repeat,
                  snoozeMinutes: snoozeMinutes,
                  ringtone: ringtone,
                );
                if (mode == 'edit') {
                  _service.update(r);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Updated reminder: ${r.name}',
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } else {
                  _service.add(r);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added reminder: ${r.name}',
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              icon: Icon(
                mode == 'edit' ? Icons.save_rounded : Icons.add_rounded,
                size: 20,
              ),
              label: Text(mode == 'edit' ? 'Save Changes' : 'Add Reminder'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _scheduleReminders({bool showSnack = false}) {
    // The service always computes scheduled on demand via `scheduled` getter.
    if (showSnack) {
      final names = _scheduled.map((r) => r.name).join(', ');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Scheduled order: $names')));
    }
  }

  void _clear() {
    _service.clear();
  }

  void _openHealthSearch(String query) {
    final cleaned = query.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TipsScreen(
          initialQuery: cleaned.isEmpty ? null : cleaned,
          onAccept: () async {
            await _service.setOnboardingSeen(true);
          },
        ),
      ),
    );
  }

  Future<void> _openGoogleSearch(String query) async {
    final cleaned = query.trim();
    if (cleaned.isEmpty) return;
    final uri = Uri.https('www.google.com', '/search', {'q': cleaned});
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to open browser right now.',
            style: GoogleFonts.plusJakartaSans(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openCareServicesQuick() {
    if (!_isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Care services need internet access.',
            style: GoogleFonts.plusJakartaSans(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CareServicesScreen()));
  }

  String _ringtoneLabel(String id) {
    switch (id) {
      case 'default':
        return 'Default';
      case 'chime.wav':
        return 'Chime';
      case 'soft_bell.wav':
        return 'Soft bell';
      case 'silent':
        return 'Silent';
      default:
        return id;
    }
  }

  Future<void> _showRingtonePicker(Reminder reminder) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select ringtone',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ..._ringtones.map((tone) {
              final selected = reminder.ringtone == tone;
              return ListTile(
                leading: Icon(
                  tone == 'silent'
                      ? Icons.volume_off_rounded
                      : Icons.music_note_rounded,
                  color: selected
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF64748B),
                ),
                title: Text(_ringtoneLabel(tone)),
                trailing: selected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF6366F1),
                      )
                    : null,
                onTap: () async {
                  Navigator.of(context).pop();
                  final updated = Reminder(
                    id: reminder.id,
                    name: reminder.name,
                    time: reminder.time,
                    priority: reminder.priority,
                    muted: tone == 'silent' ? true : false,
                    repeat: reminder.repeat,
                    snoozeMinutes: reminder.snoozeMinutes,
                    ringtone: tone,
                  );
                  await _service.update(updated);
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleMute(Reminder reminder) async {
    if (!reminder.muted) {
      final updated = Reminder(
        id: reminder.id,
        name: reminder.name,
        time: reminder.time,
        priority: reminder.priority,
        muted: true,
        repeat: reminder.repeat,
        snoozeMinutes: reminder.snoozeMinutes,
        ringtone: 'silent',
      );
      await _service.update(updated);
      return;
    }

    await _showRingtonePicker(reminder);
  }

  Future<void> _logDose(Reminder reminder, {required bool taken}) async {
    await _historyService.logDose(
      reminderId: reminder.id,
      reminderName: reminder.name,
      taken: taken,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          taken
              ? 'Logged as taken: ${reminder.name}'
              : 'Logged as missed: ${reminder.name}',
          style: GoogleFonts.plusJakartaSans(),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showDoseHistory(Reminder reminder) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
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
                Icons.history_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Dose History',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: FutureBuilder<List<DoseLog>>(
            future: _historyService.getHistoryForReminder(reminder.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 160,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                    ),
                  ),
                );
              }

              final history = snapshot.data ?? [];
              if (history.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No history yet. Mark a dose as taken to see it here.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                );
              }

              history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              return ListView.separated(
                shrinkWrap: true,
                itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final log = history[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                (log.taken
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444))
                                    .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            log.taken
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: log.taken
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.taken ? 'Taken' : 'Missed',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDateTime(log.timestamp),
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
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    Color? background,
    String? tooltip,
    double iconSize = 18,
    double padding = 8,
  }) {
    final bg = background ?? color.withOpacity(0.12);
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip ?? '',
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Icon(icon, size: iconSize, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final enabled = _isOnline;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? onTap : _openCareServicesQuick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: enabled
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: enabled
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersList() {
    if (_reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medication_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No reminders yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first reminder',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: _reminders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final r = _reminders[i];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _priorityColor(r.priority),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${r.priority}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            title: Text(
              r.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(r.time),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (r.repeat != 'none') ...[
                    Icon(
                      Icons.repeat_rounded,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      r.repeat,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                  if (r.muted) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.volume_off_rounded,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Muted',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCircleIconButton(
                  icon: Icons.check_rounded,
                  color: const Color(0xFF10B981),
                  background: const Color(0xFF10B981).withOpacity(0.12),
                  tooltip: 'Mark taken',
                  iconSize: 16,
                  padding: 6,
                  onPressed: () => _logDose(r, taken: true),
                ),
                const SizedBox(width: 6),
                _buildCircleIconButton(
                  icon: Icons.history_rounded,
                  color: const Color(0xFF0EA5E9),
                  background: const Color(0xFF0EA5E9).withOpacity(0.12),
                  tooltip: 'View history',
                  iconSize: 16,
                  padding: 6,
                  onPressed: () => _showDoseHistory(r),
                ),
                const SizedBox(width: 6),
                _buildCircleIconButton(
                  icon: r.muted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: r.muted
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                  background:
                      (r.muted
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981))
                          .withOpacity(0.12),
                  tooltip: r.muted ? 'Unmute & pick sound' : 'Mute',
                  iconSize: 16,
                  padding: 6,
                  onPressed: () => _toggleMute(r),
                ),
                const SizedBox(width: 6),
                _buildCircleIconButton(
                  icon: Icons.music_note_rounded,
                  color: const Color(0xFF6366F1),
                  tooltip: 'Choose ringtone',
                  iconSize: 16,
                  padding: 6,
                  onPressed: () => _showRingtonePicker(r),
                ),
                const SizedBox(width: 6),
                _buildCircleIconButton(
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF6366F1),
                  tooltip: 'Edit',
                  iconSize: 16,
                  padding: 6,
                  onPressed: () => _showAddReminderDialog(editReminder: r),
                ),
                const SizedBox(width: 6),
                _buildCircleIconButton(
                  icon: Icons.delete_rounded,
                  color: const Color(0xFFEF4444),
                  background: const Color(0xFFEF4444).withOpacity(0.12),
                  tooltip: 'Delete',
                  iconSize: 16,
                  padding: 6,
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(
                          'Delete reminder?',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: Text(
                          'Delete ${r.name}?',
                          style: GoogleFonts.plusJakartaSans(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(c).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(c).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await _service.remove(r.id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Deleted ${r.name}',
                            style: GoogleFonts.plusJakartaSans(),
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduledList() {
    if (_scheduled.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No scheduled reminders',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Press Schedule to organize',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: _scheduled.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final r = _scheduled[i];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _priorityColor(r.priority),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${r.priority}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            title: Text(
              r.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(r.time),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (r.repeat != 'none') ...[
                    Icon(
                      Icons.repeat_rounded,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      r.repeat,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                  if (r.muted) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.volume_off_rounded,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Muted',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCircleIconButton(
                  icon: Icons.check_rounded,
                  color: const Color(0xFF10B981),
                  background: const Color(0xFF10B981).withOpacity(0.12),
                  tooltip: 'Mark taken',
                  iconSize: 16,
                  padding: 6,
                  onPressed: () => _logDose(r, taken: true),
                ),
                const SizedBox(width: 6),
                _buildCircleIconButton(
                  icon: Icons.history_rounded,
                  color: const Color(0xFF0EA5E9),
                  background: const Color(0xFF0EA5E9).withOpacity(0.12),
                  tooltip: 'View history',
                  iconSize: 16,
                  padding: 6,
                  onPressed: () => _showDoseHistory(r),
                ),
                const SizedBox(width: 6),
                _buildCircleIconButton(
                  icon: r.muted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: r.muted
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                  background:
                      (r.muted
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981))
                          .withOpacity(0.12),
                  tooltip: r.muted ? 'Unmute & pick sound' : 'Mute',
                  iconSize: 16,
                  padding: 6,
                  onPressed: () => _toggleMute(r),
                ),
                const SizedBox(width: 6),
                _buildCircleIconButton(
                  icon: Icons.music_note_rounded,
                  color: const Color(0xFF6366F1),
                  tooltip: 'Choose ringtone',
                  iconSize: 16,
                  padding: 6,
                  onPressed: () => _showRingtonePicker(r),
                ),
                const SizedBox(width: 6),
                _buildCircleIconButton(
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF6366F1),
                  tooltip: 'Edit',
                  iconSize: 16,
                  padding: 6,
                  onPressed: () => _showAddReminderDialog(editReminder: r),
                ),
                const SizedBox(width: 6),
                _buildCircleIconButton(
                  icon: Icons.delete_rounded,
                  color: const Color(0xFFEF4444),
                  background: const Color(0xFFEF4444).withOpacity(0.12),
                  tooltip: 'Delete',
                  iconSize: 16,
                  padding: 6,
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(
                          'Delete reminder?',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: Text(
                          'Delete ${r.name}?',
                          style: GoogleFonts.plusJakartaSans(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(c).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(c).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await _service.remove(r.id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Deleted ${r.name}',
                            style: GoogleFonts.plusJakartaSans(),
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6366F1)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(int p) {
    switch (p) {
      case 1:
        return const Color(0xFF10B981); // emerald
      case 2:
        return const Color(0xFF3B82F6); // blue
      case 3:
        return const Color(0xFFF59E0B); // amber
      case 4:
        return const Color(0xFFEF4444); // red
      default:
        return const Color(0xFFEC4899); // pink
    }
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    final date =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  List<HealthSuggestion> _matchSuggestionsForReminders(
    List<Reminder> reminders,
    HealthSuggestionsService service,
  ) {
    final mapping = <String, String>{
      'insulin': 'Diabetes Type 2',
      'metformin': 'Diabetes Type 2',
      'glipizide': 'Diabetes Type 2',
      'amlodipine': 'Hypertension (High Blood Pressure)',
      'lisinopril': 'Hypertension (High Blood Pressure)',
      'losartan': 'Hypertension (High Blood Pressure)',
      'metoprolol': 'Hypertension (High Blood Pressure)',
      'albuterol': 'Asthma',
      'salbutamol': 'Asthma',
      'omeprazole': 'Gastric Reflux (GERD)',
      'pantoprazole': 'Gastric Reflux (GERD)',
      'levothyroxine': 'Thyroid Disease',
      'cetirizine': 'Allergic Rhinitis',
      'loratadine': 'Allergic Rhinitis',
    };

    final matched = <HealthSuggestion>[];
    final added = <String>{};

    for (final reminder in reminders) {
      final name = reminder.name.toLowerCase();
      for (final entry in mapping.entries) {
        if (name.contains(entry.key) && !added.contains(entry.value)) {
          final suggestion = service.getSuggestionByTitle(entry.value);
          if (suggestion != null) {
            matched.add(suggestion);
            added.add(entry.value);
          }
        }
      }
    }

    return matched;
  }

  _SpeechParseResult _parseSpeechToReminder(String speech, DateTime base) {
    var cleaned = speech.trim();
    if (cleaned.isEmpty) {
      return const _SpeechParseResult(name: '');
    }

    final lower = cleaned.toLowerCase();
    DateTime? time;

    if (lower.contains(' at ')) {
      final parts = cleaned.split(RegExp(r'\s+at\s+', caseSensitive: false));
      if (parts.length >= 2) {
        final timePart = parts.sublist(1).join(' ').trim();
        time = _extractTime(timePart, base);
        cleaned = parts.first.trim();
      }
    }

    if (lower.contains('tomorrow') && time != null) {
      time = time.add(const Duration(days: 1));
    }

    cleaned = cleaned
        .replaceFirst(
          RegExp(
            r'^(remind me to|remind me|set reminder to|set a reminder to|set reminder|reminder to)\s+',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    if (cleaned.isEmpty) {
      cleaned = speech.trim();
    }

    return _SpeechParseResult(name: cleaned, time: time);
  }

  DateTime? _extractTime(String input, DateTime base) {
    final match = RegExp(
      r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?',
      caseSensitive: false,
    ).firstMatch(input);
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    final meridiem = match.group(3)?.toLowerCase();

    if (meridiem == 'pm' && hour < 12) hour += 12;
    if (meridiem == 'am' && hour == 12) hour = 0;

    var dt = DateTime(base.year, base.month, base.day, hour, minute);
    if (dt.isBefore(base)) {
      dt = dt.add(const Duration(days: 1));
    }
    return dt;
  }

  Widget _buildHealthSuggestionCard(HealthSuggestion suggestion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF14B8A6).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      suggestion.category,
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
          const SizedBox(height: 12),
          Text(
            suggestion.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF334155),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Learn More',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard(Ad ad) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      ad.category,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'AD',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ad.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF334155),
            ),
          ),
          if (ad.actionText != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  ad.actionText!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestionQuery = _frontSearchController.text.trim();
    final suggestions = suggestionQuery.isEmpty
        ? <HealthLibraryEntry>[]
        : HealthLibraryService.instance
              .search(suggestionQuery)
              .take(4)
              .toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/logo/medalert_logo.svg',
                width: 28,
                height: 28,
              ),
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          if (_isOnline)
            IconButton(
              tooltip: 'Health Tips',
              icon: const Icon(Icons.health_and_safety_rounded, size: 24),
              onPressed: _showHealthTipsDialog,
            ),
          if (_isOnline)
            IconButton(
              tooltip: 'Featured',
              icon: const Icon(Icons.campaign_rounded, size: 24),
              onPressed: _showAdsDialog,
            ),
          IconButton(
            tooltip: 'Dashboard',
            icon: const Icon(Icons.bar_chart_rounded, size: 24),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const DashboardScreen())),
          ),
          IconButton(
            tooltip: 'Care services',
            icon: const Icon(Icons.medical_services_rounded, size: 24),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CareServicesScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Tips & help',
            icon: const Icon(Icons.help_outline_rounded, size: 24),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TipsScreen(
                  onAccept: () async {
                    await _service.setOnboardingSeen(true);
                  },
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Alert settings',
            icon: const Icon(Icons.tune_rounded, size: 24),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AlertSettingsScreen()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_rounded, size: 28),
            tooltip: 'Account',
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) async {
              if (value == 'profile') {
                final userInfo = await AuthService.instance.getUserInfo();
                if (!mounted) return;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF6366F1),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Profile',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileRow(
                          Icons.person_rounded,
                          'Name',
                          userInfo['name'] ?? 'Not set',
                        ),
                        const SizedBox(height: 12),
                        _buildProfileRow(
                          Icons.email_rounded,
                          'Email',
                          userInfo['email'] ?? 'Not set',
                        ),
                        const SizedBox(height: 12),
                        _buildProfileRow(
                          Icons.badge_rounded,
                          'Role',
                          (userInfo['role'] ?? 'client') == 'doctor'
                              ? 'Doctor'
                              : 'Client',
                        ),
                        if ((userInfo['role'] ?? 'client') == 'doctor') ...[
                          const SizedBox(height: 12),
                          _buildProfileRow(
                            Icons.verified_rounded,
                            'License',
                            userInfo['license'] ?? 'Not set',
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildProfileRow(
                          Icons.calendar_today_rounded,
                          'Member since',
                          userInfo['createdAt'] != null
                              ? DateTime.parse(
                                  userInfo['createdAt']!,
                                ).toLocal().toString().split(' ')[0]
                              : 'Unknown',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              } else if (value == 'patients') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PatientManagementScreen(),
                  ),
                );
              } else if (value == 'doctorDirectory') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DoctorDirectoryManagementScreen(),
                  ),
                );
              } else if (value == 'logout') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to logout?',
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
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await AuthService.instance.logout();
                  if (!mounted) return;
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      size: 20,
                      color: Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 12),
                    Text('View Profile', style: GoogleFonts.plusJakartaSans()),
                  ],
                ),
              ),
              if (_userRole == 'doctor') ...[
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'doctorDirectory',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_hospital_rounded,
                        size: 20,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Doctor directory',
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'patients',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people_alt_rounded,
                        size: 20,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 12),
                      Text('Patients', style: GoogleFonts.plusJakartaSans()),
                    ],
                  ),
                ),
              ],
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFEFF4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _frontSearchController,
                            decoration: InputDecoration(
                              hintText:
                                  'Search health info (disease, symptoms, medication)',
                              border: InputBorder.none,
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                            onSubmitted: _openHealthSearch,
                          ),
                        ),
                        _buildCircleIconButton(
                          icon: Icons.public_rounded,
                          color: const Color(0xFF0EA5E9),
                          tooltip: 'Search',
                          onPressed: () =>
                              _openHealthSearch(_frontSearchController.text),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (suggestions.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suggestions',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...suggestions.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          entry.category,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Definition',
                                    icon: const Icon(
                                      Icons.menu_book_rounded,
                                      size: 18,
                                    ),
                                    color: const Color(0xFF6366F1),
                                    onPressed: () =>
                                        _openHealthSearch(entry.name),
                                  ),
                                  IconButton(
                                    tooltip: 'Google',
                                    icon: const Icon(
                                      Icons.public_rounded,
                                      size: 18,
                                    ),
                                    color: const Color(0xFF0EA5E9),
                                    onPressed: () =>
                                        _openGoogleSearch(entry.name),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: FutureBuilder<List<DoseLog>>(
                      future: _historyService.getDoseHistory(),
                      builder: (context, snapshot) {
                        final logs = snapshot.data ?? [];
                        final cutoff = DateTime.now().subtract(
                          const Duration(days: 7),
                        );
                        final recent = logs.where(
                          (l) => l.timestamp.isAfter(cutoff),
                        );
                        final taken = recent.where((l) => l.taken).length;
                        final missed = recent.where((l) => !l.taken).length;
                        final total = taken + missed;
                        final adherence = total == 0
                            ? 0
                            : ((taken / total) * 100).round();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.bar_chart_rounded,
                                    size: 18,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dashboard summary',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        'Medication adherence (7 days)',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const DashboardScreen(),
                                    ),
                                  ),
                                  child: const Text('View'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildSummaryChip(
                                  label: 'Adherence',
                                  value: '$adherence%',
                                  color: const Color(0xFF10B981),
                                ),
                                const SizedBox(width: 8),
                                _buildSummaryChip(
                                  label: 'Taken',
                                  value: '$taken',
                                  color: const Color(0xFF6366F1),
                                ),
                                const SizedBox(width: 8),
                                _buildSummaryChip(
                                  label: 'Missed',
                                  value: '$missed',
                                  color: const Color(0xFFEF4444),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                                color: const Color(
                                  0xFF6366F1,
                                ).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.medical_services_rounded,
                                size: 18,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Care services',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    _isOnline
                                        ? 'Consult, delivery, hospitals, doctors'
                                        : 'Connect to access online services',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildServiceChip(
                                label: 'Online consult',
                                icon: Icons.video_call_rounded,
                                onTap: _openCareServicesQuick,
                              ),
                              const SizedBox(width: 10),
                              _buildServiceChip(
                                label: 'Medicine delivery',
                                icon: Icons.local_shipping_rounded,
                                onTap: _openCareServicesQuick,
                              ),
                              const SizedBox(width: 10),
                              _buildServiceChip(
                                label: 'Nearby hospitals',
                                icon: Icons.local_hospital_rounded,
                                onTap: _openCareServicesQuick,
                              ),
                              const SizedBox(width: 10),
                              _buildServiceChip(
                                label: 'Doctor search',
                                icon: Icons.search_rounded,
                                onTap: _openCareServicesQuick,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showAddReminderDialog(),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Add Reminder'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => _scheduleReminders(showSnack: true),
                        icon: const Icon(Icons.schedule_rounded, size: 20),
                        label: const Text('Schedule'),
                      ),
                      const SizedBox(width: 12),
                      _buildCircleIconButton(
                        icon: Icons.delete_outline_rounded,
                        color: const Color(0xFFEF4444),
                        background: const Color(0xFFEF4444).withOpacity(0.12),
                        tooltip: 'Clear all',
                        onPressed: _clear,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF6366F1,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.notifications_active_rounded,
                                      color: Color(0xFF6366F1),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'My Reminders',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Offline-ready',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: TabBar(
                                labelColor: const Color(0xFF6366F1),
                                unselectedLabelColor: const Color(0xFF94A3B8),
                                labelStyle: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                ),
                                tabs: const [
                                  Tab(text: 'My Reminders'),
                                  Tab(text: 'Scheduled'),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 16,
                              thickness: 1,
                              color: Color(0xFFE2E8F0),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildRemindersList(),
                                  _buildScheduledList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddReminderDialog(),
          icon: const Icon(Icons.add_rounded, size: 24),
          label: Text(
            'New Reminder',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
