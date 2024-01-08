import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_tracking/firebase_options.dart';
import 'package:team_tracking/locator.dart';
import 'package:team_tracking/services/provider/auth_provider.dart';
import 'screens/login_screen/login_screen.dart';
import 'utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  setupLocator();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AuthProvider>(create: (context) => locator.get<AuthProvider>(),)
  ], child: const MyApp(),));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: kPrimaryColor,
              fontFamily: 'Montserrat',
            ),
      ),
      home: const LoginScreen(),
    );
  }
}
