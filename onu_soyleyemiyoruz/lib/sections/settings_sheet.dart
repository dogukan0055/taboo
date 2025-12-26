part of '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final messenger = ScaffoldMessenger.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color panelColor = isDark ? const Color(0xFF1D1A22) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color iconColor = isDark ? Colors.white70 : Colors.black54;
    final Color adsCardColor =
        isDark ? const Color(0xFF241B33) : const Color(0xFFF6F1FF);
    final Color adsAccent = Colors.deepPurple;
    final Color adsBorder = isDark ? Colors.white24 : Colors.black12;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(game.t("settings_title")),
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
        child: Container(
          color: panelColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth < 380 ? 16.0 : 24.0;
              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    horizontalPadding,
                    horizontalPadding,
                    horizontalPadding + MediaQuery.of(context).padding.bottom,
                  ),
                  children: [
                    SwitchListTile(
                      title: Text(
                        game.t("settings_music"),
                        style: TextStyle(color: textColor),
                      ),
                      secondary: game.musicEnabled
                          ? Icon(Icons.music_note, color: iconColor)
                          : Icon(Icons.music_off, color: iconColor),
                      value: game.musicEnabled,
                      onChanged: (val) async {
                        await game.playClick();
                        game.toggleMusic(val);
                      },
                    ),
                    SwitchListTile(
                      title: Text(
                        game.t("settings_sfx"),
                        style: TextStyle(color: textColor),
                      ),
                      secondary: game.soundEnabled
                          ? Icon(Icons.volume_up_outlined, color: iconColor)
                          : Icon(Icons.volume_off_outlined, color: iconColor),
                      value: game.soundEnabled,
                      onChanged: (val) async {
                        game.toggleSound(val);
                        if (val) {
                          await game.playClick(force: true);
                        }
                      },
                    ),
                    SwitchListTile(
                      title: Text(
                        game.t("settings_vibration"),
                        style: TextStyle(color: textColor),
                      ),
                      secondary: game.vibrationEnabled
                          ? Icon(Icons.vibration, color: iconColor)
                          : Icon(Icons.phone_iphone, color: iconColor),
                      value: game.vibrationEnabled,
                      onChanged: (val) async {
                        await game.playClick();
                        game.toggleVibration(val);
                      },
                    ),
                    SwitchListTile(
                      title: Text(
                        game.t("settings_performance"),
                        style: TextStyle(color: textColor),
                      ),
                      secondary: Icon(
                        Icons.speed,
                        color: game.reducedMotion ? Colors.amber : iconColor,
                      ),
                      value: game.reducedMotion,
                      onChanged: (val) async {
                        await game.playClick();
                        game.toggleReducedMotion(val);
                      },
                    ),
                    if (game.gameCenterSupported) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          game.t("game_center_title"),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              game.t("game_center_desc"),
                              style: TextStyle(color: iconColor),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: game.gameCenterSignedIn
                                  ? null
                                  : () async {
                                      await game.playClick();
                                      final ok =
                                          await game.connectGameCenter();
                                      if (!context.mounted) return;
                                      if (!ok) {
                                        _showSnack(
                                          messenger,
                                          game.t("game_center_connect_failed"),
                                          isError: true,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: game.gameCenterSignedIn
                                    ? Colors.grey
                                    : Colors.deepPurple,
                                padding: const EdgeInsets.all(12),
                              ),
                              child: Text(
                                game.gameCenterSignedIn
                                    ? game.t("game_center_connected")
                                    : game.t("game_center_connect"),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: () async {
                                await game.playClick();
                                final ok =
                                    await game.openGameCenterAchievements();
                                if (!context.mounted) return;
                                if (!ok) {
                                  _showSnack(
                                    messenger,
                                    game.t("game_center_achievements_failed"),
                                    isError: true,
                                  );
                                }
                              },
                              child: Text(game.t("game_center_achievements")),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        game.t("ads_section_title"),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: adsCardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: adsBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.08,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: adsAccent.withValues(
                                    alpha: isDark ? 0.28 : 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  game.adsRemoved
                                      ? Icons.check_circle
                                      : Icons.block,
                                  color: adsAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      game.t("remove_ads"),
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      game.t("remove_ads_desc"),
                                      style: TextStyle(color: iconColor),
                                    ),
                                  ],
                                ),
                              ),
                              if (game.removeAdsPrice != null &&
                                  !game.adsRemoved)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: adsAccent.withValues(
                                      alpha: isDark ? 0.2 : 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    game.removeAdsPrice!,
                                    style: TextStyle(
                                      color: adsAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            game.adsRemoved
                                ? game.t("remove_ads_owned")
                                : game.t("remove_ads_desc"),
                            style: TextStyle(
                              color: iconColor,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: game.adsRemoved || !game.iapAvailable
                                  ? null
                                  : () async {
                                      await game.playClick();
                                      await game.buyRemoveAds();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: game.adsRemoved
                                    ? Colors.grey
                                    : adsAccent,
                                padding: const EdgeInsets.all(14),
                              ),
                              icon: Icon(
                                game.adsRemoved
                                    ? Icons.check
                                    : Icons.shopping_cart_outlined,
                                color: Colors.white,
                              ),
                              label: Text(
                                game.adsRemoved
                                    ? game.t("remove_ads_owned")
                                    : game.t("remove_ads"),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: game.iapAvailable
                                ? () async {
                                    await game.playClick();
                                    await game.restorePurchases();
                                  }
                                : null,
                            icon: Icon(
                              Icons.restore,
                              color: iconColor,
                            ),
                            label: Text(
                              game.t("restore_purchases"),
                              style: TextStyle(color: iconColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await game.playClick();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.all(14),
                        ),
                        child: Text(
                          game.t("close"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
