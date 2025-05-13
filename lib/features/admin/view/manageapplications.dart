// // manageapplications.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ManageApplicationsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Manage Applications")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('applications')
//             .orderBy('submittedAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No applications found"));
//
//           return ListView(
//             children: snapshot.data!.docs.map((doc) {
//               final data = doc.data() as Map<String, dynamic>;
//               return Card(
//                 margin: EdgeInsets.all(10),
//                 child: ListTile(
//                   title: Text("Name: ${data['name']}"),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Status: ${data['status']}"),
//                       Text("College: ${data['college']}"),
//                       Text("Student ID: ${data['studentId']}"),
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(icon: Icon(Icons.check, color: Colors.green), onPressed: () => _updateStatus(doc.id, data, "Approved")),
//                       IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => _updateStatus(doc.id, data, "Rejected")),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
//
//   void _updateStatus(String docId, Map<String, dynamic> data, String status) async {
//     Map<String, dynamic> updateData = {
//       'status': status,
//     };
//
//     if (status == "Approved") {
//       updateData['validUntil'] = DateTime.now().add(Duration(days: 180)); // 6 months validity
//     }
//
//     await FirebaseFirestore.instance.collection('applications').doc(docId).update(updateData);
//   }
// }
//
//

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageApplicationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Applications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('verifiedByInstitution', isEqualTo: true) // Filter here
            .orderBy('submittedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text("No verified applications found"));

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Name: ${data['name']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${data['status']}"),
                      Text("College: ${data['college']}"),
                      Text("Student ID: ${data['studentId']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _updateStatus(doc.id, data, "Approved"),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _updateStatus(doc.id, data, "Rejected"),
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

  void _updateStatus(String docId, Map<String, dynamic> data, String status) async {
    Map<String, dynamic> updateData = {
      'status': status,
    };

    if (status == "Approved") {
      updateData['validUntil'] = DateTime.now().add(Duration(days: 180)); // 6 months validity
    }

    await FirebaseFirestore.instance.collection('applications').doc(docId).update(updateData);
  }
}
