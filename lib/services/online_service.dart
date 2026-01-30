import 'package:connectivity_plus/connectivity_plus.dart';

class OnlineService {
  static final OnlineService _instance = OnlineService._internal();
  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _currentStatus = [ConnectivityResult.none];

  OnlineService._internal();

  factory OnlineService() {
    return _instance;
  }

  Future<bool> isOnline() async {
    try {
      _currentStatus = await _connectivity.checkConnectivity();
      return !_currentStatus.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  bool get currentIsOnline => !_currentStatus.contains(ConnectivityResult.none);

  Stream<bool> onlineStatusStream() {
    return _connectivity.onConnectivityChanged.map((result) {
      _currentStatus = result;
      return !result.contains(ConnectivityResult.none);
    });
  }
}
