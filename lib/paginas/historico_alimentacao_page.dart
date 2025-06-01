import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de data e hora
import 'package:projetoflutter/widgets/app_bar_poti.dart'; //
import 'package:projetoflutter/widgets/side_bar_menu.dart'; //

// Modelo de dados para um registro de alimentação (substitua pelo seu modelo do Firebase)
class RegistroAlimentacao {
  final String id;
  final DateTime dataHora;
  final String tipo; // Ex: "Programada", "Manual", "Plano Viagem"
  final double quantidade; // Em gramas
  final String petNome; // Nome do pet, se aplicável
  final bool concluido; // true se concluído, false se pendente/falhou

  RegistroAlimentacao({
    required this.id,
    required this.dataHora,
    required this.tipo,
    required this.quantidade,
    this.petNome = "Pet", // Default
    required this.concluido,
  });
}

class HistoricoAlimentacaoPage extends StatefulWidget {
  const HistoricoAlimentacaoPage({super.key});

  @override
  State<HistoricoAlimentacaoPage> createState() =>
      _HistoricoAlimentacaoPageState();
}

class _HistoricoAlimentacaoPageState extends State<HistoricoAlimentacaoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<RegistroAlimentacao> _historico = [];
  bool _isLoading = true;
  String _filtroSelecionado = "Hoje"; // Filtros: "Hoje", "Ontem", "7 dias"

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    setState(() {
      _isLoading = true;
    });
    // TODO: Implementar lógica para buscar o histórico do Firebase
    // Abaixo, dados de exemplo:
    await Future.delayed(const Duration(seconds: 1)); // Simula a latência da rede

    // Dados de exemplo baseados na imagem image_d82b86.png
    // Note que a imagem tem "Quarta-Feira 25/02/2025", que é uma data futura.
    // Para "Hoje", "Ontem", etc. funcionarem, usarei datas relativas a agora.
    final now = DateTime.now();
    _historico = [
      RegistroAlimentacao(
          id: '1',
          dataHora: DateTime(2025, 2, 25, 22, 00), // Data da imagem
          tipo: "Plano de alimentação - Viagem",
          quantidade: 150,
          petNome: "Max",
          concluido: true),
      RegistroAlimentacao(
          id: '2',
          dataHora: now.subtract(const Duration(hours: 2)),
          tipo: "Refeição Extra",
          quantidade: 50,
          petNome: "Bella",
          concluido: false), // Pendente/Agendado (ícone de relógio)
      RegistroAlimentacao(
          id: '3',
          dataHora: now.subtract(const Duration(days: 1, hours: 5)),
          tipo: "Programada",
          quantidade: 120,
          petNome: "Max",
          concluido: true),
      RegistroAlimentacao(
          id: '4',
          dataHora: now.subtract(const Duration(days: 3, hours: 1)),
          tipo: "Manual",
          quantidade: 80,
          concluido: true),
    ];

    // Aplicar filtro inicial (se houver)
    _aplicarFiltro();

    setState(() {
      _isLoading = false;
    });
  }

  void _aplicarFiltro() {
    // TODO: Rebuscar do Firebase com o filtro ou filtrar a lista local
    // Por enquanto, filtrando a lista local para demonstração
    List<RegistroAlimentacao> historicoFiltrado = [];
    final now = DateTime.now();
    final hoje = DateTime(now.year, now.month, now.day);
    final ontem = hoje.subtract(const Duration(days: 1));
    final seteDiasAtras = hoje.subtract(const Duration(days: 6)); // Inclui hoje

    // Lógica de filtro (simplificada)
    // Adicionar todos os itens se não houver filtro específico ou se for "Todos"
    // Aqui, vamos apenas recarregar tudo e depois filtrar no build para simplicidade
    // ou filtrar a lista _historico aqui mesmo e atualizar o estado.

    // Para o propósito deste exemplo, vamos assumir que _carregarHistorico
    // já traria os dados corretos ou que o filtro é aplicado no backend.
    // Se for filtrar localmente, a lógica seria algo como:
    /*
    if (_filtroSelecionado == "Hoje") {
      historicoFiltrado = _historico.where((r) => DateUtils.isSameDay(r.dataHora, hoje)).toList();
    } else if (_filtroSelecionado == "Ontem") {
      historicoFiltrado = _historico.where((r) => DateUtils.isSameDay(r.dataHora, ontem)).toList();
    } else if (_filtroSelecionado == "7 dias") {
      historicoFiltrado = _historico.where((r) => r.dataHora.isAfter(seteDiasAtras.subtract(Duration(days:1))) && r.dataHora.isBefore(hoje.add(Duration(days:1)))).toList();
    } else {
      historicoFiltrado = List.from(_historico); // Mostrar todos ou default
    }
    setState(() {
      // _historico = historicoFiltrado; // CUIDADO: isso modifica a lista original.
      // Melhor ter uma lista separada para exibição.
    });
    */
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
            setState(() {
              _filtroSelecionado = label;
              _carregarHistorico(); // Recarrega os dados com o novo filtro
            });
          }
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: const Color(0xFFF9A825).withOpacity(0.3),
        labelStyle: TextStyle(
            color: isSelected ? const Color(0xFFF9A825) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? const Color(0xFFF9A825) : Colors.grey.shade300,
            )
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Filtrar a lista _historico com base em _filtroSelecionado antes de construir a lista
    List<RegistroAlimentacao> historicoExibido = [];
    final now = DateTime.now();
    final hoje = DateTime(now.year, now.month, now.day);
    final ontem = hoje.subtract(const Duration(days: 1));
    final seteDiasAtras = hoje.subtract(const Duration(days: 6));

    if (!_isLoading) {
      if (_filtroSelecionado == "Hoje") {
        historicoExibido = _historico.where((r) => DateUtils.isSameDay(r.dataHora, hoje)).toList();
      } else if (_filtroSelecionado == "Ontem") {
        historicoExibido = _historico.where((r) => DateUtils.isSameDay(r.dataHora, ontem)).toList();
      } else if (_filtroSelecionado == "Últimos 7 dias") {
        historicoExibido = _historico.where((r) =>
        !r.dataHora.isBefore(seteDiasAtras) && !r.dataHora.isAfter(hoje.add(const Duration(days: 1)))
        ).toList();
      } else { // "Todos" ou filtro não reconhecido mostra tudo por enquanto
        historicoExibido = List.from(_historico);
      }
      // Ordenar do mais recente para o mais antigo
      historicoExibido.sort((a, b) => b.dataHora.compareTo(a.dataHora));
    }


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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildChipFiltro("Hoje"),
                    _buildChipFiltro("Ontem"),
                    _buildChipFiltro("Últimos 7 dias"),
                    IconButton(
                      icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFFF9A825)),
                      onPressed: () async {
                        // TODO: Implementar seletor de data customizado
                        final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFFF9A825),
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                  dialogBackgroundColor: Colors.white,
                                ),
                                child: child!,
                              );
                            }
                        );
                        if (picked != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Intervalo selecionado: ${DateFormat('dd/MM/yy').format(picked.start)} - ${DateFormat('dd/MM/yy').format(picked.end)} (TODO: aplicar filtro)')),
                          );
                          // setState(() { _filtroSelecionado = "Custom"; }); // E aplicar a lógica de filtro
                        }
                      },
                      tooltip: "Selecionar intervalo",
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF9A825)))
                : historicoExibido.isEmpty
                ? Center(
              child: Text(
                "Nenhum registro encontrado para '$_filtroSelecionado'.",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              itemCount: historicoExibido.length,
              itemBuilder: (context, index) {
                final registro = historicoExibido[index];
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
                          : Colors.grey.shade300,
                      child: Icon(
                        Icons.pets,
                        color: registro.concluido
                            ? const Color(0xFFF9A825)
                            : Colors.grey.shade700,
                      ),
                    ),
                    title: Text(
                      registro.tipo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // Ex: "Quarta-feira, 25/02/2025 - 22:00"
                          "${DateFormat('EEEE, dd/MM/yyyy – HH:mm', 'pt_BR').format(registro.dataHora)}",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                        Text(
                          "Quantidade: ${registro.quantidade.toStringAsFixed(0)}g"
                              "${registro.petNome.isNotEmpty && registro.petNome != "Pet" ? ' para ${registro.petNome}' : ''}",
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
        ],
      ),
    );
  }
}