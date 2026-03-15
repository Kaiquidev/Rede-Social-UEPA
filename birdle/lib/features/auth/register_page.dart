import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/routes.dart';
import '../../core/services/app_store.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_page_layout.dart';
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
  final _picker = ImagePicker();

  final _nomeController = TextEditingController();
  final _dataController = TextEditingController();
  final _cpfController = TextEditingController();
  final _instagramController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _bioController = TextEditingController();

  String? _tipoPerfil = 'aluno';
  String? _cursoSelecionado;
  String _fotoPath = '';
  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    _cpfController.dispose();
    _instagramController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
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
    );

    final error = _authController.register(user);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta criada com sucesso! Faça login.')),
    );

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

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
                          backgroundImage: _fotoPath.isNotEmpty
                              ? NetworkImage(_fotoPath)
                              : null,
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
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
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
                      onPressed: () => setState(() =>
                          _confirmarSenhaOculta = !_confirmarSenhaOculta),
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

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Já tem conta? '),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login),
                    child: const Text('Fazer login'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
