import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projetoflutter/paginas/cadastro_pet.dart';
import 'package:projetoflutter/paginas/login.dart'; // Importe a tela de login

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  // Função auxiliar para construir itens do menu
  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isSelected = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFFF9A825) : Colors.grey.shade600,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFFF9A825) : Colors.black87,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Fecha o drawer antes de navegar ou executar ação
        onTap();
      },
      selected: isSelected,
      selectedTileColor: const Color(0xFFF9A825).withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  // Função auxiliar para o botão Adicionar
  Widget _buildAddButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.pop(context); // Fecha o drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CadastroPetsPage()),
        );
      },
      icon: Container(
        padding: const EdgeInsets.all(12), // Aumenta o padding para um círculo maior
        decoration: const BoxDecoration(
          color: Color(0xFFF9A825), // Laranja P.O.T.I
          shape: BoxShape.circle, // Torna o fundo circular
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
      label: const Text(
        'Adicionar',
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

    return Drawer(
      width: 280, // Largura do Drawer
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          // Logo e Título
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('imagens/logo_sem_fundo.png', height: 50), //
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

          // Seção "Seus Pets"
          const Text('Seus Pets', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 10),
          _buildAddButton(context), // Botão Adicionar estilizado
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 15),

          // Itens do Menu Principal
          _buildMenuItem(context, Icons.home_outlined, 'Início', () {}, isSelected: true), // Marcado como selecionado (exemplo)
          _buildMenuItem(context, Icons.pets_outlined, 'Alimentar', () {}),
          _buildMenuItem(context, Icons.history_outlined, 'Histórico', () {}),
          _buildMenuItem(context, Icons.calendar_today_outlined, 'Criar Plano', () {}),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 15),

          // Itens do Menu Secundário
          _buildMenuItem(context, Icons.person_outline, 'Meu Perfil', () {}),
          _buildMenuItem(context, Icons.settings_outlined, 'Configurações', () {}),

          // Espaçador para empurrar o perfil para baixo (opcional)
          const SizedBox(height: 80),

          // Perfil do Usuário
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF9A825).withOpacity(0.3),
              // TODO: Adicionar foto do usuário se tiver
              child: Text(user?.email?.substring(0, 1).toUpperCase() ?? 'U', style: const TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.bold)),
            ),
            title: const Text('Olá', style: TextStyle(fontSize: 12, color: Colors.grey)),
            subtitle: Text(
              user?.email ?? 'Usuário', // Mostra o email ou 'Usuário'
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.exit_to_app_outlined, color: Colors.grey),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // Navega para Login, removendo todas as telas anteriores
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()), //
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