import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final double width;
  final Color? backgroundColor;
  final Color? selectedColor;

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.width = 250.0,
    this.backgroundColor,
    this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF4F6FF),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          _buildMenuItem(
            context,
            'Dashboard',
            Icons.dashboard_outlined,
            Icons.dashboard,
            0,
          ),
          _buildMenuItem(
            context,
            'Product',
            Icons.inventory_2_outlined,
            Icons.inventory_2,
            1,
          ),
          _buildMenuItem(
            context,
            'Transaksi',
            Icons.receipt_long_outlined,
            Icons.receipt_long,
            2,
          ),
          _buildMenuItem(
            context,
            'Statistik',
            Icons.bar_chart_outlined,
            Icons.bar_chart,
            3,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    IconData activeIcon,
    int index,
  ) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? (selectedColor ??
                      Theme.of(context).primaryColor.withOpacity(0.1))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected
                        ? (selectedColor ?? Theme.of(context).primaryColor)
                        : Colors.black,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? (selectedColor ?? Theme.of(context).primaryColor)
                          : Colors.black,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
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
