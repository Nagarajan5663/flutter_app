Inventory Reports - Video Exact Glass UI

Place this folder at:
lib/screens/sidebar/reports/inventory_reports/

Entry page:
InventoryReportsPage()

Example import:
import 'package:your_app/screens/sidebar/reports/inventory_reports/inventory_reports_page.dart';

Open from your Reports -> Inventory section using:
const InventoryReportsPage()

If your parent Reports page already manages back navigation, pass:
InventoryReportsPage(
  onBackToAllReports: () {
    // switch back to your All Reports page here
  },
)

Visible report content included exactly from the supplied video:
1. Inventory Summary
2. Inventory Valuation Summary
3. Inventory Aging Summary
4. ABC Classification

No additional report content/sample data has been added.
