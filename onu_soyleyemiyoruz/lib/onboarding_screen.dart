import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'game_provider.dart';

class OnboardingScreen extends StatefulWidget {
  final void Function(BuildContext) onFinished;

  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final AudioPlayer _player = AudioPlayer();

  int _index = 0;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      title: "Takımını Kur",
      subtitle:
          "Arkadaşlarını ekle, kategorini seç.\nOyun başlarken her şey hazır olsun.",
      lottie: "assets/lottie/team.json",
    ),
    _OnboardPage(
      title: "Anlat ama Dikkat!",
      subtitle:
          "Yasaklı kelimeyi söylersen buzzer çalar 😈\nHızlı anlat, puanı kap!",
      lottie: "assets/lottie/talk.json",
    ),
    _OnboardPage(
      title: "Eğlen & Kazan",
      subtitle: "Tur sonunda skorları paylaş.\nRövanş için tek dokunuş yeter!",
      lottie: "assets/lottie/trophy.json",
    ),
  ];

  // ----------------- FEEDBACK -----------------

  void _hapticLight() {
    HapticFeedback.lightImpact();
  }

  void _hapticSuccess() {
    HapticFeedback.mediumImpact();
  }

  Future<void> _playClick() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/click.mp3'));
    } catch (_) {
      // Ignore audio failures on platforms where assets might be unavailable.
    }
  }

  Future<void> _playStart() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/start.mp3'));
    } catch (_) {
      // Ignore audio failures on platforms where assets might be unavailable.
    }
  }

  // ----------------- FLOW -----------------

  void _next() {
    _hapticLight();
    _playClick();
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _previous() {
    _hapticLight();
    _playClick();
    _controller.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _finish(BuildContext context) {
    _hapticSuccess();
    _playStart();
    context.read<GameProvider>().completeOnboarding();
    widget.onFinished(context);
  }

  // ----------------- LIFECYCLE -----------------

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  // ----------------- UI -----------------

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: isLast ? const Color(0xFF35227A) : const Color(0xFF2D1B69),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (i) {
                        setState(() => _index = i);
                      },
                      itemBuilder: (context, i) {
                        final page = _pages[i];
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: AnimatedScale(
                            scale: _index == i ? 1 : 0.96,
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: SizedBox(
                                    key: ValueKey(page.lottie),
                                    height: 220,
                                    child: Lottie.asset(
                                      page.lottie,
                                      repeat: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  page.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  page.subtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.white.withValues(alpha: .85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // -------- Indicator --------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 16,
                        ),
                        height: 8,
                        width: _index == i ? (isLast ? 28 : 22) : 8,
                        decoration: BoxDecoration(
                          color: _index == i ? Colors.amber : Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // -------- Buttons --------
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        if (_index > 0)
                          TextButton(
                            onPressed: _previous,
                            child: const Text(
                              "Geri",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        else
                          const SizedBox(width: 72),
                        const Spacer(),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLast ? () => _finish(context) : _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              isLast ? "Oyuna Başla 🚀" : "İleri",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // -------- SKIP (son sayfada yok) --------
              if (!isLast)
                Positioned(
                  top: 12,
                  right: 12,
                  child: TextButton(
                    onPressed: () => _finish(context),
                    child: const Text(
                      "Geç",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
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

// ----------------- MODEL -----------------

class _OnboardPage {
  final String title;
  final String subtitle;
  final String lottie;

  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.lottie,
  });
}
