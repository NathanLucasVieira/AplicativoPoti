import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projetoflutter/paginas/cadastro_pet.dart';
import 'package:projetoflutter/paginas/login.dart';

class SideMenu extends StatelessWidget { // Revertido para StatelessWidget
  const SideMenu({super.key});

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
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        onTap();
      },
      selected: isSelected,
      selectedTileColor: const Color(0xFFF9A825).withOpacity(0.1),
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
          // Removida a seção que exibia a lista de pets com avatares
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 15),

          _buildMenuItem(context, Icons.home_outlined, 'Início', () {
            // Lógica para determinar se a página atual é a inicial
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute == '/' || currentRoute == '/pagina_inicial') { // Ajuste os nomes das rotas conforme necessário
              // Já está na página inicial, não faz nada ou apenas fecha o drawer
            } else {
              // Navega para a página inicial (se PaginaInicialRefatorada for sua home route)
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          }, isSelected: ModalRoute.of(context)?.settings.name == '/' || ModalRoute.of(context)?.settings.name == '/pagina_inicial'),
          _buildMenuItem(context, Icons.pets_outlined, 'Alimentar', () {
            // TODO: Implementar navegação
          }),
          _buildMenuItem(context, Icons.history_outlined, 'Histórico', () {
            // TODO: Implementar navegação
          }),
          _buildMenuItem(context, Icons.calendar_today_outlined, 'Criar Plano', () {
            // TODO: Implementar navegação
          }),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 15),
          _buildMenuItem(context, Icons.person_outline, 'Meu Perfil', () {
            // TODO: Implementar navegação
          }),
          _buildMenuItem(context, Icons.settings_outlined, 'Configurações', () {
            // TODO: Implementar navegação
          }),
          const SizedBox(height: 80),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF9A825).withOpacity(0.3),
              child: Text(user?.email?.substring(0, 1).toUpperCase() ?? 'U', style: const TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.bold)),
            ),
            title: const Text('Olá', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                  MaterialPageRoute(builder: (context) => const Login()),
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