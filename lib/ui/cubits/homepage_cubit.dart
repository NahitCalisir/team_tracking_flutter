import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/repo/user_dao_repository.dart';

class HomepageCubit extends Cubit<void> {
  HomepageCubit(): super(null);

  Future<void> runUpdateMyLocation() async {
    await UserDaoRepository.shared.runUpdateMyLocation();
  }

}