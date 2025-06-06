import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
import 'package:concessoapp/core/constants/colors.dart';
import 'package:concessoapp/core/constants/styles.dart';
import 'package:concessoapp/core/utils/app_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/user/view/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();

  final _loginKey = GlobalKey<FormState>();
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Form(
          key: _loginKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              AppText(
                data: "Welcome Back",
                mystyle: MyStyle.titleStyle,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter  email";
                  } else {
                    return null;
                  }
                },
                controller: _emailcontroller,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.red)),
                  hintText: "Enter Email",
                ),
              ),
              TextFormField(
                cursorColor: Colors.teal,
                cursorErrorColor: Colors.red,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter a Password";
                  } else {
                    return null;
                  }
                },
                obscureText: _visible,
                obscuringCharacter: "*",
                controller: passcontroller,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _visible = !_visible;
                      });
                    },
                    icon: _visible == false
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.red)),
                  hintText: "Enter YourPassword",
                ),
              ),
              Material(
                color: Colors.transparent, // To keep only the gradient visible
                child: InkWell(
                  onTap: () async {
                    if (_loginKey.currentState!.validate() == true) {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                              email: _emailcontroller.text,
                              password: passcontroller.text);
                      if (userCredential.user!.uid != null) {
                        // Navigator.pushNamedAndRemoveUntil(context,
                        //     '/home', (Route route) => false);
                        String? token = await userCredential.user!.getIdToken();

                        SharedPreferences _pref =
                            await SharedPreferences.getInstance();
                             _pref.setString('token', token!);  // Ensure token is stored before navigating



                        DocumentSnapshot rolesnap = await FirebaseFirestore
                            .instance
                            .collection('login')
                            .doc(userCredential.user!.uid)
                            .get();

                        if (rolesnap['role'] == 'student') {
                          DocumentSnapshot snap = await FirebaseFirestore
                              .instance
                              .collection('student')
                              .doc(userCredential.user!.uid)
                              .get();

                          _pref.setString('name', snap['name']!);
                          _pref.setString('uid', snap['uid']!);
                          _pref.setString('email', snap['email']!);
                          _pref.setString('phone', snap['phone']!);
                          _pref.setString('role', rolesnap['role']!);
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/home', (Route route) => false);
                        } else if (rolesnap['role'] == 'admin') {
                          DocumentSnapshot adminSnap = await FirebaseFirestore
                              .instance
                              .collection('login')
                              .doc(userCredential.user!.uid)
                              .get();

                          _pref.setString('uid', adminSnap['uid']!);
                          _pref.setString('email', adminSnap['email']!);
                          _pref.setString('role', rolesnap['role']!);

                          Navigator.pushNamedAndRemoveUntil(
                              context, '/adminhome', (Route route) => false);
                        } else {
                          DocumentSnapshot snap = await FirebaseFirestore
                              .instance
                              .collection('institution')
                              .doc(userCredential.user!.uid)
                              .get();

                          _pref.setString('name', snap['name']!);
                          _pref.setString('uid', snap['uid']!);
                          _pref.setString('email', snap['email']!);
                          _pref.setString('role', rolesnap['role']!);

                          Navigator.pushNamedAndRemoveUntil(context,
                              '/InstitutionHome', (Route route) => false);
                        }
                      }
                    }
                  },

                  borderRadius: BorderRadius.circular(
                      10), // Match the container's border radius
                  splashColor: Colors.yellow, // Ripple effect color
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal, Colors.black],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 45,
                    width: 250,
                    child: Center(
                      child: Text(
                        "Login",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  AppText(
                    data: "Don't have an account?",
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/userregister');
                      },
                      child: AppText(
                        data: "Register",
                      ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  AppText(
                    data: "Don't have an account?",
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/institutionreg');
                      },
                      child: AppText(
                        data: "Institution Register",
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
