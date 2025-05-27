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
        Image.asset('imagens/logo_sem_fundo.png', width: 250),
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
            'Crie sua Conta!',
            style: TextStyle(
              color: Color(0xFFD4842C),
              fontSize: 20,
              fontFamily: 'RobotoSlab',
            ),
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
              ),
              child: const Text(
                'Cadastrar',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              text: 'Já tem uma conta? ',
              children: [
                TextSpan(
                  text: 'FAZER LOGIN',
                  style: const TextStyle(
                    color: Color(0xFFD4842C),
                    fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
