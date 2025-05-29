import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projetoflutter/widgets/app_bar_poti.dart';
import 'package:projetoflutter/widgets/side_bar_menu.dart';
import 'package:projetoflutter/widgets/pet_card.dart';

class TelaDispositivoConectado extends StatefulWidget {
  const TelaDispositivoConectado({super.key});

  @override
  State<TelaDispositivoConectado> createState() =>
      _TelaDispositivoConectadoState();
}

class _TelaDispositivoConectadoState extends State<TelaDispositivoConectado> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Pet> _petsCadastrados = [];
  bool _isLoadingPets = true;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75, initialPage: 0);
    _fetchUserPets();
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

        setState(() {
          _petsCadastrados = pets;
          _isLoadingPets = false;
          _currentPage = _petsCadastrados.isNotEmpty ? 0 : 0;
          if (_pageController.hasClients && _petsCadastrados.isNotEmpty) {
            _pageController.jumpToPage(0);
          } else if (_petsCadastrados.isEmpty){
            _currentPage = 0;
          }
        });
      } catch (e) {
        // ignore: avoid_print
        print("Erro ao buscar pets: $e");
        setState(() {
          _isLoadingPets = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar os pets: ${e.toString()}')),
          );
        }
      }
    } else {
      setState(() {
        _isLoadingPets = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado.')),
        );
      }
    }
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
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Text(
              'Nenhum pet cadastrado ainda.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ));
    }

    const double carouselHeight = 170.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (_petsCadastrados.length > 1)
                ? IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.grey.shade600, size: 20),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutSine,
                );
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
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (BuildContext context, Widget? cardWidget) {
                        double scaleFactor = 0.88;
                        if (_pageController.position.haveDimensions) {
                          double page = _pageController.page ?? _currentPage.toDouble();
                          double diff = (index - page).abs();
                          scaleFactor = (1 - (diff * 0.12)).clamp(0.88, 1.0);
                        } else {
                          scaleFactor = (index == _currentPage) ? 1.0 : 0.88;
                        }
                        return Transform.scale(
                          scale: scaleFactor,
                          child: cardWidget,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: PetCard(
                          pet: _petsCadastrados[index],
                          isSelected: index == _currentPage,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            (_petsCadastrados.length > 1)
                ? IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600, size: 20),
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutSine,
                );
              },
            )
                : const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 12.0),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildPageIndicator() {
    if (_petsCadastrados.length <= 1) return const SizedBox.shrink();

    List<Widget> indicators = [];
    for (int i = 0; i < _petsCadastrados.length; i++) {
      indicators.add(
        Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == i
                ? const Color(0xFFF9A825)
                : Colors.grey.shade300,
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: indicators,
    );
  }

  Widget _buildAlimentadorStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi, size: 40, color: Color(0xFFF9A825)),
          const SizedBox(height: 10),
          const Text(
            "Alimentador1 conectado",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green),
          ),
          const SizedBox(height: 5),
          Text(
            "Conectado ao alimentador",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            "Via Wi-Fi SUCESSO - 2.4 GHz",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Siga nas Redes sociais'),
          SizedBox(width: 10),
          Icon(Icons.facebook),
          SizedBox(width: 10),
          Icon(Icons.camera_alt_outlined),
          SizedBox(width: 10),
          Icon(Icons.alternate_email),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarPoti(
        scaffoldKey: _scaffoldKey,
        titleText: "Meus Pets",
      ),
      drawer: const SideMenu(),
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Seus Pets Cadastrados",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!_isLoadingPets && _petsCadastrados.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _petsCadastrados.length.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Veja as informações do seu pet",
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPetCarousel(),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(child: _buildAlimentadorStatusCard()),
              const SizedBox(height: 30),
              _buildSocialMediaFooter(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 10),
                child: Center(
                  child: Text(
                    "P.O.T.I\n©2023 Todos os Direitos Reservados",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}