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
        'fotoUrl': null,
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
        Navigator.push(
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBarPoti(
        scaffoldKey: _scaffoldKey,
        titleText: "Cadastrar Pet",
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Olá Tutor\nSeja bem Vindo ao P.O.T.I',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(40.0),
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
                      const Text(
                        'Nome e Raça',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 50),
                  // Avatar Placeholder
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey.shade300,
                        // Removida a lógica de FileImage
                        backgroundImage: const NetworkImage( // Placeholder da internet
                            'https://via.placeholder.com/160/FFA500/000000?Text=Pet'),
                        child: null, // Sem ícone se tiver backgroundImage
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300)),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Color(0xFFF9A825)),
                          onPressed: () {
                            // Ação de upload removida, pode mostrar uma mensagem
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Funcionalidade de upload de imagem desativada temporariamente.')),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('Qual é o Nome do seu pet?', 'Nome:', _nomeController),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: _buildTextField('Qual é Raça do seu pet?', 'Raça:', _racaController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (_nomeController.text.isNotEmpty && _racaController.text.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CadastroPetPesoPage(petId: "temp_id_simulado_para_proxima_etapa"),
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
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Ignorar',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _cadastrarPet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF9A825),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
                              'Confirmar',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Siga nas Redes sociais'),
                  SizedBox(width: 10),
                  Icon(Icons.facebook),
                  SizedBox(width: 10),
                  Icon(Icons.camera_alt_outlined),
                  SizedBox(width: 10),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}