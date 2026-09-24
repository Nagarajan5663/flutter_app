import 'package:flutter/material.dart';

import 'create_template_page.dart';
import 'edit_template_page.dart';
import 'template_models.dart';

class PdfTemplatesPage extends StatefulWidget {
  final VoidCallback onBack;

  const PdfTemplatesPage({
    super.key,
    required this.onBack,
  });

  @override
  State<PdfTemplatesPage> createState() => _PdfTemplatesPageState();
}

class _PdfTemplatesPageState extends State<PdfTemplatesPage> {
  final List<TemplateData> _templates = [
    const TemplateData(
      module: 'Bills',
      templateName: 'Standard Bills',
      isDefault: true,
    ),
    const TemplateData(
      module: 'Credit Notes',
      templateName: 'Standard Credit Notes',
      isDefault: true,
    ),
    const TemplateData(
      module: 'Delivery Challan',
      templateName: 'Standard Delivery Challan',
      isDefault: true,
    ),
    const TemplateData(
      module: 'Invoice',
      templateName: 'Standard Invoice',
      isDefault: true,
    ),
    const TemplateData(
      module: 'Payment Received',
      templateName: 'Standard Payment Received',
      isDefault: true,
    ),
    const TemplateData(
      module: 'Payments Made',
      templateName: 'Standard Payments Made',
      isDefault: true,
    ),
    const TemplateData(
      module: 'Purchase Order',
      templateName: 'Standard Purchase Order',
      isDefault: true,
    ),
    const TemplateData(
      module: 'Sales Order',
      templateName: 'Standard Sales Order',
      isDefault: true,
    ),
    const TemplateData(
      module: 'Vendor Credit Note',
      templateName: 'Standard Vendor Credit Note',
      isDefault: true,
    ),
  ];

  Future<void> _openCreateTemplate() async {
    final TemplateData? result =
        await Navigator.of(context).push<TemplateData>(
      MaterialPageRoute<TemplateData>(
        builder: (_) => const CreateTemplatePage(),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _templates.add(result);
    });
  }

  Future<void> _openEditTemplate(
    int index,
    TemplateData template,
  ) async {
    final TemplateData? result =
        await Navigator.of(context).push<TemplateData>(
      MaterialPageRoute<TemplateData>(
        builder: (_) => EditTemplatePage(
          template: template,
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _templates[index] = result;
    });
  }

  void _previewTemplate(TemplateData template) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.55,
      ),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 760,
              maxHeight: 650,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    14,
                    10,
                    14,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Template Preview',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(
                            0xFFE2E5E7,
                          ),
                        ),
                      ),
                      child: Text(
                        template.body.isEmpty
                            ? '''
${template.module.toUpperCase()}

{organization.name}
{organization.address}
GSTIN: {organization.gstin}

Bill To:

{customer.name}
{customer.billing_address}
GSTIN: {customer.gstin}
'''
                            : template.body,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          22,
          24,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'PDF Templates',
                    style: TextStyle(
                      color: Color(0xFF252A2E),
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openCreateTemplate,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    'New Template',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF20AE49),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                TextButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 16,
                  ),
                  label: const Text(
                    'Back to Settings',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE1E5E7),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F9FA),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE2E6E8),
                        ),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'TEMPLATE NAME',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: Text(
                            'ACTIONS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (int i = 0;
                      i < _templates.length;
                      i++)
                    _TemplateRow(
                      template: _templates[i],
                      onPreview: () {
                        _previewTemplate(
                          _templates[i],
                        );
                      },
                      onEdit: () {
                        _openEditTemplate(
                          i,
                          _templates[i],
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  final TemplateData template;
  final VoidCallback onPreview;
  final VoidCallback onEdit;

  const _TemplateRow({
    required this.template,
    required this.onPreview,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          color: const Color(0xFFEAF1F4),
          child: Text(
            template.module,
            style: const TextStyle(
              color: Color(0xFF1688E8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE6EAEC),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      template.templateName,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    if (template.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(
                            0xFFD8F3DF,
                          ),
                          borderRadius:
                              BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                            color:
                                Color(0xFF31924A),
                            fontSize: 9,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 170,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Preview',
                      onPressed: onPreview,
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 18,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Duplicate',
                      onPressed: () {},
                      icon: const Icon(
                        Icons.content_copy_outlined,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}