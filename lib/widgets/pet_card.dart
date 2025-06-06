import 'package:flutter/material.dart';

class Pet {
  final String id;
  final String nome;
  final String raca;
  final String? fotoUrl;
  final String? tamanho;

  Pet({required this.id, required this.nome, required this.raca, this.fotoUrl, this.tamanho});

  factory Pet.fromMap(Map<String, dynamic> data, String documentId) {
    return Pet(
      id: documentId,
      nome: data['nome'] ?? 'Sem nome',
      raca: data['raca'] ?? 'Sem raça',
      fotoUrl: data['fotoUrl'],
      // Compatibilidade com o campo 'peso' que agora é 'tamanho'.
      tamanho: data['peso'] ?? data['tamanho'] ?? 'Não informado',
    );
  }
}

class PetCard extends StatelessWidget {
  final Pet pet;
  final bool isSelected;

  const PetCard({super.key, required this.pet, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    // Cores baseadas na seleção.
    final cardColor = isSelected ? const Color(0xFFF9A825) : const Color(0xFFFEF6E6);
    final textColor = isSelected ? Colors.white : const Color(0xFF8D5B2A);
    final secondaryTextColor = isSelected ? Colors.white70 : const Color(0xFFA17A53);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          // Informações do Pet (Nome, Raça, Tamanho).
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(pet.nome, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("Raça: ${pet.raca}", style: TextStyle(fontSize: 14, color: secondaryTextColor), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("Tamanho: ${pet.tamanho}", style: TextStyle(fontSize: 14, color: secondaryTextColor), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Avatar do Pet.
          CircleAvatar(
            radius: 38,
            backgroundColor: isSelected ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
            backgroundImage: pet.fotoUrl != null ? NetworkImage(pet.fotoUrl!) : null,
            child: pet.fotoUrl == null ? Icon(Icons.pets, size: 38, color: isSelected ? Colors.white70 : const Color(0xFFC5A686)) : null,
          ),
        ],
      ),
    );
  }
}