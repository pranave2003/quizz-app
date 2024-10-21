import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'ViewModel/admin/QuestionProvider.dart';
import 'View/admin/admin_page.dart';

import 'View/students/gauthgate.dart';
import 'ViewModel/user/Auth.dart';

import 'package:firebase_core/firebase_core.dart';

import 'View/students/quiz/quiz_page.dart';
import 'ViewModel/user/userdetails.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [

        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider<QuestionProvider>(
          create: (context) => QuestionProvider(),
        ), ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),

        // Add more providers here if needed
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      splitScreenMode: true,
      minTextAdapt: true,
      designSize: Size(411, 891),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quiz App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Gauth(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => AdminPage()));
              },
              child: Text('Admin Module'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => UserQuizPage()));
              },
              child: Text('User Module'),
            ),
          ],
        ),
      ),
    );
  }
}
