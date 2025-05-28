import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'orderhistory_page.dart';
import 'orderdatesiswa_page.dart';

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double scaleWidth(BuildContext context, double value) => value * screenWidth(context) / 375; // 375 = width iPhone 11
double scaleHeight(BuildContext context, double value) => value * screenHeight(context) / 812; // 812 = height iPhone 11

class DetailOrderHistorySiswaPage extends StatefulWidget {
  final Order order;
  const DetailOrderHistorySiswaPage({Key? key, required this.order}) : super(key: key);

  @override
  State<DetailOrderHistorySiswaPage> createState() => _DetailOrderHistorySiswaPageState();
}

class _DetailOrderHistorySiswaPageState extends State<DetailOrderHistorySiswaPage> {
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
      details = List.from(widget.order.details);
      details.sort((a, b) => a.meet.compareTo(b.meet));
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Order', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 18))),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Color(0xEF003566),
        backgroundColor: Colors.white,
        child: _isLoading
            ? ListView(
                children: [
                  SizedBox(height: scaleHeight(context, 120)),
                  Center(child: CircularProgressIndicator()),
                  SizedBox(height: 16),
                  Center(child: Text('Memuat data, mohon tunggu...', style: GoogleFonts.poppins())),
                ],
              )
            : _error != null
                ? ListView(
                    children: [
                      SizedBox(height: scaleHeight(context, 100)),
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
                : Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(scaleWidth(context, 16.0)),
                        child: ListView(
                          padding: EdgeInsets.only(bottom: scaleHeight(context, 16)),
                          children: [
                            ...details.map((detail) {
                              final isPresence = detail.isPresence;
                              final isPaid = detail.isPaid;
                              final statusColor = const Color.fromARGB(238, 0, 105, 204);
                              final statusIcon = isPresence
                                  ? Icons.verified_rounded
                                  : Icons.hourglass_top_rounded;
                              final cardGradient = const LinearGradient(
                                colors: [Color.fromARGB(238, 0, 105, 204), Color.fromARGB(238, 0, 105, 204)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              );
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: scaleHeight(context, 4), horizontal: 0),
                                decoration: BoxDecoration(
                                  gradient: cardGradient,
                                  borderRadius: BorderRadius.circular(scaleWidth(context, 16)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withOpacity(0.15),
                                      blurRadius: scaleWidth(context, 8),
                                      offset: Offset(0, scaleHeight(context, 2)),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                                ),
                                child: Stack(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(vertical: scaleHeight(context, 8), horizontal: scaleWidth(context, 10)),
                                      leading: CircleAvatar(
                                        radius: scaleWidth(context, 20),
                                        backgroundColor: Colors.white.withOpacity(0.18),
                                        child: Icon(statusIcon, color: Colors.white, size: scaleWidth(context, 20)),
                                      ),
                                      title: Text(
                                        'Pertemuan ke-${detail.meet}',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: scaleWidth(context, 14), color: Colors.white),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today, size: scaleWidth(context, 12), color: Colors.white),
                                              SizedBox(width: scaleWidth(context, 3)),
                                              Text('Tanggal: ${detail.scheduleDate}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 12), color: Colors.white)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.today, size: scaleWidth(context, 12), color: Colors.white),
                                              SizedBox(width: scaleWidth(context, 3)),
                                              Text('Hari: ${detail.day}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 12), color: Colors.white)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time, size: scaleWidth(context, 12), color: Colors.white),
                                              SizedBox(width: scaleWidth(context, 3)),
                                              Text('Jam: ${detail.time}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 12), color: Colors.white)),
                                            ],
                                          ),
                                          if (detail.realDate != null)
                                            Row(
                                              children: [
                                                Icon(Icons.event_available, size: scaleWidth(context, 12), color: Colors.white),
                                                SizedBox(width: scaleWidth(context, 3)),
                                                Text('Tanggal Real: ${detail.realDate}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 12), color: Colors.white)),
                                              ],
                                            ),
                                          if (detail.presenceDay != null)
                                            Row(
                                              children: [
                                                Icon(Icons.today, size: scaleWidth(context, 12), color: Colors.white),
                                                SizedBox(width: scaleWidth(context, 3)),
                                                Text('Hari Hadir: ${detail.presenceDay}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 12), color: Colors.white)),
                                              ],
                                            ),
                                          if (detail.paidDate != null)
                                            Row(
                                              children: [
                                                Icon(Icons.attach_money, size: scaleWidth(context, 12), color: Colors.white),
                                                SizedBox(width: scaleWidth(context, 3)),
                                                Text('Tanggal Bayar: ${detail.paidDate}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 12), color: Colors.white)),
                                              ],
                                            ),
                                          if (detail.realTime != null)
                                            Row(
                                              children: [
                                                Icon(Icons.access_time_filled, size: scaleWidth(context, 12), color: Colors.white),
                                                SizedBox(width: scaleWidth(context, 3)),
                                                Text('Jam Real: ${detail.realTime}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 12), color: Colors.white)),
                                              ],
                                            ),
                                          Row(
                                            children: [
                                              Icon(Icons.repeat, size: scaleWidth(context, 12), color: Colors.white),
                                              SizedBox(width: scaleWidth(context, 3)),
                                              Text('Periode: ${detail.periode}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 12), color: Colors.white)),
                                            ],
                                          ),
                                          SizedBox(height: scaleHeight(context, 4)),
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: scaleWidth(context, 8), vertical: scaleHeight(context, 2)),
                                                decoration: BoxDecoration(
                                                  color: isPresence
                                                      ? const Color.fromARGB(255, 85, 255, 91).withOpacity(0.20)
                                                      : const Color.fromARGB(255, 255, 255, 255).withOpacity(0.20),
                                                  borderRadius: BorderRadius.circular(scaleWidth(context, 6)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      isPresence ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                                                      size: scaleWidth(context, 13),
                                                      color: isPresence
                                                          ? const Color.fromARGB(255, 85, 255, 91)
                                                          : const Color.fromARGB(255, 255, 208, 0),
                                                    ),
                                                    SizedBox(width: scaleWidth(context, 3)),
                                                    Text(
                                                      isPresence ? 'Hadir' : 'Belum Hadir',
                                                      style: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: scaleWidth(context, 12),
                                                        color: isPresence
                                                            ? const Color.fromARGB(255, 85, 255, 91)
                                                            : const Color.fromARGB(255, 255, 208, 0),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: scaleWidth(context, 8)),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: scaleWidth(context, 8), vertical: scaleHeight(context, 2)),
                                                decoration: BoxDecoration(
                                                  color: isPaid
                                                      ? const Color.fromARGB(255, 85, 255, 91).withOpacity(0.20)
                                                      : const Color.fromARGB(255, 255, 255, 255).withOpacity(0.20),
                                                  borderRadius: BorderRadius.circular(scaleWidth(context, 6)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      isPaid ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                                                      size: scaleWidth(context, 13),
                                                      color: isPaid
                                                          ? const Color.fromARGB(255, 85, 255, 91)
                                                          : const Color.fromARGB(255, 255, 208, 0),
                                                    ),
                                                    SizedBox(width: scaleWidth(context, 3)),
                                                    Text(
                                                      isPaid ? 'Sudah Bayar' : 'Belum Bayar',
                                                      style: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: scaleWidth(context, 12),
                                                        color: isPaid
                                                            ? const Color.fromARGB(255, 85, 255, 91)
                                                            : const Color.fromARGB(255, 255, 208, 0),
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
                                  ],
                                ),
                              );
                            }),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: EdgeInsets.only(top: scaleHeight(context, 16), right: scaleWidth(context, 8), bottom: scaleHeight(context, 8)),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(scaleWidth(context, 16)),
                                  elevation: 2,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(scaleWidth(context, 16)),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OrderDateSiswaPage(order: widget.order),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color.fromARGB(238, 0, 105, 204), Color(0xFF003566)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(scaleWidth(context, 16)),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: scaleWidth(context, 22), vertical: scaleHeight(context, 14)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.info_outline, size: scaleWidth(context, 26), color: Colors.white),
                                          SizedBox(width: scaleWidth(context, 10)),
                                          Text(
                                            'Order Date',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: scaleWidth(context, 17),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
