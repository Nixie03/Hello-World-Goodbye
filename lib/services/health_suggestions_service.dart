class HealthSuggestion {
  final String title;
  final String description;
  final String category;
  final List<String> symptoms;
  final List<String> treatments;

  HealthSuggestion({
    required this.title,
    required this.description,
    required this.category,
    required this.symptoms,
    required this.treatments,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'symptoms': symptoms,
      'treatments': treatments,
    };
  }
}

class HealthSuggestionsService {
  static final HealthSuggestionsService _instance = HealthSuggestionsService._internal();

  HealthSuggestionsService._internal();

  factory HealthSuggestionsService() {
    return _instance;
  }

  final List<HealthSuggestion> suggestions = [
    HealthSuggestion(
      title: 'Hypertension (High Blood Pressure)',
      description: 'Hypertension is when blood pressure is consistently 130/80 mmHg or higher. It\'s often called "the silent killer" because many people don\'t know they have it.',
      category: 'Cardiovascular',
      symptoms: ['Headaches', 'Shortness of breath', 'Nosebleeds', 'Fatigue'],
      treatments: ['Reduce sodium intake', 'Exercise regularly', 'Manage stress', 'Take prescribed medications as directed'],
    ),
    HealthSuggestion(
      title: 'Diabetes Type 2',
      description: 'Type 2 diabetes occurs when the body can\'t use insulin properly (insulin resistance). It\'s the most common type of diabetes.',
      category: 'Endocrine',
      symptoms: ['Increased thirst', 'Frequent urination', 'Fatigue', 'Blurred vision', 'Slow wound healing'],
      treatments: ['Monitor blood sugar levels', 'Eat balanced meals', 'Regular physical activity', 'Take medications as prescribed', 'Regular check-ups'],
    ),
    HealthSuggestion(
      title: 'Asthma',
      description: 'Asthma is a chronic respiratory condition that causes inflammation of the airways, making it difficult to breathe.',
      category: 'Respiratory',
      symptoms: ['Wheezing', 'Shortness of breath', 'Chest tightness', 'Coughing (especially at night)'],
      treatments: ['Use inhalers as prescribed', 'Identify and avoid triggers', 'Keep rescue inhaler handy', 'Regular monitoring', 'Maintain clean environment'],
    ),
    HealthSuggestion(
      title: 'Arthritis',
      description: 'Arthritis is inflammation of one or more joints, causing pain, stiffness, and sometimes swelling. Common types include osteoarthritis and rheumatoid arthritis.',
      category: 'Musculoskeletal',
      symptoms: ['Joint pain', 'Stiffness', 'Swelling', 'Reduced range of motion', 'Redness around joints'],
      treatments: ['Anti-inflammatory medications', 'Physical therapy', 'Hot/cold therapy', 'Regular gentle exercise', 'Weight management'],
    ),
    HealthSuggestion(
      title: 'Thyroid Disease',
      description: 'Thyroid disorders affect the thyroid gland\'s ability to produce hormones, impacting metabolism, energy, and body temperature.',
      category: 'Endocrine',
      symptoms: ['Fatigue', 'Weight changes', 'Temperature sensitivity', 'Hair loss', 'Mood changes'],
      treatments: ['Thyroid medication (levothyroxine)', 'Regular monitoring of TSH levels', 'Consistent medication timing', 'Balanced diet', 'Regular check-ups'],
    ),
    HealthSuggestion(
      title: 'Allergic Rhinitis',
      description: 'Allergic rhinitis is an allergic reaction that causes inflammation of the nasal passages. It\'s triggered by exposure to allergens.',
      category: 'Allergic',
      symptoms: ['Sneezing', 'Nasal congestion', 'Itchy/watery eyes', 'Runny nose', 'Itchy throat'],
      treatments: ['Avoid allergen triggers', 'Antihistamine medications', 'Decongestants', 'Nasal saline rinses', 'Air purifiers in home'],
    ),
    HealthSuggestion(
      title: 'Depression',
      description: 'Depression is a mental health condition characterized by persistent sad mood, loss of interest in activities, and decreased energy.',
      category: 'Mental Health',
      symptoms: ['Persistent sadness', 'Loss of interest in activities', 'Sleep disturbances', 'Fatigue', 'Difficulty concentrating', 'Feelings of worthlessness'],
      treatments: ['Antidepressant medications', 'Therapy/counseling', 'Regular exercise', 'Social support', 'Healthy sleep habits', 'Stress management'],
    ),
    HealthSuggestion(
      title: 'Gastric Reflux (GERD)',
      description: 'Gastroesophageal reflux disease occurs when stomach acid frequently flows back into the esophagus, causing heartburn and discomfort.',
      category: 'Digestive',
      symptoms: ['Heartburn', 'Regurgitation', 'Difficulty swallowing', 'Chest pain', 'Sensation of lump in throat'],
      treatments: ['Proton pump inhibitors', 'H2 blockers', 'Avoid spicy/acidic foods', 'Eat smaller meals', 'Sleep with head elevated', 'Weight management'],
    ),
  ];

  List<HealthSuggestion> getAllSuggestions() => suggestions;

  HealthSuggestion? getSuggestionByTitle(String title) {
    try {
      return suggestions.firstWhere((s) => s.title.toLowerCase() == title.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  List<HealthSuggestion> getSuggestionsByCategory(String category) {
    return suggestions.where((s) => s.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<String> getAvailableCategories() {
    final categories = <String>{};
    for (var suggestion in suggestions) {
      categories.add(suggestion.category);
    }
    return categories.toList();
  }

  HealthSuggestion getRandomSuggestion() {
    suggestions.shuffle();
    return suggestions.first;
  }
}
