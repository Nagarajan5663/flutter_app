import 'package:flutter/material.dart';

import '../auth/login_page.dart';
import '../auth/signup_page.dart';
import '../../widgets/animated_auth_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  String? _selectedPlan;

  final GlobalKey featuresKey = GlobalKey();
  final GlobalKey showcaseKey = GlobalKey();
  final GlobalKey pricingKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();

  static const Color navy = Color(0xFF0D3154);
  static const Color navyDark = Color(0xFF092846);
  static const Color cardColor = Color(0xFF174064);
  static const Color cardLight = Color(0xFF1B496F);
  static const Color borderColor = Color(0xFF315779);
  static const Color gold = Color(0xFFD99A3E);
  static const Color white = Color(0xFFF7F8FA);
  static const Color muted = Color(0xFFB8C7D8);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final targetContext = key.currentContext;

    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        alignment: 0.05,
      );
    }
  }

  void _goToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  void _goToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SignUpPage(),
      ),
    );
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  void _selectPlan(String plan) {
    setState(() {
      _selectedPlan = plan;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$plan plan selected'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: AnimatedAuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildNavbar(),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      _buildHeroSection(),
                      _buildStatsSection(),
                      _buildFeaturesSection(),
                      _buildShowcaseSection(),
                      _buildPricingSection(),
                      _buildAboutSection(),
                      _buildFooter(),
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

  // ============================================================
  // NAVBAR
  // ============================================================

  Widget _buildNavbar() {
    return Container(
      width: double.infinity,
      color: navyDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 15,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 850) {
              return _buildMobileNavbar();
            }

            return _buildDesktopNavbar();
          },
        ),
      ),
    );
  }

  Widget _buildDesktopNavbar() {
    return Row(
      children: [
        _HoverScale(
          child: IconButton(
            onPressed: _goBack,
            tooltip: 'Back',
            icon: const Icon(
              Icons.arrow_back,
              color: white,
            ),
          ),
        ),

        const SizedBox(width: 8),

        _buildLogo(),

        const Spacer(),

        _navButton(
          'Features',
          () => _scrollTo(featuresKey),
        ),

        _navButton(
          'Showcase',
          () => _scrollTo(showcaseKey),
        ),

        _navButton(
          'Pricing',
          () => _scrollTo(pricingKey),
        ),

        _navButton(
          'About Us',
          () => _scrollTo(aboutKey),
        ),

        const SizedBox(width: 20),

        _HoverScale(
          child: TextButton(
            onPressed: _goToLogin,
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        _AnimatedButton(
          onPressed: _goToSignUp,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: gold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(
                color: navyDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileNavbar() {
    return Row(
      children: [
        IconButton(
          onPressed: _goBack,
          icon: const Icon(
            Icons.arrow_back,
            color: white,
          ),
        ),

        _buildLogo(),

        const Spacer(),

        PopupMenuButton<String>(
          color: navyDark,
          icon: const Icon(
            Icons.menu,
            color: white,
          ),
          onSelected: (value) {
            switch (value) {
              case 'features':
                _scrollTo(featuresKey);
                break;

              case 'showcase':
                _scrollTo(showcaseKey);
                break;

              case 'pricing':
                _scrollTo(pricingKey);
                break;

              case 'about':
                _scrollTo(aboutKey);
                break;

              case 'signin':
                _goToLogin();
                break;

              case 'signup':
                _goToSignUp();
                break;
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'features',
                child: Text(
                  'Features',
                  style: TextStyle(color: white),
                ),
              ),
              PopupMenuItem(
                value: 'showcase',
                child: Text(
                  'Showcase',
                  style: TextStyle(color: white),
                ),
              ),
              PopupMenuItem(
                value: 'pricing',
                child: Text(
                  'Pricing',
                  style: TextStyle(color: white),
                ),
              ),
              PopupMenuItem(
                value: 'about',
                child: Text(
                  'About Us',
                  style: TextStyle(color: white),
                ),
              ),
              PopupMenuItem(
                value: 'signin',
                child: Text(
                  'Sign In',
                  style: TextStyle(color: white),
                ),
              ),
              PopupMenuItem(
                value: 'signup',
                child: Text(
                  'Get Started',
                  style: TextStyle(color: white),
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.code,
            color: navyDark,
          ),
        ),

        const SizedBox(width: 10),

        const Text(
          'CODEXIA',
          style: TextStyle(
            color: gold,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _navButton(
    String title,
    VoidCallback onPressed,
  ) {
    return _HoverScale(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(
            color: muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHeroSection() {
    return _ScrollReveal(
      animationType: RevealAnimationType.fadeUp,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 85,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1150,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return Column(
                    children: [
                      _buildHeroText(),
                      const SizedBox(height: 45),
                      _buildHeroVisual(),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildHeroText(),
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      flex: 5,
                      child: _buildHeroVisual(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScrollReveal(
          animationType: RevealAnimationType.fade,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: gold.withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              'SMART BUSINESS MANAGEMENT',
              style: TextStyle(
                color: gold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'Manage Your Business',
          style: TextStyle(
            color: white,
            fontSize: 52,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Elegantly.',
          style: TextStyle(
            color: gold,
            fontSize: 52,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Codexia gives you a powerful and simple way to manage '
          'your sales, purchases, inventory and finances from one '
          'beautiful platform.',
          style: TextStyle(
            color: muted,
            fontSize: 17,
            height: 1.7,
          ),
        ),

        const SizedBox(height: 34),

        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            _AnimatedButton(
              onPressed: _goToSignUp,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Start Your Free Trial',
                  style: TextStyle(
                    color: navyDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            _AnimatedButton(
              onPressed: () => _scrollTo(featuresKey),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Explore Features',
                  style: TextStyle(
                    color: white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroVisual() {
    return _HoverScale(
      scale: 1.02,
      child: Container(
        width: double.infinity,
        height: 390,
        constraints: const BoxConstraints(
          minHeight: 350,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 35,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _windowDot(),
                const SizedBox(width: 6),
                _windowDot(),
                const SizedBox(width: 6),
                _windowDot(),
                const Spacer(),
                const Text(
                  'CODEXIA DASHBOARD',
                  style: TextStyle(
                    color: muted,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _miniStat(
                    'Revenue',
                    '₹1.45L',
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniStat(
                    'Orders',
                    '248',
                    Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: navyDark,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revenue Overview',
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _chartBar(0.35),
                          _chartBar(0.55),
                          _chartBar(0.42),
                          _chartBar(0.75),
                          _chartBar(0.60),
                          _chartBar(0.90),
                          _chartBar(0.78),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _smallInfo(
                    'Low Stock',
                    '3 Items',
                    Icons.warning_amber_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _smallInfo(
                    'Invoices',
                    '12 Pending',
                    Icons.receipt_long_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _windowDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: muted,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _miniStat(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: navyDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: gold,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartBar(double value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1100),
            tween: Tween(
              begin: 0,
              end: value,
            ),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return FractionallySizedBox(
                heightFactor: animatedValue,
                child: Container(
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _smallInfo(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: navyDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: gold,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 9,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANIMATED STATISTICS
  // ============================================================

  Widget _buildStatsSection() {
    return _ScrollReveal(
      animationType: RevealAnimationType.fadeUp,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 45,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1150,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;

                final children = [
                  _AnimatedStatCard(
                    value: 10000,
                    suffix: '+',
                    title: 'Active Businesses',
                    icon: Icons.business,
                    gold: gold,
                  ),
                  _AnimatedStatCard(
                    value: 50000,
                    suffix: '+',
                    title: 'Orders Managed',
                    icon: Icons.shopping_cart,
                    gold: gold,
                  ),
                  _AnimatedStatCard(
                    value: 99,
                    suffix: '%',
                    title: 'Reliable Platform',
                    icon: Icons.verified_outlined,
                    gold: gold,
                  ),
                  _AnimatedStatCard(
                    value: 24,
                    suffix: '/7',
                    title: 'Business Access',
                    icon: Icons.access_time,
                    gold: gold,
                  ),
                ];

                if (isMobile) {
                  return Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: children
                        .map(
                          (child) => SizedBox(
                            width: constraints.maxWidth < 500
                                ? double.infinity
                                : (constraints.maxWidth - 15) / 2,
                            child: child,
                          ),
                        )
                        .toList(),
                  );
                }

                return Row(
                  children: [
                    for (int i = 0; i < children.length; i++) ...[
                      Expanded(
                        child: children[i],
                      ),
                      if (i != children.length - 1)
                        const SizedBox(width: 15),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FEATURES
  // ============================================================

  Widget _buildFeaturesSection() {
    return Container(
      key: featuresKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 90,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1150,
          ),
          child: Column(
            children: [
              _ScrollReveal(
                animationType: RevealAnimationType.fadeUp,
                child: _sectionHeading(
                  'Everything You Need',
                  'Powerful tools designed to simplify your business.',
                ),
              ),

              const SizedBox(height: 45),

              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth >= 950 ? 4 : 2;

                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        _featureCard(
                          Icons.people_alt_outlined,
                          'Sales & CRM',
                          'Manage customers, leads, orders and sales from one place.',
                          'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=900&q=80',
                          RevealAnimationType.slideLeft,
                        ),
                        const SizedBox(height: 18),
                        _featureCard(
                          Icons.shopping_cart_outlined,
                          'Purchase Management',
                          'Track suppliers, purchase orders and incoming products.',
                          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=900&q=80',
                          RevealAnimationType.slideRight,
                        ),
                        const SizedBox(height: 18),
                        _featureCard(
                          Icons.inventory_2_outlined,
                          'Inventory Control',
                          'Know stock levels and identify low-stock products instantly.',
                          'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=900&q=80',
                          RevealAnimationType.slideLeft,
                        ),
                        const SizedBox(height: 18),
                        _featureCard(
                          Icons.account_balance_wallet_outlined,
                          'Financial Dashboard',
                          'Understand revenue, expenses and business performance.',
                          'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=900&q=80',
                          RevealAnimationType.slideRight,
                        ),
                      ],
                    );
                  }

                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.92,
                    children: [
                      _featureCard(
                        Icons.people_alt_outlined,
                        'Sales & CRM',
                        'Manage customers, leads, orders and sales from one place.',
                        'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=900&q=80',
                        RevealAnimationType.slideLeft,
                      ),
                      _featureCard(
                        Icons.shopping_cart_outlined,
                        'Purchase Management',
                        'Track suppliers, purchase orders and incoming products.',
                        'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=900&q=80',
                        RevealAnimationType.fadeUp,
                      ),
                      _featureCard(
                        Icons.inventory_2_outlined,
                        'Inventory Control',
                        'Know stock levels and identify low-stock products instantly.',
                        'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=900&q=80',
                        RevealAnimationType.fadeUp,
                      ),
                      _featureCard(
                        Icons.account_balance_wallet_outlined,
                        'Financial Dashboard',
                        'Understand revenue, expenses and business performance.',
                        'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=900&q=80',
                        RevealAnimationType.slideRight,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard(
    IconData icon,
    String title,
    String description,
    String imageUrl,
    RevealAnimationType animation,
  ) {
    return _ScrollReveal(
      animationType: animation,
      child: _HoverCard(
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: _HoverImage(
                    imageUrl: imageUrl,
                  ),
                ),

                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          icon,
                          color: gold,
                          size: 30,
                        ),

                        const SizedBox(height: 14),

                        Text(
                          title,
                          style: const TextStyle(
                            color: white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          description,
                          style: const TextStyle(
                            color: muted,
                            height: 1.55,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SHOWCASE
  // ============================================================

  Widget _buildShowcaseSection() {
    return Container(
      key: showcaseKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 90,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1150,
          ),
          child: Column(
            children: [
              _ScrollReveal(
                animationType: RevealAnimationType.fadeUp,
                child: _sectionHeading(
                  'Built For Better Decisions',
                  'A clear view of your business whenever you need it.',
                ),
              ),

              const SizedBox(height: 45),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: [
                        _ScrollReveal(
                          animationType:
                              RevealAnimationType.slideLeft,
                          child: _buildShowcaseDashboard(),
                        ),
                        const SizedBox(height: 30),
                        _ScrollReveal(
                          animationType:
                              RevealAnimationType.slideRight,
                          child: _buildShowcasePoints(),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: _ScrollReveal(
                          animationType:
                              RevealAnimationType.slideLeft,
                          child: _buildShowcaseDashboard(),
                        ),
                      ),
                      const SizedBox(width: 45),
                      Expanded(
                        flex: 4,
                        child: _ScrollReveal(
                          animationType:
                              RevealAnimationType.slideRight,
                          child: _buildShowcasePoints(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShowcaseDashboard() {
    return _HoverCard(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Business Overview',
                  style: TextStyle(
                    color: white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: navyDark,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text(
                    'This Month',
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: _dashboardMetric(
                    'Total Revenue',
                    '₹1,45,200',
                    Icons.currency_rupee,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dashboardMetric(
                    'Orders',
                    '248',
                    Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _dashboardMetric(
                    'Customers',
                    '1,248',
                    Icons.people_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dashboardMetric(
                    'Products',
                    '486',
                    Icons.inventory_2_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              height: 180,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: navyDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  _showcaseBar(0.30),
                  _showcaseBar(0.45),
                  _showcaseBar(0.62),
                  _showcaseBar(0.50),
                  _showcaseBar(0.78),
                  _showcaseBar(0.66),
                  _showcaseBar(0.95),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardMetric(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: navyDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: gold,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _showcaseBar(double height) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
        ),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(
            milliseconds: 1200,
          ),
          tween: Tween(
            begin: 0,
            end: height,
          ),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius:
                        BorderRadius.circular(7),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShowcasePoints() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _showcasePoint(
          Icons.visibility_outlined,
          'Complete Visibility',
          'See your business performance clearly from one dashboard.',
        ),

        const SizedBox(height: 22),

        _showcasePoint(
          Icons.flash_on_outlined,
          'Faster Decisions',
          'Important information is available when you need it.',
        ),

        const SizedBox(height: 22),

        _showcasePoint(
          Icons.auto_graph_outlined,
          'Business Growth',
          'Understand your trends and make smarter decisions.',
        ),

        const SizedBox(height: 32),

        _AnimatedButton(
          onPressed: _goToSignUp,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: gold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Explore Codexia',
              style: TextStyle(
                color: navyDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _showcasePoint(
    IconData icon,
    String title,
    String description,
  ) {
    return _HoverCard(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: gold,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: muted,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRICING
  // ============================================================

  Widget _buildPricingSection() {
    return Container(
      key: pricingKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 90,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1150,
          ),
          child: Column(
            children: [
              _ScrollReveal(
                animationType: RevealAnimationType.fadeUp,
                child: _sectionHeading(
                  'Simple, Transparent Pricing',
                  'Choose the plan that fits your business.',
                ),
              ),

              const SizedBox(height: 50),

              LayoutBuilder(
                builder: (context, constraints) {
                  final plans = [
                    _pricingCard(
                      'Starter',
                      '₹0',
                      'Perfect for getting started',
                      [
                        'Basic Dashboard',
                        'Sales Management',
                        'Customer Management',
                        'Basic Reports',
                      ],
                      false,
                    ),
                    _pricingCard(
                      'Professional',
                      '₹999',
                      'For growing businesses',
                      [
                        'Everything in Starter',
                        'Inventory Management',
                        'Purchase Management',
                        'Advanced Reports',
                        'Priority Support',
                      ],
                      true,
                    ),
                    _pricingCard(
                      'Enterprise',
                      'Custom',
                      'For large organizations',
                      [
                        'Everything in Professional',
                        'Advanced Analytics',
                        'Custom Modules',
                        'Dedicated Support',
                      ],
                      false,
                    ),
                  ];

                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: [
                        plans[0],
                        const SizedBox(height: 22),
                        plans[1],
                        const SizedBox(height: 22),
                        plans[2],
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(child: plans[0]),
                      const SizedBox(width: 20),
                      Expanded(child: plans[1]),
                      const SizedBox(width: 20),
                      Expanded(child: plans[2]),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pricingCard(
    String plan,
    String price,
    String description,
    List<String> features,
    bool recommended,
  ) {
    final selected = _selectedPlan == plan;

    return _ScrollReveal(
      animationType: RevealAnimationType.fadeUp,
      child: _HoverCard(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: selected
                ? cardLight
                : cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: recommended || selected
                  ? gold
                  : borderColor,
              width: recommended || selected ? 2 : 1,
            ),
            boxShadow: recommended
                ? [
                    BoxShadow(
                      color: gold.withValues(alpha: 0.12),
                      blurRadius: 25,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (recommended)
                Container(
                  margin:
                      const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      color: navyDark,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              Text(
                plan,
                style: const TextStyle(
                  color: white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                description,
                style: const TextStyle(
                  color: muted,
                ),
              ),

              const SizedBox(height: 25),

              Text(
                price,
                style: TextStyle(
                  color: gold,
                  fontSize: price == 'Custom'
                      ? 32
                      : 40,
                  fontWeight: FontWeight.w800,
                ),
              ),

              if (price != 'Custom')
                const Text(
                  'per month',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),

              const SizedBox(height: 25),

              const Divider(
                color: borderColor,
              ),

              const SizedBox(height: 15),

              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: gold,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: _AnimatedButton(
                  onPressed: () =>
                      _selectPlan(plan),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: recommended
                          ? gold
                          : navyDark,
                      borderRadius:
                          BorderRadius.circular(8),
                      border: recommended
                          ? null
                          : Border.all(
                              color: borderColor,
                            ),
                    ),
                    child: Text(
                      selected
                          ? 'Selected'
                          : 'Choose Plan',
                      style: TextStyle(
                        color: recommended
                            ? navyDark
                            : white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  Widget _buildAboutSection() {
    return Container(
      key: aboutKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 90,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1150,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return Column(
                  children: [
                    _ScrollReveal(
                      animationType:
                          RevealAnimationType.slideLeft,
                      child: _buildAboutImage(),
                    ),
                    const SizedBox(height: 40),
                    _ScrollReveal(
                      animationType:
                          RevealAnimationType.slideRight,
                      child: _buildAboutContent(),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _ScrollReveal(
                      animationType:
                          RevealAnimationType.slideLeft,
                      child: _buildAboutImage(),
                    ),
                  ),
                  const SizedBox(width: 65),
                  Expanded(
                    child: _ScrollReveal(
                      animationType:
                          RevealAnimationType.slideRight,
                      child: _buildAboutContent(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAboutImage() {
    return _HoverImage(
      imageUrl:
          'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=1200&q=80',
      height: 400,
      borderRadius: 20,
    );
  }

  Widget _buildAboutContent() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'ABOUT CODEXIA',
          style: TextStyle(
            color: gold,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Built To Make Business Management Simpler.',
          style: TextStyle(
            color: white,
            fontSize: 38,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 22),

        const Text(
          'Codexia brings important business operations together '
          'into one powerful platform. Manage sales, inventory, '
          'purchases, finances and customers with clarity.',
          style: TextStyle(
            color: muted,
            fontSize: 16,
            height: 1.7,
          ),
        ),

        const SizedBox(height: 28),

        _aboutCheck(
          'Simple and easy to use',
        ),
        _aboutCheck(
          'Designed for modern businesses',
        ),
        _aboutCheck(
          'Clear insights and analytics',
        ),
        _aboutCheck(
          'Accessible from anywhere',
        ),

        const SizedBox(height: 30),

        _AnimatedButton(
          onPressed: _goToSignUp,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: gold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Get Started Today',
              style: TextStyle(
                color: navyDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _aboutCheck(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: gold,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: muted,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: navyDark,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 50,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1150,
          ),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 700) {
                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _footerBrand(),
                        const SizedBox(height: 35),
                        _footerLinks(),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _footerBrand(),
                      ),
                      Expanded(
                        child: _footerLinks(),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 35),

              const Divider(
                color: borderColor,
              ),

              const SizedBox(height: 20),

              const Text(
                '© 2026 Codexia. All rights reserved.',
                style: TextStyle(
                  color: muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerBrand() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildLogo(),

        const SizedBox(height: 18),

        const Text(
          'A smarter way to manage your business.',
          style: TextStyle(
            color: muted,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _footerLinks() {
    return Wrap(
      spacing: 35,
      runSpacing: 15,
      children: [
        _footerButton(
          'Features',
          () => _scrollTo(featuresKey),
        ),
        _footerButton(
          'Showcase',
          () => _scrollTo(showcaseKey),
        ),
        _footerButton(
          'Pricing',
          () => _scrollTo(pricingKey),
        ),
        _footerButton(
          'About',
          () => _scrollTo(aboutKey),
        ),
        _footerButton(
          'Sign In',
          _goToLogin,
        ),
      ],
    );
  }

  Widget _footerButton(
    String text,
    VoidCallback onPressed,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  Widget _sectionHeading(
    String title,
    String subtitle,
  ) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: white,
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: muted,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ANIMATED STAT CARD
// ============================================================

class _AnimatedStatCard extends StatelessWidget {
  const _AnimatedStatCard({
    required this.value,
    required this.suffix,
    required this.title,
    required this.icon,
    required this.gold,
  });

  final int value;
  final String suffix;
  final String title;
  final IconData icon;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return _HoverCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF174064),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF315779),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: gold,
              size: 30,
            ),

            const SizedBox(height: 12),

            _AnimatedCounter(
              value: value,
              suffix: suffix,
            ),

            const SizedBox(height: 7),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB8C7D8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ANIMATED COUNTER
// ============================================================

class _AnimatedCounter extends StatelessWidget {
  const _AnimatedCounter({
    required this.value,
    required this.suffix,
  });

  final int value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: value.toDouble(),
      ),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '${animatedValue.toInt()}$suffix',
          style: const TextStyle(
            color: Color(0xFFF7F8FA),
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        );
      },
    );
  }
}

// ============================================================
// HOVER CARD
// ============================================================

class _HoverCard extends StatefulWidget {
  const _HoverCard({
    required this.child,
  });

  final Widget child;

  @override
  State<_HoverCard> createState() =>
      _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _hovered ? -6 : 0,
          0,
        ),
        decoration: BoxDecoration(
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.25,
                    ),
                    blurRadius: 25,
                    offset: const Offset(0, 14),
                  ),
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}

// ============================================================
// HOVER SCALE
// ============================================================

class _HoverScale extends StatefulWidget {
  const _HoverScale({
    required this.child,
    this.scale = 1.05,
  });

  final Widget child;
  final double scale;

  @override
  State<_HoverScale> createState() =>
      _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: _hovered ? widget.scale : 1,
        child: widget.child,
      ),
    );
  }
}

// ============================================================
// ANIMATED BUTTON
// ============================================================

class _AnimatedButton extends StatefulWidget {
  const _AnimatedButton({
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final VoidCallback onPressed;

  @override
  State<_AnimatedButton> createState() =>
      _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed
        ? 0.96
        : _hovered
            ? 1.04
            : 1.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
          _pressed = false;
        });
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _pressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _pressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            _pressed = false;
          });
        },
        onTap: widget.onPressed,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 130),
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOVER IMAGE
// ============================================================

class _HoverImage extends StatefulWidget {
  const _HoverImage({
    required this.imageUrl,
    this.height,
    this.borderRadius = 0,
  });

  final String imageUrl;
  final double? height;
  final double borderRadius;

  @override
  State<_HoverImage> createState() =>
      _HoverImageState();
}

class _HoverImageState extends State<_HoverImage> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(widget.borderRadius),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            scale: _hovered ? 1.08 : 1,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  color: const Color(0xFF174064),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFFB8C7D8),
                      size: 45,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SCROLL REVEAL ANIMATION
// ============================================================

enum RevealAnimationType {
  fade,
  fadeUp,
  slideLeft,
  slideRight,
}

class _ScrollReveal extends StatefulWidget {
  const _ScrollReveal({
    required this.child,
    this.animationType =
        RevealAnimationType.fadeUp,
  });

  final Widget child;
  final RevealAnimationType animationType;

  @override
  State<_ScrollReveal> createState() =>
      _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: _beginOffset(),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  Offset _beginOffset() {
    switch (widget.animationType) {
      case RevealAnimationType.fade:
        return Offset.zero;

      case RevealAnimationType.fadeUp:
        return const Offset(0, 0.18);

      case RevealAnimationType.slideLeft:
        return const Offset(-0.15, 0);

      case RevealAnimationType.slideRight:
        return const Offset(0.15, 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animationType ==
        RevealAnimationType.fade) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}