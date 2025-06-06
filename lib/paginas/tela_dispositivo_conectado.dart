import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projetoflutter/widgets/app_bar_poti.dart';
import 'package:projetoflutter/widgets/side_bar_menu.dart';
<<<<<<< HEAD
import 'package:projetoflutter/widgets/pet_card.dart'; // Ensure Pet model is here
=======
import 'package:projetoflutter/widgets/pet_card.dart';
import 'package:projetoflutter/paginas/detalhes_pet_page.dart'; // Import da tela de detalhes
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524

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
    // Initialize with a default value, even if it changes later
    _pageController = PageController(viewportFraction: 0.8, initialPage: _currentPage);
    _fetchUserPets();

    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage && _pageController.hasClients) {
        if(mounted){
          setState(() {
            _currentPage = _pageController.page!.round();
          });
        }
      }
    });
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

<<<<<<< HEAD
=======
        // Ordena os pets alfabeticamente pelo nome para consistência
        pets.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
        if (!mounted) return;
        setState(() {
          _petsCadastrados = pets;
          _isLoadingPets = false;
<<<<<<< HEAD
          // Update PageController initial page if pets list was empty and now has items
          if (_petsCadastrados.isNotEmpty && _currentPage >= _petsCadastrados.length) {
=======
          // Garante que _currentPage seja válido após o fetch
          if (_petsCadastrados.isNotEmpty) {
            _currentPage = _currentPage.clamp(0, _petsCadastrados.length - 1);
            // Se o pageController já foi criado e tem clientes, anima para a página correta
            if (_pageController.hasClients) {
              // Apenas atualiza se a página realmente mudou para evitar saltos desnecessários
              if(_pageController.page?.round() != _currentPage) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if(_pageController.hasClients) { // Checa novamente por segurança
                    _pageController.jumpToPage(_currentPage);
                  }
                });
              }
            }
          } else {
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
            _currentPage = 0;
          }
          if (_pageController.hasClients && _petsCadastrados.isNotEmpty) {
            // No need to jump if it's already at a valid page or list is empty.
            // _pageController.jumpToPage(_currentPage); //This can cause issues if called too early or state changes rapidly
          } else if (_petsCadastrados.isEmpty){
            _currentPage = 0; // Or -1 if you want to signify no page.
          }
        });
      } catch (e) {
<<<<<<< HEAD
        // ignore: avoid_print
        print("Erro ao buscar pets: $e");
        if (!mounted) return;
        setState(() {
          _isLoadingPets = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar os pets: ${e.toString()}')),
        );
      }
    } else {
      if (!mounted) return;
      setState(() {
        _isLoadingPets = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
=======
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
      });
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
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
      // Se result for true, significa que houve alteração (salvo ou excluído)
      // Atualiza a lista de pets
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

    // Re-initialize PageController if it was disposed or if number of pages changed drastically
    // This is a simplified check; more complex logic might be needed for dynamic page counts
    if (!_pageController.hasClients || (_pageController.viewportFraction != 0.8 && _petsCadastrados.isNotEmpty) ) {
      _pageController = PageController(viewportFraction: 0.8, initialPage: _currentPage);
    }


    const double carouselHeight = 160.0; // Slightly reduced height for cards

    return Column(
      children: [
<<<<<<< HEAD
        SizedBox( // Explicitly define SizedBox for PageView
          height: carouselHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _petsCadastrados.length,
            onPageChanged: (int page) {
              if(mounted){
                setState(() {
                  _currentPage = page;
                });
              }
            },
            itemBuilder: (context, index) {
              // Card scaling animation (optional, can be simplified if causing issues)
              double scaleFactor = 0.85; // Non-selected scale
              if (_pageController.position.haveDimensions) {
                // Use _currentPage if page is not yet an integer (during scroll)
                double page = _pageController.page ?? _currentPage.toDouble();
                scaleFactor = (1 - ((index - page).abs() * 0.15)).clamp(0.85, 1.0);
              } else if (index == _currentPage) {
                scaleFactor = 1.0; // Selected scale
              }

              return Transform.scale(
                scale: scaleFactor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0), // Adjust padding
                  child: PetCard(
                    pet: _petsCadastrados[index],
                    isSelected: index == _currentPage,
                  ),
                ),
              );
            },
          ),
=======
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
                : const SizedBox(width: 48), // Espaço para alinhar quando não há seta

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
                          padding: const EdgeInsets.symmetric(vertical: 8.0), // Espaço para a sombra do card
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
                : const SizedBox(width: 48), // Espaço para alinhar
          ],
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
        ),
        if (_petsCadastrados.length > 1) ...[ // Show indicator only if more than 1 pet
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
<<<<<<< HEAD
        AnimatedContainer( // Added animation for indicator change
          duration: const Duration(milliseconds: 150),
          width: _currentPage == i ? 10.0 : 8.0, // Larger if selected
          height: _currentPage == i ? 10.0 : 8.0,
=======
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: _currentPage == i ? 12.0 : 8.0,
          height: _currentPage == i ? 12.0 : 8.0,
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
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
      padding: const EdgeInsets.all(16.0), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0), // Slightly smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1, // Reduced spread
            blurRadius: 4,   // Reduced blur
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi, size: 36, color: Color(0xFFF9A825)), // Slightly smaller icon
          const SizedBox(height: 8),
          const Text(
<<<<<<< HEAD
            "Alimentador Conectado", // Generic name
=======
            "Alimentador P.O.T.I", // Nome genérico do alimentador
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
            style: TextStyle(
                fontSize: 17, // Adjusted font size
                fontWeight: FontWeight.bold,
                color: Colors.green),
          ),
          const SizedBox(height: 4),
          Text(
<<<<<<< HEAD
            "Status: Online", // Simplified status
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700), // Adjusted font size
          ),
          Text(
            "Rede: Wi-Fi SUCESSO - 2.4 GHz", // Example network
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600), // Adjusted font size
=======
            "Status: Conectado",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            "Rede: Wi-Fi SUCESSO - 2.4 GHz", // Exemplo de rede
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0), // Reduced padding
      child: Wrap( // Used Wrap for responsiveness
        alignment: WrapAlignment.center,
        spacing: 12.0, // Spacing between items
        runSpacing: 8.0, // Spacing between lines
        children: [
<<<<<<< HEAD
          Text('Siga-nos:', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)), // Adjusted
          const Icon(Icons.facebook, size: 22),
          const Icon(Icons.camera_alt_outlined, size: 22),
          const Icon(Icons.alternate_email, size: 22), // Changed to a generic social icon
=======
          Text('Siga nas Redes sociais'),
          SizedBox(width: 10),
          Icon(Icons.facebook), // Exemplo de ícone
          SizedBox(width: 10),
          Icon(Icons.camera_alt_outlined), // Exemplo de ícone
          SizedBox(width: 10),
          Icon(Icons.alternate_email), // Exemplo de ícone
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determina o pet selecionado para a AppBar
    Pet? petSelecionadoParaAppBar;
    if (_petsCadastrados.isNotEmpty && _currentPage < _petsCadastrados.length) {
      petSelecionadoParaAppBar = _petsCadastrados[_currentPage];
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarPoti(
        scaffoldKey: _scaffoldKey,
        titleText: petSelecionadoParaAppBar == null ? "Meus Pets" : null, // Mostra "Meus Pets" se nenhum pet estiver no carrossel
        selectedPet: petSelecionadoParaAppBar,
        onSelectedPetTap: petSelecionadoParaAppBar != null
            ? () => _navigateToPetDetails(petSelecionadoParaAppBar!)
            : null,
      ),
      drawer: const SideMenu(),
      backgroundColor: const Color(0xFFFAFAFA),
<<<<<<< HEAD
      body: RefreshIndicator( // Added RefreshIndicator
        onRefresh: _fetchUserPets,
        color: const Color(0xFFF9A825),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll even if content is small
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0), // Adjusted padding
=======
      body: RefreshIndicator( // Adicionado RefreshIndicator
        onRefresh: _fetchUserPets,
        color: const Color(0xFFF9A825),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Permite scroll mesmo com pouco conteúdo
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
<<<<<<< HEAD
                  padding: const EdgeInsets.all(12.0), // Reduced padding
=======
                  padding: const EdgeInsets.all(16.0),
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
<<<<<<< HEAD
                        color: Colors.grey.withOpacity(0.15), // Slightly adjusted shadow
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
=======
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
<<<<<<< HEAD
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0), // Adjusted
=======
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Seus Pets Cadastrados",
                              style: TextStyle(
<<<<<<< HEAD
                                fontSize: 17, // Adjusted
=======
                                fontSize: 18,
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
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
<<<<<<< HEAD
                                      fontSize: 13, // Adjusted
=======
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
                                      color: Colors.grey.shade700),
                                ),
                              ),
                          ],
                        ),
                      ),
<<<<<<< HEAD
                      const SizedBox(height: 2), // Reduced
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          "Arraste para ver os detalhes do seu pet.", // Changed text
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600), // Adjusted
                        ),
                      ),
                      const SizedBox(height: 12), // Adjusted
                      _buildPetCarousel(),
                      const SizedBox(height: 4.0), // Adjusted
                    ],
                  ),
                ),
                const SizedBox(height: 24), // Adjusted
                Center(child: _buildAlimentadorStatusCard()),
                const SizedBox(height: 24), // Adjusted
                _buildSocialMediaFooter(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 8.0), // Adjusted
                  child: Center(
                    child: Text(
                      "P.O.T.I\n©2024 Todos os Direitos Reservados", // Updated year
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600), // Adjusted
=======
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
                      const SizedBox(height: 8.0), // Espaço após o carrossel
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
                      "P.O.T.I\n©2024 Todos os Direitos Reservados", // Atualizado o ano
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
>>>>>>> 53061dc7b58e7cb904a2031c6cc3dad74cac5524
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
