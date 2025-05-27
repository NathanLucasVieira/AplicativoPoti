import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projetoflutter/paginas/pagina_inicial.dart'; // Para voltar para a inicial

class CadastroPetPesoPage extends StatefulWidget {
  final String petId; // Recebe o ID do pet da página anterior

  const CadastroPetPesoPage({required this.petId, super.key});

  @override
  State<CadastroPetPesoPage> createState() => _CadastroPetPesoPageState();
}

class _CadastroPetPesoPageState extends State<CadastroPetPesoPage> {
  String? _selectedPeso; // Para armazenar a seleção: "Pequeno", "Médio", "Grande"
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função para atualizar o peso no Firestore
  Future<void> _atualizarPeso() async {
    if (_selectedPeso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecione um tamanho.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Atualiza o documento existente usando o ID recebido
      await _firestore.collection('pets').doc(widget.petId).update({
        'peso': _selectedPeso, // Atualiza apenas o campo 'peso'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pet cadastrado com sucesso!'),
            backgroundColor: Colors.green),
      );

      // Navega para a Página Inicial (ou para onde desejar) após sucesso
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PaginaInicialRefatorada()),
            (Route<dynamic> route) => false, // Remove todas as rotas anteriores
      );

    } catch (e) {
      print("Erro ao atualizar peso: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao salvar o peso: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Widget auxiliar para os cards de seleção de peso
  Widget _buildPesoCard(String titulo, String subtitulo, IconData icone, String valor) {
    bool isSelected = _selectedPeso == valor;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeso = valor;
        });
      },
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF9A825).withOpacity(0.1) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: isSelected ? const Color(0xFFF9A825) : Colors.grey.shade300,
            width: 2.0,
          ),
          boxShadow: isSelected ? [
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

  // --- O Sidebar é idêntico ao anterior, pode ser reutilizado ---
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('imagens/logo_sem_fundo.png', height: 60),
              const SizedBox(width: 5),
              const Text('P.O.T.I', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 50),
          const Text('Seus Pets', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () { /* Navegar para cadastro_pet? */ },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFFF9A825), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            label: const Text('Adicionar', style: TextStyle(color: Colors.black, fontSize: 16)),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
          ),
          const Divider(),
          const SizedBox(height: 20),
          _buildMenuItem(Icons.home_outlined, 'Início'),
          _buildMenuItem(Icons.monitor_heart_outlined, 'Monitorar'),
          _buildMenuItem(Icons.restaurant_menu_outlined, 'Próximas Refeições'),
          const Spacer(),
          const Divider(),
          _buildMenuItem(Icons.person_outline, 'Meu Perfil'),
          _buildMenuItem(Icons.settings_outlined, 'Configurações'),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF9A825).withOpacity(0.8),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const CircleAvatar(
                    backgroundImage: NetworkImage('https://via.placeholder.com/40'), radius: 20),
                const SizedBox(width: 10),
                Text('Olá\n${_auth.currentUser?.email ?? 'Usuário'}', style: const TextStyle(color: Colors.black, fontSize: 14)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.exit_to_app, color: Colors.black54), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.grey, size: 20),
      label: Text(title, style: const TextStyle(color: Colors.black54, fontSize: 16)),
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), alignment: Alignment.centerLeft),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          _buildSidebar(context), // Reutiliza o sidebar
          // Conteúdo Principal
          Expanded(
            child: Container(
              color: const Color(0xFFFAFAFA),
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Olá Tutor\nSeja bem Vindo ao P.O.T.I', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                  const SizedBox(height: 40),
                  // Card de Cadastro
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.grey),
                              onPressed: () => Navigator.pop(context), // Volta para a página de nome/raça
                            ),
                            const Column(
                              children: [
                                Text('Adicione Informações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('Tamanho', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                            const Text('Passo 2 / 2', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(
                          value: 1.0, // Barra completa
                          backgroundColor: Colors.grey,
                          color: Color(0xFFF9A825),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 30),
                        const CircleAvatar( // Avatar menor
                          radius: 60,
                          backgroundImage: NetworkImage('https://via.placeholder.com/120/FFA500/000000?Text=Pet'),
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Qual é o Tamanho do seu pet?',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        // Seleção de Peso
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPesoCard('Pequeno', 'Abaixo 14kg', Icons.pets, 'Pequeno'), // Use ícones melhores se tiver
                            _buildPesoCard('Médio', '14-25kg', Icons.pets, 'Médio'),
                            _buildPesoCard('Grande', 'Acima 25kg', Icons.pets, 'Grande'), // Ícones placeholder
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Botões de Navegação
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {}, // Ação para próximo passo (ou apenas texto)
                              child: const Text('Ir para o próximo passo', style: TextStyle(color: Colors.black54, decoration: TextDecoration.underline)),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () { // Ignorar vai direto para a home
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
                                  onPressed: _isLoading ? null : _atualizarPeso,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF9A825),
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Confirmar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Ícones placeholder - idealmente, use ícones personalizados ou do font_awesome_flutter
extension CustomIcons on Icons {
  static const IconData small_dog = Icons.pets;
  static const IconData medium_dog = Icons.pets;
  static const IconData big_dog = Icons.pets;
}