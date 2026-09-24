import 'package:flutter/material.dart';

import '../sales_line_item_model.dart';
import 'sales_dialog_helpers.dart';

class SalesItemRowControllers {
  final itemNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final rateController = TextEditingController(text: '0');

  double get quantity => double.tryParse(quantityController.text) ?? 0;
  double get rate => double.tryParse(rateController.text) ?? 0;
  double get amount => quantity * rate;

  void fillFrom(SalesLineItemModel item) {
    itemNameController.text = item.itemName;
    descriptionController.text = item.description;
    quantityController.text = item.quantity.toString();
    rateController.text = item.rate.toString();
  }

  SalesLineItemModel? toModelOrNull() {
    if (itemNameController.text.trim().isEmpty || quantity <= 0 || rate < 0) return null;
    return SalesLineItemModel(
      itemName: itemNameController.text.trim(),
      description: descriptionController.text.trim(),
      quantity: quantity,
      rate: rate,
      amount: amount,
    );
  }

  void dispose() {
    itemNameController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    rateController.dispose();
  }
}

class SalesItemRowsEditor extends StatelessWidget {
  const SalesItemRowsEditor({
    required this.rows,
    required this.onAddRow,
    required this.onRemoveRow,
    required this.onRowChanged,
    super.key,
  });

  final List<SalesItemRowControllers> rows;
  final VoidCallback onAddRow;
  final ValueChanged<int> onRemoveRow;
  final VoidCallback onRowChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: row.itemNameController,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (_) => onRowChanged(),
                    decoration: salesFieldDecoration(hint: 'Item name'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: row.quantityController,
                    style: const TextStyle(color: Colors.black),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => onRowChanged(),
                    decoration: salesFieldDecoration(hint: 'Qty'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: row.rateController,
                    style: const TextStyle(color: Colors.black),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => onRowChanged(),
                    decoration: salesFieldDecoration(hint: 'Rate'),
                  ),
                ),
                IconButton(
                  onPressed: rows.length == 1 ? null : () => onRemoveRow(index),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove item',
                ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: onAddRow,
          icon: const Icon(Icons.add),
          label: const Text('Add item'),
        ),
      ],
    );
  }
}
