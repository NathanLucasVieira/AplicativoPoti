// lib/paginas/historico_alimentacao_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de data e hora
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetoflutter/widgets/app_bar_poti.dart';
import 'package:projetoflutter/widgets/side_bar_menu.dart';

// Modelo de dados para um registro de alimentação
class RegistroAlimentacao {
  final String id;
  final DateTime dataHora;
  final String tipo; // Ex: "Programada", "Manual", "Plano - Viagem"
  final double quantidade; // Em gramas
  final String petNome; // Nome do pet, pode ser vazio
  final bool concluido;
  final String? nomePlano; // Para guardar o nome do plano original se aplicável

  RegistroAlimentacao({
    required this.id,
    required this.dataHora,
    required this.tipo,
    required this.quantidade,
    this.petNome = "", // Default como string vazia se não informado
    required this.concluido,
    this.nomePlano,
  });

  factory RegistroAlimentacao.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RegistroAlimentacao(
      id: doc.id,
      dataHora: (data['dataHora'] as Timestamp).toDate(),
      tipo: data['tipo'] as String? ?? 'Não especificado',
      quantidade: (data['quantidade'] as num?)?.toDouble() ?? 0.0,
      petNome: data['petNome'] as String? ?? '', // Garante que sempre haverá um valor
      concluido: data['concluido'] as bool? ?? false, // Default para false se não existir
      nomePlano: data['nomePlano'] as String?,
    );
  }
}

class HistoricoAlimentacaoPage extends StatefulWidget {
  const HistoricoAlimentacaoPage({super.key});

  @override
  State<HistoricoAlimentacaoPage> createState() =>
      _HistoricoAlimentacaoPageState();
}

class _HistoricoAlimentacaoPageState extends State<HistoricoAlimentacaoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<RegistroAlimentacao> _historicoCompleto = []; // Guarda todos os registros carregados
  List<RegistroAlimentacao> _historicoFiltrado = []; // Registros após aplicar o filtro
  bool _isLoading = true;
  String _filtroSelecionado = "Hoje"; // Filtro padrão

  // Para o DateRangePicker
  DateTimeRange? _intervaloSelecionado;


  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Usuário não autenticado.'),
            backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('historico_alimentacao')
          .where('userId', isEqualTo: currentUser.uid)
      // Ordenar no cliente após carregar pode ser mais flexível com filtros
      // .orderBy('dataHora', descending: true)
          .get();

      if (mounted) {
        _historicoCompleto = snapshot.docs
            .map((doc) => RegistroAlimentacao.fromFirestore(doc))
            .toList();
        // Ordena do mais recente para o mais antigo
        _historicoCompleto.sort((a, b) => b.dataHora.compareTo(a.dataHora));
        _aplicarFiltro(); // Aplica o filtro inicial "Hoje"
      }
    } catch (e) {
      // ignore: avoid_print
      print("Erro ao carregar histórico: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao carregar histórico: ${e.toString()}'),
            backgroundColor: Colors.red));
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _aplicarFiltro() {
    if (!mounted) return;

    List<RegistroAlimentacao> filtrados = [];
    final now = DateTime.now();
    final hoje = DateTime(now.year, now.month, now.day);

    if (_filtroSelecionado == "Hoje") {
      filtrados = _historicoCompleto
          .where((r) => DateUtils.isSameDay(r.dataHora, hoje))
          .toList();
    } else if (_filtroSelecionado == "Ontem") {
      final ontem = hoje.subtract(const Duration(days: 1));
      filtrados = _historicoCompleto
          .where((r) => DateUtils.isSameDay(r.dataHora, ontem))
          .toList();
    } else if (_filtroSelecionado == "Últimos 7 dias") {
      final seteDiasAtras = hoje.subtract(const Duration(days: 6));
      filtrados = _historicoCompleto.where((r) {
        final dataRegistro = DateTime(r.dataHora.year, r.dataHora.month, r.dataHora.day);
        return !dataRegistro.isBefore(seteDiasAtras) && !dataRegistro.isAfter(hoje);
      }).toList();
    } else if (_filtroSelecionado == "Intervalo" && _intervaloSelecionado != null) {
      filtrados = _historicoCompleto.where((r) {
        final dataRegistro = DateTime(r.dataHora.year, r.dataHora.month, r.dataHora.day);
        final inicioIntervalo = DateTime(_intervaloSelecionado!.start.year, _intervaloSelecionado!.start.month, _intervaloSelecionado!.start.day);
        final fimIntervalo = DateTime(_intervaloSelecionado!.end.year, _intervaloSelecionado!.end.month, _intervaloSelecionado!.end.day);
        return !dataRegistro.isBefore(inicioIntervalo) && !dataRegistro.isAfter(fimIntervalo);
      }).toList();
    }
    else { // "Todos" ou fallback
      filtrados = List.from(_historicoCompleto);
    }

    // A lista _historicoCompleto já está ordenada, então os subconjuntos filtrados também estarão.
    setState(() {
      _historicoFiltrado = filtrados;
    });
  }


  Widget _buildChipFiltro(String label) {
    bool isSelected = _filtroSelecionado == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            if (mounted) {
              setState(() {
                _filtroSelecionado = label;
                _intervaloSelecionado = null; // Reseta o intervalo se outro chip for selecionado
                _aplicarFiltro();
              });
            }
          }
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: const Color(0xFFF9A825).withOpacity(0.3),
        labelStyle: TextStyle(
            color: isSelected ? const Color(0xFFF9A825) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? const Color(0xFFF9A825) : Colors.grey.shade300,
            )),
      ),
    );
  }

  Future<void> _selecionarIntervalo() async {
    final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020), // Data inicial permitida
        lastDate: DateTime.now().add(const Duration(days: 365)), // Data final permitida
        initialDateRange: _intervaloSelecionado ?? DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        ),
        locale: const Locale('pt', 'BR'), // Localização para português
        helpText: 'SELECIONE UM INTERVALO',
        cancelText: 'CANCELAR',
        confirmText: 'OK',
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFF9A825), // Cor principal
                onPrimary: Colors.white, // Cor do texto sobre a cor principal
                onSurface: Colors.black87, // Cor do texto geral
              ),
              dialogBackgroundColor: Colors.white,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF9A825), // Cor dos botões de texto
                ),
              ),
            ),
            child: child!,
          );
        });

    if (picked != null) {
      if (mounted) {
        setState(() {
          _intervaloSelecionado = picked;
          _filtroSelecionado = "Intervalo"; // Define o filtro para "Intervalo"
          _aplicarFiltro();
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarPoti(
        scaffoldKey: _scaffoldKey,
        titleText: "Histórico de Alimentação",
      ),
      drawer: const SideMenu(),
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildChipFiltro("Hoje"),
                      _buildChipFiltro("Ontem"),
                      _buildChipFiltro("Últimos 7 dias"),
                      _buildChipFiltro("Todos"), // Adicionado para ver todos os registros
                      IconButton(
                        icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFFF9A825)),
                        onPressed: _selecionarIntervalo,
                        tooltip: "Selecionar intervalo personalizado",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF9A825)))
                : _historicoFiltrado.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _historicoCompleto.isEmpty
                      ? "Nenhum registro de alimentação encontrado."
                      : "Nenhum registro encontrado para o filtro selecionado.",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: _carregarHistorico, // Permite "puxar para atualizar"
              color: const Color(0xFFF9A825),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                itemCount: _historicoFiltrado.length,
                itemBuilder: (context, index) {
                  final registro = _historicoFiltrado[index];
                  return Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: registro.concluido
                            ? const Color(0xFFF9A825).withOpacity(0.2)
                            : Colors.orange.withOpacity(0.15),
                        child: Icon(
                          registro.tipo.toLowerCase().contains('plano') || registro.tipo.toLowerCase().contains('rotina')
                              ? Icons.calendar_month_outlined
                              : registro.tipo.toLowerCase().contains('manual')
                              ? Icons.touch_app_outlined // Ícone para manual
                              : Icons.pets, // Ícone padrão
                          color: registro.concluido
                              ? const Color(0xFFF9A825)
                              : Colors.orange.shade700,
                        ),
                      ),
                      title: Text(
                        registro.nomePlano?.isNotEmpty == true ? registro.nomePlano! : registro.tipo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // Formata a data e hora para o padrão brasileiro
                            DateFormat('EEEE, dd/MM/yyyy – HH:mm','pt_BR').format(registro.dataHora),
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                          Text(
                            "Quantidade: ${registro.quantidade % 1 == 0 ? registro.quantidade.toInt() : registro.quantidade.toStringAsFixed(1)}g" // Mostra inteiro ou decimal
                                "${registro.petNome.isNotEmpty ? ' para ${registro.petNome}' : ''}",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        registro.concluido
                            ? Icons.check_circle
                            : Icons.watch_later_outlined,
                        color: registro.concluido
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                        size: 28,
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}