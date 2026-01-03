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

  List<_OnboardPage> _buildPages(GameProvider game) {
    return [
      _OnboardPage(
        title: game.t("onboard_title_1"),
        subtitle: game.t("onboard_subtitle_1"),
        lottie: "assets/lottie/team.json",
      ),
      _OnboardPage(
        title: game.t("onboard_title_2"),
        subtitle: game.t("onboard_subtitle_2"),
        lottie: "assets/lottie/talk.json",
      ),
      _OnboardPage(
        title: game.t("onboard_title_3"),
        subtitle: game.t("onboard_subtitle_3"),
        lottie: "assets/lottie/trophy.json",
      ),
    ];
  }

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
    final game = Provider.of<GameProvider>(context);
    final pages = _buildPages(game);
    final isLast = _index == pages.length - 1;
    final Size size = MediaQuery.of(context).size;
    final bool isWide = size.shortestSide >= 600;
    final double maxContentWidth = isWide ? 960 : 640;
    final double lottieHeight =
        (size.height * 0.32).clamp(240.0, isWide ? 380.0 : 280.0);
    final double titleSize = isWide ? 36 : 28;
    final double subtitleSize = isWide ? 20 : 16;
    final EdgeInsets pagePadding = isWide
        ? const EdgeInsets.symmetric(horizontal: 64, vertical: 36)
        : const EdgeInsets.all(24);
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
                      itemCount: pages.length,
                      onPageChanged: (i) {
                        setState(() => _index = i);
                      },
                      itemBuilder: (context, i) {
                        final page = pages[i];
                        return Padding(
                          padding: pagePadding,
                          child: AnimatedScale(
                            scale: _index == i ? 1 : 0.96,
                            duration: const Duration(milliseconds: 300),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: maxContentWidth),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      child: SizedBox(
                                        key: ValueKey(page.lottie),
                                        height: lottieHeight,
                                        child: Lottie.asset(
                                          page.lottie,
                                          repeat: true,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: isWide ? 36 : 28),
                                    Text(
                                      page.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: titleSize,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      page.subtitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: subtitleSize,
                                        height: 1.6,
                                        color:
                                            Colors.white.withValues(alpha: .85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                      pages.length,
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
                    padding: EdgeInsets.fromLTRB(
                      isWide ? 48 : 24,
                      0,
                      isWide ? 48 : 24,
                      isWide ? 32 : 24,
                    ),
                    child: Row(
                      children: [
                        if (_index > 0)
                          TextButton(
                            onPressed: _previous,
                            child: Text(
                              game.t("onboard_back"),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isWide ? 16 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          SizedBox(width: isWide ? 96 : 72),
                        const Spacer(),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLast ? () => _finish(context) : _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.deepPurple,
                              padding: EdgeInsets.symmetric(
                                vertical: isWide ? 18 : 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              isLast
                                  ? game.t("onboard_start")
                                  : game.t("onboard_next"),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isWide ? 18 : 16,
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
                    child: Text(
                      game.t("onboard_skip"),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
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
