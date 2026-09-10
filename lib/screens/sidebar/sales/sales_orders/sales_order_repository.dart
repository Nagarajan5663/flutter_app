import 'sales_order_model.dart';

abstract class SalesOrderRepository {
  Future<List<SalesOrderModel>> getSalesOrders();
  Future<SalesOrderModel> addSalesOrder(SalesOrderModel order);
}

class InMemorySalesOrderRepository implements SalesOrderRepository {
  InMemorySalesOrderRepository._internal();
  static final InMemorySalesOrderRepository instance = InMemorySalesOrderRepository._internal();
  factory InMemorySalesOrderRepository() => instance;

  final List<SalesOrderModel> _orders = [];
  int _nextId = 1;

  @override
  Future<List<SalesOrderModel>> getSalesOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<SalesOrderModel>.from(_orders);
  }

  @override
  Future<SalesOrderModel> addSalesOrder(SalesOrderModel order) async {
    final saved = SalesOrderModel(
      id: (_nextId++).toString(),
      soNumber: order.soNumber,
      customerId: order.customerId,
      customerName: order.customerName,
      orderDate: order.orderDate,
      items: order.items,
    );
    _orders.add(saved);
    return saved;
  }
}
