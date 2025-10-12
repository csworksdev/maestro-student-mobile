import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'detail_orderhistorysiswa_page.dart';
import 'package:flutter/cupertino.dart';

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double scaleWidth(BuildContext context, double value) => value * screenWidth(context) / 375; // 375 = width iPhone 11
double scaleHeight(BuildContext context, double value) => value * screenHeight(context) / 812; // 812 = height iPhone 11

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  List<bool> _selected = [true, false];
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Order History',
          style: GoogleFonts.poppins(
            fontSize: scaleWidth(context, 20),
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Color(0xEF003566),
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleWidth(context, 16), vertical: scaleHeight(context, 16)),
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(scaleWidth(context, 16)),
                isSelected: _selected,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selected.length; i++) {
                      _selected[i] = i == index;
                    }
                    _selectedIndex = index;
                  });
                },
                selectedColor: Colors.white,
                fillColor: Color.fromARGB(255, 0, 70, 140),
                color: Colors.black,
                borderColor: Color.fromARGB(255, 0, 70, 140),
                selectedBorderColor: Color.fromARGB(255, 0, 70, 140),
                children: [
                  SizedBox(
                    width: scaleWidth(context, 160),
                    height: scaleHeight(context, 40),
                    child: Center(child: Text('Pending', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 16)))),
                  ),
                  SizedBox(
                    width: scaleWidth(context, 160),
                    height: scaleHeight(context, 40),
                    child: Center(child: Text('Paid', style: GoogleFonts.poppins(fontSize: scaleWidth(context, 16)))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Order>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView(
                      children: [
                        SizedBox(height: scaleHeight(context, 120)),
                        Center(child: CircularProgressIndicator()),
                        SizedBox(height: 16),
                        Center(child: Text('Memuat data, mohon tunggu...', style: GoogleFonts.poppins())),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return ListView(
                      children: [
                        SizedBox(height: scaleHeight(context, 100)),
                        Center(child: Icon(Icons.wifi_off, color: Colors.red, size: 48)),
                        SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Gagal mengambil data order history.\nPeriksa koneksi internet Anda.',
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
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(height: scaleHeight(context, 120)),
                        Center(
                          child: Text(
                            'Belum ada order history.',
                            style: GoogleFonts.poppins(fontSize: scaleWidth(context, 16)),
                          ),
                        ),
                      ],
                    );
                  }

                  final orders = snapshot.data!;
                  final pendingOrders = orders.where((o) => o.isPaid.toLowerCase() == 'pending').toList();
                  final paidOrders = orders.where((o) => o.isPaid.toLowerCase() == 'paid').toList();

                  Widget buildOrderCardAPI(Order order, int index) {
                    final isPending = order.isPaid.toLowerCase() == 'pending';
                    final statusColor = Theme.of(context).colorScheme.primary; // navy
                    final statusIcon = isPending ? Icons.hourglass_top_rounded : Icons.verified_rounded;
                    final cardGradient = LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                    return InkWell(
                      borderRadius: BorderRadius.circular(scaleWidth(context, 16)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailOrderHistorySiswaPage(order: order),
                          ),
                        );
                      },
                      child: Container(
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
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(
                                Icons.star,
                                color: Colors.white.withOpacity(0.13),
                                size: scaleWidth(context, 60),
                              ),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: scaleHeight(context, 8), horizontal: scaleWidth(context, 10)),
                              leading: CircleAvatar(
                                radius: scaleWidth(context, 20),
                                backgroundColor: Colors.white.withOpacity(0.18),
                                child: Icon(statusIcon, color: Colors.white, size: scaleWidth(context, 20)),
                              ),
                              title: Text(
                                order.students.isNotEmpty ? (order.students[0]['student_fullname'] ?? '-') : '-',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: scaleWidth(context, 14), color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.shopping_bag, size: scaleWidth(context, 13), color: Colors.white),
                                      SizedBox(width: scaleWidth(context, 3)),
                                      Flexible(
                                        child: Text(
                                          order.productName,
                                          style: GoogleFonts.poppins(fontSize: scaleWidth(context, 12), color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.pool, size: scaleWidth(context, 13), color: Colors.white),
                                      SizedBox(width: scaleWidth(context, 3)),
                                      Flexible(
                                        child: Text(
                                          order.poolName,
                                          style: GoogleFonts.poppins(fontSize: scaleWidth(context, 12), color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: scaleWidth(context, 12), color: Colors.white),
                                      SizedBox(width: scaleWidth(context, 3)),
                                      Text(
                                        order.orderDate,
                                        style: GoogleFonts.poppins(fontSize: scaleWidth(context, 12), color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.people, size: scaleWidth(context, 12), color: Colors.white),
                                      SizedBox(width: scaleWidth(context, 3)),
                                      Text(
                                        'Paket: ${order.packageStudent}',
                                        style: GoogleFonts.poppins(fontSize: scaleWidth(context, 12), color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: scaleHeight(context, 8)),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: scaleWidth(context, 8), vertical: scaleHeight(context, 2)),
                                        decoration: BoxDecoration(
                                          color: order.isPaid.toLowerCase() == 'pending'
                                              ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.20)
                                              : order.isPaid.toLowerCase() == 'paid'
                                                  ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.20)
                                                  : Colors.white.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(scaleWidth(context, 6)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              statusIcon,
                                              size: scaleWidth(context, 13),
                                              color: order.isPaid.toLowerCase() == 'pending'
                                                  ? const Color.fromARGB(255, 255, 208, 0)
                                                  : order.isPaid.toLowerCase() == 'paid'
                                                      ? const Color.fromARGB(255, 85, 255, 91)
                                                      : Colors.white,
                                            ),
                                            SizedBox(width: scaleWidth(context, 3)),
                                            Text(
                                              order.isPaid,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: scaleWidth(context, 12),
                                                color: order.isPaid.toLowerCase() == 'pending'
                                                    ? const Color.fromARGB(255, 255, 208, 0)
                                                    : order.isPaid.toLowerCase() == 'paid'
                                                        ? const Color.fromARGB(255, 85, 255, 91)
                                                        : Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Padding(
                                padding: EdgeInsets.only(right: scaleWidth(context, 14)),
                                child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: scaleWidth(context, 22)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return _selectedIndex == 0
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: scaleWidth(context, 12)),
                          child: ListView.builder(
                            itemCount: pendingOrders.length,
                            itemBuilder: (context, index) => buildOrderCardAPI(pendingOrders[index], index),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: scaleWidth(context, 12)),
                          child: ListView.builder(
                            itemCount: paidOrders.length,
                            itemBuilder: (context, index) => buildOrderCardAPI(paidOrders[index], index),
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model OrderDetail
class OrderDetail {
  final String orderDetailId;
  final int meet;
  final bool isPresence;
  final String day;
  final String time;
  final bool isPaid;
  final String scheduleDate;
  final String pricePerMeet;
  final String? realDate;
  final String? presenceDay;
  final String? paidDate;
  final String? realTime;
  final String periode;
  final String student;

  OrderDetail({
    required this.orderDetailId,
    required this.meet,
    required this.isPresence,
    required this.day,
    required this.time,
    required this.isPaid,
    required this.scheduleDate,
    required this.pricePerMeet,
    this.realDate,
    this.presenceDay,
    this.paidDate,
    this.realTime,
    required this.periode,
    required this.student,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderDetailId: json['order_detail_id'],
      meet: json['meet'],
      isPresence: json['is_presence'],
      day: json['day'],
      time: json['time'],
      isPaid: json['is_paid'],
      scheduleDate: json['schedule_date'],
      pricePerMeet: json['price_per_meet'],
      realDate: json['real_date'],
      presenceDay: json['presence_day'],
      paidDate: json['paid_date'],
      realTime: json['real_time'],
      periode: json['periode'],
      student: json['student'],
    );
  }
}

// Model Order
class Order {
  final String orderId;
  final String productName;
  final String trainerName;
  final String poolName;
  final List students;
  final List<OrderDetail> details;
  final String orderDate;
  final String? promo;
  final String? expireDate;
  final bool isFinish;
  final String notes;
  final String price;
  final String isPaid;
  final String startDate;
  final String trainerPercentage;
  final String companyPercentage;
  final String periode;
  final String day;
  final String time;
  final String grandTotal;
  final String packageStudent;

  Order({
    required this.orderId,
    required this.productName,
    required this.trainerName,
    required this.poolName,
    required this.students,
    required this.details,
    required this.orderDate,
    this.promo,
    this.expireDate,
    required this.isFinish,
    required this.notes,
    required this.price,
    required this.isPaid,
    required this.startDate,
    required this.trainerPercentage,
    required this.companyPercentage,
    required this.periode,
    required this.day,
    required this.time,
    required this.grandTotal,
    required this.packageStudent,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      productName: json['product_name'],
      trainerName: json['trainer_name'],
      poolName: json['pool_name'],
      students: json['students'],
      details: (json['detail'] as List).map((e) => OrderDetail.fromJson(e)).toList(),
      orderDate: json['order_date'],
      promo: json['promo'],
      expireDate: json['expire_date'],
      isFinish: json['is_finish'],
      notes: json['notes'],
      price: json['price'],
      isPaid: json['is_paid'],
      startDate: json['start_date'],
      trainerPercentage: json['trainer_percentage'],
      companyPercentage: json['company_percentage'],
      periode: json['periode'],
      day: json['day'],
      time: json['time'],
      grandTotal: json['grand_total'],
      packageStudent: json['package_student'],
    );
  }
}

Future<List<Order>> fetchOrders() async {
  print('[DEBUG] Fetching orders from API...');
  final response = await http.get(Uri.parse('https://api.maestroswim.com/api/order/byIdSiswa/2c005ea4-2286-4615-8151-859bb1f39220/'));
  print('[DEBUG] Status code: ${response.statusCode}');
  if (response.statusCode == 200) {
    print('[DEBUG] API connected successfully!');
    final data = json.decode(response.body);
    final List results = data['results'];
    print('[DEBUG] Orders fetched: ${results.length}');
    return results.map((e) => Order.fromJson(e)).toList();
  } else {
    print('[DEBUG] Failed to connect to API.');
    throw Exception('Failed to load orders');
  }
}
