// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:concessoapp/core/constants/styles.dart';
// import 'package:concessoapp/core/utils/app_text.dart';
//
// class UserRegistrationPage extends StatefulWidget {
//   const UserRegistrationPage({super.key});
//
//   @override
//   State<UserRegistrationPage> createState() => _UserRegistrationPageState();
// }
//
// class _UserRegistrationPageState extends State<UserRegistrationPage> {
//   final _registerKey = GlobalKey<FormState>();
//
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passController = TextEditingController();
//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _phoneController = TextEditingController();
//   TextEditingController _universityController = TextEditingController();
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
//                 data: "User Registartion",
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
//                 controller: _nameController,
//                 decoration: InputDecoration(hintText: "Name"),
//               ),
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(hintText: "Phone"),
//               ),
//               TextFormField(
//                 controller: _universityController,
//                 decoration: InputDecoration(hintText: "University Name"),
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
//                           'role': "user"
//                         });
//
//                         FirebaseFirestore.instance
//                             .collection('users')
//                             .doc(userCredential.user!.uid)
//                             .set({
//                           "uid": userCredential.user!.uid,
//                           'name': _nameController.text,
//                           'email': userCredential.user!.email,
//                           'phone': _phoneController.text,
//                           'universityName': _universityController.text,
//                           'createdAt': DateTime.now(),
//                           'status': 1,
//                           'role': "user"
//                         }).then((value) {
//                           Navigator.pushNamedAndRemoveUntil(
//                               context, '/home', (Route route) => false);
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
// // TODO Implement this library.


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/styles.dart';
import '../../../core/utils/app_text.dart';

class UserRegistrationPage extends StatefulWidget {
  const UserRegistrationPage({super.key});

  @override
  State<UserRegistrationPage> createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final _registerKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _universityController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('User Registration')),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(20),
          child: Form(
            key: _registerKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppText(
                  data: "User Registration",
                  mystyle: MyStyle.loginHeading,
                ),
                SizedBox(height: 20),

                // Email Input
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) return "Enter email";
                    return null;
                  },
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 10),

                // Name Input
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) return "Enter Name";
                    if (value.length < 4) return "Name should be at least 4 characters";
                    return null;
                  },
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Name",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 10),

                // Phone Input
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: "Phone",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 10),

                // University Input
                TextFormField(
                  controller: _universityController,
                  decoration: InputDecoration(
                    hintText: "University Name",
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
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Register Button
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () async {
                    if (_registerKey.currentState!.validate()) {
                      setState(() => _isLoading = true);

                      try {
                        UserCredential userCredential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passController.text);

                        if (userCredential.user != null) {
                          FirebaseFirestore.instance.collection('login')
                              .doc(userCredential.user!.uid)
                              .set({
                            "uid": userCredential.user!.uid,
                            'email': userCredential.user!.email,
                            'createdAt': DateTime.now(),
                            'status': 1,
                            'role': "student"
                          });

                          FirebaseFirestore.instance.collection('student')
                              .doc(userCredential.user!.uid)
                              .set({
                            "uid": userCredential.user!.uid,
                            'name': _nameController.text,
                            'email': userCredential.user!.email,
                            'phone': _phoneController.text,
                            'universityName': _universityController.text,
                            'createdAt': DateTime.now(),
                            'status': 1,
                            'role': "student"
                          }).then((value) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/home', (Route route) => false);
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
                  child: Text("Student Register"),
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


