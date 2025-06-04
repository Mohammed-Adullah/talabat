// lib/viewmodels/statistics_viewmodel.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// فئة بسيطة لتخزين زوج (رمز اللون + عدد التكرارات)
class ColorCount {
  final String code; // رمز اللون
  final int count; // عدد المرات التي طلب فيها
  ColorCount({required this.code, required this.count});
}

/// تعريف القيم الممكنة لفترة الإحصائيات
enum StatisticsPeriod { weekly, monthly, quarterly, halfYearly, yearly }

class StatisticsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1) المتغير الخاص بالفترة المُختارة حاليًا (افتراضيًا: أسبوعي)
  StatisticsPeriod _currentPeriod = StatisticsPeriod.weekly;

  // 2) حالات التحميل والخطأ
  bool _isLoading = false;
  String? _error;

  // 3) القوائم النهائية لأعلى 10 ألوان
  List<ColorCount> _topSadah = [];
  List<ColorCount> _topKhashabi = [];

  /// الإنشائي: عند إنشاء الـ ViewModel، نحمّل البيانات فورًا للأسبوع الماضي
  StatisticsViewModel() {
    loadStatistics();
  }

  // —————————— GETTERS ——————————

  StatisticsPeriod get currentPeriod => _currentPeriod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _error;
  List<ColorCount> get topSadah => List.unmodifiable(_topSadah);
  List<ColorCount> get topKhashabi => List.unmodifiable(_topKhashabi);

  /// تغيير الفترة واستدعاء إعادة تحميل البيانات
  Future<void> setPeriod(StatisticsPeriod p) async {
    if (p == _currentPeriod) return;
    _currentPeriod = p;
    await loadStatistics();
  }

  /// الدالة الرئيسية التي تتولى:
  ///  1. حساب نقطة البداية (cutoff) بناءً على الفترة المختارة
  ///  2. استعلام Firestore عن جميع المستندات التي تاريخها >= نقطة البداية
  ///  3. تجميع التكرارات لكل رمز لون في خريطتين (سادة وخشابي)
  ///  4. فرز القوائم واختيار أعلى 10
  Future<void> loadStatistics() async {
    // خطوات تهيئة الحالة:
    _isLoading = true;
    _error = null;
    _topSadah = [];
    _topKhashabi = [];
    notifyListeners();

    try {
      // 1) نحسب "cutoff" بناءً على _currentPeriod
      DateTime now = DateTime.now();
      DateTime cutoff;
      switch (_currentPeriod) {
        case StatisticsPeriod.weekly:
          cutoff = now.subtract(const Duration(days: 7));
          break;
        case StatisticsPeriod.monthly:
          cutoff = DateTime(
            now.year,
            now.month - 1,
            now.day,
            now.hour,
            now.minute,
            now.second,
          );
          break;
        case StatisticsPeriod.quarterly:
          cutoff = DateTime(
            now.year,
            now.month - 3,
            now.day,
            now.hour,
            now.minute,
            now.second,
          );
          break;
        case StatisticsPeriod.halfYearly:
          cutoff = DateTime(
            now.year,
            now.month - 6,
            now.day,
            now.hour,
            now.minute,
            now.second,
          );
          break;
        case StatisticsPeriod.yearly:
          cutoff = DateTime(
            now.year - 1,
            now.month,
            now.day,
            now.hour,
            now.minute,
            now.second,
          );
          break;
      }

      // 2) نحول الـ DateTime إلى Timestamp Firestore
      final cutoffTimestamp = Timestamp.fromDate(cutoff);

      // 3) ننفّذ الاستعلام على مجموعة "orders"
      final querySnapshot = await _firestore
          .collection('orders')
          .where('orderTimestamp', isGreaterThanOrEqualTo: cutoffTimestamp)
          .get();

      // 4) نعد خريطتين فارغتين لحساب التكرارات
      final Map<String, int> countsSadahMap = {};
      final Map<String, int> countsKhashabiMap = {};

      // 5) نمرّ على كل مستند (document) نأتيه من Firestore
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final code = (data['localColorCode'] as String?)?.trim(); // رمز اللون
        final type = (data['colorType'] as String?)
            ?.trim(); // "سادة" أو "خشابي"

        if (code == null || code.isEmpty || type == null || type.isEmpty) {
          // إذا أحد الحقلين فارغ أو null، نتجنّب إضافة
          continue;
        }
        // 6) نزيد العداد في الخريطة المناسبة
        if (type == 'سادة') {
          countsSadahMap[code] = (countsSadahMap[code] ?? 0) + 1;
        } else if (type == 'خشابي') {
          countsKhashabiMap[code] = (countsKhashabiMap[code] ?? 0) + 1;
        }
      }

      // 7) نحول كل خريطة إلى قائمة ColorCount ونرتّبها تنازلياً ونأخذ أول 10
      _topSadah =
          countsSadahMap.entries
              .map((e) => ColorCount(code: e.key, count: e.value))
              .toList()
            ..sort((a, b) => b.count.compareTo(a.count));
      if (_topSadah.length > 10) {
        _topSadah = _topSadah.sublist(0, 10);
      }

      _topKhashabi =
          countsKhashabiMap.entries
              .map((e) => ColorCount(code: e.key, count: e.value))
              .toList()
            ..sort((a, b) => b.count.compareTo(a.count));
      if (_topKhashabi.length > 10) {
        _topKhashabi = _topKhashabi.sublist(0, 10);
      }
    } catch (e) {
      // إذا حدث أي خطأ أثناء جلب البيانات من Firestore
      _error = "حدث خطأ أثناء جلب البيانات: $e";
    }

    // 8) نضع isLoading = false وننبّه المستمعين (listeners) حتى تنعكس القيم الجديدة في الواجهة
    _isLoading = false;
    notifyListeners();
  }
}
