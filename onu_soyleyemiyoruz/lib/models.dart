enum CardStatus { correct, taboo, pass }

class WordCard {
  final String id;
  final String word;
  final List<String> tabooWords;
  final String category;
  final bool isCustom;

  WordCard({
    String? id,
    required this.word,
    required this.tabooWords,
    this.category = "Genel",
    this.isCustom = false,
  }) : id = id ?? _buildStableId(word, category);
}

String _buildStableId(String word, String category) {
  String sanitize(String v) {
    return v
        .replaceAll(RegExp(r'[^A-Za-z0-9ÇĞİÖŞÜçğıöşü]+'), "_")
        .replaceAll(RegExp(r'_+'), "_")
        .trim()
        .toUpperCase();
  }

  return "${sanitize(category)}_${sanitize(word)}";
}

class RoundEvent {
  final WordCard card;
  final CardStatus status;
  final bool timedOut;

  RoundEvent({required this.card, required this.status, this.timedOut = false});
}

class RoundSummary {
  final int turnIndex;
  final int roundNumber;
  final int turnInRound;
  final bool isTeamA;
  final String teamName;
  final String narrator;
  final int correct;
  final int taboo;
  final int pass;
  final int points;
  final int maxTabooStreak;

  const RoundSummary({
    required this.turnIndex,
    required this.roundNumber,
    required this.turnInRound,
    required this.isTeamA,
    required this.teamName,
    required this.narrator,
    required this.correct,
    required this.taboo,
    required this.pass,
    required this.points,
    required this.maxTabooStreak,
  });
}

// --- DUMMY DATA ---
final List<WordCard> initialDeckTr = [
  // Genel Kategori
  WordCard(
    word: "SAAT",
    tabooWords: ["Zaman", "Dakika", "Saniye", "Kol", "Duvar"],
    category: "Genel",
  ),
  WordCard(
    word: "ANAHTAR",
    tabooWords: ["Kapı", "Kilit", "Açmak", "Ev", "Girmek"],
    category: "Genel",
  ),
  WordCard(
    word: "YASTIK",
    tabooWords: ["Uyku", "Yatak", "Kafa", "Yumuşak", "Gece"],
    category: "Genel",
  ),
  WordCard(
    word: "AYNA",
    tabooWords: ["Bakmak", "Görmek", "Cam", "Yüz", "Yansıma"],
    category: "Genel",
  ),
  WordCard(
    word: "ÇANTA",
    tabooWords: ["Taşımak", "Okul", "Omuz", "Sırt", "Eşya"],
    category: "Genel",
  ),
  WordCard(
    word: "ŞEMSİYE",
    tabooWords: ["Yağmur", "Islanmak", "Açmak", "Hava", "Korunmak"],
    category: "Genel",
  ),
  WordCard(
    word: "MERDİVEN",
    tabooWords: ["Basamak", "Çıkmak", "İnmek", "Kat", "Bina"],
    category: "Genel",
  ),
  WordCard(
    word: "KAPAK",
    tabooWords: ["Kapatmak", "Şişe", "Kutu", "Açmak", "Üst"],
    category: "Genel",
  ),
  WordCard(
    word: "YORGAN",
    tabooWords: ["Uyku", "Yatak", "Sıcak", "Gece", "Üst"],
    category: "Genel",
  ),
  WordCard(
    word: "FIRÇA",
    tabooWords: ["Saç", "Taramak", "Boyamak", "Diş", "Kıl"],
    category: "Genel",
  ),
  WordCard(
    word: "TABAK",
    tabooWords: ["Yemek", "Mutfak", "Servis", "Cam", "Porselen"],
    category: "Genel",
  ),
  WordCard(
    word: "KAŞIK",
    tabooWords: ["Çatal", "Yemek", "Çorba", "Metal", "Ağız"],
    category: "Genel",
  ),
  WordCard(
    word: "PERDE",
    tabooWords: ["Pencere", "Güneş", "Kapamak", "Tül", "Ev"],
    category: "Genel",
  ),
  WordCard(
    word: "HALI",
    tabooWords: ["Zemin", "Ev", "Desen", "Kilimi", "Sermek"],
    category: "Genel",
  ),
  WordCard(
    word: "DOLAP",
    tabooWords: ["Kıyafet", "Kapak", "Mutfak", "Raf", "Saklamak"],
    category: "Genel",
  ),
  WordCard(
    word: "YASTIK KILIFI",
    tabooWords: ["Kumaş", "Uyku", "Yatak", "Geçirmek", "Baş"],
    category: "Genel",
  ),
  WordCard(
    word: "KUMANDA",
    tabooWords: ["Televizyon", "Tuş", "Pil", "Kanal", "Değiştirmek"],
    category: "Genel",
  ),
  WordCard(
    word: "LAMBА",
    tabooWords: ["Işık", "Aydınlatma", "Ampul", "Gece", "Elektrik"],
    category: "Genel",
  ),
  WordCard(
    word: "PRİZ",
    tabooWords: ["Elektrik", "Fiş", "Duvar", "Şarj", "Akım"],
    category: "Genel",
  ),
  WordCard(
    word: "DEFTER",
    tabooWords: ["Yazmak", "Okul", "Sayfa", "Kalem", "Not"],
    category: "Genel",
  ),
  WordCard(
    word: "SANDALYE",
    tabooWords: ["Oturmak", "Masa", "Ahşap", "Ayak", "Ev"],
    category: "Genel",
  ),
  WordCard(
    word: "MASA",
    tabooWords: ["Yemek", "Çalışmak", "Ayak", "Üst", "Mobilya"],
    category: "Genel",
  ),
  WordCard(
    word: "BATTANİYE",
    tabooWords: ["Soğuk", "Üst", "Yatak", "Sıcak", "Kumaş"],
    category: "Genel",
  ),
  WordCard(
    word: "ÇEKMECE",
    tabooWords: ["Dolap", "Açmak", "Kapatmak", "Saklamak", "Mobilya"],
    category: "Genel",
  ),
  WordCard(
    word: "FIRIN",
    tabooWords: ["Yemek", "Isı", "Mutfak", "Pişirmek", "Elektrik"],
    category: "Genel",
  ),
  WordCard(
    word: "SÜPÜRGE",
    tabooWords: ["Temizlik", "Elektrik", "Toz", "Halı", "Ev"],
    category: "Genel",
  ),
  WordCard(
    word: "TEPSİ",
    tabooWords: ["Yemek", "Fırın", "Metal", "Taşımak", "Mutfak"],
    category: "Genel",
  ),
  WordCard(
    word: "MINDER",
    tabooWords: ["Oturmak", "Yumuşak", "Yer", "Koltuk", "Ev"],
    category: "Genel",
  ),
  WordCard(
    word: "ÇALAR SAAT",
    tabooWords: ["Uyanmak", "Sabah", "Zil", "Alarm", "Zaman"],
    category: "Genel",
  ),
  WordCard(
    word: "KİLİT",
    tabooWords: ["Anahtar", "Kapı", "Güvenlik", "Açmak", "Kapatmak"],
    category: "Genel",
  ),
  WordCard(
    word: "PENCERE",
    tabooWords: ["Cam", "Perde", "Açmak", "Ev", "Işık"],
    category: "Genel",
  ),
  WordCard(
    word: "KOLTUK",
    tabooWords: ["Oturmak", "Salon", "Rahat", "Mobilya", "Ev"],
    category: "Genel",
  ),
  WordCard(
    word: "HAVLU",
    tabooWords: ["Banyo", "Kurulamak", "Su", "Kumaş", "El"],
    category: "Genel",
  ),
  WordCard(
    word: "SABUN",
    tabooWords: ["Yıkamak", "Köpük", "Temizlik", "Banyo", "El"],
    category: "Genel",
  ),
  WordCard(
    word: "DİŞ FIRÇASI",
    tabooWords: ["Diş", "Macun", "Ağız", "Temizlik", "Banyo"],
    category: "Genel",
  ),
  WordCard(
    word: "BAVUL",
    tabooWords: ["Seyahat", "Valiz", "Kıyafet", "Taşımak", "Yolculuk"],
    category: "Genel",
  ),
  WordCard(
    word: "ÇÖP KUTUSU",
    tabooWords: ["Atmak", "Çöp", "Temizlik", "Ev", "Poşet"],
    category: "Genel",
  ),
  WordCard(
    word: "NOT DEFTERİ",
    tabooWords: ["Yazmak", "Küçük", "Taşımak", "Sayfa", "Kalem"],
    category: "Genel",
  ),
  WordCard(
    word: "TERLİK",
    tabooWords: ["Ev", "Ayak", "Rahat", "Giymek", "İç"],
    category: "Genel",
  ),
  WordCard(
    word: "ŞARJ ALETİ",
    tabooWords: ["Telefon", "Pil", "Elektrik", "Kablo", "Dolmak"],
    category: "Genel",
  ),
  WordCard(
    word: "FANUS",
    tabooWords: ["Cam", "Korumak", "Üst", "Kapatmak", "Şeffaf"],
    category: "Genel",
  ),
  WordCard(
    word: "TAKVİM",
    tabooWords: ["Gün", "Ay", "Yıl", "Tarih", "Zaman"],
    category: "Genel",
  ),
  WordCard(
    word: "KUTU",
    tabooWords: ["Koymak", "Kapak", "Saklamak", "Karton", "İç"],
    category: "Genel",
  ),
  WordCard(
    word: "MANDAL",
    tabooWords: ["Çamaşır", "Asmak", "Balkon", "Sıkıştırmak", "İp"],
    category: "Genel",
  ),
  WordCard(
    word: "ÇAKMAK",
    tabooWords: ["Ateş", "Yakmak", "Sigara", "Gaz", "El"],
    category: "Genel",
  ),

  // Sanat Kategori
  WordCard(
    word: "MONA LISA",
    tabooWords: ["Tablo", "Leonardo", "Gülümseme", "Resim", "Louvre"],
    category: "Sanat",
  ),
  WordCard(
    word: "PİKASSO",
    tabooWords: ["Ressam", "Kübizm", "Tablo", "İspanya", "Modern"],
    category: "Sanat",
  ),
  WordCard(
    word: "VAN GOGH",
    tabooWords: ["Ressam", "Kulak", "Yıldızlı", "Hollanda", "Tablo"],
    category: "Sanat",
  ),
  WordCard(
    word: "HEYKEL",
    tabooWords: ["Taş", "Bronz", "Yontmak", "Figür", "Sanatçı"],
    category: "Sanat",
  ),
  WordCard(
    word: "TİYATRO",
    tabooWords: ["Sahne", "Oyuncu", "Perde", "Oyun", "Salon"],
    category: "Sanat",
  ),
  WordCard(
    word: "OPERA",
    tabooWords: ["Şarkı", "Sahne", "Klasik", "Ses", "Temsil"],
    category: "Sanat",
  ),
  WordCard(
    word: "BALE",
    tabooWords: ["Dans", "Tütü", "Sahne", "Müzik", "Zarif"],
    category: "Sanat",
  ),
  WordCard(
    word: "RESİM",
    tabooWords: ["Boya", "Tuval", "Fırça", "Renk", "Tablo"],
    category: "Sanat",
  ),
  WordCard(
    word: "PORTRE",
    tabooWords: ["Yüz", "Resim", "Kişi", "Tablo", "Çizmek"],
    category: "Sanat",
  ),
  WordCard(
    word: "MANZARA",
    tabooWords: ["Doğa", "Resim", "Dağ", "Deniz", "Tablo"],
    category: "Sanat",
  ),
  WordCard(
    word: "SOYUT",
    tabooWords: ["Anlamsız", "Şekil", "Modern", "Resim", "Renk"],
    category: "Sanat",
  ),
  WordCard(
    word: "KARİKATÜR",
    tabooWords: ["Çizim", "Mizah", "Abartı", "Gazete", "Komik"],
    category: "Sanat",
  ),
  WordCard(
    word: "GRAFİTİ",
    tabooWords: ["Duvar", "Sprey", "Sokak", "Yazı", "Çizim"],
    category: "Sanat",
  ),
  WordCard(
    word: "FOTOĞRAF",
    tabooWords: ["Kamera", "Çekmek", "Görüntü", "Işık", "Kare"],
    category: "Sanat",
  ),
  WordCard(
    word: "SİNEMA",
    tabooWords: ["Film", "Salon", "Perde", "Oyuncu", "Yönetmen"],
    category: "Sanat",
  ),
  WordCard(
    word: "YÖNETMEN",
    tabooWords: ["Film", "Kamera", "Set", "Sinema", "Oyuncu"],
    category: "Sanat",
  ),
  WordCard(
    word: "SENARYO",
    tabooWords: ["Film", "Yazı", "Hikâye", "Sahne", "Metin"],
    category: "Sanat",
  ),
  WordCard(
    word: "KAMERA",
    tabooWords: ["Çekmek", "Video", "Fotoğraf", "Lens", "Film"],
    category: "Sanat",
  ),
  WordCard(
    word: "ROMAN",
    tabooWords: ["Kitap", "Yazar", "Hikâye", "Sayfa", "Kurgu"],
    category: "Sanat",
  ),
  WordCard(
    word: "ŞİİR",
    tabooWords: ["Dize", "Şair", "Kısa", "Duygu", "Yazı"],
    category: "Sanat",
  ),
  WordCard(
    word: "ŞAİR",
    tabooWords: ["Şiir", "Yazmak", "Dize", "Edebiyat", "Kalem"],
    category: "Sanat",
  ),
  WordCard(
    word: "BESTECİ",
    tabooWords: ["Müzik", "Nota", "Yazmak", "Klasik", "Eser"],
    category: "Sanat",
  ),
  WordCard(
    word: "ORKESTRA",
    tabooWords: ["Müzik", "Çalgı", "Şef", "Konser", "Topluluk"],
    category: "Sanat",
  ),
  WordCard(
    word: "KONSER",
    tabooWords: ["Müzik", "Sahne", "Canlı", "Dinlemek", "Kalabalık"],
    category: "Sanat",
  ),
  WordCard(
    word: "ENSTRÜMAN",
    tabooWords: ["Müzik", "Çalmak", "Ses", "Nota", "Alet"],
    category: "Sanat",
  ),
  WordCard(
    word: "GİTAR",
    tabooWords: ["Tel", "Çalmak", "Müzik", "Akustik", "Elektro"],
    category: "Sanat",
  ),
  WordCard(
    word: "KEMAN",
    tabooWords: ["Yay", "Tel", "Müzik", "Çalmak", "Klasik"],
    category: "Sanat",
  ),
  WordCard(
    word: "PİYANO",
    tabooWords: ["Tuş", "Müzik", "Çalmak", "Nota", "Kuyruklu"],
    category: "Sanat",
  ),
  WordCard(
    word: "NOTA",
    tabooWords: ["Müzik", "Yazı", "Ses", "Kağıt", "Çalmak"],
    category: "Sanat",
  ),
  WordCard(
    word: "SERGİ",
    tabooWords: ["Sanat", "Galeri", "Eser", "Gezmek", "Resim"],
    category: "Sanat",
  ),
  WordCard(
    word: "GALERİ",
    tabooWords: ["Sergi", "Resim", "Sanat", "Salon", "Duvar"],
    category: "Sanat",
  ),
  WordCard(
    word: "MÜZE",
    tabooWords: ["Tarih", "Eser", "Sergi", "Gezmek", "Bina"],
    category: "Sanat",
  ),
  WordCard(
    word: "KOSTÜM",
    tabooWords: ["Kıyafet", "Sahne", "Rol", "Tiyatro", "Film"],
    category: "Sanat",
  ),
  WordCard(
    word: "DEKOR",
    tabooWords: ["Sahne", "Arka plan", "Tiyatro", "Film", "Mekan"],
    category: "Sanat",
  ),
  WordCard(
    word: "MAKYAJ",
    tabooWords: ["Yüz", "Sahne", "Oyuncu", "Kozmetik", "Hazırlık"],
    category: "Sanat",
  ),
  WordCard(
    word: "KURGU",
    tabooWords: ["Film", "Kesmek", "Montaj", "Sahne", "Video"],
    category: "Sanat",
  ),
  WordCard(
    word: "MONTAJ",
    tabooWords: ["Video", "Kesmek", "Film", "Kurgu", "Bilgisayar"],
    category: "Sanat",
  ),
  WordCard(
    word: "AFİŞ",
    tabooWords: ["Tanıtım", "Film", "Duvar", "Poster", "Reklam"],
    category: "Sanat",
  ),
  WordCard(
    word: "POSTER",
    tabooWords: ["Duvar", "Film", "Resim", "Asmak", "Büyük"],
    category: "Sanat",
  ),
  WordCard(
    word: "ÇİZGİ FİLM",
    tabooWords: ["Animasyon", "Çocuk", "Karakter", "Televizyon", "Seslendirme"],
    category: "Sanat",
  ),
  WordCard(
    word: "ANİMASYON",
    tabooWords: ["Çizim", "Hareket", "Film", "Karakter", "Bilgisayar"],
    category: "Sanat",
  ),
  WordCard(
    word: "KOMEDİ",
    tabooWords: ["Komik", "Gülmek", "Film", "Mizah", "Tür"],
    category: "Sanat",
  ),
  WordCard(
    word: "DRAM",
    tabooWords: ["Film", "Duygu", "Ağlamak", "Tür", "Hikâye"],
    category: "Sanat",
  ),
  WordCard(
    word: "KLASİK MÜZİK",
    tabooWords: ["Orkestra", "Beste", "Nota", "Konser", "Eski"],
    category: "Sanat",
  ),
  WordCard(
    word: "MODERN SANAT",
    tabooWords: ["Soyut", "Güncel", "Galeri", "Anlam", "Yeni"],
    category: "Sanat",
  ),

  // Bilim Kategori
  WordCard(
    word: "ATOM",
    tabooWords: ["Parçacık", "Çekirdek", "Elektron", "Fizik", "Madde"],
    category: "Bilim",
  ),
  WordCard(
    word: "HÜCRE",
    tabooWords: ["Canlı", "Mikroskop", "DNA", "Biyoloji", "Çekirdek"],
    category: "Bilim",
  ),
  WordCard(
    word: "DNA",
    tabooWords: ["Gen", "Kalıtım", "Hücre", "Biyoloji", "Kod"],
    category: "Bilim",
  ),
  WordCard(
    word: "GEN",
    tabooWords: ["DNA", "Kalıtım", "Anne", "Baba", "Özellik"],
    category: "Bilim",
  ),
  WordCard(
    word: "MİKROSKOP",
    tabooWords: ["Küçük", "Mercek", "Laboratuvar", "Bakteri", "Görmek"],
    category: "Bilim",
  ),
  WordCard(
    word: "TELESKOP",
    tabooWords: ["Uzay", "Yıldız", "Gezegen", "Bakmak", "Gözlem"],
    category: "Bilim",
  ),
  WordCard(
    word: "ENERJİ",
    tabooWords: ["Güç", "Elektrik", "Hareket", "Isı", "Kaynak"],
    category: "Bilim",
  ),
  WordCard(
    word: "IŞIK",
    tabooWords: ["Görmek", "Hız", "Dalga", "Karanlık", "Güneş"],
    category: "Bilim",
  ),
  WordCard(
    word: "SES",
    tabooWords: ["Dalga", "Duymak", "Titreşim", "Kulak", "Gürültü"],
    category: "Bilim",
  ),
  WordCard(
    word: "DALGA",
    tabooWords: ["Su", "Ses", "Işık", "Titreşim", "Yayılmak"],
    category: "Bilim",
  ),
  WordCard(
    word: "ELEKTRON",
    tabooWords: ["Atom", "Yük", "Negatif", "Çekirdek", "Parçacık"],
    category: "Bilim",
  ),
  WordCard(
    word: "KİMYA",
    tabooWords: ["Deney", "Madde", "Reaksiyon", "Laboratuvar", "Bilim"],
    category: "Bilim",
  ),
  WordCard(
    word: "FİZİK",
    tabooWords: ["Kuvvet", "Hareket", "Enerji", "Bilim", "Newton"],
    category: "Bilim",
  ),
  WordCard(
    word: "BİYOLOJİ",
    tabooWords: ["Canlı", "Hücre", "Bilim", "İnsan", "Hayat"],
    category: "Bilim",
  ),
  WordCard(
    word: "DENEY",
    tabooWords: ["Laboratuvar", "Test", "Bilim", "Sonuç", "Araştırma"],
    category: "Bilim",
  ),
  WordCard(
    word: "LABORATUVAR",
    tabooWords: ["Deney", "Bilim", "Kimya", "Tüp", "Araştırma"],
    category: "Bilim",
  ),
  WordCard(
    word: "BAKTERİ",
    tabooWords: ["Mikrop", "Hastalık", "Mikroskop", "Küçük", "Canlı"],
    category: "Bilim",
  ),
  WordCard(
    word: "VİRÜS",
    tabooWords: ["Hastalık", "Bulaşıcı", "Mikrop", "Bağışıklık", "Enfeksiyon"],
    category: "Bilim",
  ),
  WordCard(
    word: "AŞI",
    tabooWords: ["Hastalık", "Koruma", "İğne", "Bağışıklık", "Virüs"],
    category: "Bilim",
  ),
  WordCard(
    word: "BAĞIŞIKLIK",
    tabooWords: ["Vücut", "Hastalık", "Savunma", "Aşı", "Koruma"],
    category: "Bilim",
  ),
  WordCard(
    word: "İNSAN VÜCUDU",
    tabooWords: ["Organ", "Kas", "Kemik", "Sistem", "Canlı"],
    category: "Bilim",
  ),
  WordCard(
    word: "BEYİN",
    tabooWords: ["Düşünmek", "Sinir", "Kafa", "Zeka", "Organ"],
    category: "Bilim",
  ),
  WordCard(
    word: "KALP",
    tabooWords: ["Kan", "Atmak", "Dolaşım", "Organ", "Göğüs"],
    category: "Bilim",
  ),
  WordCard(
    word: "KAN",
    tabooWords: ["Dolaşım", "Kırmızı", "Vücut", "Kalp", "Damar"],
    category: "Bilim",
  ),
  WordCard(
    word: "DAMAR",
    tabooWords: ["Kan", "Vücut", "Kalp", "Taşımak", "İç"],
    category: "Bilim",
  ),
  WordCard(
    word: "İSKELET",
    tabooWords: ["Kemik", "Vücut", "Destek", "İnsan", "Yapı"],
    category: "Bilim",
  ),
  WordCard(
    word: "KAS",
    tabooWords: ["Hareket", "Vücut", "Güç", "İnsan", "Çekmek"],
    category: "Bilim",
  ),
  WordCard(
    word: "SİNDİRİM",
    tabooWords: ["Mide", "Bağırsak", "Yemek", "Vücut", "Sistem"],
    category: "Bilim",
  ),
  WordCard(
    word: "SOLUNUM",
    tabooWords: ["Nefes", "Akciğer", "Oksijen", "Vücut", "Hava"],
    category: "Bilim",
  ),
  WordCard(
    word: "AKCİĞER",
    tabooWords: ["Nefes", "Solunum", "Oksijen", "Organ", "Göğüs"],
    category: "Bilim",
  ),
  WordCard(
    word: "UZAY",
    tabooWords: ["Evren", "Yıldız", "Gezegen", "Boşluk", "Astronomi"],
    category: "Bilim",
  ),
  WordCard(
    word: "GEZEGEN",
    tabooWords: ["Dünya", "Uzay", "Güneş", "Yörünge", "Astronomi"],
    category: "Bilim",
  ),
  WordCard(
    word: "GÜNEŞ",
    tabooWords: ["Yıldız", "Işık", "Isı", "Merkez", "Gündüz"],
    category: "Bilim",
  ),
  WordCard(
    word: "AY",
    tabooWords: ["Dünya", "Gece", "Uydu", "Yörünge", "Gökyüzü"],
    category: "Bilim",
  ),
  WordCard(
    word: "YILDIZ",
    tabooWords: ["Uzay", "Işık", "Güneş", "Gökyüzü", "Parlamak"],
    category: "Bilim",
  ),
  WordCard(
    word: "ASTRONOMİ",
    tabooWords: ["Uzay", "Gezegen", "Yıldız", "Bilim", "Teleskop"],
    category: "Bilim",
  ),
  WordCard(
    word: "EVRİM",
    tabooWords: ["Değişim", "Canlı", "Zaman", "Tür", "Bilim"],
    category: "Bilim",
  ),
  WordCard(
    word: "EKOSİSTEM",
    tabooWords: ["Canlı", "Doğa", "Denge", "Çevre", "Sistem"],
    category: "Bilim",
  ),
  WordCard(
    word: "İKLİM",
    tabooWords: ["Hava", "Uzun", "Sıcaklık", "Dünya", "Değişim"],
    category: "Bilim",
  ),
  WordCard(
    word: "HAVA",
    tabooWords: ["Nefes", "Atmosfer", "Gaz", "Rüzgar", "Oksijen"],
    category: "Bilim",
  ),
  WordCard(
    word: "SU",
    tabooWords: ["Sıvı", "İçmek", "Hayat", "Temel", "H2O"],
    category: "Bilim",
  ),
  WordCard(
    word: "KAYNAMA",
    tabooWords: ["Isı", "Su", "Sıcaklık", "Buhar", "Derece"],
    category: "Bilim",
  ),
  WordCard(
    word: "ERİME",
    tabooWords: ["Buz", "Isı", "Katı", "Sıvı", "Değişim"],
    category: "Bilim",
  ),
  WordCard(
    word: "YOĞUŞMA",
    tabooWords: ["Buhar", "Gaz", "Sıvı", "Soğuk", "Dönüşüm"],
    category: "Bilim",
  ),

  // Yemek Kategori
  WordCard(
    word: "MANTI",
    tabooWords: ["Hamur", "Kıyma", "Yoğurt", "Kayısı", "Susamak"],
    category: "Yemek",
  ),
  WordCard(
    word: "LAHMACUN",
    tabooWords: ["Hamur", "Kıyma", "Fırın", "İnce", "Acı"],
    category: "Yemek",
  ),
  WordCard(
    word: "BAKLAVA",
    tabooWords: ["Tatlı", "Şerbet", "Fıstık", "Hamur", "Tepsi"],
    category: "Yemek",
  ),
  WordCard(
    word: "KARNIYARIK",
    tabooWords: ["Patlıcan", "Kızartma", "Kıyma", "Tencere", "Yemek"],
    category: "Yemek",
  ),
  WordCard(
    word: "DÖNER",
    tabooWords: ["Et", "Şiş", "Ekmek", "Tavuk", "Dilim"],
    category: "Yemek",
  ),
  WordCard(
    word: "PİDE",
    tabooWords: ["Fırın", "Hamur", "Peynir", "Uzun", "Karadeniz"],
    category: "Yemek",
  ),
  WordCard(
    word: "KÖFTE",
    tabooWords: ["Kıyma", "Izgara", "Et", "Yuvarlak", "Ekmek"],
    category: "Yemek",
  ),
  WordCard(
    word: "İSKENDER",
    tabooWords: ["Döner", "Yoğurt", "Tereyağı", "Bursa", "Et"],
    category: "Yemek",
  ),
  WordCard(
    word: "MENEMEN",
    tabooWords: ["Yumurta", "Domates", "Biber", "Kahvaltı", "Tava"],
    category: "Yemek",
  ),
  WordCard(
    word: "PİLAV",
    tabooWords: ["Pirinç", "Tane", "Tereyağı", "Su", "Yan"],
    category: "Yemek",
  ),
  WordCard(
    word: "BÖREK",
    tabooWords: ["Yufka", "Peynir", "Fırın", "Kat", "Hamur"],
    category: "Yemek",
  ),
  WordCard(
    word: "GÖZLEME",
    tabooWords: ["Sac", "Yufka", "Peynir", "Katlamak", "Köy"],
    category: "Yemek",
  ),
  WordCard(
    word: "ÇORBA",
    tabooWords: ["Sıcak", "Kaşık", "Başlangıç", "Tencere", "Sıvı"],
    category: "Yemek",
  ),
  WordCard(
    word: "EZOGELİN",
    tabooWords: ["Çorba", "Mercimek", "Bulgur", "Kırmızı", "Sıcak"],
    category: "Yemek",
  ),
  WordCard(
    word: "TARHANA",
    tabooWords: ["Çorba", "Kurutmak", "Ekşi", "Kış", "Toz"],
    category: "Yemek",
  ),
  WordCard(
    word: "KURU FASULYE",
    tabooWords: ["Bakliyat", "Pilav", "Beyaz", "Tencere", "Yemek"],
    category: "Yemek",
  ),
  WordCard(
    word: "NOHUT",
    tabooWords: ["Bakliyat", "Yuvarlak", "Tencere", "Yemek", "Protein"],
    category: "Yemek",
  ),
  WordCard(
    word: "MERCİMEK",
    tabooWords: ["Bakliyat", "Kırmızı", "Çorba", "Sarı", "Tane"],
    category: "Yemek",
  ),
  WordCard(
    word: "İMAM BAYILDI",
    tabooWords: ["Patlıcan", "Zeytinyağı", "Soğuk", "Sebze", "Yemek"],
    category: "Yemek",
  ),
  WordCard(
    word: "SALATA",
    tabooWords: ["Yeşillik", "Çiğ", "Karıştırmak", "Limon", "Yan"],
    category: "Yemek",
  ),
  WordCard(
    word: "CACIK",
    tabooWords: ["Yoğurt", "Salatalık", "Sarımsak", "Soğuk", "Yaz"],
    category: "Yemek",
  ),
  WordCard(
    word: "AYRAN",
    tabooWords: ["Yoğurt", "Su", "Tuz", "İçmek", "Soğuk"],
    category: "Yemek",
  ),
  WordCard(
    word: "KEBAP",
    tabooWords: ["Et", "Şiş", "Izgara", "Acı", "Adana"],
    category: "Yemek",
  ),
  WordCard(
    word: "ADANA",
    tabooWords: ["Kebap", "Acı", "Şiş", "Et", "Urfa"],
    category: "Yemek",
  ),
  WordCard(
    word: "URFA",
    tabooWords: ["Kebap", "Acısız", "Et", "Şiş", "Adana"],
    category: "Yemek",
  ),
  WordCard(
    word: "SUCUK",
    tabooWords: ["Et", "Baharat", "Kahvaltı", "Kızartmak", "Sosis"],
    category: "Yemek",
  ),
  WordCard(
    word: "PASTIRMA",
    tabooWords: ["Et", "Kayseri", "Çemen", "Kurutmak", "Dilim"],
    category: "Yemek",
  ),
  WordCard(
    word: "OMLET",
    tabooWords: ["Yumurta", "Tava", "Kahvaltı", "Pişirmek", "Karıştırmak"],
    category: "Yemek",
  ),
  WordCard(
    word: "KAYMAK",
    tabooWords: ["Süt", "Kahvaltı", "Bal", "Yağlı", "Beyaz"],
    category: "Yemek",
  ),
  WordCard(
    word: "BAL",
    tabooWords: ["Arı", "Tatlı", "Kahvaltı", "Sarı", "Doğal"],
    category: "Yemek",
  ),
  WordCard(
    word: "PEYNİR",
    tabooWords: ["Süt", "Kahvaltı", "Beyaz", "Tuzlu", "Dil"],
    category: "Yemek",
  ),
  WordCard(
    word: "YOĞURT",
    tabooWords: ["Süt", "Beyaz", "Soğuk", "Kase", "Ekşi"],
    category: "Yemek",
  ),
  WordCard(
    word: "KAHVALTI",
    tabooWords: ["Sabah", "Yumurta", "Peynir", "Çay", "Masa"],
    category: "Yemek",
  ),
  WordCard(
    word: "ÇAY",
    tabooWords: ["Bardak", "Demlemek", "Sıcak", "Siyah", "İçmek"],
    category: "Yemek",
  ),
  WordCard(
    word: "KAHVE",
    tabooWords: ["Türk", "Fincan", "Kafein", "Telve", "İçmek"],
    category: "Yemek",
  ),
  WordCard(
    word: "LOKUM",
    tabooWords: ["Tatlı", "Şeker", "Yumuşak", "İkram", "Türk"],
    category: "Yemek",
  ),
  WordCard(
    word: "HELVA",
    tabooWords: ["Tatlı", "Un", "İrmik", "Kavurmak", "Şeker"],
    category: "Yemek",
  ),
  WordCard(
    word: "SÜTLAÇ",
    tabooWords: ["Tatlı", "Süt", "Pirinç", "Fırın", "Kase"],
    category: "Yemek",
  ),
  WordCard(
    word: "KAZANDİBİ",
    tabooWords: ["Tatlı", "Süt", "Yanık", "Muhallebi", "Tepsi"],
    category: "Yemek",
  ),
  WordCard(
    word: "DONDURMA",
    tabooWords: ["Soğuk", "Tatlı", "Yaz", "Külah", "Erimek"],
    category: "Yemek",
  ),
  WordCard(
    word: "WAFFLE",
    tabooWords: ["Tatlı", "Çikolata", "Meyve", "Hamur", "Kare"],
    category: "Yemek",
  ),
  WordCard(
    word: "PİZZA",
    tabooWords: ["Hamur", "Peynir", "Fırın", "Dilmek", "İtalyan"],
    category: "Yemek",
  ),
  WordCard(
    word: "HAMBURGER",
    tabooWords: ["Ekmek", "Köfte", "Fast food", "Sandviç", "Et"],
    category: "Yemek",
  ),
  WordCard(
    word: "MAKARNA",
    tabooWords: ["Hamur", "Haşlamak", "Sos", "Spagetti", "Tabak"],
    category: "Yemek",
  ),

  // Spor Kategori
  WordCard(
    word: "FUTBOL",
    tabooWords: ["Top", "Kale", "Gol", "Maç", "Saha"],
    category: "Spor",
  ),
  WordCard(
    word: "BASKETBOL",
    tabooWords: ["Potа", "Top", "Saha", "NBA", "Maç"],
    category: "Spor",
  ),
  WordCard(
    word: "VOLEYBOL",
    tabooWords: ["File", "Top", "Smaç", "Set", "Saha"],
    category: "Spor",
  ),
  WordCard(
    word: "TENİS",
    tabooWords: ["Raket", "Top", "Kort", "Servis", "Maç"],
    category: "Spor",
  ),
  WordCard(
    word: "MASA TENİSİ",
    tabooWords: ["Raket", "Top", "Masa", "File", "Pinpon"],
    category: "Spor",
  ),
  WordCard(
    word: "YÜZME",
    tabooWords: ["Havuz", "Deniz", "Su", "Kulaç", "Yüzmek"],
    category: "Spor",
  ),
  WordCard(
    word: "KOŞU",
    tabooWords: ["Atletizm", "Hız", "Parkur", "Nefes", "Ayak"],
    category: "Spor",
  ),
  WordCard(
    word: "ATLETİZM",
    tabooWords: ["Koşu", "Atlama", "Saha", "Olimpiyat", "Sporcu"],
    category: "Spor",
  ),
  WordCard(
    word: "HALTER",
    tabooWords: ["Ağırlık", "Kaldırmak", "Bar", "Güç", "Kas"],
    category: "Spor",
  ),
  WordCard(
    word: "BOKS",
    tabooWords: ["Ring", "Eldiven", "Yumruk", "Maç", "Sporcu"],
    category: "Spor",
  ),
  WordCard(
    word: "GÜREŞ",
    tabooWords: ["Pehlivan", "Kispet", "Yağlı", "Tutuş", "Minder"],
    category: "Spor",
  ),
  WordCard(
    word: "JUDO",
    tabooWords: ["Dövüş", "Rakip", "Atmak", "Minder", "Japon"],
    category: "Spor",
  ),
  WordCard(
    word: "KARATE",
    tabooWords: ["Dövüş", "Tekme", "Kata", "Japon", "Spor"],
    category: "Spor",
  ),
  WordCard(
    word: "FİTNESS",
    tabooWords: ["Spor salonu", "Ağırlık", "Egzersiz", "Kas", "Antrenman"],
    category: "Spor",
  ),
  WordCard(
    word: "VÜCUT GELİŞTİRME",
    tabooWords: ["Kas", "Ağırlık", "Fitness", "Protein", "Salon"],
    category: "Spor",
  ),
  WordCard(
    word: "KAYAK",
    tabooWords: ["Kar", "Dağ", "Pist", "Kış", "Kaymak"],
    category: "Spor",
  ),
  WordCard(
    word: "SNOWBOARD",
    tabooWords: ["Kar", "Tahta", "Kaymak", "Dağ", "Kış"],
    category: "Spor",
  ),
  WordCard(
    word: "BUZ PATENİ",
    tabooWords: ["Buz", "Kaymak", "Pist", "Ayak", "Soğuk"],
    category: "Spor",
  ),
  WordCard(
    word: "PATEN",
    tabooWords: ["Tekerlek", "Kaymak", "Ayak", "Kask", "Denge"],
    category: "Spor",
  ),
  WordCard(
    word: "BİSİKLET",
    tabooWords: ["Pedal", "İki teker", "Sürmek", "Kask", "Yol"],
    category: "Spor",
  ),
  WordCard(
    word: "DAĞCILIK",
    tabooWords: ["Tırmanmak", "Zirve", "İp", "Dağ", "Risk"],
    category: "Spor",
  ),
  WordCard(
    word: "OKÇULUK",
    tabooWords: ["Yay", "Ok", "Hedef", "Atmak", "Nişan"],
    category: "Spor",
  ),
  WordCard(
    word: "ESKRİM",
    tabooWords: ["Kılıç", "Maske", "Düello", "Puan", "Fransız"],
    category: "Spor",
  ),
  WordCard(
    word: "HENTBOL",
    tabooWords: ["Top", "Kale", "Takım", "Atmak", "Salon"],
    category: "Spor",
  ),
  WordCard(
    word: "SU TOPU",
    tabooWords: ["Havuz", "Top", "Kale", "Takım", "Yüzmek"],
    category: "Spor",
  ),
  WordCard(
    word: "DART",
    tabooWords: ["Ok", "Hedef", "Atmak", "Puan", "Tahta"],
    category: "Spor",
  ),
  WordCard(
    word: "BİLARDO",
    tabooWords: ["Top", "İstaka", "Masa", "Delik", "Vurmak"],
    category: "Spor",
  ),
  WordCard(
    word: "BOWLING",
    tabooWords: ["Top", "Pİn", "Salon", "Yuvarlamak", "Vurmak"],
    category: "Spor",
  ),
  WordCard(
    word: "GOLF",
    tabooWords: ["Sopa", "Top", "Çim", "Delik", "Vurmak"],
    category: "Spor",
  ),
  WordCard(
    word: "SÖRF",
    tabooWords: ["Dalga", "Deniz", "Tahta", "Kaymak", "Denge"],
    category: "Spor",
  ),
  WordCard(
    word: "YELKEN",
    tabooWords: ["Rüzgar", "Deniz", "Tekne", "Yarış", "Yelkenli"],
    category: "Spor",
  ),
  WordCard(
    word: "KANO",
    tabooWords: ["Kürek", "Su", "Tekne", "Nehir", "Spor"],
    category: "Spor",
  ),
  WordCard(
    word: "RAKET",
    tabooWords: ["Tenis", "Vurmak", "Top", "Sap", "File"],
    category: "Spor",
  ),
  WordCard(
    word: "HAKEM",
    tabooWords: ["Maç", "Kural", "Düdük", "Karar", "Yönetmek"],
    category: "Spor",
  ),
  WordCard(
    word: "ANTRENÖR",
    tabooWords: ["Takım", "Çalıştırmak", "Hoca", "Sporcu", "Maç"],
    category: "Spor",
  ),
  WordCard(
    word: "SPORCU",
    tabooWords: ["Antrenman", "Maç", "Takım", "Başarı", "Performans"],
    category: "Spor",
  ),
  WordCard(
    word: "OLİMPİYAT",
    tabooWords: ["Oyunlar", "Ülke", "Madalyа", "Dört yıl", "Spor"],
    category: "Spor",
  ),
  WordCard(
    word: "MADALYA",
    tabooWords: ["Altın", "Gümüş", "Bronz", "Kazanmak", "Boyun"],
    category: "Spor",
  ),
  WordCard(
    word: "REKOR",
    tabooWords: ["En iyi", "Derece", "Kırmak", "Başarı", "Zaman"],
    category: "Spor",
  ),
  WordCard(
    word: "PUAN",
    tabooWords: ["Skor", "Saymak", "Maç", "Kazanmak", "Sayı"],
    category: "Spor",
  ),
  WordCard(
    word: "SET",
    tabooWords: ["Voleybol", "Tenis", "Bölüm", "Maç", "Oyun"],
    category: "Spor",
  ),
  WordCard(
    word: "GOL",
    tabooWords: ["Futbol", "Kale", "Atmak", "Skor", "Top"],
    category: "Spor",
  ),

  // Doğa Kategori
  WordCard(
    word: "ORMAN",
    tabooWords: ["Ağaç", "Yeşil", "Yaprak", "Doğa", "Hayvan"],
    category: "Doğa",
  ),
  WordCard(
    word: "DENİZ",
    tabooWords: ["Su", "Tuzlu", "Dalga", "Plaj", "Mavi"],
    category: "Doğa",
  ),
  WordCard(
    word: "DAĞ",
    tabooWords: ["Yüksek", "Zirve", "Tırmanmak", "Kar", "Tepe"],
    category: "Doğa",
  ),
  WordCard(
    word: "GÖL",
    tabooWords: ["Su", "Durgun", "Tatlı", "Kıyı", "Balık"],
    category: "Doğa",
  ),
  WordCard(
    word: "NEHİR",
    tabooWords: ["Akmak", "Su", "Uzun", "Köprü", "Yatak"],
    category: "Doğa",
  ),
  WordCard(
    word: "ŞELALE",
    tabooWords: ["Su", "Yüksek", "Düşmek", "Akmak", "Gürültü"],
    category: "Doğa",
  ),
  WordCard(
    word: "VADİ",
    tabooWords: ["Dağ", "Arası", "Derin", "Nehir", "Doğa"],
    category: "Doğa",
  ),
  WordCard(
    word: "OVA",
    tabooWords: ["Düz", "Tarla", "Geniş", "Toprak", "Tarım"],
    category: "Doğa",
  ),
  WordCard(
    word: "PLAJ",
    tabooWords: ["Kum", "Deniz", "Güneş", "Şemsiye", "Yaz"],
    category: "Doğa",
  ),
  WordCard(
    word: "KUM",
    tabooWords: ["Plaj", "Sarı", "Tane", "Deniz", "Ayak"],
    category: "Doğa",
  ),
  WordCard(
    word: "TOPRAK",
    tabooWords: ["Çamur", "Tarla", "Bitki", "Yer", "Kahverengi"],
    category: "Doğa",
  ),
  WordCard(
    word: "AĞAÇ",
    tabooWords: ["Orman", "Gövde", "Dal", "Yaprak", "Yeşil"],
    category: "Doğa",
  ),
  WordCard(
    word: "YAPRAK",
    tabooWords: ["Ağaç", "Yeşil", "Sonbahar", "Dal", "Düşmek"],
    category: "Doğa",
  ),
  WordCard(
    word: "ÇİÇEK",
    tabooWords: ["Koku", "Renkli", "Bahar", "Bitki", "Açmak"],
    category: "Doğa",
  ),
  WordCard(
    word: "ÇİM",
    tabooWords: ["Yeşil", "Bahçe", "Zemin", "Kesmek", "Toprak"],
    category: "Doğa",
  ),
  WordCard(
    word: "YAĞMUR",
    tabooWords: ["Su", "Bulut", "Islanmak", "Şemsiye", "Hava"],
    category: "Doğa",
  ),
  WordCard(
    word: "KAR",
    tabooWords: ["Beyaz", "Soğuk", "Kış", "Yağmak", "Buz"],
    category: "Doğa",
  ),
  WordCard(
    word: "BUZ",
    tabooWords: ["Soğuk", "Donmak", "Kaygan", "Su", "Erimek"],
    category: "Doğa",
  ),
  WordCard(
    word: "RÜZGAR",
    tabooWords: ["Hava", "Esinti", "Fırtına", "Uçurmak", "Soğuk"],
    category: "Doğa",
  ),
  WordCard(
    word: "FIRTINA",
    tabooWords: ["Rüzgar", "Yağmur", "Şiddetli", "Hava", "Dalga"],
    category: "Doğa",
  ),
  WordCard(
    word: "GÖK GÜRÜLTÜSÜ",
    tabooWords: ["Şimşek", "Ses", "Fırtına", "Korku", "Bulut"],
    category: "Doğa",
  ),
  WordCard(
    word: "ŞİMŞEK",
    tabooWords: ["Işık", "Gök", "Fırtına", "Çakmak", "Bulut"],
    category: "Doğa",
  ),
  WordCard(
    word: "BULUT",
    tabooWords: ["Gökyüzü", "Beyaz", "Yağmur", "Hava", "Uçmak"],
    category: "Doğa",
  ),
  WordCard(
    word: "GÜNEŞ",
    tabooWords: ["Sıcak", "Işık", "Gündüz", "Gökyüzü", "Yıldız"],
    category: "Doğa",
  ),
  WordCard(
    word: "AY",
    tabooWords: ["Gece", "Uydu", "Gökyüzü", "Dünya", "Yuvarlak"],
    category: "Doğa",
  ),
  WordCard(
    word: "YILDIZ",
    tabooWords: ["Gökyüzü", "Gece", "Parlak", "Uzay", "Işık"],
    category: "Doğa",
  ),
  WordCard(
    word: "GÖKKUŞAĞI",
    tabooWords: ["Renk", "Yağmur", "Güneş", "Yedi", "Gökyüzü"],
    category: "Doğa",
  ),
  WordCard(
    word: "ÇÖL",
    tabooWords: ["Kum", "Sıcak", "Kurak", "Az", "Su"],
    category: "Doğa",
  ),
  WordCard(
    word: "BATAKLIK",
    tabooWords: ["Çamur", "Su", "Sinek", "Yumuşak", "Toprak"],
    category: "Doğa",
  ),
  WordCard(
    word: "MAĞARA",
    tabooWords: ["Karanlık", "Taş", "Yer altı", "Soğuk", "Derin"],
    category: "Doğa",
  ),
  WordCard(
    word: "KAYA",
    tabooWords: ["Taş", "Sert", "Dağ", "Büyük", "Ağır"],
    category: "Doğa",
  ),
  WordCard(
    word: "TAŞ",
    tabooWords: ["Sert", "Küçük", "Atmak", "Yer", "Doğa"],
    category: "Doğa",
  ),
  WordCard(
    word: "VOLKAN",
    tabooWords: ["Lav", "Yanardağ", "Patlamak", "Ateş", "Dağ"],
    category: "Doğa",
  ),
  WordCard(
    word: "LAV",
    tabooWords: ["Volkan", "Sıcak", "Akmak", "Ateş", "Kırmızı"],
    category: "Doğa",
  ),
  WordCard(
    word: "ORMAN YANGINI",
    tabooWords: ["Ateş", "Duman", "Ağaç", "Yanmak", "Felaket"],
    category: "Doğa",
  ),
  WordCard(
    word: "DOĞA",
    tabooWords: ["Çevre", "Orman", "Deniz", "Hayvan", "Dünya"],
    category: "Doğa",
  ),
  WordCard(
    word: "EKOSİSTEM",
    tabooWords: ["Canlı", "Denge", "Doğa", "Çevre", "Sistem"],
    category: "Doğa",
  ),
  WordCard(
    word: "MEVSİM",
    tabooWords: ["Yaz", "Kış", "Sonbahar", "İlkbahar", "Zaman"],
    category: "Doğa",
  ),
  WordCard(
    word: "YAZ",
    tabooWords: ["Sıcak", "Deniz", "Tatil", "Güneş", "Mevsim"],
    category: "Doğa",
  ),
  WordCard(
    word: "KIŞ",
    tabooWords: ["Soğuk", "Kar", "Mont", "Mevsim", "Buz"],
    category: "Doğa",
  ),
  WordCard(
    word: "SONBAHAR",
    tabooWords: ["Yaprak", "Sarı", "Serin", "Mevsim", "Dökülmek"],
    category: "Doğa",
  ),
  WordCard(
    word: "İLKBAHAR",
    tabooWords: ["Bahar", "Çiçek", "Yağmur", "Mevsim", "Yeşil"],
    category: "Doğa",
  ),
  WordCard(
    word: "HAYVAN",
    tabooWords: ["Canlı", "Doğa", "Vahşi", "Tür", "Yaşamak"],
    category: "Doğa",
  ),
  WordCard(
    word: "VAHŞİ YAŞAM",
    tabooWords: ["Hayvan", "Doğa", "Orman", "Serbest", "Doğal"],
    category: "Doğa",
  ),

  // Teknoloji Kategori
  WordCard(
    word: "BİLGİSAYAR",
    tabooWords: ["Ekran", "Klavye", "Fare", "Program", "İnternet"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "AKILLI TELEFON",
    tabooWords: ["Dokunmatik", "İphone", "Android", "Cep", "Kamera"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "İNTERNET",
    tabooWords: ["Bağlantı", "Web", "Online", "WiFi", "Ağ"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "WI-FI",
    tabooWords: ["Kablosuz", "İnternet", "Modem", "Bağlanmak", "Ağ"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "MODEM",
    tabooWords: ["İnternet", "WiFi", "Bağlantı", "Işık", "Kutu"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "YAZILIM",
    tabooWords: ["Kod", "Program", "Bilgisayar", "Uygulama", "Geliştirme"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "DONANIM",
    tabooWords: ["Parça", "Bilgisayar", "Fiziksel", "Ekran", "Klavye"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "UYGULAMA",
    tabooWords: ["Telefon", "Program", "İndirmek", "Mobil", "App"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "OYUN",
    tabooWords: ["Oynamak", "Konsol", "Bilgisayar", "Eğlence", "Skor"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "KONSOL",
    tabooWords: ["Oyun", "PlayStation", "Xbox", "Kontrolcü", "Televizyon"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "SUNUCU",
    tabooWords: ["Server", "Veri", "İnternet", "Bağlantı", "Depolama"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "BULUT",
    tabooWords: ["Depolama", "Online", "Veri", "Sunucu", "İnternet"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "VERİ",
    tabooWords: ["Bilgi", "Dosya", "Depolamak", "Sayısal", "Bilgisayar"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "DOSYA",
    tabooWords: ["Belge", "Kaydetmek", "Bilgisayar", "Klasör", "Veri"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "KLASÖR",
    tabooWords: ["Dosya", "Düzen", "Bilgisayar", "İç", "Saklamak"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "E-POSTA",
    tabooWords: ["Mail", "Mesaj", "Göndermek", "İnternet", "Adres"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "TARAYICI",
    tabooWords: ["Chrome", "Web", "İnternet", "Site", "Açmak"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "ARAMA MOTORU",
    tabooWords: ["Google", "İnternet", "Bulmak", "Site", "Yazmak"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "YAPAY ZEKA",
    tabooWords: ["Makine", "Öğrenme", "Algoritma", "Bilgisayar", "Akıl"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "ROBOT",
    tabooWords: ["Makine", "Otomatik", "Metal", "Program", "Yapay"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "ALGORİTMA",
    tabooWords: ["Adım", "Kod", "Çözüm", "Mantık", "Program"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "KOD",
    tabooWords: ["Yazmak", "Program", "Bilgisayar", "Dil", "Yazılım"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "PROGRAMLAMA",
    tabooWords: ["Kod", "Yazılım", "Bilgisayar", "Dil", "Geliştirme"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "HATA",
    tabooWords: ["Bug", "Sorun", "Kod", "Çalışmamak", "Düzeltmek"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "GÜNCELLEME",
    tabooWords: ["Yeni", "Versiyon", "Yazılım", "İndirmek", "Değişiklik"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "ŞARJ",
    tabooWords: ["Pil", "Dolmak", "Kablo", "Elektrik", "Batarya"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "BATARYA",
    tabooWords: ["Pil", "Enerji", "Şarj", "Telefon", "Dolmak"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "EKRAN",
    tabooWords: ["Görüntü", "Dokunmak", "Işık", "Telefon", "Bilgisayar"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "KLAVYE",
    tabooWords: ["Tuş", "Yazmak", "Bilgisayar", "Harf", "Giriş"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "FARE",
    tabooWords: ["Tıklamak", "İmleç", "Bilgisayar", "El", "Kablo"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "USB",
    tabooWords: ["Kablo", "Takmak", "Bağlamak", "Dosya", "Port"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "BLUETOOTH",
    tabooWords: ["Kablosuz", "Bağlantı", "Kulaklık", "Telefon", "Açmak"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "KULAKLIK",
    tabooWords: ["Ses", "Müzik", "Takmak", "Bluetooth", "Kablo"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "HOPARLÖR",
    tabooWords: ["Ses", "Müzik", "Yüksek", "Dinlemek", "Cihaz"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "KAMERA",
    tabooWords: ["Fotoğraf", "Video", "Çekmek", "Lens", "Görüntü"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "DRONE",
    tabooWords: ["Uçmak", "Kamera", "Uzaktan", "Hava", "Kontrol"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "NAVİGASYON",
    tabooWords: ["Harita", "Yol", "GPS", "Bulmak", "Gitmek"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "GPS",
    tabooWords: ["Konum", "Uydu", "Harita", "Telefon", "Bulmak"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "SOSYAL MEDYA",
    tabooWords: ["Paylaşmak", "İnternet", "Takip", "Uygulama", "Fotoğraf"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "ŞİFRE",
    tabooWords: ["Gizli", "Güvenlik", "Giriş", "Hesap", "Kod"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "GÜVENLİK",
    tabooWords: ["Koruma", "Şifre", "Veri", "Tehlike", "Sistem"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "VİRÜS",
    tabooWords: ["Zarar", "Bilgisayar", "Program", "Silmek", "Tehdit"],
    category: "Teknoloji",
  ),

  // Tarih Kategori
  WordCard(
    word: "ATATÜRK",
    tabooWords: ["Cumhuriyet", "Mustafa Kemal", "Türkiye", "Lider", "Kurtuluş"],
    category: "Tarih",
  ),
  WordCard(
    word: "CUMHURİYET",
    tabooWords: ["Atatürk", "Devlet", "Yönetim", "Türkiye", "1923"],
    category: "Tarih",
  ),
  WordCard(
    word: "OSMANLI",
    tabooWords: ["İmparatorluk", "Padişah", "Devlet", "Tarih", "İstanbul"],
    category: "Tarih",
  ),
  WordCard(
    word: "İSTANBUL'UN FETHİ",
    tabooWords: ["1453", "Fatih", "Savaş", "Bizans", "İstanbul"],
    category: "Tarih",
  ),
  WordCard(
    word: "FATİH SULTAN MEHMET",
    tabooWords: ["İstanbul", "Fetih", "Osmanlı", "Padişah", "1453"],
    category: "Tarih",
  ),
  WordCard(
    word: "PADİŞAH",
    tabooWords: ["Osmanlı", "Taht", "Saray", "Hükümdar", "Devlet"],
    category: "Tarih",
  ),
  WordCard(
    word: "SULTAN",
    tabooWords: ["Padişah", "Osmanlı", "Hükümdar", "Taht", "Devlet"],
    category: "Tarih",
  ),
  WordCard(
    word: "SARAY",
    tabooWords: ["Padişah", "Osmanlı", "Yaşam", "Bina", "Taht"],
    category: "Tarih",
  ),
  WordCard(
    word: "TOPKAPI SARAYI",
    tabooWords: ["İstanbul", "Osmanlı", "Padişah", "Saray", "Müze"],
    category: "Tarih",
  ),
  WordCard(
    word: "KURTULUŞ SAVAŞI",
    tabooWords: ["Atatürk", "Savaş", "Türkiye", "Bağımsızlık", "Yunan"],
    category: "Tarih",
  ),
  WordCard(
    word: "ANAYASA",
    tabooWords: ["Kanun", "Devlet", "Hak", "Yasa", "Madde"],
    category: "Tarih",
  ),
  WordCard(
    word: "MECLİS",
    tabooWords: ["TBMM", "Milletvekili", "Yasa", "Toplantı", "Devlet"],
    category: "Tarih",
  ),
  WordCard(
    word: "TBMM",
    tabooWords: ["Meclis", "Ankara", "Yasa", "Millet", "Devlet"],
    category: "Tarih",
  ),
  WordCard(
    word: "ANKARA",
    tabooWords: ["Başkent", "Türkiye", "Meclis", "Atatürk", "Şehir"],
    category: "Tarih",
  ),
  WordCard(
    word: "İMPARATORLUK",
    tabooWords: ["Devlet", "Büyük", "Toprak", "Yönetim", "Osmanlı"],
    category: "Tarih",
  ),
  WordCard(
    word: "KRAL",
    tabooWords: ["Taht", "Krallık", "Hükümdar", "Taç", "Yönetmek"],
    category: "Tarih",
  ),
  WordCard(
    word: "KRALİÇE",
    tabooWords: ["Taht", "Krallık", "Kadın", "Taç", "Yönetmek"],
    category: "Tarih",
  ),
  WordCard(
    word: "SAVAŞ",
    tabooWords: ["Ordu", "Silah", "Çatışma", "Cephe", "Tarih"],
    category: "Tarih",
  ),
  WordCard(
    word: "ORDU",
    tabooWords: ["Asker", "Savaş", "Silah", "Cephe", "Birlik"],
    category: "Tarih",
  ),
  WordCard(
    word: "ASKER",
    tabooWords: ["Ordu", "Silah", "Savaş", "Üniforma", "Görev"],
    category: "Tarih",
  ),
  WordCard(
    word: "CEPHE",
    tabooWords: ["Savaş", "Asker", "Hat", "Mücadele", "Alan"],
    category: "Tarih",
  ),
  WordCard(
    word: "ANTLAŞMA",
    tabooWords: ["İmza", "Barış", "Devlet", "Savaş", "Anlaşmak"],
    category: "Tarih",
  ),
  WordCard(
    word: "LOZAN",
    tabooWords: ["Antlaşma", "Türkiye", "1923", "Barış", "Sınır"],
    category: "Tarih",
  ),
  WordCard(
    word: "SEVR",
    tabooWords: ["Antlaşma", "Osmanlı", "Parçalanmak", "Savaş", "Red"],
    category: "Tarih",
  ),
  WordCard(
    word: "FETİH",
    tabooWords: ["Almak", "Savaş", "Toprak", "Zafer", "Ordu"],
    category: "Tarih",
  ),
  WordCard(
    word: "ZAFER",
    tabooWords: ["Kazanmak", "Savaş", "Başarı", "Ordu", "Kutlama"],
    category: "Tarih",
  ),
  WordCard(
    word: "TAHT",
    tabooWords: ["Padişah", "Kral", "Oturmak", "Yönetmek", "Saray"],
    category: "Tarih",
  ),
  WordCard(
    word: "TAÇ",
    tabooWords: ["Kral", "Kraliçe", "Baş", "Altın", "Sembol"],
    category: "Tarih",
  ),
  WordCard(
    word: "YAZIT",
    tabooWords: ["Taş", "Tarih", "Eski", "Yazı", "Anıt"],
    category: "Tarih",
  ),
  WordCard(
    word: "ANIT",
    tabooWords: ["Heykel", "Tarih", "Yapı", "Hatıra", "Taş"],
    category: "Tarih",
  ),
  WordCard(
    word: "MÜZE",
    tabooWords: ["Tarih", "Eser", "Sergi", "Gezmek", "Bina"],
    category: "Tarih",
  ),
  WordCard(
    word: "ESKİ ÇAĞ",
    tabooWords: ["Tarih", "Antik", "İlk", "Uygarlık", "Dönem"],
    category: "Tarih",
  ),
  WordCard(
    word: "ORTA ÇAĞ",
    tabooWords: ["Tarih", "Şövalye", "Kale", "Karanlık", "Dönem"],
    category: "Tarih",
  ),
  WordCard(
    word: "YENİ ÇAĞ",
    tabooWords: ["Tarih", "Keşif", "Rönesans", "Dönem", "Başlangıç"],
    category: "Tarih",
  ),
  WordCard(
    word: "RÖNESANS",
    tabooWords: ["Avrupa", "Sanat", "Yeniden", "Tarih", "Dönem"],
    category: "Tarih",
  ),
  WordCard(
    word: "REFORM",
    tabooWords: ["Din", "Değişim", "Avrupa", "Kilise", "Tarih"],
    category: "Tarih",
  ),
  WordCard(
    word: "UYGARLIK",
    tabooWords: ["Medeniyet", "Toplum", "Tarih", "Kültür", "Eski"],
    category: "Tarih",
  ),
  WordCard(
    word: "MEDENİYET",
    tabooWords: ["Uygarlık", "Toplum", "Kültür", "Tarih", "Gelişmiş"],
    category: "Tarih",
  ),
  WordCard(
    word: "YAZI",
    tabooWords: ["Harf", "Tarih", "İlk", "Tablet", "İletişim"],
    category: "Tarih",
  ),
  WordCard(
    word: "TAKVİM",
    tabooWords: ["Zaman", "Gün", "Ay", "Yıl", "Tarih"],
    category: "Tarih",
  ),
  WordCard(
    word: "KRONOLOJİ",
    tabooWords: ["Sıra", "Zaman", "Tarih", "Olay", "Dizmek"],
    category: "Tarih",
  ),
  WordCard(
    word: "DESTAN",
    tabooWords: ["Hikâye", "Kahraman", "Eski", "Sözlü", "Tarih"],
    category: "Tarih",
  ),
  WordCard(
    word: "KİTABE",
    tabooWords: ["Yazı", "Taş", "Tarih", "Anıt", "Eski"],
    category: "Tarih",
  ),
];

final List<WordCard> initialDeckEn = [
  // General Category
  WordCard(
    word: "WATCH",
    tabooWords: ["Time", "Minute", "Second", "Wrist", "Hour"],
    category: "Genel",
  ),
  WordCard(
    word: "KEY",
    tabooWords: ["Door", "Lock", "Open", "House", "Enter"],
    category: "Genel",
  ),
  WordCard(
    word: "PILLOW",
    tabooWords: ["Sleep", "Bed", "Head", "Soft", "Night"],
    category: "Genel",
  ),
  WordCard(
    word: "MIRROR",
    tabooWords: ["Look", "See", "Glass", "Face", "Reflection"],
    category: "Genel",
  ),
  WordCard(
    word: "BAG",
    tabooWords: ["Carry", "School", "Shoulder", "Back", "Stuff"],
    category: "Genel",
  ),
  WordCard(
    word: "UMBRELLA",
    tabooWords: ["Rain", "Wet", "Open", "Weather", "Protect"],
    category: "Genel",
  ),
  WordCard(
    word: "STAIRS",
    tabooWords: ["Step", "Up", "Down", "Floor", "Building"],
    category: "Genel",
  ),
  WordCard(
    word: "LID",
    tabooWords: ["Close", "Bottle", "Box", "Open", "Top"],
    category: "Genel",
  ),
  WordCard(
    word: "DUVET",
    tabooWords: ["Sleep", "Bed", "Warm", "Night", "Cover"],
    category: "Genel",
  ),
  WordCard(
    word: "BRUSH",
    tabooWords: ["Hair", "Comb", "Paint", "Tooth", "Bristle"],
    category: "Genel",
  ),
  WordCard(
    word: "PLATE",
    tabooWords: ["Food", "Kitchen", "Serve", "Glass", "Porcelain"],
    category: "Genel",
  ),
  WordCard(
    word: "SPOON",
    tabooWords: ["Fork", "Food", "Soup", "Metal", "Mouth"],
    category: "Genel",
  ),
  WordCard(
    word: "CURTAIN",
    tabooWords: ["Window", "Sun", "Close", "Sheer", "Home"],
    category: "Genel",
  ),
  WordCard(
    word: "CARPET",
    tabooWords: ["Floor", "Home", "Pattern", "Kilim", "Lay"],
    category: "Genel",
  ),
  WordCard(
    word: "CABINET",
    tabooWords: ["Clothes", "Door", "Kitchen", "Shelf", "Store"],
    category: "Genel",
  ),
  WordCard(
    word: "PILLOWCASE",
    tabooWords: ["Fabric", "Sleep", "Bed", "Cover", "Head"],
    category: "Genel",
  ),
  WordCard(
    word: "REMOTE",
    tabooWords: ["TV", "Button", "Battery", "Channel", "Change"],
    category: "Genel",
  ),
  WordCard(
    word: "LAMP",
    tabooWords: ["Light", "Lighting", "Bulb", "Night", "Electricity"],
    category: "Genel",
  ),
  WordCard(
    word: "OUTLET",
    tabooWords: ["Electricity", "Plug", "Wall", "Charge", "Current"],
    category: "Genel",
  ),
  WordCard(
    word: "NOTEBOOK",
    tabooWords: ["Write", "School", "Page", "Pen", "Note"],
    category: "Genel",
  ),
  WordCard(
    word: "CHAIR",
    tabooWords: ["Sit", "Table", "Wood", "Leg", "Home"],
    category: "Genel",
  ),
  WordCard(
    word: "TABLE",
    tabooWords: ["Eat", "Work", "Leg", "Top", "Furniture"],
    category: "Genel",
  ),
  WordCard(
    word: "BLANKET",
    tabooWords: ["Cold", "Cover", "Bed", "Warm", "Fabric"],
    category: "Genel",
  ),
  WordCard(
    word: "DRAWER",
    tabooWords: ["Cabinet", "Open", "Close", "Store", "Furniture"],
    category: "Genel",
  ),
  WordCard(
    word: "OVEN",
    tabooWords: ["Food", "Heat", "Kitchen", "Bake", "Electricity"],
    category: "Genel",
  ),
  WordCard(
    word: "VACUUM",
    tabooWords: ["Cleaning", "Electricity", "Dust", "Carpet", "Home"],
    category: "Genel",
  ),
  WordCard(
    word: "TRAY",
    tabooWords: ["Food", "Oven", "Metal", "Carry", "Kitchen"],
    category: "Genel",
  ),
  WordCard(
    word: "CUSHION",
    tabooWords: ["Sit", "Soft", "Floor", "Sofa", "Home"],
    category: "Genel",
  ),
  WordCard(
    word: "ALARM CLOCK",
    tabooWords: ["Wake Up", "Morning", "Bell", "Ring", "Time"],
    category: "Genel",
  ),
  WordCard(
    word: "LOCK",
    tabooWords: ["Key", "Door", "Security", "Open", "Close"],
    category: "Genel",
  ),
  WordCard(
    word: "WINDOW",
    tabooWords: ["Glass", "Curtain", "Open", "Home", "Light"],
    category: "Genel",
  ),
  WordCard(
    word: "SOFA",
    tabooWords: ["Sit", "Living Room", "Comfort", "Furniture", "Home"],
    category: "Genel",
  ),
  WordCard(
    word: "TOWEL",
    tabooWords: ["Bathroom", "Dry", "Water", "Fabric", "Hand"],
    category: "Genel",
  ),
  WordCard(
    word: "SOAP",
    tabooWords: ["Wash", "Foam", "Cleaning", "Bathroom", "Hand"],
    category: "Genel",
  ),
  WordCard(
    word: "TOOTHBRUSH",
    tabooWords: ["Tooth", "Paste", "Mouth", "Cleaning", "Bathroom"],
    category: "Genel",
  ),
  WordCard(
    word: "SUITCASE",
    tabooWords: ["Travel", "Luggage", "Clothes", "Carry", "Trip"],
    category: "Genel",
  ),
  WordCard(
    word: "TRASH CAN",
    tabooWords: ["Throw", "Trash", "Cleaning", "Home", "Bag"],
    category: "Genel",
  ),
  WordCard(
    word: "NOTEPAD",
    tabooWords: ["Write", "Small", "Carry", "Page", "Pen"],
    category: "Genel",
  ),
  WordCard(
    word: "SLIPPERS",
    tabooWords: ["Home", "Foot", "Comfort", "Wear", "Inside"],
    category: "Genel",
  ),
  WordCard(
    word: "CHARGER",
    tabooWords: ["Phone", "Battery", "Electricity", "Cable", "Fill"],
    category: "Genel",
  ),
  WordCard(
    word: "GLASS DOME",
    tabooWords: ["Glass", "Protect", "Top", "Cover", "Clear"],
    category: "Genel",
  ),
  WordCard(
    word: "CALENDAR",
    tabooWords: ["Day", "Month", "Year", "Date", "Time"],
    category: "Genel",
  ),
  WordCard(
    word: "BOX",
    tabooWords: ["Put", "Lid", "Store", "Cardboard", "Inside"],
    category: "Genel",
  ),
  WordCard(
    word: "CLOTHESPIN",
    tabooWords: ["Laundry", "Hang", "Balcony", "Clip", "Line"],
    category: "Genel",
  ),
  WordCard(
    word: "LIGHTER",
    tabooWords: ["Fire", "Light", "Cigarette", "Gas", "Hand"],
    category: "Genel",
  ),

  // Art Category
  WordCard(
    word: "MONA LISA",
    tabooWords: ["Painting", "Leonardo", "Smile", "Art", "Louvre"],
    category: "Sanat",
  ),
  WordCard(
    word: "PICASSO",
    tabooWords: ["Painter", "Cubism", "Painting", "Spain", "Modern"],
    category: "Sanat",
  ),
  WordCard(
    word: "VAN GOGH",
    tabooWords: ["Painter", "Ear", "Starry", "Netherlands", "Painting"],
    category: "Sanat",
  ),
  WordCard(
    word: "SCULPTURE",
    tabooWords: ["Stone", "Bronze", "Carve", "Figure", "Artist"],
    category: "Sanat",
  ),
  WordCard(
    word: "THEATER",
    tabooWords: ["Stage", "Actor", "Curtain", "Play", "Hall"],
    category: "Sanat",
  ),
  WordCard(
    word: "OPERA",
    tabooWords: ["Singing", "Stage", "Classical", "Voice", "Performance"],
    category: "Sanat",
  ),
  WordCard(
    word: "BALLET",
    tabooWords: ["Dance", "Tutu", "Stage", "Music", "Graceful"],
    category: "Sanat",
  ),
  WordCard(
    word: "PAINTING",
    tabooWords: ["Paint", "Canvas", "Brush", "Color", "Picture"],
    category: "Sanat",
  ),
  WordCard(
    word: "PORTRAIT",
    tabooWords: ["Face", "Painting", "Person", "Picture", "Draw"],
    category: "Sanat",
  ),
  WordCard(
    word: "LANDSCAPE",
    tabooWords: ["Nature", "Painting", "Mountain", "Sea", "Picture"],
    category: "Sanat",
  ),
  WordCard(
    word: "ABSTRACT",
    tabooWords: ["Shape", "Modern", "Painting", "Color", "Nonfigurative"],
    category: "Sanat",
  ),
  WordCard(
    word: "CARICATURE",
    tabooWords: ["Drawing", "Humor", "Exaggeration", "Newspaper", "Funny"],
    category: "Sanat",
  ),
  WordCard(
    word: "GRAFFITI",
    tabooWords: ["Wall", "Spray", "Street", "Writing", "Drawing"],
    category: "Sanat",
  ),
  WordCard(
    word: "PHOTOGRAPH",
    tabooWords: ["Camera", "Shoot", "Image", "Light", "Frame"],
    category: "Sanat",
  ),
  WordCard(
    word: "CINEMA",
    tabooWords: ["Movie", "Hall", "Screen", "Actor", "Director"],
    category: "Sanat",
  ),
  WordCard(
    word: "DIRECTOR",
    tabooWords: ["Movie", "Camera", "Set", "Cinema", "Actor"],
    category: "Sanat",
  ),
  WordCard(
    word: "SCREENPLAY",
    tabooWords: ["Film", "Writing", "Story", "Scene", "Script"],
    category: "Sanat",
  ),
  WordCard(
    word: "CAMERA",
    tabooWords: ["Shoot", "Video", "Photo", "Lens", "Film"],
    category: "Sanat",
  ),
  WordCard(
    word: "NOVEL",
    tabooWords: ["Book", "Author", "Story", "Page", "Fiction"],
    category: "Sanat",
  ),
  WordCard(
    word: "POEM",
    tabooWords: ["Verse", "Poet", "Short", "Emotion", "Writing"],
    category: "Sanat",
  ),
  WordCard(
    word: "POET",
    tabooWords: ["Poem", "Write", "Verse", "Literature", "Pen"],
    category: "Sanat",
  ),
  WordCard(
    word: "COMPOSER",
    tabooWords: ["Music", "Note", "Write", "Classical", "Piece"],
    category: "Sanat",
  ),
  WordCard(
    word: "ORCHESTRA",
    tabooWords: ["Music", "Instrument", "Conductor", "Concert", "Group"],
    category: "Sanat",
  ),
  WordCard(
    word: "CONCERT",
    tabooWords: ["Music", "Stage", "Live", "Listen", "Crowd"],
    category: "Sanat",
  ),
  WordCard(
    word: "INSTRUMENT",
    tabooWords: ["Music", "Play", "Sound", "Note", "Tool"],
    category: "Sanat",
  ),
  WordCard(
    word: "GUITAR",
    tabooWords: ["String", "Play", "Music", "Acoustic", "Electric"],
    category: "Sanat",
  ),
  WordCard(
    word: "VIOLIN",
    tabooWords: ["Bow", "String", "Music", "Play", "Classical"],
    category: "Sanat",
  ),
  WordCard(
    word: "PIANO",
    tabooWords: ["Key", "Music", "Play", "Note", "Grand"],
    category: "Sanat",
  ),
  WordCard(
    word: "NOTE",
    tabooWords: ["Music", "Writing", "Sound", "Paper", "Play"],
    category: "Sanat",
  ),
  WordCard(
    word: "EXHIBITION",
    tabooWords: ["Art", "Gallery", "Work", "Visit", "Painting"],
    category: "Sanat",
  ),
  WordCard(
    word: "GALLERY",
    tabooWords: ["Exhibition", "Painting", "Art", "Hall", "Wall"],
    category: "Sanat",
  ),
  WordCard(
    word: "MUSEUM",
    tabooWords: ["History", "Artifact", "Exhibition", "Visit", "Building"],
    category: "Sanat",
  ),
  WordCard(
    word: "COSTUME",
    tabooWords: ["Clothing", "Stage", "Role", "Theater", "Film"],
    category: "Sanat",
  ),
  WordCard(
    word: "SET DESIGN",
    tabooWords: ["Stage", "Background", "Theater", "Film", "Location"],
    category: "Sanat",
  ),
  WordCard(
    word: "MAKEUP",
    tabooWords: ["Face", "Stage", "Actor", "Cosmetics", "Prep"],
    category: "Sanat",
  ),
  WordCard(
    word: "EDITING",
    tabooWords: ["Film", "Cut", "Montage", "Scene", "Video"],
    category: "Sanat",
  ),
  WordCard(
    word: "MONTAGE",
    tabooWords: ["Video", "Cut", "Film", "Editing", "Computer"],
    category: "Sanat",
  ),
  WordCard(
    word: "ADVERTISEMENT",
    tabooWords: ["Promotion", "Film", "Wall", "Poster", "Ad"],
    category: "Sanat",
  ),
  WordCard(
    word: "POSTER",
    tabooWords: ["Wall", "Movie", "Picture", "Hang", "Large"],
    category: "Sanat",
  ),
  WordCard(
    word: "CARTOON",
    tabooWords: ["Animation", "Kids", "Character", "TV", "Voice"],
    category: "Sanat",
  ),
  WordCard(
    word: "ANIMATION",
    tabooWords: ["Drawing", "Motion", "Film", "Character", "Computer"],
    category: "Sanat",
  ),
  WordCard(
    word: "COMEDY",
    tabooWords: ["Funny", "Laugh", "Movie", "Humor", "Genre"],
    category: "Sanat",
  ),
  WordCard(
    word: "DRAMA",
    tabooWords: ["Film", "Emotion", "Cry", "Genre", "Story"],
    category: "Sanat",
  ),
  WordCard(
    word: "CLASSICAL MUSIC",
    tabooWords: ["Orchestra", "Composer", "Note", "Concert", "Old"],
    category: "Sanat",
  ),
  WordCard(
    word: "MODERN ART",
    tabooWords: ["Abstract", "Contemporary", "Gallery", "Meaning", "New"],
    category: "Sanat",
  ),

  // Science Category
  WordCard(
    word: "ATOM",
    tabooWords: ["Particle", "Nucleus", "Electron", "Physics", "Matter"],
    category: "Bilim",
  ),
  WordCard(
    word: "CELL",
    tabooWords: ["Living", "Microscope", "DNA", "Biology", "Nucleus"],
    category: "Bilim",
  ),
  WordCard(
    word: "DNA",
    tabooWords: ["Gene", "Heredity", "Cell", "Biology", "Code"],
    category: "Bilim",
  ),
  WordCard(
    word: "GENE",
    tabooWords: ["DNA", "Heredity", "Mother", "Father", "Trait"],
    category: "Bilim",
  ),
  WordCard(
    word: "MICROSCOPE",
    tabooWords: ["Tiny", "Lens", "Laboratory", "Bacteria", "See"],
    category: "Bilim",
  ),
  WordCard(
    word: "TELESCOPE",
    tabooWords: ["Space", "Star", "Planet", "Look", "Observe"],
    category: "Bilim",
  ),
  WordCard(
    word: "ENERGY",
    tabooWords: ["Power", "Electricity", "Motion", "Heat", "Source"],
    category: "Bilim",
  ),
  WordCard(
    word: "LIGHT",
    tabooWords: ["See", "Speed", "Wave", "Dark", "Sun"],
    category: "Bilim",
  ),
  WordCard(
    word: "SOUND",
    tabooWords: ["Wave", "Hear", "Vibration", "Ear", "Noise"],
    category: "Bilim",
  ),
  WordCard(
    word: "WAVE",
    tabooWords: ["Water", "Sound", "Light", "Vibration", "Spread"],
    category: "Bilim",
  ),
  WordCard(
    word: "ELECTRON",
    tabooWords: ["Atom", "Charge", "Negative", "Nucleus", "Particle"],
    category: "Bilim",
  ),
  WordCard(
    word: "CHEMISTRY",
    tabooWords: ["Experiment", "Matter", "Reaction", "Laboratory", "Science"],
    category: "Bilim",
  ),
  WordCard(
    word: "PHYSICS",
    tabooWords: ["Force", "Motion", "Energy", "Science", "Newton"],
    category: "Bilim",
  ),
  WordCard(
    word: "BIOLOGY",
    tabooWords: ["Living", "Cell", "Science", "Human", "Life"],
    category: "Bilim",
  ),
  WordCard(
    word: "EXPERIMENT",
    tabooWords: ["Laboratory", "Test", "Science", "Result", "Research"],
    category: "Bilim",
  ),
  WordCard(
    word: "LABORATORY",
    tabooWords: ["Experiment", "Science", "Chemistry", "Tube", "Research"],
    category: "Bilim",
  ),
  WordCard(
    word: "BACTERIA",
    tabooWords: ["Germ", "Illness", "Microscope", "Tiny", "Living"],
    category: "Bilim",
  ),
  WordCard(
    word: "VIRUS",
    tabooWords: ["Disease", "Contagious", "Germ", "Immunity", "Infection"],
    category: "Bilim",
  ),
  WordCard(
    word: "VACCINE",
    tabooWords: ["Disease", "Protection", "Needle", "Immunity", "Virus"],
    category: "Bilim",
  ),
  WordCard(
    word: "IMMUNITY",
    tabooWords: ["Body", "Disease", "Defense", "Vaccine", "Protection"],
    category: "Bilim",
  ),
  WordCard(
    word: "HUMAN BODY",
    tabooWords: ["Organ", "Muscle", "Bone", "System", "Living"],
    category: "Bilim",
  ),
  WordCard(
    word: "BRAIN",
    tabooWords: ["Think", "Nerve", "Head", "Intelligence", "Organ"],
    category: "Bilim",
  ),
  WordCard(
    word: "HEART",
    tabooWords: ["Blood", "Beat", "Circulation", "Organ", "Chest"],
    category: "Bilim",
  ),
  WordCard(
    word: "BLOOD",
    tabooWords: ["Circulation", "Red", "Body", "Heart", "Vein"],
    category: "Bilim",
  ),
  WordCard(
    word: "VEIN",
    tabooWords: ["Blood", "Body", "Heart", "Carry", "Inside"],
    category: "Bilim",
  ),
  WordCard(
    word: "SKELETON",
    tabooWords: ["Bone", "Body", "Support", "Human", "Structure"],
    category: "Bilim",
  ),
  WordCard(
    word: "MUSCLE",
    tabooWords: ["Motion", "Body", "Strength", "Human", "Pull"],
    category: "Bilim",
  ),
  WordCard(
    word: "DIGESTION",
    tabooWords: ["Stomach", "Intestine", "Food", "Body", "System"],
    category: "Bilim",
  ),
  WordCard(
    word: "RESPIRATION",
    tabooWords: ["Breath", "Lung", "Oxygen", "Body", "Air"],
    category: "Bilim",
  ),
  WordCard(
    word: "LUNG",
    tabooWords: ["Breath", "Respiration", "Oxygen", "Organ", "Chest"],
    category: "Bilim",
  ),
  WordCard(
    word: "SPACE",
    tabooWords: ["Universe", "Star", "Planet", "Vacuum", "Astronomy"],
    category: "Bilim",
  ),
  WordCard(
    word: "PLANET",
    tabooWords: ["Earth", "Space", "Sun", "Orbit", "Astronomy"],
    category: "Bilim",
  ),
  WordCard(
    word: "SUN",
    tabooWords: ["Star", "Light", "Heat", "Center", "Day"],
    category: "Bilim",
  ),
  WordCard(
    word: "MOON",
    tabooWords: ["Earth", "Night", "Satellite", "Orbit", "Sky"],
    category: "Bilim",
  ),
  WordCard(
    word: "STAR",
    tabooWords: ["Space", "Light", "Sun", "Sky", "Shine"],
    category: "Bilim",
  ),
  WordCard(
    word: "ASTRONOMY",
    tabooWords: ["Space", "Planet", "Star", "Science", "Telescope"],
    category: "Bilim",
  ),
  WordCard(
    word: "EVOLUTION",
    tabooWords: ["Change", "Living", "Time", "Species", "Science"],
    category: "Bilim",
  ),
  WordCard(
    word: "ECOSYSTEM",
    tabooWords: ["Living", "Nature", "Balance", "Environment", "System"],
    category: "Bilim",
  ),
  WordCard(
    word: "CLIMATE",
    tabooWords: ["Weather", "Long", "Temperature", "Earth", "Change"],
    category: "Bilim",
  ),
  WordCard(
    word: "AIR",
    tabooWords: ["Breath", "Atmosphere", "Gas", "Wind", "Oxygen"],
    category: "Bilim",
  ),
  WordCard(
    word: "WATER",
    tabooWords: ["Liquid", "Drink", "Life", "Basic", "H2O"],
    category: "Bilim",
  ),
  WordCard(
    word: "BOILING",
    tabooWords: ["Heat", "Water", "Temperature", "Steam", "Degree"],
    category: "Bilim",
  ),
  WordCard(
    word: "MELTING",
    tabooWords: ["Ice", "Heat", "Solid", "Liquid", "Change"],
    category: "Bilim",
  ),
  WordCard(
    word: "CONDENSATION",
    tabooWords: ["Steam", "Gas", "Liquid", "Cold", "Transition"],
    category: "Bilim",
  ),

  // Food Category
  WordCard(
    word: "DUMPLINGS",
    tabooWords: ["Dough", "Ground Meat", "Yogurt", "Garlic", "Boiled"],
    category: "Yemek",
  ),
  WordCard(
    word: "TURKISH PIZZA",
    tabooWords: ["Dough", "Ground Meat", "Oven", "Thin", "Spicy"],
    category: "Yemek",
  ),
  WordCard(
    word: "BAKLAVA",
    tabooWords: ["Dessert", "Syrup", "Pistachio", "Phyllo", "Tray"],
    category: "Yemek",
  ),
  WordCard(
    word: "STUFFED EGGPLANT",
    tabooWords: ["Eggplant", "Fried", "Ground Meat", "Pot", "Dish"],
    category: "Yemek",
  ),
  WordCard(
    word: "DONER KEBAB",
    tabooWords: ["Meat", "Spit", "Bread", "Chicken", "Slice"],
    category: "Yemek",
  ),
  WordCard(
    word: "TURKISH FLATBREAD",
    tabooWords: ["Oven", "Dough", "Cheese", "Long", "Black Sea"],
    category: "Yemek",
  ),
  WordCard(
    word: "MEATBALL",
    tabooWords: ["Ground Meat", "Grill", "Meat", "Round", "Bread"],
    category: "Yemek",
  ),
  WordCard(
    word: "ISKENDER KEBAB",
    tabooWords: ["Doner", "Yogurt", "Butter", "Bursa", "Meat"],
    category: "Yemek",
  ),
  WordCard(
    word: "SCRAMBLED EGGS",
    tabooWords: ["Egg", "Tomato", "Pepper", "Breakfast", "Pan"],
    category: "Yemek",
  ),
  WordCard(
    word: "RICE PILAF",
    tabooWords: ["Rice", "Grain", "Butter", "Water", "Side"],
    category: "Yemek",
  ),
  WordCard(
    word: "SAVORY PASTRY",
    tabooWords: ["Phyllo", "Cheese", "Oven", "Layer", "Dough"],
    category: "Yemek",
  ),
  WordCard(
    word: "STUFFED FLATBREAD",
    tabooWords: ["Griddle", "Phyllo", "Cheese", "Fold", "Village"],
    category: "Yemek",
  ),
  WordCard(
    word: "SOUP",
    tabooWords: ["Hot", "Spoon", "Starter", "Pot", "Liquid"],
    category: "Yemek",
  ),
  WordCard(
    word: "LENTIL SOUP",
    tabooWords: ["Soup", "Lentil", "Bulgur", "Red", "Hot"],
    category: "Yemek",
  ),
  WordCard(
    word: "TARHANA SOUP",
    tabooWords: ["Soup", "Dried", "Sour", "Winter", "Powder"],
    category: "Yemek",
  ),
  WordCard(
    word: "WHITE BEANS",
    tabooWords: ["Legume", "Rice", "White", "Pot", "Dish"],
    category: "Yemek",
  ),
  WordCard(
    word: "CHICKPEA",
    tabooWords: ["Legume", "Round", "Pot", "Dish", "Protein"],
    category: "Yemek",
  ),
  WordCard(
    word: "LENTIL",
    tabooWords: ["Legume", "Red", "Soup", "Yellow", "Grain"],
    category: "Yemek",
  ),
  WordCard(
    word: "OLIVE OIL EGGPLANT",
    tabooWords: ["Eggplant", "Olive Oil", "Cold", "Vegetable", "Dish"],
    category: "Yemek",
  ),
  WordCard(
    word: "SALAD",
    tabooWords: ["Greens", "Raw", "Mix", "Lemon", "Side"],
    category: "Yemek",
  ),
  WordCard(
    word: "TZATZIKI",
    tabooWords: ["Yogurt", "Cucumber", "Garlic", "Cold", "Summer"],
    category: "Yemek",
  ),
  WordCard(
    word: "YOGURT DRINK",
    tabooWords: ["Yogurt", "Water", "Salt", "Drink", "Cold"],
    category: "Yemek",
  ),
  WordCard(
    word: "KEBAB",
    tabooWords: ["Meat", "Skewer", "Grill", "Spicy", "Adana"],
    category: "Yemek",
  ),
  WordCard(
    word: "ADANA KEBAB",
    tabooWords: ["Kebab", "Spicy", "Skewer", "Meat", "Urfa"],
    category: "Yemek",
  ),
  WordCard(
    word: "URFA KEBAB",
    tabooWords: ["Kebab", "Mild", "Meat", "Skewer", "Adana"],
    category: "Yemek",
  ),
  WordCard(
    word: "SPICY SAUSAGE",
    tabooWords: ["Meat", "Spice", "Breakfast", "Fry", "Sausage"],
    category: "Yemek",
  ),
  WordCard(
    word: "CURED BEEF",
    tabooWords: ["Meat", "Kayseri", "Fenugreek", "Dry", "Slice"],
    category: "Yemek",
  ),
  WordCard(
    word: "OMELET",
    tabooWords: ["Egg", "Pan", "Breakfast", "Cook", "Mix"],
    category: "Yemek",
  ),
  WordCard(
    word: "CLOTTED CREAM",
    tabooWords: ["Milk", "Breakfast", "Honey", "Fatty", "White"],
    category: "Yemek",
  ),
  WordCard(
    word: "HONEY",
    tabooWords: ["Bee", "Sweet", "Breakfast", "Yellow", "Natural"],
    category: "Yemek",
  ),
  WordCard(
    word: "CHEESE",
    tabooWords: ["Milk", "Breakfast", "White", "Salty", "Slice"],
    category: "Yemek",
  ),
  WordCard(
    word: "YOGURT",
    tabooWords: ["Milk", "White", "Cold", "Bowl", "Sour"],
    category: "Yemek",
  ),
  WordCard(
    word: "BREAKFAST",
    tabooWords: ["Morning", "Egg", "Cheese", "Tea", "Table"],
    category: "Yemek",
  ),
  WordCard(
    word: "TEA",
    tabooWords: ["Glass", "Brew", "Hot", "Black", "Drink"],
    category: "Yemek",
  ),
  WordCard(
    word: "COFFEE",
    tabooWords: ["Turkish", "Cup", "Caffeine", "Grounds", "Drink"],
    category: "Yemek",
  ),
  WordCard(
    word: "TURKISH DELIGHT",
    tabooWords: ["Dessert", "Sugar", "Soft", "Treat", "Turkish"],
    category: "Yemek",
  ),
  WordCard(
    word: "HALVA",
    tabooWords: ["Dessert", "Flour", "Semolina", "Toast", "Sugar"],
    category: "Yemek",
  ),
  WordCard(
    word: "RICE PUDDING",
    tabooWords: ["Dessert", "Milk", "Rice", "Oven", "Bowl"],
    category: "Yemek",
  ),
  WordCard(
    word: "CARAMELIZED PUDDING",
    tabooWords: ["Dessert", "Milk", "Burnt", "Custard", "Tray"],
    category: "Yemek",
  ),
  WordCard(
    word: "ICE CREAM",
    tabooWords: ["Cold", "Dessert", "Summer", "Cone", "Melt"],
    category: "Yemek",
  ),
  WordCard(
    word: "WAFFLE",
    tabooWords: ["Dessert", "Chocolate", "Fruit", "Batter", "Square"],
    category: "Yemek",
  ),
  WordCard(
    word: "PIZZA",
    tabooWords: ["Dough", "Cheese", "Oven", "Slice", "Italian"],
    category: "Yemek",
  ),
  WordCard(
    word: "HAMBURGER",
    tabooWords: ["Bun", "Patty", "Fast Food", "Sandwich", "Meat"],
    category: "Yemek",
  ),
  WordCard(
    word: "PASTA",
    tabooWords: ["Dough", "Boil", "Sauce", "Spaghetti", "Plate"],
    category: "Yemek",
  ),

  // Sports Category
  WordCard(
    word: "SOCCER",
    tabooWords: ["Ball", "Goal", "Match", "Field", "Team"],
    category: "Spor",
  ),
  WordCard(
    word: "BASKETBALL",
    tabooWords: ["Hoop", "Ball", "Court", "NBA", "Match"],
    category: "Spor",
  ),
  WordCard(
    word: "VOLLEYBALL",
    tabooWords: ["Net", "Ball", "Spike", "Set", "Court"],
    category: "Spor",
  ),
  WordCard(
    word: "TENNIS",
    tabooWords: ["Racket", "Ball", "Court", "Serve", "Match"],
    category: "Spor",
  ),
  WordCard(
    word: "TABLE TENNIS",
    tabooWords: ["Racket", "Ball", "Table", "Net", "Ping Pong"],
    category: "Spor",
  ),
  WordCard(
    word: "SWIMMING",
    tabooWords: ["Pool", "Sea", "Water", "Stroke", "Swim"],
    category: "Spor",
  ),
  WordCard(
    word: "RUNNING",
    tabooWords: ["Athletics", "Speed", "Track", "Breath", "Feet"],
    category: "Spor",
  ),
  WordCard(
    word: "ATHLETICS",
    tabooWords: ["Running", "Jumping", "Field", "Olympics", "Athlete"],
    category: "Spor",
  ),
  WordCard(
    word: "WEIGHTLIFTING",
    tabooWords: ["Weight", "Lift", "Bar", "Strength", "Muscle"],
    category: "Spor",
  ),
  WordCard(
    word: "BOXING",
    tabooWords: ["Ring", "Gloves", "Punch", "Match", "Fighter"],
    category: "Spor",
  ),
  WordCard(
    word: "WRESTLING",
    tabooWords: ["Wrestler", "Oil", "Grapple", "Hold", "Mat"],
    category: "Spor",
  ),
  WordCard(
    word: "JUDO",
    tabooWords: ["Fight", "Opponent", "Throw", "Mat", "Japan"],
    category: "Spor",
  ),
  WordCard(
    word: "KARATE",
    tabooWords: ["Fight", "Kick", "Kata", "Japan", "Sport"],
    category: "Spor",
  ),
  WordCard(
    word: "FITNESS",
    tabooWords: ["Gym", "Weights", "Exercise", "Muscle", "Training"],
    category: "Spor",
  ),
  WordCard(
    word: "BODYBUILDING",
    tabooWords: ["Muscle", "Weights", "Fitness", "Protein", "Gym"],
    category: "Spor",
  ),
  WordCard(
    word: "SKIING",
    tabooWords: ["Snow", "Mountain", "Slope", "Winter", "Slide"],
    category: "Spor",
  ),
  WordCard(
    word: "SNOWBOARDING",
    tabooWords: ["Snow", "Board", "Slide", "Mountain", "Winter"],
    category: "Spor",
  ),
  WordCard(
    word: "ICE SKATING",
    tabooWords: ["Ice", "Glide", "Rink", "Foot", "Cold"],
    category: "Spor",
  ),
  WordCard(
    word: "ROLLER SKATING",
    tabooWords: ["Wheel", "Glide", "Foot", "Helmet", "Balance"],
    category: "Spor",
  ),
  WordCard(
    word: "BICYCLE",
    tabooWords: ["Pedal", "Two Wheels", "Ride", "Helmet", "Road"],
    category: "Spor",
  ),
  WordCard(
    word: "MOUNTAINEERING",
    tabooWords: ["Climb", "Summit", "Rope", "Mountain", "Risk"],
    category: "Spor",
  ),
  WordCard(
    word: "ARCHERY",
    tabooWords: ["Bow", "Arrow", "Target", "Shoot", "Aim"],
    category: "Spor",
  ),
  WordCard(
    word: "FENCING",
    tabooWords: ["Sword", "Mask", "Duel", "Point", "French"],
    category: "Spor",
  ),
  WordCard(
    word: "HANDBALL",
    tabooWords: ["Ball", "Goal", "Team", "Throw", "Indoor"],
    category: "Spor",
  ),
  WordCard(
    word: "WATER POLO",
    tabooWords: ["Pool", "Ball", "Goal", "Team", "Swim"],
    category: "Spor",
  ),
  WordCard(
    word: "DARTS",
    tabooWords: ["Arrow", "Target", "Throw", "Points", "Board"],
    category: "Spor",
  ),
  WordCard(
    word: "BILLIARDS",
    tabooWords: ["Ball", "Cue", "Table", "Pocket", "Hit"],
    category: "Spor",
  ),
  WordCard(
    word: "BOWLING",
    tabooWords: ["Ball", "Pins", "Alley", "Roll", "Hit"],
    category: "Spor",
  ),
  WordCard(
    word: "GOLF",
    tabooWords: ["Club", "Ball", "Grass", "Hole", "Hit"],
    category: "Spor",
  ),
  WordCard(
    word: "SURFING",
    tabooWords: ["Wave", "Sea", "Board", "Ride", "Balance"],
    category: "Spor",
  ),
  WordCard(
    word: "SAILING",
    tabooWords: ["Wind", "Sea", "Boat", "Race", "Sailboat"],
    category: "Spor",
  ),
  WordCard(
    word: "CANOEING",
    tabooWords: ["Paddle", "Water", "Boat", "River", "Sport"],
    category: "Spor",
  ),
  WordCard(
    word: "RACKET",
    tabooWords: ["Tennis", "Hit", "Ball", "Handle", "Net"],
    category: "Spor",
  ),
  WordCard(
    word: "REFEREE",
    tabooWords: ["Match", "Rule", "Whistle", "Decision", "Manage"],
    category: "Spor",
  ),
  WordCard(
    word: "COACH",
    tabooWords: ["Team", "Train", "Teacher", "Athlete", "Match"],
    category: "Spor",
  ),
  WordCard(
    word: "ATHLETE",
    tabooWords: ["Training", "Match", "Team", "Success", "Performance"],
    category: "Spor",
  ),
  WordCard(
    word: "OLYMPICS",
    tabooWords: ["Games", "Country", "Medal", "Four Years", "Sport"],
    category: "Spor",
  ),
  WordCard(
    word: "MEDAL",
    tabooWords: ["Gold", "Silver", "Bronze", "Win", "Neck"],
    category: "Spor",
  ),
  WordCard(
    word: "RECORD",
    tabooWords: ["Best", "Score", "Break", "Success", "Time"],
    category: "Spor",
  ),
  WordCard(
    word: "SCORE",
    tabooWords: ["Points", "Count", "Match", "Win", "Number"],
    category: "Spor",
  ),
  WordCard(
    word: "SET",
    tabooWords: ["Volleyball", "Tennis", "Segment", "Match", "Game"],
    category: "Spor",
  ),
  WordCard(
    word: "GOAL",
    tabooWords: ["Soccer", "Net", "Score", "Ball", "Shoot"],
    category: "Spor",
  ),

  // Nature Category
  WordCard(
    word: "FOREST",
    tabooWords: ["Tree", "Green", "Leaf", "Nature", "Animal"],
    category: "Doğa",
  ),
  WordCard(
    word: "SEA",
    tabooWords: ["Water", "Salty", "Wave", "Beach", "Blue"],
    category: "Doğa",
  ),
  WordCard(
    word: "MOUNTAIN",
    tabooWords: ["High", "Summit", "Climb", "Snow", "Peak"],
    category: "Doğa",
  ),
  WordCard(
    word: "LAKE",
    tabooWords: ["Water", "Still", "Fresh", "Shore", "Fish"],
    category: "Doğa",
  ),
  WordCard(
    word: "RIVER",
    tabooWords: ["Flow", "Water", "Long", "Bridge", "Bed"],
    category: "Doğa",
  ),
  WordCard(
    word: "WATERFALL",
    tabooWords: ["Water", "High", "Fall", "Flow", "Noise"],
    category: "Doğa",
  ),
  WordCard(
    word: "VALLEY",
    tabooWords: ["Mountain", "Between", "Deep", "River", "Nature"],
    category: "Doğa",
  ),
  WordCard(
    word: "PLAIN",
    tabooWords: ["Flat", "Field", "Wide", "Soil", "Farming"],
    category: "Doğa",
  ),
  WordCard(
    word: "BEACH",
    tabooWords: ["Sand", "Sea", "Sun", "Umbrella", "Summer"],
    category: "Doğa",
  ),
  WordCard(
    word: "SAND",
    tabooWords: ["Beach", "Yellow", "Grain", "Sea", "Foot"],
    category: "Doğa",
  ),
  WordCard(
    word: "SOIL",
    tabooWords: ["Mud", "Field", "Plant", "Ground", "Brown"],
    category: "Doğa",
  ),
  WordCard(
    word: "TREE",
    tabooWords: ["Forest", "Trunk", "Branch", "Leaf", "Green"],
    category: "Doğa",
  ),
  WordCard(
    word: "LEAF",
    tabooWords: ["Tree", "Green", "Autumn", "Branch", "Fall"],
    category: "Doğa",
  ),
  WordCard(
    word: "FLOWER",
    tabooWords: ["Scent", "Colorful", "Spring", "Plant", "Bloom"],
    category: "Doğa",
  ),
  WordCard(
    word: "GRASS",
    tabooWords: ["Green", "Garden", "Ground", "Cut", "Soil"],
    category: "Doğa",
  ),
  WordCard(
    word: "RAIN",
    tabooWords: ["Water", "Cloud", "Wet", "Umbrella", "Weather"],
    category: "Doğa",
  ),
  WordCard(
    word: "SNOW",
    tabooWords: ["White", "Cold", "Winter", "Fall", "Ice"],
    category: "Doğa",
  ),
  WordCard(
    word: "ICE",
    tabooWords: ["Cold", "Freeze", "Slippery", "Water", "Melt"],
    category: "Doğa",
  ),
  WordCard(
    word: "WIND",
    tabooWords: ["Air", "Breeze", "Storm", "Blow", "Cold"],
    category: "Doğa",
  ),
  WordCard(
    word: "STORM",
    tabooWords: ["Wind", "Rain", "Strong", "Weather", "Wave"],
    category: "Doğa",
  ),
  WordCard(
    word: "THUNDER",
    tabooWords: ["Lightning", "Sound", "Storm", "Fear", "Cloud"],
    category: "Doğa",
  ),
  WordCard(
    word: "LIGHTNING",
    tabooWords: ["Light", "Sky", "Storm", "Strike", "Cloud"],
    category: "Doğa",
  ),
  WordCard(
    word: "CLOUD",
    tabooWords: ["Sky", "White", "Rain", "Weather", "Fly"],
    category: "Doğa",
  ),
  WordCard(
    word: "SUN",
    tabooWords: ["Warm", "Light", "Day", "Sky", "Star"],
    category: "Doğa",
  ),
  WordCard(
    word: "MOON",
    tabooWords: ["Night", "Satellite", "Sky", "Earth", "Round"],
    category: "Doğa",
  ),
  WordCard(
    word: "STAR",
    tabooWords: ["Sky", "Night", "Bright", "Space", "Light"],
    category: "Doğa",
  ),
  WordCard(
    word: "RAINBOW",
    tabooWords: ["Color", "Rain", "Sun", "Seven", "Sky"],
    category: "Doğa",
  ),
  WordCard(
    word: "DESERT",
    tabooWords: ["Sand", "Hot", "Dry", "Little", "Water"],
    category: "Doğa",
  ),
  WordCard(
    word: "SWAMP",
    tabooWords: ["Mud", "Water", "Mosquito", "Soft", "Ground"],
    category: "Doğa",
  ),
  WordCard(
    word: "CAVE",
    tabooWords: ["Dark", "Rock", "Underground", "Cold", "Deep"],
    category: "Doğa",
  ),
  WordCard(
    word: "ROCK",
    tabooWords: ["Stone", "Hard", "Mountain", "Big", "Heavy"],
    category: "Doğa",
  ),
  WordCard(
    word: "STONE",
    tabooWords: ["Hard", "Small", "Throw", "Ground", "Nature"],
    category: "Doğa",
  ),
  WordCard(
    word: "VOLCANO",
    tabooWords: ["Lava", "Eruption", "Explode", "Fire", "Mountain"],
    category: "Doğa",
  ),
  WordCard(
    word: "LAVA",
    tabooWords: ["Volcano", "Hot", "Flow", "Fire", "Red"],
    category: "Doğa",
  ),
  WordCard(
    word: "WILDFIRE",
    tabooWords: ["Fire", "Smoke", "Tree", "Burn", "Disaster"],
    category: "Doğa",
  ),
  WordCard(
    word: "NATURE",
    tabooWords: ["Environment", "Forest", "Sea", "Animal", "Earth"],
    category: "Doğa",
  ),
  WordCard(
    word: "ECOSYSTEM",
    tabooWords: ["Living", "Balance", "Nature", "Environment", "System"],
    category: "Doğa",
  ),
  WordCard(
    word: "SEASON",
    tabooWords: ["Summer", "Winter", "Autumn", "Spring", "Time"],
    category: "Doğa",
  ),
  WordCard(
    word: "SUMMER",
    tabooWords: ["Hot", "Sea", "Vacation", "Sun", "Season"],
    category: "Doğa",
  ),
  WordCard(
    word: "WINTER",
    tabooWords: ["Cold", "Snow", "Coat", "Season", "Ice"],
    category: "Doğa",
  ),
  WordCard(
    word: "AUTUMN",
    tabooWords: ["Leaf", "Yellow", "Cool", "Season", "Fall"],
    category: "Doğa",
  ),
  WordCard(
    word: "SPRING",
    tabooWords: ["Flower", "Rain", "Season", "Green", "Warm"],
    category: "Doğa",
  ),
  WordCard(
    word: "ANIMAL",
    tabooWords: ["Living", "Nature", "Wild", "Species", "Live"],
    category: "Doğa",
  ),
  WordCard(
    word: "WILDLIFE",
    tabooWords: ["Animal", "Nature", "Forest", "Free", "Natural"],
    category: "Doğa",
  ),

  // Technology Category
  WordCard(
    word: "COMPUTER",
    tabooWords: ["Screen", "Keyboard", "Mouse", "Program", "Internet"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "SMARTPHONE",
    tabooWords: ["Touchscreen", "iPhone", "Android", "Mobile", "Camera"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "INTERNET",
    tabooWords: ["Connection", "Web", "Online", "WiFi", "Network"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "WI-FI",
    tabooWords: ["Wireless", "Internet", "Modem", "Connect", "Network"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "MODEM",
    tabooWords: ["Internet", "WiFi", "Connection", "Light", "Box"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "SOFTWARE",
    tabooWords: ["Code", "Program", "Computer", "App", "Development"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "HARDWARE",
    tabooWords: ["Part", "Computer", "Physical", "Screen", "Keyboard"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "APP",
    tabooWords: ["Phone", "Program", "Download", "Mobile", "Store"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "GAME",
    tabooWords: ["Play", "Console", "Computer", "Fun", "Score"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "CONSOLE",
    tabooWords: ["Game", "PlayStation", "Xbox", "Controller", "TV"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "SERVER",
    tabooWords: ["Data", "Internet", "Connection", "Storage", "Host"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "CLOUD",
    tabooWords: ["Storage", "Online", "Data", "Server", "Internet"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "DATA",
    tabooWords: ["Information", "File", "Store", "Digital", "Computer"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "FILE",
    tabooWords: ["Document", "Save", "Computer", "Folder", "Data"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "FOLDER",
    tabooWords: ["File", "Organize", "Computer", "Inside", "Store"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "EMAIL",
    tabooWords: ["Mail", "Message", "Send", "Internet", "Address"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "BROWSER",
    tabooWords: ["Chrome", "Web", "Internet", "Site", "Open"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "SEARCH ENGINE",
    tabooWords: ["Google", "Internet", "Find", "Site", "Type"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "ARTIFICIAL INTELLIGENCE",
    tabooWords: ["Machine", "Learning", "Algorithm", "Computer", "Mind"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "ROBOT",
    tabooWords: ["Machine", "Automatic", "Metal", "Program", "Artificial"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "ALGORITHM",
    tabooWords: ["Step", "Code", "Solution", "Logic", "Program"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "CODE",
    tabooWords: ["Write", "Program", "Computer", "Language", "Software"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "PROGRAMMING",
    tabooWords: ["Code", "Software", "Computer", "Language", "Development"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "BUG",
    tabooWords: ["Error", "Problem", "Code", "Fail", "Fix"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "UPDATE",
    tabooWords: ["New", "Version", "Software", "Download", "Change"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "CHARGE",
    tabooWords: ["Battery", "Fill", "Cable", "Electricity", "Power"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "BATTERY",
    tabooWords: ["Charge", "Energy", "Phone", "Fill", "Power"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "SCREEN",
    tabooWords: ["Display", "Touch", "Light", "Phone", "Computer"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "KEYBOARD",
    tabooWords: ["Key", "Type", "Computer", "Letter", "Input"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "MOUSE",
    tabooWords: ["Click", "Cursor", "Computer", "Hand", "Cable"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "USB",
    tabooWords: ["Cable", "Plug", "Connect", "File", "Port"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "BLUETOOTH",
    tabooWords: ["Wireless", "Connection", "Headset", "Phone", "Turn On"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "HEADPHONES",
    tabooWords: ["Sound", "Music", "Wear", "Bluetooth", "Cable"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "SPEAKER",
    tabooWords: ["Sound", "Music", "Loud", "Listen", "Device"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "CAMERA",
    tabooWords: ["Photo", "Video", "Shoot", "Lens", "Image"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "DRONE",
    tabooWords: ["Fly", "Camera", "Remote", "Air", "Control"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "NAVIGATION",
    tabooWords: ["Map", "Road", "GPS", "Find", "Go"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "GPS",
    tabooWords: ["Location", "Satellite", "Map", "Phone", "Find"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "SOCIAL MEDIA",
    tabooWords: ["Share", "Internet", "Follow", "App", "Photo"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "PASSWORD",
    tabooWords: ["Secret", "Security", "Login", "Account", "Code"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "SECURITY",
    tabooWords: ["Protection", "Password", "Data", "Danger", "System"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "VIRUS",
    tabooWords: ["Damage", "Computer", "Program", "Delete", "Threat"],
    category: "Teknoloji",
  ),

  // History Category
  WordCard(
    word: "ATATURK",
    tabooWords: ["Republic", "Mustafa Kemal", "Turkey", "Leader", "Independence"],
    category: "Tarih",
  ),
  WordCard(
    word: "REPUBLIC",
    tabooWords: ["Ataturk", "State", "Government", "Turkey", "1923"],
    category: "Tarih",
  ),
  WordCard(
    word: "OTTOMAN",
    tabooWords: ["Empire", "Sultan", "State", "History", "Istanbul"],
    category: "Tarih",
  ),
  WordCard(
    word: "CONQUEST OF ISTANBUL",
    tabooWords: ["1453", "Mehmed", "War", "Byzantium", "Istanbul"],
    category: "Tarih",
  ),
  WordCard(
    word: "MEHMED THE CONQUEROR",
    tabooWords: ["Istanbul", "Conquest", "Ottoman", "Sultan", "1453"],
    category: "Tarih",
  ),
  WordCard(
    word: "OTTOMAN SULTAN",
    tabooWords: ["Ottoman", "Throne", "Palace", "Ruler", "State"],
    category: "Tarih",
  ),
  WordCard(
    word: "SULTAN",
    tabooWords: ["Padishah", "Ottoman", "Ruler", "Throne", "State"],
    category: "Tarih",
  ),
  WordCard(
    word: "PALACE",
    tabooWords: ["Sultan", "Ottoman", "Life", "Building", "Throne"],
    category: "Tarih",
  ),
  WordCard(
    word: "TOPKAPI PALACE",
    tabooWords: ["Istanbul", "Ottoman", "Sultan", "Palace", "Museum"],
    category: "Tarih",
  ),
  WordCard(
    word: "WAR OF INDEPENDENCE",
    tabooWords: ["Ataturk", "War", "Turkey", "Independence", "Greece"],
    category: "Tarih",
  ),
  WordCard(
    word: "CONSTITUTION",
    tabooWords: ["Law", "State", "Rights", "Legal", "Article"],
    category: "Tarih",
  ),
  WordCard(
    word: "PARLIAMENT",
    tabooWords: ["TBMM", "Deputy", "Law", "Meeting", "State"],
    category: "Tarih",
  ),
  WordCard(
    word: "TBMM",
    tabooWords: ["Parliament", "Ankara", "Law", "People", "State"],
    category: "Tarih",
  ),
  WordCard(
    word: "ANKARA",
    tabooWords: ["Capital", "Turkey", "Parliament", "Ataturk", "City"],
    category: "Tarih",
  ),
  WordCard(
    word: "EMPIRE",
    tabooWords: ["State", "Large", "Land", "Rule", "Ottoman"],
    category: "Tarih",
  ),
  WordCard(
    word: "KING",
    tabooWords: ["Throne", "Kingdom", "Ruler", "Crown", "Rule"],
    category: "Tarih",
  ),
  WordCard(
    word: "QUEEN",
    tabooWords: ["Throne", "Kingdom", "Woman", "Crown", "Rule"],
    category: "Tarih",
  ),
  WordCard(
    word: "WAR",
    tabooWords: ["Army", "Weapon", "Conflict", "Front", "History"],
    category: "Tarih",
  ),
  WordCard(
    word: "ARMY",
    tabooWords: ["Soldier", "War", "Weapon", "Front", "Unit"],
    category: "Tarih",
  ),
  WordCard(
    word: "SOLDIER",
    tabooWords: ["Army", "Weapon", "War", "Uniform", "Duty"],
    category: "Tarih",
  ),
  WordCard(
    word: "FRONTLINE",
    tabooWords: ["War", "Soldier", "Line", "Battle", "Field"],
    category: "Tarih",
  ),
  WordCard(
    word: "TREATY",
    tabooWords: ["Signature", "Peace", "State", "War", "Agreement"],
    category: "Tarih",
  ),
  WordCard(
    word: "LAUSANNE",
    tabooWords: ["Treaty", "Turkey", "1923", "Peace", "Border"],
    category: "Tarih",
  ),
  WordCard(
    word: "SEVRES",
    tabooWords: ["Treaty", "Ottoman", "Partition", "War", "Rejected"],
    category: "Tarih",
  ),
  WordCard(
    word: "CONQUEST",
    tabooWords: ["Take", "War", "Land", "Victory", "Army"],
    category: "Tarih",
  ),
  WordCard(
    word: "VICTORY",
    tabooWords: ["Win", "War", "Success", "Army", "Celebration"],
    category: "Tarih",
  ),
  WordCard(
    word: "THRONE",
    tabooWords: ["Sultan", "King", "Sit", "Rule", "Palace"],
    category: "Tarih",
  ),
  WordCard(
    word: "CROWN",
    tabooWords: ["King", "Queen", "Head", "Gold", "Symbol"],
    category: "Tarih",
  ),
  WordCard(
    word: "INSCRIPTION",
    tabooWords: ["Stone", "History", "Ancient", "Writing", "Monument"],
    category: "Tarih",
  ),
  WordCard(
    word: "MONUMENT",
    tabooWords: ["Statue", "History", "Structure", "Memory", "Stone"],
    category: "Tarih",
  ),
  WordCard(
    word: "MUSEUM",
    tabooWords: ["History", "Artifact", "Exhibition", "Visit", "Building"],
    category: "Tarih",
  ),
  WordCard(
    word: "ANCIENT AGE",
    tabooWords: ["History", "Ancient", "First", "Civilization", "Era"],
    category: "Tarih",
  ),
  WordCard(
    word: "MIDDLE AGES",
    tabooWords: ["History", "Knight", "Castle", "Dark", "Era"],
    category: "Tarih",
  ),
  WordCard(
    word: "MODERN AGE",
    tabooWords: ["History", "Discovery", "Renaissance", "Era", "Beginning"],
    category: "Tarih",
  ),
  WordCard(
    word: "RENAISSANCE",
    tabooWords: ["Europe", "Art", "Rebirth", "History", "Era"],
    category: "Tarih",
  ),
  WordCard(
    word: "REFORMATION",
    tabooWords: ["Religion", "Change", "Europe", "Church", "History"],
    category: "Tarih",
  ),
  WordCard(
    word: "CIVILIZATION",
    tabooWords: ["Society", "Culture", "History", "Ancient", "People"],
    category: "Tarih",
  ),
  WordCard(
    word: "CULTURE",
    tabooWords: ["Civilization", "Society", "Tradition", "History", "Developed"],
    category: "Tarih",
  ),
  WordCard(
    word: "WRITING",
    tabooWords: ["Letters", "History", "First", "Tablet", "Communication"],
    category: "Tarih",
  ),
  WordCard(
    word: "CALENDAR",
    tabooWords: ["Time", "Day", "Month", "Year", "Date"],
    category: "Tarih",
  ),
  WordCard(
    word: "CHRONOLOGY",
    tabooWords: ["Order", "Time", "History", "Event", "Arrange"],
    category: "Tarih",
  ),
  WordCard(
    word: "EPIC",
    tabooWords: ["Story", "Hero", "Ancient", "Oral", "History"],
    category: "Tarih",
  ),
  WordCard(
    word: "EPITAPH",
    tabooWords: ["Writing", "Stone", "History", "Monument", "Old"],
    category: "Tarih",
  ),
];
