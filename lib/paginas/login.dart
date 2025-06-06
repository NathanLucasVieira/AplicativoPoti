import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// Importe a PaginaInicialRefatorada para navegação direta
import 'package:projetoflutter/paginas/pagina_inicial.dart';
import '../home.dart'; // Para CadastroPage (link "FAZER CADASTRO")

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _mostrarSenha = false;

  void _logarUsuario() async {
    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();

    if (email.isNotEmpty && senha.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: senha);

        if (userCredential.user != null) {
          // Alterado de volta para MaterialPageRoute para evitar problemas com rotas nomeadas não configuradas
          // Isso garante que vá para PaginaInicialRefatorada.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PaginaInicialRefatorada()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String mensagemErro = 'Erro ao fazer login.';
        if (e.code == 'user-not-found') {
          mensagemErro = 'Nenhum usuário encontrado com este e-mail.';
        } else if (e.code == 'wrong-password') {
          mensagemErro = 'Senha incorreta.';
        } else if (e.code == 'invalid-email') {
          mensagemErro = 'O formato do e-mail é inválido.';
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
        const SnackBar(content: Text('Por favor, preencha e-mail e senha.')),
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
              // Removed large bottom margin for mobile
              margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(bottom: 200),
              child: isMobile
                  ? _buildVerticalLayout(context)
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    // Added SingleChildScrollView for mobile
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Consider adding SizedBox(height: MediaQuery.of(context).size.height * 0.05) if needed
          _buildLogoSection(isMobile: true),
          const SizedBox(height: 30),
          _buildFormSection(isMobile: true),
          // Consider adding SizedBox(height: MediaQuery.of(context).size.height * 0.05) if needed
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
          width: isMobile ? 180 : 200, // Adjusted size for mobile
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
      padding: EdgeInsets.all(isMobile ? 20 : 30), // Adjusted padding for mobile
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
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
              fontSize: 26, // Adjusted
              fontFamily: 'RobotoSlab',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Entre com sua Conta!',
            style: TextStyle(
              color: Color(0xFFD4842C),
              fontSize: 18, // Adjusted
              fontFamily: 'RobotoSlab',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          _buildTextField(
              'Email', _emailController, TextInputType.emailAddress),
          _buildPasswordField(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logarUsuario,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4842C),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Entrar',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text.rich(
            TextSpan(
              text: 'Não tem uma conta? ',
              style: const TextStyle(color: Colors.black54),
              children: [
                TextSpan(
                    text: 'FAZER CADASTRO',
                    style: const TextStyle(
                      color: Color(0xFFD4842C),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CadastroPage()),
                        );
                      }),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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