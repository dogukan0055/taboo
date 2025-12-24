part of '../main.dart';

// --- 6. GAME OVER SCREEN ---
class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context, listen: false);
    final reduceMotion = game.reducedMotion;
    final GlobalKey boundaryKey = GlobalKey();
    Future<void> shareSummary() async {
      try {
        final winnerLine = game.gameWinner != null
            ? game.t(
                "share_winner",
                params: {"winner": game.gameWinner!},
              )
            : game.t("share_tie");
        if (kIsWeb) {
          final summary =
              "${game.teamAName}: ${game.teamAScore}\n${game.teamBName}: ${game.teamBScore}\n$winnerLine";
          await SharePlus.instance.share(ShareParams(text: summary));
          return;
        }
        await WidgetsBinding.instance.endOfFrame;
        if (!context.mounted) return;
        final boundary =
            boundaryKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary == null) return;
        final pixelRatio = View.of(context).devicePixelRatio;
        final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return;
        final bytes = byteData.buffer.asUint8List();
        final dir = await getTemporaryDirectory();
        final file = File(
          "${dir.path}/score_${DateTime.now().millisecondsSinceEpoch}.png",
        );
        await file.writeAsBytes(bytes, flush: true);
        await SharePlus.instance.share(
          ShareParams(text: game.t("score_summary"), files: [XFile(file.path)]),
        );
      } catch (e) {
        if (!context.mounted) return;
        final winnerLine = game.gameWinner != null
            ? game.t(
                "share_winner",
                params: {"winner": game.gameWinner!},
              )
            : game.t("share_tie");
        final summary =
            "${game.teamAName}: ${game.teamAScore}\n${game.teamBName}: ${game.teamBScore}\n$winnerLine";
        await SharePlus.instance.share(ShareParams(text: summary));
      }
    }

    return Scaffold(
      body: GameBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: RepaintBoundary(
              key: boundaryKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 100,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      game.t("game_over_title"),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        letterSpacing: 5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (game.endMessage != null)
                      Text(
                        game.endMessage!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (game.endMessage != null) const SizedBox(height: 10),
                    if (game.gameWinner != null)
                      Text(
                        game.t("winner_label"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          game.gameWinner ?? game.t("tie_label"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            shadows: reduceMotion
                                ? []
                                : const [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 20,
                                    ),
                                  ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: _finalScoreItem(
                              game.teamAName,
                              game.teamAScore,
                              Colors.blue,
                            ),
                          ),
                          const Text(
                            "-",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: _finalScoreItem(
                              game.teamBName,
                              game.teamBScore,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Provider.of<GameProvider>(context, listen: false)
                            .playClick();
                        if (!context.mounted) return;
                        await shareSummary();
                      },
                      icon: const Icon(Icons.share),
                      label: Text(
                        game.t("share"),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    ElevatedButton(
                      onPressed: () async {
                        await Provider.of<GameProvider>(context, listen: false)
                            .playClick();
                        if (!context.mounted) return;
                        game.startGame();
                        game.rollDice();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const RoundStartScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 38,
                          vertical: 14,
                        ),
                      ),
                      child: Text(
                        game.t("rematch"),
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await Provider.of<GameProvider>(context, listen: false)
                            .playClick();
                        if (!context.mounted) return;
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        game.t("return_menu_button"),
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _finalScoreItem(String name, int score, Color c) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Text(
          "$score",
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
