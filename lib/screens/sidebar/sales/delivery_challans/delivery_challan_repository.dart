import 'delivery_challan_filter.dart';
import 'delivery_challan_model.dart';

abstract class DeliveryChallanRepository {
  Future<List<DeliveryChallanModel>> getChallans({DeliveryChallanFilter? filter});
  Future<DeliveryChallanModel> addChallan(DeliveryChallanModel challan);
  Future<void> deleteChallan(String id);
  Future<String> nextChallanNumber();
}

class InMemoryDeliveryChallanRepository implements DeliveryChallanRepository {
  InMemoryDeliveryChallanRepository._internal();
  static final InMemoryDeliveryChallanRepository instance =
      InMemoryDeliveryChallanRepository._internal();
  factory InMemoryDeliveryChallanRepository() => instance;

  final List<DeliveryChallanModel> _challans = [];
  int _nextId = 1;

  @override
  Future<List<DeliveryChallanModel>> getChallans({DeliveryChallanFilter? filter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = List<DeliveryChallanModel>.from(_challans);
    if (filter == null) return all;
    return all.where(filter.matches).toList();
  }

  @override
  Future<DeliveryChallanModel> addChallan(DeliveryChallanModel challan) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final withId = challan.copyWith(id: (_nextId++).toString());
    _challans.add(withId);
    return withId;
  }

  @override
  Future<void> deleteChallan(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _challans.removeWhere((c) => c.id == id);
  }

  @override
  Future<String> nextChallanNumber() async => 'DC-${_challans.length + 1}';
}