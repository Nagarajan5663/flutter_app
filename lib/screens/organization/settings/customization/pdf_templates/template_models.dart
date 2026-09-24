class TemplateData {
  final String module;
  final String templateName;
  final String body;
  final bool isDefault;

  const TemplateData({
    required this.module,
    required this.templateName,
    this.body = '',
    this.isDefault = false,
  });

  TemplateData copyWith({
    String? module,
    String? templateName,
    String? body,
    bool? isDefault,
  }) {
    return TemplateData(
      module: module ?? this.module,
      templateName: templateName ?? this.templateName,
      body: body ?? this.body,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}