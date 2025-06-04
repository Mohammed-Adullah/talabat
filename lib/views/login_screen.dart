import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(), // ربط ViewModel بالواجهة
      child: Scaffold(
        appBar: AppBar(
          title: Text('تسجيل الدخول'),

          // centerTitle: true,
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<LoginViewModel>(
            builder: (context, viewModel, child) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),

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
