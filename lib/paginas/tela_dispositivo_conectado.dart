import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabalhopoti/widgets/app_bar_poti.dart'; // <<< CORREÇÃO
import 'package:trabalhopoti/widgets/side_bar_menu.dart';
import 'package:trabalhopoti/widgets/pet_card.dart';
import 'package:trabalhopoti/paginas/detalhes_pet_page.dart';

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
    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);
    _fetchUserPets();
  }

  Future<void> _fetchUserPets() async {
    if (!mounted) return;
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

        pets.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

        if (!mounted) return;
        setState(() {
          _petsCadastrados = pets;
          _isLoadingPets = false;

          if (_petsCadastrados.isNotEmpty) {
            _currentPage = _currentPage.clamp(0, _petsCadastrados.length - 1);
            if (_pageController.hasClients) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if(_pageController.hasClients) {
                  _pageController.jumpToPage(_currentPage);
                }
              });
            }
          } else {
            _currentPage = 0;
          }
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar os pets: ${e.toString()}')),
        );
        setState(() {
          _isLoadingPets = false;
        });
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      setState(() {
        _isLoadingPets = false;
        _petsCadastrados = [];
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _navigateToPetDetails(Pet pet) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesPetPage(pet: pet),
      ),
    );
    if (result == true && mounted) {
      _fetchUserPets();
    }
  }

  Widget _buildPetCarousel() {
    if (_isLoadingPets) {
      return const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 50.0),
        child: CircularProgressIndicator(color: Color(0xFFF9A825)),
      ));
    }
    if (_petsCadastrados.isEmpty) {
      return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: Text(
              'Nenhum pet cadastrado ainda.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ));
    }

    const double carouselHeight = 160.0;

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
                    if (mounted) {
                      setState(() {
                        _currentPage = page;
                      });
                    }
                  },
                  itemBuilder: (context, index) {
                    final pet = _petsCadastrados[index];
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
                      child: GestureDetector(
                        onTap: () => _navigateToPetDetails(pet),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: PetCard(
                            pet: pet,
                            isSelected: index == _currentPage,
                          ),
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
        if (_petsCadastrados.length > 1) ...[
          const SizedBox(height: 10.0),
          _buildPageIndicator(),
        ]
      ],
    );
  }

  Widget _buildPageIndicator() {
    if (_petsCadastrados.length <= 1) return const SizedBox.shrink();

    List<Widget> indicators = [];
    for (int i = 0; i < _petsCadastrados.length; i++) {
      indicators.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: _currentPage == i ? 12.0 : 8.0,
          height: _currentPage == i ? 12.0 : 8.0,
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi, size: 36, color: Color(0xFFF9A825)),
          const SizedBox(height: 8),
          const Text(
            "Alimentador P.O.T.I",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.green),
          ),
          const SizedBox(height: 4),
          Text(
            "Status: Conectado",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            "Rede: Wi-Fi SUCESSO - 2.4 GHz",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12.0,
        runSpacing: 8.0,
        children: [
          Text('Siga nas Redes sociais', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const Icon(Icons.facebook, size: 22),
          const Icon(Icons.camera_alt_outlined, size: 22),
          const Icon(Icons.alternate_email, size: 22),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Pet? petSelecionadoParaAppBar;
    if (_petsCadastrados.isNotEmpty && _currentPage < _petsCadastrados.length) {
      petSelecionadoParaAppBar = _petsCadastrados[_currentPage];
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarPoti(
        scaffoldKey: _scaffoldKey,
        titleText: petSelecionadoParaAppBar == null ? "Meus Pets" : null,
        selectedPet: petSelecionadoParaAppBar,
        onSelectedPetTap: petSelecionadoParaAppBar != null
            ? () => _navigateToPetDetails(petSelecionadoParaAppBar!)
            : null,
      ),
      drawer: const SideMenu(),
      backgroundColor: const Color(0xFFFAFAFA),
      body: RefreshIndicator(
        onRefresh: _fetchUserPets,
        color: const Color(0xFFF9A825),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                          "Selecione um pet para ver ou editar detalhes.",
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
                      "P.O.T.I\n©2024 Todos os Direitos Reservados",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}