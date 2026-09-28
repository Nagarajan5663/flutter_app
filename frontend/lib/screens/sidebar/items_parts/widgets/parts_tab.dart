import 'package:flutter/material.dart';

import '../part_model.dart';

class PartsTab extends StatelessWidget {
  final List<PartModel> parts;
  final VoidCallback onAddPart;
  final ValueChanged<int> onEditPart;
  final ValueChanged<int> onDeletePart;

  const PartsTab({
    super.key,
    required this.parts,
    required this.onAddPart,
    required this.onEditPart,
    required this.onDeletePart,
  });

  @override
  Widget build(BuildContext context) {
    const double minimumTableWidth = 760;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.78,
        ),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4E9EF),
        ),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final double tableWidth =
                constraints.maxWidth <
                        minimumTableWidth
                    ? minimumTableWidth
                    : constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    _buildHeader(),

                    if (parts.isEmpty)
                      _buildEmptyState(
                        tableWidth,
                      )
                    else
                      ...List.generate(
                        parts.length,
                        (index) =>
                            _buildPartRow(
                          part:
                              parts[index],
                          index: index,
                          tableWidth:
                              tableWidth,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 17,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F9FB),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE4E9EF),
          ),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: _TableHeading(
              title: 'NAME',
            ),
          ),
          Expanded(
            flex: 2,
            child: _TableHeading(
              title: 'SKU',
            ),
          ),
          Expanded(
            flex: 3,
            child: _TableHeading(
              title: 'PURCHASE PRICE',
            ),
          ),
          Expanded(
            flex: 2,
            child: _TableHeading(
              title: 'ACTIONS',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    double tableWidth,
  ) {
    return SizedBox(
      width: tableWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 58,
        ),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFEEF5FA),
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons
                    .precision_manufacturing_outlined,
                size: 36,
                color: Color(0xFF487EA6),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No parts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w700,
                color: Color(0xFF25394B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first part to start managing inventory components.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF85919D),
              ),
            ),
            const SizedBox(height: 21),
            OutlinedButton.icon(
              onPressed: onAddPart,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'Add First Part',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartRow({
    required PartModel part,
    required int index,
    required double tableWidth,
  }) {
    return Container(
      width: tableWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8EDF2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              part.name,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
                color: Color(0xFF25394B),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              part.sku,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF657687),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '₹${part.purchasePrice}',
              style: const TextStyle(
                color: Color(0xFF425B6C),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () {
                    onEditPart(index);
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color:
                        Color(0xFF3479A8),
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () {
                    onDeletePart(index);
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color:
                        Color(0xFFC35A5A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeading
    extends StatelessWidget {
  final String title;

  const _TableHeading({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 0.7,
        fontWeight: FontWeight.w700,
        color: Color(0xFF657687),
      ),
    );
  }
}