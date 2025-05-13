import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String userType = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    detectUserType();
  }

  Future<void> detectUserType() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        userType = 'unknown';
        isLoading = false;
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('student').doc(uid).get();
      if (userDoc.exists && userDoc.data()?['role'] != null) {
        setState(() {
          userType = userDoc.data()!['role']; // should be 'student' or 'institution'
          isLoading = false;
        });
      } else {
        setState(() {
          userType = 'unknown';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        userType = 'unknown';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userType == 'unknown') {
      return const Center(child: Text("User type not recognized."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .where('target', whereIn: ['all', userType])
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No announcements available."));
        }

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
                subtitle: Text("Date: $formattedDate"),
                leading: const Icon(Icons.announcement, color: Colors.orange),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
