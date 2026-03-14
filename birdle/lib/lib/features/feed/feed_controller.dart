import '../../core/services/app_store.dart';
import '../../models/post_model.dart';

class FeedController {
  final AppStore _store = AppStore.instance;

  List<PostModel> get posts => _store.posts;

  void publicar(String conteudo) {
    _store.createPost(conteudo);
  }

  void curtir(String postId) {
    _store.curtirPost(postId);
  }
}
