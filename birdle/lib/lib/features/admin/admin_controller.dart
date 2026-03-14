import '../../core/services/app_store.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';

class AdminController {
  final AppStore _store = AppStore.instance;

  List<UserModel> get usuarios => _store.users;
  List<PostModel> get posts => _store.posts;

  void alternarStatusUsuario(String userId) {
    _store.toggleUserStatus(userId);
  }

  void removerPost(String postId) {
    _store.removePost(postId);
  }
}
