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
import '../../../core/constants/styles.dart';
import '../../../core/utils/app_text.dart';

class InstitutionRegistration extends StatefulWidget {
  const InstitutionRegistration({super.key});

  @override
  State<InstitutionRegistration> createState() => _InstitutionRegistrationState();
}

class _InstitutionRegistrationState extends State<InstitutionRegistration> {
  final _registerKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  TextEditingController _institutionNameController = TextEditingController();
  TextEditingController _institutionIdController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Institution Registration')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _registerKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(
                data: "Institution Registration",
                mystyle: MyStyle.loginHeading,
              ),
              SizedBox(height: 20),

              // Email Input
              TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value!.isEmpty) return "Enter email";
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 10),

              // Institution Name Input
              TextFormField(
                controller: _institutionNameController,
                validator: (value) {
                  if (value!.isEmpty) return "Enter Institution Name";
                  if (value.length < 4) return "Name should be at least 4 characters";
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Institution Name",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 10),

              // Institution ID Input
              TextFormField(
                controller: _institutionIdController,
                decoration: InputDecoration(
                  hintText: "Institution ID",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 10),

              // Password Input with Visibility Toggle
              TextFormField(
                controller: _passController,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value!.isEmpty) return "Enter password";
                  if (value.length < 6) return "Password should be at least 6 characters";
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Register Button with Gradient Styling
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () async {
                  if (_registerKey.currentState!.validate()) {
                    setState(() => _isLoading = true);

                    try {
                      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: _emailController.text, password: _passController.text);

                      if (userCredential.user != null) {
                        // Save login details
                        FirebaseFirestore.instance.collection('login').doc(userCredential.user!.uid).set({
                          "uid": userCredential.user!.uid,
                          'email': userCredential.user!.email,
                          'createdAt': DateTime.now(),
                          'status': 1,
                          'role': "institution"
                        });

                        // Save institution details
                        FirebaseFirestore.instance.collection('institution').doc(userCredential.user!.uid).set({
                          "uid": userCredential.user!.uid,
                          'name': _institutionNameController.text,
                          'email': userCredential.user!.email,
                          'institutionID': _institutionIdController.text,
                          'createdAt': DateTime.now(),
                          'status': 1,
                          'role': "institution"
                        }).then((value) {
                          Navigator.pushNamedAndRemoveUntil(context, '/InstitutionHome', (Route route) => false);
                        });
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
                      );
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  }
                },
                child: Text("Register"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




