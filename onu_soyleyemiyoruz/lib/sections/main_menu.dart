part of '../main.dart';

// --- 1. MAIN MENU ---
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: GameBackground(
        child: Padding(
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
              const Text(
                "ONU\nSÖYLEYEMİYORUZ",
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
                label: "OYNA",
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SetupHubScreen()),
                ),
              ),
              const SizedBox(height: 15),
              _MenuButton(
                label: "AYARLAR",
                color: Colors.teal,
                onTap: () {
                  final reduceMotion = Provider.of<GameProvider>(
                    context,
                    listen: false,
                  ).reducedMotion;
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    enableDrag: !reduceMotion,
                    builder: (_) => const SettingsSheet(),
                  );
                },
              ),
              const SizedBox(height: 15),
              _MenuButton(
                label: "NASIL OYNANIR?",
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TutorialScreen()),
                ),
              ),
              const SizedBox(height: 15),
              _MenuButton(
                label: "ÇIKIŞ",
                color: Colors.red,
                onTap: () => SystemNavigator.pop(),
              ),
              const Spacer(),
            ],
          ),
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
