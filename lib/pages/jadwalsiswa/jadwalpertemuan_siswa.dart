import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JadwalPertemuanSiswaPage extends StatefulWidget {
  final dynamic order;
  final dynamic siswa;

  const JadwalPertemuanSiswaPage({Key? key, required this.order, required this.siswa}) : super(key: key);

  @override
  State<JadwalPertemuanSiswaPage> createState() => _JadwalPertemuanSiswaPageState();
}

class _JadwalPertemuanSiswaPageState extends State<JadwalPertemuanSiswaPage> {
  late List details;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Simulasi fetch data, jika API, panggil ulang API di sini
      details = List.from(widget.order.details);
      details.sort((a, b) => (a.scheduleDate as String).compareTo(b.scheduleDate as String));
      await Future.delayed(Duration(milliseconds: 300)); // Simulasi loading
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal mengambil data. Periksa koneksi internet Anda.';
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchDetails();
  }

  @override
  Widget build(BuildContext context) {
    // final details = List.from(widget.order.details); // Sudah di-state
    // final namaSiswa = widget.siswa['student_fullname'] ?? '-';
    double scaleWidth(BuildContext context, double value) => value * MediaQuery.of(context).size.width / 375;
    double scaleHeight(BuildContext context, double value) => value * MediaQuery.of(context).size.height / 812;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jadwal Pertemuan',
          style: GoogleFonts.poppins(
            fontSize: scaleWidth(context, 20),
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Color(0xEF003566),
        backgroundColor: Colors.white,
        child: _isLoading
            ? ListView(
                children: [
                  SizedBox(height: scaleHeight(context, 200)),
                  Center(child: CircularProgressIndicator()),
                  SizedBox(height: 16),
                  Center(child: Text('Memuat data, mohon tunggu...', style: GoogleFonts.poppins())),
                ],
              )
            : _error != null
                ? ListView(
                    children: [
                      SizedBox(height: scaleHeight(context, 180)),
                      Center(child: Icon(Icons.wifi_off, color: Colors.red, size: 48)),
                      SizedBox(height: 12),
                      Center(
                        child: Text(
                          _error!,
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
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xEF003566), foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(scaleWidth(context, 16)),
                    itemCount: details.length,
                    itemBuilder: (context, idx) {
                      final detail = details[idx];
                      final isPresence = detail.isPresence;
                      final isPaid = detail.isPaid;
                      final statusColor = isPresence ? Color(0xFF55FF5B) : Color(0xFFFFD000);
                      final statusIcon = isPresence ? Icons.verified_rounded : Icons.hourglass_top_rounded;
                      final paidColor = isPaid ? Color(0xFF55FF5B) : Color(0xFFFFD000);
                      final paidIcon = isPaid ? Icons.verified_rounded : Icons.hourglass_top_rounded;
                      final cardGradient = LinearGradient(
                        colors: [Color.fromARGB(237, 0, 132, 255), Color.fromARGB(199, 0, 53, 102)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      );
                      return Container(
                        margin: EdgeInsets.only(bottom: scaleHeight(context, 16)),
                        decoration: BoxDecoration(
                          gradient: cardGradient,
                          borderRadius: BorderRadius.circular(scaleWidth(context, 18)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: scaleWidth(context, 10),
                              offset: Offset(0, scaleHeight(context, 4)),
                            ),
                          ],
                          border: Border.all(color: Colors.white.withOpacity(0.18)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: scaleHeight(context, 18), horizontal: scaleWidth(context, 18)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: scaleWidth(context, 22),
                                    backgroundColor: Colors.white.withOpacity(0.18),
                                    child: Icon(statusIcon, color: Colors.white, size: scaleWidth(context, 28)),
                                  ),
                                  SizedBox(width: scaleWidth(context, 14)),
                                  Text(
                                    'Pertemuan ke-${detail.meet}',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: scaleWidth(context, 18), color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(height: scaleHeight(context, 10)),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: scaleWidth(context, 13), color: Colors.white),
                                  SizedBox(width: scaleWidth(context, 4)),
                                  Text('Tanggal: ${detail.scheduleDate}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 16), color: Colors.white)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.today, size: scaleWidth(context, 13), color: Colors.white),
                                  SizedBox(width: scaleWidth(context, 4)),
                                  Text('Hari: ${detail.day}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 16), color: Colors.white)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: scaleWidth(context, 13), color: Colors.white),
                                  SizedBox(width: scaleWidth(context, 4)),
                                  Text('Jam: ${detail.time}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 16), color: Colors.white)),
                                ],
                              ),
                              SizedBox(height: scaleHeight(context, 10)),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(context, 10), vertical: scaleHeight(context, 4)),
                                    decoration: BoxDecoration(
                                      color: isPresence ? Color(0xFF55FF5B).withOpacity(0.20) : Color.fromARGB(255, 255, 255, 255).withOpacity(0.20),
                                      borderRadius: BorderRadius.circular(scaleWidth(context, 8)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(statusIcon, size: scaleWidth(context, 15), color: statusColor),
                                        SizedBox(width: scaleWidth(context, 4)),
                                        Text(
                                          isPresence ? 'Hadir' : 'Belum Hadir',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: scaleWidth(context, 13),
                                            color: statusColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: scaleWidth(context, 10)),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: scaleWidth(context, 10), vertical: scaleHeight(context, 4)),
                                    decoration: BoxDecoration(
                                      color: isPaid ? Color(0xFF55FF5B).withOpacity(0.20) : Color.fromARGB(255, 255, 255, 255).withOpacity(0.20),
                                      borderRadius: BorderRadius.circular(scaleWidth(context, 8)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(paidIcon, size: scaleWidth(context, 15), color: paidColor),
                                        SizedBox(width: scaleWidth(context, 4)),
                                        Text(
                                          isPaid ? 'Sudah Bayar' : 'Belum Bayar',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: scaleWidth(context, 13),
                                            color: paidColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
