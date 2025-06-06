import 'package:flutter/material.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  bool _notificationsEnabled = true;

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre o P.O.T.I'),
        content: const Text('P.O.T.I - Alimentador Inteligente\nVersão 1.0.0'),
        actions: [TextButton(child: const Text('Fechar'), onPressed: () => Navigator.of(context).pop())],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.white, elevation: 1.0),
      backgroundColor: const Color(0xFFFAFAFA),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          // Grupo de configurações.
          _buildSettingsGroup(
            children: [
              _buildSettingsTile(icon: Icons.notifications_outlined, title: 'Notificações', subtitle: _notificationsEnabled ? 'Ativadas' : 'Desativadas', trailing: Switch(value: _notificationsEnabled, onChanged: (val) => setState(() => _notificationsEnabled = val), activeColor: const Color(0xFFF9A825))),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _buildSettingsTile(icon: Icons.palette_outlined, title: 'Tema do App', subtitle: 'Claro (Padrão)', trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
            ],
          ),
          _buildSettingsGroup(
            children: [
              _buildSettingsTile(icon: Icons.account_circle_outlined, title: 'Conta', subtitle: 'Gerenciar informações da conta', trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _buildSettingsTile(icon: Icons.lock_outline, title: 'Privacidade e Segurança', trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
            ],
          ),
          _buildSettingsGroup(
            children: [
              _buildSettingsTile(icon: Icons.help_outline, title: 'Ajuda e Suporte', trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _buildSettingsTile(icon: Icons.info_outline, title: 'Sobre o P.O.T.I', onTap: _showAboutDialog),
            ],
          ),
          const SizedBox(height: 30),
          Center(child: Text("P.O.T.I ©2024", style: TextStyle(fontSize: 12, color: Colors.grey.shade500))),
        ],
      ),
    );
  }

  // Item da lista de configurações.
  Widget _buildSettingsTile({required IconData icon, required String title, String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF9A825).withOpacity(0.8)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600)) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  // Grupo de configurações em um card.
  Widget _buildSettingsGroup({required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(children: children),
    );
  }
}