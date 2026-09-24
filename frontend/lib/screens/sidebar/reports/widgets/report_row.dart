import 'package:flutter/material.dart';

class ReportRow extends StatefulWidget {
  final String reportName;
  final String lastVisited;
  final String createdBy;
  final VoidCallback? onTap;

  const ReportRow({
    super.key,
    required this.reportName,
    this.lastVisited = '-',
    this.createdBy = 'System Generated',
    this.onTap,
  });

  @override
  State<ReportRow> createState() =>
      _ReportRowState();
}

class _ReportRowState extends State<ReportRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },

      child: InkWell(
        onTap: widget.onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),

          constraints: const BoxConstraints(
            minHeight: 56,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 13,
          ),

          color: _isHovered
              ? const Color(0xFFF3F9FD)
              : Colors.white,

          child: Row(
            children: [
              // REPORT NAME
              Expanded(
                flex: 5,
                child: Text(
                  widget.reportName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _isHovered
                        ? const Color(0xFF168ACC)
                        : const Color(0xFF279FE3),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // LAST VISITED
              Expanded(
                flex: 3,
                child: Text(
                  widget.lastVisited,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 13,
                  ),
                ),
              ),

              // CREATED BY
              Expanded(
                flex: 3,
                child: Text(
                  widget.createdBy,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}