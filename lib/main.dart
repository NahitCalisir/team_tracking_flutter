import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/data/repo/team_tracking_dao_repository.dart';
import 'package:team_tracking/firebase_options.dart';
import 'package:team_tracking/ui/cubits/create_group_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/create_route_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/edit_group_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/group_members_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/homepage_cubit.dart';
import 'package:team_tracking/ui/cubits/map_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/settings_secreen_cubit.dart';
import 'package:team_tracking/ui/cubits/users_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/groups_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/login_screen_cubit.dart';
import 'package:team_tracking/ui/views/bottom_navigation_bar.dart';
import 'package:team_tracking/ui/views/login_screen/login_screen.dart';
import 'data/entity/users.dart';
import 'utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider("6Lf9IVgpAAAAALPwk2dx8kuZknThQ3H0d-bL8sHP"),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => HomepageCubit()),
        BlocProvider(create: (BuildContext context) => AccountsScreenCubit()),
        BlocProvider(create: (BuildContext context) => LoginScreenCubit()),
        BlocProvider(create: (BuildContext context) => GroupsScreenCubit()),
        BlocProvider(create: (BuildContext context) => MapScreenCubit()),
        BlocProvider(create: (BuildContext context) => SettingsScreenCubit()),
        BlocProvider(create: (BuildContext context) => CreateRouteScreenCubit()),
        BlocProvider(create: (BuildContext context) => CreateGroupScreenCubit()),
        BlocProvider(create: (BuildContext context) => EditGroupScreenCubit()),
        BlocProvider(create: (BuildContext context) => GroupMembersScreenCubit()),
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
            bodyColor: kPrimaryColor2,
            fontFamily: 'Montserrat',
          ),
        ),
        home: FutureBuilder(
          // Kullanıcı oturumu kontrolü
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)  {
              // Yükleniyor durumundayken bir yükleniyor gösterilebilir.
              return const CircularProgressIndicator();
            } else {
              if(snapshot.data != null)  {
                checkAndSetUserLogin();
                return const BottomNavigationBarPage();
              } else {
                return const LoginScreen();
              }
            }
          },
        ),
      ),
    );
  }
}
Future<User?> checkAndSetUserLogin() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    Map<String, dynamic>? userData = await TeamTrackingDaoRepository.shared.getUserData();
    if (userData != null) {
      Users currentUser = Users.fromMap(user.uid, userData);
      await UsersManager().setUser(currentUser);
      await TeamTrackingDaoRepository.shared.updateUserLocation(userId: currentUser.id);
      print("Current User: ${currentUser.name}");
    }
  }
  return user;
}