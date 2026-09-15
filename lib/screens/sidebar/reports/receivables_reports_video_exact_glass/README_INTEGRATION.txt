Receivables Reports - Integration

1. Copy the folder:
   receivables_reports/

   into your project, for example:
   lib/screens/sidebar/reports/receivables_reports/

2. Import:
   import 'receivables_reports/receivables_reports_page.dart';

3. Open the Receivables reports section with:
   const ReceivablesReportsPage()

4. Optional: if your Reports Center already manages Back to All Reports,
   pass the callback:

   ReceivablesReportsPage(
     onBackToAllReports: () {
       // switch back to your main reports center here
     },
   )

Included exactly from the supplied video:
- AR Aging Summary
- AR Aging Details
- Invoice Details
- Customer Balance Summary

The pages use the same glassmorphism/hover/tilt visual system as the previously generated report modules.
