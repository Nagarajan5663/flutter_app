import 'bill_filter.dart';
import 'bill_model.dart';

abstract class BillRepository {
  Future<List<BillModel>> getBills({BillFilter? filter});
  Future<BillModel> addBill(BillModel bill);
  Future<void> deleteBill(String id);
  Future<String> nextBillNumber();
  Future<BillModel> recordPayment(String billId, double amountPaid);
}

/// Swap for ApiBillRepository later:
///   GET    $baseUrl/bills?...filter.toQueryParams()
///   POST   $baseUrl/bills   body: bill.toJson()
///   DELETE $baseUrl/bills/$id
class InMemoryBillRepository implements BillRepository {
  InMemoryBillRepository._internal();
  static final InMemoryBillRepository instance = InMemoryBillRepository._internal();
  factory InMemoryBillRepository() => instance;

  final List<BillModel> _bills = [];
  int _nextId = 1;

  @override
  Future<List<BillModel>> getBills({BillFilter? filter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = List<BillModel>.from(_bills);
    if (filter == null) return all;
    return all.where(filter.matches).toList();
  }

  @override
  Future<BillModel> addBill(BillModel bill) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final withId = bill.copyWith(id: (_nextId++).toString());
    _bills.add(withId);
    return withId;
  }

  @override
  Future<void> deleteBill(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _bills.removeWhere((b) => b.id == id);
  }

  @override
  Future<String> nextBillNumber() async {
    return 'BILL-${_bills.length + 1}';
  }

  @override
  Future<BillModel> recordPayment(String billId, double amountPaid) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _bills.indexWhere((b) => b.id == billId);
    if (index == -1) {
      throw Exception('Bill not found');
    }
    final bill = _bills[index];
    final newAmountPaid = bill.amountPaid + amountPaid;
    final updated = bill.copyWith(amountPaid: newAmountPaid);
    _bills[index] = updated;
    return updated;
  }
}