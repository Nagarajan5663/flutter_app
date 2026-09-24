import 'vendor_filter.dart';
import 'vendor_model.dart';

abstract class VendorRepository {
  Future<List<VendorModel>> getVendors({VendorFilter? filter});
  Future<VendorModel> addVendor(VendorModel vendor);
  Future<void> deleteVendor(String id);
}

/// Singleton so every page (Vendors, Purchase Orders, Bills, ...)
/// sees the same in-memory vendor list instead of its own empty copy.
/// Swap for ApiVendorRepository later using the same interface.
class InMemoryVendorRepository implements VendorRepository {
  InMemoryVendorRepository._internal();
  static final InMemoryVendorRepository instance = InMemoryVendorRepository._internal();
  factory InMemoryVendorRepository() => instance;

  final List<VendorModel> _vendors = [];
  int _nextId = 1;

  @override
  Future<List<VendorModel>> getVendors({VendorFilter? filter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = List<VendorModel>.from(_vendors);
    if (filter == null) return all;
    return all.where(filter.matches).toList();
  }

  @override
  Future<VendorModel> addVendor(VendorModel vendor) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final withId = vendor.copyWith(id: (_nextId++).toString());
    _vendors.add(withId);
    return withId;
  }

  @override
  Future<void> deleteVendor(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _vendors.removeWhere((v) => v.id == id);
  }
}