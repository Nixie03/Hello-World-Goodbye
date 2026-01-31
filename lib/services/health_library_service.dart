class HealthLibraryEntry {
  final String name;
  final String type; // condition | medication
  final String category;
  final String definition;
  final List<String> uses;
  final List<String> symptoms;

  HealthLibraryEntry({
    required this.name,
    required this.type,
    required this.category,
    required this.definition,
    this.uses = const [],
    this.symptoms = const [],
  });
}

class HealthLibraryService {
  static final HealthLibraryService instance = HealthLibraryService._internal();
  HealthLibraryService._internal();

  final List<HealthLibraryEntry> _entries = [
    HealthLibraryEntry(
      name: 'Hypertension (High Blood Pressure)',
      type: 'condition',
      category: 'Cardiovascular',
      definition:
          'A long-term condition where blood pressure stays elevated (often 130/80 mmHg or higher).',
      symptoms: ['Headaches', 'Shortness of breath', 'Fatigue', 'Dizziness'],
    ),
    HealthLibraryEntry(
      name: 'Diabetes Type 2',
      type: 'condition',
      category: 'Endocrine',
      definition:
          'A condition where the body does not use insulin properly, leading to elevated blood sugar.',
      symptoms: [
        'Increased thirst',
        'Frequent urination',
        'Blurred vision',
        'Fatigue',
      ],
    ),
    HealthLibraryEntry(
      name: 'Asthma',
      type: 'condition',
      category: 'Respiratory',
      definition:
          'A chronic respiratory condition that causes airway inflammation and breathing difficulty.',
      symptoms: ['Wheezing', 'Shortness of breath', 'Chest tightness'],
    ),
    HealthLibraryEntry(
      name: 'Gastric Reflux (GERD)',
      type: 'condition',
      category: 'Digestive',
      definition:
          'A condition where stomach acid flows back into the esophagus causing heartburn.',
      symptoms: ['Heartburn', 'Regurgitation', 'Chest discomfort'],
    ),
    HealthLibraryEntry(
      name: 'Amlodipine',
      type: 'medication',
      category: 'Calcium Channel Blocker',
      definition:
          'A medication used to treat high blood pressure and chest pain (angina).',
      uses: ['Lowers blood pressure', 'Helps prevent angina'],
    ),
    HealthLibraryEntry(
      name: 'Lisinopril',
      type: 'medication',
      category: 'ACE Inhibitor',
      definition:
          'A medication used to treat high blood pressure and heart failure.',
      uses: ['Lowers blood pressure', 'Protects kidneys in diabetes'],
    ),
    HealthLibraryEntry(
      name: 'Metformin',
      type: 'medication',
      category: 'Antidiabetic',
      definition:
          'A medication that helps control blood sugar in type 2 diabetes.',
      uses: ['Improves insulin sensitivity', 'Lowers blood sugar'],
    ),
    HealthLibraryEntry(
      name: 'Albuterol',
      type: 'medication',
      category: 'Bronchodilator',
      definition:
          'A quick-relief inhaler that relaxes airway muscles for asthma symptoms.',
      uses: ['Relieves wheezing', 'Opens airways quickly'],
    ),
    HealthLibraryEntry(
      name: 'Omeprazole',
      type: 'medication',
      category: 'Proton Pump Inhibitor',
      definition: 'Reduces stomach acid production to treat reflux and ulcers.',
      uses: ['Treats GERD', 'Helps heal stomach ulcers'],
    ),
    HealthLibraryEntry(
      name: 'Levothyroxine',
      type: 'medication',
      category: 'Thyroid Hormone',
      definition: 'A synthetic thyroid hormone used to treat hypothyroidism.',
      uses: ['Replaces thyroid hormone', 'Improves energy'],
    ),
  ];

  List<HealthLibraryEntry> getAllEntries() => List.unmodifiable(_entries);

  List<HealthLibraryEntry> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    return _entries.where((entry) {
      return entry.name.toLowerCase().contains(q) ||
          entry.category.toLowerCase().contains(q) ||
          entry.definition.toLowerCase().contains(q);
    }).toList();
  }
}
