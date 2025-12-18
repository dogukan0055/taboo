import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'models.dart';

class GameProvider extends ChangeNotifier {
  // --- Global Settings ---
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;
  bool tutorialTipShown = false;

  // --- Profanity Filter List (Basic) ---
  final List<String> _badWords = [
    "GÖT",
    "SİK",
    "AM",
    "OROSPU",
    "İBNE",
    "PİÇ",
    "YARRAK",
    "SAÇMA",
    "SALAK",
    "GERİZEKALI",
    "YAVŞAK",
    "AMK",
    "SİKTİR",
    "OÇ",
    "MAL",
  ];

  // --- Category & Word Data ---
  List<String> availableCategories = [
    "Genel",
    "Spor",
    "Bilim",
    "Yemek",
    "Sanat",
    "Teknoloji",
    "Doga",
    "Tarih",
    "Ozel",
  ];
  Set<String> selectedCategories = {
    "Genel",
    "Spor",
    "Bilim",
    "Yemek",
    "Sanat",
    "Teknoloji",
    "Doga",
    "Tarih",
  };
  Set<String> disabledCardIds = {};
  List<WordCard> customCards = [];

  // --- Game Config ---
  int _roundTime = 60;
  int _targetScore = 20;
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
  Timer? _timer;
  WordCard? currentCard;

  // Cooldown Tracker
  bool _cooldownActive = false;
  Timer? _cooldownTimer;

  List<RoundEvent> roundHistory = [];
  List<WordCard> _activeDeck = [];

  GameProvider() {
    _musicPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    _sfxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
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
    String clean = input.trim().toUpperCase();
    if (clean.isEmpty || containsProhibitedWords(clean)) return null;
    return clean;
  }

  bool containsProhibitedWords(String input) {
    String upper = input.toUpperCase();
    for (var bad in _badWords) {
      if (upper.contains(bad)) return true;
    }
    return false;
  }

  // --- ACTIONS ---
  void toggleSound(bool val) {
    soundEnabled = val;
    notifyListeners();
  }

  void toggleMusic(bool val) {
    musicEnabled = val;
    ensureAudioInitialized();
    _updateMusicState();
    notifyListeners();
  }

  void toggleVibration(bool val) {
    vibrationEnabled = val;
    notifyListeners();
  }

  void toggleRepeats(bool val) {
    _allowRepeats = val;
    notifyListeners();
  }

  void toggleCategory(String cat) {
    if (selectedCategories.contains(cat)) {
      if (selectedCategories.length > 1) selectedCategories.remove(cat);
    } else {
      selectedCategories.add(cat);
    }
    notifyListeners();
  }

  void toggleWordStatus(String cardId) {
    if (disabledCardIds.contains(cardId)) {
      disabledCardIds.remove(cardId);
    } else {
      disabledCardIds.add(cardId);
    }
    notifyListeners();
  }

  void addCustomCard(String word, List<String> taboos) {
    String? cleanWord = validateInput(word);
    if (cleanWord != null) {
      // Clean taboos
      List<String> cleanTaboos = taboos
          .map((e) => validateInput(e) ?? "")
          .where((e) => e.isNotEmpty)
          .toList();
      customCards.add(
        WordCard(
          word: cleanWord,
          tabooWords: cleanTaboos,
          category: "Ozel",
          isCustom: true,
        ),
      );
      notifyListeners();
    }
  }

  void updateSettings({int? time, int? score}) {
    if (time != null) _roundTime = time;
    if (score != null) _targetScore = score;
    notifyListeners();
  }

  String? setTeamName(bool isTeamA, String name) {
    if (name.trim().isEmpty) return "İsim boş olamaz";
    if (containsProhibitedWords(name)) return "Uygunsuz isim tespit edildi";
    String? valid = validateInput(name);
    if (valid == null) return "İsim geçersiz";
    if (isTeamA && valid == teamBName) return "Diğer takımla aynı isim olamaz";
    if (!isTeamA && valid == teamAName) return "Diğer takımla aynı isim olamaz";

    if (isTeamA) {
      teamAName = valid;
    } else {
      teamBName = valid;
    }
    notifyListeners();
    return null;
  }

  String? addPlayer(String name, bool toTeamA) {
    if (name.trim().isEmpty) return "İsim boş olamaz";
    if (containsProhibitedWords(name)) return "Uygunsuz isim tespit edildi";

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
    notifyListeners();
    return null;
  }

  void removePlayer(String name, bool fromTeamA) {
    if (fromTeamA) {
      teamA.remove(name);
    } else {
      teamB.remove(name);
    }
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
    nextCard();
    ensureAudioInitialized();
    _updateMusicState();
    _playSfx("start");
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        timeLeft--;
        notifyListeners();
      } else {
        endRound();
      }
    });
  }

  void endRound() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    _cooldownActive = false;
    timeLeft = 0;
    if (vibrationEnabled) HapticFeedback.heavyImpact();
    _playSfx("taboo");

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
    if (vibrationEnabled) HapticFeedback.lightImpact();
    _playSfx("correct");
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
    _playSfx("taboo");
    _logEvent(CardStatus.taboo);
    nextCard();
  }

  void actionPass() {
    if (!_beginCooldown()) return;
    if (currentPasses > 0) {
      currentPasses--;
      if (vibrationEnabled) HapticFeedback.selectionClick();
      _playSfx("pass");
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
    notifyListeners();
  }

  Future<void> ensureAudioInitialized() async {
    if (_audioReady) return;
    _audioReady = true;
    await _musicPlayer.setSource(AssetSource("audio/music_loop.wav"));
    await _musicPlayer.setVolume(musicEnabled ? 0.3 : 0);
    if (musicEnabled) {
      await _musicPlayer.resume();
    }
  }

  Future<void> _updateMusicState() async {
    if (!_audioReady) return;
    if (musicEnabled) {
      await _musicPlayer.setVolume(0.35);
      if (_musicPlayer.state != PlayerState.playing) {
        await _musicPlayer.resume();
      }
    } else {
      await _musicPlayer.pause();
    }
  }

  Future<void> _playSfx(String name) async {
    if (!soundEnabled || !_audioReady) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource("audio/$name.wav"));
  }

  Future<void> playClick() async {
    await ensureAudioInitialized();
    await _playSfx("click");
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }
}
