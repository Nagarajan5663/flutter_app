ACCOUNTANT REPORTS - INTEGRATION

Copy this folder to:

lib/screens/sidebar/reports/accountant_reports/

Import:

import 'package:YOUR_APP/screens/sidebar/reports/accountant_reports/accountant_reports_page.dart';

Open the module with:

const AccountantReportsPage()

If your main Reports Center controls back navigation:

AccountantReportsPage(
  onBackToAllReports: () {
    // switch back to your main Reports Center
  },
)

EXACT SOURCE LIMITATION FROM THE VIDEO

The uploaded reference video shows these Accountant report rows:

- Account Transactions
- General Ledger
- Journal Report
- Trial Balance

However, when Account Transactions, General Ledger, and Journal Report
are opened in the video, the reference website returns a server error
instead of showing the report UI.

Because you asked not to add anything beyond the video, this package DOES NOT
invent forms, filters, table columns, or report content for those three pages.
Their rows are preserved exactly. By default, tapping them does not replace the
Accountant Reports screen.

If your project already has those pages, connect them using:

AccountantReportsPage(
  onUnavailableReportTap: (reportName) {
    // route to your existing page
  },
)

Trial Balance is fully implemented because its complete UI is visible in the
video, including:
- Back to Accountant Reports
- Download PDF
- Download Excel (CSV)
- ACCOUNT / DEBIT / CREDIT
- No account balances found.
- Total 0.00 / 0.00
