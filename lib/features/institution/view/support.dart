import 'package:flutter/material.dart';

class InstitutionSupport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Support")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Institution Support & Help Center",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // FAQs Section
          Container(
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ExpansionTile(
              title: Text("Frequently Asked Questions"),
              children: [
                _supportTile("How to validate student documents?", "Go to 'Validate Documents' under the dashboard and review uploaded files."),
                _supportTile("How to approve/reject applications?", "Navigate to 'Manage Applications' and use the action buttons for each entry."),
                _supportTile("Can I update an approved application?", "No. You may advise the student to reapply with updated details."),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Tutorials Section
          Container(
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ExpansionTile(
              title: Text("Admin Guide"),
              children: [
                _supportTile("Using the Admin Dashboard", "Step-by-step instructions to manage applications effectively."),
                _supportTile("Validating Uploaded Documents", "Tips on what to check for in student submissions."),
                _supportTile("Issuing Concession Cards", "Guide to approve and trigger concession card generation."),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Contact Technical Support
          Container(
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ExpansionTile(
              title: Text("Contact Technical Support"),
              children: [
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text("Email Us"),
                  subtitle: Text("admin-support@yourapp.com"),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text("Call Us"),
                  subtitle: Text("+1 (800) 987-6543"),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Useful Links
          Container(
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ExpansionTile(
              title: Text("Useful Links"),
            ),
          ),
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
