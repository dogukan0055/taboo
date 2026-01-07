import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'game_provider.dart';
import 'models.dart';

class AddCustomCardScreen extends StatefulWidget {
  final WordCard? existingCard;
  const AddCustomCardScreen({super.key, this.existingCard});

  @override
  State<AddCustomCardScreen> createState() => _AddCustomCardScreenState();
}

class _AddCustomCardScreenState extends State<AddCustomCardScreen> {
  final TextEditingController _wordController = TextEditingController();
  final List<TextEditingController> _tabooControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final FocusNode _wordFocus = FocusNode();
  late final bool _editing;

  @override
  void initState() {
    super.initState();
    _editing = widget.existingCard != null;
    if (_editing) {
      _wordController.text = widget.existingCard!.word;
      final taboos = widget.existingCard!.tabooWords;
      for (var i = 0; i < _tabooControllers.length; i++) {
        _tabooControllers[i].text = i < taboos.length ? taboos[i] : "";
      }
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    for (final c in _tabooControllers) {
      c.dispose();
    }
    _wordFocus.dispose();
    super.dispose();
  }

  void _clearFields() {
    _wordController.clear();
    for (final c in _tabooControllers) {
      c.clear();
    }
    _wordFocus.requestFocus();
  }

  Future<void> _handleSave({required bool exitAfter}) async {
    final game = Provider.of<GameProvider>(context, listen: false);
    await game.playClick();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (_wordController.text.trim().length > 16) {
      _showSnack(
        messenger,
        game.t("error_word_max", params: {"max": "16"}),
        isError: true,
      );
      return;
    }
    final taboos = _tabooControllers.map((c) => c.text).toList();
    final error = _editing && widget.existingCard != null
        ? game.updateCustomCard(
            widget.existingCard!,
            _wordController.text,
            taboos,
          )
        : game.addCustomCard(_wordController.text, taboos);
    if (error != null) {
      _showSnack(messenger, error, isError: true);
      return;
    }
    final addedWord = game.languageUpper(_wordController.text.trim());
    _showSnack(
      messenger,
      game.t(
        "custom_added",
        params: {
          "word": addedWord,
          "category": game.languageUpper(game.categoryLabel("Özel")),
        },
      ),
      isSuccess: true,
    );
    if (exitAfter || _editing) {
      Navigator.pop(context, addedWord);
    } else {
      _clearFields();
      setState(() {});
    }
  }

  Widget _cardPreview() {
    final game = Provider.of<GameProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color headerColor = isDark
        ? const Color(0xFF2E1A4A)
        : const Color(0xFF7B1FA2);
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color hintColor = isDark ? Colors.white38 : Colors.black38;
    final Color dividerColor = isDark
        ? Colors.white24
        : const Color(0xFFE0E0E0);
    final taboosPreview = _tabooControllers
        .asMap()
        .entries
        .map(
          (e) => e.value.text.isEmpty
              ? game.t("taboo_hint", params: {"index": "${e.key + 1}"})
              : game.languageUpper(e.value.text),
        )
        .toList();
    final wordText = _wordController.text.isEmpty
        ? game.t("word_hint")
        : game.languageUpper(_wordController.text);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            height: 64,
            alignment: Alignment.center,
            child: Text(
              game.languageUpper(game.categoryLabel("Özel")),
              style: TextStyle(
                color: Colors.white70,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _wordController,
            focusNode: _wordFocus,
            maxLength: 16,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(game.wordAllowedChars),
            ],
            decoration: InputDecoration(
              counterText: "",
              isDense: true,
              border: InputBorder.none,
              hintText: wordText,
              hintStyle: TextStyle(
                color: hintColor,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, thickness: 1, color: dividerColor),
          const SizedBox(height: 12),
          Column(
            children: List.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: TextField(
                  controller: _tabooControllers[i],
                  maxLength: 20,
                  textCapitalization: TextCapitalization.sentences,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(game.wordAllowedChars),
                  ],
                  decoration: InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                    hintText: taboosPreview[i],
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saveColor = isDark ? Colors.amber[400]! : Colors.amber;
    final saveTextColor = Colors.black;
    final continueColor = isDark ? Colors.green[400]! : Colors.greenAccent;
    final continueTextColor = Colors.black;
    final dangerColor = isDark ? Colors.red[400]! : Colors.redAccent;
    final dangerBorderColor = isDark ? Colors.red[300]! : Colors.redAccent;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          _editing ? game.t("edit_custom_card") : game.t("add_custom_card"),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await Provider.of<GameProvider>(context, listen: false).playClick();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    Color(0xFF2E0249),
                    Color(0xFF570A57),
                    Color(0xFFA91079),
                  ]
                : const [
                    Color(0xFFE2D3F0),
                    Color(0xFFB78BD5),
                    Color(0xFF8F4FB8),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final Size size = MediaQuery.of(context).size;
              final bool isWide = size.shortestSide >= 600;
              final double baseWidth = size.width * (isWide ? 0.5 : 0.75);
              final double formMaxWidth = math.min(
                baseWidth,
                isWide ? 480 : 360,
              );
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: formMaxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _cardPreview(),
                          const SizedBox(height: 20),
                          if (_editing) ...[
                            ElevatedButton(
                              onPressed: () => _handleSave(exitAfter: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: saveColor,
                                foregroundColor: saveTextColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                game.t("save"),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: () async {
                                await Provider.of<GameProvider>(
                                  context,
                                  listen: false,
                                ).playClick();
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: dangerColor,
                                side: BorderSide(color: dangerBorderColor),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(game.t("exit")),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _handleSave(exitAfter: true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: saveColor,
                                      foregroundColor: saveTextColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: Text(
                                      game.t("save_and_exit"),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _handleSave(exitAfter: false),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: continueColor,
                                      foregroundColor: continueTextColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: Text(
                                      game.t("save_and_continue"),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: () async {
                                await Provider.of<GameProvider>(
                                  context,
                                  listen: false,
                                ).playClick();
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: dangerColor,
                                side: BorderSide(color: dangerBorderColor),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(game.t("exit_without_save")),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
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
  const Duration fadeOutDuration = Duration(milliseconds: 260);
  const Duration fadeInDuration = Duration(milliseconds: 320);
  final secondsLeft = ValueNotifier<int>(toastDuration.inSeconds);
  final opacity = ValueNotifier<double>(0.0);
  final dismissKey = UniqueKey();
  bool dismissed = false;
  bool notifierDisposed = false;
  bool actionHandled = false;
  Timer? timer;
  final game = Provider.of<GameProvider>(messenger.context, listen: false);
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
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
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
                      "$value ${game.t("seconds_short")}",
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
