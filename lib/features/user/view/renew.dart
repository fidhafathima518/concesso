import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RenewConcessionCardPage extends StatefulWidget {
  @override
  _RenewConcessionCardPageState createState() => _RenewConcessionCardPageState();
}

class _RenewConcessionCardPageState extends State<RenewConcessionCardPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _collegeController = TextEditingController();
  TextEditingController _studentIdController = TextEditingController();
  TextEditingController _yearOfStudyController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  File? _photo;
  File? _oldCard;

  // Future<void> _pickImage(ImageSource source, bool isPhoto) async {
  //   final pickedFile = await ImagePicker().pickImage(source: source);
  //   if (pickedFile != null) {
  //     setState(() {
  //       if (isPhoto) {
  //         _photo = File(pickedFile.path);
  //       } else {
  //         _oldCard = File(pickedFile.path);
  //       }
  //     });
  //   }
  // }

  void _submitRenewal() {
    if (_formKey.currentState!.validate() && _photo != null && _oldCard != null) {
      // Submit renewal logic
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Renewal Application Submitted Successfully!"))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all fields and upload required documents"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Renew Concession Card")),
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
                Text("Upload Recent Photo:"),
                _photo == null
                    ? Text("No image selected")
                    : Image.file(_photo!, height: 100),
                // ElevatedButton(
                //   onPressed: () => _pickImage(ImageSource.gallery, true),
                //   child: Text("Select Photo"),
                // ),
                SizedBox(height: 20),
                Text("Upload Old Concession Card:"),
                _oldCard == null
                    ? Text("No image selected")
                    : Image.file(_oldCard!, height: 100),
                // ElevatedButton(
                //   onPressed: () => _pickImage(ImageSource.gallery, false),
                //   child: Text("Select Old Card"),
                // ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitRenewal,
                  child: Text("Submit Renewal"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
