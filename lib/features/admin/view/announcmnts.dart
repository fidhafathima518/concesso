import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementsPage extends StatefulWidget {
  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final TextEditingController _announcementController = TextEditingController();
  String _selectedTarget = 'all';

  void _addAnnouncement() async {
    if (_announcementController.text.isNotEmpty) {
      final now = Timestamp.fromDate(DateTime.now());

      await FirebaseFirestore.instance.collection('announcements').add({
        'message': _announcementController.text,
        'timestamp': now,
        'target': _selectedTarget,
      });

      _announcementController.clear();
    }
  }

  void _deleteAnnouncement(String docId) async {
    await FirebaseFirestore.instance.collection('announcements').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Announcements")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _announcementController,
                    decoration: InputDecoration(
                      labelText: "New Announcement",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedTarget,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text("All")),
                    DropdownMenuItem(value: 'student', child: Text("Students")),
                    DropdownMenuItem(value: 'institution', child: Text("Institutions")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedTarget = value!;
                    });
                  },
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addAnnouncement,
                  child: Text("Post"),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('announcements')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No announcements available"));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var announcement = snapshot.data!.docs[index];
                    final data = announcement.data() as Map<String, dynamic>;
                    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                    final formattedDate = timestamp != null
                        ? "${timestamp.day}/${timestamp.month}/${timestamp.year}"
                        : "Unknown date";

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(data['message'] ?? ''),
                        subtitle: Text("Target: ${data['target']} • $formattedDate"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAnnouncement(announcement.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
