class Ad {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? actionText;
  final String category;

  Ad({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.actionText,
    required this.category,
  });
}

class AdsService {
  static final AdsService _instance = AdsService._internal();

  AdsService._internal();

  factory AdsService() {
    return _instance;
  }

  final List<Ad> ads = [
    Ad(
      id: 'ad_001',
      title: 'Health Monitoring Device',
      description: 'Track your vital signs with our smart health monitoring device. Compatible with MedAlert+.',
      category: 'Health Device',
      actionText: 'Learn More',
    ),
    Ad(
      id: 'ad_002',
      title: 'Telehealth Consultations',
      description: 'Connect with licensed doctors online. Schedule appointments in minutes.',
      category: 'Healthcare Service',
      actionText: 'Book Now',
    ),
    Ad(
      id: 'ad_003',
      title: 'Supplement Store',
      description: 'Quality vitamins and supplements delivered to your home. Use code MEDALERT for 10% off.',
      category: 'Wellness',
      actionText: 'Shop Now',
    ),
    Ad(
      id: 'ad_004',
      title: 'Fitness App',
      description: 'Combine medication management with fitness tracking for better health outcomes.',
      category: 'Wellness',
      actionText: 'Download',
    ),
    Ad(
      id: 'ad_005',
      title: 'Medical Records Storage',
      description: 'Secure cloud storage for your medical documents and health records.',
      category: 'Healthcare Service',
      actionText: 'Sign Up',
    ),
  ];

  List<Ad> getAllAds() => ads;

  Ad getRandomAd() {
    ads.shuffle();
    return ads.first;
  }

  List<Ad> getAdsByCategory(String category) {
    return ads.where((ad) => ad.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<Ad> getMultipleRandomAds(int count) {
    final shuffled = [...ads];
    shuffled.shuffle();
    return shuffled.take(count).toList();
  }
}
