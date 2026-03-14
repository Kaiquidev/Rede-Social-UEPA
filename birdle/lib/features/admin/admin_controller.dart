import '../../core/services/app_store.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';

class AdminController {
  final AppStore _store = AppStore.instance;

  List<UserModel> get usuarios => _store.users;
  List<PostModel> get posts => _store.posts;
  List<String> get cursos => _store.courses;

  void alternarStatusUsuario(String userId) {
    _store.toggleUserStatus(userId);
  }

  void removerPost(String postId) {
    _store.removePost(postId);
  }

  void adicionarCurso(String nome) {
    _store.addCourse(nome);
  }

  void editarCurso(String antigo, String novo) {
    _store.updateCourse(antigo, novo);
  }

  void excluirCurso(String nome) {
    _store.removeCourse(nome);
  }
}
