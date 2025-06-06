import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trabalhopoti/paginas/pagina_inicial.dart';
import 'package:trabalhopoti/paginas/cadastro_pet.dart';
import 'package:trabalhopoti/paginas/alimentar_manual_page.dart';
import 'package:trabalhopoti/paginas/historico_alimentacao_page.dart';
import 'package:trabalhopoti/paginas/login.dart';
import 'package:trabalhopoti/paginas/cadastrar_rotina_page.dart';
import 'package:trabalhopoti/widgets/pet_card.dart';
import 'package:trabalhopoti/paginas/detalhes_pet_page.dart';
import 'package:trabalhopoti/paginas/perfil_page.dart';
import 'package:trabalhopoti/paginas/configuracoes_page.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  User? _currentUser;
  String _userDisplayName = "Usuário";
  String _userDisplayEmail = "Não autenticado";
  List<Pet> _userPets = [];
  bool _isLoadingPets = true;
  StreamSubscription<User?>? _authStateChangesSubscription;

  @override
  void initState() {
    super.initState();
    _authStateChangesSubscription = FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
    _loadInitialData();
  }

  void _onAuthStateChanged(User? user) {
    if (mounted) {
      _currentUser = user;
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    if (_currentUser != null) {
      _fetchUserDetails();
      _fetchUserPets();
    } else {
      setState(() {
        _userPets = [];
        _isLoadingPets = false;
        _userDisplayName = "Usuário";
        _userDisplayEmail = "Não autenticado";
      });
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(_currentUser!.uid).get();
      if (mounted && userDoc.exists) {
        setState(() => _userDisplayName = userDoc.data()!['nome'] ?? 'Usuário');
      }
      if (mounted) setState(() => _userDisplayEmail = _currentUser!.email ?? '');
    } catch (_) {}
  }

  Future<void> _fetchUserPets() async {
    setState(() => _isLoadingPets = true);
    try {
      final petSnapshot = await FirebaseFirestore.instance.collection('pets').where('tutorId', isEqualTo: _currentUser!.uid).get();
      if (mounted) {
        setState(() {
          _userPets = petSnapshot.docs.map((doc) => Pet.fromMap(doc.data(), doc.id)).toList();
          _isLoadingPets = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPets = false);
    }
  }

  @override
  void dispose() {
    _authStateChangesSubscription?.cancel();
    super.dispose();
  }

  void _navigateTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page)).then((_) => _loadInitialData());
  }

  void _navigateToAndRemoveUntil(Widget page) {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => page), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerHeader(),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Text("Meus Pets", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
                _buildPetList(),
                if (_currentUser != null) _buildAddButton(),
                const Divider(indent: 20, endIndent: 20),
                _buildMenuItem(Icons.home_outlined, 'Início', () => _navigateToAndRemoveUntil(const PaginaInicialRefatorada())),
                _buildMenuItem(Icons.restaurant_menu_outlined, 'Alimentar Agora', () => _navigateTo(const AlimentarManualPage())),
                _buildMenuItem(Icons.calendar_today_outlined, 'Criar Plano', () => _navigateTo(const CadastrarRotinaPage())),
                _buildMenuItem(Icons.history_outlined, 'Histórico', () => _navigateTo(const HistoricoAlimentacaoPage())),
                const Divider(indent: 20, endIndent: 20),
                _buildMenuItem(Icons.person_outline, 'Meu Perfil', () => _navigateTo(const PerfilPage())),
                _buildMenuItem(Icons.settings_outlined, 'Configurações', () => _navigateTo(const ConfiguracoesPage())),
              ],
            ),
          ),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  // Cabeçalho do Drawer.
  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      color: const Color(0xFFF9A825).withOpacity(0.05),
      child: Row(children: [
        Image.asset('imagens/logo_sem_fundo.png', height: 45),
        const SizedBox(width: 12),
        const Text('P.O.T.I', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFD4842C))),
      ]),
    );
  }

  // Lista de pets no Drawer.
  Widget _buildPetList() {
    if (_currentUser == null) return const Padding(padding: EdgeInsets.all(20), child: Text('Faça login para ver seus pets.', style: TextStyle(color: Colors.orangeAccent)));
    if (_isLoadingPets) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFFF9A825))));
    if (_userPets.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('Nenhum pet cadastrado.', style: TextStyle(color: Colors.grey)));
    return Column(children: _userPets.map((pet) => _buildPetListItem(pet)).toList());
  }

  // Rodapé do Drawer.
  Widget _buildDrawerFooter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _currentUser != null ? _buildUserFooter() : _buildLoginFooter(),
    );
  }

  // Rodapé para usuário logado.
  Widget _buildUserFooter() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF9A825).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        CircleAvatar(backgroundColor: const Color(0xFFF9A825), child: Text(_userDisplayName.isNotEmpty ? _userDisplayName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_userDisplayName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            Text(_userDisplayEmail, style: TextStyle(fontSize: 12, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis),
          ]),
        ),
        IconButton(icon: Icon(Icons.exit_to_app_outlined, color: Colors.grey.shade600), onPressed: () async { await FirebaseAuth.instance.signOut(); if (mounted) _navigateToAndRemoveUntil(const Login()); }, tooltip: 'Sair'),
      ]),
    );
  }

  // Rodapé para usuário deslogado.
  Widget _buildLoginFooter() {
    return TextButton.icon(
      icon: const Icon(Icons.login, color: Color(0xFFF9A825)),
      label: const Text('Fazer Login', style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.bold)),
      onPressed: () => _navigateToAndRemoveUntil(const Login()),
      style: TextButton.styleFrom(backgroundColor: const Color(0xFFF9A825).withOpacity(0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(double.infinity, 48)),
    );
  }

  // Item de menu padrão.
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: Colors.grey.shade700), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)), onTap: onTap);
  }

  // Botão para adicionar pet.
  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextButton.icon(
        onPressed: () => _navigateTo(const CadastroPetsPage()),
        icon: const Icon(Icons.add, color: Color(0xFFF9A825)),
        label: const Text('Adicionar Novo Pet', style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.w600)),
        style: TextButton.styleFrom(alignment: Alignment.centerLeft, backgroundColor: const Color(0xFFF9A825).withOpacity(0.05)),
      ),
    );
  }

  // Item da lista de pets.
  Widget _buildPetListItem(Pet pet) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: pet.fotoUrl != null ? NetworkImage(pet.fotoUrl!) : null,
        child: pet.fotoUrl == null ? const Icon(Icons.pets, size: 20, color: Colors.grey) : null,
      ),
      title: Text(pet.nome, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () => _navigateTo(DetalhesPetPage(pet: pet)),
    );
  }
}