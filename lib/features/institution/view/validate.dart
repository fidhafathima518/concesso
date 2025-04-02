import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ValidateStudentDocumentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Validate Student Documents")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('student_documents').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No student documents found"));
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(document['fullName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Registration No: ${document['registrationNumber']}"),
                      SizedBox(height: 8),
                      Text("Document Type: ${document['documentType']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DocumentViewerPage(
                                documentUrl: document['documentUrl'],
                              ),
                            ),
                          );
                        },
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

  void validateDocument(String documentId, String status) {
    FirebaseFirestore.instance
        .collection('student_documents')
        .doc(documentId)
        .update({'status': status});
  }
}

class DocumentViewerPage extends StatelessWidget {
  final String documentUrl;

  DocumentViewerPage({required this.documentUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Document")),
      body: Center(
        child: documentUrl.isNotEmpty
            ? Image.network(documentUrl)
            : Text("No document available"),
      ),
    );
  }
}
