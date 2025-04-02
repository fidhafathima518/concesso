

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   String userName = "Loading...";
//   String universityName = "Loading...";
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }
//
//   Future<void> _fetchUserData() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//
//       if (userDoc.exists) {
//         setState(() {
//           userName = userDoc['name'] ?? "Unknown";
//           universityName = userDoc['universityName'] ?? "Unknown University";
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Concesso"),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               SharedPreferences _pref = await SharedPreferences.getInstance();
//               _pref.clear();
//               FirebaseAuth.instance.signOut().then((value) {
//                 Navigator.pushNamedAndRemoveUntil(
//                     context, '/loginpage', (Route route) => false);
//               });
//             },
//             icon: Icon(Icons.logout, color: Colors.black, size: 24),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildProfileSection(),
//             SizedBox(height: 20),
//             _buildCardSection(
//               context,
//               title: "Apply for Concession Card",
//               subtitle: "Start your application now",
//               icon: Icons.card_membership,
//               onTap: () {
//                 // Navigate to Apply Page
//               },
//             ),
//             _buildCardSection(
//               context,
//               title: "Renew Concession Card",
//               subtitle: "Renew your expired card",
//               icon: Icons.refresh,
//               onTap: () {
//                 // Navigate to Renew Page
//               },
//             ),
//             _buildCardSection(
//               context,
//               title: "Complaint Registration",
//               subtitle: "Report any issues",
//               icon: Icons.report_problem,
//               onTap: () {
//                 // Navigate to Complaint Page
//               },
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.list), label: "Applications"),
//           BottomNavigationBarItem(icon: Icon(Icons.support), label: "Support"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//       ),
//     );
//   }
//
//   Widget _buildProfileSection() {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 30,
//           backgroundImage: AssetImage("assets/image/stdnt.png"),
//         ),
//         SizedBox(width: 16),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text(universityName, style: TextStyle(color: Colors.grey)),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCardSection(BuildContext context,
//       {required String title,
//         required String subtitle,
//         required IconData icon,
//         required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 3,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: ListTile(
//           leading: Icon(icon, color: Colors.blue),
//           title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
//           subtitle: Text(subtitle),
//           trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
//         ),
//       ),
//     );
//   }
// }





import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'applications.dart';
import 'profile.dart';
import 'support.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String userName = "Loading...";
  String universityName = "Loading...";

  final List<Widget> _pages = [
    HomeContent(),
    ApplicationsPage(),
    SupportPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? "Unknown";
          universityName = userDoc['universityName'] ?? "Unknown University";
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Concesso"),
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences _pref = await SharedPreferences.getInstance();
              _pref.clear();
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (Route route) => false);
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.support), label: "Support"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardSection(
            context,
            title: "Apply for Concession Card",
            subtitle: "Start your application now",
            icon: Icons.card_membership,
            onTap: () {
              Navigator.pushNamed(context, '/applyConcession');
            },
          ),
          _buildCardSection(
            context,
            title: "Renew Concession Card",
            subtitle: "Renew your expired card",
            icon: Icons.refresh,
            onTap: () {
              Navigator.pushNamed(context, '/renewConcession');
            },
          ),
          _buildCardSection(
            context,
            title: "Complaint Registration",
            subtitle: "Report any issues",
            icon: Icons.report_problem,
            onTap: () {
              Navigator.pushNamed(context, '/complaints');
            },
          ),
        ],
      ),
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
