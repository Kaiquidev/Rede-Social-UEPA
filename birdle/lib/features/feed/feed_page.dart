import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/routes.dart';
import '../../core/services/app_store.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/post_media_view.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import 'feed_controller.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FeedController _controller = FeedController();
  final AppStore _store = AppStore.instance;
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  PostMediaType _selectedMediaType = PostMediaType.none;
  String _selectedMediaPath = '';
  bool _isPosting = false;

  // Filtro: false = Todos, true = Seguindo
  bool _apenasSegunido = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_refreshPage);
  }

  @override
  void dispose() {
    _store.removeListener(_refreshPage);
    _postController.dispose();
    super.dispose();
  }

  void _refreshPage() {
    if (mounted) setState(() {});
  }

  // ── Mídia ──────────────────────────────────────────────────────────────────

  Future<void> _selecionarImagem() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      setState(() {
        _selectedMediaType = PostMediaType.image;
        _selectedMediaPath = file.path;
      });
    } catch (_) {
      _mostrarMensagem('Erro ao selecionar imagem.');
    }
  }

  Future<void> _selecionarVideo() async {
    try {
      final file = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );
      if (file == null) return;
      setState(() {
        _selectedMediaType = PostMediaType.video;
        _selectedMediaPath = file.path;
      });
    } catch (_) {
      _mostrarMensagem('Erro ao selecionar vídeo.');
    }
  }

  void _limparMidiaSelecionada() {
    setState(() {
      _selectedMediaType = PostMediaType.none;
      _selectedMediaPath = '';
    });
  }

  // ── Publicar ───────────────────────────────────────────────────────────────

  Future<void> _publicarPost() async {
    final texto = _postController.text.trim();

    if (texto.isEmpty && _selectedMediaPath.isEmpty) {
      _mostrarMensagem('Escreva uma mensagem ou adicione uma mídia.');
      return;
    }

    if (texto.isNotEmpty) {
      final erro = Validators.postagem(texto);
      if (erro != null) {
        _mostrarMensagem(erro);
        return;
      }
    }

    setState(() => _isPosting = true);

    try {
      _controller.publicar(
        conteudo: texto,
        mediaType: _selectedMediaType,
        mediaPath: _selectedMediaPath,
      );
      _postController.clear();
      _limparMidiaSelecionada();
      _mostrarMensagem('Postagem publicada com sucesso!');
    } catch (_) {
      _mostrarMensagem('Erro ao publicar postagem.');
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  // ── Editar post ────────────────────────────────────────────────────────────

  void _abrirEdicao(PostModel post) {
    final editController = TextEditingController(text: post.conteudo);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar publicação'),
        content: TextField(
          controller: editController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Edite sua publicação...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final novoTexto = editController.text.trim();
              if (novoTexto.isEmpty) {
                _mostrarMensagem('O conteúdo não pode estar vazio.');
                return;
              }
              final ok = _controller.editar(
                postId: post.id,
                novoConteudo: novoTexto,
              );
              Navigator.pop(context);
              if (ok) {
                _mostrarMensagem('Publicação editada!');
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // ── Confirmar deleção ──────────────────────────────────────────────────────

  void _confirmarDelecao(String postId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir publicação'),
        content: const Text(
            'Tem certeza que deseja excluir esta publicação? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _controller.remover(postId);
              Navigator.pop(context);
              _mostrarMensagem('Publicação excluída.');
            },
            child: const Text('Excluir',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Navegação para perfil público ──────────────────────────────────────────

  void _abrirPerfilPublico(String userId) {
    if (userId == _store.currentUser?.uid) {
      Navigator.pushNamed(context, AppRoutes.profile);
      return;
    }
    Navigator.pushNamed(context, AppRoutes.publicProfile, arguments: userId);
  }

  // ── Comentários ────────────────────────────────────────────────────────────

  void _abrirComentarios(PostModel post) {
    final currentUserId = _store.currentUser?.uid ?? '';
    final isPostAuthor = post.authorId == currentUserId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        final commentController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Busca o post atualizado a cada rebuild
            final postAtualizado = _store.posts.firstWhere(
              (p) => p.id == post.id,
              orElse: () => post,
            );

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                height: 560,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cabeçalho com toggle de comentários (só para o autor)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text('Comentários',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          const Spacer(),
                          if (isPostAuthor)
                            Row(
                              children: [
                                Text(
                                  postAtualizado.comentariosAtivos
                                      ? 'Ativados'
                                      : 'Desativados',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: postAtualizado.comentariosAtivos
                                        ? const Color(0xff1877f2)
                                        : const Color(0xff94a3b8),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Switch(
                                  value: postAtualizado.comentariosAtivos,
                                  onChanged: (_) {
                                    _store.toggleComentarios(post.id);
                                    setModalState(() {});
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),
                    const SizedBox(height: 4),

                    // Lista de comentários
                    Expanded(
                      child: postAtualizado.comments.isEmpty
                          ? Center(
                              child: Text(
                                postAtualizado.comentariosAtivos
                                    ? 'Nenhum comentário ainda.'
                                    : 'Comentários desativados.',
                                style: const TextStyle(
                                    color: Color(0xff94a3b8)),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              itemCount: postAtualizado.comments.length,
                              itemBuilder: (context, index) {
                                final comment =
                                    postAtualizado.comments[index];
                                final isCommentAuthor =
                                    comment.authorId == currentUserId;
                                final podeGerenciar =
                                    isCommentAuthor || isPostAuthor;

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xfff1f5f9),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor:
                                              const Color(0xffdbeafe),
                                          child: Text(
                                            comment.authorName.isNotEmpty
                                                ? comment.authorName[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                                color: Color(0xff1877f2),
                                                fontSize: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                comment.authorName,
                                                style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                comment.content,
                                                style: const TextStyle(
                                                    height: 1.4,
                                                    fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (podeGerenciar)
                                          PopupMenuButton<String>(
                                            icon: const Icon(
                                                Icons.more_vert,
                                                size: 18,
                                                color: Color(0xff94a3b8)),
                                            onSelected: (value) {
                                              if (value == 'editar') {
                                                _editarComentario(
                                                  context: context,
                                                  postId: post.id,
                                                  commentId: comment.id,
                                                  conteudoAtual:
                                                      comment.content,
                                                  onDone: () =>
                                                      setModalState(
                                                          () {}),
                                                );
                                              } else if (value ==
                                                  'excluir') {
                                                _store.removeComment(
                                                  postId: post.id,
                                                  commentId: comment.id,
                                                );
                                                setModalState(() {});
                                                setState(() {});
                                              }
                                            },
                                            itemBuilder: (_) => [
                                              if (isCommentAuthor)
                                                const PopupMenuItem(
                                                  value: 'editar',
                                                  child: Row(children: [
                                                    Icon(
                                                        Icons
                                                            .edit_outlined,
                                                        size: 16),
                                                    SizedBox(width: 8),
                                                    Text('Editar'),
                                                  ]),
                                                ),
                                              const PopupMenuItem(
                                                value: 'excluir',
                                                child: Row(children: [
                                                  Icon(
                                                      Icons
                                                          .delete_outline,
                                                      size: 16,
                                                      color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Excluir',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red)),
                                                ]),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Campo para novo comentário
                    if (postAtualizado.comentariosAtivos) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: commentController,
                                decoration: const InputDecoration(
                                  hintText: 'Escreva um comentário...',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                final text =
                                    commentController.text.trim();
                                if (text.isEmpty) return;
                                _store.addComment(
                                    postId: post.id, content: text);
                                commentController.clear();
                                setModalState(() {});
                                setState(() {});
                              },
                              child: const Text('Enviar'),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.comments_disabled_outlined,
                                size: 16, color: Color(0xff94a3b8)),
                            SizedBox(width: 6),
                            Text(
                              'Comentários desativados pelo autor',
                              style: TextStyle(
                                  color: Color(0xff94a3b8), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editarComentario({
    required BuildContext context,
    required String postId,
    required String commentId,
    required String conteudoAtual,
    required VoidCallback onDone,
  }) {
    final editController = TextEditingController(text: conteudoAtual);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar comentário'),
        content: TextField(
          controller: editController,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final novo = editController.text.trim();
              if (novo.isEmpty) return;
              _store.editComment(
                postId: postId,
                commentId: commentId,
                novoConteudo: novo,
              );
              Navigator.pop(context);
              setState(() {});
              onDone();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // ── Formatação de tempo ────────────────────────────────────────────────────

  String _formatarTempo(DateTime data) {
    final d = DateTime.now().difference(data);
    if (d.inSeconds < 60) return 'agora';
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    if (d.inHours < 24) return '${d.inHours} h';
    if (d.inDays < 7) return '${d.inDays} d';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currentUser = _store.currentUser;

    if (currentUser == null) {
      Future.microtask(() => Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (_) => false));
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final posts =
        _apenasSegunido ? _controller.postsSeguindo : _controller.posts;
    final notifications = _store.currentUserNotifications;
    final unreadCount = notifications.where((n) => !n.read).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UEPA Social',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Buscar usuários',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.search),
            icon: const Icon(Icons.search),
          ),
          Stack(
            children: [
              IconButton(
                tooltip: 'Notificações',
                onPressed: () {
                  _store.markNotificationsAsRead();
                  showDialog(
                    context: context,
                    builder: (context) {
                      final list = _store.currentUserNotifications;
                      return AlertDialog(
                        title: const Text('Notificações'),
                        content: SizedBox(
                          width: 380,
                          child: list.isEmpty
                              ? const Text('Nenhuma notificação.')
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    final item = list[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(item.title),
                                      subtitle: Text(item.body),
                                    );
                                  },
                                ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fechar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.notifications_none),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$unreadCount',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11)),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Perfil',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
          if (currentUser.isAdmin)
            IconButton(
              tooltip: 'Administrador',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.admin),
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () {
              _store.logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (_) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xfff3f6fb),
              Color(0xffdce5f1),
              Color(0xffcfd9e8),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTopoUsuario(currentUser),
                const SizedBox(height: 16),
                _buildFiltro(),
                const SizedBox(height: 12),
                _buildCaixaCriarPost(currentUser),
                const SizedBox(height: 18),
                if (posts.isEmpty)
                  _buildEmptyFeed()
                else
                  ...posts.map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildPostCard(post, currentUser.uid),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Topo do usuário ────────────────────────────────────────────────────────

  Widget _buildTopoUsuario(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1877f2), Color(0xff0f5fd3)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          user.fotoUrl.isNotEmpty
              ? CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(user.fotoUrl),
                )
              : CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    user.nomeCompleto.isNotEmpty
                        ? user.nomeCompleto[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Color(0xff1877f2),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bem-vindo(a)',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 2),
                Text(user.nomeCompleto,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(user.curso,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filtro Todos / Seguindo ────────────────────────────────────────────────

  Widget _buildFiltro() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Text(
              'Mostrar:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xff475569),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Todos'),
                    icon: Icon(Icons.public_outlined),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Seguindo'),
                    icon: Icon(Icons.people_outline),
                  ),
                ],
                selected: {_apenasSegunido},
                onSelectionChanged: (value) {
                  setState(() => _apenasSegunido = value.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Caixa criar post ───────────────────────────────────────────────────────

  Widget _buildCaixaCriarPost(UserModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                user.fotoUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(user.fotoUrl),
                      )
                    : CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xffdbeafe),
                        child: Text(
                          user.nomeCompleto.isNotEmpty
                              ? user.nomeCompleto[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Color(0xff1877f2),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(width: 12),
                const Text(
                  'Criar publicação',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1e293b),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _postController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'No que você está pensando?',
                alignLabelWithHint: true,
              ),
            ),
            if (_selectedMediaPath.isNotEmpty) ...[
              const SizedBox(height: 14),
              Stack(
                children: [
                  PostMediaView(
                    mediaType: _selectedMediaType,
                    mediaPath: _selectedMediaPath,
                    height: 240,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: _limparMidiaSelecionada,
                        icon: const Icon(Icons.close,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: _selecionarImagem,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Adicionar imagem'),
                ),
                OutlinedButton.icon(
                  onPressed: _selecionarVideo,
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Adicionar vídeo'),
                ),
                ElevatedButton.icon(
                  onPressed: _isPosting ? null : _publicarPost,
                  icon: _isPosting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_isPosting ? 'Postando...' : 'Postar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Feed vazio ─────────────────────────────────────────────────────────────

  Widget _buildEmptyFeed() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          children: [
            Icon(
              _apenasSegunido
                  ? Icons.people_outline
                  : Icons.dynamic_feed_outlined,
              size: 52,
              color: const Color(0xff64748b),
            ),
            const SizedBox(height: 12),
            Text(
              _apenasSegunido
                  ? 'Nenhuma postagem de quem você segue'
                  : 'Nenhuma postagem ainda',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _apenasSegunido
                  ? 'Siga mais pessoas para ver as publicações delas aqui.'
                  : 'Faça a primeira publicação e movimente a rede social da UEPA.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xff64748b), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card de post ───────────────────────────────────────────────────────────

  Widget _buildPostCard(PostModel post, String currentUserId) {
    final liked = post.isLikedBy(currentUserId);
    final isOwnPost = post.authorId == currentUserId;
    final author = _store.getUserById(post.authorId);
    final isFollowing =
        author == null ? false : _store.isFollowing(author.uid);
    final hasPending = _store.hasPendingRequest(post.authorId);
    final podeInteragir = _store.podeInteragir(post.authorId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCabecalhoPost(post, isOwnPost, isFollowing),
            if (post.conteudo.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                post.conteudo,
                style: const TextStyle(
                  fontSize: 15.5,
                  color: Color(0xff1e293b),
                  height: 1.45,
                ),
              ),
            ],
            if (post.mediaPath.isNotEmpty) ...[
              const SizedBox(height: 14),
              PostMediaView(
                mediaType: post.mediaType,
                mediaPath: post.mediaPath,
                height: 280,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.favorite, size: 18, color: Colors.red),
                const SizedBox(width: 6),
                Text(
                  '${post.curtidas} curtidas',
                  style: const TextStyle(
                    color: Color(0xff475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.mode_comment_outlined,
                    size: 18, color: Color(0xff64748b)),
                const SizedBox(width: 6),
                Text(
                  '${post.comments.length} comentários',
                  style: const TextStyle(
                    color: Color(0xff475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: podeInteragir
                        ? () => _controller.curtir(post.id)
                        : null,
                    icon: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: !podeInteragir
                          ? const Color(0xffcbd5e1)
                          : liked
                              ? Colors.red
                              : const Color(0xff1877f2),
                    ),
                    label: Text(
                      liked ? 'Curtido' : 'Curtir',
                      style: TextStyle(
                        color: !podeInteragir
                            ? const Color(0xffcbd5e1)
                            : liked
                                ? Colors.red
                                : const Color(0xff1877f2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: podeInteragir
                        ? () => _abrirComentarios(post)
                        : null,
                    icon: Icon(
                      post.comentariosAtivos
                          ? Icons.mode_comment_outlined
                          : Icons.comments_disabled_outlined,
                      color: !podeInteragir
                          ? const Color(0xffcbd5e1)
                          : post.comentariosAtivos
                              ? const Color(0xff1877f2)
                              : const Color(0xff94a3b8),
                    ),
                    label: Text(
                      'Comentar',
                      style: TextStyle(
                        color: !podeInteragir
                            ? const Color(0xffcbd5e1)
                            : post.comentariosAtivos
                                ? const Color(0xff1877f2)
                                : const Color(0xff94a3b8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Cabeçalho do post ──────────────────────────────────────────────────────

  Widget _buildCabecalhoPost(
      PostModel post, bool isOwnPost, bool isFollowing) {
    final hasPending = _store.hasPendingRequest(post.authorId);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _abrirPerfilPublico(post.authorId),
          child: post.authorPhoto.isNotEmpty
              ? CircleAvatar(
                  radius: 23,
                  backgroundImage: NetworkImage(post.authorPhoto),
                )
              : CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xffdbeafe),
                  child: Text(
                    post.authorName.trim().isNotEmpty
                        ? post.authorName.trim()[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Color(0xff0f4db8),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _abrirPerfilPublico(post.authorId),
                child: Text(
                  post.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.5,
                    color: Color(0xff0f172a),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(post.cursoAutor,
                  style: const TextStyle(
                      color: Color(0xff64748b), fontSize: 13)),
              const SizedBox(height: 2),
              Text(_formatarTempo(post.createdAt),
                  style: const TextStyle(
                      color: Color(0xff94a3b8), fontSize: 12.5)),
            ],
          ),
        ),

        // Menu de ações do próprio post ou botão seguir
        if (isOwnPost)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: Color(0xff94a3b8)),
            tooltip: 'Opções',
            onSelected: (value) {
              if (value == 'editar') _abrirEdicao(post);
              if (value == 'comentarios') _store.toggleComentarios(post.id);
              if (value == 'excluir') _confirmarDelecao(post.id);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'comentarios',
                child: Row(
                  children: [
                    Icon(
                      post.comentariosAtivos
                          ? Icons.comments_disabled_outlined
                          : Icons.mode_comment_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(post.comentariosAtivos
                        ? 'Desativar comentários'
                        : 'Ativar comentários'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'excluir',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir',
                        style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          )
        else
          // Botão seguir com 3 estados: Seguir / Solicitado / Seguindo
          isFollowing
              ? OutlinedButton(
                  onPressed: () => _store.toggleFollow(post.authorId),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Seguindo'),
                )
              : hasPending
                  ? OutlinedButton.icon(
                      onPressed: () => _store.toggleFollow(post.authorId),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: const Color(0xff64748b),
                      ),
                      icon: const Icon(Icons.hourglass_top_outlined,
                          size: 14),
                      label: const Text('Solicitado',
                          style: TextStyle(fontSize: 13)),
                    )
                  : ElevatedButton(
                      onPressed: () => _store.toggleFollow(post.authorId),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Seguir'),
                    ),
      ],
    );
  }
}
