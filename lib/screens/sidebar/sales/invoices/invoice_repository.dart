import 'invoice_filter.dart';
import 'invoice_model.dart';

abstract class InvoiceRepository {
  Future<List<InvoiceModel>> getInvoices({InvoiceFilter? filter});
  Future<InvoiceModel> addInvoice(InvoiceModel invoice);
  Future<void> deleteInvoice(String id);
  Future<void> recordPayment(String id, double amount);
  Future<String> nextInvoiceNumber();
}

class InMemoryInvoiceRepository implements InvoiceRepository {
  InMemoryInvoiceRepository._internal();
  static final InMemoryInvoiceRepository instance = InMemoryInvoiceRepository._internal();
  factory InMemoryInvoiceRepository() => instance;

  final List<InvoiceModel> _invoices = [];
  int _nextId = 1;

  @override
  Future<List<InvoiceModel>> getInvoices({InvoiceFilter? filter}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = List<InvoiceModel>.from(_invoices);
    if (filter == null) return all;
    return all.where(filter.matches).toList();
  }

  @override
  Future<InvoiceModel> addInvoice(InvoiceModel invoice) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final withId = invoice.copyWith(id: (_nextId++).toString());
    _invoices.add(withId);
    return withId;
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _invoices.removeWhere((i) => i.id == id);
  }

  @override
  Future<void> recordPayment(String id, double amount) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _invoices.indexWhere((i) => i.id == id);
    if (index == -1) return;
    final current = _invoices[index];
    _invoices[index] = current.copyWith(amountPaid: current.amountPaid + amount);
  }

  @override
  Future<String> nextInvoiceNumber() async => 'INV-${_invoices.length + 1}';
}