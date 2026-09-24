import 'package:flutter/material.dart';

import 'report_row.dart';

class ReportItem {
  final String name;
  final String lastVisited;
  final String createdBy;

  const ReportItem({
    required this.name,
    this.lastVisited = '-',
    this.createdBy = 'System Generated',
  });
}

class ReportSectionData {
  final String title;
  final List<ReportItem> reports;

  const ReportSectionData({
    required this.title,
    required this.reports,
  });
}

class ReportsSection extends StatelessWidget {
  final ReportSectionData section;
  final ValueChanged<ReportItem>? onReportSelected;

  const ReportsSection({
    super.key,
    required this.section,
    this.onReportSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: const Color(0xFFE5E8EB),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      clipBehavior: Clip.antiAlias,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================================================
          // SECTION TITLE
          // =========================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: Text(
              section.title,
              style: const TextStyle(
                color: Color(0xFF123653),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const Divider(
            height: 1,
            color: Color(0xFFE5E5E5),
          ),

          // =========================================================
          // TABLE HEADER
          // =========================================================

          Container(
            height: 49,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'REPORT NAME',
                    style: TextStyle(
                      color: Color(0xFF8C8C8C),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Text(
                    'LAST VISITED',
                    style: TextStyle(
                      color: Color(0xFF8C8C8C),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Text(
                    'CREATED BY',
                    style: TextStyle(
                      color: Color(0xFF8C8C8C),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color: Color(0xFFE5E5E5),
          ),

          // =========================================================
          // REPORT ROWS
          // =========================================================

          for (int i = 0;
              i < section.reports.length;
              i++) ...[
            ReportRow(
              reportName: section.reports[i].name,
              lastVisited:
                  section.reports[i].lastVisited,
              createdBy:
                  section.reports[i].createdBy,

              onTap: () {
                if (onReportSelected != null) {
                  onReportSelected!(
                    section.reports[i],
                  );
                }
              },
            ),

            if (i != section.reports.length - 1)
              const Divider(
                height: 1,
                color: Color(0xFFEAEAEA),
              ),
          ],
        ],
      ),
    );
  }
}