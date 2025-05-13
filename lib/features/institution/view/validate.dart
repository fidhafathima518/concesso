//
//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class ValidateStudentDocumentsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Validate Student Documents")),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('student_documents')
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No student documents found"));
//           }
//
//           return ListView(
//             children: snapshot.data!.docs.map((document) {
//               final data = document.data() as Map<String, dynamic>;
//               return Card(
//                 margin: EdgeInsets.all(8.0),
//                 child: ListTile(
//                   title: Text(data['fullName'] ?? 'No Name'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Registration No: ${data['registrationNumber'] ?? 'N/A'}"),
//                       SizedBox(height: 8),
//                       Text("Document Type: ${data['documentType'] ?? 'N/A'}"),
//                       SizedBox(height: 8),
//                       data['documentUrl'] != null
//                           ? Image.network(data['documentUrl'], height: 100)
//                           : Text("No Document Uploaded"),
//                       SizedBox(height: 8),
//                       Text("Status: ${data['status'] ?? 'Pending'}"),
//                     ],
//                   ),
//                   isThreeLine: true,
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.check, color: Colors.green),
//                         onPressed: () {
//                           validateDocument(document.id, "Approved");
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.cancel, color: Colors.red),
//                         onPressed: () {
//                           validateDocument(document.id, "Rejected");
//                         },
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
//   void validateDocument(String documentId, String status) {
//     FirebaseFirestore.instance
//         .collection('student_documents')
//         .doc(documentId)
//         .update({'status': status});
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ValidateStudentDocumentsPage extends StatelessWidget {
  const ValidateStudentDocumentsPage({Key? key}) : super(key: key);

  void validateDocument(String documentId, String status) {
    FirebaseFirestore.instance
        .collection('student_documents')
        .doc(documentId)
        .update({'status': status});
  }

  void showImageFullScreen(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: Center(
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Validate Student Documents")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('student_documents')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No student documents found"));
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              final data = document.data() as Map<String, dynamic>;
              final docUrl = data['documentUrl'] ?? '';

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(data['fullName'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Registration No: ${data['registrationNumber'] ?? 'N/A'}"),
                      SizedBox(height: 8),
                      Text("Document Type: ${data['documentType'] ?? 'N/A'}"),
                      SizedBox(height: 8),
                      docUrl.isNotEmpty
                          ? Image.network(docUrl, height: 100)
                          : Text("No Document Uploaded"),
                      SizedBox(height: 8),
                      Text("Status: ${data['status'] ?? 'Pending'}"),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                        tooltip: 'View Full Document',
                        onPressed: docUrl.isNotEmpty
                            ? () => showImageFullScreen(context, docUrl)
                            : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          validateDocument(document.id, "Approved");
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          validateDocument(document.id, "Rejected");
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
}
