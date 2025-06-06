import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talabat/views/widgets/animated_logo.dart';

import '../viewmodels/login_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // نحصل على عرض الشاشة لاستخدامه في ضبط حجم الشعار
    final screenWidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(), // ربط ViewModel بالواجهة
      child: Scaffold(
        appBar: AppBar(title: const Text('تسجيل الدخول')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<LoginViewModel>(
            builder: (context, viewModel, child) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // فراغ علوي بسيط
                    const SizedBox(height: 40),
                    Image.asset(
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.15,
                      'assets/images/TALABAT LOGO.png',
                      // color: Color.fromARGB(255, 32, 101, 135),

                      // نسمح للصورة بأن تحافظ على نسبة الطول للعرض تلقائيًا
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),

                    // حقل إدخال البريد الإلكتروني
                    TextField(
                      controller: viewModel.usernameController,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // حقل إدخال كلمة المرور
                    TextField(
                      controller: viewModel.passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    viewModel.isLoading
                        ? const AnimatedLogo()
                        :
                          // زر تسجيل الدخول
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => viewModel.login(context),
                              child: const Text('تسجيل الدخول'),
                            ),
                          ),

                    // رسالة الخطأ إن وجدت
                    if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
