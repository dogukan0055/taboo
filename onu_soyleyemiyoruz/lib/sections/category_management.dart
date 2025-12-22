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

  @override
  void initState() {
    super.initState();
    _categoryScrollController = ScrollController();
    final game = Provider.of<GameProvider>(context, listen: false);
    _selectedCategories = Set.of(game.selectedCategories);
    _disabledIds = Set.of(game.disabledCardIds);
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
    final Map<String, IconData> categoryIcons = {
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
      ),
      body: GameBackground(
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _categoryScrollController,
                thumbVisibility: true,
                child: ListView(
                  controller: _categoryScrollController,
                  padding: const EdgeInsets.all(16),
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

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Theme(
                        data: ThemeData.dark().copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: isCatSelected,
                                activeThumbColor: Colors.green,
                                onChanged: (_) => setState(() {
                                  game.playClick();
                                  if (isCatSelected) {
                                    _selectedCategories.remove(cat);
                                    for (final w in words) {
                                      _disabledIds.add(w.id);
                                    }
                                  } else {
                                    _selectedCategories.add(cat);
                                    for (final w in words) {
                                      _disabledIds.remove(w.id);
                                    }
                                  }
                                }),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                categoryIcons[cat] ?? Icons.category,
                                color: isCatSelected
                                    ? Colors.amber
                                    : isPartial
                                    ? Colors.lightBlueAccent
                                    : Colors.white54,
                              ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Text(
                                cat,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            "$activeCount / ${words.length} Kelime",
                            style: const TextStyle(color: Colors.white54),
                          ),
                          children: [
                            Container(
                              color: Colors.black26,
                              child: Column(
                                children: words.map((w) {
                                  bool isDisabled = _disabledIds.contains(w.id);
                                  final isCustom = w.isCustom;
                                  return ListTile(
                                    title: Text(
                                      w.word,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    leading: Icon(
                                      categoryIcons[cat] ?? Icons.style,
                                      color: Colors.white54,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_red_eye,
                                            color: Colors.white70,
                                          ),
                                          onPressed: () async {
                                            await game.playClick();
                                            if (!context.mounted) return;
                                            _showCardPreview(context, w);
                                          },
                                        ),
                                        if (isCustom)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.white70,
                                            ),
                                            onPressed: () async {
                                              await game.playClick();
                                              if (!context.mounted) return;
                                              final updated =
                                                  await Navigator.push<String>(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AddCustomCardScreen(
                                                            existingCard: w,
                                                          ),
                                                    ),
                                                  );
                                              if (!context.mounted) return;
                                              if (updated != null) {
                                                setState(() {});
                                                _showSnack(
                                                  messenger,
                                                  "$updated güncellendi",
                                                );
                                              }
                                            },
                                          ),
                                        if (isCustom)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_forever,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () {
                                              game.playClick();
                                              game.removeCustomCard(w.id);
                                              setState(() {
                                                _disabledIds.remove(w.id);
                                              });
                                              _showSnack(
                                                messenger,
                                                "${w.word} silindi",
                                              );
                                            },
                                          ),
                                        Switch(
                                          value: !isDisabled,
                                          activeThumbColor: Colors.amber,
                                          onChanged: (val) => setState(() {
                                            game.playClick();
                                            if (val) {
                                              _disabledIds.remove(w.id);
                                            } else {
                                              _disabledIds.add(w.id);
                                            }
                                            final allEnabled = words.every(
                                              (cw) =>
                                                  !_disabledIds.contains(cw.id),
                                            );
                                            if (allEnabled) {
                                              _selectedCategories.add(cat);
                                            } else {
                                              final allDisabled = words.every(
                                                (cw) => _disabledIds.contains(
                                                  cw.id,
                                                ),
                                              );
                                              if (allDisabled &&
                                                  _selectedCategories.contains(
                                                    cat,
                                                  )) {
                                                _selectedCategories.remove(cat);
                                              }
                                            }
                                          }),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            if (cat == "Özel")
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  12,
                                  16,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await game.playClick();
                                    if (!context.mounted) return;
                                    final added = await Navigator.push<String>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AddCustomCardScreen(),
                                      ),
                                    );
                                    if (!context.mounted) return;
                                    if (added != null) {
                                      _showSnack(
                                        messenger,
                                        "$added ÖZEL kategorisine eklendi",
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text("Kart Ekle"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
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
                    _showSnack(messenger, "Kategoriler güncellendi");
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
