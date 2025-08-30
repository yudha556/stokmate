// components/barChart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../widget/app_colors.dart';

class SalesBarChart extends StatelessWidget {
  final List<int> sales; 
  final bool showWeekly; 
  final bool showYearly; // Tambahkan ini
  final String? title;
  final double? height;

  const SalesBarChart({
    super.key, 
    required this.sales,
    this.showWeekly = true,
    this.showYearly = false, // Default false
    this.title,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Convert int to double for fl_chart
    final salesData = sales.map((e) => e.toDouble()).toList();
    
    // Calculate max value with some padding
    final maxValue = salesData.isEmpty ? 0.0 : salesData.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue == 0 ? 100.0 : (maxValue * 1.2); // 20% padding

    return Container(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          groupsSpace: showWeekly ? 20 : 12,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              // tooltipBgColor: AppColors.darkText,
              // tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String label;
                if (showYearly) {
                  label = _getYearLabel(groupIndex);
                } else if (showWeekly) {
                  label = _getWeekdayLabel(groupIndex);
                } else {
                  label = _getMonthLabel(groupIndex);
                }
                return BarTooltipItem(
                  '$label\n${_formatCurrency(rod.toY.toInt())}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: maxY / 5, // 5 intervals
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      _formatCompactCurrency(value.toInt()),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.lightText,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= salesData.length) {
                    return const SizedBox.shrink();
                  }
                  String label;
                  if (showYearly) {
                    label = _getYearShortLabel(index);
                  } else if (showWeekly) {
                    label = _getWeekdayShortLabel(index);
                  } else {
                    label = _getMonthShortLabel(index);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.lightText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.borderColor,
                strokeWidth: 0.5,
                dashArray: [5, 5],
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: AppColors.borderColor, width: 1),
              left: BorderSide(color: AppColors.borderColor, width: 1),
            ),
          ),
          barGroups: salesData.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;
            
            // Determine color based on performance
            Color barColor = AppColors.primaryPurple;
            if (salesData.isNotEmpty) {
              final average = salesData.reduce((a, b) => a + b) / salesData.length;
              if (value > average * 1.2) {
                barColor = AppColors.successGreen; // High performance
              } else if (value < average * 0.8) {
                barColor = AppColors.warningRed; // Low performance
              }
            }
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  gradient: LinearGradient(
                    colors: [
                      barColor,
                      barColor.withOpacity(0.7),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: showWeekly ? 24 : 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: AppColors.lightPurple.withOpacity(0.3),
                  ),
                ),
              ],
              showingTooltipIndicators: [], // Will show on touch
            );
          }).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 300),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }

  // Tambahkan fungsi label tahun
  String _getYearLabel(int index) {
    final now = DateTime.now();
    return (now.year - (4 - index)).toString(); // Untuk 5 tahun terakhir
  }

  String _getYearShortLabel(int index) {
    final now = DateTime.now();
    return (now.year - (4 - index)).toString().substring(2); // Misal '23', '24'
  }

  String _getWeekdayLabel(int index) {
    final weekdays = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    // Calculate the actual day based on current date
    final now = DateTime.now();
    final dayIndex = (now.weekday - 1 + index - 6) % 7;
    return weekdays[dayIndex < 0 ? dayIndex + 7 : dayIndex];
  }

  String _getWeekdayShortLabel(int index) {
    final weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    // Calculate the actual day based on current date
    final now = DateTime.now();
    final dayIndex = (now.weekday - 1 + index - 6) % 7;
    return weekdays[dayIndex < 0 ? dayIndex + 7 : dayIndex];
  }

  String _getMonthLabel(int index) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return index < months.length ? months[index] : '';
  }

  String _getMonthShortLabel(int index) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return index < months.length ? months[index] : '';
  }

  String _formatCurrency(int amount) {
    return "Rp${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}";
  }

  String _formatCompactCurrency(int amount) {
    if (amount >= 1000000000) {
      return "${(amount / 1000000000).toStringAsFixed(1)}B";
    } else if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(1)}K";
    }
    return amount.toString();
  }
}

// Enhanced Chart Widget dengan Header
class SalesChartCard extends StatelessWidget {
  final List<int> sales;
  final String title;
  final String subtitle;
  final bool showWeekly;
  final bool showYearly; // Tambahkan ini
  final VoidCallback? onViewMore;

  const SalesChartCard({
    super.key,
    required this.sales,
    required this.title,
    required this.subtitle,
    required this.showWeekly,
    this.showYearly = false, // Default false
    this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    final totalSales = sales.fold(0, (sum, item) => sum + item);
    final averageSales = sales.isEmpty ? 0 : totalSales ~/ sales.length;

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
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bar_chart,
                        color: AppColors.primaryPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.lightText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onViewMore != null)
                      TextButton(
                        onPressed: onViewMore,
                        child: const Text(
                          "Lihat Detail",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Quick Stats
                Row(
                  children: [
                    _buildQuickStat(
                      "Total",
                      _formatCurrency(totalSales),
                      AppColors.primaryPurple,
                    ),
                    const SizedBox(width: 20),
                    _buildQuickStat(
                      "Rata-rata",
                      _formatCurrency(averageSales),
                      AppColors.successGreen,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.lightPurple,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        showWeekly ? "7 Hari" : "12 Bulan",
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Chart
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 20, bottom: 20),
            child: SizedBox(
              height: 200,
              child: SalesBarChart(
                sales: sales,
                showWeekly: showWeekly,
                showYearly: showYearly, // Teruskan ke SalesBarChart
                height: 200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.lightText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    return "Rp${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}";
  }
}