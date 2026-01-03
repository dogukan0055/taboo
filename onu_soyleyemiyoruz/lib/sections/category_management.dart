part of '../main.dart';

// --- 2.2 CATEGORY MANAGEMENT (Switches) ---
class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  late final ScrollController _categoryScrollController;
  late Set<String> _selectedCategories;
  late Set<String> _disabledIds;
  late final Map<String, IconData> _categoryIcons;
  Set<String> _activeRewardedCategories = {};
  Timer? _rewardTicker;

  @override
  void initState() {
    super.initState();
    _categoryScrollController = ScrollController();
    final game = Provider.of<GameProvider>(context, listen: false);
    _selectedCategories = Set.of(game.selectedCategories);
    _disabledIds = Set.of(game.disabledCardIds);
    _categoryIcons = {
      "Genel": Icons.public,
      "Spor": Icons.sports,
      "Bilim": Icons.science,
      "Doğa": Icons.nature_people,
      "Yemek": Icons.restaurant,
      "Sanat": Icons.brush,
      "Teknoloji": Icons.memory,
      "Tarih": Icons.history_edu_outlined,
      "Futbol": Icons.sports_soccer,
      "90'lar Nostalji": Icons.album,
      "Zor Seviye": Icons.psychology,
      "Gece Yarısı": Icons.favorite,
      "Özel": Icons.star,
    };
  }

  @override
  void dispose() {
    _rewardTicker?.cancel();
    _categoryScrollController.dispose();
    super.dispose();
  }

  bool _hasActiveReward(GameProvider game) {
    return game.availableCategories.any(
      (cat) => game.rewardRemaining(cat) != null,
    );
  }

  void _refreshRewardState(GameProvider game, {bool showExpiry = false}) {
    final messenger = mounted ? ScaffoldMessenger.maybeOf(context) : null;
    final currentRewards = <String>{};
    for (final cat in game.availableCategories) {
      if (game.rewardRemaining(cat) != null) {
        currentRewards.add(cat);
      }
    }
    final expired = _activeRewardedCategories.difference(currentRewards);
    if (expired.isNotEmpty && showExpiry && messenger != null) {
      for (final cat in expired) {
        final label = game.categoryLabel(cat);
        _showSnack(
          messenger,
          game.t("reward_limit_reached", params: {"category": label}),
          isError: true,
        );
      }
      _selectedCategories = Set.of(game.selectedCategories);
      _disabledIds = Set.of(game.disabledCardIds);
    }
    _activeRewardedCategories = currentRewards;
    if (_activeRewardedCategories.isEmpty) {
      _rewardTicker?.cancel();
    }
  }

  void _startRewardTicker(GameProvider game) {
    _rewardTicker?.cancel();
    _refreshRewardState(game);
    if (!_hasActiveReward(game)) return;
    _rewardTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _refreshRewardState(game, showExpiry: true);
      if (!_hasActiveReward(game)) {
        _rewardTicker?.cancel();
      }
      setState(() {});
    });
  }

  void _ensureRewardTicker(GameProvider game) {
    if (_rewardTicker?.isActive == true) return;
    _startRewardTicker(game);
  }

  Future<void> _promptUnlockCategory(
    BuildContext context,
    GameProvider game,
    String category,
  ) async {
    final access = game.categoryAccess(category);
    if (access == CategoryAccess.free) return;
    final messenger = ScaffoldMessenger.of(context);
    final label = game.categoryLabel(category);
    final body = access == CategoryAccess.adUnlock
        ? game.t("unlock_category_body_ad", params: {"category": label})
        : game.t("unlock_category_body_premium", params: {"category": label});
    final price = game.priceForCategory(category);
    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        final bool isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final Color dialogBg = isDark
            ? Colors.black.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.96);
        final Color titleColor = isDark ? Colors.white : Colors.black87;
        final Color contentColor = isDark ? Colors.white70 : Colors.black87;
        final Color actionColor =
            isDark ? Colors.amber : Colors.deepPurple.shade700;
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: dialogBg,
            title: Text(
              game.t("unlock_category_title"),
              style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
            ),
            content: Text(
              body,
              style: TextStyle(color: contentColor),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  game.playClick();
                  Navigator.pop(dialogContext);
                },
                style: TextButton.styleFrom(foregroundColor: actionColor),
                child: Text(game.t("cancel")),
              ),
              TextButton(
                onPressed: () async {
                  game.playClick();
                  Navigator.pop(dialogContext);
                  final activeTimed = game.activeTimedRewardCategory;
                  if (access == CategoryAccess.premium && activeTimed != null) {
                    _showSnack(
                      messenger,
                      game.t("reward_active_warning"),
                      isError: true,
                    );
                    return;
                  }
                  final unlocked = await game.unlockCategoryWithReward(category);
                  if (!mounted) return;
                  if (!unlocked) {
                    _showSnack(
                      messenger,
                      game.t("unlock_failed"),
                      isError: true,
                    );
                    return;
                  }
                  setState(() {
                    _selectedCategories = Set.of(game.selectedCategories);
                    _disabledIds = Set.of(game.disabledCardIds);
                  });
                  final bool timedUnlock =
                      access == CategoryAccess.premium && !game.recentUnlockedPermanent;
                  _showSnack(
                    messenger,
                    timedUnlock
                        ? game.t(
                            "unlock_redeemed_1h",
                            params: {"category": label},
                          )
                        : game.t(
                            "unlock_success",
                            params: {"category": label},
                          ),
                    isSuccess: true,
                  );
                  game.clearRecentUnlockedCategory();
                  _ensureRewardTicker(game);
                },
                style: TextButton.styleFrom(foregroundColor: actionColor),
                child: Text(
                  access == CategoryAccess.adUnlock
                      ? game.t("watch_ad_unlock")
                      : game.t("watch_ad_1h"),
                ),
              ),
              if (access == CategoryAccess.premium && game.iapAvailable)
                ElevatedButton(
                  onPressed: () async {
                    game.playClick();
                    Navigator.pop(dialogContext);
                    await game.buyCategoryPack(category);
                  },
                  child: Text(
                    price != null
                        ? "${game.t("buy_unlock_forever")} • $price"
                        : game.t("buy_unlock_forever"),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    _ensureRewardTicker(game);
    final messenger = ScaffoldMessenger.of(context);
    var wordsMap = game.wordsByCategory;
    if (game.recentUnlockedCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final catLabel = game.categoryLabel(game.recentUnlockedCategory!);
        final msg = game.recentUnlockedPermanent
            ? game.t("unlock_redeemed_forever", params: {"category": catLabel})
            : game.t("unlock_redeemed_1h", params: {"category": catLabel});
        _showSnack(messenger, msg, isSuccess: true);
        game.clearRecentUnlockedCategory();
      });
    }
    final reduceMotion = game.reducedMotion;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(game.t("manage_categories_title")),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await game.playClick();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
      ),
      body: GameBackground(
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _categoryScrollController,
                thumbVisibility: true,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: GridView(
                      controller: _categoryScrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      children: game.availableCategories.map((cat) {
                        List<WordCard> words = wordsMap[cat] ?? [];
                        final access = game.categoryAccess(cat);
                        final bool isUnlocked = game.isCategoryUnlocked(cat);
                        final bool isLocked =
                            access != CategoryAccess.free && !isUnlocked;
                        final bool categoryActive = _selectedCategories.contains(
                          cat,
                        );
                        final int activeCount = words
                            .where((w) => !_disabledIds.contains(w.id))
                            .length;
                        final bool isPartial =
                            activeCount > 0 && activeCount < words.length;
                        final bool isCatSelected =
                            categoryActive &&
                            !isPartial &&
                            activeCount == words.length;
                        final Duration? rewardRemaining =
                            game.rewardRemaining(cat);

                        final Color titleColor = isLocked
                            ? Colors.white38
                            : isCatSelected
                            ? Colors.amber
                            : isPartial
                            ? Colors.lightBlueAccent
                            : Colors.white;

                        return _CategoryCard(
                          title: game.categoryLabel(cat),
                          icon: _categoryIcons[cat] ?? Icons.category,
                          titleColor: titleColor,
                          countLabel: game.t(
                            "category_word_count",
                            params: {
                              "active": "$activeCount",
                              "total": "${words.length}",
                            },
                          ),
                          isSelected: isCatSelected,
                          isPartial: isPartial,
                          isLocked: isLocked,
                          access: access,
                          rewardRemaining: rewardRemaining,
                          lockBadge: game.t("badge_locked"),
                          paidBadge: null,
                          adBadge: null,
                          unlockLabel: isLocked
                              ? access == CategoryAccess.adUnlock
                                    ? game.t("watch_ad_unlock_short")
                                    : game.t("watch_ad_1h")
                              : null,
                          buyLabel: isLocked && access == CategoryAccess.premium
                              ? game.t("buy_unlock_short")
                              : null,
                          reduceMotion: reduceMotion,
                          onToggle: (val) async {
                            await game.playClick();
                            if (val && cat == "Özel" && words.isEmpty) {
                              _showSnack(
                                messenger,
                                game.t("custom_empty_warning"),
                                isError: true,
                              );
                              return;
                            }
                            setState(() {
                              if (val) {
                                _selectedCategories.add(cat);
                                for (final w in words) {
                                  _disabledIds.remove(w.id);
                                }
                              } else {
                                _selectedCategories.remove(cat);
                                for (final w in words) {
                                  _disabledIds.add(w.id);
                                }
                              }
                            });
                          },
                          onUnlock: isLocked
                              ? () => _promptUnlockCategory(context, game, cat)
                              : null,
                          onBuy: isLocked && access == CategoryAccess.premium
                              ? () async {
                                  await game.playClick();
                                  await game.buyCategoryPack(cat);
                                }
                              : null,
                          onOpen: () async {
                            await game.playClick();
                            if (!context.mounted) return;
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryWordsScreen(
                                  category: cat,
                                  icon: _categoryIcons[cat] ?? Icons.category,
                                  words: words,
                                  selectedCategories: _selectedCategories,
                                  disabledIds: _disabledIds,
                                  onChanged: () => setState(() {}),
                                ),
                              ),
                            );
                            if (!context.mounted) return;
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await game.playClick();
                        if (!context.mounted) return;
                        game.applyCategoryChanges(
                          _selectedCategories,
                          _disabledIds,
                        );
                        _showSnack(
                          messenger,
                          game.t("categories_updated"),
                          isSuccess: true,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Text(
                        game.t("save_and_back"),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color titleColor;
  final String countLabel;
  final bool isSelected;
  final bool isPartial;
  final bool isLocked;
  final CategoryAccess access;
  final Duration? rewardRemaining;
  final String? lockBadge;
  final String? paidBadge;
  final String? adBadge;
  final String? unlockLabel;
  final String? buyLabel;
  final bool reduceMotion;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onUnlock;
  final VoidCallback? onBuy;
  final VoidCallback onOpen;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.titleColor,
    required this.countLabel,
    required this.isSelected,
    required this.isPartial,
    required this.isLocked,
    required this.access,
    required this.rewardRemaining,
    required this.lockBadge,
    required this.paidBadge,
    required this.adBadge,
    required this.unlockLabel,
    required this.buyLabel,
    required this.reduceMotion,
    required this.onToggle,
    required this.onUnlock,
    required this.onBuy,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    final bool showUnlock = isLocked && onUnlock != null && unlockLabel != null;
    final Color accent = isLocked
        ? Colors.white38
        : isSelected
        ? Colors.amber
        : isPartial
        ? Colors.lightBlueAccent
        : Colors.white70;
    final Color borderColor = isLocked
        ? Colors.white24
        : isSelected
        ? Colors.amber
        : isPartial
        ? Colors.lightBlueAccent
        : Colors.white24;
    final Color glowColor = isLocked
        ? Colors.transparent
        : isSelected
        ? Colors.amber.withValues(alpha: 0.3)
        : isPartial
        ? Colors.lightBlueAccent.withValues(alpha: 0.3)
        : Colors.transparent;
    final Color bgTop = isLocked
        ? Colors.white.withValues(alpha: 0.04)
        : isSelected
        ? Colors.amber.withValues(alpha: 0.16)
        : isPartial
        ? Colors.lightBlueAccent.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.06);
    final Color bgBottom = Colors.black.withValues(alpha: 0.45);
    final Duration animDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 220);
    final String statusLabel = isSelected
        ? game.t("status_on")
        : isPartial
        ? game.t("status_partial")
        : game.t("status_off");
    final bool isPremiumLocked =
        isLocked && access == CategoryAccess.premium && onUnlock != null;
    final bool hasTimedUnlock = rewardRemaining != null;
    return AnimatedContainer(
      duration: animDuration,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgTop, bgBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          if (glowColor != Colors.transparent)
            BoxShadow(
              color: glowColor,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (showUnlock) {
              onUnlock!();
              return;
            }
            if (isPartial) {
              onToggle(false);
              return;
            }
            onToggle(!isSelected);
          },
          borderRadius: BorderRadius.circular(18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxHeight < 150;
              final bool ultraCompact = constraints.maxHeight < 130;
              final double titleSize = compact ? 14 : 16;
              final double countSize = compact ? 10 : 12;
              final double statusSize = compact ? 9 : 10;
              final double bgIconSize = compact ? 84 : 104;
              final double actionIconSize = compact ? 16 : 18;
              final double actionFontSize = compact ? 10 : 11;
              Widget buildActionButton(
                String label,
                IconData icon,
                VoidCallback? onTap,
              ) {
                return InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: Colors.white70, size: actionIconSize),
                        const SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                fontSize: actionFontSize,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  Align(
                    alignment: const Alignment(0, 0.15),
                    child: Icon(
                      icon,
                      size: bgIconSize,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Positioned(
                    top: compact ? 8 : 10,
                    left: compact ? 10 : 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.35),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          fontSize: statusSize,
                        ),
                      ),
                    ),
                  ),
                  if (isLocked)
                    Positioned(
                      top: compact ? 8 : 10,
                      right: compact ? 10 : 12,
                      child: Icon(
                        Icons.lock,
                        size: actionIconSize + 4,
                        color: Colors.white70,
                      ),
                    ),
                  if (!isLocked && hasTimedUnlock && rewardRemaining != null)
                    Positioned(
                      top: compact ? 8 : 10,
                      right: compact ? 10 : 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_open,
                              size: actionIconSize,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDuration(rewardRemaining!),
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: statusSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 16 : 18,
                        compact ? 18 : 20,
                        compact ? 16 : 18,
                        compact ? 30 : 34,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                                fontSize: titleSize,
                              ),
                            ),
                            if (!ultraCompact) ...[
                              SizedBox(height: compact ? 6 : 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 0.6,
                                  ),
                                ),
                                child: Text(
                                  countLabel,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: countSize,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: compact ? 6 : 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: isPremiumLocked
                          ? Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                if (unlockLabel != null)
                                  buildActionButton(
                                    unlockLabel!,
                                    Icons.ondemand_video,
                                    onUnlock,
                                  ),
                                if (buyLabel != null)
                                  buildActionButton(
                                    buyLabel!,
                                    Icons.shopping_bag_outlined,
                                    onBuy,
                                  ),
                              ],
                            )
                          : buildActionButton(
                              showUnlock
                                  ? unlockLabel ?? game.t("badge_locked")
                                  : game.t("words_button"),
                              showUnlock ? Icons.lock : Icons.menu_book,
                              showUnlock ? onUnlock : onOpen,
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}

class CategoryWordsScreen extends StatefulWidget {
  final String category;
  final IconData icon;
  final List<WordCard> words;
  final Set<String> selectedCategories;
  final Set<String> disabledIds;
  final VoidCallback onChanged;

  const CategoryWordsScreen({
    super.key,
    required this.category,
    required this.icon,
    required this.words,
    required this.selectedCategories,
    required this.disabledIds,
    required this.onChanged,
  });

  @override
  State<CategoryWordsScreen> createState() => _CategoryWordsScreenState();
}

class _CategoryWordsScreenState extends State<CategoryWordsScreen> {
  late final ScrollController _wordScrollController;

  @override
  void initState() {
    super.initState();
    _wordScrollController = ScrollController();
  }

  @override
  void dispose() {
    _wordScrollController.dispose();
    super.dispose();
  }

  void _toggleWord(List<WordCard> words, WordCard word, bool enabled) {
    if (enabled) {
      widget.disabledIds.remove(word.id);
    } else {
      widget.disabledIds.add(word.id);
    }
    final allEnabled = words.every((cw) => !widget.disabledIds.contains(cw.id));
    if (allEnabled) {
      widget.selectedCategories.add(widget.category);
    } else {
      final allDisabled = words.every(
        (cw) => widget.disabledIds.contains(cw.id),
      );
      if (allDisabled && widget.selectedCategories.contains(widget.category)) {
        widget.selectedCategories.remove(widget.category);
      }
    }
    widget.onChanged();
  }

  Widget _buildWordChip({
    required String label,
    required Color color,
    required bool compact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
          fontSize: compact ? 9 : 10,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool compact,
  }) {
    final double size = compact ? 30 : 34;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: compact ? 16 : 18),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildEmptyCustomState(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                game.t("no_cards"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                game.t("custom_add_hint"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final messenger = ScaffoldMessenger.of(context);
    final reduceMotion = game.reducedMotion;
    final words = game.wordsByCategory[widget.category] ?? widget.words;
    final bool isCustomEmpty = widget.category == "Özel" && words.isEmpty;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(game.categoryLabel(widget.category)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await game.playClick();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
        actions: [
          if (widget.category == "Özel")
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await game.playClick();
                if (!context.mounted) return;
                final added = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddCustomCardScreen(),
                  ),
                );
                if (!context.mounted) return;
                if (added != null) {
                  _showSnack(
                    messenger,
                    game.t(
                      "custom_added",
                      params: {
                        "word": added,
                        "category": game.languageUpper(
                          game.categoryLabel("Özel"),
                        ),
                      },
                    ),
                    isSuccess: true,
                  );
                  setState(() {});
                  widget.onChanged();
                }
              },
            ),
        ],
      ),
      body: GameBackground(
        child: isCustomEmpty
            ? _buildEmptyCustomState(context)
            : Scrollbar(
                controller: _wordScrollController,
                thumbVisibility: true,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: GridView.builder(
                      controller: _wordScrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: words.length,
                      itemBuilder: (context, index) {
                        final word = words[index];
                        final isDisabled = widget.disabledIds.contains(word.id);
                        final isCustom = word.isCustom;
                        final bool isEnabled = !isDisabled;
                        final Color accent = isEnabled
                            ? Colors.amber
                            : Colors.white38;
                        final Color borderColor = isEnabled
                            ? Colors.amber
                            : Colors.white24;
                        final Color bgTop = isEnabled
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.05);
                        final Color bgBottom =
                            Colors.black.withValues(alpha: 0.5);
                        final Duration animDuration = reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 200);
                        return AnimatedContainer(
                          duration: animDuration,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [bgTop, bgBottom],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderColor, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await game.playClick();
                                setState(
                                  () => _toggleWord(words, word, !isEnabled),
                                );
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final bool compact =
                                        constraints.maxHeight < 140;
                                    final bool ultraCompact =
                                        constraints.maxHeight < 120;
                                    final double wordSize =
                                        compact ? 13 : 15;
                                    final double bgIconSize =
                                        compact ? 78 : 96;
                                    final bool showCustomActions =
                                        isCustom && !ultraCompact;
                                    return Stack(
                                      children: [
                                        Align(
                                          alignment: const Alignment(0, 0.2),
                                          child: Icon(
                                            widget.icon,
                                            size: bgIconSize,
                                            color: Colors.white.withValues(
                                              alpha: 0.07,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _buildWordChip(
                                                  label: isEnabled
                                                      ? game.t("status_on")
                                                      : game.t("status_off"),
                                                  color: accent,
                                                  compact: compact,
                                                ),
                                                if (isCustom && !compact)
                                                  _buildWordChip(
                                                    label:
                                                        game.t("custom_label"),
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    compact: compact,
                                                  ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    word.word,
                                                    textAlign:
                                                        TextAlign.center,
                                                    style: TextStyle(
                                                      color: isEnabled
                                                          ? Colors.white
                                                          : Colors.white60,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: wordSize,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                _buildActionButton(
                                                  icon: Icons.remove_red_eye,
                                                  color: Colors.white70,
                                                  compact: compact,
                                                  onPressed: () async {
                                                    await game.playClick();
                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    _showCardPreview(
                                                      context,
                                                      word,
                                                    );
                                                  },
                                                ),
                                                if (showCustomActions) ...[
                                                  const SizedBox(width: 8),
                                                  _buildActionButton(
                                                    icon: Icons.edit,
                                                    color: Colors.white70,
                                                    compact: compact,
                                                    onPressed: () async {
                                                      await game.playClick();
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      final updated =
                                                          await Navigator.push<
                                                              String>(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  AddCustomCardScreen(
                                                                existingCard:
                                                                    word,
                                                              ),
                                                            ),
                                                          );
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      if (updated != null) {
                                                        setState(() {});
                                                        widget.onChanged();
                                                        _showSnack(
                                                          messenger,
                                                          game.t(
                                                            "custom_updated",
                                                            params: {
                                                              "word": updated,
                                                            },
                                                          ),
                                                          isSuccess: true,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _buildActionButton(
                                                    icon: Icons.delete_forever,
                                                    color: Colors.redAccent,
                                                    compact: compact,
                                                    onPressed: () {
                                                      game.playClick();
                                                      final removed = word;
                                                      final bool wasSelected =
                                                          widget
                                                              .selectedCategories
                                                              .contains(
                                                                widget
                                                                    .category,
                                                              );
                                                      final wasDisabled = widget
                                                          .disabledIds
                                                          .contains(word.id);
                                                      game.removeCustomCard(
                                                        word.id,
                                                      );
                                                      setState(() {
                                                        widget.disabledIds
                                                            .remove(word.id);
                                                      });
                                                      if (widget.category ==
                                                          "Özel") {
                                                        final remaining =
                                                            game.wordsByCategory[
                                                                  "Özel"] ??
                                                                [];
                                                        if (remaining.isEmpty) {
                                                          widget
                                                              .selectedCategories
                                                              .remove("Özel");
                                                        }
                                                      }
                                                      widget.onChanged();
                                                      _showSnack(
                                                        messenger,
                                                        game.t(
                                                          "custom_deleted",
                                                          params: {
                                                            "word": word.word,
                                                          },
                                                        ),
                                                        isSuccess: true,
                                                        actionLabel:
                                                            game.t("undo"),
                                                        actionIcon: Icons.undo,
                                                        onAction: () {
                                                          game.restoreCustomCard(
                                                            removed,
                                                            disabled:
                                                                wasDisabled,
                                                          );
                                                          if (widget.category ==
                                                                  "Özel" &&
                                                              wasSelected) {
                                                            widget
                                                                .selectedCategories
                                                                .add("Özel");
                                                          }
                                                          if (wasDisabled) {
                                                            setState(() {
                                                              widget.disabledIds
                                                                  .add(
                                                                    removed.id,
                                                                  );
                                                            });
                                                          } else {
                                                            setState(() {});
                                                          }
                                                          widget.onChanged();
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
