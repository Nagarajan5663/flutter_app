class CustomerModel {
  final String? id;

  // --- New Vendor form fields (from the reference app) ---
  final String vendorType; // 'Business' or 'Individual'
  final String salutation; // 'Mr.', 'Mrs.', 'Ms.', 'Dr.'
  final String firstName;
  final String lastName;
  final String website;
  final String gstApplicable; // 'Yes' or 'No'

  // Billing address
  final String billingStreet;
  final String billingZip;

  // Shipping address
  final bool shippingSameAsBilling;
  final String shippingStreet;
  final String shippingCity;
  final String shippingState;
  final String shippingZip;
  final String shippingCountry;

  // --- Existing fields (used by vendors_page.dart, vendor_filter.dart,
  // vendor_repository.dart) — kept as-is so nothing else needs to change.
  // `vendorName` is populated from the "Display Name" field.
  // `city` / `state` / `country` represent the Billing City/State/Country.
  final String vendorName;
  final String companyName;
  final String email;
  final String phone;
  final String city;
  final String state;
  final String country;
  final String status; // 'Active' or 'Inactive'

  String get customerName => vendorName;

  CustomerModel({
    this.id,
    this.vendorType = 'Business',
    this.salutation = 'Mr.',
    this.firstName = '',
    this.lastName = '',
    this.website = '',
    this.gstApplicable = 'No',
    this.billingStreet = '',
    this.billingZip = '',
    this.shippingSameAsBilling = true,
    this.shippingStreet = '',
    this.shippingCity = '',
    this.shippingState = '',
    this.shippingZip = '',
    this.shippingCountry = '',
    required this.vendorName,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.city,
    required this.state,
    required this.country,
    required this.status,
  });

  CustomerModel copyWith({
    String? id,
    String? vendorType,
    String? salutation,
    String? firstName,
    String? lastName,
    String? website,
    String? gstApplicable,
    String? billingStreet,
    String? billingZip,
    bool? shippingSameAsBilling,
    String? shippingStreet,
    String? shippingCity,
    String? shippingState,
    String? shippingZip,
    String? shippingCountry,
    String? vendorName,
    String? companyName,
    String? email,
    String? phone,
    String? city,
    String? state,
    String? country,
    String? status,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      vendorType: vendorType ?? this.vendorType,
      salutation: salutation ?? this.salutation,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      website: website ?? this.website,
      gstApplicable: gstApplicable ?? this.gstApplicable,
      billingStreet: billingStreet ?? this.billingStreet,
      billingZip: billingZip ?? this.billingZip,
      shippingSameAsBilling: shippingSameAsBilling ?? this.shippingSameAsBilling,
      shippingStreet: shippingStreet ?? this.shippingStreet,
      shippingCity: shippingCity ?? this.shippingCity,
      shippingState: shippingState ?? this.shippingState,
      shippingZip: shippingZip ?? this.shippingZip,
      shippingCountry: shippingCountry ?? this.shippingCountry,
      vendorName: vendorName ?? this.vendorName,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      status: status ?? this.status,
    );
  }

  // Ready for when a real backend sends/receives JSON.
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString(),
      vendorType: json['vendorType']?.toString() ?? 'Business',
      salutation: json['salutation']?.toString() ?? 'Mr.',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      gstApplicable: json['gstApplicable']?.toString() ?? 'No',
      billingStreet: json['billingStreet']?.toString() ?? '',
      billingZip: json['billingZip']?.toString() ?? '',
      shippingSameAsBilling: json['shippingSameAsBilling'] as bool? ?? true,
      shippingStreet: json['shippingStreet']?.toString() ?? '',
      shippingCity: json['shippingCity']?.toString() ?? '',
      shippingState: json['shippingState']?.toString() ?? '',
      shippingZip: json['shippingZip']?.toString() ?? '',
      shippingCountry: json['shippingCountry']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vendorType': vendorType,
      'salutation': salutation,
      'firstName': firstName,
      'lastName': lastName,
      'website': website,
      'gstApplicable': gstApplicable,
      'billingStreet': billingStreet,
      'billingZip': billingZip,
      'shippingSameAsBilling': shippingSameAsBilling,
      'shippingStreet': shippingStreet,
      'shippingCity': shippingCity,
      'shippingState': shippingState,
      'shippingZip': shippingZip,
      'shippingCountry': shippingCountry,
      'vendorName': vendorName,
      'companyName': companyName,
      'email': email,
      'phone': phone,
      'city': city,
      'state': state,
      'country': country,
      'status': status,
    };
  }
}