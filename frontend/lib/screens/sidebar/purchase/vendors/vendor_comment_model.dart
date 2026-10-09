class VendorComment {
  const VendorComment({
    required this.id,
    required this.vendorId,
    required this.authorName,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String vendorId;
  final String authorName;
  final String comment;
  final DateTime? createdAt;

  factory VendorComment.fromJson(Map<String, dynamic> json) {
    return VendorComment(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? 'User',
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
