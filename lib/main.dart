// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart'; // << أضفنا هذا السطر
import 'package:talabat/core/app_theme.dart';
import 'package:talabat/viewmodels/home_viewmodel.dart';
import 'firebase_options.dart';
import 'package:responsive_framework/responsive_framework.dart';

// استورد ViewModel صفحة الإحصائيات
import 'viewmodels/statistics_viewmodel.dart';

// استورد جميع الشاشات (Views)
import 'views/login_screen.dart';
import 'views/home_screen.dart';
import 'views/new_order_screen.dart';
import 'views/review_order_screen.dart';
import 'views/item_management_screen.dart';
import 'views/statistics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FactoryOrdersApp());
}

class FactoryOrdersApp extends StatelessWidget {
  const FactoryOrdersApp({super.key});

  @override
  Widget build(BuildContext context) {
    // هنا نغلف MaterialApp بمزوّد واحد (ChangeNotifierProvider)
    // من نوع StatisticsViewModel حتى تتوفّر بيانات الإحصائيات في أي راوت
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StatisticsViewModel>(
          create: (_) => StatisticsViewModel(),
        ),
        ChangeNotifierProvider<HomeViewModel>(create: (_) => HomeViewModel()),
      ],
      child: MaterialApp(
        title: 'طلبات التشغيل',

        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.lightTheme,
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/new-order': (context) => const NewOrderScreen(),
          '/review_order': (context) => const ReviewOrderScreen(),
          '/itemmanagement': (context) => const ItemManagementScreen(),
          '/statistics': (context) => const StatisticsScreen(),
        },
      ),
    );
  }
}
