// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class CardReissuancePage extends StatefulWidget {
//   @override
//   _CardReissuancePageState createState() => _CardReissuancePageState();
// }
//
// class _CardReissuancePageState extends State<CardReissuancePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Card Reissuance Requests"),
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance.collection('card_reissuance').snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No reissuance requests found"));
//           }
//
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               var request = snapshot.data!.docs[index];
//               return Card(
//                 margin: EdgeInsets.all(10),
//                 child: ListTile(
//                   title: Text("User: " + request['name']),
//                   subtitle: Text("Reason: " + request['reason']),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.check, color: Colors.green),
//                         onPressed: () => _updateRequestStatus(request.id, "Approved"),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.close, color: Colors.red),
//                         onPressed: () => _updateRequestStatus(request.id, "Rejected"),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   void _updateRequestStatus(String docId, String status) async {
//     await FirebaseFirestore.instance.collection('card_reissuance').doc(docId).update({'status': status});
//   }
// }






import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardReissuancePage extends StatelessWidget {
  const CardReissuancePage({super.key});

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Renewal Application Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow("Name", data['name']),
              _infoRow("Student ID", data['studentId']),
              _infoRow("College", data['college']),
              _infoRow("Year", data['yearOfStudy']),
              _infoRow("Address", data['address']),
              _infoRow("Status", data['status']),
              const SizedBox(height: 10),
              const Text("Uploaded Photo:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              _imagePreview(data['photoUrl']),
              const SizedBox(height: 10),
              const Text("Old Concession Card:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              _imagePreview(data['oldCardUrl']),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text("$label: ${value ?? 'N/A'}"),
    );
  }

  Widget _imagePreview(String? url) {
    if (url == null || url.isEmpty) return const Text("No image");
    return Image.network(url, height: 150, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Card Renewal Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('card_reissuance')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No renewal requests found."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['name'] ?? ''),
                subtitle: Text("ID: ${data['studentId']} | Status: ${data['status']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_red_eye),
                  onPressed: () => _showDetailsDialog(context, data),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
