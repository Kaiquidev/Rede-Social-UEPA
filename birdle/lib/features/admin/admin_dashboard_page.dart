import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/services/app_store.dart';
import '../../core/widgets/app_page_layout.dart';
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

  void _snack(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  // ── Cursos ─────────────────────────────────────────────────────────────────

  void _adicionarCurso() {
    final nome = _novoCursoController.text.trim();
    if (nome.isEmpty) {
      _snack('Digite o nome do curso.');
      return;
    }
    if (_controller.cursos
        .map((e) => e.toLowerCase())
        .contains(nome.toLowerCase())) {
      _snack('Esse curso já existe.');
      return;
    }
    _controller.adicionarCurso(nome);
    _novoCursoController.clear();
    _snack('Curso adicionado com sucesso.');
  }

  void _abrirEditarCurso(String cursoAtual) {
    final editCtrl = TextEditingController(text: cursoAtual);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar curso'),
        content: TextField(
          controller: editCtrl,
          decoration: const InputDecoration(hintText: 'Novo nome do curso'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final novo = editCtrl.text.trim();
              if (novo.isEmpty) {
                _snack('Digite o nome do curso.');
                return;
              }
              if (_controller.cursos
                  .where((c) => c != cursoAtual)
                  .map((e) => e.toLowerCase())
                  .contains(novo.toLowerCase())) {
                _snack('Já existe um curso com esse nome.');
                return;
              }
              _controller.editarCurso(cursoAtual, novo);
              Navigator.pop(context);
              _snack('Curso atualizado.');
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmarExcluirCurso(String curso) {
    final usuariosComCurso =
        _store.users.where((u) => u.curso == curso).length;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir curso'),
        content: Text(
          usuariosComCurso > 0
              ? 'Existem $usuariosComCurso usuário(s) vinculados. Deseja excluir mesmo assim?'
              : 'Deseja excluir o curso "$curso"?',
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
              _snack('Curso excluído.');
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currentUser = _store.currentUser;

    if (currentUser == null || !currentUser.isAdmin) {
      Future.microtask(() => Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (_) => false));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Painel do administrador',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Usuários'),
            Tab(text: 'Posts'),
            Tab(text: 'Cursos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsuariosTab(),
          _buildPostsTab(),
          _buildCursosTab(),
        ],
      ),
    );
  }

  // ── Aba Usuários ───────────────────────────────────────────────────────────

  Widget _buildUsuariosTab() {
    final usuarios = _controller.usuarios;
    return AppPageLayout(
      scrollable: true,
      child: Column(
        children: [
          const SizedBox(height: 4),
          ...usuarios.map(
            (user) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xffdbeafe),
                  child: Text(
                    user.nomeCompleto.isNotEmpty
                        ? user.nomeCompleto[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Color(0xff1877f2)),
                  ),
                ),
                title: Text(user.nomeCompleto),
                subtitle: Text(
                  '${user.email}\n${user.curso} · ${user.tipoPerfil}',
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
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Aba Posts ──────────────────────────────────────────────────────────────

  Widget _buildPostsTab() {
    final posts = _controller.posts;
    if (posts.isEmpty) {
      return AppPageLayout(
        child: const Center(
          child: Text(
            'Nenhuma publicação ainda.',
            style: TextStyle(color: Color(0xff64748b)),
          ),
        ),
      );
    }
    return AppPageLayout(
      scrollable: true,
      child: Column(
        children: [
          const SizedBox(height: 4),
          ...posts.map(
            (post) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(post.authorName),
                subtitle: Text(
                  post.conteudo.isEmpty ? '(post com mídia)' : post.conteudo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('${post.curtidas}'),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _controller.removerPost(post.id),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Remover post',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Aba Cursos ─────────────────────────────────────────────────────────────

  Widget _buildCursosTab() {
    final cursos = _controller.cursos;
    return AppPageLayout(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Adicionar curso
          Card(
            margin: const EdgeInsets.only(bottom: 16, top: 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Adicionar curso',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1877f2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _novoCursoController,
                    decoration: const InputDecoration(
                      hintText: 'Nome do novo curso',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: _adicionarCurso,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de cursos
          if (cursos.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Nenhum curso cadastrado.',
                    style: TextStyle(color: Color(0xff64748b)),
                  ),
                ),
              ),
            )
          else
            ...cursos.map(
              (curso) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(curso),
                  subtitle: Text(
                    '${_store.users.where((u) => u.curso == curso).length} usuário(s)',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar',
                        onPressed: () => _abrirEditarCurso(curso),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Excluir',
                        onPressed: () => _confirmarExcluirCurso(curso),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
