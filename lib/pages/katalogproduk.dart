import 'package:flutter/material.dart';
class KatalogProdukPage extends StatelessWidget {
  const KatalogProdukPage({Key? key}) : super(key: key
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: isMobile ? 18 : 32, left: isMobile ? 12 : 0, right: isMobile ? 12 : 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 5/7,
            child: Image.asset(
              'assets/images/katalog.jpg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
