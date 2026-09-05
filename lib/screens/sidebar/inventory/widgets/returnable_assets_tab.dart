import 'package:flutter/material.dart';

class ReturnableAssetsTab extends StatefulWidget {
  final bool isMobile;

  const ReturnableAssetsTab({
    super.key,
    required this.isMobile,
  });

  @override
  State<ReturnableAssetsTab> createState() =>
      _ReturnableAssetsTabState();
}

class _ReturnableAssetsTabState
    extends State<ReturnableAssetsTab> {
  int selectedSubTab = 0;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = widget.isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // SECONDARY TABS
        // ======================================================

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSubTab(
                title: 'Available Assets',
                index: 0,
              ),
              _buildSubTab(
                title: 'In Field',
                index: 1,
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

        // ======================================================
        // SECTION TITLE
        // ======================================================

        Text(
          selectedSubTab == 0
              ? 'Available Returnable Assets'
              : 'Returnable Assets In Field',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // TABLE
        // ======================================================

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFD9DEE5),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: isMobile ? 700 : 900,
              child: Column(
                children: [
                  // ------------------------------------------------
                  // TABLE HEADER
                  // ------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 18,
                      vertical: 15,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F7F9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _headerText('ASSET TAG'),
                        ),
                        Expanded(
                          flex: 3,
                          child: _headerText('ITEM NAME'),
                        ),
                        Expanded(
                          flex: 2,
                          child: _headerText('SKU'),
                        ),
                        Expanded(
                          flex: 3,
                          child: _headerText('SERIAL NUMBER'),
                        ),
                        Expanded(
                          flex: 2,
                          child: _headerText('ACTIONS'),
                        ),
                      ],
                    ),
                  ),

                  // ------------------------------------------------
                  // DIVIDER
                  // ------------------------------------------------

                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFD9DEE5),
                  ),

                  // ------------------------------------------------
                  // EMPTY STATE
                  // ------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 22,
                    ),
                    child: Text(
                      selectedSubTab == 0
                          ? 'No returnable assets are currently available.'
                          : 'No returnable assets are currently in the field.',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF42474D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SECONDARY TAB
  // ==========================================================

  Widget _buildSubTab({
    required String title,
    required int index,
  }) {
    final bool isSelected = selectedSubTab == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          selectedSubTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? const Color(0xFF17395C)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: widget.isMobile ? 14 : 15,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? const Color(0xFF17395C)
                : const Color(0xFF888888),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // TABLE HEADER TEXT
  // ==========================================================

  Widget _headerText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: widget.isMobile ? 11 : 13,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF606060),
      ),
    );
  }
}