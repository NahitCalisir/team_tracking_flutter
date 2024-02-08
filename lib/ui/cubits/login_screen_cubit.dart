import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/repo/user_dao_repository.dart';

class LoginScreenCubit extends Cubit<void> {
  LoginScreenCubit():super(0);

  Future<void> signUp(BuildContext context, {required String name, required String email, required String password}) async {

    await UserDaoRepository.shared.signUp(context, name: name, email: email, password: password);
  }

  Future<void> signIn(BuildContext context, {required String email, required String password}) async {
    await UserDaoRepository.shared.signIn(context, email: email, password: password);
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    await UserDaoRepository.shared.signInWithGoogle(context);
  }

  //Forgot password method
  Future<void> forgotPassword(BuildContext context, {required String email}) async {
    UserDaoRepository.shared.forgotPassword(context, email: email);
  }


}