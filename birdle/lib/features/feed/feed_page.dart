import 'dart:io';

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
  final _controller = FeedController();
  final _store = AppStore.instance;
  final _postController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  PostMediaType _selectedMediaType = PostMediaType.none;
  String _selectedMediaPath = '';

  @override
  void initState() {
    super.initState();
    _store.addListener(_refresh);
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    _postController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _selecionarImagem() async {
    final file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    setState(() {
      _selectedMediaType = PostMediaType.image;
      _selectedMediaPath = file.path;
    });
  }

  Future<void> _selecionarVideo() async {
    final file = await _picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(seconds: 30));
    if (file == null) return;
    setState(() {
      _selectedMediaType = PostMediaType.video;
      _selectedMediaPath = file.path;
    });
  }

  void _limparMidia() {
    setState(() {
      _selectedMediaType = PostMediaType.none;
      _selectedMediaPath = '';
    });
  }

  String _formatarTempo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'agora';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min';
    if (difference.inHours < 24) return '${difference.inHours} h';
    return '${difference.inDays} d';
  }

  void _publicar() {
    final hasText = _postController.text.trim().isNotEmpty;
    final hasMedia = _selectedMediaPath.isNotEmpty;

    if (!hasText && !hasMedia) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Escreva uma mensagem ou adicione uma mídia.')),
      );
      return;
    }

    if (hasText && !_formKey.currentState!.validate()) return;

    _controller.publicar(
      conteudo: _postController.text.trim(),
      mediaType: _selectedMediaType,
      mediaPath: _selectedMediaPath,
    );

    _postController.clear();
    _limparMidia();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Postagem publicada com sucesso.')),
    );
  }

  void _logout() {
    _store.logout();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _store.currentUser;
    if (currentUser == null) {
      Future.microtask(() {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (_) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('UEPA Social'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            icon: const Icon(Icons.person),
            tooltip: 'Meu perfil',
          ),
          if (currentUser.isAdmin)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.admin),
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Administrador',
            ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xfff3f5f9), Color(0xffdde3ee)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _buildComposer(currentUser),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'Feed da comunidade',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                ..._controller.posts
                    .map((post) => _buildPostCard(post, currentUser.uid)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComposer(currentUser) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xffdbeafe),
                  child: Text(
                    currentUser.nomeCompleto.isNotEmpty
                        ? currentUser.nomeCompleto[0]
                        : 'U',
                    style: const TextStyle(
                      color: Color(0xff0f4db8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.nomeCompleto,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${currentUser.curso} • ${currentUser.tipoPerfil}',
                        style: const TextStyle(color: Color(0xff64748b)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _postController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return Validators.postagem(value);
                },
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText:
                      'No que você está pensando? Compartilhe algo com a UEPA...',
                ),
              ),
            ),
            if (_selectedMediaPath.isNotEmpty) ...[
              const SizedBox(height: 12),
              Stack(
                children: [
                  PostMediaView(
                    mediaType: _selectedMediaType,
                    mediaPath: _selectedMediaPath,
                    height: 220,
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        onPressed: _limparMidia,
                        icon: const Icon(Icons.close, color: Colors.white),
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
              alignment: WrapAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _selecionarImagem,
                  icon: const Icon(Icons.image_outlined,
                      color: Color(0xff1877f2)),
                  label: const Text('Adicionar imagem'),
                ),
                OutlinedButton.icon(
                  onPressed: _selecionarVideo,
                  icon: const Icon(Icons.videocam_outlined,
                      color: Color(0xff1877f2)),
                  label: const Text('Vídeo curto'),
                ),
                ElevatedButton.icon(
                  onPressed: _publicar,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Postar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post, String currentUserId) {
    final liked = post.isLikedBy(currentUserId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xffdbeafe),
                    child: Text(
                      post.authorName.isNotEmpty ? post.authorName[0] : '?',
                      style: const TextStyle(
                        color: Color(0xff0f4db8),
                        fontWeight: FontWeight.bold,
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${post.cursoAutor} • ${_formatarTempo(post.createdAt)}',
                          style: const TextStyle(color: Color(0xff64748b)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (post.conteudo.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  post.conteudo,
                  style: const TextStyle(fontSize: 15.2, height: 1.4),
                ),
              ],
              if (post.mediaPath.isNotEmpty) ...[
                const SizedBox(height: 14),
                PostMediaView(
                    mediaType: post.mediaType, mediaPath: post.mediaPath),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : const Color(0xff64748b),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text('${post.curtidas} curtidas'),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _controller.curtir(post.id),
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? Colors.red : const Color(0xff1877f2),
                      ),
                      label: Text(liked ? 'Curtido' : 'Curtir'),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Comentários podem ser a próxima etapa do projeto.')),
                        );
                      },
                      icon: const Icon(Icons.mode_comment_outlined),
                      label: const Text('Comentar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
