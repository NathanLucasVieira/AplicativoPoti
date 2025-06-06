import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trabalhopoti/paginas/pagina_inicial.dart';
import '../home.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _mostrarSenha = false;
  bool _isLoading = false;

  void _logarUsuario() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha e-mail e senha.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Função de login.
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: senha);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PaginaInicialRefatorada()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Tratamento de erros de login.
      String mensagemErro;
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        mensagemErro = 'E-mail ou senha incorretos.';
      } else {
        mensagemErro = 'Ocorreu um erro ao fazer login.';
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
      // Corpo com scroll.
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            // Seção do Logo.
            _buildLogoSection(),
            const SizedBox(height: 40),
            // Formulário de Login.
            _buildFormSection(),
          ],
        ),
      ),
    );
  }

  // Widget da seção do logo.
  Widget _buildLogoSection() {
    return Column(
      children: [
        Image.asset('imagens/logo_sem_fundo.png', width: 150),
        const SizedBox(height: 16),
        const Text('P.O.T.I', style: TextStyle(fontSize: 24, color: Color(0xFFD4842C), fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Widget do formulário de login.
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
          const Text('Bem-vindo de volta!', style: TextStyle(color: Color(0xFFD4842C), fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 25),
          _buildTextField('Email', _emailController, TextInputType.emailAddress, Icons.email_outlined),
          const SizedBox(height: 15),
          _buildPasswordField(),
          const SizedBox(height: 25),
          _isLoading
              ? const CircularProgressIndicator(color: Color(0xFFD4842C))
              : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logarUsuario,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4842C), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Entrar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              text: 'Não tem uma conta? ',
              style: const TextStyle(color: Colors.black54),
              children: [
                TextSpan(
                  text: 'FAZER CADASTRO',
                  style: const TextStyle(color: Color(0xFFD4842C), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastroPage())),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget para campo de texto.
  Widget _buildTextField(String label, TextEditingController controller, TextInputType type, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.grey.shade600), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD4842C), width: 2.0), borderRadius: BorderRadius.circular(8))),
    );
  }

  // Widget para campo de senha.
  Widget _buildPasswordField() {
    return TextField(
      controller: _senhaController,
      obscureText: !_mostrarSenha,
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD4842C), width: 2.0), borderRadius: BorderRadius.circular(8)),
        suffixIcon: IconButton(icon: Icon(_mostrarSenha ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha)),
      ),
    );
  }
}