import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concessoapp/features/institution/view/support.dart';
import 'package:concessoapp/features/institution/view/validate.dart';
import 'package:concessoapp/features/institution/view/verify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:concessoapp/features/institution/view/profile.dart';

import 'institutenotification.dart';
import 'manage.dart';

class InstitutionHome extends StatefulWidget {
  @override
  _InstitutionHomeState createState() => _InstitutionHomeState();
}

class _InstitutionHomeState extends State<InstitutionHome> {
  int _selectedIndex = 0;
  String institutionName = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchInstitutionDetails();
  }

  Future<void> fetchInstitutionDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot institutionDoc = await FirebaseFirestore.instance
          .collection('institution')
          .doc(user.uid)
          .get();

      if (institutionDoc.exists) {
        setState(() {
          institutionName = institutionDoc['name'] ?? "Unknown Institution";
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      InstitutionDashboard(institutionName: institutionName),
      InstitutionSupport(),
      InstitutionNotificationsPage(userType: 'institution'),
      InstitutionProfile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Institution Dashboard"),
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences _pref = await SharedPreferences.getInstance();
              _pref.clear();
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/loginpage', (Route route) => false);
              });
            },
            icon: Icon(Icons.logout, color: Colors.black, size: 24),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.support), label: "Support"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class InstitutionDashboard extends StatelessWidget {
  final String institutionName;

  const InstitutionDashboard({required this.institutionName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileSection(context),
          SizedBox(height: 20),
          _buildCardSection(
            context,
            title: "Verify Student Applications",
            subtitle: "Approve or Reject Student Requests",
            icon: Icons.assignment,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VerifyStudentApplicationsPage()),
              );
            },
          ),
          _buildCardSection(
            context,
            title: "Validate Student Documents",
            subtitle: "Check uploaded documents for authenticity",
            icon: Icons.folder_open,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ValidateStudentDocumentsPage()),
              );
            },
          ),
          _buildCardSection(
            context,
            title: "Manage Approvals",
            subtitle: "Approve or Reject Transport Pass Applications",
            icon: Icons.check_circle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageApprovalsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage("assets/image/institute.png"),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(institutionName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Verification Panel", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildCardSection(BuildContext context,
      {required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
