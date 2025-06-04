// lib/widgets/side_bar_menu.dart
import 'dart:async'; // IMPORTANTE: Para StreamSubscription
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetoflutter/paginas/pagina_inicial.dart';
import 'package:projetoflutter/paginas/cadastro_pet.dart';
import 'package:projetoflutter/paginas/alimentar_manual_page.dart';
import 'package:projetoflutter/paginas/historico_alimentacao_page.dart';
import 'package:projetoflutter/paginas/login.dart';
import 'package:projetoflutter/paginas/cadastrar_rotina_page.dart';
import 'package:projetoflutter/widgets/pet_card.dart';
import 'package:projetoflutter/paginas/detalhes_pet_page.dart'; // Importar a tela de detalhes do pet

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Pet> _userPets = [];
  bool _isLoadingPets = false;
  User? _currentUser;
  bool _isPetListExpanded = true;
  StreamSubscription<User?>? _authStateChangesSubscription; // Tipo CORRIGIDO

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;

    _authStateChangesSubscription = _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
        if (user != null) {
          _fetchUserPets();
        } else {
          setState(() {
            _userPets = [];
            _isLoadingPets = false;
          });
        }
      }
    });

    if (_currentUser != null) {
      _fetchUserPets();
    }
  }

  @override
  void dispose() {
    _authStateChangesSubscription?.cancel(); // Agora deve funcionar
    super.dispose();
  }

  Future<void> _fetchUserPets() async {
    if (_currentUser == null || !mounted) {
      if (mounted) {
        setState(() {
          _isLoadingPets = false;
          _userPets = [];
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingPets = true;
      });
    }

    try {
      QuerySnapshot petSnapshot = await _firestore
          .collection('pets')
          .where('tutorId', isEqualTo: _currentUser!.uid)
          .get();

      List<Pet> pets = petSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) {
          // ignore: avoid_print
          print("Alerta: Documento de pet com dados nulos encontrado: ${doc.id}");
          return null;
        }
        return Pet.fromMap(data, doc.id);
      }).whereType<Pet>().toList();

      if (mounted) {
        setState(() {
          _userPets = pets;
          _isLoadingPets = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Erro ao buscar pets para o SideMenu: $e");
      if (mounted) {
        setState(() {
          _isLoadingPets = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar seus pets: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey.shade700,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle( // Adicionado const para otimização
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        onTap();
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: TextButton.icon(
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroPetsPage()),
          ).then((_) {
            // Após retornar da tela de cadastro de pet, recarrega a lista de pets
            if (_currentUser != null) {
              _fetchUserPets();
            }
          });
        },
        icon: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFF9A825),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
        label: const Text(
          'Adicionar Novo Pet',
          style: TextStyle(color: Color(0xFFF9A825), fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: const Color(0xFFF9A825).withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildPetListItem(BuildContext context, Pet pet) {
    return ListTile(
      leading: Icon(Icons.pets_outlined, color: const Color(0xFFF9A825), size: 22),
      title: Text(pet.nome, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      dense: true,
      contentPadding: const EdgeInsets.only(left: 28.0, right: 16.0),
      visualDensity: VisualDensity.compact,
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Fecha o Drawer
        }
        // Navega para a tela de detalhes do pet
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalhesPetPage(pet: pet),
          ),
        ).then((result) {
          // Se houver alteração na tela de detalhes (result == true), recarrega os pets
          if (result == true && mounted) {
            _fetchUserPets();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 290,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                  color: const Color(0xFFF9A825).withOpacity(0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('imagens/logo_sem_fundo.png', height: 45),
                      const SizedBox(width: 12),
                      const Text(
                        'P.O.T.I',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4842C),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (mounted){
                      setState(() {
                        _isPetListExpanded = !_isPetListExpanded;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 16.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            'Seus Pets Cadastrados',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)
                        ),
                        Icon(
                          _isPetListExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: child,
                    );
                  },
                  child: _isPetListExpanded
                      ? Column(
                    key: const ValueKey<String>('petListExpanded'),
                    children: [
                      if (_currentUser == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                          child: Text(
                            'Faça login para ver seus pets.',
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 13, fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else if (_isLoadingPets)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: CircularProgressIndicator(color: Color(0xFFF9A825), strokeWidth: 2.0,)),
                        )
                      else if (_userPets.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                            child: Text(
                              'Nenhum pet cadastrado.',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                          )
                        else
                          ..._userPets.map((pet) => _buildPetListItem(context, pet)).toList(),
                      if (_currentUser != null)
                        _buildAddButton(context),
                    ],
                  )
                      : const SizedBox.shrink(key: ValueKey<String>('petListCollapsed')),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Divider(height: 1, thickness: 1),
                ),
                _buildMenuItem(context, Icons.home_outlined, 'Início', () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const PaginaInicialRefatorada()),
                        (Route<dynamic> route) => false,
                  );
                }),
                _buildMenuItem(context, Icons.restaurant_menu_outlined, 'Alimentar Agora', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AlimentarManualPage()),
                  );
                }),
                _buildMenuItem(context, Icons.calendar_today_outlined, 'Criar Plano de Alimentação', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CadastrarRotinaPage()),
                  );
                }),
                _buildMenuItem(context, Icons.history_outlined, 'Histórico de Alimentação', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoricoAlimentacaoPage()),
                  );
                }),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Divider(height: 1, thickness: 1),
                ),
                _buildMenuItem(context, Icons.person_outline, 'Meu Perfil', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navegar para Meu Perfil (TODO)')),
                  );
                }),
                _buildMenuItem(context, Icons.settings_outlined, 'Configurações', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navegar para Configurações (TODO)')),
                  );
                }),
              ],
            ),
          ),
          if (_currentUser != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9A825).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFF9A825).withOpacity(0.8),
                      child: Text(
                          _currentUser?.displayName?.substring(0, 1).toUpperCase() ?? _currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.displayName ?? _currentUser?.email?.split('@')[0] ?? 'Usuário',
                            style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _currentUser?.email ?? 'Não autenticado',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey.shade700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.exit_to_app_outlined, color: Colors.grey.shade600),
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                              (Route<dynamic> route) => false,
                        );
                      },
                      tooltip: 'Sair',
                      iconSize: 22,
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton.icon(
                icon: const Icon(Icons.login, color: Color(0xFFF9A825)),
                label: const Text('Fazer Login', style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.bold)),
                onPressed: (){
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                        (Route<dynamic> route) => false,
                  );
                },
                style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF9A825).withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12)
                ),
              ),
            ),
        ],
      ),
    );
  }
}