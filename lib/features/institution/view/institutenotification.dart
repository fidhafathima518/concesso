import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InstitutionNotificationsPage extends StatelessWidget {
  final String userType; // 'student' or 'institution'

  const InstitutionNotificationsPage({required this.userType});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .where('target', whereIn: ['all', 'institution'])
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Center(child: Text("No announcements available."));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final message = data['message'] ?? '';
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
            final formattedDate = timestamp != null
                ? "${timestamp.day}/${timestamp.month}/${timestamp.year}"
                : "Unknown date";

            return Card(
              child: ListTile(
                title: Text(message),
                subtitle: Text(formattedDate),
                leading: Icon(Icons.announcement, color: Colors.orange),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
