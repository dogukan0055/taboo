part of '../main.dart';

// --- 6. GAME OVER SCREEN ---
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiCtrl;
  late final List<_ConfettiPiece> _confettiPieces;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    final game = Provider.of<GameProvider>(context, listen: false);
    _showConfetti = game.gameWinner != null && !game.reducedMotion;
    _confettiPieces = _buildConfettiPieces();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (_showConfetti) {
      _confettiCtrl.repeat();
    }
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
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
      body: Stack(
        children: [
          GameBackground(
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
                        if (game.gameWinner != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            game.t(
                              "winner_score",
                              params: {
                                "score": game.gameWinner == game.teamAName
                                    ? "${game.teamAScore}"
                                    : "${game.teamBScore}",
                              },
                            ),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                            await Provider.of<GameProvider>(
                              context,
                              listen: false,
                            ).playClick();
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
                            await Provider.of<GameProvider>(
                              context,
                              listen: false,
                            ).playClick();
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
                            await Provider.of<GameProvider>(
                              context,
                              listen: false,
                            ).playClick();
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
          if (_showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confettiCtrl,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ConfettiPainter(
                        progress: _confettiCtrl.value,
                        pieces: _confettiPieces,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
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

  List<_ConfettiPiece> _buildConfettiPieces() {
    final rand = Random(12);
    const colors = [
      Color(0xFFFFC107),
      Color(0xFFFF5722),
      Color(0xFF03A9F4),
      Color(0xFF4CAF50),
      Color(0xFFE91E63),
    ];
    return List.generate(60, (i) {
      return _ConfettiPiece(
        x: rand.nextDouble(),
        size: 6 + rand.nextDouble() * 6,
        speed: 0.4 + rand.nextDouble() * 0.6,
        rotation: rand.nextDouble() * pi,
        color: colors[i % colors.length],
        offset: rand.nextDouble(),
      );
    });
  }
}

class _ConfettiPiece {
  final double x;
  final double size;
  final double speed;
  final double rotation;
  final double offset;
  final Color color;

  const _ConfettiPiece({
    required this.x,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.offset,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiPiece> pieces;

  const _ConfettiPainter({required this.progress, required this.pieces});

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final double y =
          ((progress * piece.speed) + piece.offset) % 1.2 - 0.1;
      final double dx = piece.x * size.width;
      final double dy = y * size.height;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(piece.rotation + progress * 2 * pi);
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: piece.size,
        height: piece.size * 0.6,
      );
      final paint = Paint()..color = piece.color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
