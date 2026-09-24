import 'purchase_order_filter.dart';
import 'purchase_order_model.dart';

abstract class PurchaseOrderRepository {
  Future<List<PurchaseOrderModel>> getPurchaseOrders({PurchaseOrderFilter? filter});
  Future<PurchaseOrderModel> addPurchaseOrder(PurchaseOrderModel order);
  Future<void> deletePurchaseOrder(String id);
  Future<String> nextPoNumber();
}

/// Swap for ApiPurchaseOrderRepository later:
///   GET    $baseUrl/purchase-orders?...filter.toQueryParams()
///   POST   $baseUrl/purchase-orders   body: order.toJson()
///   DELETE $baseUrl/purchase-orders/$id
class InMemoryPurchaseOrderRepository implements PurchaseOrderRepository {
  InMemoryPurchaseOrderRepository._internal();
  static final InMemoryPurchaseOrderRepository instance =
      InMemoryPurchaseOrderRepository._internal();
  factory InMemoryPurchaseOrderRepository() => instance;

  final List<PurchaseOrderModel> _orders = [];
  int _nextId = 1;

  @override
  Future<List<PurchaseOrderModel>> getPurchaseOrders({PurchaseOrderFilter? filter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = List<PurchaseOrderModel>.from(_orders);
    if (filter == null) return all;
    return all.where(filter.matches).toList();
  }

  @override
  Future<PurchaseOrderModel> addPurchaseOrder(PurchaseOrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final withId = order.copyWith(id: (_nextId++).toString());
    _orders.add(withId);
    return withId;
  }

  @override
  Future<void> deletePurchaseOrder(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _orders.removeWhere((o) => o.id == id);
  }

  @override
  Future<String> nextPoNumber() async {
    return 'PO-${_orders.length + 1}';
  }
}