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

  UserModel({
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
  });

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
    );
  }
}
