import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trabalhopoti/paginas/tela_dispositivo_conectado.dart';
import 'package:trabalhopoti/widgets/side_bar_menu.dart';
import 'package:trabalhopoti/widgets/app_bar_poti.dart'; // <<< CORREÇÃO

class CadastroPetPesoPage extends StatefulWidget {
  final String petId;

  const CadastroPetPesoPage({required this.petId, super.key});

  @override
  State<CadastroPetPesoPage> createState() => _CadastroPetPesoPageState();
}

class _CadastroPetPesoPageState extends State<CadastroPetPesoPage> {
  String? _selectedPeso;
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _atualizarPeso() async {
    if (_selectedPeso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecione um tamanho.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('pets').doc(widget.petId).update({
        'peso': _selectedPeso,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pet cadastrado com sucesso!'),
            backgroundColor: Colors.green),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TelaDispositivoConectado()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("Erro ao atualizar peso: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao salvar o tamanho: ${e.toString()}'),
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

  Widget _buildPesoCard(
      String titulo, String subtitulo, IconData icone, String valor) {
    bool isSelected = _selectedPeso == valor;
    double cardSize = MediaQuery.of(context).size.width / 3 - 24;
    cardSize = cardSize < 100 ? 100 : cardSize;
    cardSize = cardSize > 150 ? 150 : cardSize;


    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeso = valor;
        });
      },
      child: Container(
        width: cardSize,
        height: cardSize + 20,
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF9A825).withOpacity(0.1)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: isSelected ? const Color(0xFFF9A825) : Colors.grey.shade300,
            width: 2.0,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFFF9A825).withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
            )
          ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone,
                size: cardSize * 0.3,
                color:
                isSelected ? const Color(0xFFF9A825) : Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: cardSize * 0.12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black87 : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: cardSize * 0.1,
                color: isSelected ? Colors.black54 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
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
        titleText: "Tamanho do Pet",
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20.0 : 50.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Olá Tutor\nSeja bem Vindo ao P.O.T.I',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 20.0 : 30.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3))
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
                        const Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Adicione Informações',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text('Tamanho',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Text('Passo 2 / 2',
                            style:
                            TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(
                      value: 1.0,
                      backgroundColor: Colors.grey,
                      color: Color(0xFFF9A825),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 25),
                    CircleAvatar(
                      radius: isSmallScreen ? 50 : 60,
                      backgroundImage: const NetworkImage(
                          'https://via.placeholder.com/120/FFA500/000000?Text=Pet'),
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Qual é o Tamanho do seu pet?',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        _buildPesoCard(
                            'Pequeno', 'Abaixo 14kg', Icons.pets, 'Pequeno'),
                        _buildPesoCard(
                            'Médio', '14-25kg', Icons.pets, 'Médio'),
                        _buildPesoCard(
                            'Grande', 'Acima 25kg', Icons.pets, 'Grande'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text(
                                    'Este é o último passo do cadastro inicial.')));
                          },
                          child: const Text('Último passo',
                              style: TextStyle(
                                  color: Colors.black54,
                                  decoration: TextDecoration.underline)),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _atualizarPeso,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9A825),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                              : const Text('Confirmar Cadastro',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const TelaDispositivoConectado()),
                                  (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text('Ignorar por agora',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}