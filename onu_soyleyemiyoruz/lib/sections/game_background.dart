part of '../main.dart';

class GameBackground extends StatelessWidget {
  final Widget child;
  const GameBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF140D1F),
                  Color(0xFF22102F),
                  Color(0xFF2A0F3B),
                ]
              : const [
                  Color(0xFF2E0249),
                  Color(0xFF570A57),
                  Color(0xFFA91079),
                ],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
