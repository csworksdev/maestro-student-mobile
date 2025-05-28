import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maestro_client_mobile/pages/jadwalsiswa/jadwalpertemuan_siswa.dart';
import '../ordersiswa/orderhistory_page.dart';

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double scaleWidth(BuildContext context, double value) => value * screenWidth(context) / 375;
double scaleHeight(BuildContext context, double value) => value * screenHeight(context) / 812;

class JadwalSiswaPage extends StatefulWidget {
  const JadwalSiswaPage({Key? key}) : super(key: key);

  @override
  State<JadwalSiswaPage> createState() => _JadwalSiswaPageState();
}

class _JadwalSiswaPageState extends State<JadwalSiswaPage> {
  late Future<List<Order>> _ordersFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  Color get searchBarColor => Colors.white;
  Color get searchHintColor => Colors.grey.shade400;
  Color get primaryColor => Color(0xEF003566);
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() {
    setState(() {
      _ordersFuture = fetchOrders();
    });
  }

  Future<void> _onRefresh() async {
    _fetchOrders();
    await _ordersFuture;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Jadwal Siswa',
          style: GoogleFonts.poppins(
            fontSize: scaleWidth(context, 20),
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: primaryColor,
        backgroundColor: Colors.white,
        child: FutureBuilder<List<Order>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                children: [
                  SizedBox(height: size.height * 0.25),
                  Center(child: CircularProgressIndicator()),
                  SizedBox(height: 16),
                  Center(child: Text('Memuat data, mohon tunggu...', style: GoogleFonts.poppins())),
                ],
              );
            } else if (snapshot.hasError) {
              return ListView(
                children: [
                  SizedBox(height: size.height * 0.22),
                  Center(child: Icon(Icons.wifi_off, color: Colors.red, size: 48)),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Gagal mengambil data jadwal.\nPeriksa koneksi internet Anda.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.red, fontSize: scaleWidth(context, 16)),
                    ),
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _onRefresh,
                      icon: Icon(Icons.refresh),
                      label: Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: size.height * 0.25),
                  Center(
                    child: Text(
                      'Belum ada jadwal siswa.',
                      style: GoogleFonts.poppins(fontSize: scaleWidth(context, 16)),
                    ),
                  ),
                ],
              );
            }

            final orders = snapshot.data!;
            // Group siswa by orderId
            final List<Map<String, dynamic>> siswaList = [];
            for (var order in orders) {
              for (var siswa in order.students) {
                final nama = siswa['student_fullname'] ?? '-';
                siswaList.add({
                  'nama': nama,
                  'siswa': siswa,
                  'order': order,
                });
              }
            }

            // Filter by search
            final filteredSiswaList = siswaList.where((entry) {
              final nama = (entry['nama'] as String).toLowerCase();
              return nama.contains(_searchController.text.toLowerCase());
            }).toList();

            return Column(
              children: [
                // Search Bar
                AnimatedContainer(
                  duration: Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.only(bottom: size.height * 0.02, top: size.height * 0.025, left: size.width * 0.04, right: size.width * 0.04),
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  decoration: BoxDecoration(
                    color: searchBarColor,
                    borderRadius: BorderRadius.circular(38),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => RotationTransition(turns: anim, child: child),
                        child: _isSearching && _searchController.text.isNotEmpty
                            ? GestureDetector(
                                key: ValueKey('close'),
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _isSearching = false;
                                  });
                                },
                                child: Icon(Icons.close, color: primaryColor, size: size.width * 0.06),
                              )
                            : Icon(Icons.search, key: ValueKey('search'), color: Color(0xEF003566)),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Expanded(
                        child: FocusScope(
                          child: Focus(
                            onFocusChange: (hasFocus) {
                              setState(() {
                                _isSearching = hasFocus || _searchController.text.isNotEmpty;
                              });
                            },
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _isSearching = val.isNotEmpty;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Search...",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: searchHintColor,
                                  fontSize: size.width * 0.042,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                ),
                              ),
                              style: GoogleFonts.nunito(
                                fontSize: size.width * 0.042,
                              ),
                              cursorColor: Color(0xEF003566),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredSiswaList.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ditemukan siswa.',
                            style: GoogleFonts.poppins(fontSize: scaleWidth(context, 16)),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.only(
                            left: scaleWidth(context, 12),
                            right: scaleWidth(context, 12),
                            bottom: scaleHeight(context, 16),
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: scaleWidth(context, 12),
                            mainAxisSpacing: scaleHeight(context, 14),
                            childAspectRatio: 0.72,
                          ),
                          itemCount: filteredSiswaList.length,
                          itemBuilder: (context, idx) {
                            final entry = filteredSiswaList[idx];
                            final namaSiswa = entry['nama'];
                            final siswa = entry['siswa'];
                            final order = entry['order'] as Order;
                            return buildCategoryCard(
                              icon: Icons.person,
                              title: namaSiswa,
                              color: Color(0xEF003566),
                              gradient: LinearGradient(colors: [Color(0xFF003566), Color.fromARGB(255, 0, 100, 200)]),
                              iconGradient: LinearGradient(colors: [Color(0xFF003566), Color.fromARGB(255, 0, 100, 200)]),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JadwalPertemuanSiswaPage(
                                      order: order,
                                      siswa: siswa,
                                    ),
                                  ),
                                );
                              },
                              accent: Icon(Icons.star, color: Colors.white.withOpacity(0.13), size: 60),
                              subtitle: order.poolName,
                              trailing: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.22),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(7),
                                child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Card model seperti dashboard
  Widget buildCategoryCard({
    required IconData icon,
    required String title,
    required Color color,
    Gradient? gradient,
    Gradient? iconGradient,
    VoidCallback? onTap,
    Widget? accent,
    String? subtitle,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 0.9,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? color : null,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Stack(
            children: [
              if (accent != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: accent,
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: iconGradient ?? LinearGradient(colors: [color.withOpacity(0.7), color]),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(icon, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle ?? '-',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                  if (trailing != null)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 2.0),
                        child: trailing,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
