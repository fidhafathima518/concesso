//
//
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'profile.dart';
// import 'support.dart';
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;
//   String userName = "Loading...";
//   String universityName = "Loading...";
//   String applicationStatus = "";
//   Map<String, dynamic>? approvedCard;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//     _fetchApplicationStatus();
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
//   Future<void> _fetchApplicationStatus() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       var appSnap = await FirebaseFirestore.instance
//           .collection('applications')
//           .where('userId', isEqualTo: user.uid)
//           .orderBy('submittedAt', descending: true)
//           .limit(1)
//           .get();
//
//       if (appSnap.docs.isNotEmpty) {
//         var application = appSnap.docs.first.data();
//         setState(() {
//           applicationStatus = application['status'] ?? "Pending";
//         });
//
//         if (applicationStatus == "Approved") {
//           setState(() {
//             approvedCard = application;
//           });
//         }
//       } else {
//         setState(() {
//           applicationStatus = "No Application Found";
//         });
//       }
//     }
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   List<Widget> get _pages => [
//     HomeContent(
//       userName: userName,
//       universityName: universityName,
//       applicationStatus: applicationStatus,
//       approvedCard: approvedCard,
//     ),
//     SupportPage(),
//     ProfilePage(),
//   ];
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
//                 Navigator.pushNamedAndRemoveUntil(context, '/', (Route route) => false);
//               });
//             },
//             icon: Icon(Icons.logout, color: Colors.black),
//           ),
//         ],
//       ),
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.support), label: "Support"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//       ),
//     );
//   }
// }
//
// class HomeContent extends StatelessWidget {
//   final String userName;
//   final String universityName;
//   final String applicationStatus;
//   final Map<String, dynamic>? approvedCard;
//
//   const HomeContent({
//     required this.userName,
//     required this.universityName,
//     required this.applicationStatus,
//     required this.approvedCard,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Welcome, $userName", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           Text(universityName, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
//           SizedBox(height: 20),
//
//           if (applicationStatus == "Approved" && approvedCard != null)
//             Card(
//               color: Colors.green[50],
//               elevation: 3,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               child: ListTile(
//                 leading: Icon(Icons.card_membership, color: Colors.green),
//                 title: Text("Concession Card Approved", style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Text("Student ID: ${approvedCard!['studentId']}\nCollege: ${approvedCard!['college']}"),
//               ),
//             )
//           else if (applicationStatus == "Rejected")
//             Card(
//               color: Colors.red[50],
//               child: ListTile(
//                 leading: Icon(Icons.cancel, color: Colors.red),
//                 title: Text("Application Rejected"),
//               ),
//             )
//           else if (applicationStatus == "Pending")
//               Card(
//                 color: Colors.yellow[100],
//                 child: ListTile(
//                   leading: Icon(Icons.hourglass_bottom, color: Colors.orange),
//                   title: Text("Application Pending"),
//                 ),
//               )
//             else
//               Card(
//                 color: Colors.grey[100],
//                 child: ListTile(
//                   leading: Icon(Icons.info_outline),
//                   title: Text("No application found"),
//                 ),
//               ),
//
//           SizedBox(height: 20),
//           _buildCardSection(
//             context,
//             title: "Apply for Concession Card",
//             subtitle: "Start your application now",
//             icon: Icons.card_membership,
//             onTap: () {
//               Navigator.pushNamed(context, '/applyConcession');
//             },
//           ),
//           _buildCardSection(
//             context,
//             title: "Renew Concession Card",
//             subtitle: "Renew your expired card",
//             icon: Icons.refresh,
//             onTap: () {
//               Navigator.pushNamed(context, '/renewConcession');
//             },
//           ),
//           _buildCardSection(
//             context,
//             title: "Complaint Registration",
//             subtitle: "Report any issues",
//             icon: Icons.report_problem,
//             onTap: () {
//               Navigator.pushNamed(context, '/complaints');
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCardSection(
//       BuildContext context, {
//         required String title,
//         required String subtitle,
//         required IconData icon,
//         required VoidCallback onTap,
//       }) {
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
//
//
//
//
//
//
//



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concessoapp/features/user/view/usernotification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:concessoapp/features/user/view/carddetailspage.dart';
import 'package:concessoapp/features/user/view/support.dart';
import 'package:concessoapp/features/user/view/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String userName = '';
  String universityName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  void _fetchUserDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final userDoc =
      await FirebaseFirestore.instance.collection('student').doc(uid).get();
      final data = userDoc.data();
      if (data != null) {
        setState(() {
          userName = data['name'] ?? '';
          universityName = data['universityName'] ?? '';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
    HomeContent(
      userName: userName,
      universityName: universityName,
    ),
     SupportPage(),
     NotificationsPage(),
     ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences _pref = await SharedPreferences.getInstance();
              _pref.clear();
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (Route route) => false);
              });
            },
            icon: Icon(Icons.logout, color: Colors.black),
          ),
        ],
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: "Support"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final String userName;
  final String universityName;

  const HomeContent({
    required this.userName,
    required this.universityName,
  });

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome, $userName", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(universityName, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('applications')
                .where('userId', isEqualTo: userId)
                .orderBy('submittedAt', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text("No application found"),
                  ),
                );
              }

              final doc = snapshot.data!.docs.first;
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? "Pending";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardDetailsPage(status: status, cardData: data),
                    ),
                  );
                },
                child: Card(
                  color: _getCardColor(status),
                  child: ListTile(
                    leading: Icon(_getCardIcon(status), color: _getIconColor(status)),
                    title: Text("Application $status"),
                    subtitle: status == "Approved"
                        ? Text("Student ID: ${data['studentId'] ?? ''}\nCollege: ${data['college'] ?? ''}")
                        : null,
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildCard(context, "Apply for Concession Card", "Start your application", Icons.card_membership, "/applyConcession"),
          _buildCard(context, "Renew Concession Card", "Renew your expired card", Icons.refresh, "/renewConcession"),
          _buildCard(context, "Complaint Registration", "Report any issues", Icons.report_problem, "/complaints"),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String subtitle, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }

  Color _getCardColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green[50]!;
      case "Rejected":
        return Colors.red[50]!;
      case "Pending":
        return Colors.yellow[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  IconData _getCardIcon(String status) {
    switch (status) {
      case "Approved":
        return Icons.check_circle;
      case "Rejected":
        return Icons.cancel;
      case "Pending":
        return Icons.hourglass_bottom;
      default:
        return Icons.info;
    }
  }

  Color _getIconColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
