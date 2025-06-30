import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_state_provider.dart';
import '../services/navigation_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppStateProvider>(context, listen: false).refreshAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Weekly Stats',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Kanit',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFB71C)),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekly Calorie Chart
                _buildWeeklyChart(appState),
                SizedBox(height: 24.h),

                // Today's Summary
                _buildTodaySummary(appState),
                SizedBox(height: 24.h),

                // Weekly Summary Cards
                _buildWeeklySummaryCards(appState),
                SizedBox(height: 24.h),

                // Progress Indicators
                _buildProgressIndicators(appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyChart(AppStateProvider appState) {
    final weeklyData = appState.weeklyCalorieData;
    final maxCalories = weeklyData.values.isNotEmpty
        ? weeklyData.values.reduce((a, b) => a > b ? a : b)
        : 2000.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Text(
            'Weekly Calorie Intake',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCalories > 0 ? maxCalories * 1.2 : 2400,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ][group.x.toInt()];
                      return BarTooltipItem(
                        '$day\n${rod.toY.round()} kcal',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        return Text(
                          days[value.toInt()],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(weeklyData),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, double> weeklyData) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      final calories = weeklyData[day] ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: calories,
            color: const Color.fromARGB(255, 144, 255, 18),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildTodaySummary(AppStateProvider appState) {
    final todayLog = appState.todayLog;
    final user = appState.currentUser;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB71C),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Calories',
                '${todayLog?.totalCalories.round() ?? 0}',
                '${user?.dailyCalorieGoal.round() ?? 2000}',
                'kcal',
              ),
              _buildSummaryItem(
                'Protein',
                '${todayLog?.totalProtein.round() ?? 0}',
                null,
                'g',
              ),
              _buildSummaryItem(
                'Carbs',
                '${todayLog?.totalCarbs.round() ?? 0}',
                null,
                'g',
              ),
              _buildSummaryItem(
                'Water',
                '${todayLog?.waterIntake ?? 0}',
                '${user?.dailyWaterGoal ?? 3}',
                'L',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, String? goal, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
            fontFamily: 'Kanit',
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '$value$unit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
        if (goal != null)
          Text(
            '/ $goal$unit',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10.sp,
              fontFamily: 'Kanit',
            ),
          ),
      ],
    );
  }

  Widget _buildWeeklySummaryCards(AppStateProvider appState) {
    final weeklyLogs = appState.weeklyLogs;

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double avgWater = 0;

    if (weeklyLogs.isNotEmpty) {
      for (var log in weeklyLogs) {
        totalCalories += log.totalCalories;
        totalProtein += log.totalProtein;
        totalCarbs += log.totalCarbs;
        avgWater += log.waterIntake;
      }
      avgWater = avgWater / weeklyLogs.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildWeeklyCard(
                'Total Calories',
                '${totalCalories.round()}',
                'kcal',
                Colors.orange,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildWeeklyCard(
                'Avg Water',
                avgWater.toStringAsFixed(1),
                'L/day',
                Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildWeeklyCard(
                'Total Protein',
                '${totalProtein.round()}',
                'g',
                Colors.red,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildWeeklyCard(
                'Total Carbs',
                '${totalCarbs.round()}',
                'g',
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyCard(
      String title, String value, String unit, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? color.withOpacity(0.7)
            : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
              fontFamily: 'Kanit',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '$value $unit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(AppStateProvider appState) {
    final user = appState.currentUser;
    final calorieProgress = appState.todayCalorieProgress;
    final waterProgress = appState.todayWaterProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Progress',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey
                : Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
        SizedBox(height: 16.h),

        // Calorie Progress
        _buildProgressBar(
          'Calorie Goal',
          calorieProgress,
          '${(calorieProgress * 100).round()}%',
          const Color(0xFFFFB71C),
        ),
        SizedBox(height: 12.h),

        // Water Progress
        _buildProgressBar(
          'Water Goal',
          waterProgress,
          '${(waterProgress * 100).round()}%',
          Colors.blue,
        ),

        if (user != null) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF38342C),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Current BMI',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      appState.currentBMI.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      appState.bmiCategory,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Weight Goal',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      '${user.currentWeight.round()}kg → ${user.targetWeight.round()}kg',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressBar(
      String label, double progress, String percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Color.fromARGB(225, 150, 139, 117)
                    : Colors.white,
                fontSize: 14.sp,
                fontFamily: 'Kanit',
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kanit',
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8.h,
        ),
      ],
    );
  }
}
