part of '../main.dart';

const String _supportEmail = "eastdevgames@gmail.com";
// Replace with your real store URLs before shipping.
const String _appStoreUrlTr =
    "https://apps.apple.com/tr/app/we-cant-say-it/id6756984438";
const String _appStoreUrlEn =
    "https://apps.apple.com/us/app/we-cant-say-it/id6756984438";

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
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError
            ? Colors.red
            : isSuccess
            ? Colors.green
            : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _launchSupportEmail(
    GameProvider game,
    ScaffoldMessengerState messenger,
  ) async {
    final subject = game.isEnglish
        ? "About Your We Can't Say It App"
        : "Onu Söyleyemiyoruz Adlı Uygulamanız Hakkında";
    final body = game.t("contact_body_template");
    final query =
        "subject=${Uri.encodeComponent(subject)}"
        "&body=${Uri.encodeComponent(body)}";
    final uri = Uri.parse("mailto:$_supportEmail?$query");
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      _showSnack(messenger, game.t("contact_error"), isError: true);
    }
  }

  String _storeUrl(GameProvider game) =>
      game.isEnglish ? _appStoreUrlEn : _appStoreUrlTr;

  Future<void> _rateApp(
    GameProvider game,
    ScaffoldMessengerState messenger,
  ) async {
    final uri = Uri.parse(_storeUrl(game));
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      _showSnack(messenger, game.t("rate_error"), isError: true);
    }
  }

  Future<void> _shareApp(
    GameProvider game,
    ScaffoldMessengerState messenger,
  ) async {
    try {
      final url = _storeUrl(game);
      await SharePlus.instance.share(
        ShareParams(text: game.t("share_app_message", params: {"url": url})),
      );
    } catch (_) {
      _showSnack(messenger, game.t("share_error"), isError: true);
    }
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
            final Color cardFill = isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.7);
            final BorderRadius cardRadius = BorderRadius.circular(16);
            List<Widget> buildSettingsGroup(List<Widget> items) {
              return [
                Container(
                  decoration: BoxDecoration(
                    color: cardFill,
                    borderRadius: cardRadius,
                    border: Border.all(
                      color: isDark
                          ? Colors.white24
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        items[i],
                        if (i != items.length - 1)
                          Divider(
                            height: 1,
                            thickness: 0.6,
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ];
            }

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
                            ...buildSettingsGroup([
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
                                    : Icon(
                                        Icons.phone_iphone,
                                        color: iconColor,
                                      ),
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
                            ]),
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
                            ] else ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.videogame_asset_off,
                                      color: iconColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        game.t("game_center_unavailable"),
                                        style: TextStyle(color: iconColor),
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
                                                      ? "${game.t("remove_ads_owned")} • ${game.removeAdsPrice ?? game.t("price_unavailable")}"
                                                      : (game.removeAdsPrice ??
                                                            game.t(
                                                              "price_unavailable",
                                                            )),
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
                                          final bool restoring =
                                              game.restoringPurchases;
                                          final bool iapReady =
                                              game.iapAvailable;
                                          final removeAdsButton =
                                              ElevatedButton.icon(
                                                onPressed: () async {
                                                  await game.playClick();
                                                  if (!iapReady) {
                                                    _showSnack(
                                                      messenger,
                                                      game.t(
                                                        "iap_unavailable_toast",
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  final error = await game
                                                      .buyRemoveAds();
                                                  if (!context.mounted) return;
                                                  if (error != null) {
                                                    _showSnack(
                                                      messenger,
                                                      error,
                                                      isError: true,
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: iapReady
                                                      ? adsAccent
                                                      : adsAccent.withValues(
                                                          alpha: 0.45,
                                                        ),
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
                                          final bool restoreEnabled =
                                              iapReady &&
                                              !game.adsRemoved &&
                                              !restoring;
                                          final restoreButton = OutlinedButton.icon(
                                            onPressed: () async {
                                              await game.playClick();
                                              if (restoring) {
                                                _showSnack(
                                                  messenger,
                                                  game.t("restore_in_progress"),
                                                );
                                                return;
                                              }
                                              if (!iapReady) {
                                                _showSnack(
                                                  messenger,
                                                  game.t(
                                                    "iap_unavailable_toast",
                                                  ),
                                                );
                                                return;
                                              }
                                              if (game.adsRemoved) {
                                                _showSnack(
                                                  messenger,
                                                  game.t("restore_not_needed"),
                                                );
                                                return;
                                              }
                                              final restored = await game
                                                  .restorePurchases();
                                              if (!context.mounted) {
                                                return;
                                              }
                                              if (restored) {
                                                _showSnack(
                                                  messenger,
                                                  game.t("restore_success"),
                                                  isSuccess: true,
                                                );
                                              } else {
                                                _showSnack(
                                                  messenger,
                                                  game.t("restore_nothing"),
                                                );
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color:
                                                    (restoreEnabled
                                                            ? iconColor
                                                            : iconColor
                                                                  .withValues(
                                                                    alpha: 0.3,
                                                                  ))
                                                        .withValues(alpha: 0.9),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 14,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              foregroundColor: restoreEnabled
                                                  ? iconColor
                                                  : iconColor.withValues(
                                                      alpha: 0.6,
                                                    ),
                                            ),
                                            icon: Icon(
                                              Icons.restore,
                                              color: restoreEnabled
                                                  ? iconColor
                                                  : iconColor.withValues(
                                                      alpha: 0.4,
                                                    ),
                                            ),
                                            label: Text(
                                              game.restoringPurchases
                                                  ? "${game.t("restore_purchases")}..."
                                                  : game.t("restore_purchases"),
                                              style: TextStyle(
                                                color: restoreEnabled
                                                    ? iconColor
                                                    : iconColor.withValues(
                                                        alpha: 0.7,
                                                      ),
                                              ),
                                            ),
                                          );
                                          if (!showRemoveAds) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: restoreButton,
                                                ),
                                              ],
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
                                      const SizedBox(height: 8),
                                      Text(
                                        !game.iapAvailable
                                            ? game.t("iap_unavailable_hint")
                                            : game.adsRemoved
                                            ? game.t("restore_not_needed")
                                            : game.restoringPurchases
                                            ? game.t("restore_in_progress")
                                            : game.t("restore_help_text"),
                                        style: TextStyle(
                                          color: iconColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black12,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    game.t("contact_headline"),
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    game.t("contact_subtitle"),
                                    style: TextStyle(
                                      color: iconColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _supportEmail,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () async {
                                              await game.playClick();
                                              if (!context.mounted) return;
                                              await _launchSupportEmail(
                                                game,
                                                messenger,
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 8,
                                              ),
                                              minimumSize: Size.zero,
                                            ),
                                            icon: const Icon(
                                              Icons.mail_outline,
                                              size: 16,
                                            ),
                                            label: Text(
                                              game.t("contact_cta"),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 8,
                                    children: [
                                      FilledButton.icon(
                                        onPressed: () async {
                                          await game.playClick();
                                          if (!context.mounted) return;
                                          await _rateApp(game, messenger);
                                        },
                                        icon: const Icon(Icons.star_rate),
                                        label: Text(game.t("rate_app")),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          await game.playClick();
                                          if (!context.mounted) return;
                                          await _shareApp(game, messenger);
                                        },
                                        icon: const Icon(Icons.share_outlined),
                                        label: Text(game.t("share_app")),
                                      ),
                                    ],
                                  ),
                                ],
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
