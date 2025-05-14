import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<double> incomeData = [50, 80, 60, 100, 90, 70, 110];
  List<double> expenseData = [30, 60, 50, 80, 70, 55, 90];
  List<double> pieData = [42, 18, 24, 16];
  late Timer _timer;
  String selectedChart = "income";

  @override
  void initState() {
    super.initState();
    _startAutoUpdate();
  }

  void _startAutoUpdate() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        incomeData = incomeData.map((e) => Random().nextInt(100) + 20.0).toList();
        expenseData = expenseData.map((e) => Random().nextInt(80) + 10.0).toList();
        double total = 100.0;
        List<double> newPieData = List.generate(4, (index) => Random().nextInt(30) + 10.0);
        double sum = newPieData.reduce((a, b) => a + b);
        pieData = newPieData.map((e) => (e / sum) * total).toList();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Coach Earning",
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: isDarkMode ? Colors.white : Colors.black),
          ),
          SizedBox(height: 4),
          Text(
            "Rp 769.824.050",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedChart = "income";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedChart == "income" ? Colors.blue : Colors.grey,
                  ),
                  child: Text("Income", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedChart = "expense";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedChart == "expense" ? Colors.blue : Colors.grey,
                  ),
                  child: Text("Expense", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildCard(title: "Statistics", child: selectedChart == "income" ? _buildBarChart(incomeData, isDarkMode) : _buildLineChart(expenseData, isDarkMode), isDarkMode: isDarkMode),
          SizedBox(height: 24),
          _buildCard(title: "Transaction", child: _buildPieChart(isDarkMode), isDarkMode: isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child, required bool isDarkMode}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? LinearGradient(colors: [Colors.grey[800]!, Colors.grey[700]!])
            : LinearGradient(colors: [const Color.fromARGB(255, 21, 27, 30), const Color.fromARGB(255, 76, 104, 117)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBarChart(List<double> data, bool isDarkMode) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(data.length, (index) => _buildBarGroup(index, data[index])),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (double value, _) => Text('D${value.toInt()}'))),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<double> data, bool isDarkMode) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index])),
              isCurved: true,
              gradient: LinearGradient(colors: [Colors.blueAccent, Colors.cyan]),
              barWidth: 3,
              dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(radius: 5, color: Colors.red, strokeColor: Colors.white, strokeWidth: 2);
              }),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.blueAccent.withOpacity(0.5), Colors.transparent])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(bool isDarkMode) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: List.generate(pieData.length, (index) {
            final List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange];
            return PieChartSectionData(
              value: pieData[index],
              title: '${pieData[index].toStringAsFixed(1)}%',
              color: colors[index % colors.length],
              radius: 50,
              titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              showTitle: true,
              badgeWidget: Icon(Icons.star, color: Colors.white, size: 12),
            );
          }),
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int index, double value) {
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: value,
          gradient: LinearGradient(colors: [const Color.fromARGB(255, 240, 153, 255), const Color.fromARGB(255, 0, 153, 255)]),
          width: 14,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}