import 'package:talabat/models/paint_component.dart';

class WoodColorItem {
  final String localCode;
  final bool isMixed;
  final List<PaintComponent> components;
  final String filmCode;

  WoodColorItem({
    required this.localCode,
    required this.isMixed,
    required this.components,
    required this.filmCode,
  });
}
