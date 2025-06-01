import 'package:flutter/material.dart';
import 'package:projetoflutter/widgets/app_bar_poti.dart';
import 'package:projetoflutter/widgets/side_bar_menu.dart';
import 'package:projetoflutter/paginas/historico_alimentacao_page.dart'; // Importação garantida

class AlimentarManualPage extends StatefulWidget {
  const AlimentarManualPage({super.key});

  @override
  State<AlimentarManualPage> createState() => _AlimentarManualPageState();
}

class _AlimentarManualPageState extends State<AlimentarManualPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _quantidadeController = TextEditingController();
  String _quantidadeSelecionadaDisplay = "0g";

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
      setState(() {
        _quantidadeSelecionadaDisplay = "0g";
      });
    } else {
      final isNumeric = double.tryParse(textValue) != null;
      if (isNumeric) {
        setState(() {
          _quantidadeSelecionadaDisplay = "${textValue}g";
        });
      }
    }
  }

  void _alimentarAgora() {
    final quantidade = _quantidadeController.text;
    if (quantidade.isNotEmpty &&
        double.tryParse(quantidade) != null &&
        double.parse(quantidade) > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Alimentando com $quantidade gramas... (simulado)')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, insira uma quantidade válida.')),
      );
    }
  }

  void _navegarParaHistorico() {
    // Navegação para a tela de histórico
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoricoAlimentacaoPage()),
    );
  }

  void _navegarParaCriarPlano() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegar para Criar Plano (TODO)')),
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
      backgroundColor: const Color(0xFFFAFAFA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'imagens/logo_sem_fundo.png',
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.pets,
                            size: 120, color: Colors.grey);
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
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF9A825),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _quantidadeController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Ajustar Quantidade (gramas)",
                        hintText: "Ex: 150",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xFFF9A825), width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelStyle: const TextStyle(color: Color(0xFFF9A825)),
                        suffixText: "g",
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _alimentarAgora,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9A825),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Alimentar",
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 15),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined,
                          color: Color(0xFFF9A825)),
                      label: const Text(
                        "Criar Plano De Alimentação",
                        style:
                        TextStyle(color: Color(0xFFF9A825), fontSize: 16),
                      ),
                      onPressed: _navegarParaCriarPlano,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      icon:
                      const Icon(Icons.history, color: Color(0xFFF9A825)),
                      label: const Text(
                        "Ver Histórico de Alimentação",
                        style:
                        TextStyle(color: Color(0xFFF9A825), fontSize: 16),
                      ),
                      onPressed: _navegarParaHistorico, // Corrigido
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
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