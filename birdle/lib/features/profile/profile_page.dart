import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/routes.dart';
import '../../core/services/app_store.dart';
import '../../core/utils/validators.dart';
import '../../models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AppStore _store = AppStore.instance;
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nomeController;
  late final TextEditingController _instagramController;
  late final TextEditingController _bioController;

  String? _cursoSelecionado;
  String _fotoPath = '';

  @override
  void initState() {
    super.initState();
    _store.addListener(_refresh);

    final user = _store.currentUser;
    _nomeController = TextEditingController(text: user?.nomeCompleto ?? '');
    _instagramController = TextEditingController(text: user?.instagram ?? '');
    _bioController = TextEditingController(text: user?.biografia ?? '');
    _cursoSelecionado = user?.curso;
    _fotoPath = user?.fotoUrl ?? '';
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    _nomeController.dispose();
    _instagramController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _selecionarFoto() async {
    final file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;

    setState(() {
      _fotoPath = file.path;
    });
  }

  void _salvar() {
    final nomeErro = Validators.nome(_nomeController.text);
    if (nomeErro != null) {
      _snack(nomeErro);
      return;
    }

    final instaErro = Validators.instagram(_instagramController.text);
    if (instaErro != null) {
      _snack(instaErro);
      return;
    }

    if (_cursoSelecionado == null || _cursoSelecionado!.trim().isEmpty) {
      _snack('Selecione um curso');
      return;
    }

    _store.updateCurrentUserProfile(
      nomeCompleto: _nomeController.text,
      curso: _cursoSelecionado!,
      instagram: _instagramController.text,
      biografia: _bioController.text,
      fotoUrl: _fotoPath,
    );

    _snack('Perfil atualizado com sucesso.');
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Widget _avatar(UserModel user) {
    if (_fotoPath.isNotEmpty) {
      return CircleAvatar(
        radius: 46,
        backgroundImage: NetworkImage(_fotoPath),
      );
    }

    return CircleAvatar(
      radius: 46,
      backgroundColor: const Color(0xffdbeafe),
      child: Text(
        user.nomeCompleto.isNotEmpty ? user.nomeCompleto[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Color(0xff0f4db8),
          fontWeight: FontWeight.bold,
          fontSize: 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _store.currentUser;

    if (user == null) {
      Future.microtask(() {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (_) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final posts = _store.postsByUser(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu perfil'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xfff3f6fb), Color(0xffdce5f1)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _selecionarFoto,
                      child: _avatar(user),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _selecionarFoto,
                      child: const Text('Alterar foto'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: const TextStyle(color: Color(0xff64748b)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _metric('Posts', '${posts.length}'),
                        _metric('Seguidores', '${user.seguidores.length}'),
                        _metric('Seguindo', '${user.seguindo.length}'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _cursoSelecionado,
                      items: _store.courses
                          .map((curso) => DropdownMenuItem(
                                value: curso,
                                child: Text(curso),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _cursoSelecionado = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Curso',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _instagramController,
                      decoration: const InputDecoration(
                        labelText: 'Instagram',
                        hintText: '@nomedapessoa',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Biografia',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _salvar,
                        child: const Text('Salvar alterações'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Minhas publicações',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            if (posts.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Você ainda não publicou nada.'),
                ),
              )
            else
              ...posts.map(
                (post) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      title: Text(post.conteudo.isEmpty
                          ? '(post com mídia)'
                          : post.conteudo),
                      subtitle: Text(
                        '${post.curtidas} curtidas • ${post.comments.length} comentários',
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Color(0xff64748b)),
        ),
      ],
    );
  }
}
