import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/dose_history_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Period Selector
            Row(
              children: [
                Text('Adherence Stats', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(label: Text('7d', style: GoogleFonts.plusJakartaSans()), value: 7),
                    ButtonSegment(label: Text('30d', style: GoogleFonts.plusJakartaSans()), value: 30),
                    ButtonSegment(label: Text('90d', style: GoogleFonts.plusJakartaSans()), value: 90),
                  ],
                  selected: {_selectedDays},
                  onSelectionChanged: (p0) => setState(() => _selectedDays = p0.first),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Adherence Rate Card
            FutureBuilder<Map<String, dynamic>>(
              future: DoseHistoryService.instance.getStatistics(days: _selectedDays),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = snapshot.data!;
                final adherenceRate = (stats['adherenceRate'] as double) * 100;
                final taken = stats['taken'] as int;
                final missed = stats['missed'] as int;

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
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
                          Text('Adherence Rate', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text('${adherenceRate.toStringAsFixed(1)}%', style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                              const Spacer(),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                    value: adherenceRate / 100,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatBox('Taken', taken.toString(), const Color(0xFF10B981)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatBox('Missed', missed.toString(), const Color(0xFFEF4444)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Summary', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF64748B))),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem('Total', stats['total'].toString(), const Color(0xFF6366F1)),
                              _buildSummaryItem('On Time', taken.toString(), const Color(0xFF10B981)),
                              _buildSummaryItem('Missed', missed.toString(), const Color(0xFFEF4444)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Tips Section
            Text('Tips to Improve', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTipCard(Icons.alarm_rounded, 'Use consistent times', 'Set reminders at the same time each day'),
            _buildTipCard(Icons.notifications_active_rounded, 'Enable notifications', 'Make sure notifications are allowed'),
            _buildTipCard(Icons.edit_rounded, 'Log doses', 'Mark doses as taken immediately'),
            _buildTipCard(Icons.repeat_rounded, 'Set repeat reminders', 'Daily reminders for regular medications'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(value, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildTipCard(IconData icon, String title, String description) {
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
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(description, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
