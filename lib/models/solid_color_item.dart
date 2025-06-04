import 'package:talabat/models/paint_component.dart';

class SolidColorItem {
  final String localCode;
  final bool isMixed;
  final List<PaintComponent> components;

  SolidColorItem({
    required this.localCode,
    required this.isMixed,
    required this.components,
  });
}
