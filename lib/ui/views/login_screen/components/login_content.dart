import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:team_tracking/ui/cubits/login_screen_cubit.dart';
import 'package:team_tracking/ui/views/bottom_navigation_bar.dart';
import 'package:team_tracking/utils/helper_functions.dart';
import 'package:team_tracking/utils/constants.dart';
import '../animations/change_screen_animation.dart';
import 'bottom_text.dart';
import 'top_text.dart';

enum Screens {
  signUp,
  signIn,
}

class LoginContent extends StatefulWidget {
  const LoginContent({super.key});

  @override
  State<LoginContent> createState() => LoginContentState();
}

class LoginContentState extends State<LoginContent>
    with TickerProviderStateMixin {
  late final List<Widget> createAccountContent;
  late final List<Widget> loginContent;

  final _tName = TextEditingController();
  final _tEmail = TextEditingController();
  final _tPassword = TextEditingController();

  bool isLoading = false;

  Widget inputField(TextEditingController controller, String hint, IconData iconData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
      child: SizedBox(
        height: 50,
        child: Material(
          elevation: 8,
          shadowColor: Colors.black87,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: TextField(
            controller: controller,
            textAlignVertical: TextAlignVertical.bottom,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: hint,
              prefixIcon: Icon(iconData),
            ),
          ),
        ),
      ),
    );
  }

  Widget actionButton(String title, {Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      child: ElevatedButton(
        onPressed: () {
         if (onTap != null) {
           onTap();
         }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8), backgroundColor: kSecondaryColor2,
          shape: const StadiumBorder(),
          elevation: 8,
          shadowColor: Colors.black87,
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget orDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 8),
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 1,
              color: kPrimaryColor,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OR',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Container(
              height: 1,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget logos() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 36),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 4),
            backgroundColor: Colors.white,
            shape: const StadiumBorder(),
            elevation: 8,
            shadowColor: Colors.black87,
          ),
          onPressed: () async {
            setState(() {isLoading = true;});
            await LoginScreenCubit().signInWithGoogle(context);
            setState(() {isLoading = false;});
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/google.png'),
                const SizedBox(width: 8,),
                Text(
                  "Sin In With Google",
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 18
                  ),),
              ],
            ),
          )
      ),
    );
  }

  Widget forgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 110),
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    createAccountContent = [
      inputField(_tName, 'Name', Ionicons.person_outline),
      inputField(_tEmail, 'Email', Ionicons.mail_outline),
      inputField(_tPassword, 'Password', Ionicons.lock_closed_outline),
      actionButton('Sign Up',
        onTap: () {
          setState(() {isLoading = true;});
          LoginScreenCubit().signUp(context, name: _tName.text, email: _tEmail.text, password: _tPassword.text);
          setState(() {isLoading = false;});
        },
      ),
      orDivider(),
      logos(),
    ];

    loginContent = [
      inputField(_tEmail, 'Email', Ionicons.mail_outline),
      inputField(_tPassword, 'Password', Ionicons.lock_closed_outline),
      actionButton('Log In',
          onTap: () {
            setState(() {isLoading = true;});
            LoginScreenCubit().signIn(context, email: _tEmail.text, password: _tPassword.text);
            setState(() {isLoading = false;});
          }),
      forgotPassword(),
    ];

    if (!ChangeScreenAnimation.isPlaying) {
      ChangeScreenAnimation.initialize(
        vsync: this,
        createAccountItems: createAccountContent.length,
        loginItems: loginContent.length,
      );

      for (var i = 0; i < createAccountContent.length; i++) {
        createAccountContent[i] = HelperFunctions.wrapWithAnimatedBuilder(
          animation: ChangeScreenAnimation.createAccountAnimations[i],
          child: createAccountContent[i],
        );
      }

      for (var i = 0; i < loginContent.length; i++) {
        loginContent[i] = HelperFunctions.wrapWithAnimatedBuilder(
          animation: ChangeScreenAnimation.loginAnimations[i],
          child: loginContent[i],
        );
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    ChangeScreenAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 136,
          left: 24,
          child: TopText(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: createAccountContent,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: loginContent,
              ),
              if(isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: BottomText(),
          ),
        ),
      ],
    );
  }
}
