import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardReissuancePage extends StatefulWidget {
  @override
  _CardReissuancePageState createState() => _CardReissuancePageState();
}

class _CardReissuancePageState extends State<CardReissuancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Card Reissuance Requests"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('card_reissuance').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No reissuance requests found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var request = snapshot.data!.docs[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("User: " + request['name']),
                  subtitle: Text("Reason: " + request['reason']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _updateRequestStatus(request.id, "Approved"),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _updateRequestStatus(request.id, "Rejected"),
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

  void _updateRequestStatus(String docId, String status) async {
    await FirebaseFirestore.instance.collection('card_reissuance').doc(docId).update({'status': status});
  }
}
