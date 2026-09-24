import 'dart:ui';

import 'package:flutter/material.dart';

class ItemPreferencesPage extends StatefulWidget {
  const ItemPreferencesPage({super.key});

  @override
  State<ItemPreferencesPage> createState() => _ItemPreferencesPageState();
}

class _ItemPreferencesPageState extends State<ItemPreferencesPage> {
  bool enableInventoryTracking = false;
  bool warnNegativeStock = false;
  bool showSku = false;
  bool showUpc = false;

  String purchaseAccount = 'Cost of Goods Sold';
  String salesAccount = 'Sales';

  bool showSuccessMessage = false;

  void _saveChanges() {
    setState(() {
      showSuccessMessage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _GlassBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isMobile = constraints.maxWidth < 700;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 14 : 28),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 550),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 24 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: _TiltGlassContainer(
                  enableTilt: !isMobile,
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 18 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =====================================================
                        // HEADER
                        // =====================================================

                        if (isMobile)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitle(),
                              const SizedBox(height: 16),
                              _BackButton(
                                onTap: () {
                                  Navigator.of(context).maybePop();
                                },
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: _buildTitle(),
                              ),
                              _BackButton(
                                onTap: () {
                                  Navigator.of(context).maybePop();
                                },
                              ),
                            ],
                          ),

                        if (showSuccessMessage) ...[
                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD8F2DE)
                                  .withValues(alpha: 0.78),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF9DD0A8),
                              ),
                            ),
                            child: const Text(
                              'Item preferences have been updated successfully!',
                              style: TextStyle(
                                color: Color(0xFF27723B),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // =====================================================
                        // GENERAL
                        // =====================================================

                        _HoverGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionHeader(
                                title: 'General',
                              ),

                              Padding(
                                padding: EdgeInsets.all(
                                  isMobile ? 18 : 24,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _PreferenceCheckbox(
                                      value: enableInventoryTracking,
                                      title:
                                          'Enable inventory tracking for items.',
                                      subtitle:
                                          'Track the stock level of your goods, view inventory valuation summary, and get low stock alerts.',
                                      onChanged: (value) {
                                        setState(() {
                                          enableInventoryTracking = value;
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    _PreferenceCheckbox(
                                      value: warnNegativeStock,
                                      title:
                                          'Warn if stock on hand becomes negative during transactions.',
                                      onChanged: (value) {
                                        setState(() {
                                          warnNegativeStock = value;
                                        });
                                      },
                                    ),

                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      child: Divider(
                                        color: Color(0x55768790),
                                        height: 1,
                                      ),
                                    ),

                                    const Text(
                                      'Select the fields you want to show in the Items creation page.',
                                      style: TextStyle(
                                        color: Color(0xFF243B4C),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    _PreferenceCheckbox(
                                      value: showSku,
                                      title: 'SKU (Stock Keeping Unit)',
                                      onChanged: (value) {
                                        setState(() {
                                          showSku = value;
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 8),

                                    _PreferenceCheckbox(
                                      value: showUpc,
                                      title: 'UPC (Universal Product Code)',
                                      onChanged: (value) {
                                        setState(() {
                                          showUpc = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // =====================================================
                        // ACCOUNT DEFAULTS
                        // =====================================================

                        _HoverGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionHeader(
                                title: 'Account Defaults',
                              ),

                              Padding(
                                padding: EdgeInsets.all(
                                  isMobile ? 18 : 24,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, innerConstraints) {
                                    final double width =
                                        innerConstraints.maxWidth > 430
                                            ? 430
                                            : innerConstraints.maxWidth;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: width,
                                          child: _GlassDropdown(
                                            label:
                                                'Default Purchase Account',
                                            value: purchaseAccount,
                                            items: const [
                                              'Cost of Goods Sold',
                                            ],
                                            onChanged: (value) {
                                              if (value == null) return;

                                              setState(() {
                                                purchaseAccount = value;
                                              });
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 22),

                                        SizedBox(
                                          width: width,
                                          child: _GlassDropdown(
                                            label: 'Default Sales Account',
                                            value: salesAccount,
                                            items: const [
                                              'Sales',
                                            ],
                                            onChanged: (value) {
                                              if (value == null) return;

                                              setState(() {
                                                salesAccount = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 14),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.16),
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.white
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: _SaveButton(
                                    onTap: _saveChanges,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          '© 2026 test. All Rights Reserved.',
                          style: TextStyle(
                            color: Color(0xFF647986),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.inventory_2_outlined,
          color: Color(0xFF123456),
          size: 29,
        ),
        SizedBox(width: 10),
        Flexible(
          child: Text(
            'Item Preferences',
            style: TextStyle(
              color: Color(0xFF123456),
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// BACKGROUND
// ============================================================================

class _GlassBackground extends StatelessWidget {
  final Widget child;

  const _GlassBackground({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCADAE7),
            Color(0xFFD2D6E3),
            Color(0xFFC7DCD9),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -130,
            right: -100,
            child: _GlowCircle(
              size: 380,
              color: const Color(0xFF3984BA),
              opacity: 0.30,
            ),
          ),

          Positioned(
            left: -120,
            top: 320,
            child: _GlowCircle(
              size: 340,
              color: const Color(0xFF46B6A0),
              opacity: 0.17,
            ),
          ),

          Positioned(
            left: 100,
            bottom: -220,
            child: _GlowCircle(
              size: 500,
              color: const Color(0xFF7564AE),
              opacity: 0.20,
            ),
          ),

          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.25),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MAIN TILT GLASS
// ============================================================================

class _TiltGlassContainer extends StatefulWidget {
  final Widget child;
  final bool enableTilt;

  const _TiltGlassContainer({
    required this.child,
    required this.enableTilt,
  });

  @override
  State<_TiltGlassContainer> createState() =>
      _TiltGlassContainerState();
}

class _TiltGlassContainerState extends State<_TiltGlassContainer> {
  double rotateX = 0;
  double rotateY = 0;

  bool hovering = false;

  void _onHover(PointerEvent event) {
    if (!widget.enableTilt) return;

    final renderObject = context.findRenderObject();

    if (renderObject is! RenderBox) return;

    final size = renderObject.size;

    if (size.width == 0 || size.height == 0) return;

    final dx = event.localPosition.dx / size.width;
    final dy = event.localPosition.dy / size.height;

    final x = dx - 0.5;
    final y = dy - 0.5;

    setState(() {
      rotateY = x * 0.025;
      rotateX = -y * 0.025;
    });
  }

  void _resetTilt() {
    setState(() {
      hovering = false;
      rotateX = 0;
      rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!widget.enableTilt) return;

        setState(() {
          hovering = true;
        });
      },
      onHover: _onHover,
      onExit: (_) {
        _resetTilt();
      },
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: hovering ? 90 : 320,
        ),
        curve: hovering ? Curves.linear : Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(rotateX)
          ..rotateY(rotateY),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF173D59).withValues(
                alpha: hovering ? 0.17 : 0.10,
              ),
              blurRadius: hovering ? 48 : 34,
              spreadRadius: hovering ? 2 : 0,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 24,
              sigmaY: 24,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: hovering ? 0.64 : 0.55,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: hovering ? 0.95 : 0.76,
                  ),
                  width: 1.3,
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

// ============================================================================
// GLASS CARD
// ============================================================================

class _HoverGlassCard extends StatefulWidget {
  final Widget child;

  const _HoverGlassCard({
    required this.child,
  });

  @override
  State<_HoverGlassCard> createState() => _HoverGlassCardState();
}

class _HoverGlassCardState extends State<_HoverGlassCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: hovering ? 1.003 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: hovering ? 0.48 : 0.33,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: hovering ? 0.95 : 0.72,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF163E5A).withValues(
                  alpha: hovering ? 0.12 : 0.05,
                ),
                blurRadius: hovering ? 30 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF123456),
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================================
// CHECKBOX
// ============================================================================

class _PreferenceCheckbox extends StatefulWidget {
  final bool value;
  final String title;
  final String? subtitle;
  final ValueChanged<bool> onChanged;

  const _PreferenceCheckbox({
    required this.value,
    required this.title,
    required this.onChanged,
    this.subtitle,
  });

  @override
  State<_PreferenceCheckbox> createState() =>
      _PreferenceCheckboxState();
}

class _PreferenceCheckboxState extends State<_PreferenceCheckbox> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onChanged(!widget.value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: hovering
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, -4),
                child: Checkbox(
                  value: widget.value,
                  onChanged: (value) {
                    widget.onChanged(value ?? false);
                  },
                  activeColor: const Color(0xFF438CC0),
                  side: const BorderSide(
                    color: Color(0xFF788C99),
                  ),
                ),
              ),

              const SizedBox(width: 2),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Color(0xFF243B4C),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 7),

                        Text(
                          widget.subtitle!,
                          style: const TextStyle(
                            color: Color(0xFF70818B),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
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

// ============================================================================
// DROPDOWN
// ============================================================================

class _GlassDropdown extends StatefulWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _GlassDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<_GlassDropdown> createState() => _GlassDropdownState();
}

class _GlassDropdownState extends State<_GlassDropdown> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Color(0xFF243B4C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 9),

        MouseRegion(
          onEnter: (_) {
            setState(() {
              hovering = true;
            });
          },
          onExit: (_) {
            setState(() {
              hovering = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: hovering
                  ? [
                      BoxShadow(
                        color: const Color(0xFF438CC0)
                            .withValues(alpha: 0.16),
                        blurRadius: 18,
                      ),
                    ]
                  : null,
            ),
            child: DropdownButtonFormField<String>(
              initialValue: widget.value,
              isExpanded: true,
              items: widget.items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(
                  alpha: hovering ? 0.58 : 0.42,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF438CC0),
                    width: 1.3,
                  ),
                ),
              ),
              dropdownColor: const Color(0xFFF0F5F7),
              style: const TextStyle(
                color: Color(0xFF243B4C),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// BACK BUTTON
// ============================================================================

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _BackButton({
    required this.onTap,
  });

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: hovering ? 1.025 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE4E5F4).withValues(
                  alpha: hovering ? 1 : 0.88,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                boxShadow: hovering
                    ? [
                        BoxShadow(
                          color: const Color(0xFF5965B0)
                              .withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: const Text(
                '← Back to Settings',
                style: TextStyle(
                  color: Color(0xFF4052A5),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SAVE BUTTON
// ============================================================================

class _SaveButton extends StatefulWidget {
  final VoidCallback onTap;

  const _SaveButton({
    required this.onTap,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedScale(
        scale: hovering ? 1.035 : 1,
        duration: const Duration(milliseconds: 160),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF20A440),
                borderRadius: BorderRadius.circular(10),
                boxShadow: hovering
                    ? [
                        BoxShadow(
                          color: const Color(0xFF20A440)
                              .withValues(alpha: 0.32),
                          blurRadius: 20,
                          offset: const Offset(0, 7),
                        ),
                      ]
                    : null,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.save,
                    size: 17,
                    color: Colors.white,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}