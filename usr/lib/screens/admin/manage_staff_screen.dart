
import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../models/app_models.dart';

class ManageStaffScreen extends StatefulWidget {
  final String userId;

  const ManageStaffScreen({super.key, required this.userId});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  final DataService _dataService = DataService();
  late AppUser _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    try {
      _user = _dataService.users.firstWhere((u) => u.id == widget.userId);
    } catch (e) {
      Navigator.pop(context); // User not found
    }
  }

  void _addPoints() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Points'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Points (positive to add, negative to remove)',
            hintText: 'e.g. 10 or -5',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final points = int.tryParse(controller.text);
              if (points != null) {
                setState(() {
                  _dataService.updatePoints(_user.id, points);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _addRecord() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    RecordType selectedType = RecordType.general;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<RecordType>(
                  value: selectedType,
                  isExpanded: true,
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                  items: RecordType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final newRecord = StaffRecord(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: selectedType,
                    title: titleController.text,
                    description: descController.text,
                    date: DateTime.now(),
                  );
                  setState(() {
                    _dataService.addRecord(_user.id, newRecord);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Staff?'),
        content: Text('Are you sure you want to remove ${_user.username}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _dataService.removeStaff(_user.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dashboard
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
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
        title: Text(_user.username),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _removeUser,
            tooltip: 'Remove Staff',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_user.avatarUrl),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Points: ${_user.points}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.deepPurpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _addPoints,
                    icon: const Icon(Icons.star),
                    label: const Text('Manage Points'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Records Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Records History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: _addRecord,
                  icon: const Icon(Icons.add_circle, color: Colors.deepPurpleAccent),
                ),
              ],
            ),
            const Divider(),
            if (_user.records.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No records found.')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _user.records.length,
                itemBuilder: (context, index) {
                  final record = _user.records[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        Icons.circle,
                        color: _getRecordColor(record.type),
                        size: 16,
                      ),
                      title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.description),
                          const SizedBox(height: 4),
                          Text(
                            record.date.toString().split(' ')[0],
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _dataService.removeRecord(_user.id, record.id);
                          });
                        },
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
