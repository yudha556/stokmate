import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stokmate/models/transaksi.dart';
import 'package:stokmate/pages/screen/dashboard/components/barChart.dart';
import '../../widget/empty_state.dart';
import '../../widget/app_colors.dart';
import '../../layout/mainLayout.dart';

class Statistik extends StatelessWidget {
  const Statistik({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Transaksi>('transaksiBox').listenable(),
        builder: (context, Box<Transaksi> box, _) {
          final transaksiList = box.values.toList();

          if (transaksiList.isEmpty) {
            return EmptyState(
              icon: Icons.bar_chart,
              title: "Belum ada data statistik",
              subtitle:
                  "Tambahkan transaksi terlebih dahulu untuk melihat statistik",
              buttonText: "Input Transaksi",
              onButtonPressed: () {
                final mainLayoutState = context
                    .findAncestorStateOfType<MainLayoutState>();
                if (mainLayoutState != null) {
                  mainLayoutState.setState(() {
                    mainLayoutState.selectedIndex =
                        2; // index halaman transaksi
                  });
                }
              },
            );
          }

          final dailySales = _generateDailySalesData(transaksiList);
          final monthlySales = _generateMonthlySalesData(transaksiList);
          final yearlySales = _generateYearlySalesData(transaksiList);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Statistik Penjualan",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Data transaksi: ${transaksiList.length} transaksi",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 32),
                SalesChartCard(
                  sales: dailySales,
                  title: "Penjualan Harian",
                  subtitle: "7 hari terakhir",
                  showWeekly: true,
                ),
                const SizedBox(height: 32),
                SalesChartCard(
                  sales: monthlySales,
                  title: "Penjualan Bulanan",
                  subtitle: "12 bulan terakhir",
                  showWeekly: false,
                ),
                const SizedBox(height: 32),
                SalesChartCard(
                  sales: yearlySales,
                  title: "Penjualan Tahunan",
                  subtitle: "5 tahun terakhir",
                  showWeekly: false,
                  showYearly: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<int> _generateMonthlySalesData(List<Transaksi> transaksiList) {
    final now = DateTime.now();
    final monthlyData = List.filled(12, 0);

    for (var transaksi in transaksiList) {
      final monthDiff =
          (now.year - transaksi.tanggal.year) * 12 +
          (now.month - transaksi.tanggal.month);
      if (monthDiff >= 0 && monthDiff < 12) {
        monthlyData[11 - monthDiff] += transaksi.totalHarga;
      }
    }

    return monthlyData;
  }

  List<int> _generateDailySalesData(List<Transaksi> transaksiList) {
    final now = DateTime.now();
    final dailyData = List.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day - (6 - i));
      final dayTransactions = transaksiList.where(
        (t) =>
            t.tanggal.year == date.year &&
            t.tanggal.month == date.month &&
            t.tanggal.day == date.day,
      );
      dailyData[i] = dayTransactions.fold(0, (sum, t) => sum + t.totalHarga);
    }

    return dailyData;
  }

  List<int> _generateYearlySalesData(List<Transaksi> transaksiList) {
    final now = DateTime.now();
    final yearlyData = List.filled(5, 0);

    for (var transaksi in transaksiList) {
      final yearDiff = now.year - transaksi.tanggal.year;
      if (yearDiff >= 0 && yearDiff < 5) {
        yearlyData[4 - yearDiff] += transaksi.totalHarga;
      }
    }

    return yearlyData;
  }
}
