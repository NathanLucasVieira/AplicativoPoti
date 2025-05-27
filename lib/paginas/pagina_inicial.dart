import 'package:flutter/material.dart';
import 'package:projetoflutter/paginas/cadastro_pet.dart';
import 'package:projetoflutter/widgets/side_bar_menu.dart'; // <-- IMPORTA O NOVO DRAWER

class PaginaInicialRefatorada extends StatefulWidget {
  const PaginaInicialRefatorada({super.key});

  @override
  State<PaginaInicialRefatorada> createState() => _PaginaInicialRefatoradaState();
}

class _PaginaInicialRefatoradaState extends State<PaginaInicialRefatorada> {
  bool _permGranted = false;
  bool _showPopup = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Chave para controlar o Scaffold

  // Função para construir a área de conteúdo principal (agora é o body)
  Widget _buildContentArea(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card "Sem Dispositivos"
          Align( // Centraliza o card (ou ajuste conforme necessário)
            alignment: Alignment.center,
            child: Container(
              width: 380,
              height: 400,
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
                    'imagens/Add_Dispositivo.png', //
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text("Sem dispositivos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  const Text("Conecte-se ao alimentador\nVia Wi-Fi", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() { _showPopup = true; });
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Adicionar Dispositivos", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9A825),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const Spacer(), // Ocupa espaço se necessário
        ],
      ),
    );
  }

  // Função auxiliar para construir o popup de adicionar dispositivo (mantida)
  Widget _buildAddDevicePopup(BuildContext context) {
    // ... (Seu código _buildAddDevicePopup - mantido como está) ...
    return Align(
      alignment: const Alignment(0.8, 0.6),
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      setState(() { _showPopup = false; _permGranted = false; });
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
                        onPressed: () { setState(() { _permGranted = true; }); },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF9A825)),
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
                          setState(() { _showPopup = false; _permGranted = false; });
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF9A825)),
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

  // Widget auxiliar para criar campos de texto (mantido)
  Widget _buildTextField(String label, String hint, TextEditingController? controller) {
    // ... (Seu código _buildTextField - mantido como está) ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detecta se a tela é grande (web/tablet) ou pequena (mobile)
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      key: _scaffoldKey, // Adiciona a chave ao Scaffold
      backgroundColor: const Color(0xFFFAFAFA),
      // Mostra o AppBar apenas se NÃO for desktop (ou sempre, se preferir)
      appBar: isDesktop
          ? null // Não mostra AppBar em telas grandes
          : AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.black54), // Cor do ícone do menu
        title: Row( // Título com Logo
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('imagens/logo_sem_fundo.png', height: 30), //
            const SizedBox(width: 8),
            const Text('P.O.T.I', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      // Usa o AppDrawer que criamos
      drawer: const SideMenu(),
      body: Stack(
        children: [
          Row(
            children: [
              // Mostra o Drawer permanentemente se for desktop
              if (isDesktop) const SideMenu(),
              // Conteúdo principal agora usa Expanded
              Expanded(
                child: _buildContentArea(context),
              ),
            ],
          ),
          // Mostra o popup se _showPopup for verdadeiro (mantido)
          if (_showPopup) _buildAddDevicePopup(context),
        ],
      ),
      // Adiciona um botão flutuante para abrir o Drawer em telas grandes
      // (Se não houver AppBar) - OPCIONAL
      floatingActionButton: isDesktop ? FloatingActionButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        backgroundColor: Color(0xFFF9A825),
        child: Icon(Icons.menu, color: Colors.white),
        mini: true,
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop, // Posição do FAB
    );
  }
}