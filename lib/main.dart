import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'priority_scheduler.dart';
import 'services/medication_service.dart';
import 'services/auth_service.dart';
import 'services/online_service.dart';
import 'services/health_suggestions_service.dart';
import 'services/ads_service.dart';
import 'screens/alert_settings.dart';
import 'screens/tips_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          displayLarge: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          displayMedium: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          displaySmall: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
          headlineMedium: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          titleLarge: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          titleMedium: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF334155)),
          bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w400, color: const Color(0xFF475569)),
          bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF64748B)),
          labelLarge: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
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
          titleTextStyle: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
          surfaceTintColor: Colors.transparent,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
            side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/home': (context) => const MyHomePage(title: 'MedAlert+'),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
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
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MedicationService _service = MedicationService.instance;
  List<Reminder> get _reminders => _service.reminders;
  List<Reminder> get _scheduled => _service.scheduled;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _service.addListener(() => setState(() {}));

    // Check online status
    _checkOnlineStatus();

    // Show onboarding tips on first run
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final seen = await _service.onboardingSeen();
      if (!seen && mounted) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TipsScreen(required: true, onAccept: () async {
          await _service.setOnboardingSeen(true);
        })));
      }
    });
  }

  Future<void> _checkOnlineStatus() async {
    final isOnline = await OnlineService().isOnline();
    if (mounted) {
      setState(() => _isOnline = isOnline);
    }
  }

  void _showHealthTipsDialog() {
    final suggestions = HealthSuggestionsService().getAllSuggestions();
    final randomSuggestion = suggestions[DateTime.now().millisecondsSinceEpoch % suggestions.length];

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
              child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF10B981), size: 20),
            ),
            const SizedBox(width: 12),
            Text('Daily Health Tip', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(randomSuggestion.title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Text(randomSuggestion.category, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
              const SizedBox(height: 16),
              Text(randomSuggestion.description, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF334155))),
              const SizedBox(height: 16),
              Text('Symptoms:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...randomSuggestion.symptoms.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 13))),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              Text('Recommended Actions:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...randomSuggestion.treatments.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 13))),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
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
              child: const Icon(Icons.campaign_rounded, color: Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 12),
            Text('Featured', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...ads.map((ad) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAdCard(ad),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _service.removeListener(() {});
    super.dispose();
  }



  Future<void> _showAddReminderDialog({Reminder? editReminder}) async {
    final mode = editReminder == null ? 'add' : 'edit';
    final nameController = TextEditingController(text: editReminder?.name ?? '');
    DateTime selectedDate = editReminder?.time ?? DateTime.now().add(const Duration(minutes: 5));
    int selectedPriority = editReminder?.priority ?? 1;
    bool muted = editReminder?.muted ?? false;
    String repeat = editReminder?.repeat ?? 'none';
    int snoozeMinutes = editReminder?.snoozeMinutes ?? 0;
    String ringtone = editReminder?.ringtone ?? 'default';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: StatefulBuilder(builder: (context, setState) {
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
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(Icons.medication_rounded, color: Color(0xFF6366F1)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: Color(0xFF6366F1), size: 20),
                          const SizedBox(width: 12),
                          Text('Time:', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (d != null) {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(selectedDate),
                                  );
                                  if (t != null) {
                                    if (!mounted) return;
                                    setState(() => selectedDate = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                                  }
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: Text('${selectedDate.toLocal()}'.split('.').first, style: GoogleFonts.plusJakartaSans(fontSize: 13)),
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
                          const Icon(Icons.priority_high_rounded, color: Color(0xFF6366F1), size: 20),
                          const SizedBox(width: 12),
                          Text('Priority:', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: selectedPriority,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: List.generate(5, (i) => i + 1).map((p) => DropdownMenuItem(value: p, child: Text('Priority $p'))).toList(),
                              onChanged: (v) => setState(() => selectedPriority = v ?? 1),
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
                          const Icon(Icons.repeat_rounded, color: Color(0xFF6366F1), size: 20),
                          const SizedBox(width: 12),
                          Text('Repeat:', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: repeat,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: ['none', 'daily', 'weekly'].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                              onChanged: (v) => setState(() => repeat = v ?? 'none'),
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
                          const Icon(Icons.snooze_rounded, color: Color(0xFF6366F1), size: 20),
                          const SizedBox(width: 12),
                          Text('Snooze (min):', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue: snoozeMinutes.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (v) => setState(() => snoozeMinutes = int.tryParse(v) ?? 0),
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
                          const Icon(Icons.music_note_rounded, color: Color(0xFF6366F1), size: 20),
                          const SizedBox(width: 12),
                          Text('Sound:', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: ringtone,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: ['default', 'silent'].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                              onChanged: (v) => setState(() => ringtone = v ?? 'default'),
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
                          const Icon(Icons.notifications_active_rounded, color: Color(0xFF6366F1), size: 20),
                          const SizedBox(width: 12),
                          Text('Status:', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
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
                              color: muted ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final r = Reminder(id: mode == 'edit' ? editReminder!.id : '', name: name, time: selectedDate, priority: selectedPriority, muted: muted, repeat: repeat, snoozeMinutes: snoozeMinutes, ringtone: ringtone);
                if (mode == 'edit') {
                  _service.update(r);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Updated reminder: ${r.name}', style: GoogleFonts.plusJakartaSans()),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                } else {
                  _service.add(r);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added reminder: ${r.name}', style: GoogleFonts.plusJakartaSans()),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              icon: Icon(mode == 'edit' ? Icons.save_rounded : Icons.add_rounded, size: 20),
              label: Text(mode == 'edit' ? 'Save Changes' : 'Add Reminder'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scheduled order: $names')));
    }
  }

  void _clear() {
    _service.clear();
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
                Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A))),
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
    final date = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final time = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  Widget _buildHealthSuggestionCard(HealthSuggestion suggestion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF10B981).withOpacity(0.1), const Color(0xFF14B8A6).withOpacity(0.1)],
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
                child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(suggestion.title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                    Text(suggestion.category, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(suggestion.description, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF334155)), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Learn More', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF10B981), fontWeight: FontWeight.w500)),
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
          colors: [const Color(0xFF6366F1).withOpacity(0.1), const Color(0xFF8B5CF6).withOpacity(0.1)],
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
                child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ad.title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                    Text(ad.category, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('AD', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(ad.description, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF334155))),
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
                child: Text(ad.actionText!, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: SvgPicture.asset('assets/logo/medalert_logo.svg', width: 28, height: 28),
            ),
          ),
        ),
        title: Text(widget.title, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
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
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DashboardScreen())),
          ),
          IconButton(
            tooltip: 'Tips & help',
            icon: const Icon(Icons.help_outline_rounded, size: 24),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TipsScreen(onAccept: () async {
              await _service.setOnboardingSeen(true);
            })) ),
          ),
          IconButton(
            tooltip: 'Alert settings',
            icon: const Icon(Icons.tune_rounded, size: 24),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlertSettingsScreen())),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_rounded, size: 28),
            tooltip: 'Account',
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) async {
              if (value == 'profile') {
                final userInfo = await AuthService.instance.getUserInfo();
                if (!mounted) return;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded, color: Color(0xFF6366F1), size: 28),
                        ),
                        const SizedBox(width: 12),
                        Text('Profile', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileRow(Icons.person_rounded, 'Name', userInfo['name'] ?? 'Not set'),
                        const SizedBox(height: 12),
                        _buildProfileRow(Icons.email_rounded, 'Email', userInfo['email'] ?? 'Not set'),
                        const SizedBox(height: 12),
                        _buildProfileRow(Icons.calendar_today_rounded, 'Member since', userInfo['createdAt'] != null ? DateTime.parse(userInfo['createdAt']!).toLocal().toString().split(' ')[0] : 'Unknown'),
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
              } else if (value == 'logout') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text('Logout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                    content: Text('Are you sure you want to logout?', style: GoogleFonts.plusJakartaSans()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await AuthService.instance.logout();
                  if (!mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_rounded, size: 20, color: Color(0xFF6366F1)),
                    const SizedBox(width: 12),
                    Text('View Profile', style: GoogleFonts.plusJakartaSans()),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFEF4444)),
                    const SizedBox(width: 12),
                    Text('Logout', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAddReminderDialog(),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Add Reminder'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _scheduleReminders(showSnack: true),
                  icon: const Icon(Icons.schedule_rounded, size: 20),
                  label: const Text('Schedule'),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _clear,
                  icon: const Icon(Icons.delete_outline_rounded, size: 24),
                  tooltip: 'Clear all',
                  style: IconButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF6366F1), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text('Reminders', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('${_reminders.length}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF6366F1))),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                          Expanded(
                            child: _reminders.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.medication_rounded, size: 64, color: Colors.grey.shade300),
                                        const SizedBox(height: 16),
                                        Text('No reminders yet', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8))),
                                        const SizedBox(height: 8),
                                        Text('Add your first reminder', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFFCBD5E1))),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(12),
                                    itemCount: _reminders.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (context, i) {
                                      final r = _reminders[i];
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          leading: Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: _priorityColor(r.priority),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text('${r.priority}', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                            ),
                                          ),
                                          title: Text(r.name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Row(
                                              children: [
                                                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                                                const SizedBox(width: 4),
                                                Text(_formatDateTime(r.time), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B))),
                                                const SizedBox(width: 12),
                                                if (r.repeat != 'none') ...[
                                                  Icon(Icons.repeat_rounded, size: 14, color: Colors.grey.shade600),
                                                  const SizedBox(width: 4),
                                                  Text(r.repeat, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B))),
                                                ],
                                                if (r.muted) ...[
                                                  const SizedBox(width: 12),
                                                  Icon(Icons.volume_off_rounded, size: 14, color: Colors.grey.shade600),
                                                  const SizedBox(width: 4),
                                                  Text('Muted', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B))),
                                                ],
                                              ],
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_rounded, size: 20),
                                                color: const Color(0xFF6366F1),
                                                onPressed: () => _showAddReminderDialog(editReminder: r),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_rounded, size: 20),
                                                color: const Color(0xFFEF4444),
                                                onPressed: () async {
                                                  final ok = await showDialog<bool>(
                                                    context: context,
                                                    builder: (c) => AlertDialog(
                                                      title: Text('Delete reminder?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                                                      content: Text('Delete ${r.name}?', style: GoogleFonts.plusJakartaSans()),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
                                                        ElevatedButton(
                                                          onPressed: () => Navigator.of(c).pop(true),
                                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
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
                                                        content: Text('Deleted ${r.name}', style: GoogleFonts.plusJakartaSans()),
                                                        behavior: SnackBarBehavior.floating,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.event_available_rounded, color: Color(0xFF8B5CF6), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text('Scheduled', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('${_scheduled.length}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF8B5CF6))),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                          Expanded(
                            child: _scheduled.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.schedule_rounded, size: 64, color: Colors.grey.shade300),
                                        const SizedBox(height: 16),
                                        Text('No scheduled reminders', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8))),
                                        const SizedBox(height: 8),
                                        Text('Press Schedule to organize', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFFCBD5E1))),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(12),
                                    itemCount: _scheduled.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (context, i) {
                                      final r = _scheduled[i];
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          leading: Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: _priorityColor(r.priority),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text('${r.priority}', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                            ),
                                          ),
                                          title: Text(r.name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Row(
                                              children: [
                                                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                                                const SizedBox(width: 4),
                                                Text(_formatDateTime(r.time), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B))),
                                                const SizedBox(width: 12),
                                                if (r.repeat != 'none') ...[
                                                  Icon(Icons.repeat_rounded, size: 14, color: Colors.grey.shade600),
                                                  const SizedBox(width: 4),
                                                  Text(r.repeat, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B))),
                                                ],
                                                if (r.muted) ...[
                                                  const SizedBox(width: 12),
                                                  Icon(Icons.volume_off_rounded, size: 14, color: Colors.grey.shade600),
                                                  const SizedBox(width: 4),
                                                  Text('Muted', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B))),
                                                ],
                                              ],
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_rounded, size: 20),
                                                color: const Color(0xFF6366F1),
                                                onPressed: () => _showAddReminderDialog(editReminder: r),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_rounded, size: 20),
                                                color: const Color(0xFFEF4444),
                                                onPressed: () async {
                                                  final ok = await showDialog<bool>(
                                                    context: context,
                                                    builder: (c) => AlertDialog(
                                                      title: Text('Delete reminder?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                                                      content: Text('Delete ${r.name}?', style: GoogleFonts.plusJakartaSans()),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
                                                        ElevatedButton(
                                                          onPressed: () => Navigator.of(c).pop(true),
                                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
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
                                                        content: Text('Deleted ${r.name}', style: GoogleFonts.plusJakartaSans()),
                                                        behavior: SnackBarBehavior.floating,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  ),
                          ),
                        ],
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
          label: Text('New Reminder', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
