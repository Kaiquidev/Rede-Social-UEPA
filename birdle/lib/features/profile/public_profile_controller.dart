import '../../core/services/app_store.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';

class PublicProfileController {
  final AppStore _store = AppStore.instance;

  UserModel? getUser(String userId) => _store.getUserById(userId);

  List<PostModel> postsByUser(String userId) => _store.postsByUser(userId);

  bool isFollowing(String targetUserId) => _store.isFollowing(targetUserId);

  bool hasPendingRequest(String targetUserId) =>
      _store.hasPendingRequest(targetUserId);

  void toggleFollow(String targetUserId) => _store.toggleFollow(targetUserId);

  String? get currentUserId => _store.currentUser?.uid;
}
