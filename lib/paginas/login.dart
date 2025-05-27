import 'package:firebase_auth/firebase_auth.dart'; // Importa o Firebase Auth
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:projetoflutter/paginas/pagina_inicial.dart';


import '../home.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  // Remove o _nomeController, não é usado no login
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _mostrarSenha = false;

  // Função para fazer o login
  void _logarUsuario() async {
    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();

    if (email.isNotEmpty && senha.isNotEmpty) {
      try {
        // Tenta fazer o login com email e senha
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: senha);

        // Se o login der certo, vai pra PaginaInicial
        if (userCredential.user != null) {
          Navigator.pushReplacement( // Use pushReplacement para não voltar pra tela de login
            context,
            MaterialPageRoute(builder: (context) => PaginaInicialRefatorada()),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Trata os erros de login
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
        // Trata outros erros
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocorreu um erro inesperado.')),
        );
      }
    } else {
      // Pede pra preencher tudo
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
              margin: const EdgeInsets.only(bottom: 200),
              child: isMobile
                  ? _buildVerticalLayout()
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 4, child: _buildLogoSection()),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: _buildFormSection()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogoSection(),
        const SizedBox(height: 20),
        _buildFormSection(),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('imagens/logo_sem_fundo.png', width: 250), //
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

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(30),
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
              fontSize: 30,
              fontFamily: 'RobotoSlab',
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Entre com sua Conta!',
            style: TextStyle(
              color: Color(0xFFD4842C),
              fontSize: 20,
              fontFamily: 'RobotoSlab',
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
              'Email', _emailController, TextInputType.emailAddress),
          _buildPasswordField(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
              _logarUsuario, // Chama a função _logarUsuario ao pressionar
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4842C),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Entrar',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              text: 'Não tem uma conta? ',
              children: [
                TextSpan(
                    text: 'FAZER CADASTRO',
                    style: const TextStyle(
                      color: Color(0xFFD4842C),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CadastroPage()),
                        );
                      }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: type,
            decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _senhaController,
              obscureText: !_mostrarSenha,
              decoration: const InputDecoration(
                hintText: 'Senha',
                contentPadding:
                EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFCCCCCC)),
                bottom: BorderSide(color: Color(0xFFCCCCCC)),
                right: BorderSide(color: Color(0xFFCCCCCC)),
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: IconButton(
              icon: Icon(
                _mostrarSenha ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _mostrarSenha = !_mostrarSenha;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}