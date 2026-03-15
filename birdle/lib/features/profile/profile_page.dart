import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/routes.dart';
import '../../core/services/app_store.dart';
import '../../core/widgets/app_page_layout.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import 'profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = ProfileController();
  final AppStore _store = AppStore.instance;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nomeController;
  late TextEditingController _instagramController;
  late TextEditingController _bioController;
  String? _cursoSelecionado;
  String _fotoPath = '';

  @override
  void initState() {
    super.initState();
    final user = _store.currentUser;
    _nomeController = TextEditingController(text: user?.nomeCompleto ?? '');
    _instagramController = TextEditingController(text: user?.instagram ?? '');
    _bioController = TextEditingController(text: user?.biografia ?? '');
    _cursoSelecionado = user?.curso;
    _fotoPath = user?.fotoUrl ?? '';
    _store.addListener(_refresh);
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
    if (mounted) setState(() {});
  }

  Future<void> _selecionarFoto() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      setState(() => _fotoPath = file.path);
    } catch (_) {}
  }

  void _salvar() {
    if (_nomeController.text.trim().isEmpty) {
      _snack('O nome não pode estar vazio.');
      return;
    }
    if (_cursoSelecionado == null || _cursoSelecionado!.isEmpty) {
      _snack('Selecione um curso.');
      return;
    }

    _store.updateCurrentUserProfile(
      nomeCompleto: _nomeController.text.trim(),
      curso: _cursoSelecionado!,
      instagram: _instagramController.text.trim(),
      biografia: _bioController.text.trim(),
      fotoUrl: _fotoPath,
    );

    _snack('Perfil atualizado com sucesso!');
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

  Widget _metric(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xff0f172a),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xff64748b),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _store.currentUser;

    if (user == null) {
      Future.microtask(() => Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (_) => false));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final posts = _store.postsByUser(user.uid);
    final cursos = _store.courses;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AppPageLayout(
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cabeçalho do perfil ──────────────────────────────────────
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _selecionarFoto,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          _avatar(user),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xff1877f2),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.nomeCompleto,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0f172a),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.curso} · ${user.tipoPerfil}',
                      style: const TextStyle(
                          color: Color(0xff64748b), fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _metric('Posts', '${posts.length}'),
                        _dividerVertical(),
                        _metric('Seguidores', '${user.seguidores.length}'),
                        _dividerVertical(),
                        _metric('Seguindo', '${user.seguindo.length}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Editar perfil ────────────────────────────────────────────
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Editar perfil',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1877f2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _nomeController,
                      decoration: const InputDecoration(labelText: 'Nome completo'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _cursoSelecionado,
                      decoration: const InputDecoration(labelText: 'Curso'),
                      items: cursos
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _cursoSelecionado = v),
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
                      decoration: const InputDecoration(labelText: 'Biografia'),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _salvar,
                        child: const Text('Salvar alterações'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Minhas publicações ───────────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Minhas publicações',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xff0f172a),
                ),
              ),
            ),

            if (posts.isEmpty)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Você ainda não publicou nada.',
                      style: TextStyle(color: Color(0xff64748b)),
                    ),
                  ),
                ),
              )
            else
              ...posts.map((post) => _buildPostCard(post)),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.conteudo.isNotEmpty)
              Text(
                post.conteudo,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xff1e293b),
                  height: 1.45,
                ),
              ),
            if (post.conteudo.isEmpty)
              const Text(
                '(publicação com mídia)',
                style: TextStyle(
                  color: Color(0xff64748b),
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.favorite, size: 15, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  '${post.curtidas}',
                  style: const TextStyle(
                      color: Color(0xff64748b), fontSize: 13),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.mode_comment_outlined,
                    size: 15, color: Color(0xff64748b)),
                const SizedBox(width: 4),
                Text(
                  '${post.comments.length}',
                  style: const TextStyle(
                      color: Color(0xff64748b), fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dividerVertical() {
    return Container(
      height: 32,
      width: 1,
      color: const Color(0xffe2e8f0),
    );
  }
}
