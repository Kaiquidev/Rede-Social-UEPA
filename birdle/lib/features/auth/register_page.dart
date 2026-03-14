import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nome completo'),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(labelText: 'Data de nascimento'),
              ),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Curso')),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'CPF')),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Instagram')),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'E-mail')),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Senha')),
            ],
          ),
        ),
      ),
    );
  }
}
