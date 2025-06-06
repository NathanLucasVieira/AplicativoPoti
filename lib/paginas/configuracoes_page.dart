// lib/paginas/configuracoes_page.dart
import 'package:flutter/material.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  bool _notificationsEnabled = true; // Example state for notification toggle

  // Placeholder method for theme change
  void _changeTheme() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de mudar tema (TODO)')),
    );
  }

  // Placeholder method for navigating to account settings
  void _navigateToAccountSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegar para configurações da conta (TODO)')),
    );
  }

  // Placeholder method for showing 'About' information
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sobre o P.O.T.I'),
          content: const Text('P.O.T.I - Alimentador Inteligente\nVersão 1.0.0\n©2024 Todos os Direitos Reservados.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar', style: TextStyle(color: Color(0xFFF9A825))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF9A825).withOpacity(0.8), size: 26),
      title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.black87), // For back button
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFAFAFA), // Light background for the page
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    subtitle: _notificationsEnabled ? 'Ativadas' : 'Desativadas',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        // Here you would add logic to save this preference
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Notificações ${value ? "ativadas" : "desativadas"}')),
                        );
                      },
                      activeColor: const Color(0xFFF9A825),
                    ),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildSettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Tema do Aplicativo',
                    subtitle: 'Claro (Padrão)', // Placeholder
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: _changeTheme,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.account_circle_outlined,
                    title: 'Conta',
                    subtitle: 'Gerenciar informações da conta',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: _navigateToAccountSettings,
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildSettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Privacidade e Segurança',
                    // subtitle: 'Alterar senha, ver atividade',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navegar para Privacidade e Segurança (TODO)')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: 'Ajuda e Suporte',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navegar para Ajuda e Suporte (TODO)')),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: 'Sobre o P.O.T.I',
                    onTap: _showAboutDialog,
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildSettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Termos de Serviço',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navegar para Termos de Serviço (TODO)')),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildSettingsTile(
                    icon: Icons.shield_outlined,
                    title: 'Política de Privacidade',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navegar para Política de Privacidade (TODO)')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              "P.O.T.I ©2024",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}