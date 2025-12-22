part of '../main.dart';

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
