part of '../main.dart';

// --- 1. MAIN MENU ---
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: GameBackground(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final double maxWidth =
                    (constraints.maxWidth * 0.78).clamp(520.0, 720.0);
                final double logoHeight =
                    (constraints.maxHeight * 0.22).clamp(170.0, 220.0);
                final double titleSize =
                    (constraints.maxWidth * 0.07).clamp(32.0, 40.0);
                return Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxWidth,
                            minHeight: constraints.maxHeight -
                                MediaQuery.of(context).padding.vertical -
                                40,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              Center(
                                child: Image.asset(
                                  "assets/image/ingame_logo.png",
                                  height: logoHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 20),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  game.t("menu_title"),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const _WhatsNewCarousel(),
                              const SizedBox(height: 20),
                              _MenuButton(
                                label: game.t("menu_play"),
                                color: Colors.green,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SetupHubScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              _MenuButton(
                                label: game.t("menu_settings"),
                                color: Colors.teal,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 15),
                              _MenuButton(
                                label: game.t("menu_how_to_play"),
                                color: Colors.blue,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TutorialScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 10,
              left: 10,
              child: _LanguageToggle(
                isWide: MediaQuery.of(context).size.shortestSide >= 700,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: _ThemeModeToggle(
                isWide: MediaQuery.of(context).size.shortestSide >= 700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatsNewCarousel extends StatefulWidget {
  const _WhatsNewCarousel();

  @override
  State<_WhatsNewCarousel> createState() => _WhatsNewCarouselState();
}

class _WhatsNewCarouselState extends State<_WhatsNewCarousel> {
  late final PageController _controller;
  int _index = 0;
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final items = [
      (
        title: game.t("whats_new_item_1_title"),
        body: game.t("whats_new_item_1_body")
      ),
      (
        title: game.t("whats_new_item_2_title"),
        body: game.t("whats_new_item_2_body")
      ),
      (
        title: game.t("whats_new_item_3_title"),
        body: game.t("whats_new_item_3_body")
      ),
    ];
    final Color base = Colors.white.withValues(alpha: 0.92);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _collapsed
          ? Align(
              key: const ValueKey("whats_new_collapsed"),
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () => setState(() => _collapsed = false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.visibility_outlined),
                label: Text(game.t("whats_new_show")),
              ),
            )
          : Column(
              key: const ValueKey("whats_new_expanded"),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  game.t("whats_new_title"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Padding(
                        padding:
                            EdgeInsets.only(right: i == items.length - 1 ? 0 : 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                base,
                                base.withValues(alpha: 0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.body,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _collapsed = true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withValues(alpha: 0.9),
                    ),
                    icon: const Icon(Icons.visibility_off_outlined),
                    label: Text(game.t("whats_new_hide")),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    items.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _index == i ? 18 : 8,
                      decoration: BoxDecoration(
                        color: _index == i
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;
  final IconData? trailingIcon;
  const _MenuButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
    this.trailingIcon,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      onPressed: () async {
        await Provider.of<GameProvider>(context, listen: false).playClick();
        if (!context.mounted) return;
        onTap();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 10),
            Icon(trailingIcon, color: Colors.white),
          ],
        ],
      ),
    );
  }
}

class _ThemeModeToggle extends StatelessWidget {
  final bool isWide;
  const _ThemeModeToggle({this.isWide = false});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final bool isDark = game.themeMode == ThemeMode.dark;
    final IconData icon = isDark ? Icons.dark_mode : Icons.light_mode;
    final String tooltip =
        isDark ? game.t("theme_dark") : game.t("theme_light");
    return SafeArea(
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(
          icon,
          color: isDark ? Colors.amber : Colors.white,
          size: isWide ? 30 : 24,
        ),
        onPressed: () async {
          await game.playClick();
          game.cycleThemeMode();
        },
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final bool isWide;
  const _LanguageToggle({this.isWide = false});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final bool isEnglish = game.isEnglish;
    final String trLabel = "🇹🇷 ${game.t("lang_tr")}";
    final String enLabel = "🇺🇸 ${game.t("lang_en")}";
    Widget buildLangChip({
      required String label,
      required bool active,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: active ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 14 : 10,
            vertical: isWide ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
              fontSize: isWide ? 15 : 12,
            ),
          ),
        ),
      );
    }
    return SafeArea(
      child: Tooltip(
        message: game.t("lang_tooltip"),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildLangChip(
              label: trLabel,
              active: !isEnglish,
              onTap: () async {
                await game.playClick();
                game.toggleLanguage();
              },
            ),
            const SizedBox(width: 6),
            buildLangChip(
              label: enLabel,
              active: isEnglish,
              onTap: () async {
                await game.playClick();
                game.toggleLanguage();
              },
            ),
          ],
        ),
      ),
    );
  }
}
