import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'orderhistory_page.dart';

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double scaleWidth(BuildContext context, double value) => value * screenWidth(context) / 375; // 375 = width iPhone 11
double scaleHeight(BuildContext context, double value) => value * screenHeight(context) / 812; // 812 = height iPhone 11

class OrderDateSiswaPage extends StatefulWidget {
  final Order order;
  const OrderDateSiswaPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDateSiswaPage> createState() => _OrderDateSiswaPageState();
}

class _OrderDateSiswaPageState extends State<OrderDateSiswaPage> {
  bool _isLoading = false;
  String? _error;
  late Order order;

  @override
  void initState() {
    super.initState();
    order = widget.order;
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Simulasi fetch ulang data order jika perlu (misal dari API)
      await Future.delayed(Duration(milliseconds: 300));
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
    await _fetchOrder();
  }

  @override
  Widget build(BuildContext context) {
    final cardGradient = LinearGradient(
      colors: [Theme.of(context).colorScheme.primary.withOpacity(0.9), Theme.of(context).colorScheme.primary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Date Siswa', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 18))),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Theme.of(context).colorScheme.primary,
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
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: EdgeInsets.all(scaleWidth(context, 16.0)),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(scaleWidth(context, 20)),
                      ),
                      elevation: 6,
                      margin: EdgeInsets.only(bottom: scaleHeight(context, 16)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: cardGradient,
                          borderRadius: BorderRadius.circular(scaleWidth(context, 20)),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                              blurRadius: scaleWidth(context, 12),
                              offset: Offset(0, scaleHeight(context, 4)),
                            ),
                          ],
                          border: Border.all(color: Colors.white.withOpacity(0.18)),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: scaleWidth(context, 28), vertical: scaleHeight(context, 32)),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: -scaleHeight(context, 20),
                              right: -scaleWidth(context, 20),
                              child: Icon(
                                Icons.pool,
                                size: scaleWidth(context, 220),
                                color: Colors.white.withOpacity(0.10),
                              ),
                            ),
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.white, size: scaleWidth(context, 18)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Tanggal Order:  ${order.orderDate}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 15), fontWeight: FontWeight.w600, color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 10)),
                                  Row(
                                    children: [
                                      Icon(Icons.local_offer, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Promo: ${order.promo ?? '-'}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Icon(Icons.event_busy, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Tanggal Expired: ${order.expireDate ?? '-'}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Icon(order.isFinish ? Icons.check_circle : Icons.hourglass_empty, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Selesai: ${order.isFinish ? 'Ya' : 'Belum'}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Icon(Icons.notes, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Catatan: ${order.notes}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Icon(Icons.attach_money, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Harga: ${order.price}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Icon(Icons.payment, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Status Bayar: ${order.isPaid}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Icon(Icons.play_circle, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Tanggal Mulai: ${order.startDate}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Icon(Icons.person, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Persentase Pelatih: ${order.trainerPercentage}%', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Icon(Icons.business, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Persentase Perusahaan: ${order.companyPercentage}%', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Icon(Icons.repeat, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Periode: ${order.periode}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Icon(Icons.today, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Hari: ${order.day}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Jam: ${order.time}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Icon(Icons.monetization_on, color: Colors.white, size: scaleWidth(context, 16)),
                                      SizedBox(width: scaleWidth(context, 8)),
                                      Expanded(child: Text('Grand Total: ${order.grandTotal}', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 14), color: Colors.white))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
