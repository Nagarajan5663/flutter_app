import 'customer_filter.dart';
import 'customer_model.dart';

abstract class CustomerRepository {
  Future<List<CustomerModel>> getCustomers({CustomerFilter? filter});
  Future<CustomerModel> addCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
}

/// Singleton so every page (Vendors, Purchase Orders, Bills, ...)
/// sees the same in-memory vendor list instead of its own empty copy.
/// Swap for ApiVendorRepository later using the same interface.
class InMemoryCustomerRepository implements CustomerRepository {
  InMemoryCustomerRepository._internal();
  static final InMemoryCustomerRepository instance = InMemoryCustomerRepository._internal();
  factory InMemoryCustomerRepository() => instance;

  final List<CustomerModel> _customers = [];
  int _nextId = 1;

  @override
  Future<List<CustomerModel>> getCustomers({CustomerFilter? filter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = List<CustomerModel>.from(_customers);
    if (filter == null) return all;
    return all.where(filter.matches).toList();
  }

  @override
  Future<CustomerModel> addCustomer(CustomerModel customer) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final withId = customer.copyWith(id: (_nextId++).toString());
    _customers.add(withId);
    return withId;
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _customers.removeWhere((customer) => customer.id == id);
  }
}