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
  final AdminController _controller = AdminController();
  final AppStore _store = AppStore.instance;

  final TextEditingController _novoCursoController = TextEditingController();

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _store.addListener(_refresh);
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    _tabController.dispose();
    _novoCursoController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  void _adicionarCurso() {
    final nome = _novoCursoController.text.trim();

    if (nome.isEmpty) {
      _mostrarMensagem('Digite o nome do curso.');
      return;
    }

    final cursosExistentes =
        _controller.cursos.map((e) => e.toLowerCase().trim()).toList();

    if (cursosExistentes.contains(nome.toLowerCase())) {
      _mostrarMensagem('Esse curso já existe.');
      return;
    }

    _controller.adicionarCurso(nome);
    _novoCursoController.clear();
    _mostrarMensagem('Curso adicionado com sucesso.');
  }

  void _abrirEditarCurso(String cursoAtual) {
    final TextEditingController editarController =
        TextEditingController(text: cursoAtual);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar curso'),
          content: TextField(
            controller: editarController,
            decoration: const InputDecoration(
              hintText: 'Novo nome do curso',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final novoNome = editarController.text.trim();

                if (novoNome.isEmpty) {
                  _mostrarMensagem('Digite o nome do curso.');
                  return;
                }

                final cursosExistentes = _controller.cursos
                    .where((c) => c != cursoAtual)
                    .map((e) => e.toLowerCase().trim())
                    .toList();

                if (cursosExistentes.contains(novoNome.toLowerCase())) {
                  _mostrarMensagem('Já existe um curso com esse nome.');
                  return;
                }

                _controller.editarCurso(cursoAtual, novoNome);
                Navigator.pop(context);
                _mostrarMensagem('Curso atualizado com sucesso.');
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmarExcluirCurso(String curso) {
    final usuariosComCurso =
        _controller.usuarios.where((user) => user.curso == curso).length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir curso'),
          content: Text(
            usuariosComCurso > 0
                ? 'Existem $usuariosComCurso usuário(s) vinculados a esse curso. Deseja excluir mesmo assim?'
                : 'Deseja realmente excluir o curso "$curso"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _controller.excluirCurso(curso);
                Navigator.pop(context);
                _mostrarMensagem('Curso excluído com sucesso.');
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _store.currentUser;

    if (currentUser == null || !currentUser.isAdmin) {
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

    final usuarios = _controller.usuarios;
    final posts = _controller.posts;
    final cursos = _controller.cursos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do administrador'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Usuários'),
            Tab(text: 'Posts'),
            Tab(text: 'Cursos'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xfff3f5f9),
              Color(0xffdde3ee),
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildUsuariosTab(usuarios),
            _buildPostsTab(posts),
            _buildCursosTab(cursos),
          ],
        ),
      ),
    );
  }

  Widget _buildUsuariosTab(usuarios) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: usuarios.length,
      itemBuilder: (context, index) {
        final user = usuarios[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  user.nomeCompleto.isNotEmpty ? user.nomeCompleto[0] : '?',
                ),
              ),
              title: Text(user.nomeCompleto),
              subtitle: Text(
                '${user.email}\n${user.curso} • ${user.tipoPerfil}',
              ),
              isThreeLine: true,
              trailing: Switch(
                value: user.ativo,
                onChanged: user.isAdmin
                    ? null
                    : (_) => _controller.alternarStatusUsuario(user.uid),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsTab(posts) {
    return ListView.builder(
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
    );
  }

  Widget _buildCursosTab(List<String> cursos) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gerenciar cursos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _novoCursoController,
                  decoration: const InputDecoration(
                    hintText: 'Digite o nome do novo curso',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _adicionarCurso,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar curso'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (cursos.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('Nenhum curso cadastrado.'),
              ),
            ),
          )
        else
          ...cursos.map(
            (curso) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.school_outlined),
                  ),
                  title: Text(curso),
                  subtitle: Text(
                    '${_controller.usuarios.where((u) => u.curso == curso).length} usuário(s) vinculados',
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        onPressed: () => _abrirEditarCurso(curso),
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar curso',
                      ),
                      IconButton(
                        onPressed: () => _confirmarExcluirCurso(curso),
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Excluir curso',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
