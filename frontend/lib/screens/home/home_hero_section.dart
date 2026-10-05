import 'dart:math' as math;

import 'package:flutter/material.dart';

class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    super.key,
    this.logo,
    this.showNavigation = true,
    this.backgroundColor = const Color(0xFF00142A),
    this.onNavFeatures,
    this.onNavPricing,
    this.onNavAbout,
    this.onNavContact,
    this.onLogin,
    this.onNavGetStarted,
    required this.onStartFreeTrial,
    required this.onExploreFeatures,
  });

  final Widget? logo;
  final bool showNavigation;
  final Color backgroundColor;
  final VoidCallback? onNavFeatures;
  final VoidCallback? onNavPricing;
  final VoidCallback? onNavAbout;
  final VoidCallback? onNavContact;
  final VoidCallback? onLogin;
  final VoidCallback? onNavGetStarted;
  final VoidCallback onStartFreeTrial;
  final VoidCallback onExploreFeatures;

  static const Color ink = Color(0xFF0B1324);
  static const Color muted = Color(0xFF5B6B7C);
  static const Color heroInk = Color(0xFFD2E4FF);
  static const Color heroMuted = Color(0xFFC3C6CF);
  static const Color green = Color(0xFF17A65A);
  static const Color greenDark = Color(0xFF0F8A49);
  static const Color blue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: backgroundColor),
      child: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 56),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showNavigation) ...[
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return constraints.maxWidth < 860
                                ? _buildMobileNav()
                                : _buildDesktopNav();
                          },
                        ),
                        const SizedBox(height: 48),
                      ],
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final stacked = constraints.maxWidth < 980;
                          final textColumn = _buildTextColumn(stacked);
                          final orbit = _buildOrbitColumn();

                          if (stacked) {
                            return Column(
                              children: [
                                textColumn,
                                const SizedBox(height: 56),
                                orbit,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(flex: 6, child: textColumn),
                              const SizedBox(width: 40),
                              Expanded(flex: 6, child: orbit),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNav() {
    return Row(
      children: [
        SizedBox(height: 40, child: logo ?? const SizedBox(width: 1)),
        const Spacer(),
        _NavLink(label: 'Home', active: true, onTap: () {}),
        _NavLink(label: 'Features', onTap: onNavFeatures ?? () {}),
        _NavLink(label: 'Pricing', onTap: onNavPricing ?? () {}),
        _NavLink(label: 'About', onTap: onNavAbout ?? () {}),
        _NavLink(label: 'Contact', onTap: onNavContact ?? () {}),
        const SizedBox(width: 12),
        _NavOutlineButton(label: 'Login', onTap: onLogin ?? () {}),
        const SizedBox(width: 12),
        _NavFilledButton(
          label: 'Get Started',
          onTap: onNavGetStarted ?? () {},
        ),
      ],
    );
  }

  Widget _buildMobileNav() {
    return Row(
      children: [
        SizedBox(height: 36, child: logo ?? const SizedBox(width: 1)),
        const Spacer(),
        PopupMenuButton<String>(
          color: Colors.white,
          icon: const Icon(Icons.menu_rounded, color: ink),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'features', child: Text('Features')),
            PopupMenuItem(value: 'pricing', child: Text('Pricing')),
            PopupMenuItem(value: 'about', child: Text('About')),
            PopupMenuItem(value: 'contact', child: Text('Contact')),
            PopupMenuItem(value: 'login', child: Text('Login')),
            PopupMenuItem(value: 'get_started', child: Text('Get Started')),
          ],
          onSelected: (value) {
            switch (value) {
              case 'features':
                onNavFeatures?.call();
              case 'pricing':
                onNavPricing?.call();
              case 'about':
                onNavAbout?.call();
              case 'contact':
                onNavContact?.call();
              case 'login':
                onLogin?.call();
              case 'get_started':
                onNavGetStarted?.call();
            }
          },
        ),
      ],
    );
  }

  Widget _buildTextColumn(bool centered) {
    final crossAlign =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        const _PillBadge(
          icon: Icons.auto_awesome_rounded,
          label: 'All-in-One Business Management Platform',
        ),
        const SizedBox(height: 22),
        Text(
          'One Platform for Your',
          textAlign: textAlign,
          style: const TextStyle(
            color: heroInk,
            fontSize: 48,
            height: 1.08,
            fontWeight: FontWeight.w800,
          ),
        ),
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [green, blue],
          ).createShader(rect),
          child: Text(
            'Entire Business',
            textAlign: textAlign,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              height: 1.08,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Manage sales, purchases, inventory, customers, vendors, '
            'accounting and more — all in one powerful and easy-to-use '
            'system. Built for growing businesses.',
            textAlign: textAlign,
            style: const TextStyle(
              color: heroMuted,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          spacing: 14,
          runSpacing: 14,
          children: [
            _PrimaryButton(
              label: 'START FREE TRIAL',
              onTap: onStartFreeTrial,
            ),
            _OutlineIconButton(
              label: 'EXPLORE FEATURES',
              icon: Icons.grid_view_rounded,
              onTap: onExploreFeatures,
            ),
          ],
        ),
        const SizedBox(height: 34),
        Wrap(
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          spacing: 28,
          runSpacing: 16,
          children: const [
            _TrustItem(
              icon: Icons.verified_user_rounded,
              iconColor: green,
              title: 'Secure & Reliable',
              subtitle: 'Your data is always safe',
            ),
            _TrustItem(
              icon: Icons.groups_rounded,
              iconColor: Color(0xFF7C3AED),
              title: 'Trusted by Businesses',
              subtitle: 'Across multiple industries',
            ),
            _TrustItem(
              icon: Icons.schedule_rounded,
              iconColor: blue,
              title: '24/7 Support',
              subtitle: "We're here to help",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrbitColumn() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, 560.0);
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: const _OrbitingFeatureRing(),
          ),
        );
      },
    );
  }
}

class _OrbitItemData {
  const _OrbitItemData(this.icon, this.label, this.iconColor, this.iconBg);

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBg;
}

class _OrbitingFeatureRing extends StatefulWidget {
  const _OrbitingFeatureRing();

  @override
  State<_OrbitingFeatureRing> createState() => _OrbitingFeatureRingState();
}

class _OrbitingFeatureRingState extends State<_OrbitingFeatureRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<_OrbitItemData> _items = [
    _OrbitItemData(Icons.shopping_cart_rounded, 'Sales', Color(0xFF17A65A),
        Color(0xFFEAFBF1)),
    _OrbitItemData(Icons.description_rounded, 'Purchases', Color(0xFF2563EB),
        Color(0xFFEAF2FF)),
    _OrbitItemData(Icons.inventory_2_rounded, 'Inventory', Color(0xFF7C3AED),
        Color(0xFFF3EEFF)),
    _OrbitItemData(Icons.groups_rounded, 'Customers', Color(0xFF0D9488),
        Color(0xFFE7FBF8)),
    _OrbitItemData(Icons.calculate_rounded, 'Accounting', Color(0xFF4338CA),
        Color(0xFFEDEFFF)),
    _OrbitItemData(Icons.local_shipping_rounded, 'Vendors', Color(0xFFEA580C),
        Color(0xFFFFF1E6)),
    _OrbitItemData(Icons.bar_chart_rounded, 'Reports', Color(0xFF0EA5A4),
        Color(0xFFE6FBFA)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 42),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(size / 2, size / 2);
        final radius = size * 0.40;
        final itemSize = size * 0.155;

        return RepaintBoundary(
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final angle = _controller.value * 2 * math.pi;

                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: radius * 2,
                      height: radius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              const Color(0xFF17A65A).withValues(alpha: 0.14),
                          width: 1.4,
                        ),
                      ),
                    ),
                    _CenterHub(size: size * 0.40),
                    for (int i = 0; i < _items.length; i++)
                      _buildOrbitItem(
                        index: i,
                        angle: angle,
                        center: center,
                        radius: radius,
                        itemSize: itemSize,
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrbitItem({
    required int index,
    required double angle,
    required Offset center,
    required double radius,
    required double itemSize,
  }) {
    final angleStep = (2 * math.pi) / _items.length;
    final itemAngle = angle + (angleStep * index) - (math.pi / 2);
    final x = center.dx + radius * math.cos(itemAngle) - itemSize / 2;
    final y = center.dy + radius * math.sin(itemAngle) - itemSize / 2;

    return Positioned(
      left: x,
      top: y,
      width: itemSize,
      height: itemSize,
      child: Transform.rotate(
        angle: -angle,
        child: _OrbitCard(item: _items[index], size: itemSize),
      ),
    );
  }
}

class _CenterHub extends StatelessWidget {
  const _CenterHub({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.72),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'YOUR BUSINESS',
              style: TextStyle(
                color: HomeHeroSection.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Simpler. Smarter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: HomeHeroSection.ink,
                fontSize: size * 0.10,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            Text(
              'Stronger.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: HomeHeroSection.green,
                fontSize: size * 0.10,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitCard extends StatelessWidget {
  const _OrbitCard({required this.item, required this.size});

  final _OrbitItemData item;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size * 0.44,
            height: size * 0.44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(size * 0.14),
            ),
            child: Icon(item.icon, color: item.iconColor, size: size * 0.24),
          ),
          SizedBox(height: size * 0.08),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: HomeHeroSection.ink,
              fontSize: size * 0.135,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FAF0),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFBBEBD0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: HomeHeroSection.green, size: 15),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: HomeHeroSection.greenDark,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: HomeHeroSection.heroInk,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: HomeHeroSection.heroMuted,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HoverButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [HomeHeroSection.green, HomeHeroSection.greenDark],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: HomeHeroSection.green.withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _OutlineIconButton extends StatelessWidget {
  const _OutlineIconButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HoverButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HomeHeroSection.green, width: 1.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEAFBF1),
              ),
              child: Icon(icon, color: HomeHeroSection.greenDark, size: 14),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: HomeHeroSection.greenDark,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  const _HoverButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          child: widget.child,
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? HomeHeroSection.green : HomeHeroSection.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: active ? 18 : 0,
                color: HomeHeroSection.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavOutlineButton extends StatelessWidget {
  const _NavOutlineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HoverButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBBEBD0)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: HomeHeroSection.greenDark,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

class _NavFilledButton extends StatelessWidget {
  const _NavFilledButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HoverButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [HomeHeroSection.green, HomeHeroSection.greenDark],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
