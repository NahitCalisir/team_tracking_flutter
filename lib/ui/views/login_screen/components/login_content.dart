import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/ui/cubits/login_screen_cubit.dart';
import 'package:team_tracking/data/repo/helper_functions.dart';
import 'package:team_tracking/utils/constants.dart';
import '../animations/change_screen_animation.dart';
import 'bottom_text.dart';
import 'top_text.dart';

enum Screens {
  signUp,
  signIn,
}

class LoginContent extends StatefulWidget {
  const LoginContent({Key? key}) : super(key: key);

  @override
  State<LoginContent> createState() => LoginContentState();
}

class LoginContentState extends State<LoginContent>
    with TickerProviderStateMixin {
  late  List<Widget> createAccountContent;
  late  List<Widget> loginContent;

  final _tName = TextEditingController();
  final _tEmail = TextEditingController();
  final _tPassword = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {

    createAccountContent = [
      inputField(_tName, 'Name', Icons.person_outline),
      inputField(_tEmail, 'Email', Icons.mail_outline),
      inputField(_tPassword, 'Password', Icons.lock_outline),
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
      inputField(_tEmail, 'Email', Icons.mail_outline),
      inputField(_tPassword, 'Password', Icons.lock_outline),
      actionButton('Log In',
          onTap: () {
            setState(() {isLoading = true;});
            LoginScreenCubit().signIn(context, email: _tEmail.text, password: _tPassword.text);
            setState(() {isLoading = false;});
          }),
      forgotPassword(),
    ];

    ChangeScreenAnimation.initialize(
      vsync: this,
      createAccountItems: createAccountContent.length,
      loginItems: loginContent.length,
    );

    for (var i = 0; i < createAccountContent.length; i++) {
      ChangeScreenAnimation.createAccountAnimations[i].addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {});
        }
      });
      createAccountContent[i] = HelperFunctions.wrapWithAnimatedBuilder(
        animation: ChangeScreenAnimation.createAccountAnimations[i],
        child: createAccountContent[i],
      );
    }

    for (var i = 0; i < loginContent.length; i++) {
      ChangeScreenAnimation.loginAnimations[i].addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {});
        }
      });
      loginContent[i] = HelperFunctions.wrapWithAnimatedBuilder(
        animation: ChangeScreenAnimation.loginAnimations[i],
        child: loginContent[i],
      );
    }
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 100,
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
          backgroundColor: Colors.black54,
          shape: const StadiumBorder(),
          elevation: 8,
          shadowColor: Colors.grey,
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
      padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 0),
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 1,
              color: Colors.black,
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
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget logos() {
    return Column(
      children: [
        if (Platform.isIOS)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 36),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4),
                backgroundColor: Colors.black54,
                shape: const StadiumBorder(),
                elevation: 8,
                shadowColor: Colors.white,
              ),
              onPressed: () async {
                setState(() {isLoading = true;});
                await LoginScreenCubit().signInWithApple(context);
                setState(() {isLoading = false;});
              },
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apple,color: Colors.white,size: 30,),
                    SizedBox(width: 15,),
                    Text(
                      "Sin In With Apple",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 17
                      ),),
                  ],
                ),
              )
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 36),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4),
                backgroundColor: Colors.black54,
                shape: const StadiumBorder(),
                elevation: 8,
                shadowColor: Colors.white,
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
                    SizedBox(
                        height: 27,
                        child: Image.asset('assets/images/google.png')),
                    const SizedBox(width: 15,),
                    const Text(
                      "Sin In With Google",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 17
                      ),),
                  ],
                ),
              )
          ),
        ),
      ],
    );
  }

  Widget forgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final tMail = TextEditingController();
              return AlertDialog(
                content: TextField(
                  controller:  tMail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    //prefixIcon: Icon(Icons.email_outlined),
                    hintText: "Email Address",
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () {
                    context.read<LoginScreenCubit>().forgotPassword(context, email: tMail.text.trim());
                  }, child: const Text("Send Reset Mail"))
                ],
              );
            },
          );
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
      ),
    );
  }

}
