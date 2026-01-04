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
    if (game.gameWinner != null) {
      game.playWin();
    }
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
    final media = MediaQuery.of(context);
    final bool isTablet = media.size.shortestSide >= 700;
    final double scale = isTablet ? 1.25 : 1.0;
    final reduceMotion = game.reducedMotion;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scoreCardColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.92);
    final Color scoreBorderColor = Colors.white.withValues(
      alpha: isDark ? 0.2 : 0.14,
    );
    final Color scoreTextColor = isDark ? Colors.white : Colors.black87;
    final Color dividerColor = isDark ? Colors.white70 : Colors.black54;
    final GlobalKey boundaryKey = GlobalKey();
    final GlobalKey shareButtonKey = GlobalKey();
    final String appTitle = game.t("app_title");
    Rect? shareOriginRect() {
      RenderBox? box =
          shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      box ??= context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return null;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      return rect.isEmpty ? null : rect;
    }

    Future<void> shareSummary() async {
      final shareMessage = _buildShareMessage(game);
      final scoreLines =
          "${game.teamAName}: ${game.teamAScore}\n${game.teamBName}: ${game.teamBScore}";
      final summary = "$shareMessage\n$scoreLines";
      try {
        await WidgetsBinding.instance.endOfFrame;
        if (!context.mounted) return;
        final origin = shareOriginRect();
        if (kIsWeb) {
          await SharePlus.instance.share(
            ShareParams(text: summary, sharePositionOrigin: origin),
          );
          return;
        }
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
          ShareParams(
            text: summary,
            files: [XFile(file.path)],
            sharePositionOrigin: origin,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        await SharePlus.instance.share(
          ShareParams(text: summary, sharePositionOrigin: shareOriginRect()),
        );
      }
    }

    return Scaffold(
      body: MediaQuery(
        data: media.copyWith(
          textScaler: TextScaler.linear(isTablet ? 1.2 : 1.0),
        ),
        child: RepaintBoundary(
          key: boundaryKey,
          child: Stack(
            children: [
              GameBackground(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20.0 * scale),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: media.size.height * 0.7,
                            maxWidth: isTablet ? 900 : 760,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events,
                                size: 100 * scale,
                                color: Colors.amber,
                              ),
                              SizedBox(height: 20 * scale),
                              Text(
                                game.t("game_over_title"),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 24 * scale,
                                  letterSpacing: 5,
                                ),
                              ),
                              SizedBox(height: 10 * scale),
                              if (game.endMessage != null)
                                Text(
                                  game.endMessage!,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              if (game.endMessage != null)
                                SizedBox(height: 10 * scale),
                              if (game.gameWinner != null)
                                Text(
                                  game.t("winner_label"),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32 * scale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              SizedBox(height: 10 * scale),
                              SizedBox(
                                width: min(
                                  media.size.width * 0.9,
                                  isTablet ? 760 : 680,
                                ),
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
                              SizedBox(height: 30 * scale),
                              Container(
                                padding: EdgeInsets.all(20 * scale),
                                decoration: BoxDecoration(
                                  color: scoreCardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: scoreBorderColor),
                                  boxShadow: reduceMotion
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: isDark ? 0.4 : 0.18,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: _finalScoreItem(
                                        game.teamAName,
                                        game.teamAScore,
                                        Colors.blue,
                                        scoreTextColor,
                                        scale,
                                      ),
                                    ),
                                    Text(
                                      "-",
                                      style: TextStyle(
                                        fontSize: 40 * scale,
                                        fontWeight: FontWeight.bold,
                                        color: dividerColor,
                                      ),
                                    ),
                                    Expanded(
                                      child: _finalScoreItem(
                                        game.teamBName,
                                        game.teamBScore,
                                        Colors.red,
                                        scoreTextColor,
                                        scale,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24 * scale),
                              ElevatedButton.icon(
                                key: shareButtonKey,
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16 * scale,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 28 * scale,
                                    vertical: 12 * scale,
                                  ),
                                ),
                              ),
                              SizedBox(height: 26 * scale),
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 38 * scale,
                                    vertical: 14 * scale,
                                  ),
                                ),
                                child: Text(
                                  game.t("rematch"),
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 18 * scale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12 * scale),
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 40 * scale,
                                    vertical: 15 * scale,
                                  ),
                                ),
                                child: Text(
                                  game.t("return_menu_button"),
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 18 * scale,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            appTitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
        ),
      ),
    );
  }

  String _buildShareMessage(GameProvider game) {
    final app = game.t("app_title");
    if (game.gameWinner == null) {
      return game.t(
        "share_message_tie",
        params: {"teamA": game.teamAName, "teamB": game.teamBName, "app": app},
      );
    }
    final winner = game.gameWinner!;
    final loser = winner == game.teamAName ? game.teamBName : game.teamAName;
    return game.t(
      "share_message_win",
      params: {"winner": winner, "loser": loser, "app": app},
    );
  }

  Widget _finalScoreItem(
    String name,
    int score,
    Color c,
    Color scoreColor,
    double scale,
  ) {
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
          style: TextStyle(
            fontSize: 40 * scale,
            fontWeight: FontWeight.w900,
            color: scoreColor,
          ),
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
      final double y = ((progress * piece.speed) + piece.offset) % 1.2 - 0.1;
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
