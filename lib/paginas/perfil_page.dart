import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetoflutter/widgets/pet_card.dart';


class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  String _userName = "Usuário";
  String? _userProfileImageUrl; 
  List<Pet> _petsCadastrados = [];
  bool _isLoadingPets = true;
  bool _isLoadingUser = true;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85, initialPage: 0);
    _loadUserData();
    _fetchUserPets();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUser = true;
    });
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(_currentUser!.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          _userName = data['nome'] ?? _currentUser!.displayName ?? _currentUser!.email?.split('@')[0] ?? "Usuário";
          if (data.containsKey('profileImageUrl')) {
            _userProfileImageUrl = data['profileImageUrl'];
          }
        } else {
          _userName = _currentUser!.displayName ?? _currentUser!.email?.split('@')[0] ?? "Usuário";
        }
      } catch (e) {
        _userName = _currentUser!.displayName ?? _currentUser!.email?.split('@')[0] ?? "Usuário";
      
        print("Error fetching user data from Firestore: $e");
      }
    }
    setState(() {
      _isLoadingUser = false;
    });
  }

  Future<void> _fetchUserPets() async {
    setState(() {
      _isLoadingPets = true;
    });
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        QuerySnapshot petSnapshot = await _firestore
            .collection('pets')
            .where('tutorId', isEqualTo: currentUser.uid)
            .get();

        List<Pet> pets = petSnapshot.docs.map((doc) {
          return Pet.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        if (mounted) {
          setState(() {
            _petsCadastrados = pets;
            _isLoadingPets = false;
            _currentPage = _petsCadastrados.isNotEmpty ? 0 : 0;
            if (_pageController.hasClients && _petsCadastrados.isNotEmpty) {
              _pageController.jumpToPage(0);
            } else if (_petsCadastrados.isEmpty) {
              _currentPage = 0;
            }
          });
        }
      } catch (e) {
        print("Erro ao buscar pets: $e");
        if (mounted) {
          setState(() {
            _isLoadingPets = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar os pets: ${e.toString()}')),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingPets = false;
          _petsCadastrados = [];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de trocar imagem (TODO)')),
    );
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPetCarousel() {
    if (_isLoadingPets) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFF9A825)));
    }
    if (_petsCadastrados.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            'Nenhum pet cadastrado.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    const double carouselHeight = 160.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _petsCadastrados.length > 1
            ? IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey.shade600, size: 20),
          onPressed: () {
            if (_pageController.hasClients) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutSine,
              );
            }
          },
        )
            : const SizedBox(width: 48),
        Expanded(
          child: SizedBox(
            height: carouselHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _petsCadastrados.length,
              onPageChanged: (int page) {
                if (mounted) {
                  setState(() {
                    _currentPage = page;
                  });
                }
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                  child: PetCard(
                    pet: _petsCadastrados[index],
                    isSelected: index == _currentPage,
                  ),
                );
              },
            ),
          ),
        ),
        _petsCadastrados.length > 1
            ? IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600, size: 20),
          onPressed: () {
            if (_pageController.hasClients) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutSine,
              );
            }
          },
        )
            : const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildPageIndicator() {
    if (_petsCadastrados.length <= 1) return const SizedBox(height: 20);

    List<Widget> indicators = [];
    for (int i = 0; i < _petsCadastrados.length; i++) {
      indicators.add(
        Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 3.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == i
                ? const Color(0xFFF9A825)
                : Colors.grey.shade300,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: indicators,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color orangeAccent = Color(0xFFF9A825);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Meu perfil",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF9A825)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack( // Use Stack to overlay the icon button
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                  _userProfileImageUrl != null
                      ? NetworkImage(_userProfileImageUrl!) as ImageProvider
                      : null,
                  child: _userProfileImageUrl == null 
                      ? Icon(Icons.person, size: 50, color: Colors.grey.shade700)
                      : null,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        )
                      ]
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Color(0xFFF9A825), size: 20),
                    onPressed: _pickImage,
                    tooltip: 'Trocar foto do perfil',
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),
            Text(
              "Olá",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            Text(
              _userName,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Pets Cadastrados",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54),
                ),
                const SizedBox(width: 10),
                if (!_isLoadingPets)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: orangeAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _petsCadastrados.length.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: orangeAccent,
                          fontSize: 14),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            _buildPetCarousel(),
            if (_petsCadastrados.isNotEmpty) _buildPageIndicator(),
          ],
        ),
      ),
    );
  }
}