import 'dart:ui';
import 'package:flutter/material.dart';

const Color reportBg1 = Color(0xFFCADAE7);
const Color reportBg2 = Color(0xFFD2D6E3);
const Color reportBg3 = Color(0xFFC7DCD9);
const Color reportNavy = Color(0xFF123456);
const Color reportBlue = Color(0xFF2C79AE);

class ReportGlassPage extends StatelessWidget {
  final Widget child;
  const ReportGlassPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [reportBg1, reportBg2, reportBg3],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -70,
            child: IgnorePointer(
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF3984BA).withValues(alpha: 0.30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -170,
            left: 20,
            child: IgnorePointer(
              child: Container(
                width: 430,
                height: 430,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7563AD).withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class ReportGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final bool enableTilt;

  const ReportGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 22,
    this.enableTilt = true,
  });

  @override
  State<ReportGlassCard> createState() => _ReportGlassCardState();
}

class _ReportGlassCardState extends State<ReportGlassCard> {
  bool hovering = false;
  double rotateX = 0;
  double rotateY = 0;

  void _hover(PointerEvent event) {
    if (!widget.enableTilt) return;
    final render = context.findRenderObject();
    if (render is! RenderBox) return;
    final size = render.size;
    if (size.width == 0 || size.height == 0) return;
    final x = (event.localPosition.dx / size.width) - 0.5;
    final y = (event.localPosition.dy / size.height) - 0.5;
    const strength = 0.018;
    setState(() {
      rotateY = x * strength;
      rotateX = -y * strength;
    });
  }

  void _reset() {
    if (!mounted) return;
    setState(() {
      hovering = false;
      rotateX = 0;
      rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 850;
    return MouseRegion(
      onEnter: (_) {
        if (desktop && widget.enableTilt) setState(() => hovering = true);
      },
      onHover: desktop ? _hover : null,
      onExit: (_) => _reset(),
      child: AnimatedContainer(
        duration: Duration(milliseconds: hovering ? 90 : 280),
        curve: hovering ? Curves.linear : Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(rotateX)
          ..rotateY(rotateY),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF173D59).withValues(
                alpha: hovering ? 0.16 : 0.08,
              ),
              blurRadius: hovering ? 42 : 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: widget.padding,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: hovering ? 0.66 : 0.56,
                ),
                borderRadius: BorderRadius.circular(widget.radius),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: hovering ? 0.95 : 0.78,
                  ),
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class ReportTitleBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final bool showDownloads;
  final VoidCallback? onDownloadPdf;
  final VoidCallback? onDownloadCsv;

  const ReportTitleBar({
    super.key,
    required this.title,
    required this.onBack,
    this.showDownloads = false,
    this.onDownloadPdf,
    this.onDownloadCsv,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final actions = Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.end,
          children: [
            _ReportActionButton(
              label: 'Back',
              icon: Icons.chevron_left_rounded,
              background: const Color(0xFF7B8A8D),
              onPressed: onBack,
            ),
            if (showDownloads)
              _ReportActionButton(
                label: 'Download PDF',
                icon: Icons.picture_as_pdf_outlined,
                background: const Color(0xFFE94F43),
                onPressed: onDownloadPdf ?? () {},
              ),
            if (showDownloads)
              _ReportActionButton(
                label: 'Download Excel (CSV)',
                icon: Icons.table_view_outlined,
                background: const Color(0xFF1DAA61),
                onPressed: onDownloadCsv ?? () {},
              ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: reportNavy,
                ),
              ),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: reportNavy,
                ),
              ),
            ),
            actions,
          ],
        );
      },
    );
  }
}

class _ReportActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color background;
  final VoidCallback onPressed;

  const _ReportActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.onPressed,
  });

  @override
  State<_ReportActionButton> createState() => _ReportActionButtonState();
}

class _ReportActionButtonState extends State<_ReportActionButton> {
  bool hovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedScale(
        scale: hovering ? 1.025 : 1,
        duration: const Duration(milliseconds: 160),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: Icon(widget.icon, size: 17),
          label: Text(widget.label),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.background,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

class ReportNotice extends StatelessWidget {
  final String text;
  final bool warning;
  const ReportNotice({super.key, required this.text, this.warning = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: warning
            ? const Color(0xFFFFE9E7).withValues(alpha: 0.82)
            : const Color(0xFFFFF5CF).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: warning
              ? const Color(0xFFF2B8B2)
              : const Color(0xFFEFD77A),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: warning ? const Color(0xFFB42318) : const Color(0xFFC57500),
        ),
      ),
    );
  }
}

class ReportSectionTable extends StatelessWidget {
  final List<ReportRowData> rows;
  const ReportSectionTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return ReportGlassCard(
      enableTilt: false,
      child: Column(
        children: rows.map((row) => _ReportRow(data: row)).toList(),
      ),
    );
  }
}

class ReportRowData {
  final String label;
  final String value;
  final ReportRowStyle style;
  final bool indent;

  const ReportRowData(
    this.label,
    this.value, {
    this.style = ReportRowStyle.normal,
    this.indent = false,
  });
}

enum ReportRowStyle { normal, section, subtotal, total }

class _ReportRow extends StatefulWidget {
  final ReportRowData data;
  const _ReportRow({required this.data});

  @override
  State<_ReportRow> createState() => _ReportRowState();
}

class _ReportRowState extends State<_ReportRow> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final bold = data.style != ReportRowStyle.normal;
    final isTotal = data.style == ReportRowStyle.total;
    final isSection = data.style == ReportRowStyle.section;

    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.fromLTRB(data.indent ? 30 : 16, 13, 16, 13),
        decoration: BoxDecoration(
          color: hovering
              ? Colors.white.withValues(alpha: 0.42)
              : isSection
                  ? Colors.white.withValues(alpha: 0.30)
                  : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isTotal
                  ? reportNavy
                  : Colors.white.withValues(alpha: 0.70),
              width: isTotal ? 1.5 : 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                data.label,
                style: TextStyle(
                  fontSize: isSection ? 14 : 13,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  color: isTotal ? reportNavy : const Color(0xFF374957),
                ),
              ),
            ),
            Text(
              data.value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? reportNavy : const Color(0xFF374957),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
