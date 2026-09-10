import 'package:flutter/material.dart';

import 'widgets/reports_section.dart';

class BusinessOverviewPage extends StatelessWidget {
  final VoidCallback onBack;

  const BusinessOverviewPage({
    super.key,
    required this.onBack,
  });

  static const ReportSectionData businessOverview =
      ReportSectionData(
    title: 'Business Overview',
    reports: [
      ReportItem(
        name: 'Profit and Loss',
        lastVisited: '04/05/2025 07:49 PM',
      ),

      ReportItem(
        name: 'Profit and Loss (Schedule III)',
      ),

      ReportItem(
        name: 'Horizontal Profit and Loss',
      ),

      ReportItem(
        name: 'Cash Flow Statement',
        lastVisited: '24/03/2023 11:37 PM',
      ),

      ReportItem(
        name: 'Balance Sheet',
        lastVisited: '14/07/2025 02:31 PM',
      ),

      ReportItem(
        name: 'Horizontal Balance Sheet',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,

      color: const Color(0xFFF3F7FA),

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          30,
          30,
          30,
          40,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================================================
            // TITLE + BACK BUTTON
            // =========================================================

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 600) {
                  return Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Business Overview',
                          style: TextStyle(
                            color: Color(0xFF123653),
                            fontSize: 29,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: onBack,

                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 15,
                        ),

                        label: const Text(
                          'Back to All Reports',
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF8B9799),

                          foregroundColor: Colors.white,

                          elevation: 0,

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),

                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Overview',
                      style: TextStyle(
                        color: Color(0xFF123653),
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: onBack,

                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                      ),

                      label: const Text(
                        'Back to All Reports',
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // =========================================================
            // BUSINESS REPORTS
            // =========================================================

            ReportsSection(
              section: businessOverview,

              onReportSelected: (report) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      '${report.name} selected',
                    ),
                    duration:
                        const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}