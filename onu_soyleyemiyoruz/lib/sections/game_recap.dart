part of '../main.dart';

class GameRecapTeamScreen extends StatelessWidget {
  const GameRecapTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final summaries = game.roundSummaries;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.12);
    final Color borderColor = Colors.white.withValues(alpha: 0.2);
    final rounds = _groupByRound(summaries);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(game.t("recap_team_based")),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          foregroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () => _goToGameOver(context),
              child: Text(
                game.t("recap_skip"),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        body: GameBackground(
          child: summaries.isEmpty
              ? Center(
                  child: Text(
                    game.t("recap_no_data"),
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...rounds.entries.map(
                                (entry) => _RoundExpansion(
                                  roundNumber: entry.key,
                                  summaries: entry.value,
                                  cardColor: cardColor,
                                  borderColor: borderColor,
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _goToPlayerRecap(context),
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
                                    game.t("recap_to_player"),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _goToPlayerRecap(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GameRecapPlayerScreen()),
    );
  }

  void _goToGameOver(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GameOverScreen()),
    );
  }
}

class GameRecapPlayerScreen extends StatelessWidget {
  const GameRecapPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final summaries = game.roundSummaries;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.12);
    final Color borderColor = Colors.white.withValues(alpha: 0.2);

    final stats = _buildPlayerStats(summaries);
    final mostCorrect = _pickByTotalMax(stats, (s) => s.totalCorrect);
    final leastTaboo = _pickByTotalMin(stats, (s) => s.totalTaboo);
    final quickest = _pickQuickestRound(summaries);
    final mostPass = _pickByTotalMax(stats, (s) => s.totalPass);
    final risky = _pickByTotalMax(stats, (s) => s.totalTaboo);
    final tabooMonster = _pickByMax(stats, (s) => s.maxTabooStreak);
    final slowestRound = _pickSlowestRound(summaries);
    final fastestRound = _pickFastestRound(summaries);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(game.t("recap_player_based")),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          foregroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () => _goToGameOver(context),
              child: Text(
                game.t("recap_skip"),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        body: GameBackground(
          child: summaries.isEmpty
              ? Center(
                  child: Text(
                    game.t("recap_no_data"),
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                      _StatsTile(
                        title: game.t("recap_most_word_guesser"),
                        icon: Icons.psychology,
                        color: Colors.amber,
                        value: _formatPlayerPrimary(mostCorrect),
                        subtitle: _formatPlayerRoundDetail(
                          game,
                          mostCorrect,
                          (s) => s.bestCorrectRound,
                          _MetricType.correct,
                          game.t("recap_correct"),
                        ),
                        badges: _playerBadges(
                          game,
                          mostCorrect,
                          (s) => s.bestCorrectRound,
                          _MetricType.correct,
                          Icons.check_circle,
                          Colors.greenAccent,
                          game.t("recap_correct"),
                        ),
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 10),
                      _StatsTile(
                        title: game.t("recap_least_tabooed"),
                        icon: Icons.sentiment_satisfied_alt,
                        color: Colors.greenAccent,
                        value: _formatPlayerPrimary(leastTaboo),
                        subtitle: _formatPlayerRoundDetail(
                          game,
                          leastTaboo,
                          (s) => s.leastTabooRound,
                          _MetricType.taboo,
                          game.t("recap_taboo"),
                        ),
                        badges: _playerBadges(
                          game,
                          leastTaboo,
                          (s) => s.leastTabooRound,
                          _MetricType.taboo,
                          Icons.block,
                          Colors.redAccent,
                          game.t("recap_taboo"),
                        ),
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 10),
                      _StatsTile(
                        title: game.t("recap_quickest_player"),
                        icon: Icons.flash_on,
                        color: Colors.lightBlueAccent,
                        value: _formatPlayerFromRound(quickest),
                        subtitle: _formatRoundMetricDetail(
                          game,
                          quickest,
                          _MetricType.correct,
                          game.t("recap_correct"),
                        ),
                        badges: _roundBadges(
                          game,
                          quickest,
                          _MetricType.correct,
                          Icons.check_circle,
                          Colors.greenAccent,
                          game.t("recap_correct"),
                        ),
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 10),
                      _StatsTile(
                        title: game.t("recap_passing_player"),
                        icon: Icons.skip_next,
                        color: Colors.orangeAccent,
                        value: _formatPlayerPrimary(mostPass),
                        subtitle: _formatPlayerRoundDetail(
                          game,
                          mostPass,
                          (s) => s.bestPassRound,
                          _MetricType.pass,
                          game.t("recap_pass"),
                        ),
                        badges: _playerBadges(
                          game,
                          mostPass,
                          (s) => s.bestPassRound,
                          _MetricType.pass,
                          Icons.skip_next,
                          Colors.lightBlueAccent,
                          game.t("recap_pass"),
                        ),
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 16),
                      _StatsTile(
                        title: game.t("recap_risky_narrator"),
                        icon: Icons.mic,
                        color: Colors.redAccent,
                        value: _formatPlayerTotalOnly(risky),
                        subtitle: _formatPlayerTotalSub(
                          risky,
                          _MetricType.taboo,
                          game.t("recap_taboo"),
                        ),
                        badges: _playerBadges(
                          game,
                          risky,
                          (s) => s.mostTabooRound,
                          _MetricType.taboo,
                          Icons.block,
                          Colors.redAccent,
                          game.t("recap_taboo"),
                        ),
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 10),
                      _StatsTile(
                        title: game.t("recap_taboo_monster"),
                        icon: Icons.warning_amber_rounded,
                        color: Colors.deepOrangeAccent,
                        value: _formatPlayerTotalOnly(tabooMonster),
                        subtitle: _formatPlayerTotalSub(
                          tabooMonster,
                          _MetricType.streak,
                          game.t("recap_in_a_row"),
                        ),
                        badges: _playerBadges(
                          game,
                          tabooMonster,
                          (s) => s.maxStreakRound,
                          _MetricType.streak,
                          Icons.local_fire_department,
                          Colors.deepOrangeAccent,
                          game.t("recap_in_a_row"),
                        ),
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 10),
                      _StatsTile(
                        title: game.t("recap_slowest_round"),
                        icon: Icons.timer_outlined,
                        color: Colors.white70,
                        value: _formatRoundPrimary(game, slowestRound),
                        subtitle: _formatRoundDetail(
                          game,
                          slowestRound,
                          _MetricType.correct,
                          game.t("recap_correct"),
                        ),
                        badges: _roundBadges(
                          game,
                          slowestRound,
                          _MetricType.correct,
                          Icons.check_circle,
                          Colors.greenAccent,
                          game.t("recap_correct"),
                        ),
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 10),
                      _StatsTile(
                        title: game.t("recap_fastest_round"),
                        icon: Icons.rocket_launch,
                        color: Colors.amberAccent,
                        value: _formatRoundPrimary(game, fastestRound),
                        subtitle: _formatRoundDetail(
                          game,
                          fastestRound,
                          _MetricType.correct,
                          game.t("recap_correct"),
                        ),
                        badges: _roundBadges(
                          game,
                          fastestRound,
                          _MetricType.correct,
                          Icons.check_circle,
                          Colors.greenAccent,
                          game.t("recap_correct"),
                        ),
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                              const Spacer(),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _goToGameOver(context),
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
                                    game.t("recap_continue"),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _goToGameOver(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GameOverScreen()),
    );
  }
}

class _RoundExpansion extends StatelessWidget {
  final int roundNumber;
  final List<RoundSummary> summaries;
  final Color cardColor;
  final Color borderColor;

  const _RoundExpansion({
    required this.roundNumber,
    required this.summaries,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.white70,
          iconColor: Colors.white,
          title: Text(
            game.t("recap_round_label", params: {"index": "$roundNumber"}),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: summaries
              .map((summary) => _TeamRoundRow(summary: summary))
              .toList(),
        ),
      ),
    );
  }
}

class _TeamRoundRow extends StatelessWidget {
  final RoundSummary summary;
  const _TeamRoundRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    final Color accent =
        summary.isTeamA ? Colors.lightBlueAccent : Colors.pinkAccent;
    final String pointsLabel =
        "${summary.points >= 0 ? "+" : ""}${summary.points}";
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.groups_2, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.teamName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.mic,
                      color: Colors.white54,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      game.t("recap_narrator"),
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        summary.narrator,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _IconChip(
                      icon: Icons.stars,
                      color: Colors.amber,
                      value: pointsLabel,
                    ),
                    _IconChip(
                      icon: Icons.check_circle,
                      color: Colors.greenAccent,
                      value: "${summary.correct}",
                    ),
                    _IconChip(
                      icon: Icons.skip_next,
                      color: Colors.lightBlueAccent,
                      value: "${summary.pass}",
                    ),
                    _IconChip(
                      icon: Icons.block,
                      color: Colors.redAccent,
                      value: "${summary.taboo}",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;

  const _IconChip({
    required this.icon,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge {
  final IconData icon;
  final Color color;
  final String label;
  const _StatBadge({
    required this.icon,
    required this.color,
    required this.label,
  });
}

class _BadgeChip extends StatelessWidget {
  final _StatBadge badge;
  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badge.icon, color: badge.color, size: 14),
          const SizedBox(width: 4),
          Text(
            badge.label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color cardColor;
  final Color borderColor;
  final List<_StatBadge> badges;

  const _StatsTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.cardColor,
    required this.borderColor,
    this.badges = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (subtitle.isNotEmpty && badges.isEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final badge in badges) _BadgeChip(badge: badge),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Map<int, List<RoundSummary>> _groupByRound(List<RoundSummary> summaries) {
  final map = <int, List<RoundSummary>>{};
  for (final summary in summaries) {
    map.putIfAbsent(summary.roundNumber, () => []).add(summary);
  }
  for (final entry in map.entries) {
    entry.value.sort((a, b) => a.turnInRound.compareTo(b.turnInRound));
  }
  final sortedKeys = map.keys.toList()..sort();
  return {for (final key in sortedKeys) key: map[key]!};
}

class _PlayerAggregate {
  int totalCorrect = 0;
  int totalPass = 0;
  int totalTaboo = 0;
  int maxTabooStreak = 0;
  RoundSummary? bestCorrectRound;
  RoundSummary? bestPassRound;
  RoundSummary? leastTabooRound;
  RoundSummary? mostTabooRound;
  RoundSummary? maxStreakRound;
}

class _PlayerResult {
  final String? name;
  final _PlayerAggregate? aggregate;
  const _PlayerResult(this.name, this.aggregate);
}

Map<String, _PlayerAggregate> _buildPlayerStats(
  List<RoundSummary> summaries,
) {
  final stats = <String, _PlayerAggregate>{};
  for (final summary in summaries) {
    final agg = stats.putIfAbsent(summary.narrator, () => _PlayerAggregate());
    agg.totalCorrect += summary.correct;
    agg.totalPass += summary.pass;
    agg.totalTaboo += summary.taboo;
    if (summary.maxTabooStreak > agg.maxTabooStreak) {
      agg.maxTabooStreak = summary.maxTabooStreak;
      agg.maxStreakRound = summary;
    }
    if (agg.bestCorrectRound == null ||
        summary.correct > agg.bestCorrectRound!.correct) {
      agg.bestCorrectRound = summary;
    }
    if (agg.bestPassRound == null ||
        summary.pass > agg.bestPassRound!.pass) {
      agg.bestPassRound = summary;
    }
    if (agg.leastTabooRound == null ||
        summary.taboo < agg.leastTabooRound!.taboo) {
      agg.leastTabooRound = summary;
    }
    if (agg.mostTabooRound == null ||
        summary.taboo > agg.mostTabooRound!.taboo) {
      agg.mostTabooRound = summary;
    }
  }
  return stats;
}

_PlayerResult _pickByTotalMax(
  Map<String, _PlayerAggregate> stats,
  int Function(_PlayerAggregate) metric,
) {
  String? bestName;
  _PlayerAggregate? bestAgg;
  int bestValue = -1;
  stats.forEach((name, agg) {
    final value = metric(agg);
    if (value > bestValue) {
      bestValue = value;
      bestName = name;
      bestAgg = agg;
    }
  });
  return _PlayerResult(bestName, bestAgg);
}

_PlayerResult _pickByTotalMin(
  Map<String, _PlayerAggregate> stats,
  int Function(_PlayerAggregate) metric,
) {
  String? bestName;
  _PlayerAggregate? bestAgg;
  int bestValue = 1 << 30;
  stats.forEach((name, agg) {
    final value = metric(agg);
    if (value < bestValue) {
      bestValue = value;
      bestName = name;
      bestAgg = agg;
    }
  });
  return _PlayerResult(bestName, bestAgg);
}

_PlayerResult _pickByMax(
  Map<String, _PlayerAggregate> stats,
  int Function(_PlayerAggregate) metric,
) {
  return _pickByTotalMax(stats, metric);
}

RoundSummary? _pickQuickestRound(List<RoundSummary> summaries) {
  if (summaries.isEmpty) return null;
  RoundSummary? best;
  for (final summary in summaries) {
    if (best == null || summary.correct > best.correct) {
      best = summary;
    }
  }
  return best;
}

RoundSummary? _pickSlowestRound(List<RoundSummary> summaries) {
  if (summaries.isEmpty) return null;
  RoundSummary? slowest;
  for (final summary in summaries) {
    if (slowest == null || summary.correct < slowest.correct) {
      slowest = summary;
    }
  }
  return slowest;
}

RoundSummary? _pickFastestRound(List<RoundSummary> summaries) {
  if (summaries.isEmpty) return null;
  RoundSummary? fastest;
  for (final summary in summaries) {
    if (fastest == null || summary.correct > fastest.correct) {
      fastest = summary;
    }
  }
  return fastest;
}

enum _MetricType { correct, pass, taboo, streak }

String _formatPlayerPrimary(_PlayerResult result) {
  if (result.name == null) return "-";
  return result.name!;
}

String _formatPlayerRoundDetail(
  GameProvider game,
  _PlayerResult result,
  RoundSummary? Function(_PlayerAggregate) roundGetter,
  _MetricType metricType,
  String metricLabel,
) {
  if (result.name == null || result.aggregate == null) return "";
  final round = roundGetter(result.aggregate!);
  if (round == null) return "";
  final count = _metricCount(round, metricType);
  return "${_roundLabel(game, round.roundNumber)} • $count $metricLabel";
}

String _formatPlayerTotalOnly(_PlayerResult result) {
  if (result.name == null) return "-";
  return result.name!;
}

String _formatPlayerTotalSub(
  _PlayerResult result,
  _MetricType metricType,
  String metricLabel,
) {
  if (result.name == null || result.aggregate == null) return "";
  final agg = result.aggregate!;
  int value = 0;
  if (metricType == _MetricType.taboo) {
    value = agg.totalTaboo;
  } else if (metricType == _MetricType.pass) {
    value = agg.totalPass;
  } else if (metricType == _MetricType.correct) {
    value = agg.totalCorrect;
  } else {
    value = agg.maxTabooStreak;
  }
  return "$value $metricLabel";
}

String _formatRoundPrimary(GameProvider game, RoundSummary? summary) {
  if (summary == null) return "-";
  return _roundLabel(game, summary.roundNumber);
}

String _formatPlayerFromRound(RoundSummary? summary) {
  if (summary == null) return "-";
  return summary.narrator;
}

String _formatRoundMetricDetail(
  GameProvider game,
  RoundSummary? summary,
  _MetricType metricType,
  String metricLabel,
) {
  if (summary == null) return "";
  final count = _metricCount(summary, metricType);
  return "${_roundLabel(game, summary.roundNumber)} • $count $metricLabel";
}

String _formatRoundDetail(
  GameProvider game,
  RoundSummary? summary,
  _MetricType metricType,
  String metricLabel,
) {
  if (summary == null) return "";
  final count = _metricCount(summary, metricType);
  return "${summary.teamName} • ${summary.narrator} • $count $metricLabel";
}

String _roundLabel(GameProvider game, int roundNumber) {
  return game.t("recap_round_label", params: {"index": "$roundNumber"});
}

int _metricCount(RoundSummary summary, _MetricType metricType) {
  if (metricType == _MetricType.pass) return summary.pass;
  if (metricType == _MetricType.taboo) return summary.taboo;
  if (metricType == _MetricType.streak) return summary.maxTabooStreak;
  return summary.correct;
}

List<_StatBadge> _playerBadges(
  GameProvider game,
  _PlayerResult result,
  RoundSummary? Function(_PlayerAggregate) roundGetter,
  _MetricType metricType,
  IconData metricIcon,
  Color metricColor,
  String metricLabel,
) {
  if (result.name == null || result.aggregate == null) return const [];
  final round = roundGetter(result.aggregate!);
  if (round == null) return const [];
  final count = _metricCount(round, metricType);
  return [
    _StatBadge(
      icon: Icons.flag_outlined,
      color: Colors.white70,
      label: _roundLabel(game, round.roundNumber),
    ),
    _StatBadge(
      icon: metricIcon,
      color: metricColor,
      label: "$count $metricLabel",
    ),
  ];
}

List<_StatBadge> _roundBadges(
  GameProvider game,
  RoundSummary? summary,
  _MetricType metricType,
  IconData metricIcon,
  Color metricColor,
  String metricLabel,
) {
  if (summary == null) return const [];
  final count = _metricCount(summary, metricType);
  return [
    _StatBadge(
      icon: Icons.flag_outlined,
      color: Colors.white70,
      label: _roundLabel(game, summary.roundNumber),
    ),
    _StatBadge(
      icon: metricIcon,
      color: metricColor,
      label: "$count $metricLabel",
    ),
  ];
}
