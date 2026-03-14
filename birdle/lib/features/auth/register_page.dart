import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/routes.dart';
import '../../core/services/app_store.dart';
import '../../core/utils/validators.dart';
import '../../models/user_model.dart';
import 'auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController();
  final _store = AppStore.instance;

  final _nomeController = TextEditingController();
  final _dataController = TextEditingController();
  final _cpfController = TextEditingController();
  final _instagramController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String? _cursoSelecionado;
  String? _tipoPerfil;

  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;

  String _fotoPath = "";

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    _cpfController.dispose();
    _instagramController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarFoto() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        _fotoPath = file.path;
      });
    }
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  String _formatarCPF(String value) {
    String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length > 11) {
      numbers = numbers.substring(0, 11);
    }

    String formatted = '';

    for (int i = 0; i < numbers.length; i++) {
      if (i == 3 || i == 6) formatted += '.';
      if (i == 9) formatted += '-';
      formatted += numbers[i];
    }

    return formatted;
  }

  String _formatarData(String value) {
    String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length > 8) {
      numbers = numbers.substring(0, 8);
    }

    String formatted = '';

    for (int i = 0; i < numbers.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += numbers[i];
    }

    return formatted;
  }

  void _onCpfChanged(String value) {
    final formatted = _formatarCPF(value);

    _cpfController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    if (formatted.length == 14) {
      final erro = Validators.cpf(formatted);

      if (erro != null) {
        _mostrarMensagem(erro);
      }
    }
  }

  void _onDataChanged(String value) {
    final formatted = _formatarData(value);

    _dataController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _onInstagramChanged(String value) {
    if (!value.startsWith('@') && value.isNotEmpty) {
      value = '@$value';
    }

    _instagramController.value = TextEditingValue(
      text: value.replaceAll(' ', ''),
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  Color _passwordColor() {
    final score = Validators.passwordStrength(_senhaController.text);

    if (score < 0.4) return Colors.red;
    if (score < 0.7) return Colors.amber;
    return Colors.green;
  }

  double _passwordValue() {
    return Validators.passwordStrength(_senhaController.text);
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    final user = UserModel(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      nomeCompleto: _nomeController.text.trim(),
      dataNascimento: _dataController.text,
      curso: _cursoSelecionado!,
      cpf: _cpfController.text,
      instagram: _instagramController.text,
      fotoUrl: _fotoPath,
      tipoPerfil: _tipoPerfil!,
      biografia: "",
      ativo: true,
      email: _emailController.text,
      senha: _senhaController.text,
    );

    final erro = _authController.register(user);

    if (erro != null) {
      _mostrarMensagem(erro);
      return;
    }

    _mostrarMensagem("Cadastro realizado com sucesso!");

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Widget _campoObrigatorio(String texto) {
    return RichText(
      text: TextSpan(
        text: texto,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        children: const [
          TextSpan(
            text: " *",
            style: TextStyle(color: Colors.red),
          )
        ],
      ),
    );
  }

  Widget _buildFotoPerfil() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _selecionarFoto,
            child: CircleAvatar(
              radius: 46,
              backgroundColor: const Color(0xffdbeafe),
              child: ClipOval(
                child: _fotoPath.isEmpty
                    ? const Icon(
                        Icons.add_a_photo_outlined,
                        size: 30,
                        color: Color(0xff1877f2),
                      )
                    : Image.network(
                        _fotoPath,
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.person,
                            size: 34,
                            color: Color(0xff1877f2),
                          );
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text("Adicionar foto"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cursos = _store.courses;

    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Criar conta",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildFotoPerfil(),
                    const SizedBox(height: 20),
                    _campoObrigatorio("Nome"),
                    TextFormField(
                      controller: _nomeController,
                      validator: Validators.nome,
                    ),
                    const SizedBox(height: 12),
                    _campoObrigatorio("Data de nascimento"),
                    TextFormField(
                      controller: _dataController,
                      keyboardType: TextInputType.number,
                      onChanged: _onDataChanged,
                      validator: Validators.dataNascimento,
                    ),
                    const SizedBox(height: 12),
                    _campoObrigatorio("CPF"),
                    TextFormField(
                      controller: _cpfController,
                      keyboardType: TextInputType.number,
                      onChanged: _onCpfChanged,
                      validator: Validators.cpf,
                    ),
                    const SizedBox(height: 12),
                    _campoObrigatorio("Tipo de perfil"),
                    DropdownButtonFormField<String>(
                      items: const [
                        DropdownMenuItem(
                          value: "aluno",
                          child: Text("Aluno"),
                        ),
                        DropdownMenuItem(
                          value: "professor",
                          child: Text("Professor"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _tipoPerfil = value;
                        });
                      },
                      validator: Validators.tipoPerfil,
                    ),
                    const SizedBox(height: 12),
                    _campoObrigatorio("Curso"),
                    DropdownButtonFormField<String>(
                      items: cursos
                          .map(
                            (curso) => DropdownMenuItem(
                              value: curso,
                              child: Text(curso),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _cursoSelecionado = value;
                        });
                      },
                      validator: Validators.curso,
                    ),
                    const SizedBox(height: 12),
                    const Text("Instagram"),
                    TextFormField(
                      controller: _instagramController,
                      onChanged: _onInstagramChanged,
                      validator: Validators.instagram,
                    ),
                    const SizedBox(height: 12),
                    _campoObrigatorio("E-mail"),
                    TextFormField(
                      controller: _emailController,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 12),
                    _campoObrigatorio("Senha"),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _senhaOculta,
                      onChanged: (_) => setState(() {}),
                      validator: Validators.password,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(_senhaOculta
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _senhaOculta = !_senhaOculta;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: _passwordValue(),
                      color: _passwordColor(),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    _campoObrigatorio("Confirmar senha"),
                    TextFormField(
                      controller: _confirmarSenhaController,
                      obscureText: _confirmarSenhaOculta,
                      validator: (value) => Validators.confirmPassword(
                        _senhaController.text,
                        value,
                      ),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(_confirmarSenhaOculta
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _confirmarSenhaOculta = !_confirmarSenhaOculta;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _cadastrar,
                      child: const Text("Cadastrar"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                      child: const Text("Já tenho conta"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
