import '../../core/services/app_store.dart';
import '../../models/post_model.dart';

class FeedController {
  final AppStore _store = AppStore.instance;

  List<PostModel> get posts => _store.posts;

  void publicar({
    required String conteudo,
    PostMediaType mediaType = PostMediaType.none,
    String mediaPath = '',
  }) {
    _store.createPost(
      conteudo: conteudo,
      mediaType: mediaType,
      mediaPath: mediaPath,
    );
  }

  void curtir(String postId) {
    _store.toggleCurtida(postId);
  }
}
