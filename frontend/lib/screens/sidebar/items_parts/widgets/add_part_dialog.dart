import 'package:flutter/material.dart';

import '../part_model.dart';
import 'glass_widgets.dart';

class AddPartDialog extends StatefulWidget {
  final PartModel? initialPart;

  const AddPartDialog({
    super.key,
    this.initialPart,
  });

  @override
  State<AddPartDialog> createState() =>
      _AddPartDialogState();
}

class _AddPartDialogState
    extends State<AddPartDialog> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController skuController;
  late final TextEditingController
      purchasePriceController;
  late final TextEditingController
      descriptionController;

  bool get isEditing =>
      widget.initialPart != null;

  @override
  void initState() {
    super.initState();

    final part = widget.initialPart;

    nameController = TextEditingController(
      text: part?.name ?? '',
    );

    skuController = TextEditingController(
      text: part?.sku ?? '',
    );

    purchasePriceController =
        TextEditingController(
      text: part?.purchasePrice ?? '',
    );

    descriptionController =
        TextEditingController(
      text: part?.description ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    skuController.dispose();
    purchasePriceController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  String? _validatePrice(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Please enter purchase price';
    }

    final number =
        double.tryParse(value.trim());

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number < 0) {
      return 'Price cannot be negative';
    }

    return null;
  }

  void _savePart() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final PartModel part = PartModel(
      name: nameController.text.trim(),
      sku: skuController.text.trim(),
      purchasePrice:
          purchasePriceController.text.trim(),
      description:
          descriptionController.text.trim(),
    );

    Navigator.of(context).pop(part);
  }

  @override
  Widget build(BuildContext context) {
    return GlassModalShell(
      maxWidth: 680,
      maxHeight: 760,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          30,
          28,
          30,
          28,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              GlassDialogHeader(
                title: isEditing
                    ? 'Edit Part'
                    : 'Add New Part',
                subtitle: isEditing
                    ? 'Update your inventory part details.'
                    : 'Create a new component for your inventory.',
                icon: Icons
                    .precision_manufacturing_outlined,
                onClose: () {
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 28),

              const GlassLabel(
                'Part Name',
                required: true,
              ),

              GlassTextField(
                controller: nameController,
                hintText: 'Enter part name',
                prefixIcon:
                    Icons.settings_outlined,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter part name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 19),

              LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final bool twoColumns =
                      constraints.maxWidth >= 520;

                  final sku = Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const GlassLabel(
                        'SKU',
                        required: true,
                      ),
                      GlassTextField(
                        controller: skuController,
                        hintText: 'Enter SKU',
                        prefixIcon:
                            Icons.qr_code_2_rounded,
                        validator: (value) {
                          if (value == null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'Please enter SKU';
                          }

                          return null;
                        },
                      ),
                    ],
                  );

                  final price = Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const GlassLabel(
                        'Purchase Price',
                        required: true,
                      ),
                      GlassTextField(
                        controller:
                            purchasePriceController,
                        hintText: '0.00',
                        prefixIcon: Icons
                            .currency_rupee_rounded,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validatePrice,
                      ),
                    ],
                  );

                  if (twoColumns) {
                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(child: sku),
                        const SizedBox(width: 16),
                        Expanded(child: price),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      sku,
                      const SizedBox(height: 19),
                      price,
                    ],
                  );
                },
              ),

              const SizedBox(height: 19),

              const GlassLabel('Description'),

              GlassTextField(
                controller:
                    descriptionController,
                hintText:
                    'Enter part description',
                prefixIcon:
                    Icons.notes_rounded,
                maxLines: 4,
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    GlassButton(
                      label: 'Close',
                      icon: Icons.close_rounded,
                      primary: false,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    GlassButton(
                      label: isEditing
                          ? 'Update Part'
                          : 'Save Part',
                      icon: Icons.save_outlined,
                      onPressed: _savePart,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}