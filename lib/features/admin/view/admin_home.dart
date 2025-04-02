import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int totalApplications = 0;
  int activeComplaints = 0;
  int issuedCards = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    QuerySnapshot applicationsSnapshot =
    await FirebaseFirestore.instance.collection('applications').get();
    QuerySnapshot grievancesSnapshot =
    await FirebaseFirestore.instance.collection('complaints').where('status', isEqualTo: 'active').get();
    QuerySnapshot issuedCardsSnapshot =
    await FirebaseFirestore.instance.collection('issued_cards').get();

    setState(() {
      totalApplications = applicationsSnapshot.docs.length;
      activeComplaints = grievancesSnapshot.docs.length;
      issuedCards = issuedCardsSnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/loginpage', (route) => false);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDashboardCard("Total Applications", totalApplications, Icons.assignment),
            _buildDashboardCard("Active Complaints", activeComplaints, Icons.report_problem),
            _buildDashboardCard("Issued Cards", issuedCards, Icons.card_membership),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildFeatureTile("Manage Applications", Icons.checklist, '/manageApplications'),
                  _buildFeatureTile("Announcements", Icons.announcement, '/announcements'),
                  _buildFeatureTile("Complaints Management", Icons.support, '/complaintsmanagement'),
                  _buildFeatureTile("Card Reissuance", Icons.refresh, '/cardReissuance'),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, int count, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blue),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }

  Widget _buildFeatureTile(String title, IconData icon, String route,) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
