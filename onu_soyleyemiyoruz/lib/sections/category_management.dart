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
      "Özel": Icons.star,
    };
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final messenger = ScaffoldMessenger.of(context);
    var wordsMap = game.wordsByCategory;
    final reduceMotion = game.reducedMotion;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Kategorileri Yönet"),
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
                child: GridView(
                  controller: _categoryScrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  children: game.availableCategories.map((cat) {
                    List<WordCard> words = wordsMap[cat] ?? [];
                    bool isCatSelected = _selectedCategories.contains(cat);
                    final int activeCount = words
                        .where((w) => !_disabledIds.contains(w.id))
                        .length;
                    final bool isPartial =
                        !isCatSelected &&
                        activeCount > 0 &&
                        activeCount < words.length;

                    final Color titleColor = isCatSelected
                        ? Colors.amber
                        : isPartial
                        ? Colors.lightBlueAccent
                        : Colors.white;

                    return _CategoryCard(
                      title: cat,
                      icon: _categoryIcons[cat] ?? Icons.category,
                      titleColor: titleColor,
                      countLabel: "$activeCount / ${words.length} Kelime",
                      isSelected: isCatSelected,
                      isPartial: isPartial,
                      reduceMotion: reduceMotion,
                      onToggle: (val) async {
                        await game.playClick();
                        if (val && cat == "Özel" && words.isEmpty) {
                          _showSnack(
                            messenger,
                            "Özel kategorisi boş. Önce kelime ekleyin.",
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
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                      "Kategoriler güncellendi",
                      isSuccess: true,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    "KAYDET VE DÖN",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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
  final bool reduceMotion;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.titleColor,
    required this.countLabel,
    required this.isSelected,
    required this.isPartial,
    required this.reduceMotion,
    required this.onToggle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = isSelected
        ? Colors.amber
        : isPartial
        ? Colors.lightBlueAccent
        : Colors.white70;
    final Color borderColor = isSelected
        ? Colors.amber
        : isPartial
        ? Colors.lightBlueAccent
        : Colors.white24;
    final Color glowColor = isSelected
        ? Colors.amber.withValues(alpha: 0.3)
        : isPartial
        ? Colors.lightBlueAccent.withValues(alpha: 0.3)
        : Colors.transparent;
    final Color bgTop = isSelected
        ? Colors.amber.withValues(alpha: 0.16)
        : isPartial
        ? Colors.lightBlueAccent.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.06);
    final Color bgBottom = Colors.black.withValues(alpha: 0.45);
    final Duration animDuration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 220);
    final String statusLabel = isSelected
        ? "AÇIK"
        : isPartial
        ? "KISMİ"
        : "KAPALI";
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
          onTap: () => onToggle(!isSelected),
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
                                  color: Colors.black.withValues(
                                    alpha: 0.35,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: 0.1,
                                    ),
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
                      child: InkWell(
                        onTap: onOpen,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 10 : 12,
                            vertical: compact ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.menu_book,
                                color: Colors.white70,
                                size: actionIconSize,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "KELİMELER",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                  fontSize: actionFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
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
    final allEnabled = words.every(
      (cw) => !widget.disabledIds.contains(cw.id),
    );
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

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final messenger = ScaffoldMessenger.of(context);
    final reduceMotion = game.reducedMotion;
    final words = game.wordsByCategory[widget.category] ?? widget.words;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.category),
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
                  MaterialPageRoute(builder: (_) => const AddCustomCardScreen()),
                );
                if (!context.mounted) return;
                if (added != null) {
                  _showSnack(
                    messenger,
                    "$added ÖZEL kategorisine eklendi",
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
        child: Scrollbar(
          controller: _wordScrollController,
          thumbVisibility: true,
          child: GridView.builder(
            controller: _wordScrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
              final Color accent = isEnabled ? Colors.amber : Colors.white38;
              final Color borderColor =
                  isEnabled ? Colors.amber : Colors.white24;
              final Color bgTop = isEnabled
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.05);
              final Color bgBottom = Colors.black.withValues(alpha: 0.5);
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
                      setState(() => _toggleWord(words, word, !isEnabled));
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final bool compact = constraints.maxHeight < 140;
                          final bool ultraCompact = constraints.maxHeight < 120;
                          final double wordSize = compact ? 13 : 15;
                          final double bgIconSize = compact ? 78 : 96;
                          final bool showCustomActions =
                              isCustom && !ultraCompact;
                          return Stack(
                            children: [
                              Align(
                                alignment: const Alignment(0, 0.2),
                                child: Icon(
                                  widget.icon,
                                  size: bgIconSize,
                                  color: Colors.white.withValues(alpha: 0.07),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildWordChip(
                                        label: isEnabled ? "AÇIK" : "KAPALI",
                                        color: accent,
                                        compact: compact,
                                      ),
                                      if (isCustom && !compact)
                                        _buildWordChip(
                                          label: "ÖZEL",
                                          color: Colors.deepPurpleAccent,
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
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isEnabled
                                                ? Colors.white
                                                : Colors.white60,
                                            fontWeight: FontWeight.bold,
                                            fontSize: wordSize,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildActionButton(
                                        icon: Icons.remove_red_eye,
                                        color: Colors.white70,
                                        compact: compact,
                                        onPressed: () async {
                                          await game.playClick();
                                          if (!context.mounted) return;
                                          _showCardPreview(context, word);
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
                                            if (!context.mounted) return;
                                            final updated =
                                                await Navigator.push<String>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    AddCustomCardScreen(
                                                      existingCard: word,
                                                    ),
                                              ),
                                            );
                                            if (!context.mounted) return;
                                            if (updated != null) {
                                              setState(() {});
                                              widget.onChanged();
                                              _showSnack(
                                                messenger,
                                                "$updated güncellendi",
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
                                            final wasDisabled =
                                                widget.disabledIds.contains(
                                              word.id,
                                            );
                                            game.removeCustomCard(word.id);
                                            setState(() {
                                              widget.disabledIds.remove(word.id);
                                            });
                                            widget.onChanged();
                                            _showSnack(
                                              messenger,
                                              "${word.word} silindi",
                                              isSuccess: true,
                                              actionLabel: "GERİ AL",
                                              actionIcon: Icons.undo,
                                              onAction: () {
                                                game.restoreCustomCard(
                                                  removed,
                                                  disabled: wasDisabled,
                                                );
                                                if (wasDisabled) {
                                                  setState(() {
                                                    widget.disabledIds.add(
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
    );
  }
}
