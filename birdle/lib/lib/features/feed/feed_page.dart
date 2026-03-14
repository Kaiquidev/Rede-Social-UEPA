import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/routes.dart';
import '../../core/services/app_store.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/post_media_view.dart';
import '../../models/post_model.dart';
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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _selecionarImagem() async {
    try {
      final XFile? file = await _picker.pickImage(
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
      final XFile? file = await _picker.pickVideo(
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

  Future<void> _publicarPost() async {
    final String texto = _postController.text.trim();

    if (texto.isEmpty && _selectedMediaPath.isEmpty) {
      _mostrarMensagem('Escreva uma mensagem ou adicione uma mídia.');
      return;
    }

    if (texto.isNotEmpty) {
      final String? erro = Validators.postagem(texto);
      if (erro != null) {
        _mostrarMensagem(erro);
        return;
      }
    }

    setState(() {
      _isPosting = true;
    });

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
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  String _formatarTempo(DateTime data) {
    final Duration diferenca = DateTime.now().difference(data);

    if (diferenca.inSeconds < 60) {
      return 'agora';
    }
    if (diferenca.inMinutes < 60) {
      return '${diferenca.inMinutes} min';
    }
    if (diferenca.inHours < 24) {
      return '${diferenca.inHours} h';
    }
    if (diferenca.inDays < 7) {
      return '${diferenca.inDays} d';
    }

    final String dia = data.day.toString().padLeft(2, '0');
    final String mes = data.month.toString().padLeft(2, '0');
    final String ano = data.year.toString();

    return '$dia/$mes/$ano';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _store.currentUser;

    if (currentUser == null) {
      Future.microtask(() {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (_) => false,
        );
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<PostModel> posts = _controller.posts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UEPA Social',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            icon: const Icon(Icons.person_outline),
          ),
          if (currentUser.isAdmin)
            IconButton(
              tooltip: 'Administrador',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.admin);
              },
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () {
              _store.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (_) => false,
              );
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
                _buildTopoUsuario(currentUser.nomeCompleto, currentUser.curso),
                const SizedBox(height: 16),
                _buildCaixaCriarPost(),
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

  Widget _buildTopoUsuario(String nome, String curso) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff1877f2),
            Color(0xff0f5fd3),
          ],
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
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 30,
              color: Color(0xff1877f2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bem-vindo(a)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  curso,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaixaCriarPost() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Criar publicação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff1e293b),
              ),
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
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white,
                        ),
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

  Widget _buildEmptyFeed() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          children: const [
            Icon(
              Icons.dynamic_feed_outlined,
              size: 52,
              color: Color(0xff64748b),
            ),
            SizedBox(height: 12),
            Text(
              'Nenhuma postagem ainda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff334155),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Faça a primeira publicação e movimente a rede social da UEPA.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff64748b),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post, String currentUserId) {
    final bool liked = post.isLikedBy(currentUserId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCabecalhoPost(post),
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
                const Icon(
                  Icons.favorite,
                  size: 18,
                  color: Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  '${post.curtidas} curtidas',
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
                    onPressed: () {
                      _controller.curtir(post.id);
                    },
                    icon: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? Colors.red : const Color(0xff1877f2),
                    ),
                    label: Text(
                      liked ? 'Curtido' : 'Curtir',
                      style: TextStyle(
                        color: liked ? Colors.red : const Color(0xff1877f2),
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

  Widget _buildCabecalhoPost(PostModel post) {
    final String inicial =
        post.authorName.trim().isNotEmpty ? post.authorName.trim()[0] : '?';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 23,
          backgroundColor: const Color(0xffdbeafe),
          child: Text(
            inicial.toUpperCase(),
            style: const TextStyle(
              color: Color(0xff0f4db8),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                  color: Color(0xff0f172a),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                post.cursoAutor,
                style: const TextStyle(
                  color: Color(0xff64748b),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatarTempo(post.createdAt),
                style: const TextStyle(
                  color: Color(0xff94a3b8),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
