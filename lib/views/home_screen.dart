import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('الصفحة الرئيسية')),
        body: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2, // عمودين
                crossAxisSpacing: 16, // المسافة الأفقية بين الأعمدة
                mainAxisSpacing: 16, // المسافة الرأسية بين الصفوف
                childAspectRatio: 2.8, // العرض أكبر من الارتفاع
                children: List.generate(viewModel.options.length, (index) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => viewModel.onOptionSelected(context, index),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: LayoutBuilder(
                          builder: (context, innerConstraints) {
                            // نأخذ ارتفاع الخلية المتاح
                            final iconSize = innerConstraints.maxHeight * 0.4;
                            final fontSize = innerConstraints.maxHeight * 0.1;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(viewModel.icons[index], size: iconSize),
                                const SizedBox(height: 4),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      viewModel.options[index],
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600,
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
            );
          },
        ),
      ),
    );
  }
}
