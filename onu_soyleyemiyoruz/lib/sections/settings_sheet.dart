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

    if (game.adsRemovalJustGranted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showSnack(
          messenger,
          game.isEnglish
              ? "Ads removed forever. Sports, Science, Food categories are unlocked!"
              : "Reklamlar kalıcı olarak kapandı. Spor, Bilim, Yemek kategorileri açıldı!",
          isSuccess: true,
        );
        game.markAdsRemovalNotified();
      });
    }

    final Color panelColor = isDark ? const Color(0xFF1D1A22) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
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
        child: Container(
          color: panelColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 380
                  ? 16.0
                  : 24.0;
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
                                      final ok = await game.connectGameCenter();
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
                                final ok = await game
                                    .openGameCenterAchievements();
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: adsAccentSoft,
                                      borderRadius: BorderRadius.circular(14),
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
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: iconColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.remove_circle_outline,
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
                                                  fontWeight: FontWeight.w700,
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
                                                    ? "Sports, Science, Food categories unlocks immediately."
                                                    : "Spor, Bilim, Yemek kategorileri hemen açılır.",
                                                style: TextStyle(
                                                  color: iconColor,
                                                  fontWeight: FontWeight.w700,
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
                                          ? const Color(0xFF2E7D32).withValues(
                                              alpha: isDark ? 0.18 : 0.12,
                                            )
                                          : adsAccentSoft,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: game.adsRemoved
                                            ? const Color(
                                                0xFF2E7D32,
                                              ).withValues(alpha: 0.45)
                                            : adsAccent.withValues(alpha: 0.35),
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
                                              ? game.t("remove_ads_owned")
                                              : game.removeAdsPrice!,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: game.adsRemoved
                                                ? const Color(0xFF2E7D32)
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
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          game.adsRemoved || !game.iapAvailable
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
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      icon: Icon(
                                        game.adsRemoved
                                            ? Icons.check
                                            : Icons.shopping_bag_outlined,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        game.adsRemoved
                                            ? game.t("remove_ads_owned")
                                            : game.removeAdsPrice != null
                                            ? "${game.t("remove_ads")} • ${game.removeAdsPrice!}"
                                            : game.t("remove_ads"),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: game.iapAvailable
                                        ? () async {
                                            await game.playClick();
                                            await game.restorePurchases();
                                          }
                                        : null,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: iconColor.withValues(alpha: 0.6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      foregroundColor: iconColor,
                                    ),
                                    icon: Icon(Icons.restore, color: iconColor),
                                    label: Text(
                                      game.t("restore_purchases"),
                                      style: TextStyle(color: iconColor),
                                    ),
                                  ),
                                ],
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
                      child: ClipRRect(
                        borderRadius: adsCardRadius,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: adsAccentSoft,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: adsAccent.withValues(
                                          alpha: isDark ? 0.4 : 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.workspace_premium,
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
                                          game.isEnglish
                                              ? "Premium Bundle"
                                              : "Premium Paket",
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          game.isEnglish
                                              ? "Unlock all premium categories + remove ads!"
                                              : "Tüm premium kategorilere ek olarak reklam yok!",
                                          style: TextStyle(
                                            color: iconColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (game.adsRemoved)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              game.isEnglish
                                                  ? "Ads already removed."
                                                  : "Reklamlar zaten kaldırıldı.",
                                              style: TextStyle(
                                                color: iconColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (game.premiumBundlePrice != null)
                                    Flexible(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: adsAccentSoft,
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            border: Border.all(
                                              color: adsAccent.withValues(
                                                alpha: 0.35,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.local_offer,
                                                size: 16,
                                                color: adsAccent,
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  game.premiumBundlePrice!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: adsAccent,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: !game.iapAvailable
                                    ? null
                                    : () async {
                                        await game.playClick();
                                        await game.buyPremiumBundle();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: adsAccent,
                                  padding: const EdgeInsets.all(14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.workspace_premium,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  game.premiumBundlePrice != null
                                      ? "${game.isEnglish ? "Buy Premium Bundle" : "Premium Paket Al"} • ${game.premiumBundlePrice!}"
                                      : (game.isEnglish
                                            ? "Buy Premium Bundle"
                                            : "Premium Paket Al"),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
