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
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Center(
                    child: Image.asset(
                      "assets/image/ingame_logo.png",
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    game.t("menu_title"),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const Spacer(),
                  _MenuButton(
                    label: game.t("menu_play"),
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SetupHubScreen()),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _MenuButton(
                    label: game.t("menu_settings"),
                    color: Colors.teal,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        enableDrag: true,
                        builder: (_) => const SettingsSheet(),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _MenuButton(
                    label: game.t("menu_how_to_play"),
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TutorialScreen()),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _MenuButton(
                    label: game.t("menu_exit"),
                    color: Colors.red,
                    onTap: () => SystemNavigator.pop(),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const Positioned(
              top: 10,
              left: 10,
              child: _LanguageToggle(),
            ),
            const Positioned(
              top: 10,
              right: 10,
              child: _ThemeModeToggle(),
            ),
          ],
        ),
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
  const _ThemeModeToggle();

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
        icon: Icon(icon, color: isDark ? Colors.amber : Colors.white),
        onPressed: () async {
          await game.playClick();
          game.cycleThemeMode();
        },
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final bool isEnglish = game.isEnglish;
    final String flag = isEnglish ? "🇺🇸" : "🇹🇷";
    return SafeArea(
      child: Tooltip(
        message: game.t("lang_tooltip"),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            await game.playClick();
            game.toggleLanguage();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              "$flag ${isEnglish ? game.t("lang_en") : game.t("lang_tr")}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
