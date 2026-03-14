class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe $fieldName';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o e-mail';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  static String? cpf(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o CPF';
    }
    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length != 11) {
      return 'CPF inválido';
    }
    return null;
  }
}