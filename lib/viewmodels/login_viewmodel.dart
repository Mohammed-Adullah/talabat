import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginViewModel extends ChangeNotifier {
  // وحدة تحكم لحقل اسم المستخدم
  final TextEditingController usernameController = TextEditingController();

  // وحدة تحكم لحقل كلمة المرور
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;

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

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      // الانتقال إلى الشاشة الرئيسية واستبدال شاشة الدخول
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'حدث خطأ أثناء تسجيل الدخول';
      notifyListeners(); // لإشعار الواجهة بوجود خطأ
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage!)));
    }
  }
}
