
import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../models/app_models.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final DataService _dataService = DataService();
  late AppUser _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _dataService.currentUser!;
  }

  void _logout() {
    _dataService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _editProfile() {
    final avatarController = TextEditingController(text: _currentUser.avatarUrl);
    final bannerController = TextEditingController(text: _currentUser.bannerUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: avatarController,
              decoration: const InputDecoration(labelText: 'Avatar URL'),
            ),
            TextField(
              controller: bannerController,
              decoration: const InputDecoration(labelText: 'Banner URL'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _dataService.updateProfile(
                  _currentUser.id,
                  avatarUrl: avatarController.text,
                  bannerUrl: bannerController.text,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _getRecordColor(RecordType type) {
    switch (type) {
      case RecordType.promotion: return Colors.green;
      case RecordType.demotion: return Colors.orange;
      case RecordType.strike: return Colors.red;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner & Avatar
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    image: DecorationImage(
                      image: NetworkImage(_currentUser.bannerUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) {}, // Handle error gracefully
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_currentUser.avatarUrl),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            
            // User Info
            Text(
              _currentUser.username,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.deepPurpleAccent),
              ),
              child: Text(
                'Points: ${_currentUser.points}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Avatar & Banner'),
            ),
            
            const SizedBox(height: 32),
            
            // Records List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Records',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const Divider(indent: 16, endIndent: 16),
            
            if (_currentUser.records.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No records yet.', style: TextStyle(color: Colors.grey)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _currentUser.records.length,
                itemBuilder: (context, index) {
                  final record = _currentUser.records[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        Icons.circle,
                        color: _getRecordColor(record.type),
                      ),
                      title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(record.description),
                      trailing: Text(
                        record.date.toString().split(' ')[0],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
