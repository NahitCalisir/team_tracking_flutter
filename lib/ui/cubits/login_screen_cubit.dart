import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/repo/team_tracking_dao_repository.dart';

class LoginScreenCubit extends Cubit<void> {
  LoginScreenCubit():super(0);

  Future<void> signUp(BuildContext context, {required String name, required String email, required String password}) async {

    await TeamTrackingDaoRepository.shared.signUp(context, name: name, email: email, password: password);
  }

  Future<void> signIn(BuildContext context, {required String email, required String password}) async {
    await TeamTrackingDaoRepository.shared.signIn(context, email: email, password: password);
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    await TeamTrackingDaoRepository.shared.signInWithGoogle(context);
  }
}