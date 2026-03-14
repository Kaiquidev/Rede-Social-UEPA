import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/user_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final cursoController = TextEditingController();
  final cpfController = TextEditingController();
  final instagramController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final biografiaController = TextEditingController();

  String tipoPerfil = 'aluno';

  @override
  void dispose() {
    nomeController.dispose();
    dataNascimentoController.dispose();
    cursoController.dispose();
    cpfController.dispose();
    instagramController.dispose();
    emailController.dispose();
    senhaController.dispose();
    biografiaController.dispose();
    super.dispose();
  }

  void salvarCadastro() {
    if (!formKey.currentState!.validate()) return;

    final user = UserModel(
      uid: '',
      nomeCompleto: nomeController.text.trim(),
      dataNascimento: dataNascimentoController.text.trim(),
      curso: cursoController.text.trim(),
      cpf: cpfController.text.trim(),
      instagram: instagramController.text.trim(),
      fotoUrl: '',
      tipoPerfil: tipoPerfil,
      biografia: biografiaController.text.trim(),
      ativo: true,
    );

    debugPrint(user.toMap().toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cadastro validado com sucesso'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: nomeController,
                label: 'Nome completo',
                validator: (value) =>
                    Validators.requiredField(value, 'o nome completo'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: dataNascimentoController,
                label: 'Data de nascimento',
                validator: (value) =>
                    Validators.requiredField(value, 'a data de nascimento'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: cursoController,
                label: 'Curso',
                validator: (value) =>
                    Validators.requiredField(value, 'o curso'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: cpfController,
                label: 'CPF',
                keyboardType: TextInputType.number,
                validator: Validators.cpf,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: instagramController,
                label: 'Link do Instagram',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: tipoPerfil,
                decoration: InputDecoration(
                  labelText: 'Tipo de perfil',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'aluno',
                    child: Text('Aluno'),
                  ),
                  DropdownMenuItem(
                    value: 'professor',
                    child: Text('Professor'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    tipoPerfil = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: biografiaController,
                label: 'Biografia',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: emailController,
                label: 'E-mail',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: senhaController,
                label: 'Senha',
                obscureText: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: salvarCadastro,
                  child: const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}