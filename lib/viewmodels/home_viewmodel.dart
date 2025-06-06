import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // قائمة المسارات المقابلة لكل خيار
  final List<String> routes = [
    '/new-order', // شاشة إنشاء طلب تشغيل جديد
    '/review_order', // شاشة مراجعة طلب تشغيل سابق
    '/statistics', // شاشة الإحصائيات
    '/itemmanagement', // شاشة إدارة الأصناف
  ];

  bool _isSigningOut = false;
  bool get isSigningOut => _isSigningOut;

  /// دالة تسجيل الخروج
  Future<void> signOut() async {
    _isSigningOut = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signOut();
      // بعد نجاح تسجيل الخروج، يبقى isSigningOut true
      // حتى تنقل الـ View المستخدم إلى شاشة تسجيل الدخول
    } catch (e) {
      // في حال وجود خطأ، يمكنك هنا التعامل مع الخطأ حسب الحاجة
      _isSigningOut = false;
      notifyListeners();
    }
  }

  /// إعادة ضبط حالة تسجيل الخروج، إذا احتجت لعرض Home مرة أخرى
  void resetSignOutState() {
    _isSigningOut = false;
    notifyListeners();
  }

  /// الدالة التي تُنفذ عند الضغط على أحد العناصر
  void onOptionSelected(BuildContext context, int index) {
    final route = routes[index];

    if (route.isNotEmpty) {
      Navigator.pushNamed(context, route);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('هذه الميزة لم تُنفذ بعد')));
    }
  }
}
