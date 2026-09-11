class InventoryAdjustmentModel {
  final String date;
  final String item;
  final String sku;
  final String type;
  final String quantity;
  final String reason;
  final String status;

  InventoryAdjustmentModel({
    required this.date,
    required this.item,
    required this.sku,
    required this.type,
    required this.quantity,
    required this.reason,
    required this.status,
  });
}