import 'package:flutter/material.dart';

InputDecoration salesFieldDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black),
    filled: true,
    fillColor: const Color(0xFFF8F9FA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFF2E7DD1)),
    ),
  );
}

Widget salesLabeledField({required String label, required Widget child}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5B5B5B),
        ),
      ),
      const SizedBox(height: 6),
      child,
    ],
  );
}

TextField salesTextField({
  required TextEditingController controller,
  TextInputType? keyboardType,
  int maxLines = 1,
  String? hint,
}) {
  return TextField(
    controller: controller,
    style: const TextStyle(color: Colors.black),
    keyboardType: keyboardType,
    maxLines: maxLines,
    decoration: salesFieldDecoration(hint: hint),
  );
}

TextField salesFilterTextField(
  TextEditingController controller,
  String hint,
) {
  return TextField(
    controller: controller,
    style: const TextStyle(color: Colors.black),
    decoration: salesFieldDecoration(hint: hint),
  );
}

Widget salesFilterDateField({
  required BuildContext context,
  required DateTime? value,
  required ValueChanged<DateTime> onPicked,
}) {
  return salesDateField(
    value: value,
    onTap: () => pickSalesDate(
      context: context,
      initial: value ?? DateTime.now(),
      onPicked: onPicked,
    ),
  );
}

Widget salesDateField({
  required DateTime? value,
  required VoidCallback onTap,
}) {
  final text = value == null
      ? 'Select date'
      : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(7),
    child: InputDecorator(
      decoration: salesFieldDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.black)),
          const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF6C757D)),
        ],
      ),
    ),
  );
}

Future<void> pickSalesDate({
  required BuildContext context,
  required DateTime initial,
  required ValueChanged<DateTime> onPicked,
}) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (picked != null) onPicked(picked);
}

class SalesHeaderText extends StatelessWidget {
  const SalesHeaderText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6C757D),
      ),
    );
  }
}

Widget salesStatusPill({required String text, required Color bg, required Color fg}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
    ),
  );
}
