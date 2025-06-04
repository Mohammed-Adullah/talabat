import 'package:flutter/material.dart';

/// كلاس مسؤول عن تحديد خصائص الشبكة (Grid) بشكل تلقائي
/// بناءً على حجم الشاشة الحالية (عرض الشاشة).
class ResponsiveGrid {
  /// دالة ثابتة ترجع كائن SliverGridDelegate حسب عرض الشاشة.
  /// تستخدم لتوليد شبكة مرنة (Responsive Grid) في الواجهات.
  static SliverGridDelegateWithFixedCrossAxisCount getGridDelegate(
    BoxConstraints constraints, // معلومات عن عرض الشاشة الحالي
  ) {
    int crossAxisCount;

    // إذا كان عرض الشاشة كبير جدًا (شاشات كبيرة جدًا)
    if (constraints.maxWidth >= 1600) {
      crossAxisCount = 5;
    }
    // إذا كان العرض بين 1200 و1600 (سطح مكتب عادي)
    else if (constraints.maxWidth >= 1200) {
      crossAxisCount = 4;
    }
    // إذا كان العرض بين 800 و1200 (تابلت أو شاشات صغيرة)
    else if (constraints.maxWidth >= 800) {
      crossAxisCount = 3;
    }
    // أقل من 800 (موبايل أو شاشات ضيقة)
    else {
      crossAxisCount = 2;
    }

    // إعادة إعدادات الشبكة المناسبة
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount, // عدد الأعمدة حسب العرض
      crossAxisSpacing: 40, // المسافة الأفقية بين العناصر
      mainAxisSpacing: 40, // المسافة العمودية بين العناصر
      childAspectRatio: 2.8, // نسبة العرض إلى الارتفاع لكل عنصر
    );
  }
}
