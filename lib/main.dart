import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/firebase_options.dart';
import 'package:team_tracking/ui/cubits/map_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/users_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/groups_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/login_screen_cubit.dart';
import 'package:team_tracking/ui/views/login_screen/login_screen.dart';
import 'package:team_tracking/ui/views/map_screen/map_screen.dart';
import 'utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => AccountsScreenCubit()),
        BlocProvider(create: (BuildContext context) => LoginScreenCubit()),
        BlocProvider(create: (BuildContext context) => GroupsScreenCubit()),
        BlocProvider(create: (BuildContext context) => MapScreenCubit()),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
