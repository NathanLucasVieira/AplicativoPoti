import 'package:flutter/material.dart';

class CadastroPetsPage extends StatefulWidget {
  const CadastroPetsPage({super.key});

  @override
  State<CadastroPetsPage> createState() => _CadastroPetsPageState();
}

class _CadastroPetsPageState extends State<CadastroPetsPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _racaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo principal da página
      body: Row(
        children: [
          // Menu Lateral (Sidebar) - Simplificado para o exemplo
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
                      'imagens/logo_sem_fundo.png', // **Certifique-se de ter o logo em assets**
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
                  onPressed: () {},
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9A825), // Laranja
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
                const Spacer(), // Empurra os itens para baixo
                const Divider(),
                _buildMenuItem(Icons.person_outline, 'Meu Perfil'),
                _buildMenuItem(Icons.settings_outlined, 'Configurações'),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF9A825).withOpacity(0.8), // Laranja mais claro
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: NetworkImage('https://via.placeholder.com/40'), // **Substitua pela imagem do usuário**
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Olá\nMarcos',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.exit_to_app, color: Colors.black54),
                        onPressed: () {},
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
              color: const Color(0xFFFAFAFA), // Fundo cinza claro
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho P.O.T.I
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
                      mainAxisSize: MainAxisSize.min, // Para o Card se ajustar
                      children: [
                        // Header do Card (Voltar, Título, Progresso)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.grey),
                              onPressed: () {
                                // Ação de voltar
                                Navigator.pop(context);
                              },
                            ),
                            const Text(
                              'Nome e Raça',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '1 / 2',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Barra de Progresso
                        const LinearProgressIndicator(
                          value: 0.5,
                          backgroundColor: Colors.grey,
                          color: Color(0xFFF9A825), // Laranja
                          minHeight: 6,
                        ),
                        const SizedBox(height: 50),

                        // Avatar / Imagem do Pet
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            const CircleAvatar(
                              radius: 80,
                              backgroundImage: NetworkImage(
                                  'https://via.placeholder.com/160/FFA500/000000?Text=Pet'), // **Substitua pela imagem do pet ou placeholder**
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
                                  // Ação para escolher/tirar foto
                                },
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Campos de Texto
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

                        // Botões de Navegação
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Ação para próximo passo (ou apenas texto)
                              },
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
                                  onPressed: () {
                                    // Ação de ignorar
                                  },
                                  child: const Text(
                                    'Ignorar',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    // Ação de confirmar
                                    final nome = _nomeController.text;
                                    final raca = _racaController.text;
                                    print('Nome: $nome, Raça: $raca');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF9A825), // Laranja
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(), // Empurra o footer para baixo
                  // Footer (Redes Sociais)
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Siga nas Redes sociais'),
                        SizedBox(width: 10),
                        Icon(Icons.facebook), // **Use ícones de redes sociais reais (ex: font_awesome_flutter)**
                        SizedBox(width: 10),
                        Icon(Icons.camera_alt_outlined), // Instagram placeholder
                        SizedBox(width: 10),
                        Icon(Icons.account_box_rounded), // Twitter placeholder
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

  // Widget auxiliar para criar itens do menu lateral
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

  // Widget auxiliar para criar campos de texto
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
            fillColor: const Color(0xFFF3F4F6), // Cinza bem claro
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none, // Sem borda visível
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}