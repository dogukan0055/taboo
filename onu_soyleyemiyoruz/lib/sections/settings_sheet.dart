part of '../main.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color sheetColor = isDark ? const Color(0xFF1D1A22) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color iconColor = isDark ? Colors.white70 : Colors.black54;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                "AYARLAR",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: Text("Müzik", style: TextStyle(color: textColor)),
                secondary: game.musicEnabled
                    ? Icon(Icons.music_note, color: iconColor)
                    : Icon(Icons.music_off, color: iconColor),
                value: game.musicEnabled,
                onChanged: (val) async {
                  await game.playClick();
                  game.toggleMusic(val);
                },
              ),
              SwitchListTile(
                title: Text("Ses Efektleri", style: TextStyle(color: textColor)),
                secondary: game.soundEnabled
                    ? Icon(Icons.volume_up_outlined, color: iconColor)
                    : Icon(Icons.volume_off_outlined, color: iconColor),
                value: game.soundEnabled,
                onChanged: (val) async {
                  game.toggleSound(val);
                  if (val) {
                    await game.playClick(force: true);
                  }
                },
              ),
              SwitchListTile(
                title: Text("Titreşim", style: TextStyle(color: textColor)),
                secondary: game.vibrationEnabled
                    ? Icon(Icons.vibration, color: iconColor)
                    : Icon(Icons.phone_iphone, color: iconColor),
                value: game.vibrationEnabled,
                onChanged: (val) async {
                  await game.playClick();
                  game.toggleVibration(val);
                },
              ),
              SwitchListTile(
                title: Text("Performans Modu", style: TextStyle(color: textColor)),
                secondary: Icon(
                  Icons.speed,
                  color: game.reducedMotion ? Colors.amber : iconColor,
                ),
                value: game.reducedMotion,
                onChanged: (val) async {
                  await game.playClick();
                  game.toggleReducedMotion(val);
                },
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await game.playClick();
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Text(
                    "Kapat",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
}
