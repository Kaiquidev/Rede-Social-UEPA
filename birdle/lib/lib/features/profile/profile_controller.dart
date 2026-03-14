import '../../core/services/app_store.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';

class ProfileController {
  final AppStore _store = AppStore.instance;

  UserModel? get usuario => _store.currentUser;
  List<PostModel> get minhasPostagens =>
      _store.currentUser == null ? [] : _store.postsByUser(_store.currentUser!.uid);
}
