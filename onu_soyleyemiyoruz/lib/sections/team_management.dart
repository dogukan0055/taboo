part of '../main.dart';

// --- 2.1 TEAM MANAGEMENT ---
class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  late final ScrollController _teamScrollController;

  @override
  void initState() {
    super.initState();
    _teamScrollController = ScrollController();
  }

  @override
  void dispose() {
    _teamScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Takım Yönetimi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: GameBackground(
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _teamScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _teamScrollController,
                  primary: false,
                  padding: const EdgeInsets.all(16),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildTeamCard(context, game, true)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: VerticalDivider(
                            color: Colors.white24,
                            thickness: 1,
                            width: 1,
                          ),
                        ),
                        Expanded(child: _buildTeamCard(context, game, false)),
                      ],
                    ),
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
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isTeamA ? game.teamAName : game.teamBName,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  final suggestion = game.randomTeamName(isTeamA);
                  final error = game.setTeamName(isTeamA, suggestion);
                  if (error != null) {
                    _showSnack(messenger, error);
                  } else {
                    _showSnack(messenger, "$suggestion önerildi");
                  }
                },
                icon: const Icon(Icons.casino, color: Colors.white70, size: 26),
                label: const Text(
                  "Öner",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70, size: 28),
                onPressed: () => _showEditTeamName(context, game, isTeamA),
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
                    onTap: () {
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
            onTap: () => _showAddPlayer(context, game, isTeamA),
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
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z ]')),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
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
          ElevatedButton(
            onPressed: () {
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
        title: const Text("Oyuncu Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c,
              maxLength: 12,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z ]')),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
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
          ElevatedButton(
            onPressed: () {
              if (c.text.trim().isEmpty) {
                _showSnack(messenger, "İsim boş olamaz");
                return;
              }
              final error = game.addPlayer(c.text, isTeamA);
              if (error != null) {
                _showSnack(messenger, error);
                return;
              }
              final addedName = game.validateInput(c.text) ?? c.text.trim();
              Navigator.pop(dialogContext);
              final upperName = _turkishUpper(addedName);
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
