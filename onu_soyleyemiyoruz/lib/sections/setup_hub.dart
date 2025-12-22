part of '../main.dart';

// --- 2. SETUP HUB ---
class SetupHubScreen extends StatefulWidget {
  const SetupHubScreen({super.key});

  @override
  State<SetupHubScreen> createState() => _SetupHubScreenState();
}

class _SetupHubScreenState extends State<SetupHubScreen>
    with SingleTickerProviderStateMixin {
  bool _teamsExpanded = false;
  late final ScrollController _setupScrollController;

  @override
  void initState() {
    super.initState();
    _setupScrollController = ScrollController();
  }

  @override
  void dispose() {
    _setupScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final messenger = ScaffoldMessenger.of(context);
    final reduceMotion = game.reducedMotion;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Oyun Ayarları"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompactHeight = constraints.maxHeight < 720;
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 24.0;

            return Scrollbar(
              controller: _setupScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _setupScrollController,
                primary: false,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  horizontalPadding,
                  horizontalPadding,
                  horizontalPadding + MediaQuery.of(context).padding.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: isCompactHeight ? 8 : 16),
                      _MenuButton(
                        label: "TAKIM YÖNETİMİ",
                        color: Colors.purple,
                        icon: Icons.groups,
                        trailingIcon: _teamsExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        onTap: () =>
                            setState(() => _teamsExpanded = !_teamsExpanded),
                      ),
                      if (reduceMotion)
                        (_teamsExpanded
                            ? Container(
                                margin: const EdgeInsets.only(
                                  top: 14,
                                  bottom: 6,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const TeamManagerPanel(
                                  showCloseButton: false,
                                ),
                              )
                            : const SizedBox.shrink())
                      else
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: _teamsExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox.shrink(),
                          secondChild: Container(
                            margin: const EdgeInsets.only(top: 14, bottom: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const TeamManagerPanel(
                              showCloseButton: false,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      _MenuButton(
                        label: "KATEGORİLERİ YÖNET",
                        color: Colors.orange,
                        icon: Icons.category,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryManagementScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildUniqueSelector(
                              "Süre (saniye)",
                              [30, 45, 60, 75, 90],
                              game.roundTime,
                              (val) {
                                if (val == game.roundTime) return;
                                game.updateSettings(time: val);
                                messenger.removeCurrentSnackBar();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Tur süresi $val sn olarak kaydedildi",
                                    ),
                                  ),
                                );
                              },
                              labelBuilder: (val) => "$val",
                              reduceMotion: reduceMotion,
                            ),
                            const Divider(color: Colors.white24),
                            _buildUniqueSelector(
                              "Hedef Puan",
                              [20, 30, 50, 75, -1],
                              game.targetScore,
                              (val) {
                                if (val == game.targetScore) return;
                                game.updateSettings(score: val);
                                final label = val == -1
                                    ? "Hedef yok. Oyun istenilen sürede kazanılır!"
                                    : "$val puana ulaşan kazanır!";
                                messenger.removeCurrentSnackBar();
                                messenger.showSnackBar(
                                  SnackBar(content: Text(label)),
                                );
                              },
                              labelBuilder: (val) => val == -1 ? "-" : "$val",
                              reduceMotion: reduceMotion,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: [
                          _InfoChip(
                            icon: Icons.timer,
                            label: "Tur süresi: ${game.roundTime} saniye",
                          ),
                          _InfoChip(
                            icon: Icons.flag,
                            label: game.targetScore == -1
                                ? "Hedef yok. Oyun istenilen sürede kazanılır!"
                                : "Oyunu kazanmak için hedef: ${game.targetScore} puan",
                          ),
                        ],
                      ),

                      SizedBox(height: isCompactHeight ? 18 : 28),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await game.playClick();
                          if (!context.mounted) return;
                          if (game.teamA.length < 2 || game.teamB.length < 2) {
                            String msg = "";
                            if (game.teamA.length < 2) {
                              msg =
                                  "${game.teamAName} takımında eksik oyuncu var.";
                            } else if (game.teamB.length < 2) {
                              msg =
                                  "${game.teamBName} takımında eksik oyuncu var.";
                            }
                            _showSnack(messenger, msg);
                            return;
                          }
                          if (game.teamA.length != game.teamB.length) {
                            _showSnack(
                              messenger,
                              "Takımlardaki oyuncu sayıları eşit olmalı.",
                            );
                            return;
                          }
                          game.startGame();
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const DiceRollDialog(),
                          );
                        },
                        child: const Text(
                          "ZAR AT & OYNA",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildUniqueSelector(
    String label,
    List<int> options,
    int currentValue,
    Function(int) onSelect, {
    String Function(int)? labelBuilder,
    bool reduceMotion = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: options.map((opt) {
            bool isSelected = opt == currentValue;
            return GestureDetector(
              onTap: () async {
                await Provider.of<GameProvider>(context, listen: false)
                    .playClick();
                if (!context.mounted) return;
                onSelect(opt);
              },
              child: AnimatedContainer(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amber : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.amber : Colors.white54,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    labelBuilder != null ? labelBuilder(opt) : "$opt",
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? textColor;
  final Color? fillColor;
  const _InfoChip({
    required this.icon,
    required this.label,
    this.textColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = textColor ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: fillColor ?? Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.amber),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      ),
    );
  }
}

class TeamManagerPanel extends StatelessWidget {
  final bool showCloseButton;
  final VoidCallback? onClose;
  const TeamManagerPanel({
    super.key,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final messenger = ScaffoldMessenger.of(context);
    return Column(
      children: [
        _responsiveCards(context, game, messenger),
        if (showCloseButton)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await game.playClick();
                  if (!context.mounted) return;
                  if (onClose != null) {
                    onClose!();
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.all(14),
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
    );
  }

  Widget _responsiveCards(
    BuildContext context,
    GameProvider game,
    ScaffoldMessengerState messenger,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 620;
        final first = _buildTeamCard(context, game, true, messenger);
        final second = _buildTeamCard(context, game, false, messenger);
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: VerticalDivider(
                  color: Colors.white24,
                  thickness: 1,
                  width: 1,
                ),
              ),
              Expanded(child: second),
            ],
          );
        }
        return Column(
          children: [
            first,
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Colors.white24, thickness: 1),
            ),
            second,
          ],
        );
      },
    );
  }

  Widget _buildTeamCard(
    BuildContext context,
    GameProvider game,
    bool isTeamA,
    ScaffoldMessengerState messenger,
  ) {
    final Color badgeColor = isTeamA ? Colors.blueAccent : Colors.redAccent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isTeamA ? game.teamAName : game.teamBName,
                  style: TextStyle(
                    color: isTeamA ? Colors.blue : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70, size: 28),
                onPressed: () async {
                  await game.playClick();
                  if (!context.mounted) return;
                  _showEditTeamName(context, game, isTeamA);
                },
              ),
            ],
          ),
          if (isTeamA ? game.teamA.isEmpty : game.teamB.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Oyuncu yok",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ...(isTeamA ? game.teamA : game.teamB).map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.person, size: 24, color: badgeColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await game.playClick();
                      if (!context.mounted) return;
                      game.removePlayer(p, isTeamA);
                      final upperName = _turkishUpper(p);
                      _showSnack(
                        messenger,
                        "$upperName adlı oyuncu ${isTeamA ? game.teamAName : game.teamBName} takımından çıkarıldı",
                      );
                    },
                    child: const SizedBox(
                      width: 52,
                      height: 52,
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              await game.playClick();
              if (!context.mounted) return;
              _showAddPlayer(context, game, isTeamA);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, color: Colors.greenAccent, size: 24),
                SizedBox(width: 8),
                Text("Ekle", style: TextStyle(color: Colors.greenAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTeamName(
    BuildContext context,
    GameProvider game,
    bool isTeamA,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    TextEditingController c = TextEditingController(
      text: isTeamA ? game.teamAName : game.teamBName,
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Takım İsmi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c,
              maxLength: 16,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp('[A-Za-zÇçĞğİıÖöŞşÜü ]'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  await game.playClick();
                  final suggestion = game.randomTeamName(isTeamA);
                  c.text = suggestion;
                  c.selection = TextSelection.collapsed(offset: c.text.length);
                },
                icon: const Icon(Icons.casino, size: 22),
                label: const Text("Öner"),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              game.playClick();
              Navigator.pop(dialogContext);
            },
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              game.playClick();
              final error = game.setTeamName(isTeamA, c.text);
              if (error != null) {
                _showSnack(messenger, error);
                return;
              }
              final newName = isTeamA ? game.teamAName : game.teamBName;
              Navigator.pop(dialogContext);
              _showSnack(messenger, "$newName kaydedildi");
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  void _showAddPlayer(BuildContext context, GameProvider game, bool isTeamA) {
    final messenger = ScaffoldMessenger.of(context);
    TextEditingController c = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          "${isTeamA ? game.teamAName : game.teamBName} takımına oyuncu ekle",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c,
              maxLength: 16,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp('[A-Za-zÇçĞğİıÖöŞşÜü ]'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  await game.playClick();
                  final suggestion = game.randomPlayerName();
                  c.text = suggestion;
                  c.selection = TextSelection.collapsed(offset: c.text.length);
                },
                icon: const Icon(Icons.casino, size: 22),
                label: const Text("Öner"),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              game.playClick();
              Navigator.pop(dialogContext);
            },
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              game.playClick();
              final err = game.addPlayer(c.text, isTeamA);
              if (err != null) {
                _showSnack(messenger, err);
                return;
              }
              Navigator.pop(dialogContext);
              final upperName = _turkishUpper(c.text);
              _showSnack(
                messenger,
                "$upperName adlı oyuncu ${isTeamA ? game.teamAName : game.teamBName} takımına eklendi",
              );
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }
}
