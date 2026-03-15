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

  /// Se `true`, apenas seguidores podem curtir e comentar nos posts.
  final bool perfilPrivado;

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
  });

  bool get isAdmin => tipoPerfil == 'admin';

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
    );
  }
}
