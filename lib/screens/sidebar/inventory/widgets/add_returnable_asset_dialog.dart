import 'package:flutter/material.dart';

class AddReturnableAssetDialog extends StatefulWidget {
  const AddReturnableAssetDialog({
    super.key,
  });

  @override
  State<AddReturnableAssetDialog> createState() =>
      _AddReturnableAssetDialogState();
}

class _AddReturnableAssetDialogState
    extends State<AddReturnableAssetDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ================================================================
  // CONTROLLERS
  // ================================================================

  final TextEditingController assetTagController =
      TextEditingController();

  final TextEditingController serialNumberController =
      TextEditingController();

  final TextEditingController initialLocationController =
      TextEditingController();

  // ================================================================
  // DROPDOWN
  // ================================================================

  String? selectedProductItem;

  final List<String> productItemOptions = [
    'Select a Product Item',
  ];

  // ================================================================
  // DISPOSE
  // ================================================================

  @override
  void dispose() {
    assetTagController.dispose();
    serialNumberController.dispose();
    initialLocationController.dispose();

    super.dispose();
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    final bool isMobile = screenSize.width < 600;

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 35,
        vertical: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 562,
          maxHeight: screenSize.height - 40,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 22 : 34,
              isMobile ? 28 : 34,
              isMobile ? 22 : 34,
              isMobile ? 24 : 34,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // TITLE + CLOSE ICON
                  // ==================================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'Add Returnable Asset',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF17395C),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.close,
                            size: 24,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // 1. ITEM (TYPE OF ASSET)
                  // ==================================================

                  _buildLabel(
                    'Item (Type of Asset)',
                  ),

                  const SizedBox(height: 8),

                  _buildProductItemDropdown(),

                  const SizedBox(height: 20),

                  // ==================================================
                  // 2. ASSET TAG (UNIQUE ID)
                  // ==================================================

                  _buildLabel(
                    'Asset Tag (Unique ID)',
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: assetTagController,
                    decoration: _inputDecoration(
                      hintText: '',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // 3. SERIAL NUMBER
                  // ==================================================

                  _buildLabel(
                    'Serial Number (Optional)',
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: serialNumberController,
                    decoration: _inputDecoration(
                      hintText: '',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // 4. INITIAL LOCATION
                  // ==================================================

                  _buildLabel(
                    'Initial Location',
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: initialLocationController,
                    decoration: _inputDecoration(
                      hintText: '',
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // BUTTONS
                  // ==================================================

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // ------------------------------------------------
                      // CLOSE BUTTON
                      // ------------------------------------------------

                      SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close,
                            size: 17,
                          ),
                          label: const Text(
                            'Close',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF707981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // ------------------------------------------------
                      // SAVE ASSET BUTTON
                      // ------------------------------------------------

                      SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: _saveAsset,
                          icon: const Icon(
                            Icons.save,
                            size: 17,
                          ),
                          label: const Text(
                            'Save Asset',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF12385F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PRODUCT ITEM DROPDOWN
  // ================================================================

  Widget _buildProductItemDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedProductItem,
      isExpanded: true,
      dropdownColor: Colors.white,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Colors.black,
      ),
      decoration: _inputDecoration(
        hintText: 'Select a Product Item',
      ),
      items: productItemOptions.map(
        (String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF222222),
              ),
            ),
          );
        },
      ).toList(),
      onChanged: (String? value) {
        setState(() {
          selectedProductItem = value;
        });
      },
    );
  }

  // ================================================================
  // LABEL
  // ================================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF3D4147),
      ),
    );
  }

  // ================================================================
  // INPUT DECORATION
  // ================================================================

  InputDecoration _inputDecoration({
    required String hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 16,
        color: Color(0xFF222222),
      ),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFD8DEE5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFD8DEE5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFF17395C),
          width: 1.3,
        ),
      ),
    );
  }

  // ================================================================
  // SAVE ASSET
  // ================================================================

  void _saveAsset() {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Returnable asset saved successfully.',
        ),
      ),
    );
  }
}