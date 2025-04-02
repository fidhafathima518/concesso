import 'package:flutter/material.dart';

class ComplaintRegistrationPage extends StatefulWidget {
  @override
  _ComplaintRegistrationPageState createState() => _ComplaintRegistrationPageState();
}

class _ComplaintRegistrationPageState extends State<ComplaintRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _complaintController = TextEditingController();

  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      // Submit complaint logic
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Complaint Submitted Successfully!"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complaint Registration")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Full Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your full name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _complaintController,
                  decoration: InputDecoration(labelText: "Complaint Details"),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your complaint details";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitComplaint,
                  child: Text("Submit Complaint"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
