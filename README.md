# MedAlert+ - Algorithm-Based Medication Management System

## Research Overview

**Target Users:** Adult users in Manila, Philippines  
**Research Focus:** Deterministic, transparent, algorithm-focused medication management

## Core Algorithms

### 1. Priority-Based Medication Scheduling Algorithm

A dynamic scheduling system that organizes medication reminders based on:
- **Priority Levels (1-5):** User-assigned importance ratings
- **Time Conflicts:** Automatic detection and resolution of overlapping schedules
- **Repeat Patterns:** Support for daily, weekly, and custom recurring reminders
- **Deterministic Logic:** Reproducible scheduling decisions without AI/ML

**Key Features:**
- Transparent scheduling rules visible to users
- Conflict resolution based on priority hierarchy
- Real-time schedule recalculation
- Export/audit trail for research verification

### 2. Adaptive Threshold Alert Algorithm

An intelligent notification system that adjusts alert urgency based on user adherence patterns:

**Alert Levels:**
- **Normal:** Standard reminder for on-time adherence
- **Warning:** Escalated alert for missed doses (1-2 occurrences)
- **Critical:** High-priority notification for repeated non-adherence (3+ occurrences)

**Monitoring Metrics:**
- Dose confirmation tracking
- Snooze pattern analysis
- Time-window adherence scoring
- Historical behavior patterns

**Threshold Adaptation:**
- Baseline establishment period (7-14 days)
- Dynamic threshold adjustment based on user behavior
- Personalized alert timing optimization

## Technical Architecture

### Design Principles
- **Deterministic:** No AI/ML, purely rule-based logic
- **Transparent:** All scheduling decisions explainable
- **User-Centered:** Privacy-first, offline-capable design
- **Reproducible:** Consistent results for research validation

### Technology Stack
- **Framework:** Flutter (cross-platform mobile)
- **Storage:** Local SQLite with SharedPreferences
- **Notifications:** flutter_local_notifications
- **Audio:** Custom ringtone system with user previews

### Offline-First Architecture
- No cloud dependencies or IoT integration
- Complete functionality without internet
- Local data persistence and encryption
- User authentication with secure local storage

## Research Applications

This app is designed for:
- **Thesis Research:** Algorithm validation and user behavior studies
- **Clinical Studies:** Medication adherence pattern analysis
- **UX Research:** Deterministic vs. AI-based scheduling comparison
- **Local Healthcare:** Manila-specific medication management needs

## User Manual Features

### Getting Started
1. **Registration:** Email, password, and full name
2. **Onboarding:** Tips & Terms acceptance
3. **First Reminder:** Add medication with priority and schedule

### Priority System
- **Priority 1 (Emerald):** Highest importance, life-critical medications
- **Priority 2 (Blue):** Important daily medications
- **Priority 3 (Amber):** Moderate importance, symptomatic relief
- **Priority 4 (Red):** Lower priority, as-needed medications
- **Priority 5 (Pink):** Lowest priority, supplements

### Scheduling Features
- Date and time selection
- Repeat options (none, daily, weekly)
- Snooze duration customization
- Custom ringtone selection
- Mute/unmute per reminder

### Alert Settings
- Default ringtone configuration
- Preview audio before selection
- Global notification preferences

## Algorithm Documentation

### Priority Scheduling Logic

```
FUNCTION scheduleReminders(reminders):
  1. Filter active (non-muted) reminders
  2. Sort by time (earliest first)
  3. Within same time slot, sort by priority (highest first)
  4. Detect conflicts (overlapping ±15 minute windows)
  5. Resolve conflicts:
     - Keep highest priority
     - Shift lower priority by snooze interval
  6. Generate notification schedule
  RETURN ordered_schedule
```

### Adaptive Threshold Logic

```
FUNCTION calculateAlertLevel(reminder, history):
  missed_count = countMissedDoses(reminder, last_7_days)
  
  IF missed_count == 0:
    RETURN NORMAL
  ELSE IF missed_count <= 2:
    RETURN WARNING
  ELSE:
    RETURN CRITICAL
    
FUNCTION adjustThreshold(user_id):
  adherence_rate = calculateAdherenceRate(user_id, last_14_days)
  
  IF adherence_rate > 0.9:
    threshold_multiplier = 1.2  // More lenient
  ELSE IF adherence_rate < 0.6:
    threshold_multiplier = 0.8  // More strict
  ELSE:
    threshold_multiplier = 1.0  // Standard
    
  RETURN updated_thresholds
```

## Research Data Collection

The app supports research through:
- Export functionality for adherence data
- Timestamped event logging
- User behavior pattern tracking
- Algorithm decision audit trails

## Privacy & Ethics

- **No external data transmission:** All data stored locally
- **User consent:** Required T&C acceptance
- **Data ownership:** Users control their data
- **Research ethics:** IRB-compliant design for Manila studies

## Future Enhancements

- Multi-user household support
- Caregiver monitoring module
- Export to CSV for research analysis
- Tagalog/Filipino language support for Manila users

## Citation

If using this app for research, please cite:
```
[Your Name]. (2026). MedAlert+: A Deterministic Algorithm-Based Medication 
Management System for Adult Users in Manila. [Institution]. 
Thesis/Research Project.
```

## License

This project is intended for research and educational purposes.
See LICENSE file for details.

## Contact

For research inquiries or collaboration:
[Your Email]
[Your Institution]
Manila, Philippines
