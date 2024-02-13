import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/data/repo/user_dao_repository.dart';
import 'package:team_tracking/firebase_options.dart';
import 'package:team_tracking/ui/cubits/activities_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/activity_members_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/create_activity_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/create_group_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/create_route_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/edit_activity_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/edit_group_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/group_members_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/homepage_cubit.dart';
import 'package:team_tracking/ui/cubits/map_screen_for_activity_cubit.dart';
import 'package:team_tracking/ui/cubits/map_screen_for_group_cubit.dart';
import 'package:team_tracking/ui/cubits/settings_secreen_cubit.dart';
import 'package:team_tracking/ui/cubits/users_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/groups_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/login_screen_cubit.dart';
import 'package:team_tracking/ui/views/homepage/homepage.dart';
import 'package:team_tracking/ui/views/login_screen/login_screen.dart';
import 'data/entity/users.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
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
        BlocProvider(create: (BuildContext context) => UsersScreenCubit()),
        BlocProvider(create: (BuildContext context) => LoginScreenCubit()),
        BlocProvider(create: (BuildContext context) => GroupsScreenCubit()),
        BlocProvider(create: (BuildContext context) => ActivitiesScreenCubit()),
        BlocProvider(create: (BuildContext context) => MapScreenForGroupCubit()),
        BlocProvider(create: (BuildContext context) => MapScreenForActivityCubit()),
        BlocProvider(create: (BuildContext context) => SettingsScreenCubit()),
        BlocProvider(create: (BuildContext context) => CreateRouteScreenCubit()),
        BlocProvider(create: (BuildContext context) => CreateGroupScreenCubit()),
        BlocProvider(create: (BuildContext context) => CreateActivityScreenCubit()),
        BlocProvider(create: (BuildContext context) => EditGroupScreenCubit()),
        BlocProvider(create: (BuildContext context) => EditActivityScreenCubit()),
        BlocProvider(create: (BuildContext context) => GroupMembersScreenCubit()),
        BlocProvider(create: (BuildContext context) => ActivityMembersScreenCubit()),
      ],
      child: MaterialApp(
        title: 'Firebase Auth',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
              //backgroundColor: kSecondaryColor,
            //foregroundColor: Colors.white
          ),
          //scaffoldBackgroundColor: kSecondaryColor,
          textTheme: Theme
              .of(context)
              .textTheme
              .apply(
            //bodyColor: Colors.black87,
            fontFamily: 'Montserrat',
          ),
        ),
        home: FutureBuilder(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)  {
              return const CircularProgressIndicator();
            } else {
              if (snapshot.data != null)  {
                return FutureBuilder(
                  future: checkAndSetUserLogin(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)  {
                      // Eğer checkAndSetUserLogin() fonksiyonu hala çalışıyorsa, yükleniyor göster.
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      // checkAndSetUserLogin() fonksiyonu tamamlandıysa, HomePage'e git.
                      return snapshot.hasData ? const Homepage() : const LoginScreen();
                    }
                  },
                );
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
    print("current user ID: ${user.uid}");
    Map<String, dynamic>? userData = await UserDaoRepository.shared.getUserData();
    if (userData != null) {
      Users currentUser = Users.fromMap(user.uid, userData);
      await UsersManager().setUser(currentUser);
      print("Current User: ${currentUser.name}");
    }
  }
  return user;
}

