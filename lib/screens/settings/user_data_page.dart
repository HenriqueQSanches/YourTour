import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../services/session_manager.dart';

class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key});

  @override
  State<UserDataPage> createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  final UserService _userService = UserService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = SessionManager.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Dados'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Color(0xFF6A1B9A), size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Meus Dados Pessoais',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFF3E5F5),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _user?.userName ?? 'Usuário',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Membro desde Jan 2024',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildDataList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nenhum usuário logado'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  _showEditDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'EDITAR DADOS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataList() {
    if (_user == null) {
      return const Center(
        child: Text('Nenhum usuário logado', style: TextStyle(color: Colors.grey)),
      );
    }

    final Map<String, String> data = {
      'Nome': _user!.userName,
      'Email': _user!.userEmail,
      'Telefone': _user!.userPhone,
      'Data de Nascimento': _user!.userBirth,
      'País': _user!.userCountry,
      'Gênero': _user!.userGender,
      'ID': (_user!.userId?.toString() ?? 'N/A'),
    };

    return ListView(
      children: data.entries.map((e) => _buildDataRow(e.key, e.value)).toList(),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    if (_user == null) return;
    final nameCtrl = TextEditingController(text: _user!.userName);
    final emailCtrl = TextEditingController(text: _user!.userEmail);
    final phoneCtrl = TextEditingController(text: _user!.userPhone);
    final birthCtrl = TextEditingController(text: _user!.userBirth);
    final countryCtrl = TextEditingController(text: _user!.userCountry);
    String selectedGender = _user!.userGender;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Dados'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameCtrl, 'Nome Completo', Icons.person),
                const SizedBox(height: 12),
                _buildTextField(emailCtrl, 'E-mail', Icons.email, TextInputType.emailAddress),
                const SizedBox(height: 12),
                _buildTextField(phoneCtrl, 'Telefone', Icons.phone, TextInputType.phone),
                const SizedBox(height: 12),
                _buildTextField(birthCtrl, 'Data de Nascimento (DD/MM/AAAA)', Icons.cake),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedGender.isNotEmpty ? selectedGender : null,
                  decoration: const InputDecoration(
                    labelText: 'Gênero',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                    DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                    DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                    DropdownMenuItem(value: 'Prefiro não informar', child: Text('Prefiro não informar')),
                  ],
                  onChanged: (v) => selectedGender = v ?? '',
                ),
                const SizedBox(height: 12),
                _buildTextField(countryCtrl, 'País', Icons.location_on),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (_user?.userId == null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ID do usuário ausente'), backgroundColor: Colors.red),
                  );
                  return;
                }
                final updated = _user!.copyWith(
                  userName: nameCtrl.text.trim(),
                  userEmail: emailCtrl.text.trim(),
                  userPhone: phoneCtrl.text.trim(),
                  userBirth: birthCtrl.text.trim(),
                  userGender: selectedGender,
                  userCountry: countryCtrl.text.trim(),
                );
                try {
                  final ok = await _userService.updateUser(updated);
                  if (ok) {
                    setState(() => _user = updated);
                    SessionManager.setCurrentUser(updated);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dados atualizados!'), backgroundColor: Colors.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Falha ao atualizar.'), backgroundColor: Colors.red),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon, [TextInputType? type]) {
    return TextField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}