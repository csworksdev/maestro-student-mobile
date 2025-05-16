import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// import 'package:provider/provider.dart';
// import 'package:maestro_client_mobile/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final String nama;
  final String kelas;
  final String kolam;
  final String phoneNumber;
  final int index; // Tambahkan index

  EditProfileScreen({
    required this.nama,
    required this.kelas,
    required this.kolam,
    required this.phoneNumber,
    required this.index,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController namaController;
  late TextEditingController kelasController;
  late TextEditingController kolamController;
  late TextEditingController phoneController;
  late String selectedKolam;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.nama);
    kelasController = TextEditingController(text: widget.kelas);
    kolamController = TextEditingController(text: widget.kolam);
    phoneController = TextEditingController(
      text: widget.phoneNumber.startsWith('0')
          ? widget.phoneNumber.replaceFirst('0', '+62')
          : widget.phoneNumber,
    );
    // Daftar kolam yang valid
    final kolamList = [
      'Kolam Renang Oasis',
      'Kolam Renang Abadi',
      'Kolam Renang GBLA',
    ];
    // Jika kolam lama tidak ada di daftar, pakai default
    selectedKolam = kolamList.contains(widget.kolam) ? widget.kolam : kolamList[0];
    kolamController.text = selectedKolam;
  }

  @override
  void dispose() {
    namaController.dispose();
    kelasController.dispose();
    kolamController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> siswaJsonList = prefs.getStringList('siswaList') ?? [];
    List<Map<String, String>> siswaList = siswaJsonList
        .map((siswaJson) => Map<String, String>.from(json.decode(siswaJson)))
        .toList();

    if (widget.index >= 0 && widget.index < siswaList.length) {
      siswaList[widget.index] = {
        'fullname': namaController.text,
        'bankAccount': kelasController.text,
        'email': selectedKolam, // gunakan selectedKolam
        'phoneNumber': phoneController.text,
      };
      await prefs.setStringList(
          'siswaList', siswaList.map((siswa) => json.encode(siswa)).toList());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Kembali dan trigger refresh
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, bool isDarkMode) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[900]),
      prefixIcon: Icon(
        icon,
        color: isDarkMode ? Colors.orange : const Color.fromARGB(240, 0, 53, 102),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isDarkMode ? Colors.white24 : Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isDarkMode ? Colors.white24 : Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color.fromARGB(240, 0, 53, 102)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Edit Data Siswa', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            buildTextField("Nama", namaController, Icons.person, isDarkMode),
            buildTextField("Kelas", kelasController, Icons.class_, isDarkMode),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: DropdownButtonFormField<String>(
                value: selectedKolam,
                decoration: _buildInputDecoration("Kolam", Icons.pool, isDarkMode),
                items: [
                  'Kolam Renang Oasis',
                  'Kolam Renang Abadi',
                  'Kolam Renang GBLA',
                ].map((kolam) {
                  return DropdownMenuItem(
                    value: kolam,
                    child: Text(kolam),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedKolam = value!;
                    kolamController.text = value;
                  });
                },
              ),
            ),
            buildTextField("No WhatsApp", phoneController, Icons.phone, isDarkMode, TextInputType.phone),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final shouldSave = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Konfirmasi'),
                      content: Text('Apakah Anda yakin ingin menyimpan perubahan?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); 
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red, 
                          ),
                          child: Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green, 
                          ),
                          child: Text('Ya'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldSave == true) {
                  updateProfile(); 
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? Colors.orange
                    : const Color.fromARGB(240, 0, 53, 102),
                foregroundColor: Colors.white,
              ),
              child: Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isDarkMode, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _buildInputDecoration(label, icon, isDarkMode),
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }
}