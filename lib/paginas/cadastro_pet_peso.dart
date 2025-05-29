import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Descomente se precisar verificar o usuário aqui.
import 'package:projetoflutter/paginas/pagina_inicial.dart';
import 'package:projetoflutter/widgets/side_bar_menu.dart';
import 'package:projetoflutter/widgets/app_bar_poti.dart'; // Importa o AppBarPoti

// Página para cadastrar o peso/tamanho do pet, segunda etapa do cadastro.
class CadastroPetPesoPage extends StatefulWidget {
  final String petId; // ID do pet sendo cadastrado (vindo da página anterior).

  const CadastroPetPesoPage({required this.petId, super.key});

  @override
  State<CadastroPetPesoPage> createState() => _CadastroPetPesoPageState();
}

class _CadastroPetPesoPageState extends State<CadastroPetPesoPage> {
  String? _selectedPeso; // Armazena o peso/tamanho selecionado ("Pequeno", "Médio", "Grande").
  bool _isLoading = false;   // Controla o estado de carregamento.

  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instância do Firestore.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Chave para o Scaffold.

  // Função para atualizar o peso do pet no Firestore.
  Future<void> _atualizarPeso() async {
    // Verifica se um peso foi selecionado.
    if (_selectedPeso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecione um tamanho.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Ativa o indicador de carregamento.
    });

    try {
      // Atualiza o documento do pet com o peso selecionado.
      await _firestore.collection('pets').doc(widget.petId).update({
        'peso': _selectedPeso,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pet cadastrado com sucesso!'),
            backgroundColor: Colors.green),
      );

      // Navega para a página inicial, removendo todas as rotas anteriores.
      if (mounted) { // Verifica se o widget ainda está montado.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PaginaInicialRefatorada()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("Erro ao atualizar peso: $e"); // Loga o erro.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao salvar o peso: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) { // Verifica se o widget ainda está montado.
        setState(() {
          _isLoading = false; // Desativa o indicador de carregamento.
        });
      }
    }
  }

  // Constrói um card para seleção de peso/tamanho.
  Widget _buildPesoCard(String titulo, String subtitulo, IconData icone, String valor) {
    bool isSelected = _selectedPeso == valor; // Verifica se este card é o selecionado.
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeso = valor; // Atualiza o peso selecionado.
        });
      },
      child: Container(
        width: 150, // Largura do card.
        height: 150, // Altura do card.
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF9A825).withOpacity(0.1) : const Color(0xFFF3F4F6), // Cor de fundo condicional.
          borderRadius: BorderRadius.circular(15.0), // Bordas arredondadas.
          border: Border.all(
            color: isSelected ? const Color(0xFFF9A825) : Colors.grey.shade300, // Cor da borda condicional.
            width: 2.0,
          ),
          boxShadow: isSelected ? [ // Sombra condicional.
            BoxShadow(
              color: const Color(0xFFF9A825).withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
            )
          ] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 40, color: isSelected ? const Color(0xFFF9A825) : Colors.grey.shade600),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black87 : Colors.black54,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitulo,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.black54 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Associa a chave ao Scaffold.
      backgroundColor: const Color(0xFFFAFAFA), // Cor de fundo da página.
      // Usa o AppBar reutilizável.
      appBar: AppBarPoti(
        scaffoldKey: _scaffoldKey,
        titleText: "Peso do Pet", // Título da página.
      ),
      // Define o Drawer.
      drawer: const SideMenu(),
      // Corpo da página com rolagem.
      body: SingleChildScrollView(
        child: Container( // Container para aplicar padding geral ao conteúdo do body.
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Olá Tutor\nSeja bem Vindo ao P.O.T.I',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 40),
              // Card principal para o formulário de cadastro de peso.
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 5, blurRadius: 7, offset: const Offset(0, 3))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cabeçalho do card (Voltar, Título, Passo).
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.grey),
                          onPressed: () => Navigator.pop(context), // Ação de voltar.
                        ),
                        const Column(
                          children: [
                            Text('Adicione Informações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Tamanho', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                        const Text('Passo 2 / 2', style: TextStyle(fontSize: 16, color: Colors.grey)), // Indicador de passo.
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Barra de progresso.
                    const LinearProgressIndicator(
                      value: 1.0, // Progresso completo.
                      backgroundColor: Colors.grey,
                      color: Color(0xFFF9A825),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 30),
                    // Avatar do pet.
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage('https://via.placeholder.com/120/FFA500/000000?Text=Pet'), // Imagem placeholder.
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Qual é o Tamanho do seu pet?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    // Cards de seleção de peso.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPesoCard('Pequeno', 'Abaixo 14kg', Icons.pets, 'Pequeno'),
                        _buildPesoCard('Médio', '14-25kg', Icons.pets, 'Médio'),
                        _buildPesoCard('Grande', 'Acima 25kg', Icons.pets, 'Grande'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Botões de navegação (Próximo passo, Ignorar, Confirmar).
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Como este é o passo 2/2, este botão pode ser para "Finalizar mais tarde"
                            // ou simplesmente informar que é o último passo.
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Este é o último passo do cadastro inicial.'))
                            );
                          },
                          child: const Text('Ir para o próximo passo', style: TextStyle(color: Colors.black54, decoration: TextDecoration.underline)),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                // Ação de ignorar (navega para a página inicial).
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PaginaInicialRefatorada()),
                                      (Route<dynamic> route) => false,
                                );
                              },
                              child: const Text('Ignorar', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _atualizarPeso, // Chama _atualizarPeso.
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF9A825),
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) // Indicador de carregamento.
                                  : const Text('Confirmar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), // Texto do botão.
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30), // Espaçamento inferior.
            ],
          ),
        ),
      ),
    );
  }
}