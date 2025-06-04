import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  // قائمة الخيارات التي تظهر في الصفحة الرئيسية
  final List<String> options = [
    'إنشاء طلب تشغيل جديد',
    'مراجعة طلب تشغيل سابق',
    'إحصائيات',
    'إدارة الأصناف',
  ];

  final List<IconData> icons = [
    Icons.add,
    Icons.history,
    Icons.bar_chart,
    Icons.category,
  ];
  // قائمة المسارات المقابلة لكل خيار (بعضها لم يتم تنفيذه بعد)
  final List<String> routes = [
    '/new-order', // المسار إلى شاشة إنشاء طلب
    '/review_order', // سيتم تنفيذه لاحقاً
    '/Statistics', // سيتم تنفيذه لاحقاً
    '/itemmanagement', // سيتم تنفيذه لاحقاً
  ];

  // الدالة التي تُنفذ عند الضغط على أحد العناصر
  void onOptionSelected(BuildContext context, int index) {
    final route = routes[index];

    if (route.isNotEmpty) {
      // إذا كان هناك مسار صالح → انتقل إليه
      Navigator.pushNamed(context, route);
    } else {
      // إذا لم يكن هناك مسار → عرض رسالة بأن الميزة غير متوفرة
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('هذه الميزة لم تُنفذ بعد')));
    }
  }
}
