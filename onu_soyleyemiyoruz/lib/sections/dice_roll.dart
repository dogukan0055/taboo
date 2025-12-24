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
        const Duration(seconds: 2),
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
      title: Text(
        game.t("rolling_dice"),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              game.t(
                "game_starts_with_team",
                params: {
                  "team": game.isTeamATurn ? game.teamAName : game.teamBName,
                },
              ),
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
        _buildDiceTile(val, c),
      ],
    );
  }

  Widget _buildDiceTile(int val, Color tint) {
    const Color lightFace = Color(0xFFF7F7F7);
    const Color darkFace = Color(0xFFE2E2E2);
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [lightFace, darkFace],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: tint.withValues(alpha: 0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.45),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.center,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: _buildDiceFace(val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiceFace(int val) {
    const Map<int, List<Alignment>> pipMap = {
      1: [Alignment.center],
      2: [Alignment.topLeft, Alignment.bottomRight],
      3: [Alignment.topLeft, Alignment.center, Alignment.bottomRight],
      4: [
        Alignment.topLeft,
        Alignment.topRight,
        Alignment.bottomLeft,
        Alignment.bottomRight,
      ],
      5: [
        Alignment.topLeft,
        Alignment.topRight,
        Alignment.center,
        Alignment.bottomLeft,
        Alignment.bottomRight,
      ],
      6: [
        Alignment.topLeft,
        Alignment.topRight,
        Alignment.centerLeft,
        Alignment.centerRight,
        Alignment.bottomLeft,
        Alignment.bottomRight,
      ],
    };
    final pips = pipMap[val] ?? const [Alignment.center];
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        final dotSize = (size * 0.18).clamp(5.0, 9.0);
        final inset = size * 0.08;
        return Stack(
          children: [
            for (final alignment in pips)
              Padding(
                padding: EdgeInsets.all(inset),
                child: Align(
                  alignment: alignment,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
