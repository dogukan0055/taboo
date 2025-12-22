part of '../main.dart';

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
  late final bool _reduceMotion;

  @override
  void initState() {
    super.initState();
    _reduceMotion =
        Provider.of<GameProvider>(context, listen: false).reducedMotion;
    _ctrl = AnimationController(
      vsync: this,
      duration: _reduceMotion
          ? const Duration(milliseconds: 1)
          : const Duration(milliseconds: 2000),
    );
    _ctrl.addListener(() {
      if (_ctrl.isAnimating && !_reduceMotion) {
        setState(() {
          _displayDiceA = Random().nextInt(6) + 1;
          _displayDiceB = Random().nextInt(6) + 1;
        });
      }
    });

    _ctrl.forward().then((_) {
      if (!mounted) return;
      var game = Provider.of<GameProvider>(context, listen: false);
      game.rollDice();
      setState(() {
        _displayDiceA = game.teamADice;
        _displayDiceB = game.teamBDice;
      });
      Future.delayed(
        _reduceMotion
            ? const Duration(milliseconds: 400)
            : const Duration(seconds: 2),
        () {
        if (!mounted) return;
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildDiceColumn(
                  game.teamAName,
                  _displayDiceA,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDiceColumn(
                  game.teamBName,
                  _displayDiceB,
                  Colors.red,
                ),
              ),
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
        SizedBox(
          width: 140,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              team,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c, fontWeight: FontWeight.bold),
            ),
          ),
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
