import '../../core/services/app_store.dart';
import '../../models/user_model.dart';

class AuthController {
  final AppStore _store = AppStore.instance;

  String? login({required String email, required String senha}) {
    return _store.login(email: email, senha: senha);
  }

  String? register(UserModel user) {
    return _store.registerUser(user);
  }
}
