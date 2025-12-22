part of '../main.dart';

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
