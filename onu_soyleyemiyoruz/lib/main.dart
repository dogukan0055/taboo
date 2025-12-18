import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'game_provider.dart';
import 'models.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Onu Söyleyemiyoruz',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const MainMenuScreen(),
    );
  }
}

class GameBackground extends StatelessWidget {
  final Widget child;
  const GameBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E0249), Color(0xFF570A57), Color(0xFFA91079)],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

// --- 1. MAIN MENU ---
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.question_answer_outlined,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),
              const Text(
                "ONU\nSÖYLEYEMİYORUZ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const Spacer(),
              _MenuButton(
                label: "OYNA",
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SetupHubScreen()),
                ),
              ),
              const SizedBox(height: 15),
              _MenuButton(
                label: "AYARLAR",
                color: Colors.teal,
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const SettingsSheet(),
                ),
              ),
              const SizedBox(height: 15),
              _MenuButton(
                label: "NASIL OYNANIR?",
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TutorialScreen()),
                ),
              ),
              const SizedBox(height: 15),
              _MenuButton(
                label: "ÇIKIŞ",
                color: Colors.red,
                onTap: () => SystemNavigator.pop(),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;
  const _MenuButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 2. SETUP HUB ---
class SetupHubScreen extends StatefulWidget {
  const SetupHubScreen({super.key});

  @override
  State<SetupHubScreen> createState() => _SetupHubScreenState();
}

class _SetupHubScreenState extends State<SetupHubScreen> {
  bool _teamsExpanded = false;

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final messenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Oyun Ayarları"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GameBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              _MenuButton(
                label: "TAKIM YÖNETİMİ",
                color: Colors.purple,
                icon: _teamsExpanded ? Icons.expand_less : Icons.groups,
                onTap: () => setState(() => _teamsExpanded = !_teamsExpanded),
              ),
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
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const TeamManagerPanel(showCloseButton: false),
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
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildUniqueSelector(
                      "Süre (saniye)",
                      [30, 45, 60, 75, 90],
                      game.roundTime,
                      (val) {
                        game.updateSettings(time: val);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              "Tur süresi $val sn olarak kaydedildi",
                            ),
                          ),
                        );
                      },
                      labelBuilder: (val) => "$val",
                    ),
                    const Divider(color: Colors.white24),
                    _buildUniqueSelector(
                      "Hedef Puan",
                      [20, 30, 50, 75, -1],
                      game.targetScore,
                      (val) {
                        game.updateSettings(score: val);
                        final label = val == -1
                            ? "Hedef yok. Oyun istenilen sürede kazanılır!"
                            : "$val puana ulaşan kazanır!";
                        messenger.showSnackBar(SnackBar(content: Text(label)));
                      },
                      labelBuilder: (val) => val == -1 ? "Yok" : "$val",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.timer,
                    label: "Tur süresi: ${game.roundTime} saniye",
                  ),
                  const SizedBox(width: 10),
                  _InfoChip(
                    icon: Icons.flag,
                    label: game.targetScore == -1
                        ? "Hedef yok. Oyun istenilen sürede kazanılır!"
                        : "Oyunu kazanmak için hedef: ${game.targetScore} puan",
                  ),
                ],
              ),

              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (game.teamA.length < 2 || game.teamB.length < 2) {
                    String msg = "";
                    if (game.teamA.length < 2) {
                      msg = "${game.teamAName} takımında eksik oyuncu var.";
                    } else if (game.teamB.length < 2) {
                      msg = "${game.teamBName} takımında eksik oyuncu var.";
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (game.teamA.length != game.teamB.length) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Takımlardaki oyuncu sayıları eşit olmalı.",
                        ),
                        backgroundColor: Colors.orange,
                      ),
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
  }

  Widget _buildUniqueSelector(
    String label,
    List<int> options,
    int currentValue,
    Function(int) onSelect, {
    String Function(int)? labelBuilder,
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
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amber : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.amber : Colors.white54,
                    width: 2,
                  ),
                ),
                child: Text(
                  labelBuilder != null ? labelBuilder(opt) : "$opt",
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
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
        color: fillColor ?? Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.3)),
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
                onPressed: onClose ?? () => Navigator.pop(context),
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
              const SizedBox(width: 12),
              Expanded(child: second),
            ],
          );
        }
        return Column(children: [first, const SizedBox(height: 10), second]);
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isTeamA ? game.teamAName : game.teamBName,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => _showEditTeamName(context, game, isTeamA),
                child: const Icon(Icons.edit, color: Colors.white70, size: 18),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
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
                  Icon(Icons.person, size: 18, color: badgeColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      game.removePlayer(p, isTeamA);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            "$p adlı oyuncu ${isTeamA ? game.teamAName : game.teamBName} takımından çıkarıldı",
                          ),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showAddPlayer(context, game, isTeamA),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, color: Colors.greenAccent, size: 16),
                SizedBox(width: 4),
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
        content: TextField(controller: c, maxLength: 16),
        actions: [
          ElevatedButton(
            onPressed: () {
              final error = game.setTeamName(isTeamA, c.text);
              if (error != null) {
                messenger.showSnackBar(SnackBar(content: Text(error)));
                return;
              }
              final newName = isTeamA ? game.teamAName : game.teamBName;
              Navigator.pop(dialogContext);
              messenger.showSnackBar(
                SnackBar(content: Text("$newName kaydedildi")),
              );
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
        title: Text("${isTeamA ? game.teamAName : game.teamBName} oyuncu ekle"),
        content: TextField(controller: c, maxLength: 12),
        actions: [
          ElevatedButton(
            onPressed: () {
              final err = game.addPlayer(c.text, isTeamA);
              if (err != null) {
                messenger.showSnackBar(SnackBar(content: Text(err)));
                return;
              }
              Navigator.pop(dialogContext);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    "${c.text} ${isTeamA ? game.teamAName : game.teamBName} takımına eklendi",
                  ),
                ),
              );
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }
}

// --- 2.1 TEAM MANAGEMENT ---
class TeamManagementScreen extends StatelessWidget {
  const TeamManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Takım Yönetimi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GameBackground(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildTeamCard(context, game, true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTeamCard(context, game, false)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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

  Widget _buildTeamCard(BuildContext context, GameProvider game, bool isTeamA) {
    final Color badgeColor = isTeamA ? Colors.blueAccent : Colors.redAccent;
    final messenger = ScaffoldMessenger.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isTeamA ? game.teamAName : game.teamBName,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => _showEditTeamName(context, game, isTeamA),
                child: const Icon(Icons.edit, color: Colors.white70, size: 18),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
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
                  Icon(Icons.person, size: 18, color: badgeColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      game.removePlayer(p, isTeamA);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            "$p adlı oyuncu ${isTeamA ? game.teamAName : game.teamBName} takımından çıkarıldı",
                          ),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showAddPlayer(context, game, isTeamA),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, color: Colors.greenAccent, size: 16),
                SizedBox(width: 4),
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
        content: TextField(controller: c, maxLength: 16),
        actions: [
          ElevatedButton(
            onPressed: () {
              final error = game.setTeamName(isTeamA, c.text);
              if (error != null) {
                messenger.showSnackBar(SnackBar(content: Text(error)));
                return;
              }
              final newName = isTeamA ? game.teamAName : game.teamBName;
              Navigator.pop(dialogContext);
              messenger.showSnackBar(
                SnackBar(content: Text("$newName kaydedildi")),
              );
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
        title: const Text("Oyuncu Ekle"),
        content: TextField(controller: c, maxLength: 12),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (c.text.trim().isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text("İsim boş olamaz")),
                );
                return;
              }
              final error = game.addPlayer(c.text, isTeamA);
              if (error != null) {
                messenger.showSnackBar(SnackBar(content: Text(error)));
                return;
              }
              final addedName = game.validateInput(c.text) ?? c.text.trim();
              Navigator.pop(dialogContext);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    "$addedName adlı oyuncu ${isTeamA ? game.teamAName : game.teamBName} takımına eklendi",
                  ),
                ),
              );
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }
}

// --- 2.2 CATEGORY MANAGEMENT (Switches) ---
class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
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
      appBar: AppBar(
        title: const Text("Kategorileri Yönet"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GameBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: game.availableCategories.map((cat) {
                  List<WordCard> words = wordsMap[cat] ?? [];
                  bool isCatSelected = game.selectedCategories.contains(cat);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
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
                              onChanged: (_) => game.toggleCategory(cat),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              categoryIcons[cat] ?? Icons.category,
                              color: isCatSelected
                                  ? Colors.amber
                                  : Colors.white54,
                            ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Text(
                              cat,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          "${words.length} Kelime",
                          style: const TextStyle(color: Colors.white54),
                        ),
                        children: [
                          Container(
                            color: Colors.black26,
                            child: Column(
                              children: words.map((w) {
                                bool isDisabled = game.disabledCardIds.contains(
                                  w.id,
                                );
                                return SwitchListTile(
                                  title: Text(
                                    w.word,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  secondary: Icon(
                                    categoryIcons[cat] ?? Icons.style,
                                    color: Colors.white54,
                                  ),
                                  value: !isDisabled,
                                  activeThumbColor: Colors.amber,
                                  onChanged: isCatSelected
                                      ? (val) {
                                          game.toggleWordStatus(w.id);
                                        }
                                      : null,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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

// --- DICE ROLL DIALOG ---
class DiceRollDialog extends StatefulWidget {
  const DiceRollDialog({super.key});
  @override
  State<DiceRollDialog> createState() => _DiceRollDialogState();
}

class _DiceRollDialogState extends State<DiceRollDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _displayDiceA = 1;
  int _displayDiceB = 1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _ctrl.addListener(() {
      if (_ctrl.isAnimating) {
        setState(() {
          _displayDiceA = Random().nextInt(6) + 1;
          _displayDiceB = Random().nextInt(6) + 1;
        });
      }
    });

    _ctrl.forward().then((_) {
      var game = Provider.of<GameProvider>(context, listen: false);
      game.rollDice();
      setState(() {
        _displayDiceA = game.teamADice;
        _displayDiceB = game.teamBDice;
      });
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RoundStartScreen()),
        );
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context, listen: false);
    return AlertDialog(
      backgroundColor: Colors.deepPurple,
      title: const Text(
        "ZARLAR ATILIYOR!",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDiceColumn(game.teamAName, _displayDiceA, Colors.blue),
              _buildDiceColumn(game.teamBName, _displayDiceB, Colors.red),
            ],
          ),
          const SizedBox(height: 20),
          if (!_ctrl.isAnimating)
            Text(
              "Oyuna ${game.isTeamATurn ? game.teamAName : game.teamBName} TAKIMI BAŞLIYOR!",
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDiceColumn(String team, int val, Color c) {
    return Column(
      children: [
        Text(
          team,
          style: TextStyle(color: c, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c, width: 3),
          ),
          alignment: Alignment.center,
          child: Text(
            "$val",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

// --- 3. ROUND START ---
class RoundStartScreen extends StatelessWidget {
  const RoundStartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    bool isA = game.isTeamATurn;
    return Scaffold(
      backgroundColor: isA ? Colors.blue[900] : Colors.red[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "SIRADAKİ",
              style: TextStyle(color: Colors.white54, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            Text(
              "TAKIM: ${isA ? game.teamAName : game.teamBName}",
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "ANLATICI: ${game.currentNarrator}",
              style: const TextStyle(
                fontSize: 24,
                color: Colors.amber,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 40),

            // Explicit Team Score Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Text(
                        game.teamAName,
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                      Text(
                        "${game.teamAScore}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "-",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      Text(
                        game.teamBName,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      Text(
                        "${game.teamBScore}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            _InfoChip(
              icon: Icons.layers,
              label: "${game.remainingCards} kalan kart",
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (game.allCardsUsed) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const GameOverScreen()),
                  );
                  return;
                }
                game.startRound();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const GamePlayScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
              ),
              child: const Text(
                "BAŞLA",
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4. GAMEPLAY SCREEN ---
class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key});
  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  final List<Widget> _floatingTexts = [];
  int? _lastRemainingNotified;
  void _showFloatingText(String text, Color color) {
    final UniqueKey key = UniqueKey();
    setState(() {
      _floatingTexts.add(
        _FloatingTextItem(
          key: key,
          text: text,
          color: color,
          onComplete: () {
            setState(() {
              _floatingTexts.removeWhere((element) => element.key == key);
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final remaining = game.remainingCards;
    if (remaining > 0 &&
        remaining <= 10 &&
        remaining != _lastRemainingNotified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$remaining kart kaldı")));
        setState(() {
          _lastRemainingNotified = remaining;
        });
      });
    }
    if (game.timeLeft == 0) {
      Future.microtask(
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoundReportScreen()),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          GameBackground(
            child: Column(
              children: [
                _buildScoreHeader(game),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCardContent(game.currentCard),
                    ),
                  ),
                ),
                _buildFeedbackToggles(game),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BouncingButton(
                        icon: Icons.close,
                        color: Colors.red,
                        label: "TABU",
                        disabled: game.isCoolingDown,
                        onTap: () {
                          _showFloatingText("TABU!", Colors.redAccent);
                          game.actionTaboo();
                        },
                      ),
                      game.currentPasses > 0
                          ? BouncingButton(
                              icon: Icons.skip_next,
                              color: Colors.blue,
                              label: "PAS",
                              badgeText: "${game.currentPasses}",
                              disabled: game.isCoolingDown,
                              onTap: () {
                                _showFloatingText("PAS", Colors.blueAccent);
                                game.actionPass();
                              },
                            )
                          : Opacity(
                              opacity: 0.5,
                              child: BouncingButton(
                                icon: Icons.skip_next,
                                color: Colors.grey,
                                label: "PAS",
                                badgeText: "0",
                                disabled: true,
                                onTap: () {},
                              ),
                            ),
                      BouncingButton(
                        icon: Icons.check,
                        color: Colors.green,
                        label: "DOĞRU",
                        disabled: game.isCoolingDown,
                        onTap: () {
                          _showFloatingText("DOĞRU!", Colors.greenAccent);
                          game.actionCorrect();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ..._floatingTexts,
        ],
      ),
    );
  }

  Widget _buildFeedbackToggles(GameProvider game) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 6),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          _buildFeedbackToggle(
            icon: game.soundEnabled ? Icons.volume_up : Icons.volume_off,
            label: game.soundEnabled ? "Ses Açık" : "Ses Kapalı",
            isActive: game.soundEnabled,
            onTap: () => game.toggleSound(!game.soundEnabled),
          ),
          _buildFeedbackToggle(
            icon: game.vibrationEnabled ? Icons.vibration : Icons.phone_android,
            label: game.vibrationEnabled ? "Titreşim Açık" : "Titreşim Kapalı",
            isActive: game.vibrationEnabled,
            onTap: () => game.toggleVibration(!game.vibrationEnabled),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackToggle({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.black26,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.amber : Colors.white24,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreHeader(GameProvider game) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTeamScoreItem(
                game.teamAName,
                game.teamAScore,
                Colors.blueAccent,
                game.isTeamATurn,
              ),
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.deepPurple, width: 4),
              ),
              alignment: Alignment.center,
              child: Text(
                "${game.timeLeft}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Expanded(
              child: _buildTeamScoreItem(
                game.teamBName,
                game.teamBScore,
                Colors.redAccent,
                !game.isTeamATurn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamScoreItem(
    String name,
    int score,
    Color color,
    bool isActive,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.8) : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "$score",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              shadows: isActive
                  ? [const BoxShadow(blurRadius: 10, color: Colors.black45)]
                  : [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(WordCard? card) {
    if (card == null) return Container(key: const ValueKey("empty"));
    return Container(
      key: ValueKey(card.id),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [const BoxShadow(blurRadius: 20, color: Colors.black45)],
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            alignment: Alignment.center,
            child: Text(
              card.category.toUpperCase(),
              style: const TextStyle(
                color: Colors.white38,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card.word,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 2, indent: 40, endIndent: 40),
                const SizedBox(height: 20),
                ...card.tabooWords.map(
                  (t) => Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BouncingButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? badgeText;
  final VoidCallback onTap;
  final bool disabled;
  const BouncingButton({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.badgeText,
    this.disabled = false,
  });
  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _s = Tween<double>(begin: 1.0, end: 0.9).animate(_c);
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    return GestureDetector(
      onTapDown: (_) {
        if (widget.disabled) return;
        _c.forward();
      },
      onTapUp: (_) {
        if (widget.disabled) return;
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _s,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.disabled
                        ? widget.color.withOpacity(0.5)
                        : widget.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 30),
                ),
                if (widget.badgeText != null)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(
                        widget.badgeText!,
                        style: TextStyle(
                          color: widget.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (widget.disabled)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black45,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.hourglass_bottom,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingTextItem extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onComplete;
  const _FloatingTextItem({
    super.key,
    required this.text,
    required this.color,
    required this.onComplete,
  });
  @override
  State<_FloatingTextItem> createState() => _FloatingTextItemState();
}

class _FloatingTextItemState extends State<_FloatingTextItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<Offset> _p;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _p = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.0),
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));
    _c.forward().then((_) => widget.onComplete());
  }

  @override
  Widget build(BuildContext context) => Center(
    child: SlideTransition(
      position: _p,
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 1,
          end: 0,
        ).animate(CurvedAnimation(parent: _c, curve: const Interval(0.6, 1))),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w900,
            color: widget.color,
            shadows: const [BoxShadow(blurRadius: 10, color: Colors.black45)],
          ),
        ),
      ),
    ),
  );
}

Future<bool> _confirmExitToMenu(
  BuildContext context, {
  bool force = false,
}) async {
  final shouldExit =
      await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Ana menüye dönülsün mü?"),
          content: const Text("Oyundan çıkmak istediğine emin misin?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("HAYIR"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("EVET"),
            ),
          ],
        ),
      ) ??
      false;
  if (shouldExit) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      (route) => false,
    );
    return false;
  }
  return false;
}

// --- 5. REPORT SCREEN (Simple Cards, No Poker) ---
class RoundReportScreen extends StatelessWidget {
  const RoundReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final correctList = game.roundHistory
        .where((e) => e.status == CardStatus.correct)
        .toList();
    final tabooList = game.roundHistory
        .where((e) => e.status == CardStatus.taboo)
        .toList();
    final passList = game.roundHistory
        .where((e) => e.status == CardStatus.pass)
        .toList();

    return WillPopScope(
      onWillPop: () => _confirmExitToMenu(context),
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
              onPressed: () => _confirmExitToMenu(context, force: true),
            ),
            bottom: const TabBar(
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepPurple,
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
                        label: "Kalan kart: ${game.remainingCards}",
                        textColor: Colors.black87,
                        fillColor: Colors.grey[200],
                      ),
                      if (game.allCardsUsed)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _InfoChip(
                            icon: Icons.check_circle,
                            label: "Kartlar bitti",
                            textColor: Colors.black87,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSimpleCardList(correctList, Colors.green),
                      _buildSimpleCardList(tabooList, Colors.red),
                      _buildSimpleCardList(passList, Colors.blue),
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
                      onPressed: () {
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
  Widget _buildSimpleCardList(List<RoundEvent> events, Color color) {
    if (events.isEmpty) {
      return Center(
        child: Text("Kart yok", style: TextStyle(color: Colors.grey[500])),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final card = events[index].card;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.9), color.withOpacity(0.65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  card.category.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                card.word,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
              Container(
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: card.tabooWords
                    .map(
                      (t) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 0.6,
                            ),
                          ),
                          child: Text(
                            t,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- 6. GAME OVER SCREEN ---
class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context, listen: false);
    return Scaffold(
      body: GameBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
                const SizedBox(height: 20),
                const Text(
                  "OYUN BİTTİ",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 10),
                if (game.endMessage != null)
                  Text(
                    game.endMessage!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (game.endMessage != null) const SizedBox(height: 10),
                if (game.gameWinner != null)
                  const Text(
                    "KAZANAN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  game.gameWinner ?? "BERABERE",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    shadows: [BoxShadow(color: Colors.black, blurRadius: 20)],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _finalScoreItem(
                        game.teamAName,
                        game.teamAScore,
                        Colors.blue,
                      ),
                      const Text(
                        "-",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _finalScoreItem(
                        game.teamBName,
                        game.teamBScore,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 38,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    "RÖVANŞ?",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "ANA MENÜYE DÖN",
                    style: TextStyle(color: Colors.deepPurple, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _finalScoreItem(String name, int score, Color c) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(color: c, fontWeight: FontWeight.bold),
        ),
        Text(
          "$score",
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Text(
              "AYARLAR",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text("Müzik"),
              secondary: const Icon(Icons.music_note),
              value: game.musicEnabled,
              onChanged: game.toggleMusic,
            ),
            SwitchListTile(
              title: const Text("Ses Efektleri"),
              secondary: const Icon(Icons.surround_sound),
              value: game.soundEnabled,
              onChanged: game.toggleSound,
            ),
            SwitchListTile(
              title: const Text("Titreşim"),
              secondary: const Icon(Icons.vibration),
              value: game.vibrationEnabled,
              onChanged: game.toggleVibration,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.all(14),
                ),
                child: const Text(
                  "Kapat",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const _TutorialScreenBody();
  }
}

class _TutorialScreenBody extends StatefulWidget {
  const _TutorialScreenBody();

  @override
  State<_TutorialScreenBody> createState() => _TutorialScreenBodyState();
}

class _TutorialScreenBodyState extends State<_TutorialScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = Provider.of<GameProvider>(context, listen: false);
      if (!game.tutorialTipShown) {
        _showFirstTimeTooltip(game);
      }
    });
  }

  void _showFirstTimeTooltip(GameProvider game) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hızlı Başlangıç İpucu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.timer),
              title: Text("Sure"),
              subtitle: Text(
                "Her turda geri sayılan zaman dolunca tur otomatik biter.",
              ),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.skip_next),
              title: Text("Paslar"),
              subtitle: Text(
                "En fazla 3 pas hakkın var; her bastığında bir hak azalir.",
              ),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.block),
              title: Text("Tabu"),
              subtitle: Text(
                "Tabu sözcükleri soylersen puan kaybedersin, kart değişir.",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anladim"),
          ),
        ],
      ),
    ).then((_) => game.markTutorialTipSeen());
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nasıl Oynanır?"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GameBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Oyunun Özeti",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Takımlar, anlatıcının tabu kelimelerini kullanmadan karttaki ana kelimeyi anlattığı bir tahmin oyunu oynar.",
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _TutorialTipCard(
              icon: Icons.timer,
              title: "Süre Yönetimi",
              description:
                  "Her tur 30 ila 90 (isteğe bağlı) saniye arasında sürer. Sayaç ekranın ortasındadır; 0 olunca tur biter ve puanlar görünür.",
            ),
            _TutorialTipCard(
              icon: Icons.skip_next,
              title: "Pas Hakların",
              description:
                  "Tur başlangıcında 3 pas hakkın olur. 3 defa kart geçtiğinde, yani 'PAS' butonuna bastığında daha fazla kart geçemezsin.",
            ),
            _TutorialTipCard(
              icon: Icons.block,
              title: "Tabu Cezası",
              description:
                  "Tabu kelime söylendiğinde veya yakalandığında takım puanı bir azalır ve yeni karta geçilir.",
            ),
            _TutorialTipCard(
              icon: Icons.record_voice_over,
              title: "Anlatıcı Döngüsü",
              description:
                  "Takım sırası ekranının üstündeki 'Anlatan' alanında görünür; her tur sonunda anlatıcı bir sonraki oyuncuya geçer.",
            ),
            _TutorialTipCard(
              icon: Icons.settings_voice,
              title: "Geri Bildirim",
              description:
                  "Tabu/Doğru/Pas butonların altındaki ses ve titreşim kısayolları ile anında dokunsal/işitsel geri bildirimi aç/kapa yapabilirsin.",
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialTipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _TutorialTipCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
