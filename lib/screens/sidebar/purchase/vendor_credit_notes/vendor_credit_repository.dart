import 'vendor_credit_filter.dart';
import 'vendor_credit_model.dart';

abstract class VendorCreditRepository {
  Future<List<VendorCreditModel>> getVendorCredits({VendorCreditFilter? filter});
  Future<VendorCreditModel> addVendorCredit(VendorCreditModel credit);
  Future<void> deleteVendorCredit(String id);
  Future<String> nextCreditNoteNumber();
  Future<VendorCreditModel> applyCredit(String creditId, double amountUsed);
}

/// Swap for ApiVendorCreditRepository later:
///   GET    $baseUrl/vendor-credits?...filter.toQueryParams()
///   POST   $baseUrl/vendor-credits   body: credit.toJson()
///   DELETE $baseUrl/vendor-credits/$id
class InMemoryVendorCreditRepository implements VendorCreditRepository {
  InMemoryVendorCreditRepository._internal();
  static final InMemoryVendorCreditRepository instance = InMemoryVendorCreditRepository._internal();
  factory InMemoryVendorCreditRepository() => instance;

  final List<VendorCreditModel> _credits = [];
  int _nextId = 1;

  @override
  Future<List<VendorCreditModel>> getVendorCredits({VendorCreditFilter? filter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = List<VendorCreditModel>.from(_credits);
    if (filter == null) return all;
    return all.where(filter.matches).toList();
  }

  @override
  Future<VendorCreditModel> addVendorCredit(VendorCreditModel credit) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final withId = credit.copyWith(id: (_nextId++).toString());
    _credits.add(withId);
    return withId;
  }

  @override
  Future<void> deleteVendorCredit(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _credits.removeWhere((c) => c.id == id);
  }

  @override
  Future<String> nextCreditNoteNumber() async {
    return 'VCN-${_credits.length + 1}';
  }

  @override
  Future<VendorCreditModel> applyCredit(String creditId, double amountUsed) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _credits.indexWhere((c) => c.id == creditId);
    if (index == -1) {
      throw Exception('Vendor credit note not found');
    }
    final credit = _credits[index];
    final updated = credit.copyWith(amountUsed: credit.amountUsed + amountUsed);
    _credits[index] = updated;
    return updated;
  }
}