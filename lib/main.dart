
import 'package:concessoapp/core/shared/view/splash_page.dart';
import 'package:concessoapp/features/user/view/apply.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:concessoapp/core/shared/view/login_page.dart';

import 'features/admin/view/admin_home.dart';
import 'features/admin/view/announcmnts.dart';
import 'features/admin/view/cardreissuance.dart';
import 'features/admin/view/complntsmngmnt.dart';
import 'features/admin/view/manageapplications.dart';
import 'features/institution/view/institution_home.dart';
import 'features/institution/view/institution_reg.dart';
import 'features/institution/view/verify.dart';
import 'features/user/view/complaint.dart';
import 'features/user/view/home.dart';
import 'features/user/view/register_page.dart';
import 'features/user/view/renew.dart';
import 'firebase_options.dart'; // Import your registration page

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ConcessoApp());
}

class ConcessoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/':(context)=>SplashPage(),
        '/home':(context)=>HomePage(),
        '/userregister':(context)=>UserRegistrationPage(),
        '/loginpage':(context)=>LoginPage(),
        '/institutionreg':(context)=>InstitutionRegistration(),
        '/InstitutionHome':(context)=>InstitutionHome(),
         '/adminhome':(context)=>AdminHomePage(),
        '/applyConcession':(context)=>ApplyConcessionCardPage(),
        '/renewConcession':(context)=>RenewConcessionCardPage(),
        '/complaints':(context)=>ComplaintRegistrationPage(),
        '/complaintsmanagement':(context)=>ComplaintsManagementPage(),
        '/announcements':(context)=>AnnouncementsPage(),
        '/manageApplications':(context)=>ManageApplicationsPage(),
        '/cardReissuance':(context)=>CardReissuancePage(),
        '/verifyApplications': (context) => VerifyStudentApplicationsPage()

      },
      initialRoute: '/',

    );
  }
}

