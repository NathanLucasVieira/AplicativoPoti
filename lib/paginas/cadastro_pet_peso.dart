import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetoflutter/paginas/pagina_inicial.dart';
import 'package:projetoflutter/paginas/tela_dispositivo_conectado.dart';
import 'package:projetoflutter/widgets/side_bar_menu.dart';
import 'package:projetoflutter/widgets/app_bar_poti.dart';

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
          MaterialPageRoute(builder: (context) => const TelaDispositivoConectado()), // Alterado aqui
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("Erro ao atualizar peso: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao salvar o peso: ${e.toString()}'),
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeso = valor;
        });
      },
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(15.0),
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
                size: 40,
                color:
                isSelected ? const Color(0xFFF9A825) : Colors.grey.shade600),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black87 : Colors.black54,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitulo,
              style: TextStyle(
                fontSize: 14,
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
    // Importe PaginaInicialRefatorada se for usar no botão ignorar
    // import 'package:projetoflutter/paginas/pagina_inicial.dart';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBarPoti(
        scaffoldKey: _scaffoldKey,
        titleText: "Peso do Pet",
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Olá Tutor\nSeja bem Vindo ao P.O.T.I',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20.0),
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
                        const Column(
                          children: [
                            Text('Adicione Informações',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Tamanho',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                          ],
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
                    const SizedBox(height: 30),
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                          'https://via.placeholder.com/120/FFA500/000000?Text=Pet'),
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Qual é o Tamanho do seu pet?',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text(
                                    'Este é o último passo do cadastro inicial.')));
                          },
                          child: const Text('Ir para o próximo passo',
                              style: TextStyle(
                                  color: Colors.black54,
                                  decoration: TextDecoration.underline)),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                // Ao ignorar, leva para a PaginaInicialRefatorada
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PaginaInicialRefatorada()), // Mudado para PaginaInicialRefatorada para consistência
                                      (Route<dynamic> route) => false,
                                );
                              },
                              child: const Text('Ignorar',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16)),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _atualizarPeso,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF9A825),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 20),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                                  : const Text('Confirmar',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
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