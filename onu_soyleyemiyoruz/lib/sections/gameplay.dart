part of '../main.dart';

// --- 4. GAMEPLAY SCREEN ---
class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key});
  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final List<Widget> _floatingTexts = [];
  late AnimationController _blink;
  bool _reduceMotion = false;
  bool _pausedByBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.35,
      upperBound: 1,
    )..value = 1;
  }

  void _showFloatingText(String text, Color color) {
    if (_reduceMotion) return;
    final UniqueKey key = UniqueKey();
    setState(() {
      _floatingTexts.add(
        _FloatingTextItem(
          key: key,
          text: text,
          color: color,
          onComplete: () {
            setState(() {
              _floatingTexts.removeWhere((element) => element.key == key);
            });
          },
        ),
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final game = Provider.of<GameProvider>(context, listen: false);
      if (game.isPaused) {
        return;
      }
      game.pauseGame();
      _pausedByBackground = true;
      return;
    }
    if (state == AppLifecycleState.resumed && _pausedByBackground) {
      _pausedByBackground = false;
      if (!mounted) return;
      _onPausePressed(
        Provider.of<GameProvider>(context, listen: false),
        fromBackground: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _reduceMotion = game.reducedMotion;
    final Color tabooColor = isDark ? Colors.red.shade700 : Colors.red;
    final Color passColor = isDark ? Colors.blue.shade700 : Colors.blue;
    final Color correctColor = isDark ? Colors.green.shade700 : Colors.green;
    final Color disabledPassColor =
        isDark ? Colors.blueGrey.shade700 : Colors.grey;
    _updateBlink(game.timeLeft);
    if (!game.isPaused && !game.abortedToMenu && game.timeLeft == 0) {
      final navigator = Navigator.of(context);
      Future.microtask(() {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const RoundReportScreen()),
        );
      });
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: Text(game.t("exit_game_title")),
            content: Text(game.t("exit_game_body")),
            actions: [
              TextButton(
                onPressed: () async {
                  await game.playClick();
                  if (!context.mounted) return;
                  Navigator.pop(dialogCtx);
                },
                child: Text(game.t("cancel")),
              ),
              ElevatedButton(
                onPressed: () async {
                  await game.playClick();
                  if (!context.mounted) return;
                  Navigator.pop(dialogCtx);
                  game.abortCurrentRound();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: Text(game.t("exit_game_action")),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            GameBackground(
              child: Column(
                children: [
                  _buildScoreHeader(game),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AnimatedSwitcher(
                        duration: _reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 300),
                        child: _buildCardContent(game.currentCard),
                      ),
                    ),
                  ),
                  _buildFeedbackToggles(game),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        BouncingButton(
                          icon: Icons.close,
                          color: tabooColor,
                          label: game.t("label_taboo"),
                          disabled: game.isCoolingDown,
                          onTap: () {
                            _showFloatingText(
                              game.t("floating_taboo"),
                              Colors.redAccent,
                            );
                            game.actionTaboo();
                          },
                        ),
                        game.currentPasses > 0
                            ? BouncingButton(
                                icon: Icons.skip_next,
                                color: passColor,
                                label: game.t("label_pass"),
                                badgeText: "${game.currentPasses}",
                                disabled: game.isCoolingDown,
                                onTap: () {
                                  _showFloatingText(
                                    game.t("floating_pass"),
                                    Colors.blueAccent,
                                  );
                                  game.actionPass();
                                },
                              )
                            : Opacity(
                                opacity: 0.5,
                                child: BouncingButton(
                                icon: Icons.skip_next,
                                color: disabledPassColor,
                                label: game.t("label_pass"),
                                badgeText: "0",
                                disabled: true,
                                onTap: () {},
                              ),
                              ),
                        BouncingButton(
                          icon: Icons.check,
                          color: correctColor,
                          label: game.t("label_correct"),
                          disabled: game.isCoolingDown,
                          onTap: () {
                            _showFloatingText(
                              game.t("floating_correct"),
                              Colors.greenAccent,
                            );
                            game.actionCorrect();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ..._floatingTexts,
          ],
        ),
      ),
    );
  }

  void _updateBlink(int timeLeft) {
    if (_reduceMotion) {
      if (_blink.isAnimating) _blink.stop();
      _blink.value = 1;
      return;
    }
    if (timeLeft > 0 && timeLeft <= 10) {
      final ms = (120 + timeLeft * 40).clamp(120, 600);
      if (_blink.duration?.inMilliseconds != ms) {
        _blink.duration = Duration(milliseconds: ms);
      }
      if (!_blink.isAnimating) {
        _blink.repeat(reverse: true);
      }
    } else {
      if (_blink.isAnimating) _blink.stop();
      _blink.value = 1;
    }
  }

  void _onPausePressed(GameProvider game, {bool fromBackground = false}) {
    game.pauseGame();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      useSafeArea: false,
      builder: (dialogCtx) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ),
          ),
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF421B7A), Color(0xFF2E0F57)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 18),
                    const Icon(
                      Icons.pause_circle_outline,
                      color: Colors.amber,
                      size: 46,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.t("paused_title"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        fromBackground
                            ? game.t("paused_background")
                            : game.t("paused_body"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: fromBackground ? 12 : 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.white24,
                      indent: 16,
                      endIndent: 16,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                game.playClick();
                                Navigator.pop(dialogCtx);
                                game.resumeGame();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                game.t("resume"),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _confirmExitToMenu(
                                  context,
                                  onConfirm: () async {
                                    game.abortCurrentRound();
                                  },
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1.4,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                game.t("return_menu"),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).then((_) {
      if (game.isPaused) {
        game.resumeGame();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _blink.dispose();
    super.dispose();
  }

  Widget _buildFeedbackToggles(GameProvider game) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 6),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          _buildFeedbackToggle(
            icon: game.soundEnabled ? Icons.volume_up : Icons.volume_off,
            label: game.soundEnabled
                ? game.t("sound_on")
                : game.t("sound_off"),
            isActive: game.soundEnabled,
            onTap: () async {
              if (!game.soundEnabled) {
                await game.playClick(force: true);
              }
              game.toggleSound(!game.soundEnabled);
            },
            playClickOnTap: false,
          ),
          _buildFeedbackToggle(
            icon: game.vibrationEnabled ? Icons.vibration : Icons.phone_android,
            label: game.vibrationEnabled
                ? game.t("vibration_on")
                : game.t("vibration_off"),
            isActive: game.vibrationEnabled,
            onTap: () => game.toggleVibration(!game.vibrationEnabled),
          ),
          _buildFeedbackToggle(
            icon: Icons.style,
            label: game.t(
              "remaining_cards_label",
              params: {"count": "${game.remainingCards}"},
            ),
            isActive: false,
            onTap: () {},
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackToggle({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool playClickOnTap = true,
    bool forceClick = false,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled
          ? () async {
              if (playClickOnTap) {
                await Provider.of<GameProvider>(
                  context,
                  listen: false,
                ).playClick(force: forceClick);
                if (!context.mounted) return;
              }
              onTap();
            }
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black26,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.amber : Colors.white24,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreHeader(GameProvider game) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTeamScoreItem(
                    game.teamAName,
                    game.teamAScore,
                    Colors.blueAccent,
                    game.isTeamATurn,
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 82,
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.deepPurple, width: 4),
                    ),
                    alignment: Alignment.center,
                    child: FadeTransition(
                      opacity: _blink,
                      child: Text(
                        "${game.timeLeft}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTeamScoreItem(
                    game.teamBName,
                    game.teamBScore,
                    Colors.redAccent,
                    !game.isTeamATurn,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -12,
            child: Center(
              child: IconButton(
                icon: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pause, color: Colors.black, size: 18),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  await game.playClick();
                  _onPausePressed(game);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScoreItem(
    String name,
    int score,
    Color color,
    bool isActive, {
    required bool isDark,
  }) {
    final Color activeFill = Colors.black.withValues(
      alpha: isDark ? 0.5 : 0.35,
    );
    final Color inactiveFill = Colors.white.withValues(
      alpha: isDark ? 0.06 : 0.04,
    );
    return AnimatedContainer(
      duration: _reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? activeFill : inactiveFill,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: isDark ? 0.9 : 0.75)
              : Colors.white.withValues(alpha: isDark ? 0.12 : 0.08),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                  shadows: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Text(
            "$score",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 26,
              shadows: isActive
                  ? [
                      if (!_reduceMotion)
                        const BoxShadow(blurRadius: 10, color: Colors.black45),
                    ]
                  : [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(WordCard? card) {
    if (card == null) return Container(key: const ValueKey("empty"));
    final game = Provider.of<GameProvider>(context, listen: false);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color headerColor = isDark
        ? const Color(0xFF2E1A4A)
        : Colors.deepPurple;
    final Color wordColor = isDark ? Colors.white : Colors.black87;
    final Color tabooColor = isDark ? Colors.white70 : Colors.grey[700]!;
    final Color dividerColor = isDark
        ? Colors.white24
        : const Color(0xFFE0E0E0);
    final double cardWidth = MediaQuery.of(context).size.width * 0.7;
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        key: ValueKey(card.id),
        width: cardWidth,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: _reduceMotion
                ? []
                : [const BoxShadow(blurRadius: 20, color: Colors.black45)],
          ),
          child: Column(
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  game.languageUpper(game.categoryLabel(card.category)),
                  style: const TextStyle(
                    color: Colors.white38,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double wordSize =
                        (constraints.biggest.shortestSide * 0.1).clamp(
                          16.0,
                          30.0,
                        );
                    final double tabooSize =
                        (constraints.biggest.shortestSide * 0.06).clamp(
                          11.0,
                          18.0,
                        );
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  card.word,
                                  style: TextStyle(
                                    fontSize: wordSize,
                                    fontWeight: FontWeight.w900,
                                    color: wordColor,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0, bottom: 2),
                          child: Divider(
                            thickness: 2,
                            indent: 8,
                            endIndent: 8,
                            color: dividerColor,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: card.tabooWords
                                .map(
                                  (t) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 6,
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        t,
                                        style: TextStyle(
                                          fontSize: tabooSize,
                                          color: tabooColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BouncingButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? badgeText;
  final VoidCallback onTap;
  final bool disabled;
  const BouncingButton({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.badgeText,
    this.disabled = false,
  });
  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _s = Tween<double>(begin: 1.0, end: 0.9).animate(_c);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = Provider.of<GameProvider>(
      context,
      listen: false,
    ).reducedMotion;
    return GestureDetector(
      onTapDown: (_) {
        if (widget.disabled) return;
        if (!reduceMotion) {
          _c.forward();
        }
      },
      onTapUp: (_) {
        if (widget.disabled) return;
        if (!reduceMotion) {
          _c.reverse();
        }
        widget.onTap();
      },
      onTapCancel: () {
        if (!reduceMotion) {
          _c.reverse();
        }
      },
      child: ScaleTransition(
        scale: reduceMotion ? const AlwaysStoppedAnimation(1.0) : _s,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.disabled
                        ? widget.color.withValues(alpha: 0.5)
                        : widget.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: reduceMotion
                        ? []
                        : [
                            const BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 30),
                ),
                if (widget.badgeText != null)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(
                        widget.badgeText!,
                        style: TextStyle(
                          color: widget.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}

class _FloatingTextItem extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onComplete;
  const _FloatingTextItem({
    super.key,
    required this.text,
    required this.color,
    required this.onComplete,
  });
  @override
  State<_FloatingTextItem> createState() => _FloatingTextItemState();
}

class _FloatingTextItemState extends State<_FloatingTextItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<Offset> _p;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _p = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.0),
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));
    _c.forward().then((_) => widget.onComplete());
  }

  @override
  Widget build(BuildContext context) => Center(
    child: SlideTransition(
      position: _p,
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 1,
          end: 0,
        ).animate(CurvedAnimation(parent: _c, curve: const Interval(0.6, 1))),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w900,
            color: widget.color,
            shadows: const [BoxShadow(blurRadius: 10, color: Colors.black45)],
          ),
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}
