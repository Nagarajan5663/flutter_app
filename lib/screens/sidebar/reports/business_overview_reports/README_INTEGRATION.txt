BUSINESS OVERVIEW REPORTS

Put this folder inside your Reports feature, for example:
lib/screens/sidebar/reports/business_overview/

Main widget to open when the user clicks "Business Overview":

const BusinessOverviewPage()

Import:
import 'business_overview/business_overview_page.dart';

If your Reports Center controls the Back to All Reports action, use:
BusinessOverviewPage(
  onBackToAllReports: () {
    // set your Reports Center selected page here
  },
)

The module contains exactly the 6 report headings from the uploaded video:
1. Profit and Loss
2. Profit and Loss (Schedule III)
3. Horizontal Profit and Loss
4. Cash Flow Statement
5. Balance Sheet
6. Horizontal Balance Sheet

No extra report heading was added.
