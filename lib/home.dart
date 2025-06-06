import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trabalhopoti/paginas/login.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({Key? key}) : super(key: key);

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _mostrarSenha = false;
  bool _isLoading = false;

  void _cadastrarUsuario() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Função para criar o usuário.
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);

      // Função para salvar dados no Firestore.
      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
          'nome': nome,
          'email': email,
          'criadoEm': Timestamp.now(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Tratamento de erros específicos do Firebase Auth.
      String mensagemErro;
      switch (e.code) {
        case 'email-already-in-use':
          mensagemErro = 'O e-mail já está em uso.';
          break;
        case 'weak-password':
          mensagemErro = 'A senha é muito fraca. Use pelo menos 6 caracteres.';
          break;
        case 'invalid-email':
          mensagemErro = 'E-mail inválido.';
          break;
        default:
          mensagemErro = 'Erro ao cadastrar.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErro), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Corpo da tela com scroll para evitar overflow.
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção do Logo.
            _buildLogoSection(),
            const SizedBox(height: 40),
            // Formulário de Cadastro.
            _buildFormSection(),
          ],
        ),
      ),
    );
  }

  // Widget para a seção do logo.
  Widget _buildLogoSection() {
    return Column(
      children: [
        Image.asset('imagens/logo_sem_fundo.png', width: 150),
        const SizedBox(height: 16),
        const Text(
          'P.O.T.I',
          style: TextStyle(fontSize: 24, color: Color(0xFFD4842C), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Widget para o formulário de cadastro.
  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Crie sua Conta!',
            style: TextStyle(color: Color(0xFFD4842C), fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          _buildTextField('Nome', _nomeController, TextInputType.text, Icons.person_outline),
          const SizedBox(height: 15),
          _buildTextField('Email', _emailController, TextInputType.emailAddress, Icons.email_outlined),
          const SizedBox(height: 15),
          _buildPasswordField(),
          const SizedBox(height: 25),
          _isLoading
              ? const CircularProgressIndicator(color: Color(0xFFD4842C))
              : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cadastrarUsuario,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4842C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cadastrar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              text: 'Já tem uma conta? ',
              style: const TextStyle(color: Colors.black54),
              children: [
                TextSpan(
                  text: 'FAZER LOGIN',
                  style: const TextStyle(color: Color(0xFFD4842C), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()..onTap = () => Navigator.pop(context),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget para criar um campo de texto padrão.
  Widget _buildTextField(String label, TextEditingController controller, TextInputType type, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD4842C), width: 2.0), borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Widget para criar o campo de senha.
  Widget _buildPasswordField() {
    return TextField(
      controller: _senhaController,
      obscureText: !_mostrarSenha,
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD4842C), width: 2.0), borderRadius: BorderRadius.circular(8)),
        suffixIcon: IconButton(
          icon: Icon(_mostrarSenha ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha),
        ),
      ),
    );
  }
}