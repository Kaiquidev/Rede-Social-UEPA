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

  void _abrirListaUsuarios({
    required String titulo,
    required List<String> uids,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '$titulo (${uids.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: uids.isEmpty
                    ? Center(
                        child: Text(
                          titulo == 'Seguidores'
                              ? 'Nenhum seguidor ainda.'
                              : 'Você não segue ninguém ainda.',
                          style: const TextStyle(
                              color: Color(0xff94a3b8)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: uids.length,
                        itemBuilder: (context, index) {
                          final uid = uids[index];
                          final pessoa = _store.getUserById(uid);
                          if (pessoa == null) return const SizedBox();

                          final isSeguindo =
                              _store.isFollowing(pessoa.uid);
                          final isMe =
                              _store.currentUser?.uid == pessoa.uid;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 4),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.publicProfile,
                                arguments: pessoa.uid,
                              );
                            },
                            leading: pessoa.fotoUrl.isNotEmpty
                                ? CircleAvatar(
                                    radius: 26,
                                    backgroundImage:
                                        NetworkImage(pessoa.fotoUrl),
                                  )
                                : CircleAvatar(
                                    radius: 26,
                                    backgroundColor:
                                        const Color(0xffdbeafe),
                                    child: Text(
                                      pessoa.nomeCompleto.isNotEmpty
                                          ? pessoa.nomeCompleto[0]
                                              .toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Color(0xff0f4db8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                            title: Text(
                              pessoa.nomeCompleto,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            subtitle: Text(
                              '${pessoa.curso} · ${pessoa.tipoPerfil}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff64748b)),
                            ),
                            trailing: isMe
                                ? null
                                : isSeguindo
                                    ? OutlinedButton(
                                        onPressed: () {
                                          _store.toggleFollow(pessoa.uid);
                                          Navigator.pop(context);
                                          _abrirListaUsuarios(
                                            titulo: titulo,
                                            uids: titulo == 'Seguidores'
                                                ? _store
                                                    .currentUser!.seguidores
                                                : _store
                                                    .currentUser!.seguindo,
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                        ),
                                        child: const Text('Seguindo'),
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          _store.toggleFollow(pessoa.uid);
                                          Navigator.pop(context);
                                          _abrirListaUsuarios(
                                            titulo: titulo,
                                            uids: titulo == 'Seguidores'
                                                ? _store
                                                    .currentUser!.seguidores
                                                : _store
                                                    .currentUser!.seguindo,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                        ),
                                        child: const Text('Seguir'),
                                      ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmarDesbloquear(String uid, String nome) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Desbloquear usuário'),
        content: Text(
            'Deseja desbloquear $nome? Ele poderá voltar a interagir com seu perfil.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _store.desbloquear(uid);
              Navigator.pop(context);
              _snack('$nome foi desbloqueado.');
            },
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );
  }

  void _confirmarBloquear(String uid, String nome) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bloquear usuário'),
        content: Text(
            'Deseja bloquear $nome? Ele deixará de seguir você e não poderá mais interagir com seu perfil.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _store.bloquear(uid);
              Navigator.pop(context);
              _snack('$nome foi bloqueado.');
            },
            child: const Text('Bloquear',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
            color: Color(0xff1877f2),
            fontSize: 13,
            decoration: TextDecoration.underline,
            decorationColor: Color(0xff1877f2),
          ),
        ),
      ],
    );
  }

  Widget _dividerVertical() {
    return Container(
      height: 32,
      width: 1,
      color: const Color(0xffe2e8f0),
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
            // ── Cabeçalho ──────────────────────────────────────────────
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
                              border: Border.all(
                                  color: Colors.white, width: 2),
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
                        GestureDetector(
                          onTap: () => _abrirListaUsuarios(
                            titulo: 'Seguidores',
                            uids: user.seguidores,
                          ),
                          child: _metric(
                              'Seguidores', '${user.seguidores.length}'),
                        ),
                        _dividerVertical(),
                        GestureDetector(
                          onTap: () => _abrirListaUsuarios(
                            titulo: 'Seguindo',
                            uids: user.seguindo,
                          ),
                          child: _metric(
                              'Seguindo', '${user.seguindo.length}'),
                        ),
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
                      decoration:
                          const InputDecoration(labelText: 'Nome completo'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _cursoSelecionado,
                      decoration:
                          const InputDecoration(labelText: 'Curso'),
                      items: cursos
                          .map((c) => DropdownMenuItem(
                              value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _cursoSelecionado = v),
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
                      decoration:
                          const InputDecoration(labelText: 'Biografia'),
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

            // ── Privacidade ──────────────────────────────────────────────
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        color: Color(0xff1877f2), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Perfil privado',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xff0f172a),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.perfilPrivado
                                ? 'Apenas seus seguidores podem curtir e comentar.'
                                : 'Qualquer pessoa pode curtir e comentar.',
                            style: const TextStyle(
                              color: Color(0xff64748b),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: user.perfilPrivado,
                      onChanged: (_) {
                        _store.togglePerfilPrivado();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Usuários bloqueados ──────────────────────────────────────
            if (user.bloqueados.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.block_outlined,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Bloqueados (${user.bloqueados.length})',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...user.bloqueados.map((uid) {
                        final bloqueado = _store.getUserById(uid);
                        if (bloqueado == null) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              bloqueado.fotoUrl.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 22,
                                      backgroundImage:
                                          NetworkImage(bloqueado.fotoUrl),
                                    )
                                  : CircleAvatar(
                                      radius: 22,
                                      backgroundColor:
                                          const Color(0xfffee2e2),
                                      child: Text(
                                        bloqueado.nomeCompleto.isNotEmpty
                                            ? bloqueado.nomeCompleto[0]
                                                .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bloqueado.nomeCompleto,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      bloqueado.curso,
                                      style: const TextStyle(
                                        color: Color(0xff64748b),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    _confirmarDesbloquear(uid, bloqueado.nomeCompleto),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Desbloquear'),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

            // ── Solicitações pendentes ───────────────────────────────────
            if (user.solicitacoesPendentes.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_add_outlined,
                              color: Color(0xff1877f2), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Solicitações (${user.solicitacoesPendentes.length})',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1877f2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...user.solicitacoesPendentes.map((uid) {
                        final solicitante = _store.getUserById(uid);
                        if (solicitante == null) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              solicitante.fotoUrl.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 22,
                                      backgroundImage:
                                          NetworkImage(solicitante.fotoUrl),
                                    )
                                  : CircleAvatar(
                                      radius: 22,
                                      backgroundColor:
                                          const Color(0xffdbeafe),
                                      child: Text(
                                        solicitante.nomeCompleto.isNotEmpty
                                            ? solicitante
                                                .nomeCompleto[0]
                                                .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color: Color(0xff1877f2),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      solicitante.nomeCompleto,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    Text(
                                      solicitante.curso,
                                      style: const TextStyle(
                                          color: Color(0xff64748b),
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    _store.aceitarSolicitacao(uid),
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.green),
                                child: const Text('Aceitar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    _store.negarSolicitacao(uid),
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                child: const Text('Negar'),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

            // ── Seguidores ───────────────────────────────────────────────
            if (user.seguidores.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline,
                              color: Color(0xff1877f2), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Seguidores (${user.seguidores.length})',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1877f2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...user.seguidores.map((uid) {
                        final seguidor = _store.getUserById(uid);
                        if (seguidor == null) return const SizedBox();
                        final bloqueado = _store.isBloqueado(uid);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              seguidor.fotoUrl.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 22,
                                      backgroundImage:
                                          NetworkImage(seguidor.fotoUrl),
                                    )
                                  : CircleAvatar(
                                      radius: 22,
                                      backgroundColor:
                                          const Color(0xffdbeafe),
                                      child: Text(
                                        seguidor.nomeCompleto.isNotEmpty
                                            ? seguidor.nomeCompleto[0]
                                                .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color: Color(0xff1877f2),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      seguidor.nomeCompleto,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    Text(
                                      seguidor.curso,
                                      style: const TextStyle(
                                          color: Color(0xff64748b),
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              if (!bloqueado)
                                TextButton(
                                  onPressed: () =>
                                      _confirmarBloquear(uid, seguidor.nomeCompleto),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                  child: const Text('Bloquear'),
                                )
                              else
                                TextButton(
                                  onPressed: () => _store.desbloquear(uid),
                                  style: TextButton.styleFrom(
                                      foregroundColor:
                                          const Color(0xff64748b)),
                                  child: const Text('Desbloquear'),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

            // ── Publicações ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Minhas publicações',
                style: const TextStyle(
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
}
