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
      _showSnack(messenger, "Kelime en fazla 16 karakter olabilir");
      return;
    }
    final taboos = _tabooControllers.map((c) => c.text).toList();
    final error = _editing && widget.existingCard != null
        ? game.updateCustomCard(widget.existingCard!, _wordController.text, taboos)
        : game.addCustomCard(_wordController.text, taboos);
    if (error != null) {
      _showSnack(messenger, error);
      return;
    }
    final addedWord = _wordController.text.trim().toUpperCase();
    _showSnack(messenger, "$addedWord ÖZEL kategorisine eklendi");
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

void _showSnack(ScaffoldMessengerState messenger, String message) {
  messenger.removeCurrentSnackBar();
  messenger.showSnackBar(SnackBar(content: Text(message)));
}
