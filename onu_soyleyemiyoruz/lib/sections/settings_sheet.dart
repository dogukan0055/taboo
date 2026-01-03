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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Provider.of<GameProvider>(
        context,
        listen: false,
      ).refreshIapAvailability();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showSnack(
    ScaffoldMessengerState messenger,
    String message, {
    bool isSuccess = false,
    bool isError = false,
  }) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : isSuccess
            ? Colors.green
            : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final messenger = ScaffoldMessenger.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Size size = MediaQuery.of(context).size;
    final bool isWide = size.shortestSide >= 600;

    if (game.adsRemovalJustGranted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showSnack(
          messenger,
          game.isEnglish
              ? "Ads removed forever. All categories are unlocked!"
              : "Reklamlar kalıcı olarak kapandı. Bütün kategoriler açıldı!",
          isSuccess: true,
        );
        game.markAdsRemovalNotified();
      });
    }

    final Color textColor = isDark ? Colors.white : Colors.black;
    final double labelFont = isWide ? 18 : 16;
    final Color iconColor = isDark ? Colors.white70 : Colors.black54;
    final Color adsCardColor = isDark
        ? const Color(0xFF241B33)
        : const Color(0xFFF6F1FF);
    final Color adsAccent = Colors.deepPurple;
    final Color adsAccentSoft = adsAccent.withValues(
      alpha: isDark ? 0.22 : 0.12,
    );
    final Color adsBorder = isDark ? Colors.white24 : Colors.black12;
    final BorderRadius adsCardRadius = BorderRadius.circular(20);

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 700;
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 24.0;
            final Color surfaceColor = isDark
                ? Colors.black.withValues(alpha: 0.32)
                : Colors.white.withValues(alpha: 0.82);
            final BorderRadius surfaceRadius = BorderRadius.circular(20);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 900 : 720),
                child: ClipRRect(
                  borderRadius: surfaceRadius,
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: surfaceRadius,
                      border: Border.all(
                        color: isDark
                            ? Colors.white24
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: MediaQuery.of(
                          context,
                        ).textScaler.clamp(maxScaleFactor: isWide ? 1.2 : 1.0),
                      ),
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.fromLTRB(
                            isWide ? 32 : horizontalPadding,
                            isWide ? 24 : horizontalPadding,
                            isWide ? 32 : horizontalPadding,
                            (isWide ? 32 : horizontalPadding) +
                                MediaQuery.of(context).padding.bottom,
                          ),
                          children: [
                            SwitchListTile(
                              title: Text(
                                game.t("settings_music"),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: labelFont,
                                ),
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
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: labelFont,
                                ),
                              ),
                              secondary: game.soundEnabled
                                  ? Icon(
                                      Icons.volume_up_outlined,
                                      color: iconColor,
                                    )
                                  : Icon(
                                      Icons.volume_off_outlined,
                                      color: iconColor,
                                    ),
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
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: labelFont,
                                ),
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
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: labelFont,
                                ),
                              ),
                              secondary: Icon(
                                Icons.speed,
                                color: game.reducedMotion
                                    ? Colors.amber
                                    : iconColor,
                              ),
                              value: game.reducedMotion,
                              onChanged: (val) async {
                                await game.playClick();
                                game.toggleReducedMotion(val);
                              },
                            ),
                            if (game.gameServicesSupported) ...[
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      game.t("game_center_desc"),
                                      style: TextStyle(color: iconColor),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: game.gameServicesSignedIn
                                          ? null
                                          : () async {
                                              await game.playClick();
                                              final ok = await game
                                                  .connectGameCenter();
                                              if (!context.mounted) return;
                                              if (!ok) {
                                                _showSnack(
                                                  messenger,
                                                  game.t(
                                                    "game_center_connect_failed",
                                                  ),
                                                  isError: true,
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            game.gameServicesSignedIn
                                            ? Colors.grey
                                            : Colors.deepPurple,
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      child: Text(
                                        game.gameServicesSignedIn
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
                                        final ok = await game
                                            .openGameCenterAchievements();
                                        if (!context.mounted) return;
                                        if (!ok) {
                                          _showSnack(
                                            messenger,
                                            game.t(
                                              "game_center_achievements_failed",
                                            ),
                                            isError: true,
                                          );
                                        }
                                      },
                                      child: Text(
                                        game.t("game_center_achievements"),
                                      ),
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
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    adsCardColor,
                                    adsCardColor.withValues(
                                      alpha: isDark ? 0.92 : 0.98,
                                    ),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: adsCardRadius,
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
                              child: ClipRRect(
                                borderRadius: adsCardRadius,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: adsAccentSoft,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: adsAccent.withValues(
                                                  alpha: isDark ? 0.4 : 0.2,
                                                ),
                                              ),
                                            ),
                                            child: Icon(
                                              game.adsRemoved
                                                  ? Icons.verified
                                                  : Icons.no_adult_content,
                                              color: adsAccent,
                                              size: 26,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  game.t("remove_ads"),
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.lock_clock,
                                                      size: 14,
                                                      color: adsAccent,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        game.isEnglish
                                                            ? "One-time. No renewal."
                                                            : "Tek seferlik. Yenileme yok.",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: iconColor,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      size: 14,
                                                      color: adsAccent,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        game.isEnglish
                                                            ? "Ads removed forever."
                                                            : "Reklamlar kalıcı olarak kapanır.",
                                                        style: TextStyle(
                                                          color: iconColor,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.category_outlined,
                                                      size: 14,
                                                      color: adsAccent,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        game.isEnglish
                                                            ? "All categories unlocks immediately."
                                                            : "Bütün kategoriler anında açılır.",
                                                        style: TextStyle(
                                                          color: iconColor,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (game.adsRemoved ||
                                          game.removeAdsPrice != null) ...[
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: game.adsRemoved
                                                  ? const Color(
                                                      0xFF2E7D32,
                                                    ).withValues(
                                                      alpha: isDark
                                                          ? 0.18
                                                          : 0.12,
                                                    )
                                                  : adsAccentSoft,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: game.adsRemoved
                                                    ? const Color(
                                                        0xFF2E7D32,
                                                      ).withValues(alpha: 0.45)
                                                    : adsAccent.withValues(
                                                        alpha: 0.35,
                                                      ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  game.adsRemoved
                                                      ? Icons.check_circle
                                                      : Icons.local_offer,
                                                  size: 16,
                                                  color: game.adsRemoved
                                                      ? const Color(0xFF2E7D32)
                                                      : adsAccent,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  game.adsRemoved
                                                      ? game.t(
                                                          "remove_ads_owned",
                                                        )
                                                      : game.removeAdsPrice!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: game.adsRemoved
                                                        ? const Color(
                                                            0xFF2E7D32,
                                                          )
                                                        : adsAccent,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      LayoutBuilder(
                                        builder: (context, c) {
                                          final bool stackButtons =
                                              c.maxWidth < 400;
                                          final bool showRemoveAds =
                                              !game.adsRemoved;
                                          final removeAdsButton =
                                              ElevatedButton.icon(
                                                onPressed: !game.iapAvailable
                                                    ? null
                                                    : () async {
                                                        await game.playClick();
                                                        await game
                                                            .buyRemoveAds();
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: adsAccent,
                                                  padding: const EdgeInsets.all(
                                                    14,
                                                  ),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.shopping_bag_outlined,
                                                  color: Colors.white,
                                                ),
                                                label: Text(
                                                  game.removeAdsPrice != null
                                                      ? "${game.t("remove_ads")} • ${game.removeAdsPrice!}"
                                                      : game.t("remove_ads"),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                          final restoreButton =
                                              OutlinedButton.icon(
                                                onPressed: game.iapAvailable
                                                    ? () async {
                                                        await game.playClick();
                                                        await game
                                                            .restorePurchases();
                                                      }
                                                    : null,
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(
                                                    color: iconColor.withValues(
                                                      alpha: 0.6,
                                                    ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                  ),
                                                  foregroundColor: iconColor,
                                                ),
                                                icon: Icon(
                                                  Icons.restore,
                                                  color: iconColor,
                                                ),
                                                label: Text(
                                                  game.t("restore_purchases"),
                                                  style: TextStyle(
                                                    color: iconColor,
                                                  ),
                                                ),
                                              );
                                          if (!showRemoveAds) {
                                            return SizedBox(
                                              width: double.infinity,
                                              child: restoreButton,
                                            );
                                          }
                                          if (stackButtons) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: removeAdsButton,
                                                ),
                                                const SizedBox(height: 10),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: restoreButton,
                                                ),
                                              ],
                                            );
                                          }
                                          return Row(
                                            children: [
                                              Expanded(child: removeAdsButton),
                                              const SizedBox(width: 10),
                                              restoreButton,
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    adsCardColor,
                                    adsCardColor.withValues(
                                      alpha: isDark ? 0.92 : 0.98,
                                    ),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: adsCardRadius,
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
                            ),
                            const SizedBox(height: 24),
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
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
