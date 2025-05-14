import 'package:flutter/material.dart';

class AbsensiCard extends StatelessWidget {
  final String student;
  final String trainerFullname;
  final String poolName;
  final String product;
  final String orderDate;
  final String? expireDate;

  const AbsensiCard({
    Key? key,
    required this.student,
    required this.trainerFullname,
    required this.poolName,
    required this.product,
    required this.orderDate,
    this.expireDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Card(
      color: isDarkMode ? Colors.grey[900] : const Color.fromARGB(255, 255, 255, 255),
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.01,
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width * 0.045,
                color: textColor,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              "Pelatih: $trainerFullname",
              style: TextStyle(color: textColor),
            ),
            Text(
              "Kolam: $poolName",
              style: TextStyle(color: textColor),
            ),
            Text(
              "Produk: $product",
              style: TextStyle(color: textColor),
            ),
            Text(
              "Tanggal Order: $orderDate",
              style: TextStyle(color: textColor),
            ),
            Text(
              "Tanggal Kadaluwarsa: ${expireDate ?? 'N/A'}",
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}