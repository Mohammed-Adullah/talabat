import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginViewModel extends ChangeNotifier {
  // وحدة تحكم لحقل اسم المستخدم
  final TextEditingController usernameController = TextEditingController();

  // وحدة تحكم لحقل كلمة المرور
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;
  bool _isLoading = false; // متغيّر لتتبّع حالة التحميل
  bool get isLoading => _isLoading;
  // دالة التحقق من إدخال الحقول
  bool validateInputs(BuildContext context) {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم المستخدم وكلمة المرور')),
      );
      return false;
    }
    return true;
  }

  // دالة تسجيل الدخول عبر Firebase
  Future<void> login(BuildContext context) async {
    if (!validateInputs(context)) return;
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );
      // بمجرد انتهاء الـ await نتحقق أولاً من context.mounted
      if (!context.mounted) return;
      // الانتقال إلى الشاشة الرئيسية واستبدال شاشة الدخول
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'حدث خطأ أثناء تسجيل الدخول';
      notifyListeners(); // لإشعار الواجهة بوجود خطأ
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage!)));
    } finally {
      // في النهاية، أعِد isLoading إلى false
      _isLoading = false;
      notifyListeners();
    }
  }
}
