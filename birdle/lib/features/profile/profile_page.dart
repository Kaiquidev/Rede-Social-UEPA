import 'package:flutter/material.dart';

import '../../core/services/app_store.dart';
import '../../core/widgets/post_media_view.dart';
import 'profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _controller = ProfileController();
  final _store = AppStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_refresh);
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = _controller.usuario;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Nenhum usuário logado.')));
    }

    final posts = _controller.minhasPostagens;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
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
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xffdbeafe),
                          child: Text(
                            user.nomeCompleto.isNotEmpty ? user.nomeCompleto[0] : 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              color: Color(0xff0f4db8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.nomeCompleto,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('${user.curso} • ${user.tipoPerfil}'),
                        const SizedBox(height: 8),
                        Text(user.email),
                        const SizedBox(height: 8),
                        Text(
                          user.biografia.isEmpty ? 'Sem biografia cadastrada.' : user.biografia,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            Chip(label: Text('CPF: ${user.cpf}')),
                            Chip(
                              label: Text(
                                'Instagram: ${user.instagram.isEmpty ? 'Não informado' : user.instagram}',
                              ),
                            ),
                            Chip(label: Text('Posts: ${posts.length}')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Minhas publicações',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (posts.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Você ainda não publicou nada.'),
                    ),
                  ),
                ...posts.map(
                  (post) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.conteudo.trim().isNotEmpty) Text(post.conteudo),
                            if (post.mediaPath.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              PostMediaView(mediaType: post.mediaType, mediaPath: post.mediaPath),
                            ],
                            const SizedBox(height: 10),
                            Text('Curtidas: ${post.curtidas}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
