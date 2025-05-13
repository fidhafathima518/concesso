import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Support & Help Center"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            "How can we help you?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // FAQs Section
          Container(
            color: Colors.lightBlue[50],
            child: ExpansionTile(
              title: Text("Frequently Asked Questions"),
              children: [
                _supportTile("How do I apply for a concession card?", "Go to the Apply section and fill in the form with required details and documents."),
                _supportTile("What documents are required?", "A valid student ID and proof of enrollment are required."),
                _supportTile("How long does approval take?", "Applications are usually reviewed within 3-5 business days."),
                _supportTile("What if my application is rejected?", "You can contact support or reapply with corrected details."),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Contact Support Section
          Container(
            color: Colors.lightBlue[50],
            child: ExpansionTile(
              title: Text("Contact Support"),
              children: [
                ListTile(
                  tileColor: Colors.lightBlue[50],
                  leading: Icon(Icons.email),
                  title: Text("Email Us"),
                  subtitle: Text("support@yourapp.com"),
                ),
                ListTile(
                  tileColor: Colors.lightBlue[50],
                  leading: Icon(Icons.phone),
                  title: Text("Call Us"),
                  subtitle: Text("+1 (800) 123-4567"),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Tutorials or Guide
          Container(
            color: Colors.lightBlue[50],
            child: ExpansionTile(
              title: Text("Student Guide"),
              children: [
                _supportTile("How to fill the application form", "Step-by-step instructions with screenshots (Coming Soon)"),
                _supportTile("How to upload documents", "Make sure your files are clear and in accepted formats."),
                _supportTile("Checking application status", "Go to the Home page to see the latest status."),
              ],
            ),
          ),

          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _supportTile(String title, String subtitle) {
    return ListTile(
      tileColor: Colors.lightBlue[50],
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
