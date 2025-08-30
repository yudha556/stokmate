// pages/dashboard.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stokmate/pages/screen/statistik/statistik.dart';
import '../../../models/barang.dart';
import '../../../models/transaksi.dart';
import '../../widget/app_colors.dart';
import '../../widget/stats_card.dart';
import '../../widget/empty_state.dart';
import '../../widget/modern_snackbar.dart';
import 'components/barChart.dart';
import '../../layout/mainLayout.dart';
// Make sure MainLayoutState is imported from mainLayout.dart

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Barang>('barangBox').listenable(),
        builder: (context, Box<Barang> barangBox, _) {
          return ValueListenableBuilder(
            valueListenable: Hive.box<Transaksi>('transaksiBox').listenable(),
            builder: (context, Box<Transaksi> transaksiBox, _) {
              final barangList = barangBox.values.toList();
              final transaksiList = transaksiBox.values.toList();
              
              // Jika tidak ada data sama sekali
              if (barangList.isEmpty && transaksiList.isEmpty) {
                return EmptyState(
                  icon: Icons.dashboard_outlined,
                  title: "Dashboard Kosong",
                  subtitle: "Tambahkan produk dan transaksi untuk melihat ringkasan bisnis Anda",
                  buttonText: "Tambah Produk",
                  onButtonPressed: () => _navigateToProducts(context),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    // _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    
                    // Main Stats Grid
                    _buildMainStatsGrid(barangList, transaksiList),
                    const SizedBox(height: 24),
                    
                    // Sales Chart Section
                    _buildSalesChartSection(context, transaksiList),
                    const SizedBox(height: 24),
                    
                    // Additional Stats
                    _buildAdditionalStats(barangList, transaksiList),
                    const SizedBox(height: 24),
                    
                    // Recent Activity
                    _buildRecentActivity(transaksiList),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Widget _buildWelcomeSection() {
  //   final now = DateTime.now();
  //   final hour = now.hour;
  //   String greeting = "Selamat Pagi";
    
  //   if (hour >= 12 && hour < 15) {
  //     greeting = "Selamat Siang";
  //   } else if (hour >= 15 && hour < 18) {
  //     greeting = "Selamat Sore";
  //   } else if (hour >= 18) {
  //     greeting = "Selamat Malam";
  //   }

  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           AppColors.primaryPurple,
  //           AppColors.primaryPurple.withOpacity(0.8),
  //         ],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.primaryPurple.withOpacity(0.3),
  //           blurRadius: 12,
  //           offset: const Offset(0, 6),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           greeting,
  //           style: const TextStyle(
  //             color: Colors.white,
  //             fontSize: 16,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         const Text(
  //           "Selamat datang di Dashboard",
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           _formatDate(now),
  //           style: TextStyle(
  //             color: Colors.white.withOpacity(0.8),
  //             fontSize: 14,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMainStatsGrid(List<Barang> barangList, List<Transaksi> transaksiList) {
    // Calculate stats
    final totalProduk = barangList.length;
    final totalStok = barangList.fold(0, (sum, item) => sum + item.stok);
    final totalPenjualan = transaksiList.fold(0, (sum, item) => sum + item.totalHarga);
    final totalTransaksi = transaksiList.length;

    // Calculate profit (simplified - assuming all transactions are sales)
    int totalProfit = 0;
    for (var transaksi in transaksiList) {
      // Find the product to get buy price
      final barang = barangList.where((b) => b.nama == transaksi.namaBarang).firstOrNull;
      if (barang != null) {
        final profit = (barang.hargaJual - barang.hargaBeli) * transaksi.jumlah;
        totalProfit += profit;
      }
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatsCard(
          title: "Total Penjualan",
          value: _formatCurrency(totalPenjualan),
          icon: Icons.attach_money,
          color: AppColors.successGreen,
          onTap: () => _showDetailStats("Penjualan", "Total penjualan hari ini: ${_formatCurrency(totalPenjualan)}"),
        ),
        StatsCard(
          title: "Laba Bersih",
          value: _formatCurrency(totalProfit),
          icon: Icons.trending_up,
          color: AppColors.primaryPurple,
          onTap: () => _showDetailStats("Laba", "Laba bersih: ${_formatCurrency(totalProfit)}"),
        ),
        StatsCard(
          title: "Total Produk",
          value: totalProduk.toString(),
          icon: Icons.inventory_2,
          color: Colors.orange,
          onTap: () => _showDetailStats("Produk", "Total produk terdaftar: $totalProduk"),
        ),
        StatsCard(
          title: "Total Stok",
          value: totalStok.toString(),
          icon: Icons.warehouse,
          color: Colors.blue,
          onTap: () => _showDetailStats("Stok", "Total stok tersedia: $totalStok"),
        ),
      ],
    );
  }

  Widget _buildSalesChartSection(BuildContext context, List<Transaksi> transaksiList) {
    // Generate sales data for last 7 days
    final salesData = _generateWeeklySalesData(transaksiList);
    
    return SalesChartCard(
      title: "Penjualan Mingguan",
      subtitle: "Performa 7 hari terakhir",
      sales: salesData,
      showWeekly: true,
      onViewMore: () => _showDetailedSalesAnalysis(context, transaksiList),
    );
  }

  Widget _buildAdditionalStats(List<Barang> barangList, List<Transaksi> transaksiList) {
    final lowStockItems = barangList.where((item) => item.stok < 10).length;
    final todayTransactions = transaksiList.where((t) => 
      t.tanggal.day == DateTime.now().day &&
      t.tanggal.month == DateTime.now().month &&
      t.tanggal.year == DateTime.now().year
    ).length;

    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: "Stok Rendah",
            value: lowStockItems.toString(),
            icon: Icons.warning_amber,
            color: AppColors.warningRed,
            onTap: () => _showLowStockItems(barangList),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatsCard(
            title: "Transaksi Hari Ini",
            value: todayTransactions.toString(),
            icon: Icons.receipt_long,
            color: AppColors.successGreen,
            onTap: () => _showTodayTransactions(transaksiList),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(List<Transaksi> transaksiList) {
    final recentTransactions = transaksiList
        .where((t) => DateTime.now().difference(t.tanggal).inDays <= 7)
        .toList()
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

    if (recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: AppColors.lightText,
              ),
              SizedBox(height: 8),
              Text(
                "Belum ada transaksi terbaru",
                style: TextStyle(color: AppColors.lightText),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Aktivitas Terbaru",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
          ...recentTransactions.take(5).map((transaksi) => 
            _buildTransactionItem(transaksi)
          ),
          if (recentTransactions.length > 5)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: TextButton(
                  onPressed: () => _showAllTransactions(),
                  child: const Text("Lihat Semua Transaksi"),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaksi transaksi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: AppColors.successGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaksi.namaBarang,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "${transaksi.jumlah} item • ${_formatRelativeTime(transaksi.tanggal)}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(transaksi.totalHarga),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.successGreen,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatCurrency(int amount) {
    return "Rp${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}";
  }

  String _formatDate(DateTime date) {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return "${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return "${difference.inDays} hari lalu";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} jam lalu";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} menit lalu";
    } else {
      return "Baru saja";
    }
  }

  List<int> _generateWeeklySalesData(List<Transaksi> transaksiList) {
    final now = DateTime.now();
    final weeklyData = List.filled(7, 0);
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayTransactions = transaksiList.where((t) =>
        t.tanggal.day == date.day &&
        t.tanggal.month == date.month &&
        t.tanggal.year == date.year
      );
      
      weeklyData[i] = dayTransactions.fold(0, (sum, t) => sum + t.totalHarga);
    }
    
    return weeklyData;
  }

  // Action methods
  void _navigateToProducts(BuildContext context) {
    ModernSnackBar.show(
      context: context,
      message: "Navigasi ke halaman produk",
      type: SnackBarType.info,
    );
  }

  void _showDetailStats(String title, String message) {
    // This would show a detailed stats dialog
  }

  void _showLowStockItems(List<Barang> barangList) {
    final lowStockItems = barangList.where((item) => item.stok < 10).toList();
    // Show dialog with low stock items
  }

  void _showTodayTransactions(List<Transaksi> transaksiList) {
    // Show today's transactions
  }

  void _showAllTransactions() {
    // Navigate to transactions page
  }

void _showDetailedSalesAnalysis(BuildContext context, List<Transaksi> transaksiList) {
  final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();

  if (mainLayoutState != null) {
    mainLayoutState.setState(() {
      mainLayoutState.selectedIndex = 3; // pindah ke halaman Statistik
    });
  }
}



}