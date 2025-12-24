import 'dart:async';

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
        "Kelime en fazla 16 karakter olabilir",
        isError: true,
      );
      return;
    }
    final taboos = _tabooControllers.map((c) => c.text).toList();
    final error = _editing && widget.existingCard != null
        ? game.updateCustomCard(widget.existingCard!, _wordController.text, taboos)
        : game.addCustomCard(_wordController.text, taboos);
    if (error != null) {
      _showSnack(messenger, error, isError: true);
      return;
    }
    final addedWord = _wordController.text.trim().toUpperCase();
    _showSnack(
      messenger,
      "$addedWord ÖZEL kategorisine eklendi",
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
    final taboosPreview = _tabooControllers
        .asMap()
        .entries
        .map(
          (e) => e.value.text.isEmpty
              ? "Tabu ${e.key + 1}"
              : e.value.text.toUpperCase(),
        )
        .toList();
    final wordText = _wordController.text.isEmpty
        ? "KELİME"
        : _wordController.text.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
            decoration: const BoxDecoration(
              color: Color(0xFF7B1FA2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            height: 64,
            alignment: Alignment.center,
            child: const Text(
              "ÖZEL",
              style: TextStyle(
                color: Colors.grey,
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
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp('[A-Za-zÇçĞğİıÖöŞşÜü ]'),
              ),
            ],
            decoration: InputDecoration(
              counterText: "",
              isDense: true,
              border: InputBorder.none,
              hintText: wordText,
              hintStyle: const TextStyle(
                color: Colors.black38,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
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
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp('[A-Za-zÇçĞğİıÖöŞşÜü ]'),
                    ),
                  ],
                  decoration: InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                    hintText: taboosPreview[i],
                    hintStyle: const TextStyle(
                      color: Colors.black38,
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Özel Kart Ekle"),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E0249), Color(0xFF570A57), Color(0xFFA91079)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _cardPreview(),
                      const SizedBox(height: 20),
                      if (_editing) ...[
                        ElevatedButton(
                        onPressed: () => _handleSave(exitAfter: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Kaydet",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                      onPressed: () async {
                        await Provider.of<GameProvider>(context, listen: false)
                            .playClick();
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Çık"),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleSave(exitAfter: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  "Kaydet ve Çık",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleSave(exitAfter: false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  "Kaydet ve Devam Et",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                        onPressed: () async {
                          await Provider.of<GameProvider>(context, listen: false)
                              .playClick();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Kaydetmeden Çık"),
                        ),
                      ],
                    ],
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
          final double slideOffset =
              (1 - value).clamp(0.0, 1.0).toDouble();
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
