import 'customer_model.dart';

/// Represents the current filter selection.
/// `toQueryParams()` is unused today but is there so the exact
/// same object can drive `Uri.https(host, path, filter.toQueryParams())`
/// once there's a real API to filter server-side.
class CustomerFilter {
  final String status; // 'All' | 'Active' | 'Inactive'
  final String city;
  final String state;
  final String country;

  const CustomerFilter({
    this.status = 'All',
    this.city = '',
    this.state = '',
    this.country = '',
  });

  bool matches(CustomerModel customer) {
    final matchesStatus = status == 'All' || customer.status == status;

    final matchesCity = city.trim().isEmpty ||
        customer.city.toLowerCase().contains(city.trim().toLowerCase());

    final matchesState = state.trim().isEmpty ||
        customer.state.toLowerCase().contains(state.trim().toLowerCase());

    final matchesCountry = country.trim().isEmpty ||
        customer.country.toLowerCase().contains(country.trim().toLowerCase());

    return matchesStatus && matchesCity && matchesState && matchesCountry;
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (status != 'All') params['status'] = status;
    if (city.trim().isNotEmpty) params['city'] = city.trim();
    if (state.trim().isNotEmpty) params['state'] = state.trim();
    if (country.trim().isNotEmpty) params['country'] = country.trim();
    return params;
  }
}