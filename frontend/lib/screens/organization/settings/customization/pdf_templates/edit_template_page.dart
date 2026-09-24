import 'package:flutter/material.dart';

import 'template_editor.dart';
import 'template_models.dart';

class EditTemplatePage extends StatefulWidget {
  final TemplateData template;

  const EditTemplatePage({
    super.key,
    required this.template,
  });

  @override
  State<EditTemplatePage> createState() =>
      _EditTemplatePageState();
}

class _EditTemplatePageState
    extends State<EditTemplatePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _bodyController;

  late String _module;

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
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
      text: widget.template.templateName,
    );

    _bodyController =
        TextEditingController(
      text: widget.template.body,
    );

    _module =
        widget.template.module;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveTemplate() {
    Navigator.of(context).pop(
      widget.template.copyWith(
        templateName:
            _nameController.text.trim(),
        module: _module,
        body:
            _bodyController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF3F8FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          22,
          28,
          35,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Edit Template',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      _saveTemplate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(
                    Icons.save_rounded,
                    size: 16,
                  ),
                  label:
                      const Text('Save'),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller:
                              _nameController,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Template Name',
                            border:
                                OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child:
                            DropdownButtonFormField<
                                String>(
                          initialValue:
                              _module,
                          isExpanded: true,
                          dropdownColor:
                              Colors.white,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Module',
                            border:
                                OutlineInputBorder(),
                          ),
                          items:
                              _modules.map(
                            (module) {
                              return DropdownMenuItem<
                                  String>(
                                value:
                                    module,
                                child:
                                    Text(
                                  module,
                                ),
                              );
                            },
                          ).toList(),
                          onChanged:
                              (value) {
                            if (value ==
                                null) {
                              return;
                            }

                            setState(() {
                              _module =
                                  value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Template Body',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TemplateEditor(
                    controller:
                        _bodyController,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
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
}