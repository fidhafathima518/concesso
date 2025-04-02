import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerifyStudentApplicationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Student Applications")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('applications').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No student applications found"));
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(document['fullName']),
                  subtitle: Text("Registration No: ${document['registrationNumber']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          approveApplication(document.id);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          rejectApplication(document.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void approveApplication(String applicationId) {
    FirebaseFirestore.instance
        .collection('applications')
        .doc(applicationId)
        .update({'status': 'Approved'});
  }

  void rejectApplication(String applicationId) {
    FirebaseFirestore.instance
        .collection('applications')
        .doc(applicationId)
        .update({'status': 'Rejected'});
  }
}
