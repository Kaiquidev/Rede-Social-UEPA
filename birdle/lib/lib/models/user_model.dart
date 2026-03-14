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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nomeCompleto': nomeCompleto,
      'dataNascimento': dataNascimento,
      'curso': curso,
      'cpf': cpf,
      'instagram': instagram,
      'fotoUrl': fotoUrl,
      'tipoPerfil': tipoPerfil,
      'biografia': biografia,
      'ativo': ativo,
      'email': email,
      'senha': senha,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nomeCompleto: map['nomeCompleto'] ?? '',
      dataNascimento: map['dataNascimento'] ?? '',
      curso: map['curso'] ?? '',
      cpf: map['cpf'] ?? '',
      instagram: map['instagram'] ?? '',
      fotoUrl: map['fotoUrl'] ?? '',
      tipoPerfil: map['tipoPerfil'] ?? 'aluno',
      biografia: map['biografia'] ?? '',
      ativo: map['ativo'] ?? true,
      email: map['email'] ?? '',
      senha: map['senha'] ?? '',
    );
  }
}
