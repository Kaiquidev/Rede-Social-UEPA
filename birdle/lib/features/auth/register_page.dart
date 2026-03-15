import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/routes.dart';
import '../../core/services/app_store.dart';
import '../../core/utils/validators.dart';
<<<<<<< HEAD
import '../../core/widgets/app_page_layout.dart';
=======
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c
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
<<<<<<< HEAD
  final _picker = ImagePicker();
=======
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c

  final _nomeController = TextEditingController();
  final _dataController = TextEditingController();
  final _cpfController = TextEditingController();
  final _instagramController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
<<<<<<< HEAD
  final _bioController = TextEditingController();

  String? _tipoPerfil = 'aluno';
  String? _cursoSelecionado;
  String _fotoPath = '';
  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;
=======

  final ImagePicker _picker = ImagePicker();

  String? _cursoSelecionado;
  String? _tipoPerfil;

  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;

  String _fotoPath = "";
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    _cpfController.dispose();
    _instagramController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
<<<<<<< HEAD
    _bioController.dispose();
    super.dispose();
  }

  // ── Máscara CPF ────────────────────────────────────────────────────────────

  void _onCpfChanged(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    String masked = '';
    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 6) masked += '.';
      if (i == 9) masked += '-';
      masked += digits[i];
    }
    if (masked != value) {
      _cpfController.value = TextEditingValue(
        text: masked,
        selection: TextSelection.collapsed(offset: masked.length),
      );
    }
  }

  // ── Máscara data ───────────────────────────────────────────────────────────

  void _onDataChanged(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    String masked = '';
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) masked += '/';
      masked += digits[i];
    }
    if (masked != value) {
      _dataController.value = TextEditingValue(
        text: masked,
        selection: TextSelection.collapsed(offset: masked.length),
      );
    }
  }

  // ── Instagram ──────────────────────────────────────────────────────────────

  void _onInstagramChanged(String value) {
    if (value.isNotEmpty && !value.startsWith('@')) {
      _instagramController.value = TextEditingValue(
        text: '@$value',
        selection: TextSelection.collapsed(offset: value.length + 1),
      );
    }
  }

  // ── Foto ───────────────────────────────────────────────────────────────────

  Future<void> _selecionarFoto() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      setState(() => _fotoPath = file.path);
    } catch (_) {}
  }

  // ── Salvar ─────────────────────────────────────────────────────────────────

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final user = UserModel(
      uid: DateTime.now().microsecondsSinceEpoch.toString(),
      nomeCompleto: _nomeController.text.trim(),
      dataNascimento: _dataController.text.trim(),
      curso: _cursoSelecionado ?? '',
      cpf: _cpfController.text.trim(),
      instagram: _instagramController.text.trim(),
      fotoUrl: _fotoPath,
      tipoPerfil: _tipoPerfil ?? 'aluno',
      biografia: _bioController.text.trim(),
      ativo: true,
      email: _emailController.text.trim(),
      senha: _senhaController.text,
=======
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
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c
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

<<<<<<< HEAD
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta criada com sucesso! Faça login.')),
    );
=======
    _mostrarMensagem("Cadastro realizado com sucesso!");
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c

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

<<<<<<< HEAD
  // ── UI auxiliar ────────────────────────────────────────────────────────────

  Widget _label(String texto, {bool obrigatorio = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: texto,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xff334155),
          ),
          children: obrigatorio
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _secao(String titulo, List<Widget> campos) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xff1877f2),
=======
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
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c
              ),
            ),
            const SizedBox(height: 14),
            ...campos,
          ],
        ),
      ),
    );
  }

  double _passwordValue() {
    final s = _senhaController.text;
    if (s.isEmpty) return 0;
    int score = 0;
    if (s.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(s)) score++;
    if (RegExp(r'[0-9]').hasMatch(s)) score++;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(s)) score++;
    return score / 4;
  }

  Color _passwordColor() {
    final v = _passwordValue();
    if (v <= 0.25) return Colors.red;
    if (v <= 0.5) return Colors.orange;
    if (v <= 0.75) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final cursos = _store.courses;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criar conta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AppPageLayout(
        scrollable: true,
        maxWidth: 600,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // ── Foto de perfil ─────────────────────────────────────────
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _selecionarFoto,
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xffdbeafe),
                          backgroundImage:
                              _fotoPath.isNotEmpty ? NetworkImage(_fotoPath) : null,
                          child: _fotoPath.isEmpty
                              ? const Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 30,
                                  color: Color(0xff1877f2),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _selecionarFoto,
                        child: const Text('Adicionar foto de perfil'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Dados pessoais ─────────────────────────────────────────
              _secao('Dados pessoais', [
                _label('Nome completo', obrigatorio: true),
                TextFormField(
                  controller: _nomeController,
                  validator: Validators.nome,
                ),
                const SizedBox(height: 14),
                _label('Data de nascimento', obrigatorio: true),
                TextFormField(
                  controller: _dataController,
                  keyboardType: TextInputType.number,
                  onChanged: _onDataChanged,
                  validator: Validators.dataNascimento,
                  decoration: const InputDecoration(hintText: 'DD/MM/AAAA'),
                ),
                const SizedBox(height: 14),
                _label('CPF', obrigatorio: true),
                TextFormField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  onChanged: _onCpfChanged,
                  validator: Validators.cpf,
                  decoration:
                      const InputDecoration(hintText: '000.000.000-00'),
                ),
              ]),

              // ── Perfil acadêmico ───────────────────────────────────────
              _secao('Perfil acadêmico', [
                _label('Tipo de perfil', obrigatorio: true),
                DropdownButtonFormField<String>(
                  value: _tipoPerfil,
                  items: const [
                    DropdownMenuItem(value: 'aluno', child: Text('Aluno')),
                    DropdownMenuItem(
                        value: 'professor', child: Text('Professor')),
                  ],
                  onChanged: (v) => setState(() => _tipoPerfil = v),
                  validator: Validators.tipoPerfil,
                ),
                const SizedBox(height: 14),
                _label('Curso', obrigatorio: true),
                DropdownButtonFormField<String>(
                  value: _cursoSelecionado,
                  hint: const Text('Selecione o curso'),
                  items: cursos
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _cursoSelecionado = v),
                  validator: Validators.curso,
                ),
                const SizedBox(height: 14),
                _label('Instagram'),
                TextFormField(
                  controller: _instagramController,
                  onChanged: _onInstagramChanged,
                  validator: Validators.instagram,
                  decoration: const InputDecoration(hintText: '@usuario'),
                ),
                const SizedBox(height: 14),
                _label('Biografia'),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Fale um pouco sobre você...',
                  ),
                ),
              ]),

              // ── Acesso ─────────────────────────────────────────────────
              _secao('Acesso', [
                _label('E-mail', obrigatorio: true),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),
                _label('Senha', obrigatorio: true),
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
                      onPressed: () =>
                          setState(() => _senhaOculta = !_senhaOculta),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: _passwordValue(),
                  color: _passwordColor(),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 14),
                _label('Confirmar senha', obrigatorio: true),
                TextFormField(
                  controller: _confirmarSenhaController,
                  obscureText: _confirmarSenhaOculta,
                  validator: (v) => Validators.confirmPassword(
                    _senhaController.text,
                    v,
                  ),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(_confirmarSenhaOculta
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => _confirmarSenhaOculta = !_confirmarSenhaOculta),
                    ),
                  ),
                ),
              ]),

              // ── Botão final ────────────────────────────────────────────
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _salvar,
                  child: const Text(
                    'Criar conta',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}
