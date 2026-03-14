import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/services/app_store.dart';
import 'admin_controller.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  final _controller = AdminController();
  final _store = AppStore.instance;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _store.addListener(_refresh);
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _store.currentUser;
    if (currentUser == null || !currentUser.isAdmin) {
      Future.microtask(() {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final usuarios = _controller.usuarios;
    final posts = _controller.posts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do administrador'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Usuários'), Tab(text: 'Posts')],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xfff3f5f9), Color(0xffdde3ee)],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final user = usuarios[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(user.nomeCompleto.isNotEmpty ? user.nomeCompleto[0] : '?'),
                      ),
                      title: Text(user.nomeCompleto),
                      subtitle: Text('${user.email}\n${user.curso} • ${user.tipoPerfil}'),
                      isThreeLine: true,
                      trailing: Switch(
                        value: user.ativo,
                        onChanged: user.isAdmin ? null : (_) => _controller.alternarStatusUsuario(user.uid),
                      ),
                    ),
                  ),
                );
              },
            ),
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      title: Text(post.authorName),
                      subtitle: Text(
                        '${post.conteudo.isEmpty ? '(post com mídia)' : post.conteudo}\nCurtidas: ${post.curtidas}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        onPressed: () => _controller.removerPost(post.id),
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remover post',
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
