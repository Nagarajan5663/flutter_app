import 'package:flutter/material.dart';

import 'template_editor.dart';
import 'template_models.dart';

class CreateTemplatePage extends StatefulWidget {
  const CreateTemplatePage({
    super.key,
  });

  @override
  State<CreateTemplatePage> createState() =>
      _CreateTemplatePageState();
}

class _CreateTemplatePageState
    extends State<CreateTemplatePage> {
  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _bodyController =
      TextEditingController();

  String _module = 'Invoice';
  String? _nameError;

  static const List<String> _modules = [
    'Bills',
    'Credit Notes',
    'Delivery Challan',
    'Invoice',
    'Payment Received',
    'Payments Made',
    'Purchase Order',
    'Sales Order',
    'Vendor Credit Note',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveTemplate() {
    final String name =
        _nameController.text.trim();

    setState(() {
      _nameError =
          name.isEmpty
              ? 'Template name is required'
              : null;
    });

    if (name.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      TemplateData(
        module: _module,
        templateName: name,
        body: _bodyController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(26, 20, 26, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Text(
                      'Template Name',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Text(
                      'Module',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: _fieldDecoration(
                      errorText: _nameError,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _module,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF3A3A3A),
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      color: Color(0xFF1F1F1F),
                      fontSize: 17,
                    ),
                    decoration: _fieldDecoration(),
                    items: _modules
                        .map(
                          (module) => DropdownMenuItem<String>(
                            value: module,
                            child: Text(module),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _module = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Template Body',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: TemplateEditor(
                      controller: _bodyController,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _saveTemplate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(
                          Icons.save_rounded,
                          size: 16,
                        ),
                        label: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    String? errorText,
  }) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      errorText: errorText,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 17,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFCBCBCB),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFB5BCC1),
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFDC5B5B),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFDC5B5B),
        ),
      ),
    );
  }
}