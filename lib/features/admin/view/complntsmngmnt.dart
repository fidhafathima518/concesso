import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintsManagementPage extends StatefulWidget {
  @override
  _ComplaintsManagementPageState createState() => _ComplaintsManagementPageState();
}

class _ComplaintsManagementPageState extends State<ComplaintsManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaints Management"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No complaints found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var complaint = snapshot.data!.docs[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("User: " + complaint['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Issue: " + complaint['issue']),
                      Text("Status: " + complaint['status']),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _updateComplaintStatus(complaint.id, "Resolved"),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _updateComplaintStatus(complaint.id, "Rejected"),
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

  void _updateComplaintStatus(String docId, String status) async {
    await FirebaseFirestore.instance.collection('complaints').doc(docId).update({'status': status});
  }
}
