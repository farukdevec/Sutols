import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import '../services/firestore_rest_helper.dart';
import '../services/presentation_service.dart';
import '../state/presentation_controller.dart';
import '../state/theme_controller.dart';
import 'html_presentation_editor_page.dart';
import 'widgets/ai_load_animation.dart';
import 'design/design_system.dart';
import 'auth_page.dart';
import 'membership_page.dart';
import 'my_presentations_page.dart';
import 'presentation_view_page.dart';

class SutolHomePage extends StatefulWidget {
  const SutolHomePage({super.key});

  @override
  State<SutolHomePage> createState() => _SutolHomePageState();
}

class _SutolHomePageState extends State<SutolHomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  String _loadingStepTitle = '';
  String _loadingStepDescription = '';

  User? _user;
  late final StreamSubscription<User?> _authSub;

  /// Giriş yapan kullanıcının son sunumları (en fazla 3).
  /// null = yükleniyor/bilinmiyor, boş liste = henüz sunum yok.
  List<_RecentPresentation>? _recentPresentations;

  @override
  void initState() {
    super.initState();
    _user = AuthService.instance.currentUser;
    _authSub = AuthService.instance.authStateChanges.listen((u) {
      if (!mounted) return;
      setState(() {
        _user = u;
        _recentPresentations = null;
      });
      if (u != null) {
        _fetchRecentPresentations();
      }
    });
    if (_user != null) {
      _fetchRecentPresentations();
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecentPresentations() async {
    final uid = _user?.uid;
    if (uid == null) return;

    try {
      final docs = await FirestoreRestHelper.runQuery({
        'from': [
          {'collectionId': 'presentations'},
        ],
        'where': {
          'fieldFilter': {
            'field': {'fieldPath': 'userId'},
            'op': 'EQUAL',
            'value': {'stringValue': uid},
          },
        },
        'orderBy': [
          {
            'field': {'fieldPath': 'createdAt'},
            'direction': 'DESCENDING'
          },
        ],
        'limit': 3,
      });
      final items = docs.map((doc) {
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        final id = (doc['name'] as String? ?? '').split('/').last;
        return _RecentPresentation(
          id: id,
          topic: FirestoreRestHelper.stringField(fields, 'topic'),
          slideCount: int.tryParse(
                FirestoreRestHelper.integerField(fields, 'slideCount'),
              ) ??
              0,
          createdAt: FirestoreRestHelper.timestampField(fields, 'createdAt'),
        );
      }).toList();
      if (!mounted) return;
      setState(() => _recentPresentations = items);
    } catch (_) {
      // Best-effort: listeleme hatası ana akışı bozmamalı.
      if (!mounted) return;
      setState(() => _recentPresentations = const []);
    }
  }

  Widget _buildLogo(AppColors colors) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo.png', height: 32),
          const SizedBox(width: 10),
          Text(
            'Sutols',
            style: AppTypography.headline.copyWith(
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Geniş ekran (>= 720px): tüm öğeler tek satırda.
  Widget _buildWideNavbar(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        _buildLogo(colors),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TierBadge(),
            const SizedBox(width: AppSpacing.s12),
            const _ThemeToggleButton(),
            const SizedBox(width: AppSpacing.s8),
            const _MyPresentationsButton(),
            const SizedBox(width: AppSpacing.s8),
            const _EditorButton(),
            const SizedBox(width: AppSpacing.s8),
            _UserAvatar(),
          ],
        ),
      ],
    );
  }

  /// Dar ekran (< 720px): logo + tema + profil tek satırda, kompakt plan
  /// durumu hemen altında. Sunumlarım/Editör kısayolları yalnız geniş
  /// ekranda gösterilir.
  Widget _buildNarrowNavbar(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildLogo(colors),
            const Spacer(),
            const _ThemeToggleButton(),
            const _EditorButton(),
            _UserAvatar(),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        const _PlanStatusBar(),
      ],
    );
  }

  Future<void> _generatePresentation() async {
    final topic = _promptController.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _loadingStepTitle = 'Sunum Oluşturuluyor...';
      _loadingStepDescription =
          'Yapay zeka konunuzu analiz edip slaytları hazırlıyor.';
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('Lütfen önce giriş yapın.');
      }

      final presentationService = PresentationService();
      final result = await presentationService.createPresentation(
        userId: userId,
        topic: topic,
        slideCount: 5,
      );

      if (!mounted) return;
      setState(() {
        _isGenerating = false;
      });

      if (result.usedFallback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'AI servisi şu an sınırda; kelime tabanlı slaytlar oluşturuldu. '
              'Slaytları düzenleyebilirsiniz.',
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HtmlPresentationEditorPage(
            controller: result.controller,
            presentationId: result.presentationId,
          ),
        ),
      );
      _fetchRecentPresentations();
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('SUNUM HATASI: $e');
      // ignore: avoid_print
      print('STACK TRACE: $stackTrace');
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sunum oluşturulamadı: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // Ambient Glow Background
          const Positioned.fill(
            child: _AmbientGlowBackground(),
          ),

          // Content
          Column(
            children: [
              // Navbar
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 720;
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: narrow ? AppSpacing.s16 : AppSpacing.s32,
                      vertical: narrow ? AppSpacing.s8 : AppSpacing.s24,
                    ),
                    child: narrow
                        ? _buildNarrowNavbar(context)
                        : _buildWideNavbar(context),
                  );
                },
              ),

              // Main content
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 600;
                    final dashboard = narrow && _user != null;

                    // Kısa ekranlarda (mobil, yatay telefon vb.) içeriği
                    // kompaktlaştırıp ekrana sığdırırız.
                    final compact = constraints.maxHeight < 620;
                    final showFooter = constraints.maxHeight >= 460;

                    Widget heroColumn({
                      required String description,
                      required double gapAfter,
                    }) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            narrow
                                ? 'Fikirden sunuma,\ntek cümlede.'
                                : 'Fikirden sunuma, tek cümlede.',
                            textAlign: TextAlign.center,
                            style: AppTypography.display.copyWith(
                              color: colors.textPrimary,
                              fontSize: narrow ? 34 : null,
                              letterSpacing: narrow ? -0.5 : null,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          Text(
                            description,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLarge.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          SizedBox(height: gapAfter),
                        ],
                      );
                    }

                    Widget inputCard() {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: AnimatedSwitcher(
                          duration: AppMotion.standard,
                          child: _isGenerating
                              ? _LoadingState(
                                  title: _loadingStepTitle,
                                  description: _loadingStepDescription,
                                )
                              : _InputCard(
                                  titleController: _titleController,
                                  promptController: _promptController,
                                  onGenerate: _generatePresentation,
                                  isDashboard: dashboard,
                                ),
                        ),
                      );
                    }

                    // Ekrana sığması için kısa ekranlarda daha az
                    // son sunum gösterilir.
                    final recent = _recentPresentations;
                    final maxRecent = compact
                        ? 1
                        : (constraints.maxHeight < 760 ? 2 : 3);

                    final Widget mainContent;
                    if (dashboard) {
                      mainContent = Padding(
                        padding: EdgeInsets.all(
                          compact ? AppSpacing.s12 : AppSpacing.s16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Fikirden sunuma,\ntek cümlede.',
                              textAlign: TextAlign.center,
                              style: AppTypography.display.copyWith(
                                color: colors.textPrimary,
                                fontSize: compact ? 26 : 32,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (!compact) ...[
                              const SizedBox(height: AppSpacing.s8),
                              Text(
                                'Yeni sunumunu saniyeler içinde oluştur.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                            SizedBox(
                              height: compact
                                  ? AppSpacing.s16
                                  : AppSpacing.s24,
                            ),
                            inputCard(),
                            if (recent != null && recent.isNotEmpty) ...[
                              SizedBox(
                                height: compact
                                    ? AppSpacing.s12
                                    : AppSpacing.s24,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Son sunumların',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const MyPresentationsPage(),
                                        ),
                                      );
                                    },
                                    child: const Text('Tümünü gör'),
                                  ),
                                ],
                              ),
                              ...recent
                                  .take(maxRecent)
                                  .map((item) =>
                                      _RecentPresentationTile(item: item)),
                            ],
                          ],
                        ),
                      );
                    } else {
                      mainContent = Padding(
                        padding: EdgeInsets.all(
                          narrow ? AppSpacing.s16 : AppSpacing.s32,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            heroColumn(
                              description:
                                  'Anlatmak istediğinizi yazın. Sutols, sizin için tasarlanmış bir sunumu saniyeler içinde hazırlasın.',
                              gapAfter: narrow
                                  ? (compact
                                      ? AppSpacing.s16
                                      : AppSpacing.s24)
                                  : AppSpacing.s48,
                            ),
                            inputCard(),
                          ],
                        ),
                      );
                    }

                    // Kaydırma yok: içerik alana sığarsa ortalanır,
                    // sığmazsa ekrana ölçeklenir. Footer sabit kalır.
                    return Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(
                                width: constraints.maxWidth,
                                child: mainContent,
                              ),
                            ),
                          ),
                        ),
                        if (showFooter) const _FooterBar(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.s8,
        runSpacing: AppSpacing.s4,
        children: [
          Text(
            '© ${DateTime.now().year} Sutols',
            style: AppTypography.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/gizlilik'),
            child: const Text('Gizlilik Politikası'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/sartlar'),
            child: const Text('Kullanım Şartları'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/sss'),
            child: const Text('SSS'),
          ),
        ],
      ),
    );
  }
}

class _AmbientGlowBackground extends StatefulWidget {
  const _AmbientGlowBackground();

  @override
  State<_AmbientGlowBackground> createState() => _AmbientGlowBackgroundState();
}

class _AmbientGlowBackgroundState extends State<_AmbientGlowBackground> {
  Offset _mousePos = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _mousePos = event.localPosition;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: FractionalOffset(
              _mousePos.dx / MediaQuery.of(context).size.width,
              _mousePos.dy / MediaQuery.of(context).size.height,
            ),
            radius: 0.8,
            colors: [
              colors.accent.withValues(alpha: 0.06),
              colors.surface,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.titleController,
    required this.promptController,
    required this.onGenerate,
    this.isDashboard = false,
  });

  final TextEditingController titleController;
  final TextEditingController promptController;
  final VoidCallback onGenerate;

  /// Giriş yapmış kullanıcının özet dashboard kartı: daha kısa ve
  /// eyleme odaklı ipuçları.
  final bool isDashboard;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final narrow = MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: EdgeInsets.all(narrow ? AppSpacing.s16 : AppSpacing.s32),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        boxShadow: AppShadows.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: titleController,
            style:
                AppTypography.titleMedium.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: isDashboard ? 'Sunum başlığı' : 'Sunum Başlığı',
              filled: true,
              fillColor: colors.surface,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          TextField(
            controller: promptController,
            maxLines: narrow ? 4 : 5,
            minLines: 3,
            style: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: isDashboard
                  ? 'Sunum hakkında'
                  : 'Bu sunum ne hakkında? Konuyu, ana fikirleri ve kitleyi kısaca anlatın...',
              filled: true,
              fillColor: colors.surface,
            ),
          ),
          SizedBox(
            height: narrow ? AppSpacing.s16 : AppSpacing.s24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: onGenerate,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Oluştur'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final narrow = MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: EdgeInsets.all(narrow ? AppSpacing.s24 : AppSpacing.s48),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AiLoadAnimation(
              size: 80, style: AiLoadStyle.spinningLight, message: ''),
          const SizedBox(height: AppSpacing.s32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              title,
              key: ValueKey<String>('title_$title'),
              style:
                  AppTypography.titleMedium.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              description,
              key: ValueKey<String>('desc_$description'),
              style: AppTypography.bodyMedium
                  .copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPresentation {
  const _RecentPresentation({
    required this.id,
    required this.topic,
    required this.slideCount,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final int slideCount;
  final String createdAt;
}

class _RecentPresentationTile extends StatelessWidget {
  const _RecentPresentationTile({required this.item});

  final _RecentPresentation item;

  static const List<String> _months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  String _formatDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final local = date.toLocal();
    return '${local.day} ${_months[local.month - 1]} ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final createdAt = _formatDate(item.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(
          item.topic,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.titleMedium.copyWith(
            color: colors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            [
              if (createdAt.isNotEmpty) createdAt,
              '${item.slideCount} slayt',
            ].join(' • '),
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PresentationViewPage(presentationId: item.id),
            ),
          );
        },
      ),
    );
  }
}

class _TierBadge extends StatefulWidget {
  const _TierBadge();

  @override
  State<_TierBadge> createState() => _TierBadgeState();
}

class _TierBadgeState extends State<_TierBadge> {
  String _tier = 'free';

  @override
  void initState() {
    super.initState();
    _loadTier();
  }

  Future<void> _loadTier() async {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final tier = snapshot.data()?['tier'];
      if (mounted && tier is String) {
        setState(() => _tier = tier);
      }
    } catch (_) {
      // Best-effort: Firestore hatası rozet akışını bozmamalı.
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (_tier) {
      'plus' => ('Plus', const Color(0xFF1565C0), Icons.star_outline),
      'premium' => (
          'Premium',
          const Color(0xFFC9A227),
          Icons.workspace_premium
        ),
      _ => ('Ücretsiz', const Color(0xFF616161), Icons.circle_outlined),
    };

    // Dar ekranda taşmaması için Wrap; geniş ekranda Row gibi içerik
    // genişliğine büzülür (unbounded constraints'te tek satır).
    return Wrap(
      spacing: AppSpacing.s8,
      runSpacing: AppSpacing.s4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (_tier == 'free' || _tier == 'plus')
          _UpgradeButton(highlighted: _tier == 'free', onReturn: _loadTier),
      ],
    );
  }
}

class _PlanStatusBar extends StatefulWidget {
  const _PlanStatusBar();

  @override
  State<_PlanStatusBar> createState() => _PlanStatusBarState();
}

class _PlanStatusBarState extends State<_PlanStatusBar> {
  static const Color _gold = Color(0xFFC9A227);

  String _tier = 'free';

  @override
  void initState() {
    super.initState();
    _loadTier();
  }

  Future<void> _loadTier() async {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final tier = snapshot.data()?['tier'];
      if (mounted && tier is String) {
        setState(() => _tier = tier);
      }
    } catch (_) {
      // Best-effort: Firestore hatası plan durumunu bozmamalı.
    }
  }

  Future<void> _openMembership() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MembershipPage()),
    );
    if (mounted) _loadTier();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPremium = _tier == 'premium';
    final isPlus = _tier == 'plus';
    final withUpgrade = !isPremium;
    final upgradeColor = isPlus ? colors.primary : _gold;

    return GestureDetector(
      onTap: withUpgrade ? _openMembership : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceElevated.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: colors.border.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            Icon(
              isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.circle_outlined,
              size: 14,
              color: isPremium ? _gold : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              isPremium
                  ? 'Premium plan'
                  : isPlus
                      ? 'Plus plan'
                      : 'Ücretsiz plan',
              style: AppTypography.labelMedium.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (withUpgrade)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 14, color: upgradeColor),
                  const SizedBox(width: 4),
                  Text(
                    'Yükselt',
                    style: AppTypography.labelMedium.copyWith(
                      color: upgradeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _UpgradeButton extends StatefulWidget {
  const _UpgradeButton({required this.highlighted, this.onReturn});

  /// Ücretsiz planda daha dikkat çekici (altın) görünüm.
  final bool highlighted;

  /// Yükselt sayfasından dönüşte çağrılır (tier tazeleme için).
  final VoidCallback? onReturn;

  @override
  State<_UpgradeButton> createState() => _UpgradeButtonState();
}

class _UpgradeButtonState extends State<_UpgradeButton> {
  static const Color _gold = Color(0xFFC9A227);
  static const Color _goldLight = Color(0xFFE8B64C);

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final gradient = widget.highlighted
        ? const LinearGradient(
            colors: [_goldLight, _gold],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [colors.primary, colors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final glowColor = widget.highlighted
        ? _gold.withValues(alpha: _hovered ? 0.55 : 0.35)
        : colors.primary.withValues(alpha: 0.35);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const MembershipPage()),
          );
          widget.onReturn?.call();
        },
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: _hovered ? 14 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.highlighted
                    ? Icons.auto_awesome_rounded
                    : Icons.star_outline_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                'Yükselt',
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          style: IconButton.styleFrom(
            iconSize: 22,
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(40, 40),
          ),
          tooltip: isDark ? 'Açık Tema' : 'Koyu Tema',
          onPressed: ThemeController.instance.toggle,
          icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
        );
      },
    );
  }
}

class _MyPresentationsButton extends StatefulWidget {
  const _MyPresentationsButton();

  @override
  State<_MyPresentationsButton> createState() => _MyPresentationsButtonState();
}

class _MyPresentationsButtonState extends State<_MyPresentationsButton> {
  User? _user;

  /// null = bilinmiyor/yükleniyor/hata (kullanıcı yine de sayfaya girebilsin).
  int? _presentationCount;

  late final StreamSubscription<User?> _authSub;

  @override
  void initState() {
    super.initState();
    _user = AuthService.instance.currentUser;
    _authSub = AuthService.instance.authStateChanges.listen((u) {
      if (!mounted) return;
      setState(() => _user = u);
      if (u != null) {
        _fetchPresentationCount();
      } else {
        setState(() => _presentationCount = null);
      }
    });
    if (_user != null) {
      _fetchPresentationCount();
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  Future<void> _fetchPresentationCount() async {
    final uid = _user?.uid;
    if (uid == null) return;
    try {
      final doc = await FirestoreRestHelper.getDocument('users/$uid');
      final fields = doc?['fields'] as Map<String, dynamic>? ?? {};
      final count = int.tryParse(
          FirestoreRestHelper.integerField(fields, 'presentationCount'));
      if (!mounted) return;
      setState(() => _presentationCount = count);
    } catch (_) {
      // Best-effort: sayım okunamazsa buton yine de kullanılabilir kalsın.
      if (!mounted) return;
      setState(() => _presentationCount = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const SizedBox.shrink();

    final hasPresentations = _presentationCount != 0;

    return Tooltip(
      message: hasPresentations
          ? 'Sunumlarım'
          : 'Henüz sunum oluşturmadınız. İlk sunumunuzu oluşturduktan sonra bu sayfayı kullanabilirsiniz.',
      child: IconButton(
        onPressed: () async {
          if (!hasPresentations) return;
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MyPresentationsPage(),
            ),
          );
          if (mounted) _fetchPresentationCount();
        },
        icon: const Icon(Icons.folder_outlined),
      ),
    );
  }
}

class _EditorButton extends StatefulWidget {
  const _EditorButton();

  @override
  State<_EditorButton> createState() => _EditorButtonState();
}

class _EditorButtonState extends State<_EditorButton> {
  User? _user;
  late final StreamSubscription<User?> _authSub;

  @override
  void initState() {
    super.initState();
    _user = AuthService.instance.currentUser;
    _authSub = AuthService.instance.authStateChanges.listen((u) {
      if (mounted) setState(() => _user = u);
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const SizedBox.shrink();

    return IconButton(
      tooltip: 'Editör',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => HtmlPresentationEditorPage(
              controller: PresentationController(),
            ),
          ),
        );
      },
      icon: const Icon(Icons.edit_rounded),
    );
  }
}

class _UserAvatar extends StatefulWidget {
  @override
  State<_UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<_UserAvatar> {
  User? _user;
  late final StreamSubscription<User?> _authSub;

  @override
  void initState() {
    super.initState();
    _user = AuthService.instance.currentUser;
    _authSub = AuthService.instance.authStateChanges.listen((u) {
      if (mounted) setState(() => _user = u);
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_user != null) {
      return GestureDetector(
        onTap: () => _showUserMenu(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary,
          ),
          child: _buildAvatarContent(),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _openAuthPage(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.person_rounded, size: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (_user!.photoURL != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(_user!.photoURL!, fit: BoxFit.cover),
      );
    }
    final initial = (_user!.displayName ?? _user!.email ?? '?')
        .substring(0, 1)
        .toUpperCase();
    return Center(
      child: Text(initial,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  void _openAuthPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AuthPage()),
    );
  }

  void _showUserMenu(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: _user!.photoURL != null
                  ? NetworkImage(_user!.photoURL!)
                  : null,
              child: _user!.photoURL == null
                  ? Text(
                      (_user!.displayName ?? _user!.email ?? '?')[0]
                          .toUpperCase(),
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(_user!.displayName ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(_user!.email ?? '',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await AuthService.instance.signOut();
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Çıkış Yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
