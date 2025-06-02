// lib/paginas/cadastrar_rotina_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:projetoflutter/widgets/app_bar_poti.dart';
import 'package:projetoflutter/widgets/side_bar_menu.dart';

class CadastrarRotinaPage extends StatefulWidget {
  const CadastrarRotinaPage({super.key});

  @override
  State<CadastrarRotinaPage> createState() => _CadastrarRotinaPageState();
}

class _CadastrarRotinaPageState extends State<CadastrarRotinaPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomePlanoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;

  bool _isLoading = false;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
        helpText: 'SELECIONE O HORÁRIO',
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFF9A825),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              timePickerTheme: TimePickerThemeData(
                dialHandColor: const Color(0xFFF9A825),
                hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected) ? Colors.white : Colors.black), // Corrigido
                hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected) ? const Color(0xFFF9A825) : Colors.grey.shade300),
                dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected) ? Colors.white : Colors.black),
                dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected) ? const Color(0xFFF9A825) : Colors.grey.shade300),
                dayPeriodBorderSide: const BorderSide(color: Color(0xFFF9A825)),
                helpTextStyle: const TextStyle(color: Color(0xFFF9A825)),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF9A825),
                ),
              ),
            ),
            child: child!,
          );
        }
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime(2101),
        locale: const Locale('pt', 'BR'),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFF9A825),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF9A825),
                ),
              ),
            ),
            child: child!,
          );
        }
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _cadastrarRotina() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione data e horário.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.'), backgroundColor: Colors.red),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('historico_alimentacao').add({
        'userId': currentUser.uid,
        'nomePlano': _nomePlanoController.text.trim(),
        'dataHora': Timestamp.fromDate(combinedDateTime),
        'quantidade': double.tryParse(_quantidadeController.text.trim()) ?? 0.0,
        'tipo': 'Plano - ${_nomePlanoController.text.trim()}',
        'concluido': false,
        'petNome': '',
        'criadoEm': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rotina de alimentação cadastrada!'), backgroundColor: Colors.green),
      );
      _nomePlanoController.clear();
      _quantidadeController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar rotina: ${e.toString()}'), backgroundColor: Colors.red),
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
    const Color laranjaPrincipal = Color(0xFFF9A825);
    const Color laranjaClarinho = Color(0xFFEEEEEE);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarPoti(
        scaffoldKey: _scaffoldKey,
        titleText: "Criar Rotina de Alimentação",
      ),
      drawer: const SideMenu(),
      backgroundColor: const Color(0xFFFAFAFA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: laranjaClarinho,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Detalhes da Rotina",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade700,
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: _nomePlanoController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Plano (Ex: Viagem, Manhã)',
                          labelStyle: TextStyle(color: Colors.brown.shade400),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          prefixIcon: Icon(Icons.label_outline, color: laranjaPrincipal),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: laranjaPrincipal, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          floatingLabelStyle: const TextStyle(color: laranjaPrincipal),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira o nome do plano.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Data',
                                  labelStyle: TextStyle(color: Colors.brown.shade400),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                  prefixIcon: Icon(Icons.calendar_today, color: laranjaPrincipal),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: laranjaPrincipal, width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  floatingLabelStyle: const TextStyle(color: laranjaPrincipal),
                                ),
                                child: Text(
                                  _selectedDate == null
                                      ? 'Selecione a Data'
                                      : DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDate!),
                                  style: TextStyle(
                                    color: _selectedDate == null ? Colors.grey.shade700 : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Horário',
                                  labelStyle: TextStyle(color: Colors.brown.shade400),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                  prefixIcon: Icon(Icons.access_time, color: laranjaPrincipal),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: laranjaPrincipal, width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  floatingLabelStyle: const TextStyle(color: laranjaPrincipal),
                                ),
                                child: Text(
                                  _selectedTime == null
                                      ? 'Selecione o Horário'
                                      : _selectedTime!.format(context),
                                  style: TextStyle(
                                    color: _selectedTime == null ? Colors.grey.shade700 : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _quantidadeController,
                        decoration: InputDecoration(
                          labelText: 'Quantidade (gramas)',
                          labelStyle: TextStyle(color: Colors.brown.shade400),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          prefixIcon: Icon(Icons.restaurant_menu, color: laranjaPrincipal),
                          suffixText: 'g',
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: laranjaPrincipal, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          floatingLabelStyle: const TextStyle(color: laranjaPrincipal),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Insira a quantidade.';
                          }
                          if (double.tryParse(value.trim()) == null || double.parse(value.trim()) <= 0) {
                            return 'Insira uma quantidade válida.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: Image.asset(
                          'imagens/food_bow.png',
                          height: 100,
                          fit: BoxFit.contain,
                          color: laranjaPrincipal.withOpacity(0.8),
                          errorBuilder: (context, error, stackTrace) {
                            // ignore: avoid_print
                            print("Erro ao carregar imagem da tigela: $error");
                            return Icon(Icons.pets, size: 100, color: Colors.grey.shade400);
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: laranjaPrincipal))
                          : ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                        label: const Text(
                          'Adicionar Rotina',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        onPressed: _cadastrarRotina,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: laranjaPrincipal,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 3.0,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          if (_isLoading) return;
                          _nomePlanoController.clear();
                          _quantidadeController.clear();
                          setState(() {
                            _selectedDate = null;
                            _selectedTime = null;
                            _formKey.currentState?.reset();
                          });
                        },
                        child: Text(
                          'Limpar Campos',
                          style: TextStyle(color: Colors.brown.shade500, fontSize: 15),
                        ),
                        style: TextButton.styleFrom(
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
      ),
    );
  }
}