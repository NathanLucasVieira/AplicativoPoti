import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trabalhopoti/widgets/pet_card.dart';
import 'package:trabalhopoti/paginas/detalhes_pet_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  User? _currentUser;
  String _userName = "Carregando...";
  List<Pet> _petsCadastrados = [];
  bool _isLoading = true;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85, initialPage: 0);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      await _loadUserData();
      await _fetchUserPets();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(_currentUser!.uid).get();
      if (mounted && userDoc.exists) {
        setState(() => _userName = userDoc.data()!['nome'] ?? 'Usuário');
      } else {
        setState(() => _userName = _currentUser!.displayName ?? 'Usuário');
      }
    } catch (e) {
      if (mounted) setState(() => _userName = 'Usuário');
    }
  }

  Future<void> _fetchUserPets() async {
    try {
      final petSnapshot = await FirebaseFirestore.instance.collection('pets').where('tutorId', isEqualTo: _currentUser!.uid).get();
      if (mounted) {
        setState(() => _petsCadastrados = petSnapshot.docs.map((doc) => Pet.fromMap(doc.data(), doc.id)).toList());
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar pets: ${e.toString()}')));
    }
  }

  Future<void> _navigateToPetDetails(Pet pet) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => DetalhesPetPage(pet: pet)));
    if (result == true && mounted) _loadAllData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meu Perfil", style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.white, elevation: 1.0),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF9A825)))
          : RefreshIndicator(
        onRefresh: _loadAllData,
        color: const Color(0xFFF9A825),
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildPetsSection(),
          ],
        ),
      ),
    );
  }

  // Cabeçalho do perfil.
  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(radius: 50, backgroundColor: Colors.grey.shade300, child: Icon(Icons.person, size: 50, color: Colors.grey.shade700)),
        const SizedBox(height: 15),
        Text("Olá, $_userName", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Seção de pets.
  Widget _buildPetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text("Meus Pets", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF9A825).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Text(_petsCadastrados.length.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF9A825))),
          ),
        ]),
        const SizedBox(height: 10),
        _petsCadastrados.isEmpty
            ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Text('Nenhum pet cadastrado.', style: TextStyle(color: Colors.grey))))
            : Column(
          children: [
            SizedBox(
              height: 160.0,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _petsCadastrados.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) => GestureDetector(onTap: () => _navigateToPetDetails(_petsCadastrados[index]), child: PetCard(pet: _petsCadastrados[index], isSelected: index == _currentPage)),
              ),
            ),
            if (_petsCadastrados.length > 1) _buildPageIndicator(),
          ],
        ),
      ],
    );
  }

  // Indicador de página do carrossel.
  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_petsCadastrados.length, (i) => Container(
          width: 8.0, height: 8.0, margin: const EdgeInsets.symmetric(horizontal: 3.0),
          decoration: BoxDecoration(shape: BoxShape.circle, color: _currentPage == i ? const Color(0xFFF9A825) : Colors.grey.shade300),
        )),
      ),
    );
  }
}