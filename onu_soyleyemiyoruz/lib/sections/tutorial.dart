part of '../main.dart';

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
  late final ScrollController _tutorialScrollController;

  @override
  void initState() {
    super.initState();
    _tutorialScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = Provider.of<GameProvider>(context, listen: false);
      if (!game.tutorialTipShown) {
        _showFirstTimeTooltip(game);
      }
    });
  }

  @override
  void dispose() {
    _tutorialScrollController.dispose();
    super.dispose();
  }

  void _showFirstTimeTooltip(GameProvider game) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(game.t("quick_tip_title")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.timer),
              title: Text(game.t("tip_time_title")),
              subtitle: Text(game.t("tip_time_body")),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.skip_next),
              title: Text(game.t("tip_pass_title")),
              subtitle: Text(game.t("tip_pass_body")),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.block),
              title: Text(game.t("tip_taboo_title")),
              subtitle: Text(game.t("tip_taboo_body")),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Provider.of<GameProvider>(
                context,
                listen: false,
              ).playClick();
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: Text(game.t("got_it")),
          ),
        ],
      ),
    ).then((_) => game.markTutorialTipSeen());
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(game.t("how_to_play")),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await Provider.of<GameProvider>(context, listen: false).playClick();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
      ),
      body: GameBackground(
        child: Scrollbar(
          controller: _tutorialScrollController,
          thumbVisibility: true,
          child: ListView(
            controller: _tutorialScrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.t("game_summary_title"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.t("game_summary_body"),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _TutorialTipCard(
                icon: Icons.timer,
                title: game.t("tip_time_management_title"),
                description: game.t("tip_time_management_body"),
              ),
              _TutorialTipCard(
                icon: Icons.skip_next,
                title: game.t("tip_pass_right_title"),
                description: game.t("tip_pass_right_body"),
              ),
              _TutorialTipCard(
                icon: Icons.block,
                title: game.t("tip_taboo_penalty_title"),
                description: game.t("tip_taboo_penalty_body"),
              ),
              _TutorialTipCard(
                icon: Icons.record_voice_over,
                title: game.t("tip_narrator_cycle_title"),
                description: game.t("tip_narrator_cycle_body"),
              ),
              _TutorialTipCard(
                icon: Icons.settings_voice,
                title: game.t("tip_feedback_title"),
                description: game.t("tip_feedback_body"),
              ),
            ],
          ),
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
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.2),
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
