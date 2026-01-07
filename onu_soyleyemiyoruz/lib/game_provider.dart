import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:games_services/games_services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

enum CategoryAccess { free, adUnlock, premium }

enum _AchievementKey {
  fullHouse,
  everyoneNarrates,
  balancedBattle,
  marathonNight,
}

class _AchievementIds {
  final String ios;
  final String android;

  const _AchievementIds({required this.ios, required this.android});
}

class GameProvider extends ChangeNotifier {
  static const String _teamADefaultTr = "TAKIM A";
  static const String _teamBDefaultTr = "TAKIM B";
  static const String _teamADefaultEn = "TEAM A";
  static const String _teamBDefaultEn = "TEAM B";
  static const String _removeAdsProductId = "remove_ads";
  static const String _premiumBundleProductId = "premium_bundle";
  static const Map<String, String> _premiumCategoryProductIds = {};
  // Replace these IDs with your App Store / Play Console achievement IDs.
  static const Map<_AchievementKey, _AchievementIds> _achievementIds = {
    _AchievementKey.fullHouse: _AchievementIds(
      ios: "full_house",
      android: "full_house",
    ),
    _AchievementKey.everyoneNarrates: _AchievementIds(
      ios: "everyone_narrates",
      android: "everyone_narrates",
    ),
    _AchievementKey.balancedBattle: _AchievementIds(
      ios: "balanced_battle",
      android: "balanced_battle",
    ),
    _AchievementKey.marathonNight: _AchievementIds(
      ios: "marathon_night",
      android: "marathon_night",
    ),
  };
  static const Set<String> _freeCategories = {
    "Genel",
    "Doğa",
    "Tarih",
    "Sanat",
    "Teknoloji",
    "Spor",
  };
  static const Set<String> _adUnlockCategories = {"Bilim", "Yemek"};
  // --- Global Settings ---
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;
  bool tutorialTipShown = false;
  bool reducedMotion = false;
  bool onboardingSeen = false;
  ThemeMode themeMode = ThemeMode.light;
  String languageCode = "tr";
  bool hydrated = false;
  SharedPreferences? _prefs;
  bool _audioFailed = false;
  bool _audioInitAttempted = false;
  final Map<String, String> _copiedAudioPaths = {};
  String? _currentSfxName;
  final Map<String, DateTime> _lastSfxAt = {};
  static const Duration _sfxMinGap = Duration(milliseconds: 250);

  // --- Profanity Filter List (Basic) ---
  final List<String> _badWords = [
    "GÖT",
    "GÖTLEK",
    "GÖTVEREN",
    "SİK",
    "SİKİK",
    "SİKİM",
    "SİKİŞ",
    "SİKERİM",
    "SİKİYORUM",
    "AM",
    "AMCIK",
    "OROSPU",
    "İBNE",
    "PİÇ",
    "YARRAK",
    "YARAK",
    "YAVŞAK",
    "AMK",
    "SİKTİR",
    "OÇ",
  ];

  // --- Category & Word Data ---
  List<String> availableCategories = [
    "Genel",
    "Doğa",
    "Tarih",
    "Sanat",
    "Teknoloji",
    "Spor",
    "Bilim",
    "Yemek",
    "Futbol",
    "90'lar Nostalji",
    "Zor Seviye",
    "Gece Yarısı",
    "Özel",
  ];
  Set<String> selectedCategories = {
    "Genel",
    "Doğa",
    "Tarih",
    "Sanat",
    "Teknoloji",
    "Spor",
  };
  Set<String> disabledCardIds = {};
  List<WordCard> customCards = [];

  // --- Game Config ---
  int _roundTime = 60;
  int _targetScore = 50;
  bool _allowRepeats = false;

  // --- Teams & Players ---
  String teamAName = _teamADefaultTr;
  String teamBName = _teamBDefaultTr;
  List<String> teamA = [];
  List<String> teamB = [];

  int _teamAPlayerIndex = 0;
  int _teamBPlayerIndex = 0;

  // --- Live Game State ---
  bool isTeamATurn = true;
  int teamAScore = 0;
  int teamBScore = 0;
  String? gameWinner;
  bool endedByCards = false;
  String? endMessage;
  int teamADice = 1;
  int teamBDice = 1;

  // --- Audio ---
  late final AudioPlayer _musicPlayer;
  late final AudioPlayer _sfxPlayer;
  bool _audioReady = false;

  // --- Monetization ---
  bool adsRemoved = false;
  bool premiumBundleOwned = false;
  bool _adsRemovalJustGranted = false;
  bool iapAvailable = false;
  final Set<String> _adUnlockedCategories = {};
  final Set<String> _purchasedCategoryIds = {};
  final Map<String, DateTime> _rewardedCategoryUnlocks = {};
  String? _recentUnlockedCategory;
  bool _recentUnlockedPermanent = false;
  final List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _loadingInterstitial = false;
  bool _loadingRewarded = false;
  bool _showingInterstitial = false;
  bool _showingRewarded = false;
  bool gameServicesSignedIn = false;

  int currentPasses = 0;
  final int maxPasses = 3;
  int timeLeft = 0;
  bool isPaused = false;
  bool abortedToMenu = false;
  Timer? _timer;
  WordCard? currentCard;

  // Cooldown Tracker
  bool _cooldownActive = false;
  Timer? _cooldownTimer;

  List<RoundEvent> roundHistory = [];
  List<WordCard> _activeDeck = [];
  final List<RoundSummary> roundSummaries = [];
  bool _roundEnded = false;

  String _defaultLanguageCode() {
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    final locales = dispatcher.locales;
    final locale = locales.isNotEmpty ? locales.first : dispatcher.locale;
    final language = locale.languageCode.toLowerCase();
    final country = locale.countryCode?.toUpperCase();
    if (country == "TR" || language == "tr") {
      return "tr";
    }
    return "en";
  }

  Future<void> _hydrate() async {
    _prefs = await SharedPreferences.getInstance();
    soundEnabled = _prefs?.getBool("soundEnabled") ?? soundEnabled;
    musicEnabled = _prefs?.getBool("musicEnabled") ?? musicEnabled;
    vibrationEnabled = _prefs?.getBool("vibrationEnabled") ?? vibrationEnabled;
    reducedMotion = _prefs?.getBool("reducedMotion") ?? reducedMotion;
    onboardingSeen = _prefs?.getBool("onboardingSeen") ?? onboardingSeen;
    themeMode = _themeModeFromString(_prefs?.getString("themeMode"));
    final storedLanguage = _prefs?.getString("languageCode");
    languageCode = storedLanguage ?? _defaultLanguageCode();
    tutorialTipShown = _prefs?.getBool("tutorialTipShown") ?? tutorialTipShown;
    teamAName = _prefs?.getString("teamAName") ?? teamAName;
    teamBName = _prefs?.getString("teamBName") ?? teamBName;
    teamA = _prefs?.getStringList("teamA") ?? teamA;
    teamB = _prefs?.getStringList("teamB") ?? teamB;
    _roundTime = _prefs?.getInt("roundTime") ?? _roundTime;
    _targetScore = _prefs?.getInt("targetScore") ?? _targetScore;
    _allowRepeats = _prefs?.getBool("allowRepeats") ?? _allowRepeats;
    selectedCategories =
        (_prefs?.getStringList("selectedCategories") ?? selectedCategories)
            .toSet();
    disabledCardIds =
        (_prefs?.getStringList("disabledCardIds") ?? disabledCardIds).toSet();
    adsRemoved = _prefs?.getBool("adsRemoved") ?? adsRemoved;
    premiumBundleOwned =
        _prefs?.getBool("premiumBundleOwned") ?? premiumBundleOwned;
    _adUnlockedCategories
      ..clear()
      ..addAll(_prefs?.getStringList("adUnlockedCategories") ?? const []);
    _purchasedCategoryIds
      ..clear()
      ..addAll(_prefs?.getStringList("purchasedCategories") ?? const []);
    _rewardedCategoryUnlocks
      ..clear()
      ..addAll(_decodeRewardUnlocks(_prefs?.getString("rewardedUnlocks")));
    try {
      final rawCustom = _prefs?.getString("customCards");
      if (rawCustom != null) {
        final decoded = jsonDecode(rawCustom) as List<dynamic>;
        customCards = decoded
            .map(
              (e) => WordCard(
                id: e["id"] as String?,
                word: e["word"] as String,
                tabooWords: List<String>.from(e["tabooWords"] as List),
                category: e["category"] as String? ?? "Özel",
                isCustom: e["isCustom"] as bool? ?? true,
              ),
            )
            .toList();
      }
    } catch (_) {
      customCards = [];
    }
    _revalidateCategoryAccess();
    // Premium bundle deprecated; treat remove-ads as the only purchase.
    _syncDisabledWithCategories();
    final bool isEnglishNow = languageCode == "en";
    final String expectedTeamA = isEnglishNow
        ? _teamADefaultEn
        : _teamADefaultTr;
    final String expectedTeamB = isEnglishNow
        ? _teamBDefaultEn
        : _teamBDefaultTr;
    final String otherLangTeamA = isEnglishNow
        ? _teamADefaultTr
        : _teamADefaultEn;
    final String otherLangTeamB = isEnglishNow
        ? _teamBDefaultTr
        : _teamBDefaultEn;
    if (teamAName == otherLangTeamA) teamAName = expectedTeamA;
    if (teamBName == otherLangTeamB) teamBName = expectedTeamB;
    await _initMonetization();
    hydrated = true;
    notifyListeners();
    if (musicEnabled) {
      ensureAudioInitialized();
    }
  }

  void _persist() {
    if (_prefs == null) return;
    _prefs!.setBool("soundEnabled", soundEnabled);
    _prefs!.setBool("musicEnabled", musicEnabled);
    _prefs!.setBool("vibrationEnabled", vibrationEnabled);
    _prefs!.setBool("reducedMotion", reducedMotion);
    _prefs!.setString("themeMode", _themeModeToString(themeMode));
    _prefs!.setString("languageCode", languageCode);
    _prefs!.setBool("tutorialTipShown", tutorialTipShown);
    _prefs!.setBool("onboardingSeen", onboardingSeen);
    _prefs!.setString("teamAName", teamAName);
    _prefs!.setString("teamBName", teamBName);
    _prefs!.setStringList("teamA", teamA);
    _prefs!.setStringList("teamB", teamB);
    _prefs!.setInt("roundTime", _roundTime);
    _prefs!.setInt("targetScore", _targetScore);
    _prefs!.setBool("allowRepeats", _allowRepeats);
    _prefs!.setStringList("selectedCategories", selectedCategories.toList());
    _prefs!.setStringList("disabledCardIds", disabledCardIds.toList());
    _prefs!.setBool("adsRemoved", adsRemoved);
    _prefs!.setBool("premiumBundleOwned", premiumBundleOwned);
    _prefs!.setStringList(
      "adUnlockedCategories",
      _adUnlockedCategories.toList(),
    );
    _prefs!.setStringList(
      "purchasedCategories",
      _purchasedCategoryIds.toList(),
    );
    _prefs!.setString("rewardedUnlocks", jsonEncode(_encodeRewardUnlocks()));
    _prefs!.setString(
      "customCards",
      jsonEncode(
        customCards
            .map(
              (c) => {
                "id": c.id,
                "word": c.word,
                "tabooWords": c.tabooWords,
                "category": c.category,
                "isCustom": c.isCustom,
              },
            )
            .toList(),
      ),
    );
  }

  Map<String, int> _encodeRewardUnlocks() {
    final now = DateTime.now();
    final Map<String, int> data = {};
    _rewardedCategoryUnlocks.forEach((key, value) {
      if (value.isAfter(now)) {
        data[key] = value.millisecondsSinceEpoch;
      }
    });
    return data;
  }

  Map<String, DateTime> _decodeRewardUnlocks(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) =>
            MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value as int)),
      );
    } catch (_) {
      return {};
    }
  }

  void _revalidateCategoryAccess() {
    final now = DateTime.now();
    _rewardedCategoryUnlocks.removeWhere((_, value) => !value.isAfter(now));
    if (adsRemoved) {
      _adUnlockedCategories.addAll(_adUnlockCategories);
    }
    for (final cat in availableCategories) {
      if (cat == "Özel") continue;
      if (!isCategoryUnlocked(cat) && selectedCategories.contains(cat)) {
        _setCategoryEnabled(cat, false);
      }
    }
  }

  bool get _adsSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get _iapSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get adsRemovalJustGranted => _adsRemovalJustGranted;

  void _ensurePurchaseListener() {
    if (_purchaseSub != null) return;
    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _purchaseSub = null,
    );
  }

  Future<void> _initMonetization({bool skipAds = false}) async {
    if (_iapSupported) {
      final available = await InAppPurchase.instance.isAvailable();
      iapAvailable = available;
      if (iapAvailable) {
        _ensurePurchaseListener();
        await _loadProducts();
      }
    }
    if (!skipAds && _adsSupported && !adsRemoved) {
      await MobileAds.instance.initialize();
      _loadInterstitial();
      _loadRewarded();
    }
    notifyListeners();
  }

  Future<void> refreshIapAvailability() async {
    await _initMonetization(skipAds: true);
  }

  Future<void> _loadProducts() async {
    final ids = {_removeAdsProductId, ..._premiumCategoryProductIds.values};
    final response = await InAppPurchase.instance.queryProductDetails(ids);
    _products
      ..clear()
      ..addAll(response.productDetails);
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      final status = purchase.status;
      if (status == PurchaseStatus.purchased ||
          status == PurchaseStatus.restored) {
        _grantPurchase(purchase.productID);
      }
      if (purchase.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  void _grantPurchase(String productId) {
    if (productId == _removeAdsProductId) {
      adsRemoved = true;
      _adsRemovalJustGranted = true;
      // Remove-ads now unlocks all categories permanently.
      _adUnlockedCategories.addAll(_adUnlockCategories);
      for (final cat in availableCategories) {
        _purchasedCategoryIds.add(cat);
        _setCategoryEnabled(cat, true);
      }
      _notifyCategoryUnlock("all_categories", permanent: true);
    }
    _persist();
    notifyListeners();
  }

  void markAdsRemovalNotified() {
    _adsRemovalJustGranted = false;
  }

  Future<void> simulateRemoveAdsPurchase() async {
    if (!kDebugMode) return;
    _grantPurchase(_removeAdsProductId);
  }

  String _formatPrice(ProductDetails product) => product.price;

  ProductDetails? _productById(String productId) {
    for (final p in _products) {
      if (p.id == productId) return p;
    }
    return null;
  }

  String? priceForProduct(String productId) {
    final product = _productById(productId);
    if (product == null) return null;
    return _formatPrice(product);
  }

  String? get removeAdsPrice => priceForProduct(_removeAdsProductId);

  String? get activeTimedRewardCategory {
    final now = DateTime.now();
    for (final entry in _rewardedCategoryUnlocks.entries) {
      if (entry.value.isAfter(now)) {
        return entry.key;
      }
    }
    return null;
  }

  Future<String?> buyRemoveAds() async {
    if (!_iapSupported) {
      return isEnglish
          ? "In-app purchases aren't supported on this device."
          : "Bu cihaz uygulama içi satın almayı desteklemiyor.";
    }
    if (!iapAvailable) {
      await _initMonetization(skipAds: true);
      if (!iapAvailable) {
        return isEnglish
            ? "Purchases not available right now. Check your store login and try again."
            : "Satın almalar şu anda kullanılabilir değil. Mağaza hesabınızı kontrol edip tekrar deneyin.";
      }
    }
    _ensurePurchaseListener();
    ProductDetails? product = _productById(_removeAdsProductId);
    if (product == null) {
      await _loadProducts();
      product = _productById(_removeAdsProductId);
      if (product == null) {
        return isEnglish
            ? "Remove-ads product (ads_remove) is missing for this app id."
            : "Reklam kaldırma ürünü (ads_remove) bu uygulama için bulunamadı.";
      }
    }
    try {
      final param = PurchaseParam(productDetails: product);
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
      return null;
    } catch (_) {
      return isEnglish
          ? "Purchase could not start. Please try again."
          : "Satın alma başlatılamadı. Lütfen tekrar deneyin.";
    }
  }

  Future<void> buyPremiumBundle() async {
    if (!iapAvailable) return;
    final product = _productById(_premiumBundleProductId);
    if (product == null) return;
    final param = PurchaseParam(productDetails: product);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
  }

  Future<void> buyCategoryPack(String category) async {
    if (!iapAvailable) return;
    final productId = _premiumCategoryProductIds[category];
    if (productId == null) return;
    final product = _productById(productId);
    if (product == null) return;
    final param = PurchaseParam(productDetails: product);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    if (!iapAvailable) return;
    await InAppPurchase.instance.restorePurchases();
  }

  void _loadInterstitial() {
    if (!_adsSupported || _loadingInterstitial || _interstitialAd != null) {
      return;
    }
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
        },
      ),
    );
  }

  void _loadRewarded() {
    if (!_adsSupported || _loadingRewarded || _rewardedAd != null) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _loadingRewarded = false;
        },
        onAdFailedToLoad: (error) {
          _loadingRewarded = false;
        },
      ),
    );
  }

  Future<bool> showInterstitialAd() async {
    if (!_adsSupported || adsRemoved || _showingInterstitial) return false;
    final ad = _interstitialAd;
    if (ad == null) {
      _loadInterstitial();
      return false;
    }
    _interstitialAd = null;
    final completer = Completer<bool>();
    _showingInterstitial = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showingInterstitial = false;
        _loadInterstitial();
        completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _showingInterstitial = false;
        _loadInterstitial();
        completer.complete(false);
      },
    );
    ad.show();
    return completer.future;
  }

  Future<bool> showRewardedAd() async {
    if (!_adsSupported || _showingRewarded) return false;
    final ad = _rewardedAd;
    if (ad == null) {
      _loadRewarded();
      return false;
    }
    _rewardedAd = null;
    final completer = Completer<bool>();
    bool earned = false;
    _showingRewarded = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showingRewarded = false;
        _loadRewarded();
        completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _showingRewarded = false;
        _loadRewarded();
        completer.complete(false);
      },
    );
    ad.show(
      onUserEarnedReward: (_, reward) {
        earned = reward.amount >= 0;
      },
    );
    return completer.future;
  }

  CategoryAccess categoryAccess(String category) {
    if (category == "Özel" || _freeCategories.contains(category)) {
      return CategoryAccess.free;
    }
    if (_adUnlockCategories.contains(category)) {
      return CategoryAccess.adUnlock;
    }
    return CategoryAccess.premium;
  }

  bool isCategoryUnlocked(String category) {
    _expireRewardIfNeeded(category);
    final access = categoryAccess(category);
    if (access == CategoryAccess.free) return true;
    if (adsRemoved) return true;
    if (access == CategoryAccess.adUnlock) {
      return _adUnlockedCategories.contains(category);
    }
    final until = _rewardedCategoryUnlocks[category];
    final rewardActive = until != null && until.isAfter(DateTime.now());
    return _purchasedCategoryIds.contains(category) || rewardActive;
  }

  Duration? rewardRemaining(String category) {
    _expireRewardIfNeeded(category);
    final until = _rewardedCategoryUnlocks[category];
    if (until == null) return null;
    final remaining = until.difference(DateTime.now());
    if (remaining.isNegative) return null;
    return remaining;
  }

  void _notifyCategoryUnlock(String category, {required bool permanent}) {
    _recentUnlockedCategory = category;
    _recentUnlockedPermanent = permanent;
  }

  void _expireRewardIfNeeded(String category) {
    final until = _rewardedCategoryUnlocks[category];
    if (until == null) return;
    if (until.isAfter(DateTime.now())) return;
    _rewardedCategoryUnlocks.remove(category);
    _setCategoryEnabled(category, false);
    _persist();
    notifyListeners();
  }

  Future<bool> unlockCategoryWithReward(String category) async {
    final access = categoryAccess(category);
    if (access == CategoryAccess.free) return true;
    if (access == CategoryAccess.adUnlock && adsRemoved) {
      _adUnlockedCategories.add(category);
      _setCategoryEnabled(category, true);
      _notifyCategoryUnlock(category, permanent: true);
      _persist();
      notifyListeners();
      return true;
    }
    if (access == CategoryAccess.premium &&
        _purchasedCategoryIds.contains(category)) {
      return true;
    }
    if (access == CategoryAccess.premium) {
      final activeTimed = activeTimedRewardCategory;
      if (activeTimed != null && activeTimed != category) {
        return false;
      }
    }
    final rewarded = await showRewardedAd();
    if (!rewarded) return false;
    if (access == CategoryAccess.adUnlock) {
      _adUnlockedCategories.add(category);
      _notifyCategoryUnlock(category, permanent: true);
    } else if (access == CategoryAccess.premium) {
      _rewardedCategoryUnlocks[category] = DateTime.now().add(
        const Duration(hours: 1),
      );
      _notifyCategoryUnlock(category, permanent: false);
    }
    _setCategoryEnabled(category, true);
    _persist();
    notifyListeners();
    return true;
  }

  void _setCategoryEnabled(String category, bool enabled) {
    final ids = _idsForCategory(category);
    if (enabled) {
      selectedCategories.add(category);
      disabledCardIds.removeWhere(ids.contains);
    } else {
      selectedCategories.remove(category);
      disabledCardIds.addAll(ids);
    }
  }

  String get _interstitialAdUnitId {
    if (!_adsSupported) return "";
    if (Platform.isAndroid) {
      return "ca-app-pub-8990814046267193/3625330834";
    }
    return "ca-app-pub-8990814046267193/5955803099";
  }

  String get _rewardedAdUnitId {
    if (!_adsSupported) return "";
    if (Platform.isAndroid) {
      return "ca-app-pub-8990814046267193/5875912046";
    }
    return "ca-app-pub-8990814046267193/8582784670";
  }

  GameProvider() {
    _musicPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    _sfxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _hydrate();
  }

  // --- Getters ---
  int get roundTime => _roundTime;
  int get targetScore => _targetScore;
  bool get allowRepeats => _allowRepeats;
  bool get isCoolingDown => _cooldownActive;
  int get remainingCards => _activeDeck.length + (currentCard != null ? 1 : 0);
  bool get allCardsUsed => endedByCards;
  bool get hasReachedTargetScore =>
      _targetScore != -1 &&
      (teamAScore >= _targetScore || teamBScore >= _targetScore);
  bool get isGameEnded => endedByCards || hasReachedTargetScore;
  RoundSummary? get lastRoundSummary =>
      roundSummaries.isNotEmpty ? roundSummaries.last : null;
  String? get recentUnlockedCategory => _recentUnlockedCategory;
  bool get recentUnlockedPermanent => _recentUnlockedPermanent;

  bool shouldShowInterstitialAfter(RoundSummary summary) {
    if (adsRemoved) return false;
    if (summary.turnInRound != 2) return false;
    final round = summary.roundNumber;
    if (round == 2 || round == 4) return true;
    return round > 4 && round % 4 == 0;
  }

  bool get gameServicesSupported =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  Achievement _achievement(_AchievementKey key) {
    final ids = _achievementIds[key]!;
    return Achievement(androidID: ids.android, iOSID: ids.ios);
  }

  Future<bool> _ensureGameServicesSignedIn({bool interactive = false}) async {
    if (!gameServicesSupported) return false;
    if (gameServicesSignedIn) return true;
    if (!interactive) return false;
    try {
      await GamesServices.signIn();
      gameServicesSignedIn = true;
      notifyListeners();
      return true;
    } catch (_) {
      gameServicesSignedIn = false;
      return false;
    }
  }

  Future<bool> connectGameCenter() async {
    return _ensureGameServicesSignedIn(interactive: true);
  }

  Future<bool> openGameCenterAchievements() async {
    if (!gameServicesSupported) return false;
    final ok = await _ensureGameServicesSignedIn(interactive: true);
    if (!ok) return false;
    try {
      await GamesServices.showAchievements();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _unlockAchievement(_AchievementKey key) async {
    if (!await _ensureGameServicesSignedIn()) return;
    try {
      await GamesServices.unlock(achievement: _achievement(key));
    } catch (_) {}
  }

  Future<void> _maybeReportAchievements(RoundSummary summary) async {
    if (!gameServicesSupported || !gameServicesSignedIn) return;
    final bool hasMinimumTeams = teamA.length >= 2 && teamB.length >= 2;
    final int totalPlayers = teamA.length + teamB.length;
    if (hasMinimumTeams && totalPlayers >= 4) {
      await _unlockAchievement(_AchievementKey.fullHouse);
    }
    if (hasMinimumTeams && teamAScore >= 10 && teamBScore >= 10) {
      await _unlockAchievement(_AchievementKey.balancedBattle);
    }
    if (hasMinimumTeams && summary.roundNumber >= 6) {
      await _unlockAchievement(_AchievementKey.marathonNight);
    }
    if (hasMinimumTeams) {
      final narrators = roundSummaries.map((round) => round.narrator).toSet();
      final everyonePlayed =
          teamA.every(narrators.contains) && teamB.every(narrators.contains);
      if (everyonePlayed) {
        await _unlockAchievement(_AchievementKey.everyoneNarrates);
      }
    }
  }

  String get currentNarrator {
    if (isTeamATurn) {
      if (teamA.isEmpty) return t("no_player");
      return teamA[_teamAPlayerIndex % teamA.length];
    } else {
      if (teamB.isEmpty) return t("no_player");
      return teamB[_teamBPlayerIndex % teamB.length];
    }
  }

  List<WordCard> get allCards => [
    ...(isEnglish ? initialDeckEn : initialDeckTr),
    ...customCards,
  ];

  Map<String, List<WordCard>> get wordsByCategory {
    Map<String, List<WordCard>> map = {};
    for (var cat in availableCategories) {
      map[cat] = allCards.where((w) => w.category == cat).toList();
    }
    return map;
  }

  // --- INPUT VALIDATION ---
  RegExp get nameAllowedChars =>
      isEnglish ? RegExp(r'[A-Za-z ]') : RegExp(r'[A-Za-zÇçĞğİıÖöŞşÜü ]');

  RegExp get wordAllowedChars => RegExp(r'[A-Za-zÇçĞğİıÖöŞşÜü ]');

  RegExp get _nameValidationPattern =>
      isEnglish ? RegExp(r'^[A-Z ]+$') : RegExp(r'^[A-ZÇĞİÖŞÜ ]+$');

  RegExp get _wordValidationPattern => RegExp(r'^[A-ZÇĞİÖŞÜ ]+$');

  String languageUpper(String input) =>
      isEnglish ? input.toUpperCase() : _turkishUpper(input);

  String _languageLower(String input) =>
      isEnglish ? input.toLowerCase() : _turkishLower(input);

  String _languageCapitalizeFirst(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return "";
    final lower = _languageLower(trimmed);
    final first = languageUpper(lower[0]);
    return "$first${lower.substring(1)}";
  }

  // Returns formatted clean string or null if invalid
  String? validateNameInput(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty || containsProhibitedWords(trimmed)) return null;
    final clean = languageUpper(trimmed);
    if (!_nameValidationPattern.hasMatch(clean)) return null;
    return clean;
  }

  String? validateWordInput(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty || containsProhibitedWords(trimmed)) return null;
    final clean = languageUpper(trimmed);
    if (!_wordValidationPattern.hasMatch(clean)) return null;
    return clean;
  }

  bool containsProhibitedWords(String input) {
    final upper = _turkishUpper(input);
    final words = upper.split(RegExp(r'[^A-ZÇĞİÖŞÜ0-9]+'));
    for (var bad in _badWords) {
      if (words.contains(bad)) return true;
    }
    return false;
  }

  void applyCategoryChanges(Set<String> selected, Set<String> disabledIds) {
    selectedCategories = selected.where(isCategoryUnlocked).toSet();
    disabledCardIds = disabledIds;
    _syncDisabledWithCategories();
    _persist();
    notifyListeners();
  }

  // --- ACTIONS ---
  void toggleSound(bool val) {
    soundEnabled = val;
    _persist();
    notifyListeners();
  }

  void toggleMusic(bool val) {
    musicEnabled = val;
    ensureAudioInitialized();
    _updateMusicState();
    _persist();
    notifyListeners();
  }

  void toggleVibration(bool val) {
    vibrationEnabled = val;
    _persist();
    if (val) HapticFeedback.heavyImpact();
    notifyListeners();
  }

  void toggleReducedMotion(bool val) {
    reducedMotion = val;
    _persist();
    notifyListeners();
  }

  void clearRecentUnlockedCategory() {
    _recentUnlockedCategory = null;
    _recentUnlockedPermanent = false;
    notifyListeners();
  }

  void cycleThemeMode() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _persist();
    notifyListeners();
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case "dark":
        return ThemeMode.dark;
      case "light":
      default:
        return ThemeMode.light;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return "dark";
      case ThemeMode.light:
      default:
        return "light";
    }
  }

  bool get isEnglish => languageCode == "en";

  void toggleLanguage() {
    final bool wasEnglish = isEnglish;
    final String previousTeamA = wasEnglish ? _teamADefaultEn : _teamADefaultTr;
    final String previousTeamB = wasEnglish ? _teamBDefaultEn : _teamBDefaultTr;
    languageCode = wasEnglish ? "tr" : "en";
    final String nextTeamA = isEnglish ? _teamADefaultEn : _teamADefaultTr;
    final String nextTeamB = isEnglish ? _teamBDefaultEn : _teamBDefaultTr;
    if (teamAName == previousTeamA) {
      teamAName = nextTeamA;
    }
    if (teamBName == previousTeamB) {
      teamBName = nextTeamB;
    }
    _persist();
    notifyListeners();
  }

  String t(String key, {Map<String, String> params = const {}}) {
    const Map<String, Map<String, String>> strings = {
      "tr": {
        "app_title": "Onu Söyleyemiyoruz",
        "menu_title": "ONU\nSÖYLEYEMİYORUZ",
        "menu_play": "OYNA",
        "menu_settings": "AYARLAR",
        "menu_how_to_play": "NASIL OYNANIR?",
        "menu_exit": "ÇIKIŞ",
        "theme_dark": "Tema: Koyu",
        "theme_light": "Tema: Açık",
        "lang_tr": "TR",
        "lang_en": "EN",
        "lang_tooltip": "Dil değiştir",
        "yes": "EVET",
        "no": "HAYIR",
        "cancel": "İptal",
        "save": "Kaydet",
        "close": "Kapat",
        "undo": "GERİ AL",
        "seconds_short": "sn",
        "team_a": _teamADefaultTr,
        "team_b": _teamBDefaultTr,
        "settings_title": "AYARLAR",
        "settings_music": "Müzik",
        "settings_sfx": "Ses Efektleri",
        "settings_vibration": "Titreşim",
        "settings_performance": "Performans Modu",
        "setup_title": "Oyun Ayarları",
        "team_management": "TAKIM YÖNETİMİ",
        "manage_categories": "KATEGORİLERİ YÖNET",
        "manage_categories_title": "Kategorileri Yönet",
        "round_time_label": "⏱️ Süre (saniye)",
        "target_score_label": "🏆 Hedef Puan",
        "round_time_changed": "⏱️ Tur süresi {seconds} sn olarak değiştirildi.",
        "target_score_changed": "🏆 {score} puana ulaşan kazanır!",
        "target_score_unlimited": "Oyun istenildiği zaman bitirebilir!",
        "round_time_chip": "Tur süresi: {seconds} saniye",
        "target_score_chip": "Oyunu kazanmak için hedef: {score} puan",
        "roll_and_play": "ZAR AT & OYNA",
        "missing_players": "{team} takımında eksik oyuncu var.",
        "equal_players_required": "Takımlardaki oyuncu sayıları eşit olmalı.",
        "suggested_name": "✨ {name} önerildi",
        "save_and_back": "KAYDET VE DÖN",
        "no_players": "Oyuncu yok",
        "add_player": "Oyuncu Ekle",
        "team_name_title": "Takım Adını Düzenle",
        "suggest": "Öner",
        "team_name_saved": "Takım adı {name} olarak kaydedildi",
        "add_player_to_team": "{team} takımına oyuncu ekle",
        "add": "Ekle",
        "player_added": "{player} adlı oyuncu {team} takımına eklendi",
        "player_removed": "{player} adlı oyuncu {team} takımından çıkarıldı",
        "player_updated": "Oyuncu adı {player} olarak güncellendi",
        "player_not_changed": "Oyuncu adı değiştirilmedi",
        "edit_player": "Oyuncu Adını Düzenle",
        "category_word_count": "{active} / {total} Kelime",
        "custom_empty_warning": "Özel kategorisi boş. Önce kelime ekleyin.",
        "categories_updated": "Kategoriler güncellendi",
        "status_on": "AÇIK",
        "status_partial": "KISMİ AÇIK",
        "status_off": "KAPALI",
        "words_button": "KELİMELER",
        "no_cards": "Kart Yok",
        "custom_add_hint":
            "Özel kart eklemek için sağ üstteki + ikonuna basınız",
        "custom_label": "ÖZEL",
        "custom_added": "{word} {category} kategorisine eklendi",
        "custom_updated": "{word} güncellendi",
        "custom_deleted": "{word} silindi",
        "add_custom_card": "Özel Kart Ekle",
        "edit_custom_card": "Özel Kartı Düzenle",
        "word_hint": "KELİME",
        "taboo_hint": "Tabu {index}",
        "save_and_exit": "Kaydet ve Çık",
        "save_and_continue": "Kaydet ve Devam Et",
        "exit": "Çık",
        "exit_without_save": "Kaydetmeden Çık",
        "exit_game_title": "Oyundan çıkılsın mı?",
        "exit_game_body": "Oyunu bırakmak üzeresiniz. Emin misiniz?",
        "exit_game_action": "Oyundan Çık",
        "label_taboo": "TABU",
        "label_pass": "PAS",
        "label_correct": "DOĞRU",
        "floating_taboo": "TABU!",
        "floating_pass": "PAS",
        "floating_correct": "DOĞRU!",
        "paused_title": "DURDURULDU",
        "paused_body":
            "Oyun durduruldu. Devam edebilir veya ana menüye dönebilirsin.",
        "paused_background":
            "Oyun otomatik durduruldu. Devam edebilir veya ana menüye dönebilirsin.",
        "resume": "DEVAM ET",
        "return_menu": "ANA MENÜYE DÖN",
        "sound_on": "Ses Açık",
        "sound_off": "Ses Kapalı",
        "vibration_on": "Titreşim Açık",
        "vibration_off": "Titreşim Kapalı",
        "remaining_cards_label": "Kalan: {count} Kart",
        "next_label": "SIRADAKİ",
        "team_label": "TAKIM",
        "narrator_label": "ANLATICI",
        "remaining_cards_short": "{count} kalan kart",
        "start": "BAŞLA",
        "round_result_title": "TUR SONUCU",
        "recap_title": "OYUN ÖZETİ",
        "recap_team_based": "TAKIM İSTATİSTİKLERİ",
        "recap_player_based": "OYUNCU İSTATİSTİKLERİ",
        "recap_to_player": "Oyuncu İstatistiklerine Geç",
        "recap_round_label": "Tur {index}",
        "recap_round_points": "Tur Puanı",
        "recap_points": "Puan",
        "recap_correct": "Doğru",
        "recap_pass": "Pas",
        "recap_taboo": "Tabu",
        "recap_narrator": "Anlatıcı",
        "recap_skip": "Atla",
        "recap_continue": "Sonuçlara Geç",
        "recap_no_data": "Henüz tur verisi yok.",
        "recap_most_word_guesser": "En Çok Kelime Tahmin Ettiren",
        "recap_least_tabooed": "En Az Tabu Yapan",
        "recap_quickest_player": "En Hızlı Oyuncu",
        "recap_passing_player": "En Çok Pas Yapan",
        "recap_risky_narrator": "Riskli Anlatıcı",
        "recap_taboo_monster": "Tabu Canavarı",
        "recap_slowest_round": "En Yavaş Tur",
        "recap_fastest_round": "En Hızlı Tur",
        "recap_in_a_row": "üst üste",
        "tab_correct": "BİLİNENLER",
        "tab_taboo": "TABU OLANLAR",
        "tab_pass": "PAS GEÇİLENLER",
        "stat_correct": "DOĞRU",
        "stat_taboo": "TABU",
        "stat_score": "PUAN",
        "cards_finished": "Kartlar bitti",
        "remaining_cards": "Kalan kart: {count}",
        "continue": "DEVAM ET",
        "end_game": "OYUNU BİTİR",
        "no_cards_lower": "Kart yok",
        "time_up": "Süre bitti",
        "rolling_dice": "ZARLAR ATILIYOR!",
        "game_starts_with_team": "Oyuna {team} TAKIMI BAŞLIYOR!",
        "game_over_title": "OYUN BİTTİ",
        "winner_label": "KAZANAN",
        "tie_label": "BERABERE",
        "share": "Paylaş",
        "rematch": "RÖVANŞ?",
        "score_summary": "Skor özeti",
        "share_winner": "Kazanan: {winner}",
        "share_message_win":
            "Bakın! {winner} olarak {loser} takımını yendik. {app} oyununa sen de katıl!",
        "share_message_tie":
            "Bakın! {teamA} ile {teamB} berabere kaldı. {app} oyununa sen de katıl!",
        "share_tie": "Berabere",
        "return_menu_button": "ANA MENÜYE DÖN",
        "quick_tip_title": "Hızlı Başlangıç İpucu",
        "tip_time_title": "Süre",
        "tip_time_body":
            "Her turda geri sayılan zaman dolunca tur otomatik biter.",
        "tip_pass_title": "Pas",
        "tip_pass_body":
            "En fazla 3 kez pas geçme hakkın var; her bastığında bir hak azalır.",
        "tip_taboo_title": "Tabu",
        "tip_taboo_body":
            "Yasaklı kelimelerden birini söylersen puan kaybedersin, kart değişir.",
        "got_it": "Anladım",
        "how_to_play": "Nasıl Oynanır?",
        "game_summary_title": "Oyunun Özeti",
        "game_summary_body":
            "Takımlar, anlatıcının tabu kelimelerini kullanmadan karttaki ana kelimeyi anlattığı bir tahmin oyunu oynar.",
        "tip_time_management_title": "Süre Yönetimi",
        "tip_time_management_body":
            "Her tur 30 ila 90 saniye arasında sürer. Sayaç ekranın ortasındadır; 0 olunca tur biter ve tur özeti görünür.",
        "tip_pass_right_title": "Pas Hakkı",
        "tip_pass_right_body":
            "Tur başlangıcında 3 pas hakkın olur. 3 defa kart geçtiğinde, yani 'PAS' butonuna bastığında daha fazla kart geçemezsin.",
        "tip_taboo_penalty_title": "Tabu Cezası",
        "tip_taboo_penalty_body":
            "Tabu kelime söylendiğinde (yakalandığında) takım puanı bir azalır ve yeni karta geçilir.",
        "tip_narrator_cycle_title": "Anlatıcı Döngüsü",
        "tip_narrator_cycle_body":
            "Takım sırası ekrandaki 'Anlatıcı' alanında görünür; her tur sonunda sıra bir sonraki oyuncuya geçer.",
        "tip_feedback_title": "Geri Bildirim",
        "tip_feedback_body":
            "Tabu/Doğru/Pas butonlarının üstündeki ses ve titreşim kısayolları ile anında dokunsal/işitsel geri bildirimi aç/kapa yapabilirsin.",
        "onboard_title_1": "Takımını Kur",
        "onboard_subtitle_1":
            "Arkadaşlarını ekle, kategorini seç.\nOyun başlarken her şey hazır olsun.",
        "onboard_title_2": "Anlat ama Dikkat!",
        "onboard_subtitle_2":
            "Yasaklı kelimeyi söylersen buzzer çalar 😈\nHızlı anlat, puanı kap!",
        "onboard_title_3": "Eğlen & Kazan",
        "onboard_subtitle_3":
            "Tur sonunda skorları paylaş.\nRövanş için tek dokunuş yeter!",
        "onboard_back": "Geri",
        "onboard_next": "İleri",
        "onboard_start": "Oyuna Başla 🚀",
        "onboard_skip": "Geç",
        "confirm_exit_title": "Ana menüye dönülsün mü?",
        "confirm_exit_body": "Oyundan çıkmak istediğine emin misin?",
        "end_all_cards": "Tüm kartlar kullanıldı",
        "no_player": "Oyuncu Yok",
        "error_word_empty": "Kelime boş olamaz",
        "error_word_profanity": "Uygunsuz kelime tespit edildi",
        "error_word_max": "Kelime en fazla {max} karakter olabilir",
        "error_word_invalid": "Kelime geçersiz",
        "error_taboo_profanity": "Uygunsuz tabu kelimesi tespit edildi",
        "error_taboo_count": "5 tabu kelime girmelisin",
        "error_taboo_unique": "Tabu kelimeleri benzersiz olmalı",
        "error_word_exists": "Bu kelime zaten var",
        "error_name_empty": "İsim boş olamaz",
        "error_name_profanity": "Uygunsuz isim tespit edildi",
        "error_team_name_max": "Takım adı en fazla 20 karakter olabilir",
        "error_player_name_max": "Oyuncu adı en fazla 16 karakter olabilir",
        "error_name_invalid": "İsim geçersiz",
        "error_team_name_same": "Diğer takımla aynı isim olamaz",
        "error_player_exists": "Bu oyuncu zaten ekli",
        "error_team_max_players": "Bir takımda en fazla 6 oyuncu olabilir",
        "category_genel": "Genel",
        "category_spor": "Spor",
        "category_bilim": "Bilim",
        "category_yemek": "Yemek",
        "category_sanat": "Sanat",
        "category_teknoloji": "Teknoloji",
        "category_doga": "Doğa",
        "category_tarih": "Tarih",
        "category_ozel": "Özel",
        "category_futbol_pack": "Futbol",
        "category_90s": "90'lar Nostalji",
        "category_hard_pack": "Zor Seviye",
        "category_midnight_pack": "Ateşli Gece",
        "ads_section_title": "Satın Alımlar",
        "remove_ads": "Reklamları Kaldır",
        "remove_ads_desc": "Reklamlar kapanır, bütün kategoriler açılır!",
        "remove_ads_owned": "Reklamlar kaldırıldı",
        "premium_bundle_owned": "Premium paket satın alındı",
        "restore_purchases": "Satın Alımları Geri Yükle",
        "watch_ad_unlock": "Reklam izle",
        "watch_ad_1h": "İzle & 1 saatlik aç",
        "buy_unlock_forever": "Satın al, kalıcı aç",
        "watch_ad_unlock_short": "İZLE VE AÇ",
        "buy_unlock_short": "SATIN AL VE AÇ",
        "unlock_category_title": "Kategori Kilitli",
        "unlock_category_body_ad":
            "{category} kategorisini açmak için reklam izle",
        "unlock_category_body_premium":
            "{category} kategorisini 1 saatliğine açmak için reklam izle veya reklamları kaldırıp tüm kategorileri açmak için satın al",
        "unlock_success": "{category} açıldı",
        "unlock_failed": "Reklam şu an hazır değil",
        "unlock_redeemed_forever": "{category} kalıcı açıldı",
        "unlock_redeemed_1h": "{category} 1 saatliğine açıldı",
        "reward_limit_reached":
            "{category} için 1 saatlik erişim sona erdi. Yeniden açmalısın.",
        "reward_active_warning":
            "Premium kategorilerden biri şu anda zaten kullanımda. Süre bitince tekrar deneyebilirsin.",
        "badge_locked": "KİLİTLİ",
        "badge_paid": "PARALI",
        "badge_ad": "REKLAMLA",
        "buy": "Satın Al",
        "unlock_button": "KİLİDİ AÇ",
        "reward_active": "Geçici Açık",
        "ad_break_title": "Kısa Ara",
        "ad_break_body": "Reklam 5 saniye sonra geçilebilir",
        "ads_skip": "Geç",
        "game_center_title": "Game Center",
        "game_center_desc": "Başarımlarını Game Center ile eşitle",
        "game_center_connect": "Bağlan",
        "game_center_connected": "Bağlandı",
        "game_center_achievements": "Başarımlar",
        "game_center_connect_failed": "Game Center bağlantısı kurulamadı",
        "game_center_achievements_failed": "Başarımlar açılamadı",
      },
      "en": {
        "app_title": "We Can't Say It",
        "menu_title": "WE CAN'T\nSAY IT",
        "menu_play": "PLAY",
        "menu_settings": "SETTINGS",
        "menu_how_to_play": "HOW TO PLAY",
        "menu_exit": "EXIT",
        "theme_dark": "Theme: Dark",
        "theme_light": "Theme: Light",
        "lang_tr": "TR",
        "lang_en": "EN",
        "lang_tooltip": "Switch language",
        "yes": "YES",
        "no": "NO",
        "cancel": "Cancel",
        "save": "Save",
        "close": "Close",
        "undo": "UNDO",
        "seconds_short": "s",
        "team_a": _teamADefaultEn,
        "team_b": _teamBDefaultEn,
        "settings_title": "SETTINGS",
        "settings_music": "Music",
        "settings_sfx": "Sound Effects",
        "settings_vibration": "Vibration",
        "settings_performance": "Performance Mode",
        "setup_title": "Game Settings",
        "team_management": "TEAM MANAGEMENT",
        "manage_categories": "MANAGE CATEGORIES",
        "manage_categories_title": "Manage Categories",
        "round_time_label": "⏱️ Time (seconds)",
        "target_score_label": "🏆 Target Score",
        "round_time_changed": "⏱️ Round time set to {seconds} s.",
        "target_score_changed": "🏆 First to {score} points wins!",
        "target_score_unlimited": "End the game anytime!",
        "round_time_chip": "Round time: {seconds} seconds",
        "target_score_chip": "Target to win: {score} points",
        "roll_and_play": "ROLL & PLAY",
        "missing_players": "{team} team is missing players.",
        "equal_players_required": "Teams must have the same number of players.",
        "suggested_name": "✨ Suggested: {name}",
        "save_and_back": "SAVE & BACK",
        "no_players": "No players",
        "add_player": "Add Player",
        "team_name_title": "Edit Team Name",
        "suggest": "Suggest",
        "team_name_saved": "Team name saved as {name}",
        "add_player_to_team": "Add player to {team}",
        "add": "Add",
        "player_added": "{player} added to {team}",
        "player_removed": "{player} removed from {team}",
        "player_updated": "Player name updated to {player}",
        "player_not_changed": "Player name not changed",
        "edit_player": "Edit Player Name",
        "category_word_count": "{active} / {total} Words",
        "custom_empty_warning": "Custom category is empty. Add words first.",
        "categories_updated": "Categories updated",
        "status_on": "ON",
        "status_partial": "PARTIAL",
        "status_off": "OFF",
        "words_button": "WORDS",
        "no_cards": "No Cards",
        "custom_add_hint": "Tap the + icon at top right to add a custom card",
        "custom_label": "CUSTOM",
        "custom_added": "{word} added to {category}",
        "custom_updated": "{word} updated",
        "custom_deleted": "{word} deleted",
        "add_custom_card": "Add Custom Card",
        "edit_custom_card": "Edit Custom Card",
        "word_hint": "WORD",
        "taboo_hint": "Taboo {index}",
        "save_and_exit": "Save & Exit",
        "save_and_continue": "Save & Continue",
        "exit": "Exit",
        "exit_without_save": "Exit Without Saving",
        "exit_game_title": "Exit the game?",
        "exit_game_body": "You're about to leave the game. Are you sure?",
        "exit_game_action": "Exit Game",
        "label_taboo": "TABOO",
        "label_pass": "PASS",
        "label_correct": "CORRECT",
        "floating_taboo": "TABOO!",
        "floating_pass": "PASS",
        "floating_correct": "CORRECT!",
        "paused_title": "PAUSED",
        "paused_body": "Game paused. You can resume or return to main menu.",
        "paused_background":
            "Auto paused. You can resume or return to main menu.",
        "resume": "RESUME",
        "return_menu": "MAIN MENU",
        "sound_on": "Sound On",
        "sound_off": "Sound Off",
        "vibration_on": "Vibration On",
        "vibration_off": "Vibration Off",
        "remaining_cards_label": "Remaining: {count} Cards",
        "next_label": "NEXT",
        "team_label": "TEAM",
        "narrator_label": "NARRATOR",
        "remaining_cards_short": "{count} cards left",
        "start": "START",
        "round_result_title": "ROUND RESULT",
        "recap_title": "GAME RECAP",
        "recap_team_based": "TEAM STATS",
        "recap_player_based": "PLAYER STATS",
        "recap_to_player": "Go to Player Stats",
        "recap_round_label": "Round {index}",
        "recap_round_points": "Round Points",
        "recap_points": "Points",
        "recap_correct": "Correct",
        "recap_pass": "Pass",
        "recap_taboo": "Taboo",
        "recap_narrator": "Narrator",
        "recap_skip": "Skip",
        "recap_continue": "View Results",
        "recap_no_data": "No round data yet.",
        "recap_most_word_guesser": "Most Words Guesser",
        "recap_least_tabooed": "Least Tabooed Player",
        "recap_quickest_player": "The Quickest Player",
        "recap_passing_player": "The Passing Player",
        "recap_risky_narrator": "Risky Narrator",
        "recap_taboo_monster": "Taboo Monster",
        "recap_slowest_round": "Slowest Round",
        "recap_fastest_round": "Fastest Round",
        "recap_in_a_row": "in a row",
        "tab_correct": "CORRECT",
        "tab_taboo": "TABOO",
        "tab_pass": "PASSED",
        "stat_correct": "CORRECT",
        "stat_taboo": "TABOO",
        "stat_score": "SCORE",
        "cards_finished": "Cards finished",
        "remaining_cards": "Remaining cards: {count}",
        "continue": "CONTINUE",
        "end_game": "END GAME",
        "no_cards_lower": "No cards",
        "time_up": "Time's up",
        "rolling_dice": "ROLLING DICE!",
        "game_starts_with_team": "TEAM {team} starts the game!",
        "game_over_title": "GAME OVER",
        "winner_label": "WINNER",
        "tie_label": "TIE",
        "share": "Share",
        "rematch": "REMATCH?",
        "score_summary": "Score summary",
        "share_winner": "Winner: {winner}",
        "share_message_win":
            "Hey look! We, {winner}, beat {loser}. Come join us in {app}!",
        "share_message_tie":
            "Hey look! {teamA} and {teamB} tied. Come join us in {app}!",
        "share_tie": "Tie",
        "return_menu_button": "RETURN TO MENU",
        "quick_tip_title": "Quick Start Tip",
        "tip_time_title": "Timer",
        "tip_time_body": "When time runs out, the round ends automatically.",
        "tip_pass_title": "Pass",
        "tip_pass_body": "You have up to 3 passes; each tap uses one.",
        "tip_taboo_title": "Taboo",
        "tip_taboo_body":
            "Say a taboo word and you lose a point; the card changes.",
        "got_it": "Got it",
        "how_to_play": "How to Play",
        "game_summary_title": "Game Summary",
        "game_summary_body":
            "Teams play a guessing game where the narrator describes the main word without using taboo words.",
        "tip_time_management_title": "Time Management",
        "tip_time_management_body":
            "Each round lasts between 30 to 90 seconds. The timer is in the center of the screen; when it hits 0, the round ends and round summary appears.",
        "tip_pass_right_title": "Pass Right",
        "tip_pass_right_body":
            "You start with 3 passes. After pressing PASS three times, you can't skip more cards.",
        "tip_taboo_penalty_title": "Taboo Penalty",
        "tip_taboo_penalty_body":
            "If a taboo word is said, the team loses a point and moves to the next card.",
        "tip_narrator_cycle_title": "Narrator Rotation",
        "tip_narrator_cycle_body":
            "The current narrator is shown on screen; after each round, it moves to the next player.",
        "tip_feedback_title": "Feedback",
        "tip_feedback_body":
            "Use the sound and vibration shortcuts above the Taboo/Correct/Pass buttons to toggle feedback.",
        "onboard_title_1": "Build Your Team",
        "onboard_subtitle_1":
            "Add friends and pick categories.\nBe ready when the game starts.",
        "onboard_title_2": "Describe, But Careful!",
        "onboard_subtitle_2":
            "Say a taboo word and the buzzer hits 😈\nExplain fast, grab the points!",
        "onboard_title_3": "Have Fun & Win",
        "onboard_subtitle_3":
            "Share scores after each round.\nOne tap for a rematch!",
        "onboard_back": "Back",
        "onboard_next": "Next",
        "onboard_start": "Start Game 🚀",
        "onboard_skip": "Skip",
        "confirm_exit_title": "Return to main menu?",
        "confirm_exit_body": "Are you sure you want to leave the game?",
        "end_all_cards": "All cards used",
        "no_player": "No Player",
        "error_word_empty": "Word cannot be empty",
        "error_word_profanity": "Inappropriate word detected",
        "error_word_max": "Word can be at most {max} characters",
        "error_word_invalid": "Invalid word",
        "error_taboo_profanity": "Inappropriate taboo word detected",
        "error_taboo_count": "Enter 5 taboo words",
        "error_taboo_unique": "Taboo words must be unique",
        "error_word_exists": "This word already exists",
        "error_name_empty": "Name cannot be empty",
        "error_name_profanity": "Inappropriate name detected",
        "error_team_name_max": "Team name can be at most 20 characters",
        "error_player_name_max": "Player name can be at most 16 characters",
        "error_name_invalid": "Invalid name",
        "error_team_name_same": "Cannot match the other team name",
        "error_player_exists": "Player already added",
        "error_team_max_players": "A team can have at most 6 players",
        "category_genel": "General",
        "category_spor": "Sports",
        "category_bilim": "Science",
        "category_yemek": "Food",
        "category_sanat": "Art",
        "category_teknoloji": "Technology",
        "category_doga": "Nature",
        "category_tarih": "History",
        "category_ozel": "Custom",
        "category_futbol_pack": "Football",
        "category_90s": "90s Nostalgia",
        "category_hard_pack": "Hard Mode",
        "category_midnight_pack": "Naughty Night",
        "ads_section_title": "Purchases",
        "remove_ads": "Remove Ads",
        "remove_ads_desc": "Ads off, all categories on!",
        "remove_ads_owned": "Ads removed",
        "premium_bundle_owned": "Premium Bundle owned",
        "restore_purchases": "Restore Purchases",
        "watch_ad_unlock": "Watch ad",
        "watch_ad_1h": "Watch & unlock for 1H",
        "buy_unlock_forever": "Buy and Unlock For Good",
        "watch_ad_unlock_short": "WATCH & UNLOCK",
        "buy_unlock_short": "BUY & UNLOCK",
        "unlock_category_title": "Category Locked",
        "unlock_category_body_ad":
            "Watch an ad to unlock the {category} category",
        "unlock_category_body_premium":
            "Watch an ad to unlock {category} for 1 hour or buy remove-ads to unlock every category forever.",
        "unlock_success": "{category} unlocked",
        "unlock_failed": "Ad is not ready",
        "unlock_redeemed_forever": "{category} unlocked forever",
        "unlock_redeemed_1h": "{category} unlocked for 1 hour",
        "reward_limit_reached":
            "{category} 1-hour access ended. Please unlock again.",
        "reward_active_warning":
            "Another premium category is already unlocked. Try again when it ends.",
        "badge_locked": "LOCKED",
        "badge_paid": "PAID",
        "badge_ad": "AD",
        "buy": "Buy",
        "unlock_button": "UNLOCK",
        "reward_active": "Temporary Access",
        "ad_break_title": "Short Break",
        "ad_break_body": "You can skip in 5 seconds",
        "ads_skip": "Skip",
        "game_center_title": "Game Center",
        "game_center_desc": "Sync your achievements with Game Center",
        "game_center_connect": "Connect",
        "game_center_connected": "Connected",
        "game_center_achievements": "Achievements",
        "game_center_connect_failed": "Could not connect to Game Center",
        "game_center_achievements_failed": "Could not open achievements",
      },
    };
    String value = strings[languageCode]?[key] ?? strings["tr"]?[key] ?? key;
    params.forEach((k, v) {
      value = value.replaceAll("{$k}", v);
    });
    return value;
  }

  static const Map<String, String> _categoryKeys = {
    "Genel": "category_genel",
    "Spor": "category_spor",
    "Bilim": "category_bilim",
    "Yemek": "category_yemek",
    "Sanat": "category_sanat",
    "Teknoloji": "category_teknoloji",
    "Doğa": "category_doga",
    "Tarih": "category_tarih",
    "Futbol": "category_futbol_pack",
    "90'lar Nostalji": "category_90s",
    "Zor Seviye": "category_hard_pack",
    "Gece Yarısı": "category_midnight_pack",
    "Özel": "category_ozel",
  };

  String categoryLabel(String category) {
    final key = _categoryKeys[category];
    if (key == null) return category;
    return t(key);
  }

  void toggleRepeats(bool val) {
    _allowRepeats = val;
    _persist();
    notifyListeners();
  }

  void toggleCategory(String cat) {
    if (!isCategoryUnlocked(cat)) return;
    final ids = _idsForCategory(cat);
    if (selectedCategories.contains(cat)) {
      if (selectedCategories.length > 1) {
        selectedCategories.remove(cat);
        disabledCardIds.addAll(ids);
      }
    } else {
      selectedCategories.add(cat);
      disabledCardIds.removeWhere(ids.contains);
    }
    _syncDisabledWithCategories();
    _persist();
    notifyListeners();
  }

  void toggleWordStatus(String cardId) {
    if (disabledCardIds.contains(cardId)) {
      disabledCardIds.remove(cardId);
    } else {
      disabledCardIds.add(cardId);
    }
    _persist();
    notifyListeners();
  }

  Set<String> _idsForCategory(String cat) {
    return allCards.where((w) => w.category == cat).map((w) => w.id).toSet();
  }

  void _syncDisabledWithCategories() {
    for (final card in allCards) {
      if (!selectedCategories.contains(card.category) ||
          !isCategoryUnlocked(card.category)) {
        disabledCardIds.add(card.id);
      }
    }
  }

  String _turkishUpper(String input) {
    return input
        .split('')
        .map(
          (c) => c == 'i'
              ? 'İ'
              : c == 'ı'
              ? 'I'
              : c.toUpperCase(),
        )
        .join();
  }

  String _turkishLower(String input) {
    return input
        .split('')
        .map(
          (c) => c == 'I'
              ? 'ı'
              : c == 'İ'
              ? 'i'
              : c.toLowerCase(),
        )
        .join();
  }

  String _stableId(String word, String category) {
    String sanitize(String v) {
      return v
          .replaceAll(RegExp(r'[^A-Za-z0-9ÇĞİÖŞÜçğıöşü]+'), "_")
          .replaceAll(RegExp(r'_+'), "_")
          .trim()
          .toUpperCase();
    }

    return "${sanitize(category)}_${sanitize(word)}";
  }

  String? addCustomCard(String word, List<String> taboos) {
    if (word.trim().isEmpty) return t("error_word_empty");
    if (containsProhibitedWords(word)) return t("error_word_profanity");
    if (word.trim().length > 16) {
      return t("error_word_max", params: {"max": "16"});
    }
    String? cleanWord = validateWordInput(word);
    if (cleanWord == null) return t("error_word_invalid");
    final cleanTaboos = taboos
        .map((e) => validateWordInput(e) ?? "")
        .where((e) => e.isNotEmpty)
        .toList();
    if (cleanTaboos.any((t) => containsProhibitedWords(t))) {
      return t("error_taboo_profanity");
    }
    if (cleanTaboos.length < 5) {
      return t("error_taboo_count");
    }
    if (cleanTaboos.toSet().length < 5) {
      return t("error_taboo_unique");
    }
    final id = _stableId(cleanWord, "Özel");
    if (_idsForCategory("Özel").contains(id)) {
      return t("error_word_exists");
    }
    final formattedTaboos = cleanTaboos
        .take(5)
        .map(_languageCapitalizeFirst)
        .toList(growable: false);
    cleanWord = languageUpper(cleanWord);
    customCards.add(
      WordCard(
        id: id,
        word: cleanWord,
        tabooWords: formattedTaboos,
        category: "Özel",
        isCustom: true,
      ),
    );
    _persist();
    notifyListeners();
    return null;
  }

  void removeCustomCard(String id) {
    customCards.removeWhere((c) => c.id == id);
    disabledCardIds.remove(id);
    _persist();
    notifyListeners();
  }

  void restoreCustomCard(WordCard card, {bool disabled = false}) {
    if (!_idsForCategory("Özel").contains(card.id)) {
      customCards.add(card);
    }
    if (disabled) {
      disabledCardIds.add(card.id);
    }
    _persist();
    notifyListeners();
  }

  String? updateCustomCard(
    WordCard original,
    String newWord,
    List<String> taboos,
  ) {
    if (newWord.trim().isEmpty) return t("error_word_empty");
    if (containsProhibitedWords(newWord)) {
      return t("error_word_profanity");
    }
    if (newWord.trim().length > 16) {
      return t("error_word_max", params: {"max": "16"});
    }
    String? cleanWord = validateWordInput(newWord);
    if (cleanWord == null) return t("error_word_invalid");

    final cleanTaboos = taboos
        .map((e) => validateWordInput(e) ?? "")
        .where((e) => e.isNotEmpty)
        .toList();
    if (cleanTaboos.length < 5) return t("error_taboo_count");
    if (cleanTaboos.any((t) => containsProhibitedWords(t))) {
      return t("error_taboo_profanity");
    }
    if (cleanTaboos.toSet().length < 5) {
      return t("error_taboo_unique");
    }

    final newId = _stableId(cleanWord, "Özel");
    if (newId != original.id && _idsForCategory("Özel").contains(newId)) {
      return t("error_word_exists");
    }

    final formattedTaboos = cleanTaboos
        .take(5)
        .map(_languageCapitalizeFirst)
        .toList(growable: false);
    cleanWord = languageUpper(cleanWord);

    final bool wasDisabled = disabledCardIds.contains(original.id);
    customCards.removeWhere((c) => c.id == original.id);
    disabledCardIds.remove(original.id);
    customCards.add(
      WordCard(
        id: newId,
        word: cleanWord,
        tabooWords: formattedTaboos,
        category: "Özel",
        isCustom: true,
      ),
    );
    if (wasDisabled) {
      disabledCardIds.add(newId);
    }
    _persist();
    notifyListeners();
    return null;
  }

  void updateSettings({int? time, int? score}) {
    if (time != null) _roundTime = time;
    if (score != null) _targetScore = score;
    _persist();
    notifyListeners();
  }

  String? setTeamName(bool isTeamA, String name) {
    if (name.trim().isEmpty) return t("error_name_empty");
    if (containsProhibitedWords(name)) return t("error_name_profanity");
    if (name.trim().length > 20) {
      return t("error_team_name_max");
    }
    String? valid = validateNameInput(name);
    if (valid == null) return t("error_name_invalid");
    if (isTeamA && valid == teamBName) {
      return t("error_team_name_same");
    }
    if (!isTeamA && valid == teamAName) {
      return t("error_team_name_same");
    }

    if (isTeamA) {
      teamAName = valid;
    } else {
      teamBName = valid;
    }
    _persist();
    notifyListeners();
    return null;
  }

  String? addPlayer(String name, bool toTeamA) {
    if (name.trim().isEmpty) return t("error_name_empty");
    if (containsProhibitedWords(name)) return t("error_name_profanity");
    if (name.trim().length > 16) return t("error_player_name_max");

    String? valid = validateNameInput(name);
    if (valid == null) return t("error_name_invalid");
    if (teamA.contains(valid) || teamB.contains(valid)) {
      return t("error_player_exists");
    }
    if (toTeamA && teamA.length >= 6) {
      return t("error_team_max_players");
    }
    if (!toTeamA && teamB.length >= 6) {
      return t("error_team_max_players");
    }

    if (toTeamA) {
      teamA.add(valid);
    } else {
      teamB.add(valid);
    }
    _persist();
    notifyListeners();
    return null;
  }

  String? editPlayer(String oldName, String newName, bool toTeamA) {
    if (newName.trim().isEmpty) return t("error_name_empty");
    if (containsProhibitedWords(newName)) return t("error_name_profanity");
    if (newName.trim().length > 16) return t("error_player_name_max");

    String? valid = validateNameInput(newName);
    if (valid == null) return t("error_name_invalid");
    final list = toTeamA ? teamA : teamB;
    final exists = list.any((p) => p.toLowerCase() == valid.toLowerCase());
    if (exists && oldName.toLowerCase() != valid.toLowerCase()) {
      return t("error_player_exists");
    }
    final idx = list.indexWhere(
      (p) => p.toLowerCase() == oldName.toLowerCase(),
    );
    if (idx == -1) return t("no_player");
    list[idx] = valid;
    _persist();
    notifyListeners();
    return null;
  }

  String randomPlayerName() {
    final options = isEnglish
        ? [
            "Buzzer Victim",
            "Slip of Tongue",
            "Taboo Hunter",
            "Clueless Hero",
            "Last Second",
            "Word Master",
            "Taboo Boss",
            "Quick Mind",
            "No Buzzer",
            "Fast Talker",
            "Silent Brain",
            "Captain",
            "Guesser",
            "Wildcard",
            "Quiet Player",
            "Strategist",
            "Word Wizard",
            "Mind Ninja",
            "Buzzer Lord",
            "Meaning Master",
          ]
        : [
            "Şeyyyy",
            "Tabu Mağduru",
            "Dil Sürçmesi",
            "Yasak Avcısı",
            "Anlatamayan",
            "Kelime Ustası",
            "Tabu Efendisi",
            "Hızlı Zihin",
            "Hızlı Konuşan",
            "Sessiz Beyin",
            "Komutan",
            "Kaptan",
            "Anlatıcı",
            "Tahminci",
            "Joker",
            "Sessiz Oyuncu",
            "Stratejist",
            "Yasaklı Kahraman",
            "Kelime Büyücüsü",
            "Dil Ninjası",
            "Anlam Ustası",
          ];
    final existing = {...teamA.map(languageUpper), ...teamB.map(languageUpper)};
    final available = options.where((n) => !existing.contains(n)).toList();
    final list = available.isNotEmpty ? available : options;
    return list[Random().nextInt(list.length)];
  }

  String randomTeamName(bool forTeamA) {
    final List<String> pool = isEnglish
        ? [
            "Taboo Masters",
            "Word Hunters",
            "Buzzer Dodgers",
            "Slip Squad",
            "Quick Thinkers",
            "Silent Narrators",
            "Mind Raiders",
            "Last Seconders",
            "No Buzzer Crew",
            "Clue Makers",
            "Word Wizards",
            "Taboo Elite",
            "Finalists",
            "Untouchables",
            "Fast & Forbidden",
            "Brainstormers",
            "Guessing Kings",
            "Meaning Seekers",
            "Clue Sprinters",
            "Buzzer Monsters",
          ]
        : [
            "Yasaklılar",
            "Dili Sürçenler",
            "Tabu Canavarları",
            "Kelime Avcıları",
            "Dili Dönmeyenler",
            "Anlatamayanlar",
            "Son Saniyeciler",
            "Şeyciler",
            "Dilim Yandı",
            "Söyleyemediklerimiz",
            "Yanlışlıkla Söyledik",
            "Ağızdan Kaçtı",
            "Yasak Ama Güzel",
            "Beyin Fırtınası",
            "Kelime Cambazları",
            "Anlam Avcıları",
            "Çağrışımcılar",
            "İma Edenler",
            "Sessiz Anlatıcılar",
            "Kelime Kralları",
            "Tabu Elite",
            "Finalistler",
            "Rakipsizler",
            "Hızlı ve Yasaklı",
            "Son Turcular",
          ];
    pool.shuffle(Random());
    final otherName = languageUpper(forTeamA ? teamBName : teamAName);
    for (final name in pool) {
      if (languageUpper(name) != otherName) {
        return name;
      }
    }
    return isEnglish
        ? "TEAM ${Random().nextInt(90) + 10}"
        : "TAKIM ${Random().nextInt(90) + 10}";
  }

  void removePlayer(String name, bool fromTeamA) {
    if (fromTeamA) {
      teamA.remove(name);
    } else {
      teamB.remove(name);
    }
    _persist();
    notifyListeners();
  }

  // --- GAME LOGIC ---

  bool rollDice() {
    Random r = Random();
    teamADice = r.nextInt(6) + 1;
    teamBDice = r.nextInt(6) + 1;
    while (teamADice == teamBDice) {
      teamADice = r.nextInt(6) + 1;
      teamBDice = r.nextInt(6) + 1;
    }
    isTeamATurn = teamADice > teamBDice;
    notifyListeners();
    return isTeamATurn;
  }

  void startGame() {
    teamAScore = 0;
    teamBScore = 0;
    _teamAPlayerIndex = 0;
    _teamBPlayerIndex = 0;
    gameWinner = null;
    endedByCards = false;
    endMessage = null;
    roundSummaries.clear();
    _cooldownActive = false;
    _cooldownTimer?.cancel();
    _resetDeck();
    _persist();
    notifyListeners();
  }

  void _resetDeck() {
    _activeDeck = allCards.where((card) {
      return selectedCategories.contains(card.category) &&
          !disabledCardIds.contains(card.id);
    }).toList();
    _activeDeck.shuffle();
  }

  void startRound() {
    timeLeft = _roundTime;
    currentPasses = maxPasses;
    _cooldownActive = false;
    _cooldownTimer?.cancel();
    roundHistory.clear();
    _roundEnded = false;
    endedByCards = false;
    endMessage = null;
    isPaused = false;
    abortedToMenu = false;
    nextCard();
    ensureAudioInitialized();
    _updateMusicState();
    _playSfx("start");
    _startTimer();
    notifyListeners();
  }

  void abortCurrentRound() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    _cooldownActive = false;
    timeLeft = -1;
    currentCard = null;
    roundHistory.clear();
    abortedToMenu = true;
    _sfxPlayer.stop();
    _currentSfxName = null;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPaused) return;
      if (timeLeft <= 1) {
        timeLeft = 0;
        notifyListeners();
        endRound();
        return;
      }

      timeLeft--;
      if (vibrationEnabled && timeLeft <= 10 && timeLeft > 0) {
        HapticFeedback.lightImpact();
      }
      notifyListeners();
    });
  }

  void endRound({bool addTimeoutEvent = true, bool playTimeoutFx = true}) {
    if (_roundEnded) return;
    _roundEnded = true;
    _timer?.cancel();
    _cooldownTimer?.cancel();
    _cooldownActive = false;
    timeLeft = 0;
    if (playTimeoutFx) {
      if (vibrationEnabled) HapticFeedback.heavyImpact();
      _playSfx("taboo");
    }

    if (addTimeoutEvent && currentCard != null) {
      roundHistory.add(
        RoundEvent(card: currentCard!, status: CardStatus.pass, timedOut: true),
      );
    }
    currentCard = null;

    final statusList = roundHistory.map((e) => e.status).toList();
    final int correctCount = statusList
        .where((s) => s == CardStatus.correct)
        .length;
    final int passCount = roundHistory
        .where((e) => e.status == CardStatus.pass && !e.timedOut)
        .length;
    final int tabooCount = statusList
        .where((s) => s == CardStatus.taboo)
        .length;
    final int points = correctCount - tabooCount;
    final int turnIndex = roundSummaries.length;
    final int roundNumber = (turnIndex ~/ 2) + 1;
    final int turnInRound = (turnIndex % 2) + 1;
    final summary = RoundSummary(
      turnIndex: turnIndex,
      roundNumber: roundNumber,
      turnInRound: turnInRound,
      isTeamA: isTeamATurn,
      teamName: isTeamATurn ? teamAName : teamBName,
      narrator: currentNarrator,
      correct: correctCount,
      taboo: tabooCount,
      pass: passCount,
      points: points,
      maxTabooStreak: _maxTabooStreak(statusList),
    );
    roundSummaries.add(summary);
    unawaited(_maybeReportAchievements(summary));

    if (_targetScore != -1) {
      if (teamAScore >= _targetScore && teamAScore > teamBScore) {
        gameWinner = teamAName;
      } else if (teamBScore >= _targetScore && teamBScore > teamAScore) {
        gameWinner = teamBName;
      }
    }

    if (!_allowRepeats && _activeDeck.isEmpty && currentCard == null) {
      endedByCards = true;
      endMessage = t("end_all_cards");
      if (gameWinner == null) {
        if (teamAScore > teamBScore) {
          gameWinner = teamAName;
        } else if (teamBScore > teamAScore) {
          gameWinner = teamBName;
        } else {
          gameWinner = null; // tie
        }
      }
    }
    notifyListeners();
  }

  int _maxTabooStreak(List<CardStatus> statuses) {
    int best = 0;
    int current = 0;
    for (final status in statuses) {
      if (status == CardStatus.taboo) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  void finishTurn() {
    if (isTeamATurn) {
      _teamAPlayerIndex++;
    } else {
      _teamBPlayerIndex++;
    }
    isTeamATurn = !isTeamATurn;
    notifyListeners();
  }

  void nextCard() {
    if (_activeDeck.isEmpty) {
      if (_allowRepeats) {
        _resetDeck();
      } else {
        currentCard = null;
        notifyListeners();
        endRound();
        return;
      }
    }
    if (_activeDeck.isNotEmpty) {
      currentCard = _activeDeck.removeLast();
    } else {
      currentCard = null;
    }
    notifyListeners();
  }

  // --- COOLDOWN LOGIC ---
  bool _beginCooldown() {
    if (_cooldownActive) return false;
    _cooldownActive = true;
    notifyListeners();
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(const Duration(seconds: 1), () {
      _cooldownActive = false;
      notifyListeners();
    });
    return true;
  }

  void actionCorrect() {
    if (!_beginCooldown()) return;
    if (isTeamATurn) {
      teamAScore++;
    } else {
      teamBScore++;
    }
    if (vibrationEnabled) HapticFeedback.mediumImpact();
    _playSfx("correct", restartIfPlaying: true, bypassThrottle: true);
    _logEvent(CardStatus.correct);
    if (hasReachedTargetScore) {
      endRound(addTimeoutEvent: false, playTimeoutFx: false);
      return;
    }
    nextCard();
  }

  void actionTaboo() {
    if (!_beginCooldown()) return;
    if (isTeamATurn) {
      teamAScore--;
    } else {
      teamBScore--;
    }
    if (vibrationEnabled) HapticFeedback.heavyImpact();
    _playSfx("taboo", restartIfPlaying: true, bypassThrottle: true);
    _logEvent(CardStatus.taboo);
    nextCard();
  }

  void actionPass() {
    if (!_beginCooldown()) return;
    if (currentPasses > 0) {
      currentPasses--;
      if (vibrationEnabled) HapticFeedback.mediumImpact();
      _playSfx("pass", restartIfPlaying: true, bypassThrottle: true);
      _logEvent(CardStatus.pass);
      nextCard();
    }
  }

  void _logEvent(CardStatus status) {
    if (currentCard != null) {
      roundHistory.add(RoundEvent(card: currentCard!, status: status));
    }
  }

  void markTutorialTipSeen() {
    tutorialTipShown = true;
    _persist();
    notifyListeners();
  }

  void completeOnboarding() {
    onboardingSeen = true;
    _persist();
    notifyListeners();
  }

  Future<String> _ensureAudioFile(String assetPath) async {
    if (_copiedAudioPaths.containsKey(assetPath)) {
      return _copiedAudioPaths[assetPath]!;
    }
    final data = await rootBundle.load("assets/$assetPath");
    final dir = await getTemporaryDirectory();
    final safeName = assetPath.replaceAll("/", "_");
    final file = File("${dir.path}/$safeName");
    if (!await file.exists()) {
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }
    _copiedAudioPaths[assetPath] = file.path;
    return file.path;
  }

  Future<void> ensureAudioInitialized() async {
    if (_audioReady || _audioFailed || _audioInitAttempted) return;
    _audioInitAttempted = true;
    _audioReady = true;
    try {
      if (kIsWeb) {
        const sourceName = "audio/music_loop.mp3";
        await rootBundle.load("assets/$sourceName");
        await _musicPlayer.setSource(AssetSource(sourceName));
        await _musicPlayer.setVolume(musicEnabled ? 0.3 : 0);
        if (musicEnabled) {
          await _musicPlayer.resume();
        }
      } else {
        const sourceName = "audio/music_loop.mp3";
        await rootBundle.load("assets/$sourceName");
        final musicPath = await _ensureAudioFile(sourceName);
        await _musicPlayer.setSource(DeviceFileSource(musicPath));
        await _musicPlayer.setVolume(musicEnabled ? 0.3 : 0);
        if (musicEnabled) {
          await _musicPlayer.resume();
        }
      }
    } on PlatformException catch (e) {
      _audioReady = false;
      _audioFailed = true;
      _audioInitAttempted = true;
      debugPrint("Audio init failed: $e");
      musicEnabled = false;
      soundEnabled = false;
      notifyListeners();
    } catch (e) {
      _audioReady = false;
      _audioFailed = true;
      _audioInitAttempted = true;
      debugPrint("Audio init failed: $e");
      musicEnabled = false;
      soundEnabled = false;
      notifyListeners();
    }
  }

  Future<void> _updateMusicState() async {
    if (!_audioReady || _audioFailed) return;
    if (musicEnabled) {
      await _musicPlayer.setVolume(0.35);
      if (_musicPlayer.state != PlayerState.playing) {
        await _musicPlayer.resume();
      }
    } else {
      await _musicPlayer.pause();
    }
  }

  Future<void> _playSfx(
    String name, {
    bool force = false,
    bool restartIfPlaying = false,
    bool bypassThrottle = false,
  }) async {
    if (abortedToMenu) return;
    if ((!soundEnabled && !force) || !_audioReady || _audioFailed) return;
    final now = DateTime.now();
    final last = _lastSfxAt[name];
    if (!bypassThrottle && last != null && now.difference(last) < _sfxMinGap) {
      return;
    }
    if (_currentSfxName == name && _sfxPlayer.state == PlayerState.playing) {
      if (!restartIfPlaying) return;
    }
    try {
      _lastSfxAt[name] = now;
      _currentSfxName = name;
      final sourceName = "audio/$name.mp3";
      await rootBundle.load("assets/$sourceName");
      await _sfxPlayer.stop();
      if (kIsWeb) {
        await _sfxPlayer.play(AssetSource(sourceName));
      } else {
        final sfxPath = await _ensureAudioFile(sourceName);
        await _sfxPlayer.play(DeviceFileSource(sfxPath));
      }
      _sfxPlayer.onPlayerComplete.first.then((_) {
        if (_currentSfxName == name) {
          _currentSfxName = null;
        }
      });
    } on PlatformException catch (e) {
      debugPrint("SFX failed: $e");
      _audioReady = false;
      _audioFailed = true;
      soundEnabled = false;
      musicEnabled = false;
      _currentSfxName = null;
      notifyListeners();
    } catch (_) {
      if (_currentSfxName == name) {
        _currentSfxName = null;
      }
    }
  }

  Future<void> playClick({bool force = false}) async {
    await ensureAudioInitialized();
    await _playSfx(
      "click",
      force: force,
      restartIfPlaying: true,
      bypassThrottle: true,
    );
  }

  Future<void> playWin({bool force = false}) async {
    await ensureAudioInitialized();
    await _playSfx(
      "win",
      force: force,
      restartIfPlaying: true,
      bypassThrottle: true,
    );
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    _timer?.cancel();
    _cooldownTimer?.cancel();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  void pauseGame() {
    if (isPaused) return;
    isPaused = true;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void resumeGame() {
    if (!isPaused) return;
    isPaused = false;
    _startTimer();
    notifyListeners();
  }
}
