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
  static const Color highlightYellow = Color(0xFFFFD54F);
  static const Color white = Color(0xFFF7F8FA);
  static const Color muted = Color(0xFFB8C7D8);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        alignment: 0.08,
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _selectPlan(String plan) {
    setState(() => _selectedPlan = plan);
  }

  void _goToLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void _goToSignUp() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SignUpPage()));
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
        _buildBackButton(),
        const SizedBox(width: 8),
        _buildLogo(),

        const Spacer(),

        _navButton('Features', () => _scrollTo(featuresKey)),

        _navButton('Showcase', () => _scrollTo(showcaseKey)),

        _navButton('Pricing', () => _scrollTo(pricingKey)),

        _navButton('About Us', () => _scrollTo(aboutKey)),

        const SizedBox(width: 18),

        TextButton(
          onPressed: () {
            _goToLogin();
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 10),

        ElevatedButton(
          onPressed: () {
            _goToSignUp();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navyDark,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Get Started',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileNavbar() {
    return Row(
      children: [
        _buildBackButton(),
        const SizedBox(width: 4),
        _buildLogo(),
        const Spacer(),
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: white, size: 30),
          color: navyDark,
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

              case 'started':
                _goToSignUp();
                break;
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'features',
                child: Text('Features', style: TextStyle(color: white)),
              ),
              PopupMenuItem(
                value: 'showcase',
                child: Text('Showcase', style: TextStyle(color: white)),
              ),
              PopupMenuItem(
                value: 'pricing',
                child: Text('Pricing', style: TextStyle(color: white)),
              ),
              PopupMenuItem(
                value: 'about',
                child: Text('About Us', style: TextStyle(color: white)),
              ),
              PopupMenuItem(
                value: 'signin',
                child: Text('Sign In', style: TextStyle(color: white)),
              ),
              PopupMenuItem(
                value: 'started',
                child: Text('Get Started', style: TextStyle(color: white)),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: _goBack,
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back, color: white),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.code, color: navyDark, size: 24),
        ),
        const SizedBox(width: 10),
        _buildCodexiaWordmark(),
      ],
    );
  }

  Widget _buildCodexiaWordmark() {
    const wordmarkFont = 'Georgia';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 2,
          top: 3,
          child: Text(
            'CODEXIA',
            style: TextStyle(
              fontFamily: wordmarkFont,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: navyDark,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 1,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
        Text(
          'CODEXIA',
          style: TextStyle(
            fontFamily: wordmarkFont,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.4
              ..color = navyDark,
          ),
        ),
        Text(
          'CODEXIA',
          style: TextStyle(
            fontFamily: wordmarkFont,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: gold,
            shadows: const [
              Shadow(
                color: Color(0xFFFFE7A3),
                blurRadius: 0.5,
                offset: Offset(0, -1),
              ),
              Shadow(
                color: Color(0xFF8A5C1D),
                blurRadius: 0,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navButton(String title, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: const TextStyle(
          color: muted,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return _buildMobileHero();
              }

              return _buildDesktopHero();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHero() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: _buildHeroText()),
        const SizedBox(width: 60),
        Expanded(flex: 5, child: _buildHeroVisual()),
      ],
    );
  }

  Widget _buildMobileHero() {
    return Column(
      children: [
        _buildHeroText(),
        const SizedBox(height: 50),
        _buildHeroVisual(),
      ],
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: gold.withValues(alpha: 0.35)),
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

        const SizedBox(height: 24),

        const Text(
          'Manage Your Business',
          style: TextStyle(
            color: white,
            fontSize: 52,
            height: 1.08,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Elegantly.',
          style: TextStyle(
            color: gold,
            fontSize: 52,
            height: 1.08,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Codexia gives you a powerful and simple way to manage '
          'your sales, purchases, inventory and finances from one '
          'beautiful platform.',
          style: TextStyle(color: muted, fontSize: 17, height: 1.7),
        ),

        const SizedBox(height: 34),

        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            ElevatedButton(
              onPressed: () {
                _goToSignUp();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: navyDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 17,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Start Your Free Trial',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            OutlinedButton(
              onPressed: () {
                _scrollTo(featuresKey);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: white,
                side: const BorderSide(color: borderColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 17,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Explore Features'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroVisual() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 330),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 18),
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
                style: TextStyle(color: muted, fontSize: 9, letterSpacing: 1),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _miniStat('Revenue', '₹1.45L', Icons.trending_up),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniStat('Orders', '248', Icons.shopping_bag_outlined),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            height: 130,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: navyDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Revenue Overview',
                  style: TextStyle(color: white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _chartBar(0.35),
                      _chartBar(0.55),
                      _chartBar(0.45),
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

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _smallInfo(
                  'Low Stock',
                  '3 Items',
                  Icons.warning_amber_rounded,
                ),
              ),
              const SizedBox(width: 10),
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
    );
  }

  Widget _windowDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(color: muted, shape: BoxShape.circle),
    );
  }

  Widget _miniStat(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: navyDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: muted, fontSize: 10)),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartBar(double height) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FractionallySizedBox(
          heightFactor: height,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: gold,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallInfo(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: navyDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: muted, fontSize: 9)),
                Text(
                  value,
                  style: const TextStyle(
                    color: white,
                    fontSize: 12,
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
  // FEATURES
  // ============================================================

  Widget _buildFeaturesSection() {
    return Container(
      key: featuresKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: Column(
            children: [
              _sectionHeading(
                'Everything You Need',
                'Powerful tools designed to simplify your business.',
              ),

              const SizedBox(height: 45),

              LayoutBuilder(
                builder: (context, constraints) {
                  int columns;

                  if (constraints.maxWidth >= 950) {
                    columns = 4;
                  } else {
                    columns = 2;
                  }

                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: constraints.maxWidth < 600 ? 0.58 : 1.05,
                    children: [
                      _featureCard(
                        Icons.people_alt_outlined,
                        'Sales & CRM',
                        'Manage customers, leads, orders and sales from one place.',
                        'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=900&q=80',
                      ),
                      _featureCard(
                        Icons.shopping_cart_outlined,
                        'Purchase Management',
                        'Track suppliers, purchase orders and incoming products.',
                        'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=900&q=80',
                      ),
                      _featureCard(
                        Icons.inventory_2_outlined,
                        'Inventory Control',
                        'Know your stock levels and identify low-stock products instantly.',
                        'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=900&q=80',
                      ),
                      _featureCard(
                        Icons.account_balance_wallet_outlined,
                        'Financial Dashboard',
                        'Understand your revenue, expenses and business performance.',
                        'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=900&q=80',
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

  Widget _sectionHeading(String title, String subtitle) {
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
          style: const TextStyle(color: muted, fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _featureCard(
    IconData icon,
    String title,
    String description,
    String imageUrl,
  ) {
    return _FeatureCard(
      icon: icon,
      title: title,
      description: description,
      imageUrl: imageUrl,
      cardColor: cardColor,
      borderColor: borderColor,
      gold: gold,
      white: white,
      muted: muted,
    );
  }

  // ============================================================
  // SHOWCASE
  // ============================================================

  Widget _buildShowcaseSection() {
    return Container(
      key: showcaseKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: Column(
            children: [
              _sectionHeading(
                'Built For Better Decisions',
                'A clear view of your business whenever you need it.',
              ),

              const SizedBox(height: 45),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: [
                        _buildShowcaseDashboard(),
                        const SizedBox(height: 25),
                        _buildShowcasePoints(),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: _buildShowcaseDashboard()),
                      const SizedBox(width: 45),
                      Expanded(flex: 4, child: _buildShowcasePoints()),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Business Overview',
                style: TextStyle(
                  color: white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: navyDark,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'This Month',
                  style: TextStyle(color: muted, fontSize: 10),
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
                  '₹1,45,200.50',
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
        ],
      ),
    );
  }

  Widget _dashboardMetric(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: navyDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: muted, fontSize: 10)),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: white,
                    fontSize: 15,
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

  Widget _buildShowcasePoints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _showcasePoint(
          Icons.speed,
          'Real-Time Insights',
          'See important business information without complicated reports.',
        ),
        const SizedBox(height: 24),
        _showcasePoint(
          Icons.notifications_none,
          'Smart Alerts',
          'Stay informed about low stock, pending invoices and important activities.',
        ),
        const SizedBox(height: 24),
        _showcasePoint(
          Icons.security_outlined,
          'Secure Platform',
          'Keep your business information organized and protected.',
        ),
      ],
    );
  }

  Widget _showcasePoint(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: gold, size: 22),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                description,
                style: const TextStyle(color: muted, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRICING
  // ============================================================

  Widget _buildPricingSection() {
    return Container(
      key: pricingKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: Column(
            children: [
              _sectionHeading(
                'Simple Pricing',
                'Choose a plan that fits your business.',
              ),

              const SizedBox(height: 45),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: [
                        _pricingCard(
                          title: 'Starter',
                          price: '₹999',
                          description: 'For small businesses getting started.',
                          features: const [
                            'Sales management',
                            'Purchase management',
                            'Inventory management',
                            'Basic dashboard',
                          ],
                          highlighted: _selectedPlan == 'Starter',
                          onTap: () => _selectPlan('Starter'),
                        ),
                        const SizedBox(height: 20),
                        _pricingCard(
                          title: 'Pro',
                          price: '₹2,499',
                          description: 'For growing businesses.',
                          features: const [
                            'Everything in Starter',
                            'Advanced dashboard',
                            'Financial reports',
                            'Smart alerts',
                            'Priority support',
                          ],
                          highlighted: _selectedPlan == 'Pro',
                          onTap: () => _selectPlan('Pro'),
                        ),
                        const SizedBox(height: 20),
                        _pricingCard(
                          title: 'Enterprise',
                          price: 'Custom',
                          description: 'For large organizations.',
                          features: const [
                            'Everything in Pro',
                            'Custom solutions',
                            'Dedicated support',
                            'Advanced integrations',
                          ],
                          highlighted: _selectedPlan == 'Enterprise',
                          onTap: () => _selectPlan('Enterprise'),
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _pricingCard(
                          title: 'Starter',
                          price: '₹999',
                          description: 'For small businesses getting started.',
                          features: const [
                            'Sales management',
                            'Purchase management',
                            'Inventory management',
                            'Basic dashboard',
                          ],
                          highlighted: _selectedPlan == 'Starter',
                          onTap: () => _selectPlan('Starter'),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _pricingCard(
                          title: 'Pro',
                          price: '₹2,499',
                          description: 'For growing businesses.',
                          features: const [
                            'Everything in Starter',
                            'Advanced dashboard',
                            'Financial reports',
                            'Smart alerts',
                            'Priority support',
                          ],
                          highlighted: _selectedPlan == 'Pro',
                          onTap: () => _selectPlan('Pro'),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _pricingCard(
                          title: 'Enterprise',
                          price: 'Custom',
                          description: 'For large organizations.',
                          features: const [
                            'Everything in Pro',
                            'Custom solutions',
                            'Dedicated support',
                            'Advanced integrations',
                          ],
                          highlighted: _selectedPlan == 'Enterprise',
                          onTap: () => _selectPlan('Enterprise'),
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

  Widget _pricingCard({
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required bool highlighted,
    required VoidCallback onTap,
  }) {
    return _HoverLift(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: highlighted ? cardLight : cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: highlighted ? highlightYellow : borderColor,
            width: highlighted ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (highlighted)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: navyDark,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (highlighted) const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                color: white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: gold,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (price != 'Custom')
                  const Padding(
                    padding: EdgeInsets.only(bottom: 5, left: 4),
                    child: Text(
                      '/month',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              description,
              style: const TextStyle(color: muted, fontSize: 13, height: 1.5),
            ),

            const SizedBox(height: 22),

            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: gold,
                      size: 18,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: highlighted
                  ? ElevatedButton(
                      onPressed: () {
                        _goToSignUp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: navyDark,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: () {
                        _goToSignUp();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: white,
                        side: const BorderSide(color: borderColor),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Choose Plan'),
                    ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 750) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _aboutText(),
                    const SizedBox(height: 35),
                    _contactCard(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _aboutText()),
                  const SizedBox(width: 60),
                  Expanded(flex: 4, child: _contactCard()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _aboutText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Codexia',
          style: TextStyle(
            color: white,
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Codexia is designed to help businesses work smarter, '
          'faster and more efficiently.',
          style: TextStyle(
            color: gold,
            fontSize: 18,
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'From managing customers and inventory to understanding '
          'your financial performance, Codexia brings your most '
          'important business operations together in one platform.',
          style: TextStyle(color: muted, fontSize: 15, height: 1.8),
        ),

        const SizedBox(height: 25),

        const Text(
          'Powered by Ark Codux',
          style: TextStyle(
            color: white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _contactCard() {
    return _HoverLift(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get In Touch',
              style: TextStyle(
                color: white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 22),

            _contactRow(
              Icons.location_on_outlined,
              'Rayala Towers, Tower II, First Floor, Anna Salai, Chennai - 600002',
            ),

            const SizedBox(height: 18),

            _contactRow(Icons.email_outlined, 'sales@arkcodux.com'),

            const SizedBox(height: 18),

            _contactRow(Icons.phone_outlined, '+91 88259 13297'),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: gold, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: muted, fontSize: 13, height: 1.5),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      color: navy,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    const Text(
                      '© 2026 Codexia. All rights reserved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    _footerLinks(),
                  ],
                );
              }

              return Row(
                children: [
                  const Text(
                    '© 2026 Codexia. All rights reserved.',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  const Spacer(),
                  _footerLinks(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _footerLinks() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _footerLink('Privacy'),
        const SizedBox(width: 20),
        _footerLink('Terms'),
        const SizedBox(width: 20),
        _footerLink('Contact'),
      ],
    );
  }

  Widget _footerLink(String text) {
    return InkWell(
      onTap: () {
        _showMessage('$text page coming soon.');
      },
      child: Text(text, style: const TextStyle(color: muted, fontSize: 12)),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.cardColor,
    required this.borderColor,
    required this.gold,
    required this.white,
    required this.muted,
  });

  final IconData icon;
  final String title;
  final String description;
  final String imageUrl;
  final Color cardColor;
  final Color borderColor;
  final Color gold;
  final Color white;
  final Color muted;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: widget.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? widget.gold : widget.borderColor,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.gold.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: AnimatedScale(
                scale: _isHovered ? 1.04 : 1,
                duration: const Duration(milliseconds: 260),
                child: SizedBox(
                  width: double.infinity,
                  height: 105,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: widget.gold.withValues(alpha: 0.13),
                        alignment: Alignment.center,
                        child: Icon(widget.icon, color: widget.gold, size: 30),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(widget.icon, color: widget.gold, size: 21),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.description,
              style: TextStyle(color: widget.muted, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverLift extends StatefulWidget {
  const _HoverLift({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _active = false;

  void _setActive(bool active) {
    if (mounted) {
      setState(() => _active = active);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setActive(true),
      onExit: (_) => _setActive(false),
      child: GestureDetector(
        onTapDown: (_) => _setActive(true),
        onTapUp: (_) => _setActive(false),
        onTapCancel: () => _setActive(false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _active ? -6 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: _active
                ? [
                    BoxShadow(
                      color: _HomePageState.gold.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : null,
          ),
          child: Stack(fit: StackFit.passthrough, children: [widget.child]),
        ),
      ),
    );
  }
}
