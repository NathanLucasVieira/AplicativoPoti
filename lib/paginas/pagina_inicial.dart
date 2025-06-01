import 'package:flutter/material.dart';
import 'package:projetoflutter/widgets/side_bar_menu.dart';
import 'package:projetoflutter/widgets/app_bar_poti.dart';
// Importe a TelaDispositivoConectado para navegação direta
import 'package:projetoflutter/paginas/tela_dispositivo_conectado.dart';

class PaginaInicialRefatorada extends StatefulWidget {
  const PaginaInicialRefatorada({super.key});

  @override
  State<PaginaInicialRefatorada> createState() =>
      _PaginaInicialRefatoradaState();
}

class _PaginaInicialRefatoradaState extends State<PaginaInicialRefatorada> {
  bool _permGranted = false;
  bool _showPopup = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildContentArea(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 380,
              height: 400,
              padding: const EdgeInsets.all(30.0),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'imagens/Add_Dispositivo.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text("Sem dispositivos",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  const Text("Conecte-se ao alimentador\nVia Wi-Fi",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showPopup = true;
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Adicionar Dispositivos",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9A825),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAddDevicePopup(BuildContext context) {
    Widget popupContent;
    Alignment alignment;
    double containerWidth;
    double? containerHeight;

    if (!_permGranted) {
      alignment = const Alignment(0.85, 0.0);
      containerWidth = 350;
      containerHeight = null;
      popupContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              "Precisamos da sua permissão para procurar\ndispositivos P.O.T.I próximos.",
              style: TextStyle(fontSize: 14)),
          const SizedBox(height: 25),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _permGranted = true;
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9A825)),
              child: const Text("Conceder Permissão",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      );
    } else {
      alignment = const Alignment(0.0, 0.6);
      containerWidth = 500;
      containerHeight = 300.0; // Altura ajustável se necessário
      popupContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField('Nome do Dispositivo', 'Ex: Poti Cozinha', null),
          const SizedBox(height: 15),
          _buildTextField('ID do Dispositivo', 'Ex: POTI-123456', null),
          const SizedBox(height: 25),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // ignore: avoid_print
                print("Dispositivo cadastrado - Conexão Fictícia");
                setState(() {
                  _showPopup = false;
                  _permGranted = false;
                });
                // Alterado de volta para MaterialPageRoute para consistência com main.dart simplificado
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TelaDispositivoConectado()),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9A825)),
              child: const Text("Cadastrar",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      );
    }

    return Align(
      alignment: alignment,
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: containerWidth,
          height: containerHeight, // Pode ser null para altura automática
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Importante se height for null
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    !_permGranted
                        ? "Permissão Necessária"
                        : "Cadastro de Dispositivo",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showPopup = false;
                        _permGranted = false;
                      });
                    },
                    splashRadius: 20,
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 15),
              // Flexible é útil se o conteúdo puder exceder a altura
              Flexible(
                child: SingleChildScrollView(
                  child: popupContent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController? controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
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
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBarPoti(
        scaffoldKey: _scaffoldKey,
      ),
      drawer: const SideMenu(),
      body: Stack(
        children: [
          _buildContentArea(context),
          if (_showPopup) _buildAddDevicePopup(context),
        ],
      ),
    );
  }
}