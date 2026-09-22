import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/gestures.dart';

import '../auth/login_page.dart';
import '../auth/signup_page.dart';
import '../../widgets/codexia_logo.dart';

/// ============================================================
/// CODEXIA — dark navy / gold "executive glass" home page.
/// Features use an APPLE INVITES-STYLE SPRING COVER-FLOW CAROUSEL that is
/// SCROLL-DRIVEN: the section pins to the screen, every scroll step brings
/// the next card to the centre, and after the last card the Showcase section
/// scrolls in. A debounced SNAP-TO-CARD settles the page on a card centre
/// when scrolling pauses.
/// Performance rewrite: scrolling no longer rebuilds the whole page,
/// the navbar avoids a full-width live blur, the hero pauses off-screen,
/// heavy sections are repaint-isolated, and feature images are downsized.
/// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  String? _selectedPlan;

  // Only the navbar listens to this value. Scrolling no longer calls
  // setState() on the entire HomePage for every pixel.
  final ValueNotifier<bool> _scrolledPastTopNotifier =
      ValueNotifier<bool>(false);

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

  // ---- Scroll-driven feature carousel ----------------------------------
  /// Scroll distance (px) spent on each card. Smaller = faster card flips.
  static const double _featureStepPx = 320;

  /// Snap-to-card tuning.
  static const Duration _snapDelay = Duration(milliseconds: 120);
  static const Duration _snapDuration = Duration(milliseconds: 280);

  /// Fraction of a card step you must scroll (in your scroll direction)
  /// before the snap advances to the next/previous card instead of falling
  /// back to the current one. 0.2 means one mouse-wheel notch moves one card.
  static const double _snapIntent = 0.2;

  static const List<_Feature> _features = [
    _Feature(
      'Sales & CRM Matrix',
      'Direct pipeline tracking, automated client tiering, lead scoring, and instant customer lifecycle visibility without disconnected third-party integrations.',
      'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=900&q=75',
      Icons.point_of_sale,
      secondary,
    ),
    _Feature(
      'Purchase & Vendor Orchestration',
      'Automate multi-tier purchase orders, supplier evaluation metrics, dispatch tracking, and fulfillment reconciliation with zero latency.',
      'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=900&q=75',
      Icons.local_shipping,
      primary,
    ),
    _Feature(
      'Real-Time Inventory Control',
      'Multi-warehouse inventory routing, proactive low-stock predictive alarms, barcode telemetry, and automated replenishment dispatch.',
      'https://images.unsplash.com/photo-1553413077-190dd305871c?w=900&q=75',
      Icons.inventory_2,
      tertiary,
    ),
    _Feature(
      'Financial Telemetry & Treasury',
      'Automated P&L ledger mapping, cash burn analysis, margin trends, and instant export-ready regulatory balance sheets.',
      'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=900&q=75',
      Icons.account_balance_wallet,
      secondary,
    ),
  ];

  double get _featureScrollDistance => _features.length * _featureStepPx;

  /// Which card is currently in focus. Only the carousel listens to this.
  final ValueNotifier<int> _featureIndexNotifier = ValueNotifier<int>(0);

  Timer? _snapTimer;
  double? _lastSettledPixels;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final pastTop = _scrollController.position.pixels > 20;

    if (_scrolledPastTopNotifier.value != pastTop) {
      _scrolledPastTopNotifier.value = pastTop;
    }

    _updateFeatureIndex();
  }

  /// Scroll offset at which the features section becomes pinned.
  double? _featuresPinStart() {
    final ctx = featuresKey.currentContext;
    if (ctx == null) return null;
    final ro = ctx.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return null;
    final viewport = RenderAbstractViewport.maybeOf(ro);
    if (viewport == null) return null;
    return viewport.getOffsetToReveal(ro, 0.0).offset;
  }

  void _updateFeatureIndex() {
    final start = _featuresPinStart();
    if (start == null) return;

    final progress =
        ((_scrollController.position.pixels - start) / _featureScrollDistance)
            .clamp(0.0, 1.0)
            .toDouble();

    final index = math.min(
      _features.length - 1,
      (progress * _features.length).floor(),
    );

    if (_featureIndexNotifier.value != index) {
      _featureIndexNotifier.value = index;
    }
  }

  /// Used when a side card or a dot is tapped: scroll to that card's slot.
  void _scrollToFeature(int index) {
    final start = _featuresPinStart();
    if (start == null || !_scrollController.hasClients) return;

    _scrollController.animateTo(
      start + (index + 0.5) * _featureStepPx,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    );
  }

  // ---- Snap-to-card ------------------------------------------------------

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification) {
      // Still moving (wheel tick, drag, fling, animation): don't snap yet.
      _snapTimer?.cancel();
    } else if (notification is ScrollEndNotification) {
      // Scrolling has stopped. Wait a moment in case another wheel tick
      // follows, then settle on a card.
      _snapTimer?.cancel();
      _snapTimer = Timer(_snapDelay, _snapToNearestFeature);
    }

    return false;
  }

  void _snapToNearestFeature() {
    if (!mounted || !_scrollController.hasClients) return;

    final start = _featuresPinStart();
    if (start == null) return;

    final pixels = _scrollController.position.pixels;
    final rel = pixels - start;

    final previous = _lastSettledPixels;
    _lastSettledPixels = pixels;

    // Only snap while the features section is actually pinned.
    if (rel <= 0 || rel >= _featureScrollDistance) return;

    // x is measured in "card centres": card i is centred when x == i.
    final x = rel / _featureStepPx - 0.5;

    // Direction of the last gesture (ignore tiny drifts).
    double direction = 0;
    if (previous != null) {
      final moved = pixels - previous;
      if (moved.abs() > 8) direction = moved.sign;
    }

    // Scrolling forward: advance once you are past _snapIntent of a step.
    // Scrolling backward: retreat once you are past _snapIntent of a step.
    final int index;
    if (direction > 0) {
      index = (x + (1 - _snapIntent)).floor();
    } else if (direction < 0) {
      index = (x - (1 - _snapIntent)).ceil();
    } else {
      index = x.round();
    }

    // Beyond the first/last card means "leave the section": let the user
    // scroll out freely instead of pulling them back.
    if (index < 0 || index >= _features.length) return;

    final target = start + (index + 0.5) * _featureStepPx;
    if ((target - pixels).abs() < 1) return;

    _scrollController.animateTo(
      target,
      duration: _snapDuration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _snapTimer?.cancel();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _scrolledPastTopNotifier.dispose();
    _featureIndexNotifier.dispose();
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
                  // LayoutBuilder gives us the scroll viewport height (only
                  // rebuilds on resize, never per scroll frame) so the pinned
                  // features section can be exactly one screen tall.
                  child: LayoutBuilder(
                    builder: (context, viewport) {
                      return NotificationListener<ScrollNotification>(
                        onNotification: _handleScrollNotification,
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const ClampingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: RepaintBoundary(child: _buildHeroSection()),
                            ),
                            SliverToBoxAdapter(
                              child: RepaintBoundary(child: _buildStatsSection()),
                            ),
                            // SCROLL-DRIVEN, PINNED FEATURE CAROUSEL
                            ..._buildFeaturesPinnedSlivers(viewport.maxHeight),
                            SliverToBoxAdapter(
                              child: RepaintBoundary(child: _buildShowcaseSection()),
                            ),
                            SliverToBoxAdapter(
                              child: RepaintBoundary(child: _buildPricingSection()),
                            ),
                            SliverToBoxAdapter(
                              child: RepaintBoundary(child: _buildAboutSection()),
                            ),
                            SliverToBoxAdapter(
                              child: RepaintBoundary(child: _buildFooter()),
                            ),
                          ],
                        ),
                      );
                    },
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
    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _scrolledPastTopNotifier,
            builder: (context, scrolledPastTop, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  // Frosted-glass visual without BackdropFilter. A live blur on
                  // a full-width navbar is expensive on Flutter Web while scrolling.
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      surfaceContainerHigh.withValues(
                        alpha: scrolledPastTop ? 0.98 : 0.94,
                      ),
                      surfaceContainer.withValues(
                        alpha: scrolledPastTop ? 0.97 : 0.91,
                      ),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  boxShadow: scrolledPastTop
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : const [],
                ),
                child: child,
              );
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 860) {
                  return _buildMobileNav();
                }

                return _buildDesktopNav();
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -2,
            child: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                double progress = 0;

                if (_scrollController.hasClients) {
                  final position = _scrollController.position;
                  if (position.maxScrollExtent > 0) {
                    progress = (position.pixels / position.maxScrollExtent)
                        .clamp(0.0, 1.0);
                  }
                }

                return FractionallySizedBox(
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: child,
                );
              },
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      secondaryContainer,
                      secondary,
                      secondaryFixed,
                      secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: secondary.withValues(alpha: 0.35),
                      blurRadius: 5,
                    ),
                  ],
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
      scrollController: _scrollController,
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
  // SCROLL-DRIVEN APPLE INVITES-STYLE FEATURE CAROUSEL
  // The section pins to one screen height. An invisible spacer below the
  // pinned header supplies the scroll distance (one step per card).
  // ============================================================

  List<Widget> _buildFeaturesPinnedSlivers(double viewportHeight) {
    final pinHeight = math.max(viewportHeight, 640.0);

    return [
      // Zero-height marker: the "Features" nav link scrolls here (pin start).
      SliverToBoxAdapter(
        child: SizedBox(key: featuresKey, height: 0, width: double.infinity),
      ),
      // Heading scrolls in normally (NOT pinned) so the pinned box below only
      // has to reserve room for the card stack + dots — this is what leaves
      // enough headroom for larger cards without a bottom overflow.
      SliverToBoxAdapter(
        child: RepaintBoundary(
          child: ColoredBox(
            color: background,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: _buildFeaturesHeading(),
                ),
              ),
            ),
          ),
        ),
      ),
      SliverMainAxisGroup(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedStageDelegate(
              height: pinHeight,
              child: RepaintBoundary(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _AuroraBackground(),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: background.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                    _buildFeaturesCarouselSection(pinHeight),
                  ],
                ),
              ),
            ),
          ),
          // The scroll distance the user "spends" on the cards.
          SliverToBoxAdapter(
            child: SizedBox(height: _featureScrollDistance),
          ),
        ],
      ),
    ];
  }

  Widget _buildFeaturesHeading() {
    return Column(
      children: [
        const Text(
          'CORE CAPABILITIES',
          style: TextStyle(
            color: secondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Explore The Codexia Matrix',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: onSurface,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: const Text(
            'Scroll down to bring the next feature into focus.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurfaceVariant,
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesCarouselSection(double pinHeight) {
    return SizedBox(
      height: pinHeight,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: _AppleInvitesFeatureCarousel(
              features: _features,
              indexListenable: _featureIndexNotifier,
              onSelect: _scrollToFeature,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LEGACY SHARED CARD HELPERS
  // Retained only by the alternate Showcase/Pricing/About card
  // compositions later in this file. The active Features section
  // now uses the Apple Invites-style spring carousel above.
  // ============================================================


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

  // ------------------------------------------------------------------
  // Shared solid card shell for retained alternate compositions.
  // ------------------------------------------------------------------

  Widget _stackCardShell({required Color accent, required Widget child}) {
    final radius = BorderRadius.circular(24);
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: surfaceContainer.withValues(alpha: 0.94),
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
        child: ClipRRect(borderRadius: radius, child: child),
      ),
    );
  }


  // ============================================================
  // NORMAL SECTIONS AFTER THE FEATURE CAROUSEL
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
            imageUrl: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=900&q=75',
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
                            imageUrl: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=900&q=75',
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
// PINNED STAGE DELEGATE
// Keeps the features section fixed on screen (one viewport tall)
// while the spacer sliver below it supplies the scroll distance.
// ============================================================

class _PinnedStageDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedStageDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _PinnedStageDelegate oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
}

// ============================================================
// FLOATING CODEXIA HERO ARTWORK
// Uses the exact supplied hero image as the visual itself.
// The artwork floats, breathes and tilts gently with the mouse.
// Invisible hit-zones preserve the two CTA actions printed
// inside the artwork without changing the image visually.
// ============================================================

class _FloatingCodexiaHero extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback onStartTrial;
  final VoidCallback onExploreFeatures;

  const _FloatingCodexiaHero({
    required this.scrollController,
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

  bool _heroAnimationRunning = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    widget.scrollController.addListener(_handleScrollVisibility);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleScrollVisibility();
    });
  }

  @override
  void didUpdateWidget(covariant _FloatingCodexiaHero oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_handleScrollVisibility);
      widget.scrollController.addListener(_handleScrollVisibility);
      _handleScrollVisibility();
    }
  }

  void _handleScrollVisibility() {
    if (!mounted || !widget.scrollController.hasClients) {
      return;
    }

    // Hero is roughly 650px tall. Stop its infinite animation after it has
    // moved far enough off screen so lower sections can scroll without
    // competing for animation/repaint time.
    final shouldRun = widget.scrollController.position.pixels < 850;

    if (shouldRun == _heroAnimationRunning) {
      return;
    }

    _heroAnimationRunning = shouldRun;

    if (shouldRun) {
      _controller.repeat();
    } else {
      _controller.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScrollVisibility);
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
                        filterQuality: FilterQuality.medium,
                      ),

                      // Flutter button replacing the baked-in CTA.
                      Positioned(
                        left: artworkWidth * 0.375,
                        top: artworkHeight * 0.744,
                        width: artworkWidth * 0.145,
                        height: artworkHeight * 0.09,
                        child: _HeroActionButton(
                          label: 'Start Your Free Trial',
                          onTap: widget.onStartTrial,
                          primary: true,
                        ),
                      ),

                      // Flutter button replacing the baked-in CTA.
                      Positioned(
                        left: artworkWidth * 0.525,
                        top: artworkHeight * 0.744,
                        width: artworkWidth * 0.145,
                        height: artworkHeight * 0.09,
                        child: _HeroActionButton(
                          label: 'Explore Features',
                          onTap: widget.onExploreFeatures,
                          primary: false,
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

class _HeroActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _HeroActionButton({
    required this.label,
    required this.onTap,
    required this.primary,
  });

  @override
  State<_HeroActionButton> createState() => _HeroActionButtonState();
}

class _HeroActionButtonState extends State<_HeroActionButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.label,
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
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _hovering ? 1.04 : 1,
            duration: const Duration(milliseconds: 160),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.primary
                      ? [
                          const Color(0xFFFFD78A),
                          const Color(0xFFE89B32),
                        ]
                      : [
                          const Color(0xFF294766),
                          const Color(0xFF132B45),
                        ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.primary
                      ? const Color(0xFFFFE2B4)
                      : const Color(0xFF7C9AB5),
                  width: _hovering ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.primary
                            ? const Color(0xFFFDBA5A)
                            : const Color(0xFF3AA8FF))
                        .withValues(alpha: _hovering ? 0.75 : 0.48),
                    blurRadius: _hovering ? 24 : 16,
                    spreadRadius: _hovering ? 2 : 1,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
// SCROLL-DRIVEN SPRING CAROUSEL
// The active card is fed by [indexListenable] (driven by page scroll).
// Taps on side cards / dots call [onSelect], which scrolls the page,
// so the scroll position and the focused card always stay in sync.
// ============================================================

class _AppleInvitesFeatureCarousel extends StatefulWidget {
  final List<_Feature> features;
  final ValueListenable<int> indexListenable;
  final ValueChanged<int> onSelect;

  const _AppleInvitesFeatureCarousel({
    required this.features,
    required this.indexListenable,
    required this.onSelect,
  });

  @override
  State<_AppleInvitesFeatureCarousel> createState() =>
      _AppleInvitesFeatureCarouselState();
}

class _AppleInvitesFeatureCarouselState
    extends State<_AppleInvitesFeatureCarousel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springController;

  int _activeIndex = 0;
  int _fromIndex = 0;
  int? _hoveredIndex;

  // Keeps the motion continuous when the target changes mid-spring
  // (fast scrolling flips several cards in quick succession).
  final Map<int, _InviteCardVisual> _currentVisuals = {};
  Map<int, _InviteCardVisual>? _startVisuals;

  static const SpringDescription _spring = SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 30,
  );

  int get _count => widget.features.length;

  int _wrap(int value) {
    if (_count == 0) return 0;
    return ((value % _count) + _count) % _count;
  }

  @override
  void initState() {
    super.initState();

    _springController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
      value: 1,
    );

    _activeIndex = _wrap(widget.indexListenable.value);
    _fromIndex = _activeIndex;
    widget.indexListenable.addListener(_handleIndexChanged);
  }

  @override
  void didUpdateWidget(covariant _AppleInvitesFeatureCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.indexListenable != widget.indexListenable) {
      oldWidget.indexListenable.removeListener(_handleIndexChanged);
      widget.indexListenable.addListener(_handleIndexChanged);
    }

    if (_count == 0) {
      _activeIndex = 0;
      _fromIndex = 0;
      return;
    }

    _activeIndex = _wrap(_activeIndex);
    _fromIndex = _wrap(_fromIndex);
  }

  @override
  void dispose() {
    widget.indexListenable.removeListener(_handleIndexChanged);
    _springController.dispose();
    super.dispose();
  }

  void _handleIndexChanged() {
    if (!mounted) return;
    _moveTo(widget.indexListenable.value);
  }

  void _moveTo(int index) {
    if (_count <= 1) return;

    final next = _wrap(index);
    if (next == _activeIndex) return;

    // If a spring is still running, start the new one from where the
    // cards visually are right now instead of jumping back.
    _startVisuals =
        _springController.isAnimating && _currentVisuals.length == _count
            ? Map<int, _InviteCardVisual>.of(_currentVisuals)
            : null;

    setState(() {
      _fromIndex = _activeIndex;
      _activeIndex = next;
    });

    _springController.stop();
    _springController.value = 0;
    _springController.animateWith(SpringSimulation(_spring, 0, 1, 0));
  }

  // Non-circular: scrolling down = deck moves forward, up = back.
  int _relativeSlot(int itemIndex, int activeIndex) {
    final diff = itemIndex - activeIndex;
    if (diff == 0) return 0;
    if (diff == -1) return -1;
    if (diff == 1) return 1;
    return diff < 0 ? -2 : 2;
  }

  _InviteCardVisual _visualForSlot(
    int slot,
    double cardWidth,
  ) {
    switch (slot) {
      case -1:
        return _InviteCardVisual(
          x: -cardWidth * 0.80,
          y: 10,
          rotation: -12 * math.pi / 180,
          scale: 0.90,
          opacity: 0.80,
          depth: 2,
        );
      case 1:
        return _InviteCardVisual(
          x: cardWidth * 0.80,
          y: 10,
          rotation: 12 * math.pi / 180,
          scale: 0.90,
          opacity: 0.80,
          depth: 2,
        );
      case -2:
        return _InviteCardVisual(
          x: -cardWidth * 1.28,
          y: 36,
          rotation: -18 * math.pi / 180,
          scale: 0.82,
          opacity: 0,
          depth: 1,
        );
      case 2:
        return _InviteCardVisual(
          x: cardWidth * 1.28,
          y: 36,
          rotation: 18 * math.pi / 180,
          scale: 0.82,
          opacity: 0,
          depth: 1,
        );
      default:
        return const _InviteCardVisual(
          x: 0,
          y: 0,
          rotation: 0,
          scale: 1,
          opacity: 1,
          depth: 3,
        );
    }
  }

  _InviteCardVisual _lerpVisual(
    _InviteCardVisual a,
    _InviteCardVisual b,
    double t,
  ) {
    return _InviteCardVisual(
      x: _lerpDouble(a.x, b.x, t),
      y: _lerpDouble(a.y, b.y, t),
      rotation: _lerpDouble(a.rotation, b.rotation, t),
      scale: _lerpDouble(a.scale, b.scale, t),
      opacity: _lerpDouble(a.opacity, b.opacity, t),
      depth: t < 0.5 ? a.depth : b.depth,
    );
  }

  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.features.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 620;
        final isTablet = width < 900;

        var cardWidth = isMobile
            ? math.min(300.0, width * 0.76)
            : isTablet
                ? math.min(360.0, width * 0.42)
                : math.min(430.0, width * 0.36);

        var cardHeight = cardWidth * 1.42;

        // Extra headroom so the rotated/offset side cards never clip against
        // the stage box, plus the space the dots row below needs. Both must
        // be subtracted from the available height BEFORE capping cardHeight
        // — otherwise they get added back on afterwards and overflow.
        final stageBuffer = isMobile ? 74.0 : 110.0;
        const dotsRowReserved = 30.0;

        if (constraints.hasBoundedHeight) {
          final maxCardHeight = math.max(
            constraints.maxHeight - stageBuffer - dotsRowReserved,
            300.0,
          );
          if (cardHeight > maxCardHeight) {
            cardHeight = maxCardHeight;
            cardWidth = cardHeight / 1.42;
          }
        }

        final stageHeight = cardHeight + stageBuffer;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              child: SizedBox(
                height: stageHeight,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _springController,
                  builder: (context, child) {
                    final t = _springController.isAnimating
                        ? _springController.value.clamp(0.0, 1.0).toDouble()
                        : 1.0;

                    final entries = <_InviteRenderEntry>[];

                    for (int i = 0; i < _count; i++) {
                      final toVisual = _visualForSlot(
                        _relativeSlot(i, _activeIndex),
                        cardWidth,
                      );
                      final fromVisual = _startVisuals?[i] ??
                          _visualForSlot(
                            _relativeSlot(i, _fromIndex),
                            cardWidth,
                          );

                      final visual = _lerpVisual(fromVisual, toVisual, t);
                      _currentVisuals[i] = visual;

                      entries.add(_InviteRenderEntry(index: i, visual: visual));
                    }

                    entries.sort(
                      (a, b) => a.visual.depth.compareTo(b.visual.depth),
                    );

                    return Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        for (final entry in entries)
                          _buildAnimatedCard(
                            entry.index,
                            entry.visual,
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                            isMobile: isMobile,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildPageIndicator(),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedCard(
    int index,
    _InviteCardVisual visual, {
    required double cardWidth,
    required double cardHeight,
    required bool isMobile,
  }) {
    final feature = widget.features[index];
    final isActive = index == _activeIndex;
    final hovered = index == _hoveredIndex;
    final interactive = visual.opacity > 0.25;

    final hoverScale = hovered && !isActive ? 1.025 : 1.0;
    final activeHoverScale = hovered && isActive ? 1.018 : 1.0;

    return Transform.translate(
      offset: Offset(visual.x, visual.y),
      child: Transform.rotate(
        angle: visual.rotation,
        child: Transform.scale(
          scale: visual.scale * hoverScale * activeHoverScale,
          child: Opacity(
            opacity: visual.opacity.clamp(0.0, 1.0).toDouble(),
            child: IgnorePointer(
              ignoring: !interactive,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) {
                  setState(() {
                    _hoveredIndex = index;
                  });
                },
                onExit: (_) {
                  if (_hoveredIndex == index) {
                    setState(() {
                      _hoveredIndex = null;
                    });
                  }
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!isActive) {
                      widget.onSelect(index);
                    }
                  },
                  child: _buildInviteFeatureCard(
                    feature,
                    index,
                    width: cardWidth,
                    height: cardHeight,
                    active: isActive,
                    hovered: hovered,
                    mobile: isMobile,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInviteFeatureCard(
    _Feature feature,
    int index, {
    required double width,
    required double height,
    required bool active,
    required bool hovered,
    required bool mobile,
  }) {
    final radius = BorderRadius.circular(mobile ? 24 : 30);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: active
              ? feature.accent.withValues(alpha: hovered ? 0.95 : 0.70)
              : Colors.white.withValues(alpha: hovered ? 0.30 : 0.14),
          width: active ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: feature.accent.withValues(
              alpha: active
                  ? (hovered ? 0.30 : 0.20)
                  : (hovered ? 0.14 : 0.07),
            ),
            blurRadius: active ? 34 : 22,
            spreadRadius: active ? 1 : 0,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: active ? 0.40 : 0.28),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _FeatureNetworkImage(
              imageUrl: feature.imageUrl,
              fit: BoxFit.cover,
              requestedWidth: active ? 800 : 520,
            ),

            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.38, 0.66, 1.0],
                  colors: [
                    Color(0x12000000),
                    Color(0x24000000),
                    Color(0xB0000B17),
                    Color(0xF4000B17),
                  ],
                ),
              ),
            ),

            Positioned(
              top: mobile ? 14 : 18,
              left: mobile ? 14 : 18,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: mobile ? 10 : 12,
                  vertical: mobile ? 5 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.38),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      feature.icon,
                      color: feature.accent,
                      size: mobile ? 13 : 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'FEATURE ${(index + 1).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: mobile ? 9 : 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (active)
              Positioned(
                top: mobile ? 14 : 18,
                right: mobile ? 14 : 18,
                child: Container(
                  width: mobile ? 32 : 36,
                  height: mobile ? 32 : 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: feature.accent.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: feature.accent.withValues(alpha: 0.50),
                    ),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: feature.accent,
                    size: mobile ? 16 : 18,
                  ),
                ),
              ),

            Positioned(
              left: mobile ? 18 : 24,
              right: mobile ? 18 : 24,
              bottom: mobile ? 18 : 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: mobile ? 34 : 40,
                        height: mobile ? 34 : 40,
                        decoration: BoxDecoration(
                          color: feature.accent.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: feature.accent.withValues(alpha: 0.36),
                          ),
                        ),
                        child: Icon(
                          feature.icon,
                          color: feature.accent,
                          size: mobile ? 17 : 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(index + 1).toString().padLeft(2, '0')} / '
                        '${_count.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: _HomePageState.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: mobile ? 12 : 16),
                  Text(
                    feature.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: mobile ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      height: 1.10,
                    ),
                  ),
                  SizedBox(height: mobile ? 8 : 10),
                  Text(
                    feature.copy,
                    maxLines: mobile ? 4 : 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: mobile ? 11.5 : 12.5,
                      height: 1.48,
                    ),
                  ),
                  SizedBox(height: mobile ? 12 : 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        active ? 'Inspect Workflow' : 'Tap to Focus',
                        style: TextStyle(
                          color: feature.accent,
                          fontSize: mobile ? 11 : 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        active
                            ? Icons.arrow_forward_rounded
                            : Icons.touch_app_outlined,
                        color: feature.accent,
                        size: mobile ? 14 : 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: hovered ? 0.13 : 0.07),
                        Colors.transparent,
                        feature.accent.withValues(
                          alpha: active ? 0.06 : 0.02,
                        ),
                      ],
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

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _count,
        (index) {
          final selected = index == _activeIndex;
          final accent = widget.features[index].accent;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: selected ? 28 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: selected
                    ? accent
                    : Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(99),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.30),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InviteCardVisual {
  final double x;
  final double y;
  final double rotation;
  final double scale;
  final double opacity;
  final int depth;

  const _InviteCardVisual({
    required this.x,
    required this.y,
    required this.rotation,
    required this.scale,
    required this.opacity,
    required this.depth,
  });
}

class _InviteRenderEntry {
  final int index;
  final _InviteCardVisual visual;

  const _InviteRenderEntry({
    required this.index,
    required this.visual,
  });
}


class _FeatureNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final int requestedWidth;

  const _FeatureNetworkImage({
    required this.imageUrl,
    required this.fit,
    this.requestedWidth = 900,
  });

  String get _optimizedUrl {
    var url = imageUrl;

    final widthPattern = RegExp(r'([?&])w=\d+');
    if (widthPattern.hasMatch(url)) {
      url = url.replaceFirstMapped(
        widthPattern,
        (match) => '${match.group(1)}w=$requestedWidth',
      );
    } else {
      url += url.contains('?')
          ? '&w=$requestedWidth'
          : '?w=$requestedWidth';
    }

    final qualityPattern = RegExp(r'([?&])q=\d+');
    if (qualityPattern.hasMatch(url)) {
      url = url.replaceFirstMapped(
        qualityPattern,
        (match) => '${match.group(1)}q=75',
      );
    } else {
      url += '&q=75';
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _optimizedUrl,
      fit: fit,
      cacheWidth: requestedWidth,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: _HomePageState.surfaceContainerHigh,
          alignment: Alignment.center,
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
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
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: _HomePageState.onSurfaceVariant,
            size: 34,
          ),
        );
      },
    );
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
      cacheWidth: 1000,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
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