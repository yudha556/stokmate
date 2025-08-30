import 'package:flutter/material.dart';
import 'package:stokmate/models/transaksi.dart';
import 'package:stokmate/pages/screen/dashboard/components/barChart.dart';

class Statistik extends StatelessWidget {
  final List<Transaksi> transaksiList;

  const Statistik({super.key, required this.transaksiList});

  @override
  Widget build(BuildContext context) {
    final monthlySales = _generateMonthlySalesData(transaksiList);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik Penjualan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SalesChartCard(
          sales: monthlySales,
          title: "Penjualan Bulanan",
          subtitle: "Performa 12 bulan terakhir",
          showWeekly: false,
        ),
      ),
    );
  }

  List<int> _generateMonthlySalesData(List<Transaksi> transaksiList) {
    final now = DateTime.now();
    final monthlyData = List.filled(12, 0);

    for (var transaksi in transaksiList) {
      final monthDiff = (now.year - transaksi.tanggal.year) * 12 +
          (now.month - transaksi.tanggal.month);
      if (monthDiff >= 0 && monthDiff < 12) {
        monthlyData[11 - monthDiff] += transaksi.totalHarga;
      }
    }

    return monthlyData;
  }
}
