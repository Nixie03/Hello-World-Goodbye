import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/medication_service.dart';

class AlertSettingsScreen extends StatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  State<AlertSettingsScreen> createState() => _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends State<AlertSettingsScreen> {
  final AudioPlayer _player = AudioPlayer();
  final List<String> _ringtones = ['default', 'chime.wav', 'soft_bell.wav', 'silent'];
  String _selected = 'default';

  @override
  void initState() {
    super.initState();
    _loadSelected();
  }

  Future<void> _loadSelected() async {
    // Read persisted value directly to avoid depending on service initialization order
    // prefer the service helper in case future logic changes
    final prefsValue = await MedicationService.instance.loadPrefsForSettings();
    setState(() => _selected = prefsValue ?? 'default');
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _preview(String name) async {
    if (name == 'silent') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silent preview')));
      return;
    }
    if (name == 'default') {
      // Try to play a bundled default tone if available, otherwise fall back to system alert
      try {
        await _player.play(AssetSource('ringtones/chime.wav'));
      } catch (e) {
        SystemSound.play(SystemSoundType.alert);
      }
      return;
    }

    final assetPath = 'assets/ringtones/$name';
    try {
      await rootBundle.load(assetPath);
      await _player.play(AssetSource('ringtones/$name'));
    } catch (e) {
      SystemSound.play(SystemSoundType.alert);
      if (!mounted) return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Playing preview: $name')));
  }

  Future<void> _select(String name) async {
    setState(() => _selected = name);
    // Persist selection
    await MedicationService.instance.setDefaultRingtone(name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Default ringtone set to $name')));
  }

  void _manage() {
    showDialog<void>(context: context, builder: (c) => AlertDialog(title: const Text('Manage ringtones'), content: const Text('Import from phone or select custom ringtones is platform specific and will be supported in native builds.'), actions: [TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Close'))]));
  }

  void playRingtone() {
    // Play a short system-style tone as a preview. This is intentionally simple
    // and will be replaced with platform-specific preview behavior if needed.
    SystemSound.play(SystemSoundType.alert);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert settings'),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: _manage)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text('Choose a default ringtone for medication alarms', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListView.separated(
                  itemCount: _ringtones.length,
                  separatorBuilder: (context, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final n = _ringtones[i];
                    return ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(_titleFor(n)),
                      subtitle: Text(n == 'silent' ? 'No sound' : 'Built-in sound'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.play_arrow), onPressed: () => _preview(n)),
                          Radio<String>(value: n, groupValue: _selected, onChanged: (v) => _select(v!)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _titleFor(String id) {
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
}
