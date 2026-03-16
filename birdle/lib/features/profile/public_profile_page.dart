import 'package:flutter/material.dart';

import '../../core/services/app_store.dart';
import '../../core/widgets/app_page_layout.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import 'public_profile_controller.dart';

/// Exibe o perfil público de qualquer usuário.
///
/// Recebe o [userId] via `Navigator.pushNamed` com argumento:
/// ```dart
/// Navigator.pushNamed(context, AppRoutes.publicProfile, arguments: userId);
/// ```
class PublicProfilePage extends StatefulWidget {
  const PublicProfilePage({super.key});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  final PublicProfileController _controller = PublicProfileController();
  final AppStore _store = AppStore.instance;

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

  // ── Avatar ─────────────────────────────────────────────────────────────────

  Widget _avatar(UserModel user, {double radius = 46}) {
    if (user.fotoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user.fotoUrl),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xffdbeafe),
      child: Text(
        user.nomeCompleto.isNotEmpty
            ? user.nomeCompleto[0].toUpperCase()
            : '?',
        style: TextStyle(
          color: const Color(0xff0f4db8),
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.55,
        ),
      ),
    );
  }

  // ── Métrica ────────────────────────────────────────────────────────────────

  Widget _metric(String label, String value) {
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
          label,
          style: const TextStyle(color: Color(0xff64748b), fontSize: 13),
        ),
      ],
    );
  }

  Widget _divider() => Container(
        height: 32,
        width: 1,
        color: const Color(0xffe2e8f0),
      );

  // ── Chip de tipo de perfil ─────────────────────────────────────────────────

  Widget _tipoBadge(String tipo) {
    final Map<String, _BadgeStyle> styles = {
      'admin': _BadgeStyle(
        background: const Color(0xfffef3c7),
        text: const Color(0xff92400e),
        label: 'Administrador',
        icon: Icons.shield_outlined,
      ),
      'professor': _BadgeStyle(
        background: const Color(0xffece9fe),
        text: const Color(0xff4c1d95),
        label: 'Professor',
        icon: Icons.school_outlined,
      ),
      'aluno': _BadgeStyle(
        background: const Color(0xffdbeafe),
        text: const Color(0xff1e40af),
        label: 'Aluno',
        icon: Icons.person_outline,
      ),
    };

    final style = styles[tipo] ??
        _BadgeStyle(
          background: const Color(0xfff1f5f9),
          text: const Color(0xff475569),
          label: tipo,
          icon: Icons.person_outline,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.text),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              color: style.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Card de post ───────────────────────────────────────────────────────────

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
                const Spacer(),
                Text(
                  _formatarTempo(post.createdAt),
                  style: const TextStyle(
                      color: Color(0xff94a3b8), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
    final String userId =
        ModalRoute.of(context)!.settings.arguments as String;

    final user = _controller.getUser(userId);

    // Usuário não encontrado
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: Text('Usuário não encontrado.')),
      );
    }

    final posts = _controller.postsByUser(userId);
    final isFollowing = _controller.isFollowing(userId);
    final isOwnProfile = _controller.currentUserId == userId;
    final podeInteragir = isOwnProfile ||
        !user.perfilPrivado ||
        user.seguidores.contains(_controller.currentUserId ?? '');
    final isBloqueado = _store.isBloqueado(userId);
    final hasPending = _store.hasPendingRequest(userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user.nomeCompleto,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _avatar(user),
                    const SizedBox(height: 14),
                    Text(
                      user.nomeCompleto,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0f172a),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.curso,
                      style: const TextStyle(
                          color: Color(0xff64748b), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _tipoBadge(user.tipoPerfil),
                    if (user.perfilPrivado) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xfff1f5f9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline,
                                size: 11, color: Color(0xff64748b)),
                            SizedBox(width: 3),
                            Text(
                              'Privado',
                              style: TextStyle(
                                color: Color(0xff64748b),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Métricas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _metric('Posts', '${posts.length}'),
                        _divider(),
                        _metric('Seguidores', '${user.seguidores.length}'),
                        _divider(),
                        _metric('Seguindo', '${user.seguindo.length}'),
                      ],
                    ),

                    // Botão seguir (oculto no próprio perfil e bloqueados)
                    if (!isOwnProfile && !isBloqueado) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: isFollowing
                            ? OutlinedButton.icon(
                                onPressed: () =>
                                    _controller.toggleFollow(userId),
                                icon: const Icon(Icons.person_remove_outlined),
                                label: const Text('Seguindo'),
                              )
                            : hasPending
                                ? OutlinedButton.icon(
                                    onPressed: () =>
                                        _controller.toggleFollow(userId),
                                    icon: const Icon(Icons.hourglass_top_outlined),
                                    label: const Text('Solicitado'),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () =>
                                        _controller.toggleFollow(userId),
                                    icon: const Icon(Icons.person_add_outlined),
                                    label: const Text('Seguir'),
                                  ),
                      ),
                    ],
                    if (isBloqueado) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: () => _store.desbloquear(userId),
                          icon: const Icon(Icons.block_outlined,
                              color: Colors.red),
                          label: const Text('Bloqueado',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Biografia ──────────────────────────────────────────────
            if (user.biografia.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sobre',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1877f2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.biografia,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xff334155),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Info adicional ─────────────────────────────────────────
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1877f2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (user.instagram.isNotEmpty)
                      _infoRow(Icons.alternate_email, user.instagram),
                    _infoRow(Icons.email_outlined, user.email),
                  ],
                ),
              ),
            ),

            // ── Aviso de perfil privado ────────────────────────────────
            if (user.perfilPrivado && !podeInteragir)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Icon(Icons.lock_outline,
                          color: Color(0xff94a3b8), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Este perfil é privado. Siga para poder curtir e comentar.',
                          style: TextStyle(
                            color: Color(0xff64748b),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Publicações ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                posts.isEmpty
                    ? 'Nenhuma publicação'
                    : 'Publicações (${posts.length})',
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
                      'Este usuário ainda não publicou nada.',
                      style: TextStyle(color: Color(0xff64748b)),
                    ),
                  ),
                ),
              )
            else
              ...posts.map(_buildPostCard),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xff64748b)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  color: Color(0xff334155), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Auxiliar para estilo do badge ──────────────────────────────────────────

class _BadgeStyle {
  final Color background;
  final Color text;
  final String label;
  final IconData icon;

  const _BadgeStyle({
    required this.background,
    required this.text,
    required this.label,
    required this.icon,
  });
}
