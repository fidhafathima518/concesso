// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:concessoapp/core/constants/styles.dart';
// import 'package:concessoapp/core/utils/app_text.dart';
//
// class InstitutionRegistration extends StatefulWidget {
//   const InstitutionRegistration({super.key});
//
//   @override
//   State<InstitutionRegistration> createState() => _InstitutionRegistrationState();
// }
//
// class _InstitutionRegistrationState extends State<InstitutionRegistration> {
//   final _registerKey = GlobalKey<FormState>();
//
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passController = TextEditingController();
//   TextEditingController _institutionnameController = TextEditingController();
//   TextEditingController _institutionidController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Container(
//         height: double.infinity,
//         width: double.infinity,
//         padding: EdgeInsets.all(20),
//         child: Form(
//           key: _registerKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             spacing: 20,
//             children: [
//               AppText(
//                 data: "Institution Registartion",
//                 mystyle: MyStyle.loginHeading,
//               ),
//               TextFormField(
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return "Enter email";
//                   }
//                 },
//                 controller: _emailController,
//                 decoration: InputDecoration(hintText: "Email"),
//               ),
//               TextFormField(
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return "Enter Name";
//                   } else if (value.length < 4) {
//                     return "Name should be min of 4 charcters";
//                   }
//                 },
//                 controller: _institutionnameController,
//                 decoration: InputDecoration(hintText: "Institution Name"),
//               ),
//               TextFormField(
//                 controller: _institutionidController,
//                 decoration: InputDecoration(hintText: "id"),
//               ),
//               TextFormField(
//                 controller: _passController,
//                 decoration: InputDecoration(hintText: "Password"),
//               ),
//               ElevatedButton(
//                   onPressed: () async {
//                     if (_registerKey.currentState!.validate()) {
//                       UserCredential userCredential = await FirebaseAuth
//                           .instance
//                           .createUserWithEmailAndPassword(
//                           email: _emailController.text,
//                           password: _passController.text);
//                       if (userCredential.user!.uid != null) {
//                         FirebaseFirestore.instance
//                             .collection('login')
//                             .doc(userCredential.user!.uid)
//                             .set({
//                           "uid": userCredential.user!.uid,
//                           'email': userCredential.user!.email,
//                           'createdAt': DateTime.now(),
//                           'status': 1,
//                           'role': "login"
//                         });
//
//                         FirebaseFirestore.instance
//                             .collection('institution')
//                             .doc(userCredential.user!.uid)
//                             .set({
//                           "uid": userCredential.user!.uid,
//                           'name': _institutionnameController.text,
//                           'email': userCredential.user!.email,
//                           'phone': _institutionidController.text,
//                           'createdAt': DateTime.now(),
//                           'status': 1,
//                           'role': "institution"
//                         }).then((value) {
//                           Navigator.pushNamedAndRemoveUntil(
//                               context, '/InstitutionHome', (Route route) => false);
//                         });
//                       }
//                     }
//                   },
//                   child: Text("Register"))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/styles.dart';
import '../../../core/utils/app_text.dart';

class InstitutionRegistration extends StatefulWidget {
  const InstitutionRegistration({super.key});

  @override
  State<InstitutionRegistration> createState() => _InstitutionRegistrationState();
}

class _InstitutionRegistrationState extends State<InstitutionRegistration> {
  final _registerKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _institutionNameController = TextEditingController();
  final TextEditingController _institutionIdController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  void _registerInstitution() async {
    if (_registerKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Register user
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );

        final uid = userCredential.user!.uid;
        final email = _emailController.text.trim();
        final name = _institutionNameController.text.trim();
        final institutionID = _institutionIdController.text.trim();

        // Save login data
        await FirebaseFirestore.instance.collection('login').doc(uid).set({
          'uid': uid,
          'email': email,
          'createdAt': DateTime.now(),
          'status': 1,
          'role': "institution",
        });

        // Save institution data
        await FirebaseFirestore.instance.collection('institution').doc(uid).set({
          'uid': uid,
          'email': email,
          'name': name,
          'institutionID': institutionID,
          'createdAt': DateTime.now(),
          'status': 1,
          'role': "institution",
        });

        // Save data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', 'institution');
        await prefs.setString('institutionName', name);

        // Navigate to home
        Navigator.pushNamedAndRemoveUntil(context, '/InstitutionHome', (route) => false);
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred';
        if (e.code == 'email-already-in-use') {
          message = 'Email already in use';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email';
        } else if (e.code == 'weak-password') {
          message = 'Password too weak';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Institution Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _registerKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(
                data: "Institution Registration",
                mystyle: MyStyle.loginHeading,
              ),
              const SizedBox(height: 20),

              // Email
              TextFormField(
                controller: _emailController,
                validator: (value) =>
                (value == null || value.isEmpty) ? "Enter email" : null,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),

              // Institution Name
              TextFormField(
                controller: _institutionNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter institution name";
                  if (value.length < 4) return "Name must be at least 4 characters";
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: "Institution Name",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),

              // Institution ID (optional)
              TextFormField(
                controller: _institutionIdController,
                decoration: const InputDecoration(
                  hintText: "Institution ID (optional)",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),

              // Password
              TextFormField(
                controller: _passController,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter password";
                  if (value.length < 6) return "Password must be at least 6 characters";
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Password",
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registerInstitution,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
