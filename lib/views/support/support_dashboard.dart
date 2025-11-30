import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../services/shared_pref_service.dart';
import '../../utils/route_helper.dart';

class SupportDashboard extends StatefulWidget {
  @override
  _SupportDashboardState createState() => _SupportDashboardState();
}

class _SupportDashboardState extends State<SupportDashboard> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() {
    setState(() {
      userName = SharedPrefService.getUserName();
    });
  }

  _logout() async {
    Map<String, dynamic> result = await AuthController.logout();
    if (result['success']) {
      RouteHelper.navigateToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support Dashboard'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $userName!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    'Support Tickets',
                    Icons.support,
                    Colors.green,
                        () {
                      // Navigate to support tickets
                    },
                  ),
                  _buildDashboardCard(
                    'Chat Assistance',
                    Icons.chat,
                    Colors.blue,
                        () {
                      // Navigate to chat
                    },
                  ),
                  _buildDashboardCard(
                    'Knowledge Base',
                    Icons.library_books,
                    Colors.orange,
                        () {
                      // Navigate to knowledge base
                    },
                  ),
                  _buildDashboardCard(
                    'Ticket Analytics',
                    Icons.analytics,
                    Colors.purple,
                        () {
                      // Navigate to analytics
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}