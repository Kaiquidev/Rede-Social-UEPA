import '../../core/services/app_store.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';

class PublicProfileController {
  final AppStore _store = AppStore.instance;

  /// Retorna o usuário pelo [userId], ou `null` se não encontrado.
  UserModel? getUser(String userId) => _store.getUserById(userId);

  /// Posts publicados pelo usuário [userId], ordenados do mais recente.
  List<PostModel> postsByUser(String userId) => _store.postsByUser(userId);

  /// Se o usuário logado segue [targetUserId].
  bool isFollowing(String targetUserId) => _store.isFollowing(targetUserId);

  /// Alterna seguir / deixar de seguir [targetUserId].
  void toggleFollow(String targetUserId) => _store.toggleFollow(targetUserId);

  /// Uid do usuário logado.
  String? get currentUserId => _store.currentUser?.uid;
}
