part of '../main.dart';

// --- 5. REPORT SCREEN (Simple Cards, No Poker) ---
class RoundReportScreen extends StatelessWidget {
  const RoundReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final reduceMotion = game.reducedMotion;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldColor = isDark
        ? const Color(0xFF141414)
        : Colors.grey[200]!;
    final Color surfaceColor = isDark ? const Color(0xFF1F1F1F) : Colors.white;
    final Color chipFillColor = isDark
        ? const Color(0xFF2A2A2A)
        : Colors.grey[200]!;
    final Color textColor = isDark ? Colors.white70 : Colors.black87;
    final correctList = game.roundHistory
        .where((e) => e.status == CardStatus.correct)
        .toList();
    final tabooList = game.roundHistory
        .where((e) => e.status == CardStatus.taboo)
        .toList();
    final passList = game.roundHistory
        .where((e) => e.status == CardStatus.pass)
        .toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmExitToMenu(context);
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: scaffoldColor,
          appBar: AppBar(
            title: Text(
              "TUR SONUCU",
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            backgroundColor: surfaceColor,
            elevation: 1,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.exit_to_app, color: textColor),
              onPressed: () async {
                await Provider.of<GameProvider>(
                  context,
                  listen: false,
                ).playClick();
                if (!context.mounted) return;
                _confirmExitToMenu(context, force: true);
              },
            ),
            bottom: TabBar(
              isScrollable: false,
              labelColor: textColor,
              unselectedLabelColor: isDark ? Colors.white38 : Colors.grey,
              indicatorColor: isDark ? Colors.amber[400]! : Colors.deepPurple,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              tabs: const [
                Tab(text: "BİLİNENLER"),
                Tab(text: "TABU OLANLAR"),
                Tab(text: "PAS GEÇİLENLER"),
              ],
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 40,
                  ),
                  color: scaffoldColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statCol(
                        "DOĞRU",
                        correctList.length,
                        Colors.green,
                        textColor,
                      ),
                      _statCol("TABU", tabooList.length, Colors.red, textColor),
                      _statCol(
                        "PUAN",
                        correctList.length - tabooList.length,
                        Colors.deepPurple,
                        textColor,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _InfoChip(
                        icon: Icons.style,
                        label: game.allCardsUsed
                            ? "Kartlar bitti"
                            : "Kalan kart: ${game.remainingCards}",
                        textColor: textColor,
                        fillColor: chipFillColor,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSimpleCardList(
                        correctList,
                        Colors.green,
                        reduceMotion,
                      ),
                      _buildSimpleCardList(tabooList, Colors.red, reduceMotion),
                      _buildSimpleCardList(passList, Colors.blue, reduceMotion),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  color: scaffoldColor,
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              await Provider.of<GameProvider>(
                                context,
                                listen: false,
                              ).playClick();
                              if (!context.mounted) return;
                              if (game.allCardsUsed ||
                                  game.gameWinner != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const GameOverScreen(),
                                  ),
                                );
                              } else {
                                game.finishTurn();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RoundStartScreen(),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              "DEVAM ET",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (game.targetScore == -1) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                await Provider.of<GameProvider>(
                                  context,
                                  listen: false,
                                ).playClick();
                                if (!context.mounted) return;
                                if (game.teamAScore > game.teamBScore) {
                                  game.gameWinner = game.teamAName;
                                } else if (game.teamBScore > game.teamAScore) {
                                  game.gameWinner = game.teamBName;
                                } else {
                                  game.gameWinner = null;
                                }
                                game.endedByCards = false;
                                game.endMessage = null;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const GameOverScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "OYUNU BİTİR",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCol(String label, int val, Color c, Color valueColor) => Column(
    children: [
      Text(
        label,
        style: TextStyle(color: c, fontWeight: FontWeight.bold),
      ),
      Text(
        "$val",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: valueColor,
        ),
      ),
    ],
  );

  // SIMPLE RECTANGLE CARD
  Widget _buildSimpleCardList(
    List<RoundEvent> events,
    Color color,
    bool reduceMotion,
  ) {
    if (events.isEmpty) {
      return Center(
        child: Text("Kart yok", style: TextStyle(color: Colors.grey[500])),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final card = event.card;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.9),
                color.withValues(alpha: 0.65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: reduceMotion
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 8,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final double h = c.maxHeight;
              final double w = c.maxWidth;
              final EdgeInsets contentPadding = EdgeInsets.symmetric(
                horizontal: (w * 0.06).clamp(6.0, 10.0),
                vertical: (h * 0.04).clamp(6.0, 10.0),
              );
              final double wordSize = (h * 0.14).clamp(12.0, 18.0);
              final double tabooSize = (h * 0.12).clamp(12.0, 16.0);
              final double categoryFont = (h * 0.06).clamp(8.0, 11.0);
              final EdgeInsets chipPad = EdgeInsets.symmetric(
                horizontal: (w * 0.04).clamp(4.0, 7.0),
                vertical: (h * 0.01).clamp(1.0, 3.0),
              );
              return Padding(
                padding: contentPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: chipPad,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        card.category.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: categoryFont,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    SizedBox(height: (h * 0.02).clamp(2.0, 6.0)),
                    Text(
                      card.word,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: wordSize,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(height: (h * 0.02).clamp(2.0, 6.0)),
                    Container(
                      width: (w * 0.2).clamp(16.0, 26.0),
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: (h * 0.02).clamp(2.0, 6.0)),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, inner) {
                          final int count = card.tabooWords.length;
                          final double gap = count > 1
                              ? (inner.maxHeight * 0.04).clamp(2.0, 6.0)
                              : 0;
                          final double footerHeight = event.timedOut
                              ? (inner.maxHeight * 0.14).clamp(14.0, 22.0)
                              : 0;
                          final double totalGap = gap * (count - 1);
                          final double availableHeight =
                              (inner.maxHeight - footerHeight - totalGap).clamp(
                                0.0,
                                inner.maxHeight,
                              );
                          final double rowHeight = count > 0
                              ? availableHeight / count
                              : 0.0;
                          final double pillHeight = rowHeight * 0.82;
                          return Column(
                            children: [
                              for (
                                int i = 0;
                                i < card.tabooWords.length;
                                i++
                              ) ...[
                                SizedBox(
                                  height: rowHeight,
                                  child: Center(
                                    child: Container(
                                      width: inner.maxWidth * 0.86,
                                      height: pillHeight,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.16,
                                        ),
                                        borderRadius: BorderRadius.circular(7),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                          width: 0.6,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          card.tabooWords[i],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: tabooSize,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (i < card.tabooWords.length - 1)
                                  SizedBox(height: gap),
                              ],
                              if (event.timedOut)
                                SizedBox(
                                  height: footerHeight,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Süre bitti",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.amber[200],
                                        fontSize: (h * 0.11).clamp(14.0, 18.0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
