class UserModel {
  final String uid;
  final String nomeCompleto;
  final String dataNascimento;
  final String curso;
  final String cpf;
  final String instagram;
  final String fotoUrl;
  final String tipoPerfil;
  final String biografia;
  final bool ativo;
  final String email;
  final String senha;
  final List<String> seguidores;
  final List<String> seguindo;
  final bool perfilPrivado;

  /// UIDs bloqueados — usuários bloqueados não podem seguir nem ver posts.
  final List<String> bloqueados;

  /// UIDs com solicitação de seguimento pendente (usado quando perfil é privado).
  final List<String> solicitacoesPendentes;

  const UserModel({
    required this.uid,
    required this.nomeCompleto,
    required this.dataNascimento,
    required this.curso,
    required this.cpf,
    required this.instagram,
    required this.fotoUrl,
    required this.tipoPerfil,
    required this.biografia,
    required this.ativo,
    required this.email,
    required this.senha,
    this.seguidores = const [],
    this.seguindo = const [],
    this.perfilPrivado = false,
    this.bloqueados = const [],
    this.solicitacoesPendentes = const [],
  });

  bool get isAdmin => tipoPerfil == 'admin';

  bool isBloqueado(String uid) => bloqueados.contains(uid);
  bool temSolicitacao(String uid) => solicitacoesPendentes.contains(uid);

  UserModel copyWith({
    String? uid,
    String? nomeCompleto,
    String? dataNascimento,
    String? curso,
    String? cpf,
    String? instagram,
    String? fotoUrl,
    String? tipoPerfil,
    String? biografia,
    bool? ativo,
    String? email,
    String? senha,
    List<String>? seguidores,
    List<String>? seguindo,
    bool? perfilPrivado,
    List<String>? bloqueados,
    List<String>? solicitacoesPendentes,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      curso: curso ?? this.curso,
      cpf: cpf ?? this.cpf,
      instagram: instagram ?? this.instagram,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      tipoPerfil: tipoPerfil ?? this.tipoPerfil,
      biografia: biografia ?? this.biografia,
      ativo: ativo ?? this.ativo,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      seguidores: seguidores ?? this.seguidores,
      seguindo: seguindo ?? this.seguindo,
      perfilPrivado: perfilPrivado ?? this.perfilPrivado,
      bloqueados: bloqueados ?? this.bloqueados,
      solicitacoesPendentes:
          solicitacoesPendentes ?? this.solicitacoesPendentes,
    );
  }
}
