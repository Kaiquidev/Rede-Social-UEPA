import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/services/app_store.dart';
import '../../core/widgets/app_page_layout.dart';
import '../../models/user_model.dart';
import 'search_controller.dart' as sc;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final sc.SearchController _controller = sc.SearchController();
  final AppStore _store = AppStore.instance;
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _resultados = [];
  bool _buscou = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_refresh);
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {
        _resultados = _controller.buscar(_searchController.text);
      });
    }
  }

  void _buscar(String query) {
    setState(() {
      _buscou = query.trim().isNotEmpty;
      _resultados = _controller.buscar(query);
    });
  }

  void _abrirPerfil(String userId) {
    Navigator.pushNamed(
      context,
      AppRoutes.publicProfile,
      arguments: userId,
    );
  }

  // ── Badge de tipo de perfil ────────────────────────────────────────────────

  Widget _tipoBadge(String tipo) {
    final Map<String, _BadgeStyle> styles = {
      'admin': _BadgeStyle(
        background: const Color(0xfffef3c7),
        text: const Color(0xff92400e),
        label: 'Admin',
      ),
      'professor': _BadgeStyle(
        background: const Color(0xffece9fe),
        text: const Color(0xff4c1d95),
        label: 'Professor',
      ),
      'aluno': _BadgeStyle(
        background: const Color(0xffdbeafe),
        text: const Color(0xff1e40af),
        label: 'Aluno',
      ),
    };

    final style = styles[tipo] ??
        _BadgeStyle(
          background: const Color(0xfff1f5f9),
          text: const Color(0xff475569),
          label: tipo,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Card de usuário ────────────────────────────────────────────────────────

  Widget _buildUserCard(UserModel user) {
    final isFollowing = _controller.isFollowing(user.uid);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _abrirPerfil(user.uid),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              user.fotoUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(user.fotoUrl),
                    )
                  : CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xffdbeafe),
                      child: Text(
                        user.nomeCompleto.isNotEmpty
                            ? user.nomeCompleto[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Color(0xff0f4db8),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
              const SizedBox(width: 14),

              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.nomeCompleto,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xff0f172a),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _tipoBadge(user.tipoPerfil),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.curso,
                      style: const TextStyle(
                        color: Color(0xff64748b),
                        fontSize: 13,
                      ),
                    ),
                    if (user.instagram.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.instagram,
                        style: const TextStyle(
                          color: Color(0xff94a3b8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _statChip(
                            '${user.seguidores.length}', 'seguidores'),
                        const SizedBox(width: 10),
                        _statChip('${user.seguindo.length}', 'seguindo'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Botão seguir
              isFollowing
                  ? OutlinedButton(
                      onPressed: () {
                        _controller.toggleFollow(user.uid);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Seguindo'),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _controller.toggleFollow(user.uid);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Seguir'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xff0f172a),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xff64748b),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscar usuários',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AppPageLayout(
        scrollable: false,
        child: Column(
          children: [
            // ── Campo de busca ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _buscar,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome, curso ou @instagram...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _buscar('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

            // ── Resultados ─────────────────────────────────────────────
            Expanded(
              child: !_buscou
                  ? _buildEstadoInicial()
                  : _resultados.isEmpty
                      ? _buildSemResultados()
                      : ListView.builder(
                          itemCount: _resultados.length,
                          itemBuilder: (context, index) =>
                              _buildUserCard(_resultados[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoInicial() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.person_search_outlined,
              size: 64, color: Color(0xffcbd5e1)),
          SizedBox(height: 16),
          Text(
            'Busque por pessoas na UEPA',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xff64748b),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Digite um nome, curso ou @instagram para encontrar usuários.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff94a3b8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSemResultados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_outlined,
              size: 64, color: Color(0xffcbd5e1)),
          const SizedBox(height: 16),
          const Text(
            'Nenhum usuário encontrado',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xff64748b),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhum resultado para "${_searchController.text}".',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xff94a3b8), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BadgeStyle {
  final Color background;
  final Color text;
  final String label;

  const _BadgeStyle({
    required this.background,
    required this.text,
    required this.label,
  });
}
