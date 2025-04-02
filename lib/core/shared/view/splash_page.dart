


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override

    void initState(){
    Future.delayed(Duration(seconds: 4), () {
      checkLoginStatus();
    });
  }

  checkLoginStatus() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String? token = _pref.getString('token');
    String? role = _pref.getString('role');

    if (token != null) {
      if (role == 'user') {
        Navigator.pushNamed(context, '/home');
      }
else if(role=='institution'){
        Navigator.pushNamed(context, '/institutionHome');
      }
      else if(role=='admin'){
        Navigator.pushNamed(context, '/adminhome');
      }

    } else
    {
      Navigator.pushNamed(context, '/loginpage');
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [


              // AppText(data: "Logo",mystyle: MyStyle.loginHeading,),
              Image.asset('assets/image/logo.png', height: 100,)

            ],
          )
      ),


    );
  }
}


