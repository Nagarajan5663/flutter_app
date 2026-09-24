import 'package:flutter/material.dart';

import 'widgets/reports_section.dart';

class ReportCategoryDetailPage extends StatelessWidget {
  final ReportSectionData section;
  final VoidCallback onBack;
  final ValueChanged<ReportItem>? onReportSelected;

  const ReportCategoryDetailPage({
    super.key,
    required this.section,
    required this.onBack,
    this.onReportSelected,
  });

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
            // PAGE HEADER
            // =========================================================

            LayoutBuilder(
              builder: (context, constraints) {
                // WEB / DESKTOP
                if (constraints.maxWidth >= 600) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          section.title,
                          style: const TextStyle(
                            color: Color(0xFF123653),
                            fontSize: 29,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // =================================================
                      // BACK TO ALL REPORTS
                      // =================================================

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
                              const Color(0xFF89969A),
                          foregroundColor: Colors.white,
                          elevation: 0,

                          padding: const EdgeInsets.symmetric(
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

                // MOBILE
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        color: Color(0xFF123653),
                        fontSize: 26,
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

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF89969A),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // =========================================================
            // REPORT CATEGORY CONTENT
            // =========================================================

            ReportsSection(
              section: section,

              onReportSelected: (report) {
                if (onReportSelected != null) {
                  onReportSelected!(report);
                }
              },
            ),

            const SizedBox(height: 40),

            // =========================================================
            // FOOTER
            // =========================================================

            const Center(
              child: Text(
                '© 2026 test. All Rights Reserved.',
                style: TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}