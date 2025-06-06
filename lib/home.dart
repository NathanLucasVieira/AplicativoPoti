import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'paginas/login.dart';

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

  void _cadastrarUsuario() async {
    String nome = _nomeController.text.trim();
    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();

    if (nome.isNotEmpty && email.isNotEmpty && senha.isNotEmpty) {
      try {
        // 1. Cria o usuário no Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: senha);

        // 2. Salva dados adicionais no Firestore
        User? user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
            'nome': nome,
            'email': email,
            'criadoEm': Timestamp.now(),
          });
        }

        // 3. Navega para tela de login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } on FirebaseAuthException catch (e) {
        String mensagemErro = 'Erro ao cadastrar.';

        if (e.code == 'email-already-in-use') {
          mensagemErro = 'O e-mail já está em uso.';
        } else if (e.code == 'weak-password') {
          mensagemErro = 'A senha é muito fraca.';
        } else if (e.code == 'invalid-email') {
          mensagemErro = 'E-mail inválido.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErro)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocorreu um erro inesperado.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          return Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 1200),
              // Removed large bottom margin for mobile, relying on SingleChildScrollView and Center
              margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(bottom: 200),
              child: isMobile
                  ? _buildVerticalLayout(context)
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 4, child: _buildLogoSection()),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: _buildFormSection(isMobile: false)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0), // Added vertical padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogoSection(isMobile: true),
          const SizedBox(height: 30), // Increased spacing
          _buildFormSection(isMobile: true),
        ],
      ),
    );
  }

  Widget _buildLogoSection({bool isMobile = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'imagens/logo_sem_fundo.png',
          width: isMobile ? 180 : 250, // Smaller logo for mobile
        ),
        const SizedBox(height: 16),
        const Text(
          'P.O.T.I',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFFD4842C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection({bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 30), // Reduced padding for mobile
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Bem-vindo ao P.O.T.I',
            style: TextStyle(
              color: Color(0xFFD4842C),
              fontSize: 26, // Slightly adjusted
              fontFamily: 'RobotoSlab',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Crie sua Conta!',
            style: TextStyle(
              color: Color(0xFFD4842C),
              fontSize: 18, // Slightly adjusted
              fontFamily: 'RobotoSlab',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildTextField('Nome', _nomeController, TextInputType.text),
          _buildTextField('Email', _emailController, TextInputType.emailAddress),
          _buildPasswordField(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cadastrarUsuario,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4842C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cadastrar',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 15), // Increased spacing
          Text.rich(
            TextSpan(
              text: 'Já tem uma conta? ',
              style: const TextStyle(color: Colors.black54),
              children: [
                TextSpan(
                  text: 'FAZER LOGIN',
                  style: const TextStyle(
                    color: Color(0xFFD4842C),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFD4842C), width: 2.0),
            borderRadius: BorderRadius.circular(8),
          ),
          floatingLabelStyle: const TextStyle(color: Color(0xFFD4842C)),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: _senhaController,
        obscureText: !_mostrarSenha,
        decoration: InputDecoration(
          labelText: 'Senha',
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFD4842C), width: 2.0),
            borderRadius: BorderRadius.circular(8),
          ),
          floatingLabelStyle: const TextStyle(color: Color(0xFFD4842C)),
          suffixIcon: IconButton(
            icon: Icon(
              _mostrarSenha ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _mostrarSenha = !_mostrarSenha;
              });
            },
          ),
        ),
      ),
    );
  }
}