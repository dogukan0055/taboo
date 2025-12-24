import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class GameProvider extends ChangeNotifier {
  // --- Global Settings ---
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;
  bool tutorialTipShown = false;
  bool reducedMotion = false;
  bool onboardingSeen = false;
  ThemeMode themeMode = ThemeMode.light;
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
    "Spor",
    "Bilim",
    "Yemek",
    "Sanat",
    "Teknoloji",
    "Doğa",
    "Tarih",
    "Özel",
  ];
  Set<String> selectedCategories = {
    "Genel",
    "Spor",
    "Bilim",
    "Yemek",
    "Sanat",
    "Teknoloji",
    "Doğa",
    "Tarih",
  };
  Set<String> disabledCardIds = {};
  List<WordCard> customCards = [];

  // --- Game Config ---
  int _roundTime = 60;
  int _targetScore = 50;
  bool _allowRepeats = false;

  // --- Teams & Players ---
  String teamAName = "TAKIM A";
  String teamBName = "TAKIM B";
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

  Future<void> _hydrate() async {
    _prefs = await SharedPreferences.getInstance();
    soundEnabled = _prefs?.getBool("soundEnabled") ?? soundEnabled;
    musicEnabled = _prefs?.getBool("musicEnabled") ?? musicEnabled;
    vibrationEnabled = _prefs?.getBool("vibrationEnabled") ?? vibrationEnabled;
    reducedMotion = _prefs?.getBool("reducedMotion") ?? reducedMotion;
    onboardingSeen = _prefs?.getBool("onboardingSeen") ?? onboardingSeen;
    themeMode = _themeModeFromString(_prefs?.getString("themeMode"));
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
    _syncDisabledWithCategories();
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

  String get currentNarrator {
    if (isTeamATurn) {
      if (teamA.isEmpty) return "Oyuncu Yok";
      return teamA[_teamAPlayerIndex % teamA.length];
    } else {
      if (teamB.isEmpty) return "Oyuncu Yok";
      return teamB[_teamBPlayerIndex % teamB.length];
    }
  }

  List<WordCard> get allCards => [...initialDeck, ...customCards];

  Map<String, List<WordCard>> get wordsByCategory {
    Map<String, List<WordCard>> map = {};
    for (var cat in availableCategories) {
      map[cat] = allCards.where((w) => w.category == cat).toList();
    }
    return map;
  }

  // --- INPUT VALIDATION ---
  // Returns formatted clean string or null if invalid
  String? validateInput(String input) {
    String clean = _turkishUpper(input.trim());
    if (clean.isEmpty || containsProhibitedWords(clean)) return null;
    if (!RegExp(r'^[A-ZÇĞİÖŞÜ ]+$').hasMatch(clean)) return null;
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
    selectedCategories = selected;
    disabledCardIds = disabledIds;
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

  void cycleThemeMode() {
    themeMode = themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
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

  void toggleRepeats(bool val) {
    _allowRepeats = val;
    _persist();
    notifyListeners();
  }

  void toggleCategory(String cat) {
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
      if (!selectedCategories.contains(card.category)) {
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

  String _turkishCapitalizeFirst(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return "";
    final lower = _turkishLower(trimmed);
    final first = _turkishUpper(lower[0]);
    return "$first${lower.substring(1)}";
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
    if (word.trim().isEmpty) return "Kelime boş olamaz";
    if (containsProhibitedWords(word)) return "Uygunsuz kelime tespit edildi";
    if (word.trim().length > 16) return "Kelime en fazla 16 karakter olabilir";
    String? cleanWord = validateInput(word);
    if (cleanWord == null) return "Kelime geçersiz";
    final cleanTaboos = taboos
        .map((e) => validateInput(e) ?? "")
        .where((e) => e.isNotEmpty)
        .toList();
    if (cleanTaboos.any((t) => containsProhibitedWords(t))) {
      return "Uygunsuz tabu kelimesi tespit edildi";
    }
    if (cleanTaboos.length < 5) {
      return "5 tabu kelime girmelisin";
    }
    if (cleanTaboos.toSet().length < 5) {
      return "Tabu kelimeleri benzersiz olmalı";
    }
    final id = _stableId(cleanWord, "Özel");
    if (_idsForCategory("Özel").contains(id)) {
      return "Bu kelime zaten var";
    }
    final formattedTaboos = cleanTaboos
        .take(5)
        .map(_turkishCapitalizeFirst)
        .toList(growable: false);
    cleanWord = _turkishUpper(cleanWord);
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
    if (newWord.trim().isEmpty) return "Kelime boş olamaz";
    if (containsProhibitedWords(newWord)) {
      return "Uygunsuz kelime tespit edildi";
    }
    if (newWord.trim().length > 16) {
      return "Kelime en fazla 16 karakter olabilir";
    }
    String? cleanWord = validateInput(newWord);
    if (cleanWord == null) return "Kelime geçersiz";

    final cleanTaboos = taboos
        .map((e) => validateInput(e) ?? "")
        .where((e) => e.isNotEmpty)
        .toList();
    if (cleanTaboos.length < 5) return "5 tabu kelime girmelisin";
    if (cleanTaboos.any((t) => containsProhibitedWords(t))) {
      return "Uygunsuz tabu kelimesi tespit edildi";
    }
    if (cleanTaboos.toSet().length < 5) {
      return "Tabu kelimeleri benzersiz olmalı";
    }

    final newId = _stableId(cleanWord, "Özel");
    if (newId != original.id && _idsForCategory("Özel").contains(newId)) {
      return "Bu kelime zaten var";
    }

    final formattedTaboos = cleanTaboos
        .take(5)
        .map(_turkishCapitalizeFirst)
        .toList(growable: false);
    cleanWord = _turkishUpper(cleanWord);

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
    if (name.trim().isEmpty) return "İsim boş olamaz";
    if (containsProhibitedWords(name)) return "Uygunsuz isim tespit edildi";
    if (name.trim().length > 20) return "İsim en fazla 20 karakter olabilir";
    String? valid = validateInput(name);
    if (valid == null) return "İsim geçersiz";
    if (isTeamA && valid == teamBName) return "Diğer takımla aynı isim olamaz";
    if (!isTeamA && valid == teamAName) return "Diğer takımla aynı isim olamaz";

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
    if (name.trim().isEmpty) return "İsim boş olamaz";
    if (containsProhibitedWords(name)) return "Uygunsuz isim tespit edildi";
    if (name.trim().length > 16) return "İsim en fazla 16 karakter olabilir";

    String? valid = validateInput(name);
    if (valid == null) return "İsim geçersiz";
    if (teamA.contains(valid) || teamB.contains(valid)) {
      return "Bu oyuncu zaten ekli";
    }
    if (toTeamA && teamA.length >= 6) {
      return "Bir takımda en fazla 6 oyuncu olabilir";
    }
    if (!toTeamA && teamB.length >= 6) {
      return "Bir takımda en fazla 6 oyuncu olabilir";
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

  String randomPlayerName() {
    final options = [
      "Şeyci",
      "Buzzer Mağduru",
      "Dil Sürçmesi",
      "Yasak Avcısı",
      "Anlatamayan",
      "Son Anda Söyledi",
      "WordMaster",
      "TabuBoss",
      "QuickMind",
      "NoBuzzer",
      "FastTalker",
      "SilentBrain",
      "Kaptan",
      "Anlatıcı",
      "Tahminci",
      "Joker",
      "Sessiz Oyuncu",
      "Stratejist",
      "Yasaklı Kahraman",
      "Kelime Büyücüsü",
      "Dil Ninja",
      "Buzzer Lordu",
      "Anlam Ustası",
    ];
    final existing = {
      ...teamA.map((e) => e.toUpperCase()),
      ...teamB.map((e) => e.toUpperCase()),
    };
    final available = options.where((n) => !existing.contains(n)).toList();
    final list = available.isNotEmpty ? available : options;
    return list[Random().nextInt(list.length)];
  }

  String randomTeamName(bool forTeamA) {
    final List<String> pool = [
      "Yasaklılar",
      "Dili Sürçenler",
      "Tabu Canavarları",
      "Kelime Avcıları",
      "Buzzer Kaçakları",
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
    final otherName = (forTeamA ? teamBName : teamAName).toUpperCase();
    for (final name in pool) {
      if (name.toUpperCase() != otherName) {
        return name;
      }
    }
    return "TEAM ${Random().nextInt(90) + 10}";
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

  void endRound() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    _cooldownActive = false;
    timeLeft = 0;
    if (vibrationEnabled) HapticFeedback.heavyImpact();
    _playSfx("taboo");

    if (currentCard != null) {
      roundHistory.add(
        RoundEvent(card: currentCard!, status: CardStatus.pass, timedOut: true),
      );
      currentCard = null;
    }

    if (_targetScore != -1) {
      if (teamAScore >= _targetScore && teamAScore > teamBScore) {
        gameWinner = teamAName;
      } else if (teamBScore >= _targetScore && teamBScore > teamAScore) {
        gameWinner = teamBName;
      }
    }

    if (!_allowRepeats && _activeDeck.isEmpty && currentCard == null) {
      endedByCards = true;
      endMessage = "Tüm kartlar kullanıldı";
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
    _playSfx(
      "correct",
      restartIfPlaying: true,
      bypassThrottle: true,
    );
    _logEvent(CardStatus.correct);
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
    _playSfx(
      "taboo",
      restartIfPlaying: true,
      bypassThrottle: true,
    );
    _logEvent(CardStatus.taboo);
    nextCard();
  }

  void actionPass() {
    if (!_beginCooldown()) return;
    if (currentPasses > 0) {
      currentPasses--;
      if (vibrationEnabled) HapticFeedback.mediumImpact();
      _playSfx(
        "pass",
        restartIfPlaying: true,
        bypassThrottle: true,
      );
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

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
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
