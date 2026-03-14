class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe $fieldName';
    }
    return null;
  }

  static String? nome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o nome';
    }
    if (value.trim().length < 3) {
      return 'Nome muito curto';
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

  static String? confirmPassword(String? senha, String? confirmacao) {
    if (confirmacao == null || confirmacao.isEmpty) {
      return 'Confirme a senha';
    }
    if (senha != confirmacao) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  static String? dataNascimento(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe a data de nascimento';
    }

    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(value)) {
      return 'Data inválida. Use dd/mm/aaaa';
    }

    final partes = value.split('/');
    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);

    if (dia == null || mes == null || ano == null) {
      return 'Data inválida';
    }

    if (mes < 1 || mes > 12) {
      return 'Mês inválido';
    }

    if (dia < 1 || dia > 31) {
      return 'Dia inválido';
    }

    if (ano < 1900 || ano > DateTime.now().year) {
      return 'Ano inválido';
    }

    return null;
  }

  static String? instagram(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final regex = RegExp(r'^@[a-zA-Z0-9._]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Use o formato @nomedapessoa';
    }
    return null;
  }

  static String? curso(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Selecione um curso';
    }
    return null;
  }

  static String? tipoPerfil(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Selecione o tipo de perfil';
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
      return 'CPF deve ter 11 dígitos';
    }

    if (RegExp(r'^(\d)\1{10}$').hasMatch(numbers)) {
      return 'CPF inválido';
    }

    int calcDigit(String base, int factor) {
      int total = 0;
      for (int i = 0; i < base.length; i++) {
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

  static double passwordStrength(String value) {
    if (value.isEmpty) return 0;

    double score = 0;

    if (value.length >= 6) score += 0.25;
    if (value.length >= 8) score += 0.20;
    if (RegExp(r'[A-Z]').hasMatch(value)) score += 0.20;
    if (RegExp(r'[0-9]').hasMatch(value)) score += 0.20;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\]').hasMatch(value))
      score += 0.15;

    if (score > 1) score = 1;
    return score;
  }

  static String passwordStrengthLabel(String value) {
    final score = passwordStrength(value);
    if (score < 0.4) return 'Fraca';
    if (score < 0.75) return 'Média';
    return 'Forte';
  }
}
