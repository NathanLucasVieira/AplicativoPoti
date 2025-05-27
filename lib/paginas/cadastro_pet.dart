import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa o Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Importa o Auth para pegar o usuário logado
import 'cadastro_pet_peso.dart'; // <-- ADICIONE ESTA LINHA
class CadastroPetsPage extends StatefulWidget {
  const CadastroPetsPage({super.key});

  @override
  State<CadastroPetsPage> createState() => _CadastroPetsPageState();
}

class _CadastroPetsPageState extends State<CadastroPetsPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _racaController = TextEditingController();
  bool _isLoading = false; // Para mostrar um indicador de carregamento

  // Instância do Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Instância do Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função para cadastrar o pet no Firestore
  // ... (dentro de _CadastroPetsPageState em cadastro_pet.dart)

  Future<void> _cadastrarPet() async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Nenhum usuário logado.'), backgroundColor: Colors.red),
      );
      return;
    }

    String nome = _nomeController.text.trim();
    String raca = _racaController.text.trim();

    if (nome.isEmpty || raca.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha o Nome e a Raça.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // --- MODIFICAÇÃO AQUI ---
      // Usamos .add() para criar e pegamos a referência (DocumentReference)
      DocumentReference petRef = await _firestore.collection('pets').add({
        'nome': nome,
        'raca': raca,
        'tutorId': currentUser.uid,
        'fotoUrl': null,
        'criadoEm': Timestamp.now(),
        'peso': null, // Adiciona o campo peso como nulo inicialmente
      });

      // Pega o ID do documento criado
      String petId = petRef.id;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e Raça salvos! Próximo passo.'), backgroundColor: Colors.lightGreen),
      );

      // Navega para a próxima página (CadastroPetPesoPage), passando o ID
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CadastroPetPesoPage(petId: petId),
        ),
      );
      // --- FIM DA MODIFICAÇÃO ---

    } catch (e) {
      print("Erro ao cadastrar pet: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar o pet: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// ... (o resto do arquivo cadastro_pet.dart continua igual)

  // --- O restante do seu código da UI permanece quase o mesmo ---
  // --- Apenas adicionamos o _isLoading e a chamada a _cadastrarPet ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Menu Lateral (Sidebar) - Mantido como está
          Container(
            width: 250,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'imagens/logo_sem_fundo.png',
                      height: 60,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'P.O.T.I',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                const Text(
                  'Seus Pets',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {}, // Pode manter ou alterar
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9A825),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                  label: const Text(
                    'Adicionar',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
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
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: NetworkImage('https://via.placeholder.com/40'),
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Text( // Pega o email do usuário logado (ou mostra 'Usuário')
                        'Olá\n${_auth.currentUser?.email ?? 'Usuário'}',
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.exit_to_app, color: Colors.black54),
                        onPressed: () async {
                          // Lógica para Logout e ir para tela de Login
                          await _auth.signOut();
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // Ajuste a rota se necessário
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

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
                    child: Text(
                      'Olá Tutor\nSeja bem Vindo ao P.O.T.I',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Card de Cadastro
                  Container(
                    padding: const EdgeInsets.all(40.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.grey),
                              onPressed: () => Navigator.pop(context), // Ação de voltar
                            ),
                            const Text(
                              'Nome e Raça',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '1 / 2', // Mantenha ou ajuste a lógica de progresso
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(
                          value: 0.5,
                          backgroundColor: Colors.grey,
                          color: Color(0xFFF9A825),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 50),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            const CircleAvatar(
                              radius: 80,
                              backgroundImage: NetworkImage(
                                  'https://via.placeholder.com/160/FFA500/000000?Text=Pet'),
                              backgroundColor: Colors.grey,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300)
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Color(0xFFF9A825)),
                                onPressed: () {
                                  // TODO: Implementar upload/seleção de imagem
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Upload de foto ainda não implementado.')),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField('Qual é o Nome do seu pet?', 'Nome:', _nomeController),
                            ),
                            const SizedBox(width: 30),
                            Expanded(
                              child: _buildTextField('Qual é Raça do seu pet?', 'Raça:', _racaController),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () { /* TODO: Implementar próximo passo */ },
                              child: const Text(
                                'Vá para o próximo passo',
                                style: TextStyle(
                                  color: Colors.black54,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context), // Ignorar volta
                                  child: const Text(
                                    'Ignorar',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // --- BOTÃO CONFIRMAR MODIFICADO ---
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _cadastrarPet, // Chama a função e desabilita se estiver carregando
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF9A825),
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _isLoading // Mostra 'Cadastrando...' ou 'Confirmar'
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,),
                                  )
                                      : const Text(
                                    'Confirmar',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Siga nas Redes sociais'),
                        SizedBox(width: 10),
                        Icon(Icons.facebook),
                        SizedBox(width: 10),
                        Icon(Icons.camera_alt_outlined),
                        SizedBox(width: 10),
                        Icon(Icons.account_box_rounded),
                      ],
                    ),
                  )
                ],
              ),
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
      label: Text(
        title,
        style: const TextStyle(color: Colors.black54, fontSize: 16),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}