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

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
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

  static String? postagem(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Escreva algo para publicar';
    }
    if (value.trim().length < 3) {
      return 'A publicação está muito curta';
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

    if (RegExp(r'^(\d)\1{10}$').hasMatch(numbers)) {
      return 'CPF inválido';
    }

    int calcDigit(String base, int factor) {
      var total = 0;
      for (var i = 0; i < base.length; i++) {
        total += int.parse(base[i]) * factor--;
      }
      final remainder = total % 11;
      return remainder < 2 ? 0 : 11 - remainder;
    }

    final digit1 = calcDigit(numbers.substring(0, 9), 10);
    final digit2 = calcDigit('${numbers.substring(0, 9)}$digit1', 11);

    if ('$digit1$digit2' != numbers.substring(9)) {
      return 'CPF inválido';
    }

    return null;
  }
}
