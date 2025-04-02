import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageApplicationsPage extends StatefulWidget {
  @override
  _ManageApplicationsPageState createState() => _ManageApplicationsPageState();
}

class _ManageApplicationsPageState extends State<ManageApplicationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Applications"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('applications').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No applications found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var application = snapshot.data!.docs[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Applicant: " + application['name']),
                  subtitle: Text("Status: " + application['status']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _updateApplicationStatus(application.id, "Approved"),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _updateApplicationStatus(application.id, "Rejected"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateApplicationStatus(String docId, String status) async {
    await FirebaseFirestore.instance.collection('applications').doc(docId).update({'status': status});
  }
}
