part of '../main.dart';

// --- 5. REPORT SCREEN (Simple Cards, No Poker) ---
class RoundReportScreen extends StatelessWidget {
  const RoundReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final reduceMotion = game.reducedMotion;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Future<void> showSkippableAd() async {
      final secondsLeft = ValueNotifier<int>(5);
      final timer = Timer.periodic(const Duration(seconds: 1), (t) {
        final next = secondsLeft.value - 1;
        if (next <= 0) {
          secondsLeft.value = 0;
          t.cancel();
        } else {
          secondsLeft.value = next;
        }
      });
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(game.t("ad_break_title")),
          content: ValueListenableBuilder<int>(
            valueListenable: secondsLeft,
            builder: (context, value, _) => Text(
              "${game.t("ad_break_body")} (${value}s)",
            ),
          ),
          actions: [
            ValueListenableBuilder<int>(
              valueListenable: secondsLeft,
              builder: (context, value, _) => TextButton(
                onPressed: value == 0
                    ? () {
                        Navigator.pop(dialogContext);
                      }
                    : null,
                child: Text(game.t("ads_skip")),
              ),
            ),
          ],
        ),
      );
      timer.cancel();
      secondsLeft.dispose();
    }

    Future<void> maybeShowInterstitial() async {
      final summary = game.lastRoundSummary;
      if (summary == null) return;
      if (game.isGameEnded) return;
      if (!game.shouldShowInterstitialAfter(summary)) return;
      final shown = await game.showInterstitialAd();
      if (!shown && context.mounted) {
        await showSkippableAd();
      }
    }
    final Color scaffoldColor = isDark
        ? const Color(0xFF141414)
        : Colors.grey[200]!;
    final Color surfaceColor = isDark ? const Color(0xFF1F1F1F) : Colors.white;
    final Color chipFillColor = isDark
        ? const Color(0xFF2A2A2A)
        : Colors.grey[200]!;
    final Color textColor = isDark ? Colors.white70 : Colors.black87;
    final Color primaryButtonColor =
        isDark ? const Color(0xFF2A2A2A) : Colors.black87;
    final Color dangerButtonColor =
        isDark ? Colors.red[400]! : Colors.redAccent;
    final correctList = game.roundHistory
        .where((e) => e.status == CardStatus.correct)
        .toList();
    final tabooList = game.roundHistory
        .where((e) => e.status == CardStatus.taboo)
        .toList();
    final passList = game.roundHistory
        .where((e) => e.status == CardStatus.pass)
        .toList();
    final bool isGameEnded = game.isGameEnded;
    final bool canManualEnd = _canEndGameManually(game);
    final int total = correctList.length + tabooList.length + passList.length;
    final int score = correctList.length - tabooList.length;
    final double accuracy =
        total == 0 ? 0 : (correctList.length / total * 100);

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
              game.t("round_result_title"),
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
              tabs: [
                Tab(text: game.t("tab_correct")),
                Tab(text: game.t("tab_taboo")),
                Tab(text: game.t("tab_pass")),
              ],
            ),
          ),
          body: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      color: scaffoldColor,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          _statCard(
                            game.t("stat_correct"),
                            "${correctList.length}",
                            Icons.check_circle,
                            Colors.green,
                            isDark,
                          ),
                          _statCard(
                            game.t("stat_taboo"),
                            "${tabooList.length}",
                            Icons.block,
                            Colors.redAccent,
                            isDark,
                          ),
                          _statCard(
                            game.t("tab_pass"),
                            "${passList.length}",
                            Icons.skip_next,
                            Colors.blueAccent,
                            isDark,
                          ),
                          _statCard(
                            game.t("stat_score"),
                            "$score",
                            Icons.star,
                            Colors.deepPurple,
                            isDark,
                          ),
                          _statCard(
                            game.t("accuracy"),
                            "${accuracy.toStringAsFixed(1)}%",
                            Icons.track_changes,
                            Colors.amber,
                            isDark,
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
                                ? game.t("cards_finished")
                                : game.t(
                                    "remaining_cards",
                                    params: {"count": "${game.remainingCards}"},
                                  ),
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
                            game,
                            correctList,
                            Colors.green,
                            reduceMotion,
                            isDark,
                          ),
                          _buildSimpleCardList(
                            game,
                            tabooList,
                            Colors.red,
                            reduceMotion,
                            isDark,
                          ),
                          _buildSimpleCardList(
                            game,
                            passList,
                            Colors.blue,
                            reduceMotion,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      color: scaffoldColor,
                      child: SizedBox(
                        width: double.infinity,
                        child: isGameEnded
                            ? _buildEndGameButton(
                                context,
                                game,
                                dangerButtonColor,
                                isManual: false,
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryButtonColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.all(18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () async {
                                        final navigator = Navigator.of(context);
                                        final gameNotifier = Provider.of<
                                            GameProvider>(context, listen: false);
                                        await gameNotifier.playClick();
                                        gameNotifier.finishTurn();
                                        if (!context.mounted) return;
                                        await maybeShowInterstitial();
                                        if (!context.mounted) return;
                                        navigator.pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const RoundStartScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        game.t("continue"),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (game.targetScore == -1) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildEndGameButton(
                                        context,
                                        game,
                                        dangerButtonColor,
                                        isManual: true,
                                        enabled: canManualEnd,
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
        ),
      ),
    );
  }

  Widget _buildEndGameButton(
    BuildContext context,
    GameProvider game,
    Color dangerButtonColor, {
    required bool isManual,
    bool enabled = true,
  }) {
    final Color disabledBg = dangerButtonColor.withValues(alpha: 0.4);
    final Color disabledFg = Colors.white70;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? dangerButtonColor : disabledBg,
        foregroundColor: enabled ? Colors.white : disabledFg,
        disabledBackgroundColor: disabledBg,
        disabledForegroundColor: disabledFg,
        padding: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: !enabled
          ? null
          : () async {
        await Provider.of<GameProvider>(context, listen: false).playClick();
        if (!context.mounted) return;
        if (isManual) {
          if (game.teamAScore > game.teamBScore) {
            game.gameWinner = game.teamAName;
          } else if (game.teamBScore > game.teamAScore) {
            game.gameWinner = game.teamBName;
          } else {
            game.gameWinner = null;
          }
          game.endedByCards = false;
          game.endMessage = null;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GameRecapTeamScreen()),
        );
      },
      child: Text(
        game.t("end_game"),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  bool _canEndGameManually(GameProvider game) {
    if (game.targetScore != -1) return true;
    if (game.roundSummaries.isEmpty) return false;
    return game.roundSummaries.last.turnInRound == 2;
  }

  // SIMPLE RECTANGLE CARD
  Widget _buildSimpleCardList(
    GameProvider game,
    List<RoundEvent> events,
    Color color,
    bool reduceMotion,
    bool isDark,
  ) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          game.t("no_cards_lower"),
          style: TextStyle(color: Colors.grey[500]),
        ),
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
        final Color topColor = isDark
            ? color.withValues(alpha: 0.7)
            : color.withValues(alpha: 0.9);
        final Color bottomColor = isDark
            ? color.withValues(alpha: 0.5)
            : color.withValues(alpha: 0.65);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                topColor,
                bottomColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.2),
              width: 1,
            ),
            boxShadow: reduceMotion
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.14,
                      ),
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
                        game.languageUpper(game.categoryLabel(card.category)),
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
                                      game.t("time_up"),
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

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    final Color bg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
