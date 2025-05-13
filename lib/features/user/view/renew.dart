// import 'package:flutter/material.dart';
// import 'dart:io';
//
// import '../shared/imagepicker.dart';
//
//
// class RenewConcessionCardPage extends StatefulWidget {
//   @override
//   _RenewConcessionCardPageState createState() => _RenewConcessionCardPageState();
// }
//
// class _RenewConcessionCardPageState extends State<RenewConcessionCardPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   final _nameController = TextEditingController();
//   final _collegeController = TextEditingController();
//   final _studentIdController = TextEditingController();
//   final _yearOfStudyController = TextEditingController();
//   final _addressController = TextEditingController();
//
//   final ImageService _imageService = ImageService();
//   File? _photo;
//   File? _oldCard;
//   bool _isSubmitting = false;
//
//   Future<void> _pickImage(bool isPhoto) async {
//     final image = await _imageService.showImagePickerDialog(context);
//     if (image != null) {
//       setState(() {
//         if (isPhoto) {
//           _photo = image;
//         } else {
//           _oldCard = image;
//         }
//       });
//     }
//   }
//
//   void _submitRenewal() {
//     if (_formKey.currentState!.validate() && _photo != null && _oldCard != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Renewal Application Submitted Successfully!")),
//       );
//       // TODO: Upload to Firestore/Storage if needed
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill all fields and upload required documents")),
//       );
//     }
//   }
//
//   Widget _imagePickerBox({required File? image, required VoidCallback onTap, required String label}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 160,
//         width: double.infinity,
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: image != null
//             ? Image.file(image, fit: BoxFit.cover)
//             : Center(child: Text("Tap to upload $label")),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Renew Concession Card")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(labelText: "Full Name"),
//                   validator: (value) => value == null || value.isEmpty ? "Please enter your full name" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _collegeController,
//                   decoration: const InputDecoration(labelText: "College Name"),
//                   validator: (value) => value == null || value.isEmpty ? "Please enter your college name" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _studentIdController,
//                   decoration: const InputDecoration(labelText: "Student Registration Number"),
//                   validator: (value) => value == null || value.isEmpty ? "Please enter registration number" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _yearOfStudyController,
//                   decoration: const InputDecoration(labelText: "Year of Study"),
//                   validator: (value) => value == null || value.isEmpty ? "Please enter year of study" : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _addressController,
//                   decoration: const InputDecoration(labelText: "Address"),
//                   validator: (value) => value == null || value.isEmpty ? "Please enter address" : null,
//                 ),
//                 const SizedBox(height: 20),
//                 const Text("Upload Recent Photo:"),
//                 _imagePickerBox(
//                   image: _photo,
//                   onTap: () => _pickImage(true),
//                   label: "your photo",
//                 ),
//                 const Text("Upload Old Concession Card:"),
//                 _imagePickerBox(
//                   image: _oldCard,
//                   onTap: () => _pickImage(false),
//                   label: "your old card",
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _isSubmitting ? null : _submitRenewal,
//                   child: _isSubmitting
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text("Submit Renewal"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/imagepicker.dart';

class RenewConcessionCardPage extends StatefulWidget {
  @override
  State<RenewConcessionCardPage> createState() => _RenewConcessionCardPageState();
}

class _RenewConcessionCardPageState extends State<RenewConcessionCardPage> {
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _yearOfStudyController = TextEditingController();
  final _addressController = TextEditingController();

  final ImageService _imageService = ImageService();
  File? _photo;
  File? _oldCard;
  bool _isUploading = false;

  Future<void> _pickPhoto() async {
    final image = await _imageService.showImagePickerDialog(context);
    if (image != null) {
      setState(() => _photo = image);
    }
  }

  Future<void> _pickOldCard() async {
    final image = await _imageService.showImagePickerDialog(context);
    if (image != null) {
      setState(() => _oldCard = image);
    }
  }

  Future<void> _submitRenewal() async {
    if (_nameController.text.isEmpty ||
        _collegeController.text.isEmpty ||
        _studentIdController.text.isEmpty ||
        _yearOfStudyController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _photo == null ||
        _oldCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload both images')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final photoUrl = await _imageService.uploadImageWorking(_photo!, "renewal_photos");
      final oldCardUrl = await _imageService.uploadImageWorking(_oldCard!, "old_concession_cards");

      await FirebaseFirestore.instance.collection('card_reissuance').add({
        'userId': user.uid,
        'name': _nameController.text.trim(),
        'college': _collegeController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        'yearOfStudy': _yearOfStudyController.text.trim(),
        'address': _addressController.text.trim(),
        'photoUrl': photoUrl,
        'oldCardUrl': oldCardUrl,
        'status': 'Pending',
        'timestamp': Timestamp.now(),
        'reason': 'Renewal request',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Renewal Request Submitted Successfully')),
      );

      _nameController.clear();
      _collegeController.clear();
      _studentIdController.clear();
      _yearOfStudyController.clear();
      _addressController.clear();
      setState(() {
        _photo = null;
        _oldCard = null;
        _isUploading = false;
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${e.toString()}')),
      );
      setState(() => _isUploading = false);
    }
  }

  Widget _imagePickerBox({
    required File? image,
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: image != null
            ? Image.file(image, fit: BoxFit.cover)
            : Center(child: Text("Tap to upload $label")),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Renew Concession Card")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _collegeController,
              decoration: const InputDecoration(labelText: 'College Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(labelText: 'Student Registration Number'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _yearOfStudyController,
              decoration: const InputDecoration(labelText: 'Year of Study'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _imagePickerBox(image: _photo, onTap: _pickPhoto, label: "your recent photo"),
            _imagePickerBox(image: _oldCard, onTap: _pickOldCard, label: "your old concession card"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _submitRenewal,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Renewal"),
            ),
          ],
        ),
      ),
    );
  }
}
