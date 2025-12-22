part of '../main.dart';

class GameBackground extends StatelessWidget {
  final Widget child;
  const GameBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
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
