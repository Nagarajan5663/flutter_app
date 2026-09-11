import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _taxBoxKey = GlobalKey();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController skuController = TextEditingController();
  final TextEditingController purchasePriceController =
      TextEditingController();
  final TextEditingController salesPriceController =
      TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();

  // ============================================================
  // TAX OPTIONS
  // ============================================================

  final List<String> taxOptions = [
    'GST0 (Tax Group)',
    'GST12 (Tax Group)',
    'GST18 (Tax Group)',
    'GST5 (Tax Group)',
    'IGST0',
    'IGST12',
    'IGST18',
    'IGST5',
  ];

  String? selectedTax;

  @override
  void dispose() {
    nameController.dispose();
    skuController.dispose();
    purchasePriceController.dispose();
    salesPriceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // OPEN TAX LIST
  // ============================================================

  Future<void> _openTaxDropdown() async {
    final RenderBox? renderBox =
        _taxBoxKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return;
    }

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final Size screenSize = MediaQuery.of(context).size;

    const double itemHeight = 48;
    const double menuPadding = 8;

    final double menuHeight =
        (taxOptions.length * itemHeight) + menuPadding;

    // Open ABOVE the tax box.
    double menuTop = position.dy - menuHeight - 4;

    // Keep a small gap from the top of the screen.
    if (menuTop < 8) {
      menuTop = 8;
    }

    final double menuLeft = position.dx;

    final double menuRight =
        screenSize.width - (position.dx + size.width);

    final String? result = await showMenu<String>(
      context: context,

      color: Colors.white,

      elevation: 8,

      shadowColor: Colors.black26,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(
          color: Color(0xFFBFC5CC),
        ),
      ),

      position: RelativeRect.fromLTRB(
        menuLeft,
        menuTop,
        menuRight,
        screenSize.height - position.dy,
      ),

      constraints: BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: 320,
      ),

      items: [
        // ======================================================
        // SELECT TAX
        // ======================================================

        const PopupMenuItem<String>(
          value: '__none__',
          height: 44,
          child: Text(
            'Select Tax',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),

        // ======================================================
        // TAX OPTIONS
        // ======================================================

        ...taxOptions.map(
          (String tax) {
            return PopupMenuItem<String>(
              value: tax,
              height: itemHeight,
              child: Text(
                tax,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      ],
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      if (result == '__none__') {
        selectedTax = null;
      } else {
        selectedTax = result;
      }
    });
  }

  // ============================================================
  // ADD NEW TAX
  // ============================================================

  Future<void> _addNewTax() async {
    final String? newTax = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AddTaxRateDialog();
      },
    );

    if (!mounted || newTax == null || newTax.trim().isEmpty) {
      return;
    }

    setState(() {
      if (!taxOptions.contains(newTax)) {
        taxOptions.add(newTax);
      }

      selectedTax = newTax;
    });
  }

  // ============================================================
  // SAVE ITEM
  // ============================================================

  void _saveItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added successfully'),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,

      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 650,
          maxHeight: 820,
        ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            34,
            30,
            34,
            28,
          ),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add New Item',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123456),
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFFAAAAAA),
                        size: 25,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ==================================================
                // ITEM NAME
                // ==================================================

                _buildLabel('Item Name'),

                _buildTextField(
                  controller: nameController,

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter item name';
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

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
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

                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter purchase price';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // SALES PRICE
                // ==================================================

                _buildLabel('Sales Price'),

                _buildTextField(
                  controller: salesPriceController,

                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter sales price';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // TAX LABEL
                // ==================================================

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tax',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3D4147),
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: _addNewTax,

                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),

                      child: const Text(
                        '+ Add New',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ==================================================
                // CUSTOM TAX SELECT BOX
                // ==================================================

                GestureDetector(
                  key: _taxBoxKey,

                  onTap: _openTaxDropdown,

                  child: Container(
                    width: double.infinity,
                    height: 50,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),

                      borderRadius:
                          BorderRadius.circular(7),

                      border: Border.all(
                        color: const Color(0xFFD9DEE5),
                      ),
                    ),

                    child: Row(
                      children: [
                        // ------------------------------------------
                        // SELECTED TAX
                        // ------------------------------------------

                        Expanded(
                          child: Text(
                            selectedTax ?? 'Select Tax',

                            style: TextStyle(
                              fontSize: 16,

                              color: selectedTax == null
                                  ? const Color(0xFF333333)
                                  : Colors.black,
                            ),

                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),

                        // ------------------------------------------
                        // ARROW
                        // ------------------------------------------

                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
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
                    filled: true,

                    fillColor:
                        const Color(0xFFF8F9FA),

                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(7),
                    ),

                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(7),

                      borderSide:
                          const BorderSide(
                        color: Color(0xFFD9DEE5),
                      ),
                    ),

                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(7),

                      borderSide:
                          const BorderSide(
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
                  mainAxisAlignment:
                      MainAxisAlignment.end,

                  children: [
                    // CLOSE
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(
                        Icons.close,
                        size: 18,
                      ),

                      label: const Text('Close'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF6C757D),

                        foregroundColor: Colors.white,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(7),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // SAVE ITEM
                    ElevatedButton.icon(
                      onPressed: _saveItem,

                      icon: const Icon(
                        Icons.save,
                        size: 18,
                      ),

                      label:
                          const Text('Save Item'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF123456),

                        foregroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(7),
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
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),

      child: Text(
        text,

        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF3D4147),
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: keyboardType,

      validator: validator,

      decoration: InputDecoration(
        filled: true,

        fillColor: const Color(0xFFF8F9FA),

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(7),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(7),

          borderSide:
              const BorderSide(
            color: Color(0xFFD9DEE5),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(7),

          borderSide:
              const BorderSide(
            color: Color(0xFF123456),
            width: 2,
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// ADD NEW TAX RATE DIALOG
// ==================================================================

class AddTaxRateDialog extends StatefulWidget {
  const AddTaxRateDialog({super.key});

  @override
  State<AddTaxRateDialog> createState() =>
      _AddTaxRateDialogState();
}

class _AddTaxRateDialogState
    extends State<AddTaxRateDialog> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController taxNameController =
      TextEditingController();

  final TextEditingController rateController =
      TextEditingController();

  final TextEditingController cgstController =
      TextEditingController();

  final TextEditingController sgstController =
      TextEditingController();

  @override
  void dispose() {
    taxNameController.dispose();
    rateController.dispose();
    cgstController.dispose();
    sgstController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE TAX
  // ============================================================

  void _saveTax() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String taxName =
        taxNameController.text.trim();

    Navigator.pop(
      context,
      taxName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,

      insetPadding:
          const EdgeInsets.all(24),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),

      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 560,
          maxHeight: 700,
        ),

        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            34,
            30,
            34,
            28,
          ),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ==================================================
                // TITLE
                // ==================================================

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add New Tax Rate',

                        style: TextStyle(
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF123456),
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon:
                          const Icon(
                        Icons.close,
                        color:
                            Color(0xFFAAAAAA),
                        size: 25,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ==================================================
                // TAX NAME
                // ==================================================

                _buildLabel('Tax Name'),

                _buildTextField(
                  controller:
                      taxNameController,

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter tax name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // RATE
                // ==================================================

                _buildLabel('Rate (%)'),

                _buildTextField(
                  controller:
                      rateController,

                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter rate';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // CGST
                // ==================================================

                _buildLabel(
                    'CGST Rate (%)'),

                _buildTextField(
                  controller:
                      cgstController,

                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // SGST
                // ==================================================

                _buildLabel(
                    'SGST Rate (%)'),

                _buildTextField(
                  controller:
                      sgstController,

                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // BUTTONS
                // ==================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end,

                  children: [
                    // CLOSE
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(
                        Icons.close,
                        size: 18,
                      ),

                      label:
                          const Text('Close'),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                                0xFF6C757D),

                        foregroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // SAVE TAX
                    ElevatedButton.icon(
                      onPressed: _saveTax,

                      icon: const Icon(
                        Icons.save,
                        size: 18,
                      ),

                      label:
                          const Text('Save Tax'),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                                0xFF123456),

                        foregroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 20,
                          vertical: 14,
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
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),

      child: Text(
        text,

        style: const TextStyle(
          fontSize: 16,
          fontWeight:
              FontWeight.w500,
          color:
              Color(0xFF3D4147),
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController
        controller,
    TextInputType? keyboardType,
    String? Function(String?)?
        validator,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType:
          keyboardType,

      validator:
          validator,

      decoration:
          InputDecoration(
        filled: true,

        fillColor:
            const Color(0xFFF8F9FA),

        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  7),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  7),

          borderSide:
              const BorderSide(
            color:
                Color(0xFFD9DEE5),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  7),

          borderSide:
              const BorderSide(
            color:
                Color(0xFF123456),
            width: 2,
          ),
        ),
      ),
    );
  }
}