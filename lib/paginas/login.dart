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
              margin: const EdgeInsets.only(bottom: 200), // Ajuste para centralizar melhor o formulário
              child: isMobile
                  ? _buildVerticalLayout()
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Ajustado para melhor espaçamento
                crossAxisAlignment: CrossAxisAlignment.center, // Centraliza verticalmente
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
    return SingleChildScrollView( // Adicionado para evitar overflow em telas menores
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Espaçamento superior
          _buildLogoSection(),
          const SizedBox(height: 30),
          _buildFormSection(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Espaçamento inferior
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('imagens/logo_sem_fundo.png', width: 200), // Ajuste no tamanho da imagem
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
            blurRadius: 10, // Aumentado o blur para suavizar a sombra
            offset: Offset(0, 5), // Ajustado o offset da sombra
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
              fontSize: 28, // Ajustado tamanho da fonte
              fontFamily: 'RobotoSlab', // Certifique-se que esta fonte está no pubspec.yaml se for customizada
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Entre com sua Conta!',
            style: TextStyle(
              color: Color(0xFFD4842C),
              fontSize: 18, // Ajustado tamanho da fonte
              fontFamily: 'RobotoSlab',
            ),
          ),
          const SizedBox(height: 25),
          _buildTextField(
              'Email', _emailController, TextInputType.emailAddress),
          _buildPasswordField(), // Este já tem um Padding
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logarUsuario,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4842C),
                padding: const EdgeInsets.symmetric(vertical: 15), // Aumentado o padding vertical
                shape: RoundedRectangleBorder( // Adicionado para bordas arredondadas
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
              style: const TextStyle(color: Colors.black54), // Cor ajustada para melhor leitura
              children: [
                TextSpan(
                    text: 'FAZER CADASTRO',
                    style: const TextStyle(
                      color: Color(0xFFD4842C),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline, // Adicionado sublinhado para indicar clicabilidade
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
            textAlign: TextAlign.center, // Centralizado o texto
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField( // Simplificado para usar labelText
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label, // Usando labelText
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 12), // Ajustado padding
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), // Bordas arredondadas
          focusedBorder: OutlineInputBorder( // Borda quando focado
            borderSide: const BorderSide(color: Color(0xFFD4842C), width: 2.0),
            borderRadius: BorderRadius.circular(8),
          ),
          floatingLabelStyle: const TextStyle(color: Color(0xFFD4842C)), // Cor do label quando flutuando
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
          labelText: 'Senha', // Usando labelText
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
          suffixIcon: IconButton( // Ícone para mostrar/ocultar senha
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