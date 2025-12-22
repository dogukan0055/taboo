part of '../main.dart';

// --- 5. REPORT SCREEN (Simple Cards, No Poker) ---
class RoundReportScreen extends StatelessWidget {
  const RoundReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final reduceMotion = game.reducedMotion;
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
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: const Text(
              "TUR SONUCU",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.black87),
              onPressed: () async {
                await Provider.of<GameProvider>(context, listen: false)
                    .playClick();
                if (!context.mounted) return;
                _confirmExitToMenu(context, force: true);
              },
            ),
            bottom: const TabBar(
              isScrollable: false,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepPurple,
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontSize: 12),
              tabs: [
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
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statCol("DOĞRU", correctList.length, Colors.green),
                      _statCol("TABU", tabooList.length, Colors.red),
                      _statCol(
                        "PUAN",
                        correctList.length - tabooList.length,
                        Colors.deepPurple,
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
                    children: [
                      _InfoChip(
                        icon: Icons.layers,
                        label: game.allCardsUsed
                            ? "Kartlar bitti"
                            : "Kalan kart: ${game.remainingCards}",
                        textColor: Colors.black87,
                        fillColor: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
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
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
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
                        await Provider.of<GameProvider>(context, listen: false)
                            .playClick();
                        if (!context.mounted) return;
                        if (game.allCardsUsed || game.gameWinner != null) {
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCol(String label, int val, Color c) => Column(
    children: [
      Text(
        label,
        style: TextStyle(color: c, fontWeight: FontWeight.bold),
      ),
      Text(
        "$val",
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: LayoutBuilder(
            builder: (context, c) {
              final bool compact = c.maxHeight < 140;
              final double wordSize = compact ? 15 : 18;
              final double tabooSize = compact ? 10 : 12;
              final EdgeInsets chipPad = compact
                  ? const EdgeInsets.symmetric(horizontal: 6, vertical: 3)
                  : const EdgeInsets.symmetric(horizontal: 7, vertical: 4);
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        fontSize: compact ? 9 : 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Text(
                    card.word,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (wordSize * 0.9).clamp(12, 18),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...card.tabooWords.map(
                          (t) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.5),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                t,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (tabooSize * 0.9).clamp(9, 13),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (event.timedOut)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Süre bitti",
                              style: TextStyle(
                                color: Colors.amber[200],
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
