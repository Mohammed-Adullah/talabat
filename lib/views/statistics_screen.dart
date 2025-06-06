// lib/views/statistics_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talabat/views/widgets/animated_logo.dart';
import '../viewmodels/statistics_viewmodel.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // ignore: unused_field
  late StatisticsViewModel _vm;

  @override
  void initState() {
    super.initState();
    // نؤخّر الحصول على المزود حتى بعد انتهاء عملية بناء الويجيت (لبعد التأكد من وجوده في الشجرة)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm = Provider.of<StatisticsViewModel>(context, listen: false);
      // ملاحظة: تم تحميل البيانات في الإنشائي الخاص بالـ ViewModel نفسه،
      // لذلك لا حاجة لاستدعاء loadStatistics() هنا مجددًا.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإحصائيات')),
      body: Consumer<StatisticsViewModel>(
        builder: (context, vm, _) {
          // 1) إذا كانت العملية "جارٍ التحميل"، نعرض سبينر
          if (vm.isLoading) {
            return const Center(child: AnimatedLogo());
          }
          // 2) إذا كان هناك خطأ، نظهر رسالة الخطأ
          if (vm.errorMessage != null) {
            return Center(child: Text(vm.errorMessage!));
          }

          // 3) خلاف ذلك، نعرض محتويات الصفحة (Dropdown + الرسمين البيانيين)
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ——— شريط اختيار الفترة ———
                Row(
                  children: [
                    const Text('اختر الفترة: ', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    DropdownButton<StatisticsPeriod>(
                      value: vm.currentPeriod,
                      items: const [
                        DropdownMenuItem(
                          value: StatisticsPeriod.weekly,
                          child: Text('أسبوعي'),
                        ),
                        DropdownMenuItem(
                          value: StatisticsPeriod.monthly,
                          child: Text('شهري'),
                        ),
                        DropdownMenuItem(
                          value: StatisticsPeriod.quarterly,
                          child: Text('ربع سنوي'),
                        ),
                        DropdownMenuItem(
                          value: StatisticsPeriod.halfYearly,
                          child: Text('نصف سنوي'),
                        ),
                        DropdownMenuItem(
                          value: StatisticsPeriod.yearly,
                          child: Text('سنوي'),
                        ),
                      ],
                      onChanged: (newPeriod) {
                        if (newPeriod != null) {
                          // عند تغير الاختيار، نستدعي setPeriod حتى يعيد تحميل البيانات
                          vm.setPeriod(newPeriod);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ——— أول رسم بياني: “سادة” ———
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أكثر 10 ألوان سادة طلبًا',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: vm.topSadah.isEmpty
                            ? const Center(child: Text('لا توجد بيانات لسادة'))
                            : _buildBarChart(vm.topSadah),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ——— ثاني رسم بياني: “خشابي” ———
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أكثر 10 ألوان خشابي طلبًا',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: vm.topKhashabi.isEmpty
                            ? const Center(child: Text('لا توجد بيانات لخشابي'))
                            : _buildBarChart(vm.topKhashabi),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// دالة مساعدة لبناء رسم بياني شريطي (Bar Chart) من قائمة بيانات ColorCount.
  Widget _buildBarChart(List<ColorCount> data) {
    // 1) ننشئ BarChartGroupData لكل عنصر في data
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < data.length; i++) {
      final cc = data[i];
      barGroups.add(
        BarChartGroupData(
          x: i, // كل عمود يُعطى فهرس (index)
          barRods: [
            BarChartRodData(
              toY: cc.count.toDouble(), // ارتفاع العمود = عدد التكرارات
              color: Colors.blueAccent, // يمكنك تغيير اللون
              width: 22, // عرض العمود
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    // 2) نبني BarChart بعناصر BarChartData
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        // نجعل أعلى قيمة على المحور الرأسي أكبر بنسبة 20% لمنح مساحة فراغ
        maxY: (data.first.count.toDouble() * 1.2),
        barTouchData: BarTouchData(
          enabled: true,
          // إعدادات Tooltip لإظهار عدد الطلبات عند الضغط على العمود
          touchTooltipData: BarTouchTooltipData(
            // tooltipBgColor: Colors.grey.shade200,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final cc = data[group.x.toInt()];
              return BarTooltipItem(
                '${cc.code}\n',
                const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '${cc.count}',
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (double value, TitleMeta meta) {
                // قيمة value هنا هي فهرس العمود (index)
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                final code = data[index].code;
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(
                    code,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                // المحور الرأسي نعرض الأعداد الصحيحة فقط
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 28,
            ),
          ),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}

/// SideTitleWidget: مُدرج من مكتبة fl_chart 1.0.0 لموازنة وتدوير عناوين المحاور.
/// في حال لم تستطع الاستيراد مباشرة، يمكنك نسخ الكود من ملف utils في fl_chart 1.0.0.
/// لكن إذا استخدمت fl_chart: ^1.0.0، يجب أن تتمكن من الاستيراد بـ:
///    import 'package:fl_chart/src/utils/utils.dart';
/// وأن يظهر لديك الصنف SideTitleWidget دون مشكلة.
