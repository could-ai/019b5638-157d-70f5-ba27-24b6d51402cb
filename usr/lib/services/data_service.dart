
import 'package:flutter/material.dart';
import '../models/app_models.dart';

class DataService extends ChangeNotifier {
  // Singleton pattern
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal() {
    _initMockData();
  }

  List<AppUser> _users = [];
  AppUser? _currentUser;

  List<AppUser> get users => _users;
  AppUser? get currentUser => _currentUser;

  void _initMockData() {
    _users = [
      AppUser(
        id: '1',
        username: 'AdminUser',
        role: UserRole.admin,
        points: 100,
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Admin',
      ),
      AppUser(
        id: '2',
        username: 'StaffMember1',
        role: UserRole.staff,
        points: 50,
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Staff1',
        records: [
          StaffRecord(
            id: 'r1',
            type: RecordType.promotion,
            title: 'Promoted to Moderator',
            description: 'Great performance in chat moderation.',
            date: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ],
      ),
      AppUser(
        id: '3',
        username: 'StaffMember2',
        role: UserRole.staff,
        points: 20,
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Staff2',
      ),
    ];
  }

  // Auth Methods
  bool login(String username) {
    try {
      final user = _users.firstWhere(
        (u) => u.username.toLowerCase() == username.toLowerCase(),
      );
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Admin Methods
  void addStaff(String username) {
    final newUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      role: UserRole.staff,
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=$username',
    );
    _users.add(newUser);
    notifyListeners();
  }

  void removeStaff(String id) {
    _users.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  void updatePoints(String userId, int pointsToAdd) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].points += pointsToAdd;
      notifyListeners();
    }
  }

  void addRecord(String userId, StaffRecord record) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].records.add(record);
      notifyListeners();
    }
  }

  void removeRecord(String userId, String recordId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].records.removeWhere((r) => r.id == recordId);
      notifyListeners();
    }
  }

  // Staff Methods
  void updateProfile(String userId, {String? avatarUrl, String? bannerUrl}) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      if (avatarUrl != null) _users[index].avatarUrl = avatarUrl;
      if (bannerUrl != null) _users[index].bannerUrl = bannerUrl;
      notifyListeners();
    }
  }
}
