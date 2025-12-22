part of '../main.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                title: const Text("Müzik"),
                secondary: const Icon(Icons.music_note),
                value: game.musicEnabled,
                onChanged: (val) async {
                  await game.playClick();
                  game.toggleMusic(val);
                },
              ),
              SwitchListTile(
                title: const Text("Ses Efektleri"),
                secondary: const Icon(Icons.surround_sound),
                value: game.soundEnabled,
                onChanged: (val) async {
                  if (val) {
                    await game.playClick();
                  }
                  game.toggleSound(val);
                },
              ),
              SwitchListTile(
                title: const Text("Titreşim"),
                secondary: const Icon(Icons.vibration),
                value: game.vibrationEnabled,
                onChanged: (val) async {
                  await game.playClick();
                  game.toggleVibration(val);
                },
              ),
              SwitchListTile(
                title: const Text("Yüksek Kontrast"),
                secondary: const Icon(Icons.contrast),
                value: game.highContrast,
                onChanged: (val) async {
                  await game.playClick();
                  game.toggleHighContrast(val);
                },
              ),
              SwitchListTile(
                title: const Text("Az Animasyon"),
                secondary: const Icon(Icons.motion_photos_off),
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
