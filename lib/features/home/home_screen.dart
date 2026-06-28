import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/theme_controller.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildGrid(),
          ],
        ),
      ),
    );
  }

  // ── Hero başlık ─────────────────────────────────────────────
  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_controller.value.clamp(0.0, 1.0));
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst aksiyon satırı (tema + dil)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const _LanguageButton(),
              const SizedBox(width: 8),
              const _ThemeToggleButton(),
            ],
          ),
          const SizedBox(height: 8),
          // Ana başlık
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.cyanLight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: Text(
              'Math Buddy',
              style: GoogleFonts.inter(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Matematiği görsel olarak keşfet',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          // Tanınır matematiksel formüller
          const _MathFormulaChips(),
        ],
      ),
    );
  }

  // ── Özellik kartları ızgarası ────────────────────────────────
  Widget _buildGrid() {
    const features = [
      _Feature(
        index: 1,
        title: 'Hesapla',
        subtitle: 'Bilimsel hesap makinesi',
        icon: Icons.calculate_rounded,
        color: AppColors.primary,
        colorLight: AppColors.primaryLight,
        formula: 'x = (−b ± √Δ) / 2a',
      ),
      _Feature(
        index: 2,
        title: 'Grafik',
        subtitle: 'Fonksiyon grafiklerini çiz',
        icon: Icons.show_chart_rounded,
        color: AppColors.cyan,
        colorLight: AppColors.cyanLight,
        formula: 'f(x) = sin x',
      ),
      _Feature(
        index: 3,
        title: 'Geometri',
        subtitle: 'Pisagor & birim çember',
        icon: Icons.pentagon_rounded,
        color: AppColors.pink,
        colorLight: AppColors.pinkLight,
        formula: 'a² + b² = c²',
      ),
      _Feature(
        index: 4,
        title: 'İstatistik',
        subtitle: 'Ortalama, varyans, dağılım',
        icon: Icons.bar_chart_rounded,
        color: AppColors.green,
        colorLight: AppColors.greenLight,
        formula: 'μ = Σx / n',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemCount: features.length,
      itemBuilder: (context, i) {
        final start = 0.15 + i * 0.12;
        final end = (start + 0.45).clamp(0.0, 1.0);
        final anim = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        );
        return AnimatedBuilder(
          animation: anim,
          builder: (context, child) {
            final t = anim.value;
            return Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.7 + 0.3 * t,
                child: child,
              ),
            );
          },
          child: _FeatureCard(
            feature: features[i],
            onTap: () => widget.onNavigate(features[i].index),
          ),
        );
      },
    );
  }
}

// ── Özellik modeli ───────────────────────────────────────────
class _Feature {
  final int index;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color colorLight;
  final String formula;

  const _Feature({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.colorLight,
    required this.formula,
  });
}

// ── Özellik kartı ────────────────────────────────────────────
class _FeatureCard extends StatefulWidget {
  final _Feature feature;
  final VoidCallback onTap;

  const _FeatureCard({required this.feature, required this.onTap});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                f.color.withAlpha(40),
                AppColors.surface,
              ],
            ),
            border: Border.all(
              color: f.color.withAlpha(80),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: f.color.withAlpha(30),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İkon alanı
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: f.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(f.icon, color: f.colorLight, size: 26),
                ),
                const Spacer(),
                // Formül
                Text(
                  f.formula,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: f.colorLight.withAlpha(180),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                // Başlık
                Text(
                  f.title,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                // Alt başlık
                Text(
                  f.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dil seçim butonu (placeholder) ──────────────────────────
class _LanguageButton extends StatelessWidget {
  const _LanguageButton();

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dil / Language',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),
                // Türkçe — aktif
                _LangOption(
                  flag: '🇹🇷',
                  label: 'Türkçe',
                  isActive: true,
                  onTap: () => Navigator.pop(ctx),
                ),
                const SizedBox(height: 10),
                // İngilizce — yakında
                _LangOption(
                  flag: '🇬🇧',
                  label: 'English',
                  isActive: false,
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'İngilizce desteği yakında geliyor!',
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                        backgroundColor: AppColors.surfaceHigh,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLanguageSheet(context),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceUp,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceHigh, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language_rounded, color: AppColors.primaryLight, size: 16),
            const SizedBox(width: 5),
            Text(
              'TR',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dil seçenek satırı ───────────────────────────────────────
class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withAlpha(20)
              : AppColors.surfaceUp,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.primary.withAlpha(80) : AppColors.surfaceHigh,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primaryLight : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (!isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'yakında',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              Icon(Icons.check_rounded, color: AppColors.primaryLight, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Tema geçiş butonu ────────────────────────────────────────
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  IconData _iconFor(ThemeMode mode) => switch (mode) {
        ThemeMode.system => Icons.brightness_auto_rounded,
        ThemeMode.light => Icons.light_mode_rounded,
        ThemeMode.dark => Icons.dark_mode_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        return GestureDetector(
          onTap: cycleThemeMode,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceUp,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceHigh, width: 1),
            ),
            child: Icon(
              _iconFor(mode),
              color: AppColors.primaryLight,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}

// ── Matematiksel formül chip'leri ────────────────────────────
class _MathFormulaChips extends StatelessWidget {
  const _MathFormulaChips();

  @override
  Widget build(BuildContext context) {
    const formulas = ['Δ = b²−4ac', 'eⁱπ + 1 = 0', 'logₐaˣ = x'];
    return Wrap(
      spacing: 8,
      children: formulas.map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceUp,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.surfaceHigh, width: 1),
          ),
          child: Text(
            f,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}
