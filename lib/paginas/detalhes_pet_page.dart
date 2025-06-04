// lib/paginas/detalhes_pet_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Para File
import 'package:firebase_storage/firebase_storage.dart';
import 'package:projetoflutter/widgets/app_bar_poti.dart';
import 'package:projetoflutter/widgets/side_bar_menu.dart';
import 'package:projetoflutter/widgets/pet_card.dart'; // Para a classe Pet
import 'package:projetoflutter/paginas/tela_dispositivo_conectado.dart';

class DetalhesPetPage extends StatefulWidget {
  final Pet pet;

  const DetalhesPetPage({super.key, required this.pet});

  @override
  State<DetalhesPetPage> createState() => _DetalhesPetPageState();
}

class _DetalhesPetPageState extends State<DetalhesPetPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _racaController;
  String? _tamanhoSelecionado;
  File? _imagemSelecionada;
  String? _fotoUrlAtual;

  bool _isLoading = false;
  bool _isEditing = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<String> _opcoesTamanho = ['Pequeno', 'Médio', 'Grande'];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.pet.nome);
    _racaController = TextEditingController(text: widget.pet.raca);
    _fotoUrlAtual = widget.pet.fotoUrl;

    // Lógica para mapear o 'tamanho' do pet para uma das opções de dropdown
    if (widget.pet.tamanho != null && widget.pet.tamanho!.isNotEmpty) {
      final String tamanhoLower = widget.pet.tamanho!.toLowerCase();
      if (tamanhoLower.contains("pequeno") || tamanhoLower.contains("abaixo 14kg")) {
        _tamanhoSelecionado = 'Pequeno';
      } else if (tamanhoLower.contains("médio") || (tamanhoLower.contains("14") && tamanhoLower.contains("25"))) {
        _tamanhoSelecionado = 'Médio';
      } else if (tamanhoLower.contains("grande") || tamanhoLower.contains("acima 25kg")) {
        _tamanhoSelecionado = 'Grande';
      } else {
        _tamanhoSelecionado = null; // Caso não corresponda a nenhuma opção conhecida
      }
    } else {
      _tamanhoSelecionado = null;
    }
  }

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagemSelecionada = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImagem(File imageFile, String petId) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      String filePath = 'pets_fotos/${user.uid}/$petId/${DateTime.now().millisecondsSinceEpoch}.png';
      UploadTask uploadTask = _storage.ref().child(filePath).putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no upload da imagem: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_tamanhoSelecionado == null || _tamanhoSelecionado!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione o tamanho do pet.'), backgroundColor: Colors.orangeAccent),
        );
      }
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    String? novaFotoUrl = _fotoUrlAtual;
    if (_imagemSelecionada != null) {
      novaFotoUrl = await _uploadImagem(_imagemSelecionada!, widget.pet.id);
      if (novaFotoUrl == null && _imagemSelecionada != null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    try {
      await _firestore.collection('pets').doc(widget.pet.id).update({
        'nome': _nomeController.text.trim(),
        'raca': _racaController.text.trim(),
        'peso': _tamanhoSelecionado, // Salvando como 'peso' no Firestore
        'fotoUrl': novaFotoUrl,
        'atualizadoEm': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet atualizado!'), backgroundColor: Colors.green),
        );
        setState(() {
          _isEditing = false;
          _fotoUrlAtual = novaFotoUrl;
          _imagemSelecionada = null;
        });
        // Retorna true para indicar que a lista de pets precisa ser atualizada na página anterior
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _excluirPet() async {
    bool confirmar = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirmar Exclusão', style: TextStyle(color: Colors.black, fontSize: 18)),
        content: Text('Tem certeza que deseja excluir ${widget.pet.nome}?', style: const TextStyle(color: Colors.black54, fontSize: 14)),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.blueAccent, fontSize: 14)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white, fontSize: 14)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;

    if (confirmar) {
      if (mounted) setState(() => _isLoading = true);
      try {
        // Excluir registros de histórico de alimentação associados a este pet
        QuerySnapshot historicoSnapshot = await _firestore
            .collection('historico_alimentacao')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
            .where('petNome', isEqualTo: widget.pet.nome) // Ou qualquer outro campo que ligue ao pet
            .get();

        for (DocumentSnapshot doc in historicoSnapshot.docs) {
          await doc.reference.delete();
        }

        // Excluir o documento do pet
        await _firestore.collection('pets').doc(widget.pet.id).delete();

        // Excluir imagem do Storage se existir
        if (widget.pet.fotoUrl != null && widget.pet.fotoUrl!.isNotEmpty) {
          try {
            await _storage.refFromURL(widget.pet.fotoUrl!).delete();
          } catch (e) {
            // Ignorar erro se a imagem não existir ou já tiver sido excluída
            // ignore: avoid_print
            print("Erro ao excluir imagem do storage: $e");
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.pet.nome} excluído com sucesso.'), backgroundColor: Colors.orange),
          );
          // Navega de volta para a tela de pets conectados e limpa a pilha de navegação
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TelaDispositivoConectado()),
                (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if(mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarPoti(
        scaffoldKey: _scaffoldKey,
        titleText: _isEditing ? "Editar ${widget.pet.nome}" : "Detalhes de ${widget.pet.nome}",
      ),
      drawer: const SideMenu(),
      backgroundColor: Colors.grey[100], // Fundo mais suave
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // Limita a largura para tablets/web
            child: Card(
              elevation: 8.0, // Sombra mais proeminente
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), // Bordas mais arredondadas
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(30.0), // Padding aumentado
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Seção da imagem do pet
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 180, // Aumenta o tamanho da imagem
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(90), // Torna a imagem um círculo perfeito
                                border: Border.all(color: const Color(0xFFF9A825), width: 3), // Borda mais grossa
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: GestureDetector( // Permite selecionar imagem clicando na foto
                                  onTap: _isEditing ? _selecionarImagem : null,
                                  child: _imagemSelecionada != null
                                      ? Image.file(_imagemSelecionada!, fit: BoxFit.cover, width: 180, height: 180)
                                      : (_fotoUrlAtual != null && _fotoUrlAtual!.isNotEmpty
                                      ? Image.network(_fotoUrlAtual!, fit: BoxFit.cover, width: 180, height: 180,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Image.asset('imagens/logo_sem_fundo.png', fit: BoxFit.cover)) // Fallback se NetworkImage falhar
                                      : Image.asset('imagens/logo_sem_fundo.png', fit: BoxFit.cover)
                                  ),
                                ),
                              ),
                            ),
                            if (_isEditing)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF9A825),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3)
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(10.0), // Aumenta o padding do ícone
                                    child: Icon(Icons.camera_alt, color: Colors.white, size: 24), // Ícone maior
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Modo de Edição
                      if (_isEditing) ...[
                        _buildTextFieldWithLabel("Nome do Pet", "Digite o nome", _nomeController, Icons.pets),
                        const SizedBox(height: 20),
                        _buildTextFieldWithLabel("Raça", "Digite a raça", _racaController, Icons.category),
                        const SizedBox(height: 20),
                        _buildDropdownFieldWithLabel("Tamanho", _tamanhoSelecionado, _opcoesTamanho, (String? newValue) {
                          setState(() {
                            _tamanhoSelecionado = newValue;
                          });
                        }, Icons.scale),
                        const SizedBox(height: 30),
                        _buildActionButton("Salvar Alterações", _salvarAlteracoes, const Color(0xFFF9A825), Icons.save),
                        const SizedBox(height: 15),
                        _buildTextActionButton("Cancelar Edição", () {
                          setState(() {
                            _isEditing = false;
                            _imagemSelecionada = null;
                            _nomeController.text = widget.pet.nome;
                            _racaController.text = widget.pet.raca;
                            if (widget.pet.tamanho != null && widget.pet.tamanho!.isNotEmpty) {
                              final String tamanhoLower = widget.pet.tamanho!.toLowerCase();
                              if (tamanhoLower.contains("pequeno") || tamanhoLower.contains("abaixo 14kg")) {
                                _tamanhoSelecionado = 'Pequeno';
                              } else if (tamanhoLower.contains("médio") || (tamanhoLower.contains("14") && tamanhoLower.contains("25"))) {
                                _tamanhoSelecionado = 'Médio';
                              } else if (tamanhoLower.contains("grande") || tamanhoLower.contains("acima 25kg")) {
                                _tamanhoSelecionado = 'Grande';
                              } else {
                                _tamanhoSelecionado = null;
                              }
                            } else {
                              _tamanhoSelecionado = null;
                            }
                          });
                        }, Colors.grey.shade600),
                      ]
                      // Modo de Visualização
                      else ...[
                        Text(
                          widget.pet.nome,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFD4842C),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInfoDisplayRow("Raça:", widget.pet.raca, Icons.category),
                        _buildInfoDisplayRow("Tamanho:", widget.pet.tamanho ?? "Não informado", Icons.scale),
                        const SizedBox(height: 40),
                        _buildActionButton("Editar Informações", () {
                          setState(() {
                            _isEditing = true;
                            _nomeController.text = widget.pet.nome;
                            _racaController.text = widget.pet.raca;
                            if (widget.pet.tamanho != null && widget.pet.tamanho!.isNotEmpty) {
                              final String tamanhoLower = widget.pet.tamanho!.toLowerCase();
                              if (tamanhoLower.contains("pequeno") || tamanhoLower.contains("abaixo 14kg")) {
                                _tamanhoSelecionado = 'Pequeno';
                              } else if (tamanhoLower.contains("médio") || (tamanhoLower.contains("14") && tamanhoLower.contains("25"))) {
                                _tamanhoSelecionado = 'Médio';
                              } else if (tamanhoLower.contains("grande") || tamanhoLower.contains("acima 25kg")) {
                                _tamanhoSelecionado = 'Grande';
                              } else {
                                _tamanhoSelecionado = null;
                              }
                            } else {
                              _tamanhoSelecionado = null;
                            }
                            _imagemSelecionada = null;
                          });
                        }, const Color(0xFFF9A825), Icons.edit),
                        const SizedBox(height: 15),
                        _buildActionButton("Excluir Pet", _excluirPet, Colors.red.shade600, Icons.delete_forever),
                      ],
                      if (_isLoading) // Indicador de carregamento centralizado e mais visível
                        const Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Center(child: CircularProgressIndicator(color: Color(0xFFF9A825))),
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

  // campos de texto com label e ícone
  Widget _buildTextFieldWithLabel(String label, String hint, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFFF9A825)),
            filled: true,
            fillColor: Colors.grey[50], // Fundo mais claro
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0), // Bordas mais arredondadas
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder( // Borda em estado normal
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder( // Borda quando focado
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFF9A825), width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            labelStyle: TextStyle(color: Colors.grey.shade700),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo não pode ser vazio.';
            }
            return null;
          },
        ),
      ],
    );
  }

  // dropdown com label e ícone
  Widget _buildDropdownFieldWithLabel(String label, String? currentValue, List<String> items, ValueChanged<String?> onChanged, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFF9A825)),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFF9A825), width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            labelStyle: TextStyle(color: Colors.grey.shade700),
          ),
          items: items.map((String v) => DropdownMenuItem<String>(value: v, child: Text(v))).toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Selecione uma opção' : null,
        ),
      ],
    );
  }

//exibir informações em modo de visualização
  Widget _buildInfoDisplayRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF9A825), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButton(String text, VoidCallback onPressed, Color color, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white, size: 24),
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5.0,
        minimumSize: const Size(double.infinity, 60),
      ),
    );
  }


  Widget _buildTextActionButton(String text, VoidCallback onPressed, Color color) {
    return TextButton(
      onPressed: _isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: Text(text),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _racaController.dispose();
    super.dispose();
  }
}