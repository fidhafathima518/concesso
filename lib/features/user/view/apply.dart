import 'package:flutter/material.dart';

class ApplyConcessionCardPage extends StatefulWidget {
  @override
  _ApplyConcessionCardPageState createState() => _ApplyConcessionCardPageState();
}

class _ApplyConcessionCardPageState extends State<ApplyConcessionCardPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _collegeController = TextEditingController();
  TextEditingController _studentIdController = TextEditingController();
  TextEditingController _yearOfStudyController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  void _submitApplication() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Application Submitted Successfully!"))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all fields"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Apply for Concession Card")),
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
                  controller: _collegeController,
                  decoration: InputDecoration(labelText: "College Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your college name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _studentIdController,
                  decoration: InputDecoration(labelText: "Student Registration Number"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter student registration number";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _yearOfStudyController,
                  decoration: InputDecoration(labelText: "Year of Study"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your year of study";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: "Address"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your address";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitApplication,
                  child: Text("Submit Application"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
