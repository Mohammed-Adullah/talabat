// lib/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // نحصل على الـ HomeViewModel المُزوَّد بواسطة Provider أعلى
    final homeVM = Provider.of<HomeViewModel>(context);

    // إذا تغيّرت حالة isSigningOut إلى true، ننقل المستخدم إلى شاشة الدخول
    // نستخدم addPostFrameCallback حتى لا نستدعي Navigator أثناء بناء الواجهة مباشرةً
    if (homeVM.isSigningOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // بعد إتمام تسجيل الخروج نعيد توجيه المستخدم إلى شاشة "/" (الدخول)
        Navigator.pushReplacementNamed(context, '/');
        // إذا كنت قد أضفت مسار '/login' في routes وفضلت استخدامه:
        // Navigator.pushReplacementNamed(context, '/login');
        // بعد التنقل، قد تحتاج إلى إعادة ضبط حالة isSigningOut إذا كانت ستُعاد
        homeVM.resetSignOutState();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل خروج',
            onPressed: () {
              // بدلاً من استدعاء FirebaseAuth هنا، نستدعي الدالة الموجودة في ViewModel
              homeVM.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // عمودين
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.8, // العرض أكبر من الارتفاع
          children: List.generate(homeVM.options.length, (index) {
            return Card(
              color: Theme.of(context).colorScheme.primary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => homeVM.onOptionSelected(context, index),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: LayoutBuilder(
                    builder: (context, innerConstraints) {
                      final iconSize = innerConstraints.maxHeight * 0.4;
                      final fontSize = innerConstraints.maxHeight * 0.1;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            homeVM.icons[index],
                            size: iconSize,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                homeVM.options[index],
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
