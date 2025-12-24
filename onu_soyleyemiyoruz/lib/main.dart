import 'dart:io';
import 'dart:async';
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
part 'sections/game_background.dart';
part 'sections/main_menu.dart';
part 'sections/setup_hub.dart';
part 'sections/category_management.dart';
part 'sections/dice_roll.dart';
part 'sections/round_start.dart';
part 'sections/gameplay.dart';
part 'sections/round_report.dart';
part 'sections/game_over.dart';
part 'sections/settings_sheet.dart';
part 'sections/tutorial.dart';

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
            brightness: Brightness.light,
          ),
          pageTransitionsTheme: pageTransitions,
        );
        final darkTheme = ThemeData(
          fontFamily: 'Roboto',
          brightness: Brightness.dark,
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
            brightness: Brightness.dark,
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
          darkTheme: darkTheme,
          themeMode: game.themeMode,
          home: home,
        );
      },
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

void _showSnack(
  ScaffoldMessengerState messenger,
  String message, {
  bool isError = false,
  bool isSuccess = false,
  String? actionLabel,
  IconData? actionIcon,
  VoidCallback? onAction,
}) {
  messenger.removeCurrentSnackBar();
  const Duration toastDuration = Duration(seconds: 3);
  const Duration fadeOutDuration = Duration(milliseconds: 350);
  const Duration fadeInDuration = Duration(milliseconds: 350);
  final secondsLeft = ValueNotifier<int>(toastDuration.inSeconds);
  final opacity = ValueNotifier<double>(0.0);
  final dismissKey = UniqueKey();
  bool dismissed = false;
  bool notifierDisposed = false;
  bool actionHandled = false;
  Timer? timer;
  final Color background = isError
      ? const Color(0xFFB00020)
      : isSuccess
      ? const Color(0xFF2E7D32)
      : const Color(0xFFFB8C00);
  final IconData icon = isError
      ? Icons.error_outline
      : isSuccess
      ? Icons.check_circle_outline
      : Icons.info_outline;
  final Color iconColor = Colors.white70;
  final Color closeColor = isError ? Colors.white : Colors.redAccent;
  final BorderRadius toastRadius = BorderRadius.circular(14);
  Future<void> fadeOutAndDismiss() async {
    if (dismissed || notifierDisposed) return;
    dismissed = true;
    opacity.value = 0;
    await Future.delayed(fadeOutDuration);
    messenger.hideCurrentSnackBar();
  }
  void handleAction() {
    if (actionHandled || dismissed || notifierDisposed) return;
    actionHandled = true;
    onAction?.call();
    fadeOutAndDismiss();
  }

  final controller = messenger.showSnackBar(
    SnackBar(
      duration: toastDuration + fadeOutDuration,
      behavior: SnackBarBehavior.fixed,
      dismissDirection: DismissDirection.none,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      content: ValueListenableBuilder<double>(
        valueListenable: opacity,
        builder: (context, value, child) {
          final animDuration = value >= 1 ? fadeInDuration : fadeOutDuration;
          final double slideOffset = (1 - value).clamp(0.0, 1.0).toDouble();
          final double maxWidth = (MediaQuery.of(context).size.width - 32)
              .clamp(0.0, 360.0)
              .toDouble();
          return AnimatedSlide(
            offset: Offset(0, slideOffset),
            duration: animDuration,
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: value,
              duration: animDuration,
              curve: Curves.easeOut,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: Dismissible(
          key: dismissKey,
          direction: DismissDirection.horizontal,
          onDismissed: (_) {
            if (dismissed) return;
            dismissed = true;
            messenger.hideCurrentSnackBar();
          },
          child: Material(
            color: background,
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            borderRadius: toastRadius,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(message)),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: handleAction,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (actionIcon != null) ...[
                              Icon(
                                actionIcon,
                                size: 14,
                                color: Colors.amber[200],
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              actionLabel,
                              style: TextStyle(
                                color: Colors.amber[200],
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  ValueListenableBuilder<int>(
                    valueListenable: secondsLeft,
                    builder: (context, value, _) => Text(
                      "$value sn",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: fadeOutAndDismiss,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: closeColor, size: 18),
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
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!notifierDisposed) {
      opacity.value = 1.0;
    }
  });
  timer = Timer.periodic(const Duration(seconds: 1), (_) {
    if (secondsLeft.value <= 1) {
      fadeOutAndDismiss();
      return;
    }
    secondsLeft.value -= 1;
  });
  controller.closed.then((_) {
    dismissed = true;
    notifierDisposed = true;
    timer?.cancel();
    secondsLeft.dispose();
    opacity.dispose();
  });
}

void _showCardPreview(BuildContext context, WordCard card) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
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
              onPressed: () async {
                await Provider.of<GameProvider>(
                  context,
                  listen: false,
                ).playClick();
                if (!context.mounted) return;
                Navigator.pop(context, false);
              },
              child: const Text("HAYIR"),
            ),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<GameProvider>(
                  context,
                  listen: false,
                ).playClick();
                if (!context.mounted) return;
                Navigator.pop(context, true);
              },
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
