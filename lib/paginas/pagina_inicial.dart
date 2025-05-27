import 'package:flutter/material.dart';
import 'cadastro_pet.dart'; // Mantenha a importação da sua página de cadastro

// Classe da Página Inicial refatorada
class PaginaInicialRefatorada extends StatefulWidget {
  const PaginaInicialRefatorada({super.key});

  @override
  State<PaginaInicialRefatorada> createState() => _PaginaInicialRefatoradaState();
}

class _PaginaInicialRefatoradaState extends State<PaginaInicialRefatorada> {
  bool _permGranted = false;
  bool _showPopup = false; // Renomeado para clareza

  // Função auxiliar para construir o menu lateral (Sidebar)
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250, // Largura padrão do sidebar
      color: Colors.white, // Fundo branco
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo e Título
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'imagens/logo_sem_fundo.png', // Mantenha seu caminho
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

          // Seção "Seus Pets" - Estilo consistente com CadastroPetsPage
          const Text(
            'Seus Pets',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CadastroPetsPage()),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9A825), // Laranja P.O.T.I
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
              alignment: Alignment.centerLeft,
            ),
          ),
          const Divider(),
          const SizedBox(height: 20),

          // Itens do Menu - Estilo consistente
          _buildMenuItem(Icons.home_outlined, 'Início', () {}),
          _buildMenuItem(Icons.pets_outlined, 'Alimentar', () {}),
          _buildMenuItem(Icons.history_outlined, 'Histórico', () {}),
          _buildMenuItem(Icons.calendar_today_outlined, 'Criar Plano', () {}),
          const Spacer(), // Empurra os itens para baixo
          const Divider(),
          _buildMenuItem(Icons.person_outline, 'Meu Perfil', () {}),
          _buildMenuItem(Icons.settings_outlined, 'Configurações', () {}),
          const SizedBox(height: 30),

          // Seção do Usuário (Placeholder)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF9A825).withOpacity(0.8),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/40'),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Olá\nUsuário', // Adapte conforme necessário
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
    );
  }

  // Função auxiliar para construir itens do menu
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
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

  // Função auxiliar para construir a área de conteúdo principal
  Widget _buildContentArea(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color(0xFFFAFAFA), // Fundo cinza claro
        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            const Text(
              'Olá Tutor\nSeja bem Vindo ao P.O.T.I',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),

            // Card "Sem Dispositivos" - Estilo consistente
            Container(
              width: 380, // Ajuste a largura conforme necessário
              height: 400, // Ajuste a altura conforme necessário
              padding: const EdgeInsets.all(30.0),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'imagens/Add_Dispositivo.png', // Mantenha seu caminho
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Sem dispositivos",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Conecte-se ao alimentador\nVia Wi-Fi",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const Spacer(), // Empurra o botão para baixo
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showPopup = true; // Mostra o popup
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Adicionar Dispositivos",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9A825), // Laranja P.O.T.I
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Bordas mais consistentes
                      ),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20), // Espaço inferior
                ],
              ),
            ),
            const Spacer(), // Empurra o rodapé (se houver) para baixo
          ],
        ),
      ),
    );
  }

  // Função auxiliar para construir o popup de adicionar dispositivo
  Widget _buildAddDevicePopup(BuildContext context) {
    return Align(
      alignment: const Alignment(0.8, 0.6), // Posição ajustada
      child: Material( // Adicionado Material para sombras e bordas corretas
        elevation: 8.0,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: 350, // Largura ajustada
          // height: 280, // Altura pode ser dinâmica
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Para se ajustar ao conteúdo
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    !_permGranted ? "Permissão Necessária" : "Cadastro de Dispositivo",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showPopup = false; // Fecha o popup
                        _permGranted = false; // Reseta a permissão ao fechar (opcional)
                      });
                    },
                    splashRadius: 20,
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 15),
              if (!_permGranted)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Precisamos da sua permissão para procurar\ndispositivos P.O.T.I próximos.", style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 25),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _permGranted = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9A825)),
                        child: const Text("Conceder Permissão", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildTextField('Nome do Dispositivo', 'Ex: Poti Cozinha', null),
                    const SizedBox(height: 15),
                    _buildTextField('ID do Dispositivo', 'Ex: POTI-123456', null),
                    const SizedBox(height: 25),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          print("Dispositivo cadastrado");
                          setState(() {
                            _showPopup = false;
                            _permGranted = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9A825)),
                        child: const Text("Cadastrar", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para criar campos de texto (como em CadastroPetsPage)
  Widget _buildTextField(String label, String hint, TextEditingController? controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14, // Menor para o popup
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF3F4F6), // Cinza bem claro
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
      ],
    );
  }


  // Função auxiliar para construir o rodapé
  Widget _buildFooter() {
    return Container(
      height: 60,
      width: double.infinity,
      color: const Color(0xFFF9A825), // Laranja P.O.T.I
      padding: const EdgeInsets.symmetric(horizontal: 50), // Alinhado com o conteúdo
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end, // Alinhado à direita
        children: [
          Text("Siga nas redes sociais", style: TextStyle(color: Colors.white)),
          SizedBox(width: 15),
          Icon(Icons.camera_alt_outlined, color: Colors.white), // Instagram
          SizedBox(width: 15),
          Icon(Icons.alternate_email_outlined, color: Colors.white), // Twitter/X
          SizedBox(width: 15),
          Icon(Icons.facebook_outlined, color: Colors.white), // Facebook
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Cor de fundo principal
      body: Stack( // Usando Stack para permitir o popup sobreposto
        children: [
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildSidebar(context), // Menu Lateral
                    _buildContentArea(context), // Conteúdo Principal
                  ],
                ),
              ),
              _buildFooter(), // Rodapé
            ],
          ),
          // Mostra o popup se _showPopup for verdadeiro
          if (_showPopup) _buildAddDevicePopup(context),
        ],
      ),
    );
  }
}