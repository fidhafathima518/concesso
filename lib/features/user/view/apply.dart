// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../shared/imagepicker.dart';
//
//
// class ApplyConcessionCardPage extends StatefulWidget {
//   const ApplyConcessionCardPage({Key? key}) : super(key: key);
//
//   @override
//   State<ApplyConcessionCardPage> createState() => _ApplyConcessionCardPageState();
// }
//
// class _ApplyConcessionCardPageState extends State<ApplyConcessionCardPage> {
//   final _nameController = TextEditingController();
//   final _collegeController = TextEditingController();
//   final _studentIdController = TextEditingController();
//   final _yearController = TextEditingController();
//   final _addressController = TextEditingController();
//
//   final ImageService _imageService = ImageService();
//   File? _photo;
//   File? _idCard;
//   bool _isUploading = false;
//
//   Future<void> _pickPhoto() async {
//     final image = await _imageService.showImagePickerDialog(context);
//     if (image != null) {
//       setState(() => _photo = image);
//     }
//   }
//
//   Future<void> _pickIdCard() async {
//     final image = await _imageService.showImagePickerDialog(context);
//     if (image != null) {
//       setState(() => _idCard = image);
//     }
//   }
//
//   Future<void> _submitApplication() async {
//     if (_nameController.text.isEmpty ||
//         _collegeController.text.isEmpty ||
//         _studentIdController.text.isEmpty ||
//         _yearController.text.isEmpty ||
//         _addressController.text.isEmpty ||
//         _photo == null ||
//         _idCard == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields and select both images')),
//       );
//       return;
//     }
//
//     setState(() => _isUploading = true);
//
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) throw Exception("User not logged in");
//
//       final photoUrl = await _imageService.uploadImageWorking(_photo!, "concession_photos");
//       final idCardUrl = await _imageService.uploadImageWorking(_idCard!, "concession_id_cards");
//
//       await FirebaseFirestore.instance.collection('applications').add({
//         'userId': user.uid,
//         'name': _nameController.text.trim(),
//         'college': _collegeController.text.trim(),
//         'studentId': _studentIdController.text.trim(),
//         'yearOfStudy': _yearController.text.trim(),
//         'address': _addressController.text.trim(),
//         'photoUrl': photoUrl,
//         'idCardUrl': idCardUrl,
//         'status': 'Pending',
//         'submittedAt': Timestamp.now(),
//         'verifiedByInstitution': false,
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Application Submitted Successfully')),
//       );
//
//       _nameController.clear();
//       _collegeController.clear();
//       _studentIdController.clear();
//       _yearController.clear();
//       _addressController.clear();
//       setState(() {
//         _photo = null;
//         _idCard = null;
//         _isUploading = false;
//       });
//
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Submission failed: ${e.toString()}')),
//       );
//       setState(() => _isUploading = false);
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
//       appBar: AppBar(title: const Text("Apply for Concession Card")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: 'Full Name'),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _collegeController,
//               decoration: const InputDecoration(labelText: 'College Name'),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _studentIdController,
//               decoration: const InputDecoration(labelText: 'Student Registration Number'),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _yearController,
//               decoration: const InputDecoration(labelText: 'Year of Study'),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _addressController,
//               decoration: const InputDecoration(labelText: 'Address'),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 20),
//             _imagePickerBox(image: _photo, onTap: _pickPhoto, label: "your photo"),
//             _imagePickerBox(image: _idCard, onTap: _pickIdCard, label: "your ID card"),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isUploading ? null : _submitApplication,
//               child: _isUploading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Submit Application"),
//             ),
//           ],
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



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/imagepicker.dart';

class ApplyConcessionCardPage extends StatefulWidget {
  const ApplyConcessionCardPage({Key? key}) : super(key: key);

  @override
  State<ApplyConcessionCardPage> createState() => _ApplyConcessionCardPageState();
}

class _ApplyConcessionCardPageState extends State<ApplyConcessionCardPage> {
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _yearController = TextEditingController();
  final _addressController = TextEditingController();

  final ImageService _imageService = ImageService();
  File? _photo;
  File? _idCard;
  bool _isUploading = false;

  Future<void> _pickPhoto() async {
    final image = await _imageService.showImagePickerDialog(context);
    if (image != null) {
      setState(() => _photo = image);
    }
  }

  Future<void> _pickIdCard() async {
    final image = await _imageService.showImagePickerDialog(context);
    if (image != null) {
      setState(() => _idCard = image);
    }
  }

  Future<void> _submitApplication() async {
    if (_nameController.text.isEmpty ||
        _collegeController.text.isEmpty ||
        _studentIdController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _photo == null ||
        _idCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select both images')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final photoUrl = await _imageService.uploadImageWorking(_photo!, "concession_photos");
      final idCardUrl = await _imageService.uploadImageWorking(_idCard!, "concession_id_cards");

      // Store application details in 'applications' collection
      await FirebaseFirestore.instance.collection('applications').add({
        'userId': user.uid,
        'name': _nameController.text.trim(),
        'college': _collegeController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        'yearOfStudy': _yearController.text.trim(),
        'address': _addressController.text.trim(),
        'photoUrl': photoUrl,
        'idCardUrl': idCardUrl,
        'status': 'Pending',
        'submittedAt': Timestamp.now(),
        'verifiedByInstitution': false,
      });

      // Store document separately in 'student_documents' collection
      await FirebaseFirestore.instance.collection('student_documents').add({
        'userId': user.uid,
        'fullName': _nameController.text.trim(),
        'registrationNumber': _studentIdController.text.trim(),
        'documentType': 'ID Card',
        'documentUrl': idCardUrl,
        'photoUrl': photoUrl,
        'status': 'Pending',
        'submittedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application Submitted Successfully')),
      );

      _nameController.clear();
      _collegeController.clear();
      _studentIdController.clear();
      _yearController.clear();
      _addressController.clear();
      setState(() {
        _photo = null;
        _idCard = null;
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
      appBar: AppBar(title: const Text("Apply for Concession Card")),
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
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Year of Study'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _imagePickerBox(image: _photo, onTap: _pickPhoto, label: "your photo"),
            _imagePickerBox(image: _idCard, onTap: _pickIdCard, label: "your ID card"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _submitApplication,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Application"),
            ),
          ],
        ),
      ),
    );
  }
}
