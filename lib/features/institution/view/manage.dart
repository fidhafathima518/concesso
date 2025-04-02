import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageApprovalsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Approvals")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('concession_applications').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No applications found"));
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(document['studentName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Reg No: ${document['registrationNumber']}"),
                      Text("Year: ${document['year']}"),
                      Text("Status: ${document['status']}"),
                    ],
                  ),
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
        .collection('concession_applications')
        .doc(applicationId)
        .update({'status': 'Approved'});
  }

  void rejectApplication(String applicationId) {
    FirebaseFirestore.instance
        .collection('concession_applications')
        .doc(applicationId)
        .update({'status': 'Rejected'});
  }
}
