import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Importe PaginaInicialRefatorada se ainda não estiver
import 'package:projetoflutter/paginas/pagina_inicial.dart';
import 'package:projetoflutter/paginas/cadastro_pet.dart';
import 'package:projetoflutter/paginas/alimentar_manual_page.dart';
import 'package:projetoflutter/paginas/historico_alimentacao_page.dart';
import 'package:projetoflutter/paginas/login.dart'; // Para o botão Sair

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isSelected = false}) {
    // Se a lógica de 'isSelected' estava atrelada a currentRouteName e você removeu
    // as rotas nomeadas de main.dart, você precisará de outra forma para determinar
    // a seleção ou remover/simplificar essa lógica de 'isSelected'.
    // Por simplicidade, vou remover o parâmetro isSelected e seu uso aqui.
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey.shade600, // Cor padrão
        size: 26,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal, // Peso padrão
          color: Colors.black87, // Cor padrão
        ),
      ),
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        onTap();
      },
      // selected: isSelected, // Removido para simplificar
      // selectedTileColor: const Color(0xFFF9A825).withOpacity(0.1), // Removido
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CadastroPetsPage()),
        );
      },
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFFF9A825),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
      label: const Text(
        'Adicionar Pet',
        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // final String? currentRouteName = ModalRoute.of(context)?.settings.name; // Removido

    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('imagens/logo_sem_fundo.png', height: 50),
                const SizedBox(width: 10),
                const Text(
                  'P.O.T.I',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Text('Seus Pets', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 10),
          _buildAddButton(context),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 15),

          _buildMenuItem(context, Icons.home_outlined, 'Início', () {
            // Navega para PaginaInicialRefatorada e remove todas as rotas anteriores
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const PaginaInicialRefatorada()),
                  (Route<dynamic> route) => false,
            );
          }),

          _buildMenuItem(context, Icons.restaurant_menu_outlined, 'Alimentar', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AlimentarManualPage()),
            );
          }),

          _buildMenuItem(context, Icons.history_outlined, 'Histórico', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoricoAlimentacaoPage()),
            );
          }),

          _buildMenuItem(context, Icons.calendar_today_outlined, 'Criar Plano', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navegar para Criar Plano (TODO)')),
            );
          }),

          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 15),
          _buildMenuItem(context, Icons.person_outline, 'Meu Perfil', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navegar para Meu Perfil (TODO)')),
            );
          }),
          _buildMenuItem(context, Icons.settings_outlined, 'Configurações', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navegar para Configurações (TODO)')),
            );
          }),
          const SizedBox(height: 80),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF9A825).withOpacity(0.3),
              child: Text(
                  user?.displayName?.substring(0, 1).toUpperCase() ?? user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.bold)
              ),
            ),
            title: Text(user?.displayName ?? 'Olá', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            subtitle: Text(
              user?.email ?? 'Usuário',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.exit_to_app_outlined, color: Colors.grey),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()), // Leva para a tela de Login
                      (Route<dynamic> route) => false,
                );
              },
              tooltip: 'Sair',
            ),
            tileColor: const Color(0xFFF9A825).withOpacity(0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ],
      ),
    );
  }
}