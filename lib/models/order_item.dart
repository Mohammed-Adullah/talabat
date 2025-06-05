// هذا الكلاس يمثل صنف ألمنيوم مضاف إلى الطلب

class OrderItem {
  // اسم الصنف (مثلاً: AL100)
  final String name;

  // الكمية المطلوبة من هذا الصنف
  final int quantity;

  // مصدر الصنف: إما "من المستودع" أو "من الزبون"
  final String source;

  // الباني الأساسي للكلاس، يتطلب كل القيم
  OrderItem({required this.name, required this.quantity, required this.source});
}
