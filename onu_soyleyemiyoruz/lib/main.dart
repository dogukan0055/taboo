import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'game_provider.dart';
import 'models.dart';
import 'add_custom_card_screen.dart';
import 'onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
  );
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        final pageTransitions = game.reducedMotion
            ? const PageTransitionsTheme(
                builders: {
                  TargetPlatform.iOS: _NoTransitionsBuilder(),
                  TargetPlatform.android: _NoTransitionsBuilder(),
                  TargetPlatform.macOS: _NoTransitionsBuilder(),
                  TargetPlatform.windows: _NoTransitionsBuilder(),
                  TargetPlatform.linux: _NoTransitionsBuilder(),
                },
              )
            : const PageTransitionsTheme();

        final theme = ThemeData(
          fontFamily: 'Roboto',
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.transparent,
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            insetPadding: const EdgeInsets.all(16),
            backgroundColor: Colors.black.withValues(alpha: .9),
            contentTextStyle: const TextStyle(color: Colors.white),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: game.highContrast ? Brightness.dark : Brightness.light,
          ),
          pageTransitionsTheme: pageTransitions,
        );

        Widget home;
        if (!game.hydrated) {
          home = const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (!game.onboardingSeen) {
          home = OnboardingScreen(
            onFinished: (ctx) => Navigator.of(ctx).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainMenuScreen()),
            ),
          );
        } else {
          home = const MainMenuScreen();
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Onu Söyleyemiyoruz',
          theme: theme,
          home: home,
        );
      },
    );
  }
}

class GameBackground extends StatelessWidget {
  final Widget child;
  const GameBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final highContrast = Provider.of<GameProvider>(context).highContrast;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: highContrast
              ? [
                  const Color(0xFF0A0318),
                  const Color(0xFF250045),
                  const Color(0xFF3C0C6A),
                ]
              : [
                  const Color(0xFF2E0249),
                  const Color(0xFF570A57),
                  const Color(0xFFA91079),
                ],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

// --- 1. MAIN MENU ---
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: GameBackground(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Image.asset(
                  "assets/image/ingame_logo.png",
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "ONU\nSÖYLEYEMİYORUZ",
                textAlign: TextAlign.center,
                maxLines: 2,
                softWrap: false,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const Spacer(),
              _MenuButton(
                label: "OYNA",
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SetupHubScreen()),
                ),
              ),
              const SizedBox(height: 15),
              _MenuButton(
                label: "AYARLAR",
                color: Colors.teal,
                onTap: () {
                  final reduceMotion = Provider.of<GameProvider>(
                    context,
                    listen: false,
                  ).reducedMotion;
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    enableDrag: !reduceMotion,
                    builder: (_) => const SettingsSheet(),
                  );
                },
              ),
              const SizedBox(height: 15),
              _MenuButton(
                label: "NASIL OYNANIR?",
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TutorialScreen()),
                ),
              ),
              const SizedBox(height: 15),
              _MenuButton(
                label: "ÇIKIŞ",
                color: Colors.red,
                onTap: () => SystemNavigator.pop(),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;
  final IconData? trailingIcon;
  const _MenuButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
    this.trailingIcon,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      onPressed: () async {
        await Provider.of<GameProvider>(context, listen: false).playClick();
        if (!context.mounted) return;
        onTap();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 10),
            Icon(trailingIcon, color: Colors.white),
          ],
        ],
      ),
    );
  }
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

// --- 2. SETUP HUB ---
class SetupHubScreen extends StatefulWidget {
  const SetupHubScreen({super.key});

  @override
  State<SetupHubScreen> createState() => _SetupHubScreenState();
}

class _SetupHubScreenState extends State<SetupHubScreen>
    with SingleTickerProviderStateMixin {
  bool _teamsExpanded = false;
  late final ScrollController _setupScrollController;

  @override
  void initState() {
    super.initState();
    _setupScrollController = ScrollController();
  }

  @override
  void dispose() {
    _setupScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final messenger = ScaffoldMessenger.of(context);
    final reduceMotion = game.reducedMotion;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Oyun Ayarları"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GameBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompactHeight = constraints.maxHeight < 720;
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 24.0;

            return Scrollbar(
              controller: _setupScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _setupScrollController,
                primary: false,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  horizontalPadding,
                  horizontalPadding,
                  horizontalPadding + MediaQuery.of(context).padding.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: isCompactHeight ? 8 : 16),
                      _MenuButton(
                        label: "TAKIM YÖNETİMİ",
                        color: Colors.purple,
                        icon: Icons.groups,
                        trailingIcon: _teamsExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        onTap: () =>
                            setState(() => _teamsExpanded = !_teamsExpanded),
                      ),
                      if (reduceMotion)
                        (_teamsExpanded
                            ? Container(
                                margin: const EdgeInsets.only(
                                  top: 14,
                                  bottom: 6,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const TeamManagerPanel(
                                  showCloseButton: false,
                                ),
                              )
                            : const SizedBox.shrink())
                      else
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: _teamsExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox.shrink(),
                          secondChild: Container(
                            margin: const EdgeInsets.only(top: 14, bottom: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const TeamManagerPanel(
                              showCloseButton: false,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      _MenuButton(
                        label: "KATEGORİLERİ YÖNET",
                        color: Colors.orange,
                        icon: Icons.category,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryManagementScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildUniqueSelector(
                              "Süre (saniye)",
                              [30, 45, 60, 75, 90],
                              game.roundTime,
                              (val) {
                                if (val == game.roundTime) return;
                                game.updateSettings(time: val);
                                messenger.removeCurrentSnackBar();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Tur süresi $val sn olarak kaydedildi",
                                    ),
                                  ),
                                );
                              },
                              labelBuilder: (val) => "$val",
                              reduceMotion: reduceMotion,
                            ),
                            const Divider(color: Colors.white24),
                            _buildUniqueSelector(
                              "Hedef Puan",
                              [20, 30, 50, 75, -1],
                              game.targetScore,
                              (val) {
                                if (val == game.targetScore) return;
                                game.updateSettings(score: val);
                                final label = val == -1
                                    ? "Hedef yok. Oyun istenilen sürede kazanılır!"
                                    : "$val puana ulaşan kazanır!";
                                messenger.removeCurrentSnackBar();
                                messenger.showSnackBar(
                                  SnackBar(content: Text(label)),
                                );
                              },
                              labelBuilder: (val) => val == -1 ? "-" : "$val",
                              reduceMotion: reduceMotion,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: [
                          _InfoChip(
                            icon: Icons.timer,
                            label: "Tur süresi: ${game.roundTime} saniye",
                          ),
                          _InfoChip(
                            icon: Icons.flag,
                            label: game.targetScore == -1
                                ? "Hedef yok. Oyun istenilen sürede kazanılır!"
                                : "Oyunu kazanmak için hedef: ${game.targetScore} puan",
                          ),
                        ],
                      ),

                      SizedBox(height: isCompactHeight ? 18 : 28),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (game.teamA.length < 2 || game.teamB.length < 2) {
                            String msg = "";
                            if (game.teamA.length < 2) {
                              msg =
                                  "${game.teamAName} takımında eksik oyuncu var.";
                            } else if (game.teamB.length < 2) {
                              msg =
                                  "${game.teamBName} takımında eksik oyuncu var.";
                            }
                            _showSnack(messenger, msg);
                            return;
                          }
                          if (game.teamA.length != game.teamB.length) {
                            _showSnack(
                              messenger,
                              "Takımlardaki oyuncu sayıları eşit olmalı.",
                            );
                            return;
                          }
                          game.startGame();
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const DiceRollDialog(),
                          );
                        },
                        child: const Text(
                          "ZAR AT & OYNA",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUniqueSelector(
    String label,
    List<int> options,
    int currentValue,
    Function(int) onSelect, {
    String Function(int)? labelBuilder,
    bool reduceMotion = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: options.map((opt) {
            bool isSelected = opt == currentValue;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amber : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.amber : Colors.white54,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    labelBuilder != null ? labelBuilder(opt) : "$opt",
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? textColor;
  final Color? fillColor;
  const _InfoChip({
    required this.icon,
    required this.label,
    this.textColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = textColor ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: fillColor ?? Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.amber),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      ),
    );
  }
}

class TeamManagerPanel extends StatelessWidget {
  final bool showCloseButton;
  final VoidCallback? onClose;
  const TeamManagerPanel({
    super.key,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final messenger = ScaffoldMessenger.of(context);
    return Column(
      children: [
        _responsiveCards(context, game, messenger),
        if (showCloseButton)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose ?? () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.all(14),
                ),
                child: const Text(
                  "KAYDET VE DÖN",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _responsiveCards(
    BuildContext context,
    GameProvider game,
    ScaffoldMessengerState messenger,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 620;
        final first = _buildTeamCard(context, game, true, messenger);
        final second = _buildTeamCard(context, game, false, messenger);
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: VerticalDivider(
                  color: Colors.white24,
                  thickness: 1,
                  width: 1,
                ),
              ),
              Expanded(child: second),
            ],
          );
        }
        return Column(
          children: [
            first,
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Colors.white24, thickness: 1),
            ),
            second,
          ],
        );
      },
    );
  }

  Widget _buildTeamCard(
    BuildContext context,
    GameProvider game,
    bool isTeamA,
    ScaffoldMessengerState messenger,
  ) {
    final Color badgeColor = isTeamA ? Colors.blueAccent : Colors.redAccent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isTeamA ? game.teamAName : game.teamBName,
                  style: TextStyle(
                    color: isTeamA ? Colors.blue : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70, size: 28),
                onPressed: () => _showEditTeamName(context, game, isTeamA),
              ),
            ],
          ),
          if (isTeamA ? game.teamA.isEmpty : game.teamB.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Oyuncu yok",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ...(isTeamA ? game.teamA : game.teamB).map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.person, size: 24, color: badgeColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      game.removePlayer(p, isTeamA);
                      final upperName = _turkishUpper(p);
                      _showSnack(
                        messenger,
                        "$upperName adlı oyuncu ${isTeamA ? game.teamAName : game.teamBName} takımından çıkarıldı",
                      );
                    },
                    child: const SizedBox(
                      width: 52,
                      height: 52,
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _showAddPlayer(context, game, isTeamA),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, color: Colors.greenAccent, size: 24),
                SizedBox(width: 8),
                Text("Ekle", style: TextStyle(color: Colors.greenAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTeamName(
    BuildContext context,
    GameProvider game,
    bool isTeamA,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    TextEditingController c = TextEditingController(
      text: isTeamA ? game.teamAName : game.teamBName,
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Takım İsmi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c,
              maxLength: 16,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp('[A-Za-zÇçĞğİıÖöŞşÜü ]'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  final suggestion = game.randomTeamName(isTeamA);
                  c.text = suggestion;
                  c.selection = TextSelection.collapsed(offset: c.text.length);
                },
                icon: const Icon(Icons.casino, size: 22),
                label: const Text("Öner"),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              game.playClick();
              Navigator.pop(dialogContext);
            },
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              game.playClick();
              final error = game.setTeamName(isTeamA, c.text);
              if (error != null) {
                _showSnack(messenger, error);
                return;
              }
              final newName = isTeamA ? game.teamAName : game.teamBName;
              Navigator.pop(dialogContext);
              _showSnack(messenger, "$newName kaydedildi");
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  void _showAddPlayer(BuildContext context, GameProvider game, bool isTeamA) {
    final messenger = ScaffoldMessenger.of(context);
    TextEditingController c = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          "${isTeamA ? game.teamAName : game.teamBName} takımına oyuncu ekle",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c,
              maxLength: 16,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp('[A-Za-zÇçĞğİıÖöŞşÜü ]'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  final suggestion = game.randomPlayerName();
                  c.text = suggestion;
                  c.selection = TextSelection.collapsed(offset: c.text.length);
                },
                icon: const Icon(Icons.casino, size: 22),
                label: const Text("Öner"),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              game.playClick();
              Navigator.pop(dialogContext);
            },
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              game.playClick();
              final err = game.addPlayer(c.text, isTeamA);
              if (err != null) {
                _showSnack(messenger, err);
                return;
              }
              Navigator.pop(dialogContext);
              final upperName = _turkishUpper(c.text);
              _showSnack(
                messenger,
                "$upperName adlı oyuncu ${isTeamA ? game.teamAName : game.teamBName} takımına eklendi",
              );
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }
}

// --- 2.1 TEAM MANAGEMENT ---
class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  late final ScrollController _teamScrollController;

  @override
  void initState() {
    super.initState();
    _teamScrollController = ScrollController();
  }

  @override
  void dispose() {
    _teamScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Takım Yönetimi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: GameBackground(
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _teamScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _teamScrollController,
                  primary: false,
                  padding: const EdgeInsets.all(16),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildTeamCard(context, game, true)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: VerticalDivider(
                            color: Colors.white24,
                            thickness: 1,
                            width: 1,
                          ),
                        ),
                        Expanded(child: _buildTeamCard(context, game, false)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    "KAYDET VE DÖN",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, GameProvider game, bool isTeamA) {
    final Color badgeColor = isTeamA ? Colors.blueAccent : Colors.redAccent;
    final messenger = ScaffoldMessenger.of(context);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isTeamA ? game.teamAName : game.teamBName,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  final suggestion = game.randomTeamName(isTeamA);
                  final error = game.setTeamName(isTeamA, suggestion);
                  if (error != null) {
                    _showSnack(messenger, error);
                  } else {
                    _showSnack(messenger, "$suggestion önerildi");
                  }
                },
                icon: const Icon(Icons.casino, color: Colors.white70, size: 26),
                label: const Text(
                  "Öner",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70, size: 28),
                onPressed: () => _showEditTeamName(context, game, isTeamA),
              ),
            ],
          ),
          if (isTeamA ? game.teamA.isEmpty : game.teamB.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Oyuncu yok",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ...(isTeamA ? game.teamA : game.teamB).map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.person, size: 24, color: badgeColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      game.removePlayer(p, isTeamA);
                      final upperName = _turkishUpper(p);
                      _showSnack(
                        messenger,
                        "$upperName adlı oyuncu ${isTeamA ? game.teamAName : game.teamBName} takımından çıkarıldı",
                      );
                    },
                    child: const SizedBox(
                      width: 52,
                      height: 52,
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _showAddPlayer(context, game, isTeamA),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, color: Colors.greenAccent, size: 24),
                SizedBox(width: 8),
                Text("Ekle", style: TextStyle(color: Colors.greenAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTeamName(
    BuildContext context,
    GameProvider game,
    bool isTeamA,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    TextEditingController c = TextEditingController(
      text: isTeamA ? game.teamAName : game.teamBName,
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Takım İsmi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c,
              maxLength: 16,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z ]')),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  final suggestion = game.randomTeamName(isTeamA);
                  c.text = suggestion;
                  c.selection = TextSelection.collapsed(offset: c.text.length);
                },
                icon: const Icon(Icons.casino, size: 22),
                label: const Text("Öner"),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final error = game.setTeamName(isTeamA, c.text);
              if (error != null) {
                _showSnack(messenger, error);
                return;
              }
              final newName = isTeamA ? game.teamAName : game.teamBName;
              Navigator.pop(dialogContext);
              _showSnack(messenger, "$newName kaydedildi");
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  void _showAddPlayer(BuildContext context, GameProvider game, bool isTeamA) {
    final messenger = ScaffoldMessenger.of(context);
    TextEditingController c = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Oyuncu Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c,
              maxLength: 12,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z ]')),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  final suggestion = game.randomPlayerName();
                  c.text = suggestion;
                  c.selection = TextSelection.collapsed(offset: c.text.length);
                },
                icon: const Icon(Icons.casino, size: 22),
                label: const Text("Öner"),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (c.text.trim().isEmpty) {
                _showSnack(messenger, "İsim boş olamaz");
                return;
              }
              final error = game.addPlayer(c.text, isTeamA);
              if (error != null) {
                _showSnack(messenger, error);
                return;
              }
              final addedName = game.validateInput(c.text) ?? c.text.trim();
              Navigator.pop(dialogContext);
              final upperName = _turkishUpper(addedName);
              _showSnack(
                messenger,
                "$upperName adlı oyuncu ${isTeamA ? game.teamAName : game.teamBName} takımına eklendi",
              );
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }
}

void _showSnack(ScaffoldMessengerState messenger, String message) {
  messenger.removeCurrentSnackBar();
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

void _showCardPreview(BuildContext context, WordCard card) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                card.category.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Text(
                card.word,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                children: card.tabooWords
                    .map(
                      (t) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          t,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
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

// --- 2.2 CATEGORY MANAGEMENT (Switches) ---
class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  late final ScrollController _categoryScrollController;
  late Set<String> _selectedCategories;
  late Set<String> _disabledIds;

  @override
  void initState() {
    super.initState();
    _categoryScrollController = ScrollController();
    final game = Provider.of<GameProvider>(context, listen: false);
    _selectedCategories = Set.of(game.selectedCategories);
    _disabledIds = Set.of(game.disabledCardIds);
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final messenger = ScaffoldMessenger.of(context);
    var wordsMap = game.wordsByCategory;
    final Map<String, IconData> categoryIcons = {
      "Genel": Icons.public,
      "Spor": Icons.sports,
      "Bilim": Icons.science,
      "Doğa": Icons.nature_people,
      "Yemek": Icons.restaurant,
      "Sanat": Icons.brush,
      "Teknoloji": Icons.memory,
      "Tarih": Icons.history_edu_outlined,
      "Özel": Icons.star,
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Kategorileri Yönet"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GameBackground(
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _categoryScrollController,
                thumbVisibility: true,
                child: ListView(
                  controller: _categoryScrollController,
                  padding: const EdgeInsets.all(16),
                  children: game.availableCategories.map((cat) {
                    List<WordCard> words = wordsMap[cat] ?? [];
                    bool isCatSelected = _selectedCategories.contains(cat);
                    final int activeCount = words
                        .where((w) => !_disabledIds.contains(w.id))
                        .length;
                    final bool isPartial =
                        !isCatSelected &&
                        activeCount > 0 &&
                        activeCount < words.length;

                    final Color titleColor = isCatSelected
                        ? Colors.amber
                        : isPartial
                        ? Colors.lightBlueAccent
                        : Colors.white;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Theme(
                        data: ThemeData.dark().copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: isCatSelected,
                                activeThumbColor: Colors.green,
                                onChanged: (_) => setState(() {
                                  game.playClick();
                                  if (isCatSelected) {
                                    _selectedCategories.remove(cat);
                                    for (final w in words) {
                                      _disabledIds.add(w.id);
                                    }
                                  } else {
                                    _selectedCategories.add(cat);
                                    for (final w in words) {
                                      _disabledIds.remove(w.id);
                                    }
                                  }
                                }),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                categoryIcons[cat] ?? Icons.category,
                                color: isCatSelected
                                    ? Colors.amber
                                    : isPartial
                                    ? Colors.lightBlueAccent
                                    : Colors.white54,
                              ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Text(
                                cat,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            "$activeCount / ${words.length} Kelime",
                            style: const TextStyle(color: Colors.white54),
                          ),
                          children: [
                            Container(
                              color: Colors.black26,
                              child: Column(
                                children: words.map((w) {
                                  bool isDisabled = _disabledIds.contains(w.id);
                                  final isCustom = w.isCustom;
                                  return ListTile(
                                    title: Text(
                                      w.word,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    leading: Icon(
                                      categoryIcons[cat] ?? Icons.style,
                                      color: Colors.white54,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_red_eye,
                                            color: Colors.white70,
                                          ),
                                          onPressed: () async {
                                            await game.playClick();
                                            if (!context.mounted) return;
                                            _showCardPreview(context, w);
                                          },
                                        ),
                                        if (isCustom)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.white70,
                                            ),
                                            onPressed: () async {
                                              await game.playClick();
                                              if (!context.mounted) return;
                                              final updated =
                                                  await Navigator.push<String>(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AddCustomCardScreen(
                                                            existingCard: w,
                                                          ),
                                                    ),
                                                  );
                                              if (!context.mounted) return;
                                              if (updated != null) {
                                                setState(() {});
                                                _showSnack(
                                                  messenger,
                                                  "$updated güncellendi",
                                                );
                                              }
                                            },
                                          ),
                                        if (isCustom)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_forever,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () {
                                              game.playClick();
                                              game.removeCustomCard(w.id);
                                              setState(() {
                                                _disabledIds.remove(w.id);
                                              });
                                              _showSnack(
                                                messenger,
                                                "${w.word} silindi",
                                              );
                                            },
                                          ),
                                        Switch(
                                          value: !isDisabled,
                                          activeThumbColor: Colors.amber,
                                          onChanged: (val) => setState(() {
                                            game.playClick();
                                            if (val) {
                                              _disabledIds.remove(w.id);
                                            } else {
                                              _disabledIds.add(w.id);
                                            }
                                            final allEnabled = words.every(
                                              (cw) =>
                                                  !_disabledIds.contains(cw.id),
                                            );
                                            if (allEnabled) {
                                              _selectedCategories.add(cat);
                                            } else {
                                              final allDisabled = words.every(
                                                (cw) => _disabledIds.contains(
                                                  cw.id,
                                                ),
                                              );
                                              if (allDisabled &&
                                                  _selectedCategories.contains(
                                                    cat,
                                                  )) {
                                                _selectedCategories.remove(cat);
                                              }
                                            }
                                          }),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            if (cat == "Özel")
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  12,
                                  16,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await game.playClick();
                                    if (!context.mounted) return;
                                    final added = await Navigator.push<String>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AddCustomCardScreen(),
                                      ),
                                    );
                                    if (!context.mounted) return;
                                    if (added != null) {
                                      _showSnack(
                                        messenger,
                                        "$added ÖZEL kategorisine eklendi",
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text("Kart Ekle"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await game.playClick();
                    if (!context.mounted) return;
                    game.applyCategoryChanges(
                      _selectedCategories,
                      _disabledIds,
                    );
                    _showSnack(messenger, "Kategoriler güncellendi");
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    "KAYDET VE DÖN",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _ctrl.addListener(() {
      if (_ctrl.isAnimating) {
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
      Future.delayed(const Duration(seconds: 2), () {
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

// --- 3. ROUND START ---
class RoundStartScreen extends StatelessWidget {
  const RoundStartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    bool isA = game.isTeamATurn;
    final double maxWidth = MediaQuery.of(context).size.width * 0.9;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmExitToMenu(context);
      },
      child: Scaffold(
        backgroundColor: isA ? Colors.blue[900] : Colors.red[900],
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _confirmExitToMenu(context, force: true),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "SIRADAKİ",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 2,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: maxWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "TAKIM",
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: maxWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isA ? game.teamAName : game.teamBName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.amber,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: maxWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "ANLATICI",
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: maxWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      game.currentNarrator,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.amber,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Explicit Team Score Display
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                game.teamAName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${game.teamAScore}",
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "-",
                        style: TextStyle(fontSize: 26, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                game.teamBName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${game.teamBScore}",
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                _InfoChip(
                  icon: Icons.layers,
                  label: "${game.remainingCards} kalan kart",
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (game.allCardsUsed) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameOverScreen(),
                        ),
                      );
                      return;
                    }
                    game.startRound();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const GamePlayScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    "BAŞLA",
                    style: TextStyle(fontSize: 24, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 4. GAMEPLAY SCREEN ---
class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key});
  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen>
    with SingleTickerProviderStateMixin {
  final List<Widget> _floatingTexts = [];
  late AnimationController _blink;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.35,
      upperBound: 1,
    )..value = 1;
  }

  void _showFloatingText(String text, Color color) {
    if (_reduceMotion) return;
    final UniqueKey key = UniqueKey();
    setState(() {
      _floatingTexts.add(
        _FloatingTextItem(
          key: key,
          text: text,
          color: color,
          onComplete: () {
            setState(() {
              _floatingTexts.removeWhere((element) => element.key == key);
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    _reduceMotion = game.reducedMotion;
    _updateBlink(game.timeLeft);
    if (!game.isPaused && !game.abortedToMenu && game.timeLeft == 0) {
      final navigator = Navigator.of(context);
      Future.microtask(() {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const RoundReportScreen()),
        );
      });
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: const Text("Oyundan çıkılsın mı?"),
            content: const Text("Oyunu bırakmak üzeresiniz. Emin misiniz?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text("Vazgeç"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  game.abortCurrentRound();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text("Oyundan Çık"),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            GameBackground(
              child: Column(
                children: [
                  _buildScoreHeader(game),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AnimatedSwitcher(
                        duration: _reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 300),
                        child: _buildCardContent(game.currentCard),
                      ),
                    ),
                  ),
                  _buildFeedbackToggles(game),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        BouncingButton(
                          icon: Icons.close,
                          color: Colors.red,
                          label: "TABU",
                          disabled: game.isCoolingDown,
                          onTap: () {
                            _showFloatingText("TABU!", Colors.redAccent);
                            game.actionTaboo();
                          },
                        ),
                        game.currentPasses > 0
                            ? BouncingButton(
                                icon: Icons.skip_next,
                                color: Colors.blue,
                                label: "PAS",
                                badgeText: "${game.currentPasses}",
                                disabled: game.isCoolingDown,
                                onTap: () {
                                  _showFloatingText("PAS", Colors.blueAccent);
                                  game.actionPass();
                                },
                              )
                            : Opacity(
                                opacity: 0.5,
                                child: BouncingButton(
                                  icon: Icons.skip_next,
                                  color: Colors.grey,
                                  label: "PAS",
                                  badgeText: "0",
                                  disabled: true,
                                  onTap: () {},
                                ),
                              ),
                        BouncingButton(
                          icon: Icons.check,
                          color: Colors.green,
                          label: "DOĞRU",
                          disabled: game.isCoolingDown,
                          onTap: () {
                            _showFloatingText("DOĞRU!", Colors.greenAccent);
                            game.actionCorrect();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ..._floatingTexts,
          ],
        ),
      ),
    );
  }

  void _updateBlink(int timeLeft) {
    if (_reduceMotion) return;
    if (timeLeft > 0 && timeLeft <= 10) {
      final ms = (120 + timeLeft * 40).clamp(120, 600);
      if (_blink.duration?.inMilliseconds != ms) {
        _blink.duration = Duration(milliseconds: ms);
      }
      if (!_blink.isAnimating) {
        _blink.repeat(reverse: true);
      }
    } else {
      if (_blink.isAnimating) _blink.stop();
      _blink.value = 1;
    }
  }

  void _onPausePressed(GameProvider game) {
    game.pauseGame();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF421B7A), Color(0xFF2E0F57)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 18),
              const Icon(
                Icons.pause_circle_filled,
                color: Colors.amber,
                size: 46,
              ),
              const SizedBox(height: 8),
              const Text(
                "DURDURULDU",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Oyunu durdurdun. Devam edebilir veya ana menüye dönebilirsin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.white24,
                indent: 16,
                endIndent: 16,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          game.playClick();
                          Navigator.pop(dialogCtx);
                          game.resumeGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "DEVAM ET",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          game.playClick();
                          Navigator.pop(dialogCtx);
                          game.abortCurrentRound();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainMenuScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.4,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "ANA MENÜYE DÖN",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ).then((_) {
      if (game.isPaused) {
        game.resumeGame();
      }
    });
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  Widget _buildFeedbackToggles(GameProvider game) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 6),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          _buildFeedbackToggle(
            icon: game.soundEnabled ? Icons.volume_up : Icons.volume_off,
            label: game.soundEnabled ? "Ses Açık" : "Ses Kapalı",
            isActive: game.soundEnabled,
            onTap: () async {
              if (!game.soundEnabled) {
                await game.playClick();
              }
              game.toggleSound(!game.soundEnabled);
            },
          ),
          _buildFeedbackToggle(
            icon: game.vibrationEnabled ? Icons.vibration : Icons.phone_android,
            label: game.vibrationEnabled ? "Titreşim Açık" : "Titreşim Kapalı",
            isActive: game.vibrationEnabled,
            onTap: () => game.toggleVibration(!game.vibrationEnabled),
          ),
          _buildFeedbackToggle(
            icon: Icons.style,
            label: "Kalan: ${game.remainingCards} Kart",
            isActive: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackToggle({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () async {
        await Provider.of<GameProvider>(context, listen: false).playClick();
        if (!context.mounted) return;
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black26,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.amber : Colors.white24,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreHeader(GameProvider game) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTeamScoreItem(
                game.teamAName,
                game.teamAScore,
                Colors.blueAccent,
                game.isTeamATurn,
              ),
            ),
            Container(
              width: 82,
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.deepPurple, width: 4),
                    ),
                    alignment: Alignment.center,
                    child: FadeTransition(
                      opacity: _blink,
                      child: Text(
                        "${game.timeLeft}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: IconButton(
                      icon: const Icon(Icons.pause_circle_filled),
                      color: Colors.black,
                      iconSize: 26,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        await game.playClick();
                        _onPausePressed(game);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildTeamScoreItem(
                game.teamBName,
                game.teamBScore,
                Colors.redAccent,
                !game.isTeamATurn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamScoreItem(
    String name,
    int score,
    Color color,
    bool isActive,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.8) : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                name,
                style: TextStyle(
                  color: color,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Text(
            "$score",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 26,
              shadows: isActive
                  ? [const BoxShadow(blurRadius: 10, color: Colors.black45)]
                  : [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(WordCard? card) {
    if (card == null) return Container(key: const ValueKey("empty"));
    return Container(
      key: ValueKey(card.id),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [const BoxShadow(blurRadius: 20, color: Colors.black45)],
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            alignment: Alignment.center,
            child: Text(
              card.category.toUpperCase(),
              style: const TextStyle(
                color: Colors.white38,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double wordSize = (constraints.biggest.shortestSide * 0.1)
                    .clamp(16.0, 30.0);
                final double tabooSize =
                    (constraints.biggest.shortestSide * 0.06).clamp(11.0, 18.0);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              card.word,
                              style: TextStyle(
                                fontSize: wordSize,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 0, bottom: 2),
                      child: Divider(thickness: 2, indent: 8, endIndent: 8),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: card.tabooWords
                            .map(
                              (t) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 6,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                      fontSize: tabooSize,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BouncingButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? badgeText;
  final VoidCallback onTap;
  final bool disabled;
  const BouncingButton({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.badgeText,
    this.disabled = false,
  });
  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _s = Tween<double>(begin: 1.0, end: 0.9).animate(_c);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = Provider.of<GameProvider>(
      context,
      listen: false,
    ).reducedMotion;
    return GestureDetector(
      onTapDown: (_) {
        if (widget.disabled) return;
        _c.forward();
      },
      onTapUp: (_) {
        if (widget.disabled) return;
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: reduceMotion ? const AlwaysStoppedAnimation(1.0) : _s,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.disabled
                        ? widget.color.withValues(alpha: 0.5)
                        : widget.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 30),
                ),
                if (widget.badgeText != null)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(
                        widget.badgeText!,
                        style: TextStyle(
                          color: widget.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}

class _FloatingTextItem extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onComplete;
  const _FloatingTextItem({
    super.key,
    required this.text,
    required this.color,
    required this.onComplete,
  });
  @override
  State<_FloatingTextItem> createState() => _FloatingTextItemState();
}

class _FloatingTextItemState extends State<_FloatingTextItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<Offset> _p;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _p = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.0),
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));
    _c.forward().then((_) => widget.onComplete());
  }

  @override
  Widget build(BuildContext context) => Center(
    child: SlideTransition(
      position: _p,
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 1,
          end: 0,
        ).animate(CurvedAnimation(parent: _c, curve: const Interval(0.6, 1))),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w900,
            color: widget.color,
            shadows: const [BoxShadow(blurRadius: 10, color: Colors.black45)],
          ),
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}

Future<bool> _confirmExitToMenu(
  BuildContext context, {
  bool force = false,
}) async {
  final shouldExit =
      await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Ana menüye dönülsün mü?"),
          content: const Text("Oyundan çıkmak istediğine emin misin?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("HAYIR"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("EVET"),
            ),
          ],
        ),
      ) ??
      false;
  if (!context.mounted) return false;
  if (shouldExit) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      (route) => false,
    );
    return false;
  }
  return false;
}

// --- 5. REPORT SCREEN (Simple Cards, No Poker) ---
class RoundReportScreen extends StatelessWidget {
  const RoundReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    final correctList = game.roundHistory
        .where((e) => e.status == CardStatus.correct)
        .toList();
    final tabooList = game.roundHistory
        .where((e) => e.status == CardStatus.taboo)
        .toList();
    final passList = game.roundHistory
        .where((e) => e.status == CardStatus.pass)
        .toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmExitToMenu(context);
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: const Text(
              "TUR SONUCU",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.black87),
              onPressed: () => _confirmExitToMenu(context, force: true),
            ),
            bottom: const TabBar(
              isScrollable: false,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepPurple,
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontSize: 12),
              tabs: [
                Tab(text: "BİLİNENLER"),
                Tab(text: "TABU OLANLAR"),
                Tab(text: "PAS GEÇİLENLER"),
              ],
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 40,
                  ),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statCol("DOĞRU", correctList.length, Colors.green),
                      _statCol("TABU", tabooList.length, Colors.red),
                      _statCol(
                        "PUAN",
                        correctList.length - tabooList.length,
                        Colors.deepPurple,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _InfoChip(
                        icon: Icons.layers,
                        label: game.allCardsUsed
                            ? "Kartlar bitti"
                            : "Kalan kart: ${game.remainingCards}",
                        textColor: Colors.black87,
                        fillColor: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSimpleCardList(correctList, Colors.green),
                      _buildSimpleCardList(tabooList, Colors.red),
                      _buildSimpleCardList(passList, Colors.blue),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (game.allCardsUsed || game.gameWinner != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GameOverScreen(),
                            ),
                          );
                        } else {
                          game.finishTurn();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RoundStartScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "DEVAM ET",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCol(String label, int val, Color c) => Column(
    children: [
      Text(
        label,
        style: TextStyle(color: c, fontWeight: FontWeight.bold),
      ),
      Text(
        "$val",
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
        ),
      ),
    ],
  );

  // SIMPLE RECTANGLE CARD
  Widget _buildSimpleCardList(List<RoundEvent> events, Color color) {
    if (events.isEmpty) {
      return Center(
        child: Text("Kart yok", style: TextStyle(color: Colors.grey[500])),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final card = event.card;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.9),
                color.withValues(alpha: 0.65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: LayoutBuilder(
            builder: (context, c) {
              final bool compact = c.maxHeight < 140;
              final double wordSize = compact ? 15 : 18;
              final double tabooSize = compact ? 10 : 12;
              final EdgeInsets chipPad = compact
                  ? const EdgeInsets.symmetric(horizontal: 6, vertical: 3)
                  : const EdgeInsets.symmetric(horizontal: 7, vertical: 4);
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: chipPad,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      card.category.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 9 : 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Text(
                    card.word,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (wordSize * 0.9).clamp(12, 18),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...card.tabooWords.map(
                          (t) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.5),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                t,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (tabooSize * 0.9).clamp(9, 13),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (event.timedOut)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Süre bitti",
                              style: TextStyle(
                                color: Colors.amber[200],
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// --- 6. GAME OVER SCREEN ---
class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context, listen: false);
    final GlobalKey boundaryKey = GlobalKey();
    Future<void> shareSummary() async {
      try {
        if (kIsWeb) {
          final summary =
              "${game.teamAName}: ${game.teamAScore}\n${game.teamBName}: ${game.teamBScore}\n${game.gameWinner != null ? "Kazanan: ${game.gameWinner}" : "Berabere"}";
          await SharePlus.instance.share(ShareParams(text: summary));
          return;
        }
        await WidgetsBinding.instance.endOfFrame;
        if (!context.mounted) return;
        final boundary =
            boundaryKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary == null) return;
        final pixelRatio = View.of(context).devicePixelRatio;
        final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return;
        final bytes = byteData.buffer.asUint8List();
        final dir = await getTemporaryDirectory();
        final file = File(
          "${dir.path}/score_${DateTime.now().millisecondsSinceEpoch}.png",
        );
        await file.writeAsBytes(bytes, flush: true);
        await SharePlus.instance.share(
          ShareParams(text: "Skor özeti", files: [XFile(file.path)]),
        );
      } catch (e) {
        if (!context.mounted) return;
        final summary =
            "${game.teamAName}: ${game.teamAScore}\n${game.teamBName}: ${game.teamBScore}\n${game.gameWinner != null ? "Kazanan: ${game.gameWinner}" : "Berabere"}";
        await SharePlus.instance.share(ShareParams(text: summary));
      }
    }

    return Scaffold(
      body: GameBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: RepaintBoundary(
              key: boundaryKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 100,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "OYUN BİTTİ",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        letterSpacing: 5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (game.endMessage != null)
                      Text(
                        game.endMessage!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (game.endMessage != null) const SizedBox(height: 10),
                    if (game.gameWinner != null)
                      const Text(
                        "KAZANAN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          game.gameWinner ?? "BERABERE",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              BoxShadow(color: Colors.black, blurRadius: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: _finalScoreItem(
                              game.teamAName,
                              game.teamAScore,
                              Colors.blue,
                            ),
                          ),
                          const Text(
                            "-",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: _finalScoreItem(
                              game.teamBName,
                              game.teamBScore,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: shareSummary,
                      icon: const Icon(Icons.share),
                      label: const Text(
                        "Paylaş",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    ElevatedButton(
                      onPressed: () {
                        game.startGame();
                        game.rollDice();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const RoundStartScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 38,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        "RÖVANŞ?",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        "ANA MENÜYE DÖN",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 18,
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
  }

  Widget _finalScoreItem(String name, int score, Color c) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Text(
          "$score",
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                "AYARLAR",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text("Müzik"),
                secondary: const Icon(Icons.music_note),
                value: game.musicEnabled,
                onChanged: (val) async {
                  await game.playClick();
                  game.toggleMusic(val);
                },
              ),
              SwitchListTile(
                title: const Text("Ses Efektleri"),
                secondary: const Icon(Icons.surround_sound),
                value: game.soundEnabled,
                onChanged: (val) async {
                  if (val) {
                    await game.playClick();
                  }
                  game.toggleSound(val);
                },
              ),
              SwitchListTile(
                title: const Text("Titreşim"),
                secondary: const Icon(Icons.vibration),
                value: game.vibrationEnabled,
                onChanged: (val) async {
                  await game.playClick();
                  game.toggleVibration(val);
                },
              ),
              SwitchListTile(
                title: const Text("Yüksek Kontrast"),
                secondary: const Icon(Icons.contrast),
                value: game.highContrast,
                onChanged: (val) async {
                  await game.playClick();
                  game.toggleHighContrast(val);
                },
              ),
              SwitchListTile(
                title: const Text("Az Animasyon"),
                secondary: const Icon(Icons.motion_photos_off),
                value: game.reducedMotion,
                onChanged: (val) async {
                  await game.playClick();
                  game.toggleReducedMotion(val);
                },
              ),
              const SizedBox(height: 6),
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
                  child: const Text(
                    "Kapat",
                    style: TextStyle(
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
    );
  }
}

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
        title: const Text("Hızlı Başlangıç İpucu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.timer),
              title: Text("Süre"),
              subtitle: Text(
                "Her turda geri sayılan zaman dolunca tur otomatik biter.",
              ),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.skip_next),
              title: Text("Pas"),
              subtitle: Text(
                "En fazla 3 kez pas geçme hakkın var; her bastığında bir hak azalır.",
              ),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.block),
              title: Text("Tabu"),
              subtitle: Text(
                "Yasaklı kelimelerden birini söylersen puan kaybedersin, kart değişir.",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anladım"),
          ),
        ],
      ),
    ).then((_) => game.markTutorialTipSeen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Nasıl Oynanır?"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
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
                    const Text(
                      "Oyunun Özeti",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Takımlar, anlatıcının tabu kelimelerini kullanmadan karttaki ana kelimeyi anlattığı bir tahmin oyunu oynar.",
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
                title: "Süre Yönetimi",
                description:
                    "Her tur 30 ila 90 (isteğe bağlı) saniye arasında sürer. Sayaç ekranın ortasındadır; 0 olunca tur biter ve puanlar görünür.",
              ),
              _TutorialTipCard(
                icon: Icons.skip_next,
                title: "Pas Hakkı",
                description:
                    "Tur başlangıcında 3 pas hakkın olur. 3 defa kart geçtiğinde, yani 'PAS' butonuna bastığında daha fazla kart geçemezsin.",
              ),
              _TutorialTipCard(
                icon: Icons.block,
                title: "Tabu Cezası",
                description:
                    "Tabu kelime söylendiğinde (yani yakalandığında) takım puanı bir azalır ve yeni karta geçilir.",
              ),
              _TutorialTipCard(
                icon: Icons.record_voice_over,
                title: "Anlatıcı Döngüsü",
                description:
                    "Takım sırası ekrandaki 'Anlatıcı' alanında görünür; her tur sonunda sıra bir sonraki oyuncuya geçer.",
              ),
              _TutorialTipCard(
                icon: Icons.settings_voice,
                title: "Geri Bildirim",
                description:
                    "Tabu/Doğru/Pas butonlarının üstündeki ses ve titreşim kısayolları ile anında dokunsal/işitsel geri bildirimi aç/kapa yapabilirsin.",
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
