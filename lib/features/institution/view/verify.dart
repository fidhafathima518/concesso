// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class VerifyStudentApplicationsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Verify Student Applications")),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('applications')
//             .where('verifiedByInstitution', isEqualTo: false) // only pending institution verification
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No student applications found"));
//           }
//           return ListView(
//             children: snapshot.data!.docs.map((document) {
//               final data = document.data() as Map<String, dynamic>;
//               return Card(
//                 margin: EdgeInsets.all(8.0),
//                 child: ListTile(
//                   title: Text(data['name']),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Registration No: ${data['studentId']}"),
//                       Text("College: ${data['college']}"),
//                       Text("Year of Study: ${data['yearOfStudy']}"),
//                       Text("Status: ${data['status']}"),
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.check, color: Colors.green),
//                         onPressed: () => _approveApplication(document.id),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.cancel, color: Colors.red),
//                         onPressed: () => _rejectApplication(document.id),
//                       ),
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
//   void _approveApplication(String applicationId) {
//     FirebaseFirestore.instance.collection('applications').doc(applicationId).update({
//       'status': 'Institution Approved',
//       'verifiedByInstitution': true,
//     });
//   }
//
//   void _rejectApplication(String applicationId) {
//     FirebaseFirestore.instance.collection('applications').doc(applicationId).update({
//       'status': 'Rejected by Institution',
//       'verifiedByInstitution': false,
//     });
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerifyStudentApplicationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Student Applications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('verifiedByInstitution', isEqualTo: false) // Only unverified applications
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No student applications to verify"));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['name'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text("Reg No: ${data['studentId'] ?? ''}"),
                      Text("College: ${data['college'] ?? ''}"),
                      Text("Year: ${data['yearOfStudy'] ?? ''}"),
                      Text("Status: ${data['status'] ?? 'Pending'}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        tooltip: 'Approve',
                        onPressed: () => _approveApplication(doc.id),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Reject',
                        onPressed: () => _rejectApplication(doc.id),
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

  void _approveApplication(String applicationId) async {
    await FirebaseFirestore.instance
        .collection('applications')
        .doc(applicationId)
        .update({
      'status': 'Institution Approved',
      'verifiedByInstitution': true,
    });
  }

  void _rejectApplication(String applicationId) async {
    await FirebaseFirestore.instance
        .collection('applications')
        .doc(applicationId)
        .update({
      'status': 'Rejected by Institution',
      'verifiedByInstitution': false,
    });
  }
}
