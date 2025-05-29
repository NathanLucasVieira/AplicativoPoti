import 'package:flutter/material.dart';

class AppBarPoti extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AppBarPoti({
    super.key,
    this.titleText,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      iconTheme: const IconThemeData(color: Colors.black54),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
            scaffoldKey.currentState?.closeDrawer();
          } else {
            scaffoldKey.currentState?.openDrawer();
          }
        },
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('imagens/logo_sem_fundo.png', height: 30),
          const SizedBox(width: 8),
          Text(
            titleText ?? 'P.O.T.I',
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}