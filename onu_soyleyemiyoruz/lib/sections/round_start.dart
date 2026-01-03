part of '../main.dart';

// --- 3. ROUND START ---
class RoundStartScreen extends StatelessWidget {
  const RoundStartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    bool isA = game.isTeamATurn;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? (isA ? Colors.blue.shade900 : Colors.red.shade900)
        : (isA ? Colors.blue.shade700 : Colors.red.shade700);
    final Color scoreCardColor = isDark
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.white.withValues(alpha: 0.16);
    final Color scoreBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.2);
    final Color activeChipColor = Colors.black.withValues(
      alpha: isDark ? 0.4 : 0.3,
    );
    final Color inactiveChipColor = Colors.black.withValues(
      alpha: isDark ? 0.3 : 0.22,
    );
    final Color teamATint = Colors.blueAccent;
    final Color teamBTint = Colors.redAccent;
    final Color startButtonColor = isDark ? Colors.amber[400]! : Colors.white;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double contentWidth = min(screenWidth * 0.9, 640);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmExitToMenu(context);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await Provider.of<GameProvider>(
                context,
                listen: false,
              ).playClick();
              if (!context.mounted) return;
              _confirmExitToMenu(context, force: true);
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  game.t("next_label"),
                  style: const TextStyle(
                    color: Colors.white,
                    letterSpacing: 2,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: contentWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      game.t("team_label"),
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: contentWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isA ? game.teamAName : game.teamBName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.amber,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: contentWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      game.t("narrator_label"),
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: contentWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      game.currentNarrator,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.amber,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Explicit Team Score Display
                Container(
                  width: contentWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: scoreCardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreBorderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isA ? activeChipColor : inactiveChipColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: teamATint.withValues(
                                    alpha: isA ? 0.7 : 0.4,
                                  ),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  game.teamAName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        isA ? FontWeight.bold : FontWeight.w600,
                                    shadows: const [
                                      BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${game.teamAScore}",
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "-",
                        style: TextStyle(fontSize: 26, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: !isA
                                    ? activeChipColor
                                    : inactiveChipColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: teamBTint.withValues(
                                    alpha: !isA ? 0.7 : 0.4,
                                  ),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  game.teamBName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: !isA
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    shadows: const [
                                      BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${game.teamBScore}",
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                _InfoChip(
                  icon: Icons.style,
                  label: game.t(
                    "remaining_cards_short",
                    params: {"count": "${game.remainingCards}"},
                  ),
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (game.allCardsUsed) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameOverScreen(),
                        ),
                      );
                      return;
                    }
                    game.startRound();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const GamePlayScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: startButtonColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                  ),
                  child: Text(
                    game.t("start"),
                    style: const TextStyle(fontSize: 24, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
