
enum UserRole { admin, staff }

enum RecordType { promotion, demotion, strike, general }

class StaffRecord {
  final String id;
  final RecordType type;
  final String title;
  final String description;
  final DateTime date;

  StaffRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
  });
}

class AppUser {
  final String id;
  final String username;
  final UserRole role;
  String avatarUrl;
  String bannerUrl;
  int points;
  List<StaffRecord> records;

  AppUser({
    required this.id,
    required this.username,
    required this.role,
    this.avatarUrl = 'https://via.placeholder.com/150',
    this.bannerUrl = 'https://via.placeholder.com/600x200',
    this.points = 0,
    List<StaffRecord>? records,
  }) : records = records ?? [];
}
