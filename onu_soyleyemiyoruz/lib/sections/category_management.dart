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
                    childAspectRatio: 1.05,
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
                      onToggle: (val) async {
                        await game.playClick();
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
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.titleColor,
    required this.countLabel,
    required this.isSelected,
    required this.isPartial,
    required this.onToggle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isSelected
        ? Colors.amber
        : isPartial
        ? Colors.lightBlueAccent
        : Colors.white24;
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: () => onToggle(!isSelected),
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxHeight < 150;
            final bool ultraCompact = constraints.maxHeight < 130;
            final double iconSize = compact ? 24 : 28;
            final double boxSize = compact ? 44 : 52;
            final double titleSize = compact ? 14 : 16;
            final double countSize = compact ? 10 : 12;
            return Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 10 : 12,
                      compact ? 10 : 12,
                      compact ? 34 : 36,
                      compact ? 10 : 12,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: boxSize,
                          height: boxSize,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            icon,
                            size: iconSize,
                            color: isSelected
                                ? Colors.amber
                                : isPartial
                                ? Colors.lightBlueAccent
                                : Colors.white70,
                          ),
                        ),
                        SizedBox(height: compact ? 4 : 8),
                        Expanded(
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
                                  SizedBox(height: compact ? 2 : 4),
                                  Text(
                                    countLabel,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: countSize,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white70,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onOpen,
                    ),
                  ),
                ),
              ],
            );
          },
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

  void _toggleWord(WordCard word, bool enabled) {
    if (enabled) {
      widget.disabledIds.remove(word.id);
    } else {
      widget.disabledIds.add(word.id);
    }
    final allEnabled = widget.words.every(
      (cw) => !widget.disabledIds.contains(cw.id),
    );
    if (allEnabled) {
      widget.selectedCategories.add(widget.category);
    } else {
      final allDisabled = widget.words.every(
        (cw) => widget.disabledIds.contains(cw.id),
      );
      if (allDisabled && widget.selectedCategories.contains(widget.category)) {
        widget.selectedCategories.remove(widget.category);
      }
    }
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final messenger = ScaffoldMessenger.of(context);
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
              childAspectRatio: 0.95,
            ),
            itemCount: widget.words.length,
            itemBuilder: (context, index) {
              final word = widget.words[index];
              final isDisabled = widget.disabledIds.contains(word.id);
              final isCustom = word.isCustom;
              final bool isEnabled = !isDisabled;
              return Card(
                color: Colors.white.withValues(alpha: 0.08),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isEnabled ? Colors.amber : Colors.white24,
                  ),
                ),
                child: InkWell(
                  onTap: () async {
                    await game.playClick();
                    setState(() => _toggleWord(word, !isEnabled));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool compact = constraints.maxHeight < 140;
                        final double iconBox = compact ? 36 : 46;
                        final double iconSize = compact ? 18 : 22;
                        final double wordSize = compact ? 13 : 15;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: iconBox,
                                height: iconBox,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: Colors.white70,
                                  size: iconSize,
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 6 : 8),
                            Expanded(
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    word.word,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: wordSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 4 : 8),
                            Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.white70,
                                  size: compact ? 18 : 22,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () async {
                                  await game.playClick();
                                  if (!context.mounted) return;
                                  _showCardPreview(context, word);
                                },
                              ),
                            ),
                            if (isCustom && !compact) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () async {
                                      await game.playClick();
                                      if (!context.mounted) return;
                                      final updated =
                                          await Navigator.push<String>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddCustomCardScreen(
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
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      game.playClick();
                                      game.removeCustomCard(word.id);
                                      setState(() {
                                        widget.disabledIds.remove(word.id);
                                      });
                                      widget.onChanged();
                                      _showSnack(
                                        messenger,
                                        "${word.word} silindi",
                                        isSuccess: true,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
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
