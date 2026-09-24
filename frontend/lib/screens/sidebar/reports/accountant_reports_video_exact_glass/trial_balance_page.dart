import 'package:flutter/material.dart';

import 'widgets/report_glass_widgets.dart';

class TrialBalancePage extends StatelessWidget {
  final VoidCallback onBack;

  const TrialBalancePage({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ReportGlassPageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportTitleActions(
            title: 'Trial Balance',
            actions: [
              ReportGlassButton(
                label: 'Back to Accountant Reports',
                icon: Icons.chevron_left_rounded,
                type: ReportGlassButtonType.back,
                onPressed: onBack,
              ),
              ReportGlassButton(
                label: 'Download PDF',
                icon: Icons.picture_as_pdf_outlined,
                type: ReportGlassButtonType.pdf,
                onPressed: () {},
              ),
              ReportGlassButton(
                label: 'Download Excel (CSV)',
                icon: Icons.table_view_outlined,
                type: ReportGlassButtonType.excel,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          const ReportGlassCard(
            child: _TrialBalanceTable(),
          ),
        ],
      ),
    );
  }
}

class _TrialBalanceTable extends StatelessWidget {
  const _TrialBalanceTable();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double minWidth = 850;
        final double width =
            constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.30),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          'ACCOUNT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF506778),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'DEBIT',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF506778),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'CREDIT',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF506778),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                  child: const Text(
                    'No account balances found.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7A8994),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  color: Colors.white.withValues(alpha: 0.20),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF243B4C),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '0.00',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF243B4C),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '0.00',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF243B4C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
