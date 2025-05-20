import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// 로그인 및 회원가입
import 'home_page.dart';
import 'login_page.dart';
import 'singup_page.dart';

// 기능 페이지
import 'ar_preview_screen.dart';
import 'record_detail_1.dart';
import 'record_detail_2.dart';
import 'record_detail_3.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'I See You',
      theme: ThemeData(fontFamily: 'Pretendard'),
      initialRoute: '/',
      routes: {
        // 로그인 및 회원가입
        '/': (context) => const LoginPage(),
        '/home': (context) => const ProjectHomePage(),
        '/signup': (context) => const SignUpPage(title: '회원가입'),

        // 기능 페이지
        '/ar': (context) => const ARPreviewScreen(),
        '/record1': (context) => const RecordDetail1(),
        '/record2': (context) => const RecordDetail2(),
        '/record3': (context) => const RecordDetail3(),
      },
    );
  }
}
