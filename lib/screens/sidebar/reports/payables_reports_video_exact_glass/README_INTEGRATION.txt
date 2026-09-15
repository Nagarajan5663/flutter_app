PAYABLES REPORTS - INTEGRATION

Copy this folder to:

lib/screens/sidebar/reports/payables_reports/

Import:

import 'package:YOUR_APP/screens/sidebar/reports/payables_reports/payables_reports_page.dart';

Open the Payables Reports module with:

const PayablesReportsPage()

If your Reports Center already controls its own back navigation, pass:

PayablesReportsPage(
  onBackToAllReports: () {
    // switch back to the main Reports Center
  },
)

The UI includes only the content shown in the uploaded reference video:
- AP Aging Summary
- Vendor Balance Summary
- Bill Details
- Payments Made

Important:
The video shows "Payments Made" opening a visible page titled
"Purchases by Vendor" with a "Back to Purchases Reports" button.
That exact visible behavior has been preserved intentionally.
