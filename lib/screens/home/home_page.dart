import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../auth/login_page.dart';
import '../auth/signup_page.dart';
import '../../widgets/codexia_logo.dart';

/// ============================================================
/// CODEXIA — dark navy / gold "executive glass" home page.
/// Now with a STICKY STACKING CARDS scroll animation: Features,
/// Showcase, Pricing and About each pin to the top of the
/// viewport and shrink into a "peek strip" as the next card
/// slides up and overlaps it — like a deck of cards being
/// dealt down the page.
/// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  String? _selectedPlan;
  double _scrollProgress = 0;
  bool _scrolledPastTop = false;

  final GlobalKey featuresKey = GlobalKey();
  final GlobalKey showcaseKey = GlobalKey();
  final GlobalKey pricingKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();

  OverlayEntry? _toastEntry;

  // ---- Tokens (pulled straight from the Tailwind config) ---------------
  static const Color background = Color(0xFF00142A);
  static const Color surfaceContainer = Color(0xFF00203E);
  static const Color surfaceContainerHigh = Color(0xFF0D2B49);
  static const Color surfaceContainerHighest = Color(0xFF1B3655);
  static const Color surfaceBright = Color(0xFF1F3A59);
  static const Color surfaceContainerLowest = Color(0xFF000F21);
  static const Color outlineVariant = Color(0xFF43474E);

  static const Color primary = Color(0xFFAAC9F4);
  static const Color onPrimary = Color(0xFF0E3255);

  static const Color secondary = Color(0xFFFDBA5A); // gold
  static const Color secondaryFixed = Color(0xFFFFDDB5);
  static const Color secondaryContainer = Color(0xFF976200);
  static const Color onSecondary = Color(0xFF452B00);

  static const Color tertiary = Color(0xFF4EDEA3); // mint

  static const Color onSurface = Color(0xFFD2E4FF);
  static const Color onSurfaceVariant = Color(0xFFC3C6CF);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final progress = position.maxScrollExtent > 0
        ? (position.pixels / position.maxScrollExtent).clamp(0.0, 1.0)
        : 0.0;
    final pastTop = position.pixels > 20;
    if (progress != _scrollProgress || pastTop != _scrolledPastTop) {
      setState(() {
        _scrollProgress = progress;
        _scrolledPastTop = pastTop;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _toastEntry?.remove();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        alignment: 0.0,
      );
    }
  }

  void _goToLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void _goToSignUp() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpPage()));
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
  }

  void _selectPlan(String plan) {
    setState(() => _selectedPlan = plan);
    _showToast('$plan Tier Selected', 'Codexia deployment configured for $plan.');
  }

  void _showToast(String title, String message) {
    _toastEntry?.remove();
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _ToastNotification(title: title, message: message),
    );
    _toastEntry = entry;
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 3200), () {
      entry.remove();
      if (_toastEntry == entry) _toastEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = MediaQuery.of(context).size.width < 820;
    final cardHeight = isMobile
      ? math.max(420.0, math.min(460.0, screenHeight * 0.58))
      : math.max(360.0, math.min(390.0, screenHeight * 0.42));
    const peekHeight = 62.0;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(
              color: background,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildNavbar(),
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeroSection()),
                      SliverToBoxAdapter(child: _buildStatsSection()),
                      // FEATURE-ONLY STACK GROUP
                      // The exit spacer belongs to the feature group. This is important:
                      // after Card 4, the whole pinned feature stack scrolls out first;
                      // only then can the Showcase section enter the viewport.
                      SliverMainAxisGroup(
                        slivers: [
                          ..._buildFeatureStackCards(cardHeight, peekHeight),
                          SliverToBoxAdapter(
                            child: SizedBox(height: cardHeight * 0.92),
                          ),
                        ],
                      ),
                      // Normal content starts only after the complete feature stack exits.
                      SliverToBoxAdapter(child: _buildShowcaseSection()),
                      SliverToBoxAdapter(child: _buildPricingSection()),
                      SliverToBoxAdapter(child: _buildAboutSection()),
                      SliverToBoxAdapter(child: _buildFooter()),
                    ],
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
  // NAVBAR
  // ============================================================

  Widget _buildNavbar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: surfaceContainerHigh.withValues(alpha: _scrolledPastTop ? 0.88 : 0.7),
                boxShadow: _scrolledPastTop
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))]
                    : const [],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 860) return _buildMobileNav();
                  return _buildDesktopNav();
                },
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -2,
          child: FractionallySizedBox(
            widthFactor: _scrollProgress,
            alignment: Alignment.centerLeft,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [secondaryContainer, secondary, secondaryFixed, secondary]),
                boxShadow: [BoxShadow(color: secondary.withValues(alpha: 0.5), blurRadius: 8)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopNav() {
    return Row(
      children: [
        _HoverScale(
          child: IconButton(onPressed: _goBack, tooltip: 'Back', icon: const Icon(Icons.arrow_back, color: onSurface)),
        ),
        const SizedBox(width: 6),
        _buildWordmark(),
        const Spacer(),
        _NavLink(title: 'Features', onPressed: () => _scrollTo(featuresKey)),
        _NavLink(title: 'Showcase', onPressed: () => _scrollTo(showcaseKey)),
        _NavLink(title: 'Pricing', onPressed: () => _scrollTo(pricingKey)),
        _NavLink(title: 'About Us', onPressed: () => _scrollTo(aboutKey)),
        const SizedBox(width: 24),
        _HoverScale(
          child: TextButton(
            onPressed: _goToLogin,
            child: const Text('Sign In', style: TextStyle(color: onSurfaceVariant, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 10),
        _GoldButton(label: 'Get Started', onPressed: _goToSignUp),
        const SizedBox(width: 14),
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: primary, shape: BoxShape.circle),
          child: const Icon(Icons.person, color: onPrimary, size: 18),
        ),
      ],
    );
  }

  Widget _buildMobileNav() {
    return Row(
      children: [
        IconButton(onPressed: _goBack, icon: const Icon(Icons.arrow_back, color: onSurface)),
        _buildWordmark(),
        const Spacer(),
        PopupMenuButton<String>(
          color: surfaceContainerHigh,
          icon: const Icon(Icons.menu, color: onSurface),
          itemBuilder: (context) => [
            _mobileItem('features', 'Features'),
            _mobileItem('showcase', 'Showcase'),
            _mobileItem('pricing', 'Pricing'),
            _mobileItem('about', 'About Us'),
            _mobileItem('signin', 'Sign In'),
            _mobileItem('signup', 'Get Started'),
          ],
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
        ),
      ],
    );
  }

  PopupMenuItem<String> _mobileItem(String value, String label) {
    return PopupMenuItem(value: value, child: Text(label, style: const TextStyle(color: onSurface)));
  }

  Widget _buildWordmark() {
    return const CodexiaLogo(iconSize: 40, fontSize: 20);
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHeroSection() {
    return _FloatingCodexiaHero(
      onStartTrial: _goToSignUp,
      onExploreFeatures: () => _scrollTo(featuresKey),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 4 : (constraints.maxWidth >= 560 ? 2 : 1);
              final cards = [
                _statCard(Icons.corporate_fare, 'GLOBAL SCALE', 10000, '+', 'Active Corporate Entities', secondary),
                _statCard(Icons.receipt_long, 'EXECUTION', 50000, '+', 'Orders Managed Daily', primary),
                _statCard(Icons.verified_user, 'SLO GUARANTEE', 99, '.9%', 'Fault-Tolerant Uptime', tertiary),
                _staticStatCard(Icons.sync_alt, 'AVAILABILITY', '24/7', 'Continuous Cloud Operation', secondary),
              ];
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: cards
                    .map((c) => SizedBox(width: (constraints.maxWidth - (columns - 1) * 16) / columns, child: c))
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String tag, int target, String suffix, String label, Color accent) {
    return _TiltCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: surfaceContainer.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: accent, size: 26),
                ),
                Text(tag, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ],
            ),
            const SizedBox(height: 16),
            _CountUp(target: target, suffix: suffix, accent: accent),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: onSurfaceVariant, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _staticStatCard(IconData icon, String tag, String value, String label, Color accent) {
    return _TiltCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: surfaceContainer.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: accent, size: 26),
                ),
                Text(tag, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(color: onSurface, fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: onSurfaceVariant, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STICKY STACKING CARDS
  // Each entry below becomes one SliverPersistentHeader that
  // pins to the top and shrinks into a "peek strip" as the next
  // card scrolls up over it, producing the overlapping-deck
  // effect down the page: Features (x4) → Showcase → Pricing → About.
  // ============================================================

  // ============================================================
  // FEATURE-ONLY STICKY STACK
  // Only the four feature cards use the overlapping sticky animation.
  // Showcase, Pricing and About continue as normal page sections.
  // ============================================================

  List<Widget> _buildFeatureStackCards(double cardHeight, double peekHeight) {
    final features = [
      _Feature('Sales & CRM Matrix',
          'Direct pipeline tracking, automated client tiering, lead scoring, and instant customer lifecycle visibility without disconnected third-party integrations.',
          'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=1200&q=80', Icons.point_of_sale, secondary),
      _Feature('Purchase & Vendor Orchestration',
          'Automate multi-tier purchase orders, supplier evaluation metrics, dispatch tracking, and fulfillment reconciliation with zero latency.',
          'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=1200&q=80', Icons.local_shipping, primary),
      _Feature('Real-Time Inventory Control',
          'Multi-warehouse inventory routing, proactive low-stock predictive alarms, barcode telemetry, and automated replenishment dispatch.',
          'https://images.unsplash.com/photo-1553413077-190dd305871c?w=1200&q=80', Icons.inventory_2, tertiary),
      _Feature('Financial Telemetry & Treasury',
          'Automated P&L ledger mapping, cash burn analysis, margin trends, and instant export-ready regulatory balance sheets.',
          'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=1200&q=80', Icons.account_balance_wallet, secondary),
    ];

    return List.generate(features.length, (i) {
      return SliverPersistentHeader(
        key: i == 0 ? featuresKey : null,
        pinned: true,
        delegate: _StackCardDelegate(
          maxHeight: cardHeight,
          minHeight: peekHeight,
          contentBuilder: (context, progress) =>
              _stackedFeatureCard(features[i], i + 1, features.length, progress),
        ),
      );
    });
  }

  /// Shared header strip for every stacked card — this is the part
  /// that stays visible once the card has fully collapsed into the
  /// stack, so it must never depend on `progress`.
  Widget _stackHeader({required IconData icon, required Color accent, required String title, required String tag, required int index, required int total}) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: accent, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tag, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.3)),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('${index.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
              style: const TextStyle(color: onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _stackCardShell({required Color accent, required Widget child}) {
    final radius = BorderRadius.circular(24);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: surfaceContainer.withValues(alpha: 0.48),
            borderRadius: radius,
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _stackedFeatureCard(_Feature f, int index, int total, double progress) {
    final isLastCard = index == total;

    return _AnimatedFeatureBackground(
      accent: f.accent,
      index: index,
      progress: progress,
      child: _stackCardShell(
        accent: f.accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _stackHeader(
              icon: f.icon,
              accent: f.accent,
              title: f.title,
              tag: 'FEATURE',
              index: index,
              total: total,
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, isLastCard ? 8 : 0, 16, isLastCard ? 22 : 16),
                    child: isLastCard
                        ? _buildFinalFeatureSlide(f)
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final stacked = constraints.maxWidth < 820;

                              final image = ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: _HoverImage(
                                  imageUrl: f.imageUrl,
                                  height: stacked ? 150 : null,
                                ),
                              );

                              final copy = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    f.title,
                                    style: const TextStyle(
                                      color: onSurface,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    f.copy,
                                    style: const TextStyle(
                                      color: onSurfaceVariant,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Inspect Workflow',
                                        style: TextStyle(
                                          color: f.accent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: f.accent,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              );

                              if (stacked) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 150,
                                      child: image,
                                    ),
                                    const SizedBox(height: 12),
                                    copy,
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: SizedBox(
                                      height: 210,
                                      child: image,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 6,
                                    child: copy,
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalFeatureSlide(_Feature f) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 820;

        final heroImage = ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: _HoverImage(
            imageUrl: f.imageUrl,
            height: isCompact ? 220 : 340,
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: heroImage,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              f.title,
              style: const TextStyle(
                color: onSurface,
                fontSize: isCompact ? 30 : 42,
                fontWeight: FontWeight.w800,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              f.copy,
              style: const TextStyle(
                color: onSurfaceVariant,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        );
      },
    );
  }

  double cardHeightForBody(BoxConstraints c) =>
      math.min(380.0, c.maxHeight.isFinite ? c.maxHeight : 380.0);

  // ============================================================
  // NORMAL SECTIONS AFTER THE FEATURE STACK
  // These sections intentionally use normal scrolling.
  // ============================================================

  Widget _sectionHeading(String eyebrow, String title, String sub) {
    return Column(
      children: [
        Text(eyebrow, style: TextStyle(color: secondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.6)),
        const SizedBox(height: 8),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(color: onSurface, fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: onSurfaceVariant, fontSize: 14.5, height: 1.55)),
        ),
      ],
    );
  }

  Widget _buildShowcaseSection() {
    return Container(
      key: showcaseKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 900;
              final deck = _buildCommandDeck();
              final points = _buildShowcasePoints();
              if (stacked) {
                return Column(children: [deck, const SizedBox(height: 32), points]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: deck),
                  const SizedBox(width: 40),
                  Expanded(flex: 5, child: points),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      key: pricingKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              _sectionHeading('Transparent Economics', 'Predictable Plans For Scaling Organizations',
                  'No hidden implementation penalties. Switch between monthly agility or annual savings whenever your scale demands.'),
              const SizedBox(height: 44),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 900;
                  final starter = _pricingTile(
                    tag: 'EARLY STAGE', plan: 'Starter Core', price: '₹0', period: '/ month',
                    desc: 'Foundational inventory and checkout tooling for nascent operations finding market rhythm.',
                    features: const [('Up to 250 orders/month', true), ('Single warehouse location', true), ('Basic revenue analytics', true), ('Multi-user permission matrix', false)],
                    recommended: false, ctaLabel: 'Deploy Starter',
                  );
                  final pro = _pricingTile(
                    tag: 'GROWTH ENGINES', plan: 'Professional', price: '₹999', period: '/ month',
                    desc: 'High-precision infrastructure designed for fast-expanding enterprises with multiple channels.',
                    features: const [('Unlimited daily transactions', true), ('Multi-warehouse inventory sync', true), ('Predictive stockout alerts', true), ('Complete CRM & Vendor automation', true)],
                    recommended: true, ctaLabel: 'Activate Professional',
                  );
                  final enterprise = _pricingTile(
                    tag: 'GLOBAL OPERATIONS', plan: 'Custom Matrix', price: 'Custom', period: '',
                    desc: 'Bespoke SLA deployment with dedicated database instances, custom SSO, and dedicated engineering.',
                    features: const [('Dedicated low-latency tenant cluster', true), ('Enterprise ERP bi-directional sync', true), ('Custom regulatory compliance reports', true), ('24/7 dedicated solutions engineer', true)],
                    recommended: false, ctaLabel: 'Contact Advisory',
                  );
                  if (stacked) return Column(children: [starter, const SizedBox(height: 22), pro, const SizedBox(height: 22), enterprise]);
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: starter),
                        const SizedBox(width: 20),
                        Expanded(child: pro),
                        const SizedBox(width: 20),
                        Expanded(child: enterprise),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      key: aboutKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: surfaceContainer.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(28)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 900;
                final image = _buildAboutImage();
                final content = _buildAboutContent();
                if (stacked) return Column(children: [image, const SizedBox(height: 40), content]);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Expanded(child: image), const SizedBox(width: 48), Expanded(child: content)],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutImage() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _HoverImage(
            imageUrl: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=1200&q=80',
            height: 400,
          ),
        ),
        Positioned(
          bottom: -20, right: -16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surfaceContainerHighest.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Icon(Icons.military_tech, color: secondary, size: 32),
              const SizedBox(width: 10),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ISO-27001 Certified', style: TextStyle(color: onSurface, fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Bank-Grade Data Encryption', style: TextStyle(color: onSurfaceVariant, fontSize: 11)),
              ]),
            ]),
          ),
        ),
      ],
    );
  }

  // Retained for the alternate stacked landing-page composition.
  // ignore: unused_element
  Widget _stackedShowcaseCard(int index, int total, double progress) {
    return _stackCardShell(
      accent: secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stackHeader(icon: Icons.dashboard_customize, accent: secondary, title: 'Enterprise Command Deck', tag: 'SHOWCASE', index: index, total: total),
          Expanded(
            child: Opacity(
              opacity: (1 - progress * 1.6).clamp(0.0, 1.0),
              child: Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 900;
                        final deck = _buildCommandDeck();
                        final points = _buildShowcasePoints();
                        if (stacked) return Column(children: [deck, const SizedBox(height: 28), points]);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: deck),
                            const SizedBox(width: 36),
                            Expanded(flex: 5, child: points),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandDeck() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: surfaceContainerHigh.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.circular(8)),
                child: const Text('Monthly', style: TextStyle(color: onSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                child: const Text('Annual', style: TextStyle(color: onSurfaceVariant, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 520 ? 4 : 2;
              final metrics = [
                ('Gross GMV', '₹1,45,200', onSurface),
                ('Live Orders', '248', secondary),
                ('Accounts', '1,248', primary),
                ('SKU Catalog', '486', tertiary),
              ];
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: metrics
                    .map((m) => SizedBox(
                          width: (constraints.maxWidth - (cols - 1) * 12) / cols,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: surfaceContainerHighest.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.$1, style: const TextStyle(color: onSurfaceVariant, fontSize: 10)),
                                const SizedBox(height: 4),
                                Text(m.$2, style: TextStyle(color: m.$3, fontSize: 17, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          _progressLine('Enterprise Revenue Target (Q3)', 0.88, '88.4% Achieved', secondary),
          const SizedBox(height: 12),
          _progressLine('Warehouse Capacity Fulfillment', 0.64, '64.2% Allocated', primary),
          const SizedBox(height: 12),
          _progressLine('Direct Supplier SLA Performance', 0.96, '96.8% Compliance', tertiary),
        ],
      ),
    );
  }

  Widget _progressLine(String label, double value, String note, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: onSurfaceVariant, fontSize: 12)),
            Text(note, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 10,
            color: surfaceContainerLowest,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(colors: [color.withValues(alpha: 0.5), color]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShowcasePoints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Built For Better, Rapid Decisions',
            style: TextStyle(color: onSurface, fontSize: 24, fontWeight: FontWeight.bold, height: 1.15)),
        const SizedBox(height: 10),
        const Text(
          'Run your company on live figures rather than delayed spreadsheets. Codexia synthesizes operational noise into strategic signal.',
          style: TextStyle(color: onSurfaceVariant, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 18),
        _showcasePoint(Icons.visibility, 'Complete Transparency',
            'Instant drill-down from enterprise-level cash aggregates to single invoices or inventory shelf bins.', secondary),
        const SizedBox(height: 10),
        _showcasePoint(Icons.bolt, 'High-Velocity Operations',
            'Pre-built procedural triggers eliminate approval bottlenecks across multi-department handoffs.', primary),
        const SizedBox(height: 10),
        _showcasePoint(Icons.auto_graph, 'Compounding Growth Velocity',
            'Automated reordering calculations prevent revenue stockouts and maximize working capital efficiency.', tertiary),
        const SizedBox(height: 18),
        _GoldButton(label: 'Explore Codexia Matrix', onPressed: () => _scrollTo(pricingKey), icon: Icons.east),
      ],
    );
  }

  Widget _showcasePoint(IconData icon, String title, String copy, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: surfaceContainerHigh.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: onSurface, fontSize: 14.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(copy, style: const TextStyle(color: onSurfaceVariant, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Retained for the alternate stacked landing-page composition.
  // ignore: unused_element
  Widget _stackedPricingCard(int index, int total, double progress) {
    return _stackCardShell(
      accent: secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stackHeader(icon: Icons.payments, accent: secondary, title: 'Predictable Plans For Scaling Orgs', tag: 'PRICING', index: index, total: total),
          Expanded(
            child: Opacity(
              opacity: (1 - progress * 1.6).clamp(0.0, 1.0),
              child: Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 900;
                        final starter = _pricingTile(
                          tag: 'EARLY STAGE',
                          plan: 'Starter Core',
                          price: '₹0',
                          period: '/ month',
                          desc: 'Foundational inventory and checkout tooling for nascent operations.',
                          features: const [('Up to 250 orders/month', true), ('Single warehouse location', true), ('Basic revenue analytics', true), ('Multi-user permissions', false)],
                          recommended: false,
                          ctaLabel: 'Deploy Starter',
                        );
                        final pro = _pricingTile(
                          tag: 'GROWTH ENGINES',
                          plan: 'Professional',
                          price: '₹999',
                          period: '/ month',
                          desc: 'High-precision infrastructure for fast-expanding enterprises.',
                          features: const [('Unlimited daily transactions', true), ('Multi-warehouse inventory sync', true), ('Predictive stockout alerts', true), ('CRM & Vendor automation', true)],
                          recommended: true,
                          ctaLabel: 'Activate Professional',
                        );
                        final enterprise = _pricingTile(
                          tag: 'GLOBAL OPERATIONS',
                          plan: 'Custom Matrix',
                          price: 'Custom',
                          period: '',
                          desc: 'Bespoke SLA deployment with dedicated infrastructure and engineering.',
                          features: const [('Dedicated tenant cluster', true), ('Enterprise ERP bi-directional sync', true), ('Custom compliance reports', true), ('24/7 solutions engineer', true)],
                          recommended: false,
                          ctaLabel: 'Contact Advisory',
                        );
                        if (stacked) {
                          return Column(children: [starter, const SizedBox(height: 18), pro, const SizedBox(height: 18), enterprise]);
                        }
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: starter),
                              const SizedBox(width: 18),
                              Expanded(child: pro),
                              const SizedBox(width: 18),
                              Expanded(child: enterprise),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pricingTile({
    required String tag,
    required String plan,
    required String price,
    required String period,
    required String desc,
    required List<(String, bool)> features,
    required bool recommended,
    required String ctaLabel,
  }) {
    final selected = _selectedPlan == plan;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: (selected || recommended) ? surfaceContainerHighest.withValues(alpha: 0.92) : surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: recommended ? Border.all(color: secondary, width: 2) : null,
        boxShadow: recommended ? [BoxShadow(color: secondary.withValues(alpha: 0.15), blurRadius: 26)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recommended)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.circular(20)),
              child: const Text('RECOMMENDED', style: TextStyle(color: onSecondary, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          Text(tag, style: TextStyle(color: recommended ? secondary : onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 5),
          Text(plan, style: const TextStyle(color: onSurface, fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: TextStyle(color: recommended ? secondary : onSurface, fontSize: price.length > 5 ? 24 : 32, fontWeight: FontWeight.w800)),
              if (period.isNotEmpty) ...[const SizedBox(width: 4), Text(period, style: const TextStyle(color: onSurfaceVariant, fontSize: 13))],
            ],
          ),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(color: onSurfaceVariant, fontSize: 12.5, height: 1.5)),
          const SizedBox(height: 14),
          for (final f in features)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(f.$2 ? Icons.check_circle : Icons.cancel, color: f.$2 ? secondary : outlineVariant, size: 15),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f.$1, style: TextStyle(color: f.$2 ? onSurface : onSurfaceVariant, fontSize: 12))),
                ],
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: recommended
                ? _GoldButton(label: ctaLabel, onPressed: () => _selectPlan(plan), fullWidth: true)
                : _OutlineButton(label: ctaLabel, onPressed: () => _selectPlan(plan)),
          ),
        ],
      ),
    );
  }

  // Retained for the alternate stacked landing-page composition.
  // ignore: unused_element
  Widget _stackedAboutCard(int index, int total, double progress) {
    return _stackCardShell(
      accent: tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stackHeader(icon: Icons.military_tech, accent: tertiary, title: 'Engineered For Clarity', tag: 'ABOUT US', index: index, total: total),
          Expanded(
            child: Opacity(
              opacity: (1 - progress * 1.6).clamp(0.0, 1.0),
              child: Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 900;
                        final image = ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _HoverImage(
                            imageUrl: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=1200&q=80',
                            height: stacked ? 220 : 340,
                          ),
                        );
                        final content = _buildAboutContent();
                        if (stacked) return Column(children: [image, const SizedBox(height: 24), content]);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: image),
                            const SizedBox(width: 44),
                            Expanded(child: content),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Engineered To Make Management Intuitive',
            style: TextStyle(color: onSurface, fontSize: 24, fontWeight: FontWeight.bold, height: 1.15)),
        const SizedBox(height: 10),
        const Text(
          'Codexia was founded with a singular conviction: operational friction is the silent killer of '
          'compounding enterprise value. We replace cumbersome modular ERPs with a unified command structure.',
          style: TextStyle(color: onSurfaceVariant, fontSize: 13.5, height: 1.6),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: const [
            _AboutCheck('Ultra-low friction UI'),
            _AboutCheck('Modern microservices backbone'),
            _AboutCheck('Actionable diagnostic telemetry'),
            _AboutCheck('Multi-device real-time sync'),
          ],
        ),
        const SizedBox(height: 20),
        _GoldButton(label: 'Onboard Your Enterprise', onPressed: _goToSignUp, icon: Icons.bolt, large: true),
      ],
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 900 ? 4 : (constraints.maxWidth >= 560 ? 2 : 1);
                  final blocks = [
                    _footerBrand(),
                    _footerColumn('Platform', ['Enterprise Core', 'Interactive Demos', 'Workflow Matrix', 'Deployment Tiers'],
                        [featuresKey, showcaseKey, featuresKey, pricingKey]),
                    _footerColumn('Company', ['Our Vision', 'Security Standards', 'Executive Board', 'Careers'],
                        [aboutKey, aboutKey, aboutKey, aboutKey]),
                    _footerOperations(),
                  ];
                  return Wrap(
                    spacing: 32,
                    runSpacing: 32,
                    children: blocks
                        .map((b) => SizedBox(width: (constraints.maxWidth - (columns - 1) * 32) / columns, child: b))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Divider(color: outlineVariant, height: 1),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 12,
                children: [
                  const Text('© 2026 Codexia Systems Inc. All rights reserved.',
                      style: TextStyle(color: onSurfaceVariant, fontSize: 12)),
                  Wrap(
                    spacing: 20,
                    children: const [
                      Text('Terms of Service', style: TextStyle(color: onSurfaceVariant, fontSize: 12)),
                      Text('Privacy Framework', style: TextStyle(color: onSurfaceVariant, fontSize: 12)),
                      Text('System Status', style: TextStyle(color: onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWordmark(),
        const SizedBox(height: 14),
        const Text(
          'The smart business management platform engineered for executive clarity, automated operations, and complete procedural command.',
          style: TextStyle(color: onSurfaceVariant, fontSize: 12.5, height: 1.6),
        ),
      ],
    );
  }

  Widget _footerColumn(String title, List<String> items, List<GlobalKey> keys) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: onSurface, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
        const SizedBox(height: 12),
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _scrollTo(keys[i]),
                child: Text(items[i], style: const TextStyle(color: onSurfaceVariant, fontSize: 12.5)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _footerOperations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Operations', style: TextStyle(color: onSurface, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: surfaceContainerHigh, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _PulsingDot(color: tertiary),
              const SizedBox(width: 6),
              const Text('All Nodes Operational', style: TextStyle(color: onSurfaceVariant, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text('Global real-time data compliance and low-latency synchronization nodes active.',
            style: TextStyle(color: onSurfaceVariant, fontSize: 12, height: 1.5)),
      ],
    );
  }
}

// ============================================================
// Supporting data class
// ============================================================


// ============================================================
// FLOATING CODEXIA HERO ARTWORK
// Uses the exact supplied hero image as the visual itself.
// The artwork floats, breathes and tilts gently with the mouse.
// Invisible hit-zones preserve the two CTA actions printed
// inside the artwork without changing the image visually.
// ============================================================

class _FloatingCodexiaHero extends StatefulWidget {
  final VoidCallback onStartTrial;
  final VoidCallback onExploreFeatures;

  const _FloatingCodexiaHero({
    required this.onStartTrial,
    required this.onExploreFeatures,
  });

  @override
  State<_FloatingCodexiaHero> createState() =>
      _FloatingCodexiaHeroState();
}

class _FloatingCodexiaHeroState extends State<_FloatingCodexiaHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double _mouseX = 0;
  double _mouseY = 0;

  static const double _artAspectRatio = 1012 / 510;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(PointerEvent event) {
    final renderObject = context.findRenderObject();

    if (renderObject is! RenderBox) {
      return;
    }

    final size = renderObject.size;

    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final x = (event.localPosition.dx / size.width) - 0.5;
    final y = (event.localPosition.dy / size.height) - 0.5;

    setState(() {
      _mouseX = x.clamp(-0.5, 0.5);
      _mouseY = y.clamp(-0.5, 0.5);
    });
  }

  void _resetHover() {
    if (!mounted) {
      return;
    }

    setState(() {
      _mouseX = 0;
      _mouseY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 650,
      ),
      padding: const EdgeInsets.fromLTRB(
        20,
        30,
        20,
        46,
      ),
      color: const Color(0xFF00142A),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool desktop = constraints.maxWidth >= 850;

            final double maxArtworkWidth = constraints.maxWidth >= 1400
                ? 1180
                : constraints.maxWidth >= 1000
                    ? constraints.maxWidth * 0.97
                    : constraints.maxWidth >= 650
                        ? constraints.maxWidth * 0.99
                        : constraints.maxWidth;

            final double artworkWidth =
                math.min(maxArtworkWidth, constraints.maxWidth);

            final double artworkHeight =
                artworkWidth / _artAspectRatio;

            return MouseRegion(
              cursor: SystemMouseCursors.basic,
              onHover: desktop ? _handleHover : null,
              onExit: (_) {
                if (desktop) {
                  _resetHover();
                }
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final phase =
                      _controller.value * math.pi * 2;

                  final floatY =
                      math.sin(phase) * (desktop ? 12.0 : 7.0);

                  final floatX =
                      math.cos(phase * 0.72) * (desktop ? 3.5 : 1.5);

                  final breathe =
                      1.04 + (math.sin(phase) * 0.0065);

                  final autoRotation =
                      math.sin(phase * 0.55) * 0.0022;

                  final pointerX =
                      desktop ? _mouseX * 18 : 0.0;

                  final pointerY =
                      desktop ? _mouseY * 10 : 0.0;

                  return Transform.translate(
                    offset: Offset(
                      floatX + pointerX,
                      floatY + pointerY,
                    ),
                    child: Transform.scale(
                      scale: breathe,
                      alignment: Alignment.center,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateX(
                            desktop
                                ? -_mouseY * 0.025
                                : 0,
                          )
                          ..rotateY(
                            desktop
                                ? _mouseX * 0.025
                                : 0,
                          )
                          ..rotateZ(autoRotation),
                        child: child,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: artworkWidth,
                  height: artworkHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Soft glow only. No border, crop or filter is applied,
                      // so the hero image itself remains visually unchanged.
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3AA8FF)
                                    .withValues(alpha: 0.15),
                                blurRadius: 52,
                                spreadRadius: 2,
                                offset: const Offset(0, 18),
                              ),
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.38),
                                blurRadius: 34,
                                offset: const Offset(0, 22),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Image.asset(
                        'assets/images/codexia_hero.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        filterQuality: FilterQuality.high,
                      ),

                      // Invisible click target over "Start Your Free Trial".
                      Positioned(
                        left: artworkWidth * 0.382,
                        top: artworkHeight * 0.746,
                        width: artworkWidth * 0.135,
                        height: artworkHeight * 0.083,
                        child: _InvisibleHeroAction(
                          tooltip: 'Start Your Free Trial',
                          onTap: widget.onStartTrial,
                        ),
                      ),

                      // Invisible click target over "Explore Features".
                      Positioned(
                        left: artworkWidth * 0.523,
                        top: artworkHeight * 0.746,
                        width: artworkWidth * 0.135,
                        height: artworkHeight * 0.083,
                        child: _InvisibleHeroAction(
                          tooltip: 'Explore Features',
                          onTap: widget.onExploreFeatures,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InvisibleHeroAction extends StatefulWidget {
  final String tooltip;
  final VoidCallback onTap;

  const _InvisibleHeroAction({
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_InvisibleHeroAction> createState() =>
      _InvisibleHeroActionState();
}

class _InvisibleHeroActionState extends State<_InvisibleHeroAction> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            _hovering = true;
          });
        },
        onExit: (_) {
          setState(() {
            _hovering = false;
          });
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: _hovering
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFDBA5A)
                            .withValues(alpha: 0.20),
                        blurRadius: 18,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature {
  final String title;
  final String copy;
  final String imageUrl;
  final IconData icon;
  final Color accent;
  const _Feature(this.title, this.copy, this.imageUrl, this.icon, this.accent);
}

// ============================================================
// STICKY STACKING CARD DELEGATE
// Pinned SliverPersistentHeader delegates naturally stack: as one
// header shrinks toward minExtent it stays pinned at the top while
// the next pinned header slides up and covers it — producing the
// "overlapping cards" scroll effect with zero manual offset math.
// ============================================================

class _AnimatedFeatureBackground extends StatefulWidget {
  const _AnimatedFeatureBackground({
    required this.accent,
    required this.index,
    required this.progress,
    required this.child,
  });

  final Color accent;
  final int index;
  final double progress;
  final Widget child;

  @override
  State<_AnimatedFeatureBackground> createState() => _AnimatedFeatureBackgroundState();
}

class _AnimatedFeatureBackgroundState extends State<_AnimatedFeatureBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8 + widget.index * 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        scale: _hovered ? 1.012 : 1,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1 + t * 0.8, -1),
                  end: Alignment(1, 1 - t * 0.8),
                  colors: [
                    _HomePageState.surfaceContainerLowest,
                    Color.lerp(_HomePageState.surfaceContainer, widget.accent, 0.10 + (_hovered ? 0.08 : 0.0))!,
                    _HomePageState.surfaceContainer,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accent.withValues(alpha: _hovered ? 0.28 : 0.10),
                    blurRadius: _hovered ? 34 : 18,
                    spreadRadius: _hovered ? 2 : 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -100 + t * 140,
                    top: 40 + math.sin(t * math.pi) * 80,
                    child: IgnorePointer(
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.accent.withValues(alpha: _hovered ? 0.12 : 0.06),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accent.withValues(alpha: 0.16),
                              blurRadius: 90,
                              spreadRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(child: widget.child),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StackCardDelegate extends SliverPersistentHeaderDelegate {
  _StackCardDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.contentBuilder,
  });

  final double maxHeight;
  final double minHeight;
  final Widget Function(BuildContext context, double progress) contentBuilder;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = (maxHeight - minHeight).clamp(1.0, double.infinity);
    final progress = (shrinkOffset / range).clamp(0.0, 1.0);
    final scale = 1 - progress * 0.04;
    final radius = 0.0 + progress * 26.0;

    final card = Transform.scale(
      alignment: Alignment.topCenter,
      scale: scale,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.35 + progress * 0.15), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: maxHeight,
          width: double.infinity,
          child: contentBuilder(context, progress),
        ),
      ),
    );

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: 0,
        maxHeight: maxHeight,
        child: card,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StackCardDelegate oldDelegate) {
    return oldDelegate.maxHeight != maxHeight || oldDelegate.minHeight != minHeight;
  }
}

// ============================================================
// AURORA BACKGROUND — approximates the animated WebGL noise
// shader from the HTML using drifting blurred gradient blobs.
// ============================================================

class _AuroraBackground extends StatefulWidget {
  const _AuroraBackground();

  @override
  State<_AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<_AuroraBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: const BoxDecoration(color: _HomePageState.background),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _AuroraPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t;
  _AuroraPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    void blob(Offset center, double radius, Color color) {
      final paint = Paint()
        ..shader = RadialGradient(colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)])
            .createShader(Rect.fromCircle(center: center, radius: radius))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
      canvas.drawCircle(center, radius, paint);
    }

    final w = size.width;
    final h = size.height;
    final angle = t * 2 * math.pi;

    blob(Offset(w * 0.2 + math.sin(angle) * 60, h * 0.25 + math.cos(angle) * 40), w * 0.32, const Color(0xFF174064));
    blob(Offset(w * 0.8 + math.cos(angle * 0.8) * 50, h * 0.65 + math.sin(angle * 0.8) * 50), w * 0.36,
        const Color(0xFFD99A3E));
    blob(Offset(w * 0.55 + math.sin(angle * 1.3) * 70, h * 0.15 + math.cos(angle * 1.3) * 30), w * 0.28,
        const Color(0xFF0D3154));
    blob(Offset(w * 0.35 + math.cos(angle * 0.6) * 40, h * 0.85 + math.sin(angle * 0.6) * 40), w * 0.30,
        const Color(0xFF1F3A59));
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) => oldDelegate.t != t;
}

// ============================================================
// TOAST
// ============================================================

class _ToastNotification extends StatefulWidget {
  final String title;
  final String message;
  const _ToastNotification({required this.title, required this.message});

  @override
  State<_ToastNotification> createState() => _ToastNotificationState();
}

class _ToastNotificationState extends State<_ToastNotification> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: FadeTransition(
        opacity: _controller,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOut),
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _HomePageState.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(color: _HomePageState.secondary, shape: BoxShape.circle),
                    child: const Icon(Icons.verified, color: _HomePageState.onSecondary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: const TextStyle(color: _HomePageState.onSurface, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(widget.message, style: const TextStyle(color: _HomePageState.secondary, fontSize: 12)),
                    ],
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

// ============================================================
// NAV LINK
// ============================================================

class _NavLink extends StatefulWidget {
  const _NavLink({required this.title, required this.onPressed});
  final String title;
  final VoidCallback onPressed;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: _hovered ? _HomePageState.secondary : _HomePageState.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                child: Text(widget.title),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 2,
                width: _hovered ? 20 : 0,
                decoration: BoxDecoration(color: _HomePageState.secondary, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BUTTONS
// ============================================================

class _GoldButton extends StatefulWidget {
  const _GoldButton({required this.label, required this.onPressed, this.icon, this.large = false, this.fullWidth = false});
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool large;
  final bool fullWidth;

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final translate = _pressed ? 3.0 : (_hovered ? -2.0 : 0.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          transform: Matrix4.translationValues(0, translate, 0),
          width: widget.fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: widget.large ? 26 : 20, vertical: widget.large ? 17 : 13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_HomePageState.secondaryFixed, _HomePageState.secondary],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: _HomePageState.secondaryContainer, offset: Offset(0, _pressed ? 1 : 4)),
              if (_hovered) BoxShadow(color: _HomePageState.secondary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.label,
                  style: TextStyle(
                      color: _HomePageState.onSecondary, fontWeight: FontWeight.bold, fontSize: widget.large ? 15 : 13.5)),
              if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(widget.icon, size: 18, color: _HomePageState.onSecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatefulWidget {
  const _GhostButton({required this.label, required this.onPressed}) : icon = null;
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  State<_GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<_GhostButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: _hovered ? _HomePageState.surfaceBright : _HomePageState.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label,
                  style: TextStyle(
                      color: _hovered ? _HomePageState.secondary : _HomePageState.onSurface, fontWeight: FontWeight.w600)),
              if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(widget.icon, size: 18, color: _HomePageState.secondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatefulWidget {
  const _OutlineButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? _HomePageState.surfaceBright : _HomePageState.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(widget.label, style: const TextStyle(color: _HomePageState.onSurface, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ============================================================
// SMALL HELPERS
// ============================================================

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_controller),
      child: Container(width: 8, height: 8, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
    );
  }
}

class _CountUp extends StatelessWidget {
  const _CountUp({required this.target, required this.suffix, required this.accent});
  final int target;
  final String suffix;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target.toDouble()),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value.toInt().toString(),
                style: const TextStyle(color: _HomePageState.onSurface, fontSize: 30, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: suffix, style: TextStyle(color: accent, fontSize: 30, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}

class _AboutCheck extends StatelessWidget {
  const _AboutCheck(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check, color: _HomePageState.secondary, size: 18),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: _HomePageState.onSurface, fontSize: 13.5, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ============================================================
// TILT CARD — cursor-driven 3D tilt, matching the HTML's
// `.tilt-card` mousemove behaviour. Used for Hero/Stats only —
// the stacking cards get their own shrink/scale animation.
// ============================================================

class _TiltCard extends StatefulWidget {
  const _TiltCard({required this.child});
  final Widget child;

  @override
  State<_TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<_TiltCard> {
  double _rotateX = 0;
  double _rotateY = 0;
  bool _hovered = false;

  void _onHover(PointerHoverEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(event.position);
    final size = box.size;
    if (size.width == 0 || size.height == 0) return;
    final dx = (local.dx / size.width) - 0.5;
    final dy = (local.dy / size.height) - 0.5;
    setState(() {
      _rotateY = dx * 0.12;
      _rotateX = -dy * 0.12;
    });
  }

  void _reset() {
    setState(() {
      _hovered = false;
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onHover: _onHover,
      onExit: (_) => _reset(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateX(_rotateX)
          ..rotateY(_rotateY)
          ..translateByDouble(0.0, _hovered ? -4.0 : 0.0, 0.0, 1.0),
        child: widget.child,
      ),
    );
  }
}

class _HoverScale extends StatefulWidget {
  const _HoverScale({required this.child}) : scale = 1.05;
  final Widget child;
  final double scale;

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(duration: const Duration(milliseconds: 180), scale: _hovered ? widget.scale : 1, child: widget.child),
    );
  }
}

class _HoverImage extends StatefulWidget {
  const _HoverImage({
    required this.imageUrl,
    this.height,
  });

  final String imageUrl;
  final double? height;

  @override
  State<_HoverImage> createState() => _HoverImageState();
}

class _HoverImageState extends State<_HoverImage> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      widget.imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          color: _HomePageState.surfaceContainerHigh,
          alignment: Alignment.center,
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: _HomePageState.secondary,
              value: loadingProgress.expectedTotalBytes == null
                  ? null
                  : loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: _HomePageState.surfaceContainerHigh,
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                color: _HomePageState.onSurfaceVariant,
                size: 42,
              ),
              SizedBox(height: 10),
              Text(
                'Unable to load image',
                style: TextStyle(
                  color: _HomePageState.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );

    final content = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: ClipRect(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          scale: _hovered ? 1.06 : 1,
          child: image,
        ),
      ),
    );

    if (widget.height != null) {
      return SizedBox(
        width: double.infinity,
        height: widget.height,
        child: content,
      );
    }

    return SizedBox.expand(child: content);
  }
}


// ============================================================
// CENTER HERO FLOATING ANIMATION
// ============================================================

class _FloatingHeroContent extends StatefulWidget {
  final Widget child;
  const _FloatingHeroContent({required this.child});

  @override
  State<_FloatingHeroContent> createState() => _FloatingHeroContentState();
}

class _FloatingHeroContentState extends State<_FloatingHeroContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3800))..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
    _scaleAnimation = Tween<double>(begin: 0.995, end: 1.005).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(top: -100, child: Container(width: 360, height: 360, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFDBA5A).withValues(alpha: 0.045), boxShadow: [BoxShadow(color: const Color(0xFFFDBA5A).withValues(alpha: 0.12), blurRadius: 100, spreadRadius: 30)]))),
                Positioned(left: -100, bottom: 20, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF4EDEA3).withValues(alpha: 0.035), boxShadow: [BoxShadow(color: const Color(0xFF4EDEA3).withValues(alpha: 0.08), blurRadius: 80, spreadRadius: 20)]))),
                Positioned(right: -100, top: 80, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFAAC9F4).withValues(alpha: 0.035), boxShadow: [BoxShadow(color: const Color(0xFFAAC9F4).withValues(alpha: 0.08), blurRadius: 90, spreadRadius: 20)]))),
                child!,
              ],
            ),
          ),
        );
      },
    );
  }
}

// Retained for the alternate hero composition.
// ignore: unused_element
class _HeroStatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroStatusItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFFDBA5A), size: 16),
        const SizedBox(width: 7),
        Text(label, style: const TextStyle(color: Color(0xFFC3C6CF), fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
