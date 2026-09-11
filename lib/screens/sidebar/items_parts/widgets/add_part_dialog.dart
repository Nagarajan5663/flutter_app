import 'package:flutter/material.dart';

class AddPartDialog extends StatefulWidget {
  const AddPartDialog({super.key});

  @override
  State<AddPartDialog> createState() => _AddPartDialogState();
}

class _AddPartDialogState extends State<AddPartDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController skuController = TextEditingController();
  final TextEditingController purchasePriceController =
      TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    skuController.dispose();
    purchasePriceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _savePart() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Part added successfully.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // TITLE
                // ==================================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Part',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF123456),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ==================================================
                // PART NAME
                // ==================================================

                _buildLabel('Part Name'),

                _buildTextField(
                  controller: nameController,
                  hintText: 'Enter part name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter part name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // SKU
                // ==================================================

                _buildLabel('SKU'),

                _buildTextField(
                  controller: skuController,
                  hintText: 'Enter SKU',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter SKU';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // PURCHASE PRICE
                // ==================================================

                _buildLabel('Purchase Price'),

                _buildTextField(
                  controller: purchasePriceController,
                  hintText: '0.00',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter purchase price';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                _buildLabel('Description'),

                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter part description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: Color(0xFFD9DEE5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: Color(0xFF123456),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // BUTTONS
                // ==================================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton(
                      onPressed: _savePart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF123456),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Save Part'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: Color(0xFFD9DEE5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: Color(0xFF123456),
            width: 2,
          ),
        ),
      ),
    );
  }
}