// lib/widgets/pet_card.dart
import 'package:flutter/material.dart';

class Pet {
  final String id;
  final String nome;
  final String raca;
  final String? fotoUrl;
  final String? tamanho; // No Firestore, este campo pode ter sido salvo como 'peso'

  Pet({
    required this.id,
    required this.nome,
    required this.raca,
    this.fotoUrl,
    this.tamanho,
  });

  factory Pet.fromMap(Map<String, dynamic> data, String documentId) {
    return Pet(
      id: documentId,
      nome: data['nome'] as String? ?? 'Nome não informado',
      raca: data['raca'] as String? ?? 'Raça não informada',
      fotoUrl: data['fotoUrl'] as String?,
      // Prioriza o campo 'peso', depois 'tamanho', depois um default.
      // Isso é para compatibilidade com a tela de cadastro de pet que usava 'peso'.
      tamanho: data['peso'] as String? ?? data['tamanho'] as String? ?? 'Tamanho não informado',
    );
  }
}

// O restante do seu widget PetCard continua aqui...
class PetCard extends StatelessWidget {
  final Pet pet;
  final bool isSelected;

  const PetCard({
    super.key,
    required this.pet,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor =
    isSelected ? const Color(0xFFF9A825) : const Color(0xFFFEF6E6);
    final Color textColor =
    isSelected ? Colors.white : const Color(0xFF8D5B2A);
    final Color secondaryTextColor =
    isSelected ? Colors.white70 : const Color(0xFFA17A53);
    final Color avatarIconColor =
    isSelected ? Colors.white70 : const Color(0xFFC5A686);
    final Color avatarPlaceholderBackgroundColor =
    isSelected ? Colors.white.withOpacity(0.1) : Colors.grey.shade200;


    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pet.nome,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Raça: ${pet.raca}",
                  style: TextStyle(fontSize: 14, color: secondaryTextColor),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  // Usa o campo 'tamanho' da classe Pet, que já foi tratado no fromMap
                  "Tamanho: ${pet.tamanho}",
                  style: TextStyle(fontSize: 14, color: secondaryTextColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 38,
            backgroundColor: pet.fotoUrl != null && pet.fotoUrl!.isNotEmpty
                ? Colors.transparent
                : avatarPlaceholderBackgroundColor,
            backgroundImage: pet.fotoUrl != null && pet.fotoUrl!.isNotEmpty
                ? NetworkImage(pet.fotoUrl!)
                : null,
            child: (pet.fotoUrl == null || pet.fotoUrl!.isEmpty)
                ? Icon(Icons.pets, size: 38, color: avatarIconColor)
                : null,
          ),
        ],
      ),
    );
  }
}