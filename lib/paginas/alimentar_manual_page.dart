import 'package:flutter/material.dart';
import 'package:projetoflutter/widgets/app_bar_poti.dart';
import 'package:projetoflutter/widgets/side_bar_menu.dart';
import 'package:projetoflutter/paginas/historico_alimentacao_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:projetoflutter/paginas/cadastrar_rotina_page.dart'; 

class AlimentarManualPage extends StatefulWidget {
  const AlimentarManualPage({super.key});

  @override
  State<AlimentarManualPage> createState() => _AlimentarManualPageState();
}

class _AlimentarManualPageState extends State<AlimentarManualPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _quantidadeController = TextEditingController();
  String _quantidadeSelecionadaDisplay = "0g";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 
  bool _isLoading = false; 
  @override
  void initState() {
    super.initState();
    _quantidadeController.text = "100"; 
    _updateQuantidadeDisplay();
    _quantidadeController.addListener(_updateQuantidadeDisplay);
  }

  void _updateQuantidadeDisplay() {
    final textValue = _quantidadeController.text;
    if (textValue.isEmpty) {
      if (mounted) {
        setState(() {
          _quantidadeSelecionadaDisplay = "0g";
        });
      }
    } else {
      final numericValue = double.tryParse(textValue);
      if (numericValue != null) {
        if (mounted) {
          setState(() {
            // Mostra como inteiro se não tiver casas decimais, ou com uma casa decimal se tiver.
            _quantidadeSelecionadaDisplay = numericValue % 1 == 0 ? "${numericValue.toInt()}g" : "${numericValue.toStringAsFixed(1)}g";
          });
        }
      }
    }
  }

  Future<void> _alimentarAgora() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Usuário não autenticado. Faça login para continuar.'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    final quantidadeText = _quantidadeController.text;
    final double? quantidade = double.tryParse(quantidadeText);

    if (quantidade != null && quantidade > 0) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      try {
        await _firestore.collection('historico_alimentacao').add({
          'userId': currentUser.uid,
          'dataHora': Timestamp.now(),
          'tipo': 'Alimentação Manual', // Tipo específico para esta ação
          'quantidade': quantidade,
          'petNome': '', // Deixar em branco ou adicionar lógica de seleção de pet se necessário
          'concluido': true, // Alimentação manual é sempre concluída imediatamente
          'criadoEm': Timestamp.now(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Alimentado com ${quantidade % 1 == 0 ? quantidade.toInt() : quantidade.toStringAsFixed(1)}g. Registro salvo.'),
                backgroundColor: Colors.green),
          );
          _quantidadeController.text = "0"; // Clear and set to 0
          _updateQuantidadeDisplay(); // Atualiza o display para "0g"
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erro ao salvar registro: ${e.toString()}'),
                backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, insira uma quantidade válida.'),
              backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _navegarParaHistorico() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoricoAlimentacaoPage()),
    );
  }

  void _navegarParaCriarPlano() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastrarRotinaPage()),
    );
  }

  @override
  void dispose() {
    _quantidadeController.removeListener(_updateQuantidadeDisplay);
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarPoti(
        scaffoldKey: _scaffoldKey,
        titleText: "Alimentar Manualmente",
      ),
      drawer: const SideMenu(),
      backgroundColor: const Color(0xFFFAFAFA), // Cor de fundo suave
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), // Limita a largura máxima
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0), // Adjusted padding
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'imagens/logo_sem_fundo.png',
                      height: 100, // Reduced height
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.pets, size: 100, color: Colors.grey);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Quantidade Selecionada",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _quantidadeSelecionadaDisplay,
                      style: const TextStyle(
                        fontSize: 34, // Slightly reduced
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF9A825),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _quantidadeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Ajustar Quantidade (gramas)",
                        hintText: "Ex: 150",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFF9A825), width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelStyle: const TextStyle(color: Color(0xFFF9A825)),
                        suffixText: "g",
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24), // Adjusted
                    _isLoading
                        ? const CircularProgressIndicator(color: Color(0xFFF9A825))
                        : ElevatedButton(
                      onPressed: _alimentarAgora,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9A825),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14), // Adjusted padding
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold), // Adjusted
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: const Size(double.infinity, 48), // Adjusted height
                      ),
                      child: const Text("Alimentar", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 12), // Adjusted
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFFF9A825)),
                      label: const Text(
                        "Criar Plano De Alimentação",
                        style: TextStyle(color: Color(0xFFF9A825), fontSize: 15), // Adjusted
                      ),
                      onPressed: _navegarParaCriarPlano,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 8), // Adjusted
                    TextButton.icon(
                      icon: const Icon(Icons.history, color: Color(0xFFF9A825)),
                      label: const Text(
                        "Ver Histórico de Alimentação",
                        style: TextStyle(color: Color(0xFFF9A825), fontSize: 15), // Adjusted
                      ),
                      onPressed: _navegarParaHistorico,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}