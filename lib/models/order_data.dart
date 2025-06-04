class OrderData {
  final String orderNumber;
  final String customerName;
  final String date;
  final String colorCode;
  final List<String> items;
  final String notes;

  OrderData({
    required this.orderNumber,
    required this.customerName,
    required this.date,
    required this.colorCode,
    required this.items,
    required this.notes,
  });
}