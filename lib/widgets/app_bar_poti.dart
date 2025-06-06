import 'package:flutter/material.dart';
import 'package:trabalhopoti/widgets/pet_card.dart';

class AppBarPoti extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Pet? selectedPet;
  final VoidCallback? onSelectedPetTap;

  const AppBarPoti({
    super.key,
    this.titleText,
    required this.scaffoldKey,
    this.selectedPet,
    this.onSelectedPetTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget;

    // Título customizado quando um pet está selecionado.
    if (selectedPet != null) {
      titleWidget = GestureDetector(
        onTap: onSelectedPetTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (selectedPet!.fotoUrl != null && selectedPet!.fotoUrl!.isNotEmpty)
                  ? NetworkImage(selectedPet!.fotoUrl!)
                  : null,
              child: (selectedPet!.fotoUrl == null || selectedPet!.fotoUrl!.isEmpty)
                  ? Icon(Icons.pets, size: 20, color: Colors.grey.shade700)
                  : null,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                selectedPet!.nome,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onSelectedPetTap != null)
              const Icon(Icons.arrow_drop_down, color: Colors.black54),
          ],
        ),
      );
    } else {
      // Título padrão com logo.
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('imagens/logo_sem_fundo.png', height: 30),
          const SizedBox(width: 8),
          Text(
            titleText ?? 'P.O.T.I',
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      iconTheme: const IconThemeData(color: Colors.black54),
      // Ícone para abrir o menu lateral.
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {

          scaffoldKey.currentState?.openDrawer();
        },
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      ),
      title: titleWidget,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}