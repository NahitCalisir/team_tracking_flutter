import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/repo/group_tracking_dao_repository.dart';

class HomepageCubit extends Cubit<void> {
  HomepageCubit(): super(null);

  Future<void> runUpdateMyLocation() async {
    await GroupTrackingDaoRepository.shared.runUpdateMyLocation();
  }

  ////Update User location in to firestore
  //Future<void> updateUserLocation({required String userId}) async {
  //  TeamTrackingDaoRepository.shared.updateUserLocation(userId: userId);
  //}
}