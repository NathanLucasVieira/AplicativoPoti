import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projetoflutter/paginas/cadastro_pet_peso.dart';
import 'package:projetoflutter/widgets/side_bar_menu.dart';
import 'package:projetoflutter/widgets/app_bar_poti.dart';

class CadastroPetsPage extends StatefulWidget {
  const CadastroPetsPage({super.key});

  @override
  State<CadastroPetsPage> createState() => _CadastroPetsPageState();
}

class _CadastroPetsPageState extends State<CadastroPetsPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _racaController = TextEditingController();
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _cadastrarPet() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erro: Nenhum usuário logado.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    String nome = _nomeController.text.trim();
    String raca = _racaController.text.trim();

    if (nome.isEmpty || raca.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, preencha o Nome e a Raça.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      DocumentReference petRef = await _firestore.collection('pets').add({
        'nome': nome,
        'raca': raca,
        'tutorId': currentUser.uid,
        'fotoUrl': null, // Manter fotoUrl como nulo, sem upload
        'criadoEm': Timestamp.now(),
        'peso': null,
      });
      String petId = petRef.id;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nome e Raça salvos! Próximo passo.'),
            backgroundColor: Colors.lightGreen),
      );

      if (mounted) {
        Navigator.pushReplacement( // Changed to pushReplacement
          context,
          MaterialPageRoute(
            builder: (context) => CadastroPetPesoPage(petId: petId),
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("Erro ao cadastrar pet: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao cadastrar o pet: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;


    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBarPoti(
        scaffoldKey: _scaffoldKey,
        titleText: "Cadastrar Pet",
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20.0 : 50.0, vertical: 30.0), // Adaptive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Olá Tutor\nSeja bem Vindo ao P.O.T.I',
              style: TextStyle(
                fontSize: 24, // Slightly reduced for mobile
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30), // Adjusted spacing
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 20.0 : 40.0), // Adaptive padding
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Flexible( // Added Flexible to prevent overflow
                        child: Text(
                          'Nome e Raça',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        '1 / 2',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.grey,
                    color: Color(0xFFF9A825),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 30), // Adjusted spacing
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: isSmallScreen ? 60 : 80, // Adaptive radius
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: const NetworkImage(
                            'https://via.placeholder.com/160/FFA500/000000?Text=Pet'),
                        child: null,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300)),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Color(0xFFF9A825)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Funcionalidade de upload de imagem desativada temporariamente.')),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30), // Adjusted spacing

                  // Changed Row to Column for text fields on small screens
                  _buildTextField('Qual é o Nome do seu pet?', 'Nome:', _nomeController),
                  const SizedBox(height: 20),
                  _buildTextField('Qual é Raça do seu pet?', 'Raça:', _racaController),

                  const SizedBox(height: 40), // Adjusted spacing
                  // Changed Row to Column for buttons on small screens
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons take full width
                    children: [
                      TextButton(
                        onPressed: () {
                          if (_nomeController.text.isNotEmpty && _racaController.text.isNotEmpty) {
                            Navigator.push( // Keep as push, user might want to go back
                              context,
                              MaterialPageRoute(
                                builder: (context) => CadastroPetPesoPage(petId: "temp_id_simulado_para_proxima_etapa"), // This ID will be replaced upon actual save
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Preencha Nome e Raça para avançar.')),
                            );
                          }
                        },
                        child: const Text(
                          'Vá para o próximo passo',
                          style: TextStyle(
                            color: Colors.black54,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _cadastrarPet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9A825),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Adjusted padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          'Confirmar e Próximo', // Changed text for clarity
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Back or cancel
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Footer can be simplified or made adaptive if needed
            // For now, keeping it as is, but consider visibility on very small screens
            const Align(
              alignment: Alignment.bottomCenter,
              child: Wrap( // Use Wrap for social media icons
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Text('Siga nas Redes sociais'),
                  Icon(Icons.facebook),
                  Icon(Icons.camera_alt_outlined),
                  Icon(Icons.account_box_rounded),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Adjusted padding
          ),
        ),
      ],
    );
  }
}