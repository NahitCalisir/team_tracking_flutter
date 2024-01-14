import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/firebase_options.dart';
import 'package:team_tracking/ui/cubits/create_route_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/map_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/settings_secreen_cubit.dart';
import 'package:team_tracking/ui/cubits/users_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/groups_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/login_screen_cubit.dart';
import 'package:team_tracking/ui/views/bottom_navigation_bar.dart';
import 'package:team_tracking/ui/views/homepage.dart';
import 'package:team_tracking/ui/views/login_screen/login_screen.dart';
import 'package:team_tracking/ui/views/map_screen/map_screen.dart';
import 'utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        BlocProvider(create: (BuildContext context) => SettingsScreenCubit()),
        BlocProvider(
            create: (BuildContext context) => CreateRouteScreenCubit()),
      ],
      child: MaterialApp(
        title: 'Firebase Auth',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: kBackgroundColor,
          textTheme: Theme
              .of(context)
              .textTheme
              .apply(
            bodyColor: kPrimaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        home: FutureBuilder(
          // Kullanıcı oturumu kontrolü
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Yükleniyor durumundayken bir yükleniyor gösterilebilir.
              return CircularProgressIndicator();
            } else {
              // Kullanıcı oturumu kapalıysa LoginScreen'e, aksi takdirde MapScreen'e yönlendirme.
              return (snapshot.data as User?) != null
                  ? BottomNavigationBarPage()
                  : LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
