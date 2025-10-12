import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/models/package_models.dart' as models;
import 'package:maestro_client_mobile/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final List<models.Transaction> transactions = _getMockTransactions();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF044366),
            size: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(isDarkMode),
            
            const SizedBox(height: 24),
            
            // Transactions List
            ...transactions.map((transaction) => _buildTransactionCard(transaction, isDarkMode)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : AppColors.navy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppColors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Riwayat Transaksi',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lihat riwayat pembayaran dan transaksi',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(models.Transaction transaction, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.invoiceNumber,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaction.studentName,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(transaction.status, isDarkMode),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Package Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.navy.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.packageName,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.description,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Transaction Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.attach_money,
                    label: 'Nominal',
                    value: NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(transaction.amount),
                    isDarkMode: isDarkMode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.payment,
                    label: 'Metode',
                    value: transaction.paymentMethod,
                    isDarkMode: isDarkMode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.calendar_today,
                    label: 'Tanggal',
                    value: DateFormat('dd MMM yyyy', 'id').format(transaction.date),
                    isDarkMode: isDarkMode,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDarkMode) {
    Color badgeColor;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'paid':
        badgeColor = const Color(0xFF4CAF50);
        statusText = 'Lunas';
        break;
      case 'unpaid':
        badgeColor = const Color(0xFFF44336);
        statusText = 'Belum Bayar';
        break;
      case 'pending':
        badgeColor = const Color(0xFFFF9800);
        statusText = 'Menunggu';
        break;
      default:
        badgeColor = const Color(0xFF9E9E9E);
        statusText = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.navy.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.navy,
            size: 14,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.navy,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 8,
              color: isDarkMode ? Colors.white60 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Mock data
List<models.Transaction> _getMockTransactions() {
  return [
    models.Transaction(
      id: '1',
      invoiceNumber: 'INV-2024-001',
      studentName: 'Ahmad Rizki',
      packageName: 'Paket Premium 12 Pertemuan',
      amount: 1200000,
      status: 'paid',
      date: DateTime.now().subtract(const Duration(days: 5)),
      paymentMethod: 'Transfer Bank',
      description: 'Pembayaran paket latihan renang premium',
    ),
    models.Transaction(
      id: '2',
      invoiceNumber: 'INV-2024-002',
      studentName: 'Siti Nurhaliza',
      packageName: 'Paket Basic 8 Pertemuan',
      amount: 800000,
      status: 'unpaid',
      date: DateTime.now().subtract(const Duration(days: 2)),
      paymentMethod: 'Cash',
      description: 'Pembayaran paket latihan renang basic',
    ),
    models.Transaction(
      id: '3',
      invoiceNumber: 'INV-2024-003',
      studentName: 'Budi Santoso',
      packageName: 'Paket Intensive 20 Pertemuan',
      amount: 2000000,
      status: 'paid',
      date: DateTime.now().subtract(const Duration(days: 10)),
      paymentMethod: 'E-Wallet',
      description: 'Pembayaran paket latihan renang intensive',
    ),
    models.Transaction(
      id: '4',
      invoiceNumber: 'INV-2024-004',
      studentName: 'Ahmad Rizki',
      packageName: 'Paket Premium 12 Pertemuan',
      amount: 1200000,
      status: 'pending',
      date: DateTime.now().subtract(const Duration(days: 1)),
      paymentMethod: 'Transfer Bank',
      description: 'Pembayaran paket latihan renang premium',
    ),
  ];
}
