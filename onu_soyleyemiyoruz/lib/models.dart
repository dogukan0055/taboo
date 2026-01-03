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

// Turkish initial deck
final List<WordCard> initialDeckTr = [
  // Genel Kategori
  WordCard(
    word: "SAAT",
    tabooWords: ["Zaman", "Akrep", "Yelkovan", "Dakika", "Duvar"],
    category: "Genel",
  ),
  WordCard(
    word: "ANAHTAR",
    tabooWords: ["Kapı", "Kilit", "Açmak", "Ev", "Girmek"],
    category: "Genel",
  ),
  WordCard(
    word: "YASTIK",
    tabooWords: ["Uyku", "Yatak", "Kafa", "Kaz Tüyü", "Gece"],
    category: "Genel",
  ),
  WordCard(
    word: "AYNA",
    tabooWords: ["Bakmak", "Görmek", "Cam", "Yüz", "Yansıma"],
    category: "Genel",
  ),
  WordCard(
    word: "ÇANTA",
    tabooWords: ["Kadın", "Okul", "Omuz", "Sırt", "Takmak"],
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
    tabooWords: ["Pencere", "Güneş", "Işık", "Tül", "Ev"],
    category: "Genel",
  ),
  WordCard(
    word: "HALI",
    tabooWords: ["Zemin", "Ev", "Desen", "Kilim", "Sermek"],
    category: "Genel",
  ),
  WordCard(
    word: "DOLAP",
    tabooWords: ["Kıyafet", "Eşya", "Mutfak", "Raf", "Saklamak"],
    category: "Genel",
  ),
  WordCard(
    word: "KOLONYA",
    tabooWords: ["Alkol", "Sıvı", "El", "Bayram", "Koku"],
    category: "Genel",
  ),
  WordCard(
    word: "KUMANDA",
    tabooWords: ["Televizyon", "Tuş", "Pil", "Kanal", "Kontrol"],
    category: "Genel",
  ),
  WordCard(
    word: "LAMBА",
    tabooWords: ["Işık", "Aydınlatma", "Uyku", "Gece", "Karanlık"],
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
    tabooWords: ["Oturmak", "Masa", "Çıkmak", "Ayak", "Ev"],
    category: "Genel",
  ),
  WordCard(
    word: "MASA",
    tabooWords: ["Yemek", "Mutfak", "Ayak", "Üst", "Mobilya"],
    category: "Genel",
  ),
  WordCard(
    word: "BATTANİYE",
    tabooWords: ["Soğuk", "Üst", "Yatak", "Sıcak", "Yorgan"],
    category: "Genel",
  ),
  WordCard(
    word: "ÇEKMECE",
    tabooWords: ["Dolap", "Açmak", "Raf", "Saklamak", "Mobilya"],
    category: "Genel",
  ),
  WordCard(
    word: "FIRIN",
    tabooWords: ["Yemek", "Derece", "Mutfak", "Pişirmek", "Ekmek"],
    category: "Genel",
  ),
  WordCard(
    word: "SÜPÜRGE",
    tabooWords: ["Temizlik", "Elektrik", "Toz", "Halı", "Ev"],
    category: "Genel",
  ),
  WordCard(
    word: "TEPSİ",
    tabooWords: ["Yemek", "Fırın", "Üst", "Taşımak", "Mutfak"],
    category: "Genel",
  ),
  WordCard(
    word: "MİNDER",
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
    tabooWords: ["Anahtar", "Kapı", "Güvenlik", "Açmak", "Kasa"],
    category: "Genel",
  ),
  WordCard(
    word: "PENCERE",
    tabooWords: ["Cam", "Perde", "Açmak", "Oda", "Duvar"],
    category: "Genel",
  ),
  WordCard(
    word: "KOLTUK",
    tabooWords: ["Oturmak", "Salon", "Yatmak", "Mobilya", "Takım"],
    category: "Genel",
  ),
  WordCard(
    word: "HAVLU",
    tabooWords: ["Banyo", "Kurulamak", "Su", "Tuvalet", "El"],
    category: "Genel",
  ),
  WordCard(
    word: "SABUN",
    tabooWords: ["Yıkamak", "Köpük", "Tuvalet", "Arap", "El"],
    category: "Genel",
  ),
  WordCard(
    word: "DİŞ FIRÇASI",
    tabooWords: ["Beyaz", "Macun", "Ağız", "Temizlik", "Banyo"],
    category: "Genel",
  ),
  WordCard(
    word: "BAVUL",
    tabooWords: ["Yolculuk", "Valiz", "Kıyafet", "Teker", "Bagaj"],
    category: "Genel",
  ),
  WordCard(
    word: "NOT DEFTERİ",
    tabooWords: ["Yazmak", "Küçük", "Taşımak", "Sayfa", "Kalem"],
    category: "Genel",
  ),
  WordCard(
    word: "TERLİK",
    tabooWords: ["Ev", "Ayak", "Rahat", "Giymek", "Yer"],
    category: "Genel",
  ),
  WordCard(
    word: "TAKVİM",
    tabooWords: ["Gün", "Ay", "Yıl", "Tarih", "Zaman"],
    category: "Genel",
  ),
  WordCard(
    word: "KUTU",
    tabooWords: ["Pense", "Koymak", "Saklamak", "Karton", "İç"],
    category: "Genel",
  ),
  WordCard(
    word: "MANDAL",
    tabooWords: ["Çamaşır", "Asmak", "Balkon", "Kurutmak", "İp"],
    category: "Genel",
  ),
  WordCard(
    word: "ÇAKMAK",
    tabooWords: ["Ateş", "Yakmak", "Sigara", "Taş", "Kaybolmak"],
    category: "Genel",
  ),

  // Sanat Kategori
  WordCard(
    word: "MONA LISA",
    tabooWords: ["Tablo", "Leonardo", "Gülümseme", "Resim", "Kadın"],
    category: "Sanat",
  ),
  WordCard(
    word: "PİKASSO",
    tabooWords: ["Ressam", "Çizim", "Tablo", "İspanya", "Modern"],
    category: "Sanat",
  ),
  WordCard(
    word: "VAN GOGH",
    tabooWords: ["Ressam", "Kulak", "Yıldızlı", "Hollanda", "Tablo"],
    category: "Sanat",
  ),
  WordCard(
    word: "HEYKEL",
    tabooWords: ["Taş", "Dikmek", "Yontmak", "Figür", "Sanatçı"],
    category: "Sanat",
  ),
  WordCard(
    word: "TİYATRO",
    tabooWords: ["Sahne", "Oyuncu", "Perde", "Oyun", "Salon"],
    category: "Sanat",
  ),
  WordCard(
    word: "OPERA",
    tabooWords: ["Şarkı", "Sahne", "Klasik", "Ses", "Tiz"],
    category: "Sanat",
  ),
  WordCard(
    word: "BALE",
    tabooWords: ["Dans", "Gösteri", "Sahne", "Müzik", "Zarif"],
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
    tabooWords: ["Doğa", "Güzel", "Dağ", "Deniz", "Tablo"],
    category: "Sanat",
  ),
  WordCard(
    word: "KARİKATÜR",
    tabooWords: ["Çizim", "Mizah", "Abartı", "Dergi", "Komik"],
    category: "Sanat",
  ),
  WordCard(
    word: "GRAFİTİ",
    tabooWords: ["Duvar", "Sprey", "Sokak", "Boya", "Sanat"],
    category: "Sanat",
  ),
  WordCard(
    word: "FOTOĞRAF",
    tabooWords: ["Kamera", "Çekmek", "Görüntü", "Işık", "Kare"],
    category: "Sanat",
  ),
  WordCard(
    word: "SİNEMA",
    tabooWords: ["Film", "Salon", "Beyaz Perde", "Aktör", "Yönetmen"],
    category: "Sanat",
  ),
  WordCard(
    word: "YÖNETMEN",
    tabooWords: ["Film", "Dizi", "Set", "Direktif", "Oyuncu"],
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
    word: "BESTECİ",
    tabooWords: ["Müzik", "Nota", "Yazmak", "Harman", "Eser"],
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
    tabooWords: ["Yay", "Tel", "Müzik", "Çalmak", "Boyun"],
    category: "Sanat",
  ),
  WordCard(
    word: "PİYANO",
    tabooWords: ["Tuş", "Müzik", "Çalmak", "Nota", "Kuyruklu"],
    category: "Sanat",
  ),
  WordCard(
    word: "SERGİ",
    tabooWords: ["Sanat", "Galeri", "Eser", "Gezmek", "Resim"],
    category: "Sanat",
  ),
  WordCard(
    word: "MÜZE",
    tabooWords: ["Tarih", "Eser", "Sergi", "Gezmek", "Eski"],
    category: "Sanat",
  ),
  WordCard(
    word: "KOSTÜM",
    tabooWords: ["Kıyafet", "Sahne", "Parti", "Tiyatro", "Makyaj"],
    category: "Sanat",
  ),
  WordCard(
    word: "DEKOR",
    tabooWords: ["Sahne", "Arka plan", "Tiyatro", "Eşya", "Mekan"],
    category: "Sanat",
  ),
  WordCard(
    word: "MAKYAJ",
    tabooWords: ["Yüz", "Sahne", "Kadın", "Kozmetik", "Hazırlık"],
    category: "Sanat",
  ),
  WordCard(
    word: "KURGU",
    tabooWords: ["Çekim", "Kesmek", "Montaj", "Sahne", "Video"],
    category: "Sanat",
  ),
  WordCard(
    word: "MONTAJ",
    tabooWords: ["Video", "Kesmek", "Film", "Kurgu", "Bilgisayar"],
    category: "Sanat",
  ),
  WordCard(
    word: "AFİŞ",
    tabooWords: ["Tanıtım", "Asmak", "Duvar", "Poster", "Reklam"],
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
    tabooWords: ["Kahkaha", "Komik", "Tür", "Mizah", "Romantik"],
    category: "Sanat",
  ),
  WordCard(
    word: "DRAM",
    tabooWords: ["Film", "Duygu", "Ağlamak", "Tür", "Hikâye"],
    category: "Sanat",
  ),
  WordCard(
    word: "KLASİK MÜZİK",
    tabooWords: ["Orkestra", "Sanat", "Türk", "Konser", "Eski"],
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
    tabooWords: ["Canlı", "Mikroskop", "DNA", "Biyoloji", "Yapı Birimi"],
    category: "Bilim",
  ),
  WordCard(
    word: "DNA",
    tabooWords: ["Gen", "Kalıtım", "Hücre", "Biyoloji", "Aktarım"],
    category: "Bilim",
  ),
  WordCard(
    word: "GEN",
    tabooWords: ["DNA", "Kalıtım", "Anne", "Baba", "Çocuk"],
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
    word: "FİZİK",
    tabooWords: ["Kuvvet", "Hareket", "Enerji", "Vücut", "Newton"],
    category: "Bilim",
  ),
  WordCard(
    word: "KİMYA",
    tabooWords: ["Deney", "Tepkime", "Formül", "Laboratuvar", "Uyuşmak"],
    category: "Bilim",
  ),
  WordCard(
    word: "BİYOLOJİ",
    tabooWords: ["Canlı", "Hücre", "Moleküler", "İnsan", "Yaşam"],
    category: "Bilim",
  ),
  WordCard(
    word: "DENEY",
    tabooWords: ["Laboratuvar", "Test", "Bilim İnsanı", "Sonuç", "Araştırma"],
    category: "Bilim",
  ),
  WordCard(
    word: "LABORATUVAR",
    tabooWords: ["Deney", "Bilim İnsanı", "Kimya", "Tüp", "Araştırma"],
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
    tabooWords: ["Dünya", "Uzay", "Güneş", "Satürn", "Jüpiter"],
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
    tabooWords: ["Uzay", "Gezegen", "Yıldız", "Gökyüzü", "Teleskop"],
    category: "Bilim",
  ),
  WordCard(
    word: "EVRİM",
    tabooWords: ["Değişim", "Canlı", "Zaman", "Geçmiş", "Günümüz"],
    category: "Bilim",
  ),
  WordCard(
    word: "EKOSİSTEM",
    tabooWords: ["Canlı", "Doğa", "Denge", "Çevre", "Döngü"],
    category: "Bilim",
  ),
  WordCard(
    word: "MEVSİM",
    tabooWords: ["İlkbahar", "Kış", "Sonbahar", "Yaz", "İklim"],
    category: "Bilim",
  ),
  WordCard(
    word: "HAVA",
    tabooWords: ["Nefes", "Atmosfer", "Gaz", "Rüzgar", "Oksijen"],
    category: "Bilim",
  ),
  WordCard(
    word: "SU",
    tabooWords: ["Sıvı", "İçecek", "Hayat", "Temel İhtiyaç", "Deniz"],
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
    tabooWords: ["Hamur", "Kıyma", "Yoğurt", "Kola", "Sinop"],
    category: "Yemek",
  ),
  WordCard(
    word: "LAHMACUN",
    tabooWords: ["Restoran", "Kıyma", "Fırın", "İnce", "Acı"],
    category: "Yemek",
  ),
  WordCard(
    word: "BAKLAVA",
    tabooWords: ["Tatlı", "Şerbet", "Fıstık", "Pastane", "Tepsi"],
    category: "Yemek",
  ),
  WordCard(
    word: "KARNIYARIK",
    tabooWords: ["Patlıcan", "Kızartma", "Kıyma", "Doldurma", "İmam Bayıldı"],
    category: "Yemek",
  ),
  WordCard(
    word: "DÖNER",
    tabooWords: ["Et", "Hatay", "Sos", "Tavuk", "Dilim"],
    category: "Yemek",
  ),
  WordCard(
    word: "PİDE",
    tabooWords: ["Fırın", "Lahmacun", "Bafra", "Kıyma", "Karadeniz"],
    category: "Yemek",
  ),
  WordCard(
    word: "KÖFTE",
    tabooWords: ["Kıyma", "Izgara", "Et", "Maç Önü", "Ekmek"],
    category: "Yemek",
  ),
  WordCard(
    word: "İSKENDER",
    tabooWords: ["Döner", "Yoğurt", "Tereyağı", "Bursa", "Et"],
    category: "Yemek",
  ),
  WordCard(
    word: "MENEMEN",
    tabooWords: ["Yumurta", "Domates", "Soğan", "Kahvaltı", "Çakallı"],
    category: "Yemek",
  ),
  WordCard(
    word: "PİLAV",
    tabooWords: ["Pirinç", "Tane", "Baldo", "Su", "Çekmek"],
    category: "Yemek",
  ),
  WordCard(
    word: "BÖREK",
    tabooWords: ["Yufka", "Peynir", "Patates", "Fırın", "Hamur"],
    category: "Yemek",
  ),
  WordCard(
    word: "GÖZLEME",
    tabooWords: ["Sac", "Yufka", "Tür", "Açmak", "Teyze"],
    category: "Yemek",
  ),
  WordCard(
    word: "ÇORBA",
    tabooWords: ["Sıcak", "Kaşık", "Başlangıç", "Tencere", "İçmek"],
    category: "Yemek",
  ),
  WordCard(
    word: "EZOGELİN",
    tabooWords: ["Çorba", "Mercimek", "Bulgur", "İçmek", "Sıcak"],
    category: "Yemek",
  ),
  WordCard(
    word: "TARHANA",
    tabooWords: ["Çorba", "İçmek", "Ekşi", "Kış", "Toz"],
    category: "Yemek",
  ),
  WordCard(
    word: "KURU FASULYE",
    tabooWords: ["Bakliyat", "Pilav", "Beyaz", "Protein", "Gaz"],
    category: "Yemek",
  ),
  WordCard(
    word: "NOHUT",
    tabooWords: ["Bakliyat", "Pilav", "Tencere", "Yemek", "Protein"],
    category: "Yemek",
  ),
  WordCard(
    word: "MERCİMEK",
    tabooWords: ["Bakliyat", "Sarı", "Kırmızı", "Çorba", "Tane"],
    category: "Yemek",
  ),
  WordCard(
    word: "İMAM BAYILDI",
    tabooWords: ["Patlıcan", "Zeytinyağı", "Soğuk", "Sebze", "Yemek"],
    category: "Yemek",
  ),
  WordCard(
    word: "SALATA",
    tabooWords: ["Yeşillik", "Çiğ", "Karıştırmak", "Limon", "Zeytinyağı"],
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
    word: "SUCUK",
    tabooWords: ["Et", "Yumurta", "Kahvaltı", "Kızartmak", "Sosis"],
    category: "Yemek",
  ),
  WordCard(
    word: "PASTIRMA",
    tabooWords: ["Et", "Kayseri", "Çemen", "Kurutmak", "Dilim"],
    category: "Yemek",
  ),
  WordCard(
    word: "SAHANDA YUMURTA",
    tabooWords: ["Yağ", "Tava", "Kahvaltı", "Sunny Side Up", "Karıştırmak"],
    category: "Yemek",
  ),
  WordCard(
    word: "KAYMAK",
    tabooWords: ["Süt", "Tereyağ", "Bal", "Yoğurt", "Beyaz"],
    category: "Yemek",
  ),
  WordCard(
    word: "BAL",
    tabooWords: ["Arı", "Tatlı", "Tereyağ", "Sarı", "Doğal"],
    category: "Yemek",
  ),
  WordCard(
    word: "PEYNİR",
    tabooWords: ["Süt", "Kaşar", "Beyaz", "Tuzlu", "Protein"],
    category: "Yemek",
  ),
  WordCard(
    word: "YOĞURT",
    tabooWords: ["Süt", "Beyaz", "Manda", "Maya", "İnek"],
    category: "Yemek",
  ),
  WordCard(
    word: "ÇAY",
    tabooWords: ["Bardak", "Demlemek", "Sıcak", "Siyah", "İçmek"],
    category: "Yemek",
  ),
  WordCard(
    word: "TÜRK KAHVESİ",
    tabooWords: ["Lokum", "Fincan", "Kafein", "Telve", "İçmek"],
    category: "Yemek",
  ),
  WordCard(
    word: "LOKUM",
    tabooWords: ["Tatlı", "Şeker", "Yumuşak", "İkram", "Türk"],
    category: "Yemek",
  ),
  WordCard(
    word: "HELVA",
    tabooWords: ["Yapmak", "Un", "İrmik", "Kavurmak", "Şeker"],
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
    tabooWords: ["Soğuk", "Yalamak", "Yaz", "Külah", "Erimek"],
    category: "Yemek",
  ),
  WordCard(
    word: "WAFFLE",
    tabooWords: ["Tatlı", "Çikolata", "Meyve", "Dondurma", "Nesh"],
    category: "Yemek",
  ),
  WordCard(
    word: "PİZZA",
    tabooWords: ["Hamur", "Peynir", "Fırın", "Dilim", "İtalyan"],
    category: "Yemek",
  ),
  WordCard(
    word: "HAMBURGER",
    tabooWords: ["Ekmek", "Köfte", "Fast food", "Sandviç", "Et"],
    category: "Yemek",
  ),
  WordCard(
    word: "MAKARNA",
    tabooWords: ["Kelebek", "Haşlamak", "Sos", "Spagetti", "Ketçap"],
    category: "Yemek",
  ),

  // Spor Kategori
  WordCard(
    word: "FUTBOL",
    tabooWords: ["22 Adam", "Kale", "Gol", "Maç", "Stadyum"],
    category: "Spor",
  ),
  WordCard(
    word: "BASKETBOL",
    tabooWords: ["Potа", "Dev Adam", "Saha", "NBA", "Smaç"],
    category: "Spor",
  ),
  WordCard(
    word: "VOLEYBOL",
    tabooWords: ["File", "Pasör", "Smaç", "Set", "Saha"],
    category: "Spor",
  ),
  WordCard(
    word: "TENİS",
    tabooWords: ["Raket", "Masa", "Kort", "Servis", "Ace"],
    category: "Spor",
  ),
  WordCard(
    word: "MASA TENİSİ",
    tabooWords: ["Raket", "Top", "Servis", "File", "Pinpon"],
    category: "Spor",
  ),
  WordCard(
    word: "YÜZME",
    tabooWords: ["Havuz", "Deniz", "Su", "Kulaç", "Dalış"],
    category: "Spor",
  ),
  WordCard(
    word: "KOŞU",
    tabooWords: ["Atletizm", "Hız", "Parkur", "Nefes", "Sprint"],
    category: "Spor",
  ),
  WordCard(
    word: "HALTER",
    tabooWords: ["Ağırlık", "Kaldırmak", "Bar", "Güç", "Kas"],
    category: "Spor",
  ),
  WordCard(
    word: "BOKS",
    tabooWords: ["Ring", "Eldiven", "Yumruk", "Ağızlık", "Dövüş"],
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
    tabooWords: ["Savaş Sanatı", "Tekme", "Kuşak", "Japon", "Kata"],
    category: "Spor",
  ),
  WordCard(
    word: "KAYAK",
    tabooWords: ["Kar", "Dağ", "Pist", "Kış", "Snowboard"],
    category: "Spor",
  ),
  WordCard(
    word: "BUZ PATENİ",
    tabooWords: ["Kızak", "Kaymak", "Pist", "Ayak", "Soğuk"],
    category: "Spor",
  ),
  WordCard(
    word: "BİSİKLET",
    tabooWords: ["Pedal", "İki teker", "Sürmek", "Kask", "Gidon"],
    category: "Spor",
  ),
  WordCard(
    word: "DAĞCILIK",
    tabooWords: ["Tırmanmak", "Zirve", "İp", "Yamaç", "Risk"],
    category: "Spor",
  ),
  WordCard(
    word: "OKÇULUK",
    tabooWords: ["Yay", "Mete Gazoz", "Hedef", "Atmak", "Nişan"],
    category: "Spor",
  ),
  WordCard(
    word: "ESKRİM",
    tabooWords: ["Kılıç", "Maske", "Düello", "Puan", "Fransız"],
    category: "Spor",
  ),
  WordCard(
    word: "HENTBOL",
    tabooWords: ["El", "Pas", "Takım", "Atmak", "Gol"],
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
    tabooWords: ["8 Top", "İsteka", "Masa", "Delik", "Vurmak"],
    category: "Spor",
  ),
  WordCard(
    word: "BOWLING",
    tabooWords: ["Top", "Lobut", "Salon", "Yuvarlamak", "Vurmak"],
    category: "Spor",
  ),
  WordCard(
    word: "GOLF",
    tabooWords: ["Sopa", "Top", "Çim", "Delik", "Zengin"],
    category: "Spor",
  ),
  WordCard(
    word: "YELKEN",
    tabooWords: ["Rüzgar", "Deniz", "Tekne", "Yarış", "Fora"],
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
    tabooWords: ["Maç", "Kural", "Düdük", "Kart", "Yönetmek"],
    category: "Spor",
  ),
  WordCard(
    word: "ANTRENÖR",
    tabooWords: ["Takım", "Çalıştırmak", "Hoca", "Teknik", "Direktör"],
    category: "Spor",
  ),
  WordCard(
    word: "OLİMPİYAT",
    tabooWords: ["Oyunlar", "Ülke", "Madalyа", "Dört yıl", "Uluslararası"],
    category: "Spor",
  ),
  WordCard(
    word: "MADALYA",
    tabooWords: ["Altın", "Gümüş", "Bronz", "Kazanmak", "Boyun"],
    category: "Spor",
  ),
  WordCard(
    word: "REKOR",
    tabooWords: ["En iyi", "Derece", "Kırmak", "Başarı", "Guinness"],
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
    tabooWords: ["Ağaç", "Yeşil", "Yangın", "Doğa", "Hayvan"],
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
    tabooWords: ["Su", "Durgun", "Balık", "Tatlı", "Kıyı"],
    category: "Doğa",
  ),
  WordCard(
    word: "NEHİR",
    tabooWords: ["Akarsu", "Kıyı", "Köprü", "Akmak", "Su"],
    category: "Doğa",
  ),
  WordCard(
    word: "ŞELALE",
    tabooWords: ["Su", "Yüksek", "Akmak", "Doğa", "Ses"],
    category: "Doğa",
  ),
  WordCard(
    word: "SAHİL",
    tabooWords: ["Kum", "Deniz", "Şemsiye", "Yaz", "Güneş"],
    category: "Doğa",
  ),
  WordCard(
    word: "ÇÖL",
    tabooWords: ["Kum", "Sıcak", "Kurak", "Vaha", "Güneş"],
    category: "Doğa",
  ),
  WordCard(
    word: "PLAJ",
    tabooWords: ["Kum", "Deniz", "Güneş", "Şezlong", "Tatil"],
    category: "Doğa",
  ),
  WordCard(
    word: "VOLKAN",
    tabooWords: ["Lav", "Patlama", "Konak", "Magma", "Yanardağ"],
    category: "Doğa",
  ),
  WordCard(
    word: "KANYON",
    tabooWords: ["Derin", "Vadi", "Kayalık", "Nehir", "Doğa"],
    category: "Doğa",
  ),
  WordCard(
    word: "OVA",
    tabooWords: ["Düzlük", "Tarım", "Toprak", "Geniş", "Alan"],
    category: "Doğa",
  ),
  WordCard(
    word: "FIRTINA",
    tabooWords: ["Rüzgar", "Yağmur", "Şimşek", "Hava", "Gök"],
    category: "Doğa",
  ),
  WordCard(
    word: "GÖKKUŞAĞI",
    tabooWords: ["Renk", "Yağmur", "Güneş", "Yedi", "Hazine"],
    category: "Doğa",
  ),
  WordCard(
    word: "ÇIĞ",
    tabooWords: ["Kar", "Dağ", "Düşme", "Tehlike", "Afet"],
    category: "Doğa",
  ),
  WordCard(
    word: "ÇİĞ",
    tabooWords: ["Sabah", "Damla", "Islak", "Çimen", "Su"],
    category: "Doğa",
  ),
  WordCard(
    word: "TOPRAK",
    tabooWords: ["Çamur", "Tarım", "Bitki", "Yer", "Doğa"],
    category: "Doğa",
  ),
  WordCard(
    word: "RÜZGAR",
    tabooWords: ["Hava", "Esinti", "Fırtına", "Soğuk", "Titremek"],
    category: "Doğa",
  ),
  WordCard(
    word: "BULUT",
    tabooWords: ["Gökyüzü", "Yağmur", "Beyaz", "Hava", "Gölge"],
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
    word: "SİS",
    tabooWords: ["Görüş", "Kısıtlı", "Hava", "Yüzey", "Görememek"],
    category: "Doğa",
  ),
  WordCard(
    word: "MAĞARA",
    tabooWords: ["Karanlık", "Yeraltı", "Taş", "Eski Çağ", "İbrahim Tatlıses"],
    category: "Doğa",
  ),
  WordCard(
    word: "KAYA",
    tabooWords: ["Taş", "Sert", "Dağ", "Büyük", "Doğa"],
    category: "Doğa",
  ),
  WordCard(
    word: "ÇAMUR",
    tabooWords: ["Islak", "Toprak", "Kirli", "Yağmur", "Zemin"],
    category: "Doğa",
  ),
  WordCard(
    word: "YILDIZ",
    tabooWords: ["Gece", "Gökyüzü", "Işık", "Uzay", "Parlak"],
    category: "Doğa",
  ),
  WordCard(
    word: "AY",
    tabooWords: ["Gece", "Uydu", "Gök", "Dolunay", "Işık"],
    category: "Doğa",
  ),
  WordCard(
    word: "GÜNEŞ",
    tabooWords: ["Sıcak", "Işık", "Gündüz", "Yıldız", "Gökyüzü"],
    category: "Doğa",
  ),
  WordCard(
    word: "EKOSİSTEM",
    tabooWords: ["Canlı", "Doğa", "Denge", "Çevre", "Sistem"],
    category: "Doğa",
  ),
  WordCard(
    word: "BİTKİ",
    tabooWords: ["Yeşil", "Toprak", "Büyümek", "Canlı", "Doğa"],
    category: "Doğa",
  ),
  WordCard(
    word: "HAYVAN",
    tabooWords: ["Canlı", "Doğa", "Tür", "Yaşamak", "Vahşi"],
    category: "Doğa",
  ),
  WordCard(
    word: "OKSİJEN",
    tabooWords: ["Hava", "Nefes", "Gaz", "Ağaç", "Yaşam"],
    category: "Doğa",
  ),
  WordCard(
    word: "AĞAÇ",
    tabooWords: ["Orman", "Oksijen", "Yaprak", "Dal", "Çam"],
    category: "Doğa",
  ),
  WordCard(
    word: "YILDIRIM",
    tabooWords: ["Elektrik", "Gökyüzü", "Fırtına", "Parlak", "Çakmak"],
    category: "Doğa",
  ),
  WordCard(
    word: "BATAKLIK",
    tabooWords: ["Islak", "Çamur", "Su", "Sazlık", "Kurbağa"],
    category: "Doğa",
  ),
  // Teknoloji Kategori
  WordCard(
    word: "BİLGİSAYAR",
    tabooWords: ["Monitör", "Klavye", "Fare", "Kasa", "Macbook"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "AKILLI TELEFON",
    tabooWords: ["Dokunmatik", "iPhone", "Android", "Cep", "Kamera"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "İNTERNET",
    tabooWords: ["Mobil Veri", "Tarayıcı", "Çevrimiçi", "WiFi", "Ağ"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "Wi-Fi",
    tabooWords: ["Kablosuz", "İnternet", "Modem", "Şifre", "Ağ"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "YAZILIMCI",
    tabooWords: ["Kod", "Web Sitesi", "Bilgisayar", "Uygulama", "Hacker"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "UYGULAMA",
    tabooWords: ["Telefon", "Program", "İndirmek", "Mobil", "Mağaza"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "OYUN",
    tabooWords: ["Oynamak", "Konsol", "Kazanmak", "Eğlence", "Skor"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "KONSOL",
    tabooWords: ["Oyun", "PlayStation", "Xbox", "Kontrolcü", "Televizyon"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "E-POSTA",
    tabooWords: ["Mail", "Mesaj", "Göndermek", "Atmak", "Adres"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "TARAYICI",
    tabooWords: ["Chrome", "Safari", "İnternet", "Site", "Açmak"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "ARAMA MOTORU",
    tabooWords: ["Google", "Yandex", "Bulmak", "İnternet", "Yazmak"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "YAPAY ZEKA",
    tabooWords: ["Makine", "Öğrenme", "Algoritma", "ChatGPT", "Sormak"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "ŞARJ",
    tabooWords: ["Pil", "Dolmak", "Telefon", "Azalmak", "Batarya"],
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
    tabooWords: ["Kablo", "Takmak", "Bağlamak", "Bilgisayar", "Flaş"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "BLUETOOTH",
    tabooWords: ["Kablosuz", "Bağlantı", "Kulaklık", "Telefon", "Araba"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "KULAKLIK",
    tabooWords: ["Ses", "Müzik", "Takmak", "Bluetooth", "Dinlemek"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "DRONE",
    tabooWords: ["Uçurmak", "Kumanda", "Uzaktan", "Hava", "Kontrol"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "NAVİGASYON",
    tabooWords: ["Harita", "Yol", "Tarif", "Adres", "Gitmek"],
    category: "Teknoloji",
  ),

  // Tarih Kategori
  WordCard(
    word: "ATATÜRK",
    tabooWords: [
      "Cumhuriyet",
      "Mustafa Kemal",
      "Türkiye",
      "Lider",
      "Anıtkabir",
    ],
    category: "Tarih",
  ),
  WordCard(
    word: "CUMHURİYET",
    tabooWords: ["Türkiye", "Kemalizm", "Yönetim", "Monarşi", "1923"],
    category: "Tarih",
  ),
  WordCard(
    word: "MODERN ÇAĞ",
    tabooWords: ["Tarih", "Buluş", "Rönesans", "Dönem", "Başlangıç"],
    category: "Tarih",
  ),
  WordCard(
    word: "ROMA",
    tabooWords: ["İmparatorluk", "Sezar", "Antik", "İtalya", "Ordu"],
    category: "Tarih",
  ),
  WordCard(
    word: "SEZAR",
    tabooWords: ["Roma", "İmparator", "Senato", "Suikast", "Salata"],
    category: "Tarih",
  ),
  WordCard(
    word: "FRANSIZ DEVRİMİ",
    tabooWords: ["1789", "Paris", "Bastille", "Özgürlük", "Giyotin"],
    category: "Tarih",
  ),
  WordCard(
    word: "KOLOMB",
    tabooWords: ["Amerika", "Keşif", "Gemi", "1492", "Kaşif"],
    category: "Tarih",
  ),
  WordCard(
    word: "SOVYETLER",
    tabooWords: ["Rusya", "Komünist", "SSCB", "Lenin", "Soğuk Savaş"],
    category: "Tarih",
  ),
  WordCard(
    word: "SANAYİ DEVRİMİ",
    tabooWords: ["Fabrika", "Makine", "İngiltere", "Buhar", "Üretim"],
    category: "Tarih",
  ),
  WordCard(
    word: "HAÇLI SEFERLERİ",
    tabooWords: ["Orta Çağ", "Kudüs", "Din", "Avrupa", "Savaş"],
    category: "Tarih",
  ),
  WordCard(
    word: "ORTA ÇAĞ",
    tabooWords: ["Şövalye", "Kale", "Feodal", "Avrupa", "Karanlık"],
    category: "Tarih",
  ),
  WordCard(
    word: "HİTLER",
    tabooWords: ["Almanya", "Nazi", "Savaş", "Diktatör", "Soykırım"],
    category: "Tarih",
  ),
  WordCard(
    word: "OSMANLI",
    tabooWords: ["İmparatorluk", "Padişah", "Devlet", "Tarih", "Beylik"],
    category: "Tarih",
  ),
  WordCard(
    word: "İSTANBUL'UN FETHİ",
    tabooWords: ["1453", "Fatih Sultan Mehmet", "Kara", "Bizans", "Gemi"],
    category: "Tarih",
  ),
  WordCard(
    word: "PADİŞAH",
    tabooWords: ["Osmanlı", "Taht", "Saray", "Hükümdar", "Sibel Can"],
    category: "Tarih",
  ),
  WordCard(
    word: "SARAY",
    tabooWords: ["Padişah", "Osmanlı", "Külliye", "Şatafat", "Taht"],
    category: "Tarih",
  ),
  WordCard(
    word: "KURTULUŞ SAVAŞI",
    tabooWords: ["Atatürk", "Misak-ı Milli", "İtilaf", "Bağımsızlık", "Yunan"],
    category: "Tarih",
  ),
  WordCard(
    word: "ANAYASA",
    tabooWords: ["Kanun", "Cumhuriyet", "Hak", "Kural", "Madde"],
    category: "Tarih",
  ),
  WordCard(
    word: "MECLİS",
    tabooWords: ["TBMM", "Milletvekili", "Yasa", "Toplantı", "Ankara"],
    category: "Tarih",
  ),
  WordCard(
    word: "ANKARA",
    tabooWords: ["Başkent", "Türkiye", "Meclis", "Atatürk", "Şehir"],
    category: "Tarih",
  ),
  WordCard(
    word: "KRAL",
    tabooWords: ["Taht", "Hünkar", "Hükümdar", "Taç", "Yönetmek"],
    category: "Tarih",
  ),
  WordCard(
    word: "KRALİÇE",
    tabooWords: ["Taht", "Krallık", "Kadın", "Taç", "Yönetmek"],
    category: "Tarih",
  ),
  WordCard(
    word: "MÜZE",
    tabooWords: ["Tarih", "Eser", "Sergi", "Gezmek", "Bina"],
    category: "Tarih",
  ),
  WordCard(
    word: "RÖNESANS",
    tabooWords: ["Avrupa", "Sanat", "Reform", "Tarih", "Dönem"],
    category: "Tarih",
  ),
  WordCard(
    word: "UYGARLIK",
    tabooWords: ["Medeniyet", "Toplum", "Tarih", "Kültür", "Eski"],
    category: "Tarih",
  ),
  WordCard(
    word: "KÜLTÜR",
    tabooWords: ["Uygarlık", "Toplum", "Gelenek", "Tarih", "Gelişim"],
    category: "Tarih",
  ),
  WordCard(
    word: "İPEK YOLU",
    tabooWords: ["Ticaret", "Çin", "Kervan", "Yol", "Antik"],
    category: "Tarih",
  ),
  WordCard(
    word: "ATOM BOMBASI",
    tabooWords: ["Hiroşima", "Nükleer", "Japon", "Patlama", "Savaş"],
    category: "Tarih",
  ),
  WordCard(
    word: "SÖMÜRGE",
    tabooWords: ["İşgal", "Kontrol", "Avrupa", "Afrika", "Bağımsızlık"],
    category: "Tarih",
  ),
  WordCard(
    word: "TRUVA ATI",
    tabooWords: ["Yunan", "Efsane", "Savaş", "Hile", "Homeros"],
    category: "Tarih",
  ),
  // Futbol
  WordCard(
    word: "GOL",
    tabooWords: ["Takım", "Maç", "Futbol", "Top", "Atmak"],
    category: "Futbol",
  ),
  WordCard(
    word: "PENALTI",
    tabooWords: ["Ceza Sahası", "Beyaz Nokta", "Hakem", "Atış", "El"],
    category: "Futbol",
  ),
  WordCard(
    word: "OFSAYT",
    tabooWords: ["Çizgi", "Yakalanmak", "Bayrak", "Yan Hakem", "Pozisyon"],
    category: "Futbol",
  ),
  WordCard(
    word: "TAÇ",
    tabooWords: ["Kenar", "Çizgi", "Atış", "Yan Hakem", "Dışarı"],
    category: "Futbol",
  ),
  WordCard(
    word: "KORNER",
    tabooWords: ["Köşe", "Vuruş", "Top", "Atış", "Ceza Sahası"],
    category: "Futbol",
  ),
  WordCard(
    word: "FORVET",
    tabooWords: ["Golcü", "Hücum", "Santrafor", "İleri", "Mevki"],
    category: "Futbol",
  ),
  WordCard(
    word: "DEFANS",
    tabooWords: ["Savunma", "Stoper", "Geri", "Kale", "Mevki"],
    category: "Futbol",
  ),
  WordCard(
    word: "KALECİ",
    tabooWords: ["Eldiven", "Kale", "Kurtarış", "File", "1 Numara"],
    category: "Futbol",
  ),
  WordCard(
    word: "HAKEM",
    tabooWords: ["Düdük", "Kart", "Yönetmek", "Faul", "Maç"],
    category: "Futbol",
  ),
  WordCard(
    word: "VAR",
    tabooWords: ["Kontrol", "İnceleme", "Hakem", "Teknoloji", "Pozisyon"],
    category: "Futbol",
  ),
  WordCard(
    word: "TRİBÜN",
    tabooWords: ["Taraftar", "Stat", "Bağırmak", "Koltuk", "Eski Açık"],
    category: "Futbol",
  ),
  WordCard(
    word: "TARAFTAR",
    tabooWords: ["Destek", "Takım", "Tribün", "Forma", "12. Adam"],
    category: "Futbol",
  ),
  WordCard(
    word: "DERBİ",
    tabooWords: ["Ezeli Rakip", "Şehir", "Büyük Maç", "Yaka", "Rekabet"],
    category: "Futbol",
  ),
  WordCard(
    word: "TRANSFER",
    tabooWords: ["Kulüp", "Oyuncu", "İmza", "Sözleşme", "Bedel"],
    category: "Futbol",
  ),
  WordCard(
    word: "TAKIM KAPTANI",
    tabooWords: ["Pazu Bandı", "Lider", "Maç", "Saha", "Yönetmek"],
    category: "Futbol",
  ),
  WordCard(
    word: "UZATMA",
    tabooWords: ["Dakika", "Ek", "4. Hakem", "Süre", "Maç"],
    category: "Futbol",
  ),
  WordCard(
    word: "MEŞİN YUVARLAK",
    tabooWords: ["Top Toplayıcı", "Orta", "Şut", "Pas", "Ayak"],
    category: "Futbol",
  ),
  WordCard(
    word: "FORMASYON",
    tabooWords: ["Diziliş", "Baklava", "Taktik", "Sistem", "Kadro"],
    category: "Futbol",
  ),
  WordCard(
    word: "DRİBLİNG",
    tabooWords: ["Adam Geçmek", "Top Sürmek", "Çalım", "Sürat", "Bilek"],
    category: "Futbol",
  ),
  WordCard(
    word: "PAS",
    tabooWords: ["Atmak", "Top", "Kısa", "Uzun", "Futbolcu"],
    category: "Futbol",
  ),
  WordCard(
    word: "ŞUT",
    tabooWords: ["Vurmak", "Kale", "Top", "Sert", "Denemek"],
    category: "Futbol",
  ),
  WordCard(
    word: "VOLE",
    tabooWords: ["Havadan", "Vuruş", "Top", "Zıplamak", "Şut"],
    category: "Futbol",
  ),
  WordCard(
    word: "RÖVEŞATA",
    tabooWords: ["Ters", "Yüksek", "Arkası Dönük", "Zıplamak", "Şut"],
    category: "Futbol",
  ),
  WordCard(
    word: "FAUL",
    tabooWords: ["Müdahale", "Hakem", "Düdük", "Sert", "Çalmak"],
    category: "Futbol",
  ),
  WordCard(
    word: "SARI KART",
    tabooWords: ["Uyarı", "Hakem", "Göstermek", "Kural", "Birinci"],
    category: "Futbol",
  ),
  WordCard(
    word: "KIRMIZI KART",
    tabooWords: ["Atılmak", "Hakem", "Göstermek", "Oyun Dışı", "Sert"],
    category: "Futbol",
  ),
  WordCard(
    word: "DÜDÜK",
    tabooWords: ["Hakem", "Ses", "Başlamak", "Bitirmek", "Çalmak"],
    category: "Futbol",
  ),
  WordCard(
    word: "KONTRA ATAK",
    tabooWords: ["Hızlı", "Hücum", "Savunma", "Ani", "Geçiş"],
    category: "Futbol",
  ),
  WordCard(
    word: "DEPAR",
    tabooWords: ["Sprint", "Hız", "Koşu", "Açılmak", "Kanat"],
    category: "Futbol",
  ),
  WordCard(
    word: "ANTRENMAN",
    tabooWords: ["İdman", "Çalışma", "Koşu", "Antrenör", "Kondisyon"],
    category: "Futbol",
  ),
  WordCard(
    word: "TEKNİK DİREKTÖR",
    tabooWords: ["Antrenör", "Taktik", "Hoca", "Kulübe", "Yönetim"],
    category: "Futbol",
  ),
  WordCard(
    word: "YARDIMCI HAKEM",
    tabooWords: ["Çizgi", "Bayrak", "Ofsayt", "Hakem", "Yan"],
    category: "Futbol",
  ),
  WordCard(
    word: "ŞAMPİYONLUK",
    tabooWords: ["Kupa", "Birincilik", "Sezon", "Kutlama", "Lider"],
    category: "Futbol",
  ),
  WordCard(
    word: "KUPA",
    tabooWords: ["Final", "Kaldırmak", "Şampiyon", "Ödül", "Turnuva"],
    category: "Futbol",
  ),
  WordCard(
    word: "SEZON",
    tabooWords: ["Fikstür", "Maç", "Puan", "Lig", "Yıl"],
    category: "Futbol",
  ),
  WordCard(
    word: "PUAN DURUMU",
    tabooWords: ["Sıralama", "Lig", "Puan", "Tablo", "Averaj"],
    category: "Futbol",
  ),
  WordCard(
    word: "GOL KRALI",
    tabooWords: ["En Çok", "Skorer", "Sezon", "Forvet", "Ödül"],
    category: "Futbol",
  ),
  WordCard(
    word: "JÜBİLE",
    tabooWords: ["Veda", "Emeklilik", "Futbolcu", "Maç", "Kariyer"],
    category: "Futbol",
  ),
  WordCard(
    word: "FİKSTÜR",
    tabooWords: ["Program", "Maçlar", "Takvim", "Lig", "Sıra"],
    category: "Futbol",
  ),
  WordCard(
    word: "KALE DİREĞİ",
    tabooWords: ["Hamit Altıntop", "Kale", "Dönmek", "Top", "Çerçeve"],
    category: "Futbol",
  ),
  WordCard(
    word: "BARAJ",
    tabooWords: ["Duvar", "Serbest Vuruş", "Oyuncu", "Şut", "Kale"],
    category: "Futbol",
  ),
  WordCard(
    word: "FRİKİK",
    tabooWords: ["Serbest Vuruş", "9-15", "Uzak Mesafe", "Baraj", "Kale"],
    category: "Futbol",
  ),
  WordCard(
    word: "CAMİA",
    tabooWords: ["Kulüp", "Taraftar", "Topluluk", "Renkler", "Birlik"],
    category: "Futbol",
  ),
  WordCard(
    word: "AVERAJ",
    tabooWords: ["Gol", "Fark", "Puan", "Lig", "Sıralama"],
    category: "Futbol",
  ),
  WordCard(
    word: "HAT-TRICK",
    tabooWords: ["Üç", "Gol", "Bir Maç", "Forvet", "Başarı"],
    category: "Futbol",
  ),
  WordCard(
    word: "AUT",
    tabooWords: ["Kale", "Çizgi", "Top", "Vuruş", "Oyun"],
    category: "Futbol",
  ),
  WordCard(
    word: "ŞAMPİYONLAR LİGİ",
    tabooWords: ["UEFA", "Avrupa", "Final", "Büyük Kulüp", "Türk Takımları"],
    category: "Futbol",
  ),
  WordCard(
    word: "SÜPER KUPA",
    tabooWords: [
      "Kazanan",
      "Şampiyonlar Ligi",
      "Avrupa Ligi",
      "Tek Maç",
      "Final",
    ],
    category: "Futbol",
  ),
  WordCard(
    word: "ASİST",
    tabooWords: ["Pas", "Gol", "Orta", "Katkı", "Şut"],
    category: "Futbol",
  ),
  WordCard(
    word: "STOPER",
    tabooWords: ["Defans", "Merkez", "Savunma", "Kapanmak", "Kale"],
    category: "Futbol",
  ),
  // 90'lar Nostalji
  WordCard(
    word: "WALKMAN",
    tabooWords: ["Müzik", "Kulaklık", "Kemer", "Kaset", "Taşınabilir"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "KASET",
    tabooWords: ["Müzik", "Bant", "Çalar", "Walkman", "Sarılı"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "DİSKET",
    tabooWords: ["Bilgisayar", "Küçük Boyut", "Dosya", "Sürücü", "Kare"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "ÇEVİRMELİ İNTERNET",
    tabooWords: ["Modem", "Telefon Hattı", "Bağlanmak", "Ses", "İnternet"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "NOKIA 3310",
    tabooWords: ["Telefon", "Yılan Oyunu", "Tuşlu", "Uzun Şarj", "Kırılmaz"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "ATARİ",
    tabooWords: ["Oyun", "Konsol", "Joystick", "Kartuş", "8-bit"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "TÜPLÜ TV",
    tabooWords: ["Televizyon", "Kutu", "Anten", "Büyük", "Ekran"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "ANTEN",
    tabooWords: ["Televizyon", "Çekmek", "Sinyal", "Çatı", "Yayın"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "MİSKET",
    tabooWords: ["Bilye", "Oyun", "Cam", "Yuvarlak", "Çocuk"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "BEŞTAŞ",
    tabooWords: ["Avuç", "Yer", "Atmak", "Çocuk", "Zemin"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "SEKSEK",
    tabooWords: ["Çizmek", "Zemin", "Kare", "Atlama", "Tebeşir"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "İP ATLAMA",
    tabooWords: ["Çevirmek", "Çocuk", "Zıplamak", "Saymak", "Dairesel"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "TASO",
    tabooWords: ["Cips", "Karton", "Koleksiyon", "Oyun", "Çıkarmak"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "ÇAĞRI CİHAZI",
    tabooWords: ["Mesaj", "Kemer", "Bip", "Telefon", "Numara"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "TELEFON KULÜBESİ",
    tabooWords: ["Jeton", "Arama", "Cam", "Sokak", "Telefon"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "JETON",
    tabooWords: ["Para", "Telefon", "Metal", "Atmak", "Kulübe"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "POKEMON",
    tabooWords: ["Pikachu", "Anime", "Kart", "Toplamak", "Çizgi Film"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "TETRİS",
    tabooWords: ["Blok", "Oyun", "Düşmek", "Puzzle", "Atari"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "WINAMP",
    tabooWords: ["Müzik", "Çalar", "MP3", "Bilgisayar", "Program"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "MSN",
    tabooWords: ["Messenger", "Sohbet", "İnternet", "Yeşil", "İleti"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "WINDOWS 95",
    tabooWords: ["Microsoft", "Bilgisayar", "Başlat", "Masaüstü", "Sistem"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "VİDEO KASET",
    tabooWords: ["VHS", "Film", "Video", "Kutu", "Oynatıcı"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "ÖNLÜK",
    tabooWords: ["Okul", "Mavi", "Kıyafet", "Düğme", "Öğrenci"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "OYUN SALONU",
    tabooWords: ["Oyun", "Jeton", "Makine", "Salon", "Atari"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "KARTUŞ",
    tabooWords: ["Oyun", "Konsol", "Takmak", "Atari", "Nintendo"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "TELEFON REHBERİ",
    tabooWords: ["Numara", "Sayfa", "Kitap", "İsim", "Aramak"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "FAKS MAKİNESİ",
    tabooWords: ["Belge", "Göndermek", "Telefon", "Kağıt", "Cihaz"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "İNTERNET KAFE",
    tabooWords: ["Bilgisayar", "Oyun", "Saat", "Mekan", "Bağlanmak"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "TEBEŞİR",
    tabooWords: ["Tahta", "Toz", "Yazı", "Okul", "Beyaz"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "FOTOĞRAF FİLMİ",
    tabooWords: ["Makine", "Poz", "Banyo", "Negatif", "Rulo"],
    category: "90'lar Nostalji",
  ),
  // Zor Seviye
  WordCard(
    word: "PARADOKS",
    tabooWords: ["Çelişki", "Mantık", "Ters", "Görünmek", "Sonuç"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "METAFOR",
    tabooWords: ["Benzetme", "Mecaz", "Anlam", "Söz", "Edebiyat"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "ENTROPİ",
    tabooWords: ["Termodinamik", "Dağınıklık", "Isı", "Sistem", "Düzensizlik"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "SİNERJİ",
    tabooWords: ["Birlik", "Etki", "Enerji", "Takım", "Toplam"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "HEGEMONYA",
    tabooWords: ["Üstünlük", "Hakimiyet", "Güç", "Egemenlik", "Lider"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "PARADİGMA",
    tabooWords: ["Model", "Örnek", "Bakış Açısı", "Çerçeve", "Değişim"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "METAFİZİK",
    tabooWords: ["Fizik Ötesi", "Felsefe", "Varlık", "Ruh", "Gerçeklik"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "KUANTUM",
    tabooWords: ["Parçacık", "Fizik", "Atom", "Ölçek", "Enerji"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "KRİPTOGRAFİ",
    tabooWords: ["Şifre", "Güvenlik", "Kod", "Gizlilik", "Anahtar"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "ALGORİTMA",
    tabooWords: ["Adım", "Problem", "Çözüm", "Kod", "Sıra"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "SÜBLİMİNAL",
    tabooWords: ["Bilinçaltı", "Mesaj", "Gizli", "Fark Etmek", "Reklam"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "KAUSALİTE",
    tabooWords: ["Sebep", "Sonuç", "Nedensellik", "İlişki", "Bağ"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "SEMANTİK",
    tabooWords: ["Anlam", "Dil", "Sözcük", "İçerik", "Mantık"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "MORFOLOJİ",
    tabooWords: ["Biçim", "Dil", "Yapı", "Kelime", "İnceleme"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "HOMEOSTAZ",
    tabooWords: ["Denge", "Vücut", "Sistem", "Isı", "Koruma"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "İZOMER",
    tabooWords: ["Kimya", "Aynı", "Formül", "Farklı", "Molekül"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "PALİNDROM",
    tabooWords: ["Ters", "Kelime", "Aynı", "Okumak", "Harf"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "HİYERARŞİ",
    tabooWords: ["Sıralama", "Üst", "Alt", "Düzen", "Seviye"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "KONJONKTÜR",
    tabooWords: ["Ekonomi", "Dönem", "Koşul", "Durum", "Piyasa"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "JEOPOLİTİK",
    tabooWords: ["Coğrafya", "Siyaset", "Ülke", "Güç", "Strateji"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "ASTROFİZİK",
    tabooWords: ["Uzay", "Yıldız", "Fizik", "Evren", "Galaksi"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "EPİDEMİYOLOJİ",
    tabooWords: ["Hastalık", "Salgın", "Sağlık", "Araştırma", "Toplum"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "KATALİZÖR",
    tabooWords: ["Kimya", "Reaksiyon", "Hız", "Enzim", "Etki"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "OSMOZ",
    tabooWords: ["Sıvı", "Geçiş", "Hücre", "Zar", "Yoğunluk"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "İZOTOP",
    tabooWords: ["Atom", "Nötron", "Element", "Çekirdek", "Radyoaktif"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "EMPİRİK",
    tabooWords: ["Deney", "Gözlem", "Veri", "Bilim", "Kanıt"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "İNFERANS",
    tabooWords: ["Çıkarım", "Sonuç", "Mantık", "Veri", "Tahmin"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "PERSEPSİYON",
    tabooWords: ["Algı", "Duyu", "Görme", "Beyin", "Yorum"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "KOGNİTİF",
    tabooWords: ["Zihin", "Düşünme", "Bellek", "Biliş", "Psikoloji"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "ENTELEKTÜEL",
    tabooWords: ["Aydın", "Düşünür", "Kültür", "Zeka", "Okumak"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "MÜPHEM",
    tabooWords: ["Belirsiz", "Muğlak", "Net", "Anlam", "Açık"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "RETORİK",
    tabooWords: ["Hitabet", "Söz", "İkna", "Dil", "Konuşma"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "NİHİLİZM",
    tabooWords: ["Hiçlik", "Felsefe", "İnanç", "Anlam", "Yok"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "ABSÜRT",
    tabooWords: ["Saçma", "Mantıksız", "Tuhaf", "Komik", "Dram"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "REDÜKSİYON",
    tabooWords: ["Azaltma", "Kimya", "Elektron", "İndirgeme", "Reaksiyon"],
    category: "Zor Seviye",
  ),
  // Gece Yarısı
  WordCard(
    word: "ÖN SEVİŞME",
    tabooWords: ["Dokunmak", "Öpüşmek", "Isınmak", "Başlangıç", "Islanmak"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "FANTEZİ",
    tabooWords: ["Hayal", "Rol", "İstek", "Düş", "Senaryo"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "AZGINLIK",
    tabooWords: [
      "İstemek",
      "Arzulamak",
      "Tahrik",
      "Yanmak",
      "Kendini Kaybetmek",
    ],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "SEVİŞMEK",
    tabooWords: ["Cinsel", "Birlikte", "Yakınlık", "Ten", "Seks"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "FRANSIZ ÖPÜCÜĞÜ",
    tabooWords: ["Dil", "Ağız", "Derin", "Öpüşmek", "Tutkulu"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "TAHRİK",
    tabooWords: ["Azmak", "Uyandırmak", "Kışkırtmak", "İstek", "Etkilemek"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "CİNSEL GERİLİM",
    tabooWords: ["Bekleyiş", "Dokunmamak", "Bakış", "Sessizlik", "Elektrik"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "SERTLEŞMEK",
    tabooWords: ["Uyarılmak", "Erkek", "Penis", "Kalkmak", "İnmemek"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "ISLANMAK",
    tabooWords: ["Kadın", "Uyarılmak", "Haz", "Azgınlık", "Sırılsıklam"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "BOŞALMAK",
    tabooWords: ["Zirve", "Rahatlamak", "Mutlu Son", "Titremek", "İnlemek"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "ORGAZM",
    tabooWords: ["Zirve", "Boşalmak", "Kasılmak", "Titremek", "Haz"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "İHTİRAS",
    tabooWords: ["Tutku", "Doyumsuzluk", "Arzu", "Şehvet", "Aşırı"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "ROL YAPMAK",
    tabooWords: ["Karakter", "Fantezi", "Oyun", "Senaryo", "Canlandırma"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "CİNSEL ÇEKİM",
    tabooWords: ["Kimya", "Elektrik", "Arzu", "İstek", "Mıknatıs"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "TEK GECELİK İLİŞKİ",
    tabooWords: ["Gece", "Yatak", "Gizli", "Ani", "Tutkulu"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "PERFORMANS KAYGISI",
    tabooWords: ["Heyecan", "İlk Kez", "Stres", "Düşünmek", "Baskı"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "MİSYONER",
    tabooWords: ["Üstte", "Yüz Yüze", "Yatak", "Klasik", "Pozisyon"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "İNLEMEK",
    tabooWords: ["İnim inim", "Ses", "Bağırmak", "Dayanamamak", "Zevk"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "DUŞTA SEVİŞMEK",
    tabooWords: ["Banyo", "Islak", "Kaygan", "Ayakta", "Yakın"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "ORAL",
    tabooWords: ["Ağız", "Dil", "Aşağı", "Haz", "Yalamak"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "ANAL",
    tabooWords: ["Arkadan", "Farklı", "Dar", "Risk", "Haz"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "SEXTING",
    tabooWords: ["Mesaj", "Yazışmak", "Telefon", "İma", "Azdırmak"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "NUDE",
    tabooWords: ["Çıplak", "Fotoğraf", "Telefon", "Kadın", "Gizli"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "DICK PIC",
    tabooWords: ["Fotoğraf", "Telefon", "Erkek", "Göndermek", "Penis"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "ŞAPLAK",
    tabooWords: ["El", "Kalça", "Ses", "Hafif", "Oyun"],
    category: "Gece Yarısı",
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
    word: "BACKPACK",
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
    tabooWords: ["Window", "Sun", "Close", "Light", "Home"],
    category: "Genel",
  ),
  WordCard(
    word: "CARPET",
    tabooWords: ["Floor", "Home", "Pattern", "Foot", "Lay"],
    category: "Genel",
  ),
  WordCard(
    word: "CABINET",
    tabooWords: ["Clothes", "Door", "Kitchen", "Shelf", "Store"],
    category: "Genel",
  ),
  WordCard(
    word: "COLOGNE",
    tabooWords: ["Alcohol", "Liquid", "Hand", "Smell", "Disinfection"],
    category: "Genel",
  ),
  WordCard(
    word: "TV REMOTE",
    tabooWords: ["Control", "Button", "Battery", "Channel", "Change"],
    category: "Genel",
  ),
  WordCard(
    word: "LAMP",
    tabooWords: ["Light", "Darkness", "Bulb", "Night", "Turn On"],
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
    tabooWords: ["Sit", "Table", "Step Up", "Leg", "Home"],
    category: "Genel",
  ),
  WordCard(
    word: "TABLE",
    tabooWords: ["Food", "Kitchen", "Leg", "Top", "Furniture"],
    category: "Genel",
  ),
  WordCard(
    word: "BLANKET",
    tabooWords: ["Cold", "Cover", "Bed", "Warm", "Top"],
    category: "Genel",
  ),
  WordCard(
    word: "DRAWER",
    tabooWords: ["Cabinet", "Open", "Shelf", "Store", "Furniture"],
    category: "Genel",
  ),
  WordCard(
    word: "OVEN",
    tabooWords: ["Food", "Heat", "Kitchen", "Bake", "Cook"],
    category: "Genel",
  ),
  WordCard(
    word: "VACUUM CLEANER",
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
    tabooWords: ["Key", "Door", "Security", "Open", "Safe"],
    category: "Genel",
  ),
  WordCard(
    word: "WINDOW",
    tabooWords: ["Glass", "Curtain", "Open", "Wall", "Room"],
    category: "Genel",
  ),
  WordCard(
    word: "SOFA",
    tabooWords: ["Sit", "Living Room", "Comfort", "Furniture", "Lay Down"],
    category: "Genel",
  ),
  WordCard(
    word: "TOWEL",
    tabooWords: ["Bathroom", "Dry", "Water", "Toilet", "Hand"],
    category: "Genel",
  ),
  WordCard(
    word: "SOAP",
    tabooWords: ["Wash", "Foam", "Cleaning", "Bathroom", "Hand"],
    category: "Genel",
  ),
  WordCard(
    word: "TOOTHBRUSH",
    tabooWords: ["White", "Paste", "Mouth", "Dentist", "Bathroom"],
    category: "Genel",
  ),
  WordCard(
    word: "SUITCASE",
    tabooWords: ["Travel", "Luggage", "Clothes", "Carry", "Trip"],
    category: "Genel",
  ),
  WordCard(
    word: "NOTEPAD",
    tabooWords: ["Write", "Small", "Carry", "Page", "Pen"],
    category: "Genel",
  ),
  WordCard(
    word: "SLIPPERS",
    tabooWords: ["Home", "Foot", "Floor", "Wear", "Inside"],
    category: "Genel",
  ),
  WordCard(
    word: "CALENDAR",
    tabooWords: ["Day", "Month", "Year", "Date", "Time"],
    category: "Genel",
  ),
  WordCard(
    word: "BOX",
    tabooWords: ["Put", "Carry", "Store", "Cardboard", "Inside"],
    category: "Genel",
  ),
  WordCard(
    word: "CLOTHESPIN",
    tabooWords: ["Laundry", "Hang", "Balcony", "Clip", "Rope"],
    category: "Genel",
  ),
  WordCard(
    word: "LIGHTER",
    tabooWords: ["Fire", "Pocket", "Cigarette", "Gas", "Spark"],
    category: "Genel",
  ),

  // Art Category
  WordCard(
    word: "MONA LISA",
    tabooWords: ["Painting", "Leonardo", "Smile", "Art", "Woman"],
    category: "Sanat",
  ),
  WordCard(
    word: "PICASSO",
    tabooWords: ["Painter", "Drawing", "Painting", "Spain", "Modern"],
    category: "Sanat",
  ),
  WordCard(
    word: "VAN GOGH",
    tabooWords: ["Painter", "Ear", "Starry", "Netherlands", "Painting"],
    category: "Sanat",
  ),
  WordCard(
    word: "SCULPTURE",
    tabooWords: ["Stone", "Statue", "Carve", "Figure", "Artist"],
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
    tabooWords: ["Dance", "Performance", "Stage", "Music", "Graceful"],
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
    tabooWords: ["Nature", "Beautiful", "Mountain", "Sea", "Picture"],
    category: "Sanat",
  ),
  WordCard(
    word: "CARTOON",
    tabooWords: ["Drawing", "Humor", "Exaggeration", "Magazine", "Funny"],
    category: "Sanat",
  ),
  WordCard(
    word: "GRAFFITI",
    tabooWords: ["Wall", "Spray", "Street", "Art", "Paint"],
    category: "Sanat",
  ),
  WordCard(
    word: "PHOTOGRAPH",
    tabooWords: ["Camera", "Shoot", "Image", "Light", "Frame"],
    category: "Sanat",
  ),
  WordCard(
    word: "CINEMA",
    tabooWords: ["Movie", "Absolute", "Screen", "Actor", "Director"],
    category: "Sanat",
  ),
  WordCard(
    word: "DIRECTOR",
    tabooWords: ["Movie", "Series", "Set", "Directive", "Actor"],
    category: "Sanat",
  ),
  WordCard(
    word: "SCREENPLAY",
    tabooWords: ["Movie", "Writing", "Story", "Scene", "Script"],
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
    word: "COMPOSER",
    tabooWords: ["Music", "Note", "Write", "Mix", "Piece"],
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
    tabooWords: ["Bow", "String", "Music", "Play", "Neck"],
    category: "Sanat",
  ),
  WordCard(
    word: "PIANO",
    tabooWords: ["Key", "Music", "Play", "Note", "Grand"],
    category: "Sanat",
  ),
  WordCard(
    word: "EXHIBITION",
    tabooWords: ["Art", "Gallery", "Work", "Visit", "Painting"],
    category: "Sanat",
  ),
  WordCard(
    word: "MUSEUM",
    tabooWords: ["History", "Artifact", "Exhibition", "Visit", "Old"],
    category: "Sanat",
  ),
  WordCard(
    word: "COSTUME",
    tabooWords: ["Clothing", "Stage", "Party", "Theater", "Makeup"],
    category: "Sanat",
  ),
  WordCard(
    word: "SET DESIGN",
    tabooWords: ["Stage", "Background", "Theater", "Prop", "Location"],
    category: "Sanat",
  ),
  WordCard(
    word: "MAKEUP",
    tabooWords: ["Face", "Stage", "Woman", "Cosmetics", "Prep"],
    category: "Sanat",
  ),
  WordCard(
    word: "EDITING",
    tabooWords: ["Shoot", "Cut", "Montage", "Scene", "Video"],
    category: "Sanat",
  ),
  WordCard(
    word: "MONTAGE",
    tabooWords: ["Video", "Cut", "Film", "Editing", "Computer"],
    category: "Sanat",
  ),
  WordCard(
    word: "BANNER",
    tabooWords: ["Promotion", "Hang", "Wall", "Poster", "Ad"],
    category: "Sanat",
  ),
  WordCard(
    word: "POSTER",
    tabooWords: ["Wall", "Movie", "Picture", "Hang", "Large"],
    category: "Sanat",
  ),
  WordCard(
    word: "CARTOON MOVIE",
    tabooWords: ["Animation", "Kids", "Character", "TV", "Voice Acting"],
    category: "Sanat",
  ),
  WordCard(
    word: "ANIMATION",
    tabooWords: ["Drawing", "Motion", "Film", "Character", "Computer"],
    category: "Sanat",
  ),
  WordCard(
    word: "COMEDY",
    tabooWords: ["Laughter", "Funny", "Romantic", "Humor", "Genre"],
    category: "Sanat",
  ),
  WordCard(
    word: "DRAMA",
    tabooWords: ["Film", "Emotion", "Cry", "Genre", "Story"],
    category: "Sanat",
  ),
  WordCard(
    word: "CLASSICAL MUSIC",
    tabooWords: ["Orchestra", "Art", "Mozart", "Concert", "Old"],
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
    tabooWords: ["Living", "Microscope", "DNA", "Biology", "Structure"],
    category: "Bilim",
  ),
  WordCard(
    word: "DNA",
    tabooWords: ["Gene", "Heredity", "Cell", "Biology", "Transfer"],
    category: "Bilim",
  ),
  WordCard(
    word: "GENE",
    tabooWords: ["DNA", "Heredity", "Mother", "Father", "Child"],
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
    tabooWords: ["Experiment", "Material", "Reaction", "Laboratory", "Match"],
    category: "Bilim",
  ),
  WordCard(
    word: "PHYSICS",
    tabooWords: ["Force", "Motion", "Energy", "Body", "Newton"],
    category: "Bilim",
  ),
  WordCard(
    word: "BIOLOGY",
    tabooWords: ["Living", "Cell", "Molecular", "Human", "Life"],
    category: "Bilim",
  ),
  WordCard(
    word: "EXPERIMENT",
    tabooWords: ["Laboratory", "Test", "Scientist", "Result", "Research"],
    category: "Bilim",
  ),
  WordCard(
    word: "LABORATORY",
    tabooWords: ["Experiment", "Scientist", "Chemistry", "Tube", "Research"],
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
    tabooWords: ["Universe", "Star", "Planet", "Void", "Astronomy"],
    category: "Bilim",
  ),
  WordCard(
    word: "PLANET",
    tabooWords: ["Earth", "Space", "Sun", "Saturn", "Jupiter"],
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
    tabooWords: ["Space", "Planet", "Star", "Sky", "Telescope"],
    category: "Bilim",
  ),
  WordCard(
    word: "EVOLUTION",
    tabooWords: ["Change", "Living", "Time", "Present", "Past"],
    category: "Bilim",
  ),
  WordCard(
    word: "ECOSYSTEM",
    tabooWords: ["Living", "Nature", "Balance", "Environment", "Cycle"],
    category: "Bilim",
  ),
  WordCard(
    word: "CLIMATE",
    tabooWords: ["Season", "Weather", "Temperature", "Earth", "Change"],
    category: "Bilim",
  ),
  WordCard(
    word: "AIR",
    tabooWords: ["Breath", "Atmosphere", "Gas", "Wind", "Oxygen"],
    category: "Bilim",
  ),
  WordCard(
    word: "WATER",
    tabooWords: ["Liquid", "Drink", "Life", "Basic Need", "Sea"],
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
    word: "SUSHI",
    tabooWords: ["Rice", "Fish", "Japanese", "Roll", "Seaweed"],
    category: "Yemek",
  ),
  WordCard(
    word: "PASTA",
    tabooWords: ["Noodles", "Italian", "Spaghetti", "Sauce", "Boil"],
    category: "Yemek",
  ),
  WordCard(
    word: "COFFEE",
    tabooWords: ["Caffeine", "Bean", "Cup", "Morning", "Turkish"],
    category: "Yemek",
  ),
  WordCard(
    word: "SANDWICH",
    tabooWords: ["Bread", "Slice", "Lunch", "Meat", "Toast"],
    category: "Yemek",
  ),
  WordCard(
    word: "SALAD",
    tabooWords: ["Lettuce", "Green", "Healthy", "Vegetables", "Vegan"],
    category: "Yemek",
  ),
  WordCard(
    word: "STEAK",
    tabooWords: ["Beef", "Grill", "Rare", "Meat", "Cook"],
    category: "Yemek",
  ),
  WordCard(
    word: "CHICKEN",
    tabooWords: ["Poultry", "Fried", "Wings", "Roast", "Bird"],
    category: "Yemek",
  ),
  WordCard(
    word: "RICE",
    tabooWords: ["Grain", "White", "Declan", "Asian", "Bowl"],
    category: "Yemek",
  ),
  WordCard(
    word: "SOUP",
    tabooWords: ["Hot", "Starter", "Bowl", "Spoon", "Pot"],
    category: "Yemek",
  ),
  WordCard(
    word: "TACOS",
    tabooWords: ["Mexican", "Shell", "Meat", "Salsa", "Tortilla"],
    category: "Yemek",
  ),
  WordCard(
    word: "BURRITO",
    tabooWords: ["Wrap", "Mexican", "Beans", "Rice", "Tortilla"],
    category: "Yemek",
  ),
  WordCard(
    word: "CROISSANT",
    tabooWords: ["French", "Pastry", "Butter", "Breakfast", "Flaky"],
    category: "Yemek",
  ),
  WordCard(
    word: "DONUT",
    tabooWords: ["Sweet", "Ring", "Fried", "Sugar", "Hole"],
    category: "Yemek",
  ),
  WordCard(
    word: "PANCAKE",
    tabooWords: ["Breakfast", "Syrup", "Flat", "Butter", "Stack"],
    category: "Yemek",
  ),
  WordCard(
    word: "WAFFLE",
    tabooWords: ["Breakfast", "Grid", "Syrup", "Square", "Eleven"],
    category: "Yemek",
  ),
  WordCard(
    word: "OMELET",
    tabooWords: ["Eggs", "Fold", "Breakfast", "Pan", "Cheese"],
    category: "Yemek",
  ),
  WordCard(
    word: "BACON",
    tabooWords: ["Pork", "Crispy", "Breakfast", "Strip", "Fried"],
    category: "Yemek",
  ),
  WordCard(
    word: "CHEESE",
    tabooWords: ["Milk", "Yellow", "Slice", "Dairy", "Melt"],
    category: "Yemek",
  ),
  WordCard(
    word: "BUTTER",
    tabooWords: ["Spread", "Dairy", "Yellow", "Knife", "Cream"],
    category: "Yemek",
  ),
  WordCard(
    word: "HONEY",
    tabooWords: ["Bee", "Sweet", "Golden", "Sticky", "Natural"],
    category: "Yemek",
  ),
  WordCard(
    word: "JAM",
    tabooWords: ["Fruit", "Sweet", "Spread", "Breakfast", "Knife"],
    category: "Yemek",
  ),
  WordCard(
    word: "YOGHURT",
    tabooWords: ["Dairy", "Spoon", "Milk", "Probiotic", "Frozen"],
    category: "Yemek",
  ),
  WordCard(
    word: "CAKE",
    tabooWords: ["Birthday", "Sweet", "Slice", "Dessert", "Frosting"],
    category: "Yemek",
  ),
  WordCard(
    word: "POPCORN",
    tabooWords: ["Coke", "Movie", "Butter", "Watching", "Snack"],
    category: "Yemek",
  ),
  WordCard(
    word: "CHIPS",
    tabooWords: ["Crispy", "Potato", "Snack", "Salty", "Bag"],
    category: "Yemek",
  ),
  WordCard(
    word: "FRENCH FRIES",
    tabooWords: ["Potato", "Fried", "Salty", "Ketchup", "Golden"],
    category: "Yemek",
  ),
  WordCard(
    word: "HOT DOG",
    tabooWords: ["Sausage", "Bun", "Mustard", "Ketchup", "Fast Food"],
    category: "Yemek",
  ),
  WordCard(
    word: "KEBAB",
    tabooWords: ["Meat", "Skewer", "Grill", "Turkish", "Roast"],
    category: "Yemek",
  ),
  WordCard(
    word: "NOODLES",
    tabooWords: ["Asian", "Soup", "Long", "Ramen", "Slurp"],
    category: "Yemek",
  ),
  WordCard(
    word: "SPRING ROLL",
    tabooWords: ["Wrap", "Asian", "Fried", "Vegetable", "Crispy"],
    category: "Yemek",
  ),
  WordCard(
    word: "LASAGNA",
    tabooWords: ["Italian", "Layers", "Pasta", "Cheese", "Bake"],
    category: "Yemek",
  ),
  WordCard(
    word: "RAVIOLI",
    tabooWords: ["Italian", "Pasta", "Stuffed", "Square", "Sauce"],
    category: "Yemek",
  ),
  WordCard(
    word: "MEATBALL",
    tabooWords: ["Ground", "Round", "Sauce", "Spaghetti", "Italian"],
    category: "Yemek",
  ),
  WordCard(
    word: "BAKLAVA",
    tabooWords: ["Dessert", "Sorbet", "Pistachio", "Phyllo", "Tray"],
    category: "Yemek",
  ),
  WordCard(
    word: "SCRAMBLED EGGS",
    tabooWords: ["Egg", "Tomato", "Pepper", "Breakfast", "Pan"],
    category: "Yemek",
  ),
  WordCard(
    word: "TEA",
    tabooWords: ["Glass", "Brew", "Hot", "English", "Drink"],
    category: "Yemek",
  ),
  WordCard(
    word: "TURKISH DELIGHT",
    tabooWords: ["Dessert", "Flavor", "Soft", "Treat", "İstanbul"],
    category: "Yemek",
  ),
  WordCard(
    word: "ICE CREAM",
    tabooWords: ["Cold", "Dessert", "Summer", "Cone", "Melt"],
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

  // Sports Category
  WordCard(
    word: "SOCCER",
    tabooWords: ["Ball", "Goal", "Match", "Field", "Team"],
    category: "Spor",
  ),
  WordCard(
    word: "BASKETBALL",
    tabooWords: ["Hoop", "Dunk", "Court", "NBA", "Jam"],
    category: "Spor",
  ),
  WordCard(
    word: "VOLLEYBALL",
    tabooWords: ["Net", "Hand", "Spike", "Set", "Ball"],
    category: "Spor",
  ),
  WordCard(
    word: "TENNIS",
    tabooWords: ["Racket", "Ball", "Court", "Serve", "Ace"],
    category: "Spor",
  ),
  WordCard(
    word: "TABLE TENNIS",
    tabooWords: ["Racket", "Ball", "Serve", "Net", "Ping Pong"],
    category: "Spor",
  ),
  WordCard(
    word: "SWIMMING",
    tabooWords: ["Pool", "Sea", "Water", "Stroke", "Diving"],
    category: "Spor",
  ),
  WordCard(
    word: "RUNNING",
    tabooWords: ["Athletics", "Speed", "Track", "Breath", "Feet"],
    category: "Spor",
  ),
  WordCard(
    word: "BOXING",
    tabooWords: ["Ring", "Gloves", "Punch", "Mouthpiece", "Fighter"],
    category: "Spor",
  ),
  WordCard(
    word: "JUDO",
    tabooWords: ["Fight", "Opponent", "Throw", "Mat", "Japan"],
    category: "Spor",
  ),
  WordCard(
    word: "KARATE",
    tabooWords: ["Martial", "Kick", "Kata", "Japan", "Belt"],
    category: "Spor",
  ),
  WordCard(
    word: "FITNESS",
    tabooWords: ["Gym", "Weights", "Exercise", "Muscle", "Training"],
    category: "Spor",
  ),
  WordCard(
    word: "SKIING",
    tabooWords: ["Snow", "Mountain", "Slope", "Winter", "Slide"],
    category: "Spor",
  ),
  WordCard(
    word: "ICE SKATING",
    tabooWords: ["Sled", "Glide", "Rink", "Foot", "Cold"],
    category: "Spor",
  ),
  WordCard(
    word: "BICYCLE",
    tabooWords: ["Pedal", "Two Wheels", "Ride", "Helmet", "Handlebar"],
    category: "Spor",
  ),
  WordCard(
    word: "MOUNTAINEERING",
    tabooWords: ["Climb", "Summit", "Rope", "Slope", "Risky"],
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
    tabooWords: ["8 Ball", "Cue", "Table", "Pocket", "Hit"],
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
    word: "REFEREE",
    tabooWords: ["Match", "Rule", "Whistle", "Decision", "Manage"],
    category: "Spor",
  ),
  WordCard(
    word: "COACH",
    tabooWords: ["Team", "Train", "Teacher", "Manager", "Head"],
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
    tabooWords: ["Tree", "Green", "Fire", "Nature", "Animal"],
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
    tabooWords: ["Stream", "High", "Cascade", "Flow", "Noise"],
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
    tabooWords: ["White", "Cold", "Winter", "John", "Ice"],
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
    word: "VOLCANO",
    tabooWords: ["Lava", "Eruption", "Explode", "Fire", "Mountain"],
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
    tabooWords: ["Screen", "Keyboard", "Mouse", "Case", "Internet"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "SMARTPHONE",
    tabooWords: ["Touchscreen", "iPhone", "Android", "Mobile", "Camera"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "INTERNET",
    tabooWords: ["Cellular Data", "Browser", "Online", "WiFi", "Network"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "WI-FI",
    tabooWords: ["Wireless", "Internet", "Modem", "Password", "Network"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "DEVELOPER",
    tabooWords: ["Coder", "Website", "Computer", "App", "Hacker"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "APP",
    tabooWords: ["Phone", "Program", "Download", "Mobile", "Store"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "GAME",
    tabooWords: ["Play", "Console", "Win", "Fun", "Score"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "CONSOLE",
    tabooWords: ["Game", "PlayStation", "Xbox", "Controller", "TV"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "EMAIL",
    tabooWords: ["Mail", "Message", "Send", "Internet", "Address"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "BROWSER",
    tabooWords: ["Chrome", "Safari", "Internet", "Site", "Open"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "SEARCH ENGINE",
    tabooWords: ["Google", "Yandex", "Find", "İnternet", "Type"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "ARTIFICIAL INTELLIGENCE",
    tabooWords: ["Machine", "Learning", "Algorithm", "ChatGPT", "Ask"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "CHARGE",
    tabooWords: ["Battery", "Fill", "Phone", "Decrease", "Power"],
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
    tabooWords: ["Cable", "Plug", "Connect", "Computer", "Flash Drive"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "BLUETOOTH",
    tabooWords: ["Wireless", "Connection", "Headset", "Phone", "Carplay"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "HEADPHONES",
    tabooWords: ["Sound", "Music", "Wear", "Bluetooth", "Listen"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "DRONE",
    tabooWords: ["Fly", "Propeller", "Remote", "Air", "Control"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "NAVIGATION",
    tabooWords: ["Map", "Road", "Address", "Find", "Go"],
    category: "Teknoloji",
  ),

  // History Category
  WordCard(
    word: "ATATURK",
    tabooWords: [
      "Republic",
      "Mustafa Kemal",
      "Turkey",
      "Leader",
      "Independence",
    ],
    category: "Tarih",
  ),
  WordCard(
    word: "REVOLUTION",
    tabooWords: ["Change", "People", "Power", "Government", "War"],
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
    word: "CIVIL WAR",
    tabooWords: ["Country", "People", "Army", "Fight", "History"],
    category: "Tarih",
  ),
  WordCard(
    word: "BERLIN WALL",
    tabooWords: ["Germany", "Cold War", "East", "West", "High"],
    category: "Tarih",
  ),
  WordCard(
    word: "HOLOCAUST",
    tabooWords: ["Nazi", "Jews", "Germany", "War", "Genocide"],
    category: "Tarih",
  ),
  WordCard(
    word: "DISCOVERY OF AMERICA",
    tabooWords: ["1492", "Columbus", "New World", "Spain", "Journey"],
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
    word: "BORDER",
    tabooWords: ["Country", "Line", "Map", "Land", "Edge"],
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
    word: "MONUMENT",
    tabooWords: ["Statue", "History", "Structure", "Memory", "Stone"],
    category: "Tarih",
  ),
  WordCard(
    word: "MAGNA CARTA",
    tabooWords: ["1215", "England", "King", "Rights", "Document"],
    category: "Tarih",
  ),
  WordCard(
    word: "BLACK DEATH",
    tabooWords: ["Plague", "Europe", "Medieval", "Disease", "Virus"],
    category: "Tarih",
  ),
  WordCard(
    word: "INDUSTRIAL REVOLUTION",
    tabooWords: ["Factory", "Machine", "England", "Production", "Steam"],
    category: "Tarih",
  ),
  WordCard(
    word: "FALL OF CONSTANTINOPLE",
    tabooWords: ["1453", "Ottoman", "Byzantine", "Istanbul", "Conquest"],
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
    word: "MEDIEVAL",
    tabooWords: ["Castle", "King", "Old", "Europe", "History"],
    category: "History",
  ),
  WordCard(
    word: "COLD WAR",
    tabooWords: ["USA", "USSR", "Nuclear", "Tension", "1947"],
    category: "Tarih",
  ),
  WordCard(
    word: "CULTURE",
    tabooWords: [
      "Civilization",
      "Society",
      "Tradition",
      "History",
      "Developed",
    ],
    category: "Tarih",
  ),
  // Football
  WordCard(
    word: "GOAL",
    tabooWords: ["Net", "Score", "Ball", "Keeper", "Celebrate"],
    category: "Futbol",
  ),
  WordCard(
    word: "PENALTY",
    tabooWords: ["Spot", "Referee", "Hand", "Kick", "Keeper"],
    category: "Futbol",
  ),
  WordCard(
    word: "OFFSIDE",
    tabooWords: ["Line", "Flag", "Assistant", "Defense", "Catch"],
    category: "Futbol",
  ),
  WordCard(
    word: "THROW-IN",
    tabooWords: ["Sideline", "Hands", "Restart", "Out", "Ball"],
    category: "Futbol",
  ),
  WordCard(
    word: "CORNER",
    tabooWords: ["Flag", "Box", "Cross", "Header", "Kick"],
    category: "Futbol",
  ),
  WordCard(
    word: "STRIKER",
    tabooWords: ["Forward", "Goal", "Number 9", "Scorer", "Attacker"],
    category: "Futbol",
  ),
  WordCard(
    word: "DEFENDER",
    tabooWords: ["Goal", "Stop", "Tackle", "Block", "Backline"],
    category: "Futbol",
  ),
  WordCard(
    word: "GOALKEEPER",
    tabooWords: ["Gloves", "Save", "Net", "Diving", "Keeper"],
    category: "Futbol",
  ),
  WordCard(
    word: "REFEREE",
    tabooWords: ["Whistle", "Cards", "Foul", "Control", "Match"],
    category: "Futbol",
  ),
  WordCard(
    word: "VAR",
    tabooWords: ["Control", "Review", "Referee", "Technology", "Replay"],
    category: "Futbol",
  ),
  WordCard(
    word: "STANDS",
    tabooWords: ["Fans", "Seats", "Yelling", "Chant", "Crowd"],
    category: "Futbol",
  ),
  WordCard(
    word: "FAN",
    tabooWords: ["Supporter", "Scarf", "Team", "Chant", "Tribune"],
    category: "Futbol",
  ),
  WordCard(
    word: "DERBY",
    tabooWords: ["Rival", "City", "Big Match", "Tension", "Hate"],
    category: "Futbol",
  ),
  WordCard(
    word: "TRANSFER",
    tabooWords: ["Club", "Contract", "Fee", "Sign", "Window"],
    category: "Futbol",
  ),
  WordCard(
    word: "TEAM CAPTAIN",
    tabooWords: ["Armband", "Leader", "Pitch", "Toss", "Voice"],
    category: "Futbol",
  ),
  WordCard(
    word: "EXTRA TIME",
    tabooWords: ["Added", "Minutes", "Referee", "Tie", "Continue"],
    category: "Futbol",
  ),
  WordCard(
    word: "FORMATION",
    tabooWords: ["Park The Bus", "Tactics", "Shape", "Lineup", "System"],
    category: "Futbol",
  ),
  WordCard(
    word: "DRIBBLE",
    tabooWords: ["Skills", "Beat", "Ball", "Feet", "Control"],
    category: "Futbol",
  ),
  WordCard(
    word: "PASS",
    tabooWords: ["Match", "Ball", "Short", "Long", "Teammate"],
    category: "Futbol",
  ),
  WordCard(
    word: "SHOT",
    tabooWords: ["Kick", "Goal", "Power", "Target", "Strike"],
    category: "Futbol",
  ),
  WordCard(
    word: "VOLLEY",
    tabooWords: ["Air", "Kick", "Jump", "Ball", "Shot"],
    category: "Futbol",
  ),
  WordCard(
    word: "FOUL",
    tabooWords: ["Whistle", "Contact", "Rule", "Free Kick", "Referee"],
    category: "Futbol",
  ),
  WordCard(
    word: "YELLOW CARD",
    tabooWords: ["Warning", "Referee", "Foul", "First", "Caution"],
    category: "Futbol",
  ),
  WordCard(
    word: "HAT-TRICK",
    tabooWords: ["Three", "Goal", "Scorer", "One Match", "Perfect"],
    category: "Futbol",
  ),
  WordCard(
    word: "RED CARD",
    tabooWords: ["Sent Off", "Referee", "Second", "Foul", "Ban"],
    category: "Futbol",
  ),
  WordCard(
    word: "WHISTLE",
    tabooWords: ["Referee", "Sound", "Start", "Stop", "Blow"],
    category: "Futbol",
  ),
  WordCard(
    word: "PENALTY BOX",
    tabooWords: ["Area", "18", "Goal", "Foul", "Inside"],
    category: "Futbol",
  ),
  WordCard(
    word: "GOAL AREA",
    tabooWords: ["Six-yard", "Keeper", "Small Box", "Goal", "Line"],
    category: "Futbol",
  ),
  WordCard(
    word: "COUNTER ATTACK",
    tabooWords: ["Fast", "Break", "Defense", "Transition", "Run"],
    category: "Futbol",
  ),
  WordCard(
    word: "SPRINT",
    tabooWords: ["Speed", "Run", "Burst", "Wing", "Dash"],
    category: "Futbol",
  ),
  WordCard(
    word: "STADIUM",
    tabooWords: ["Arena", "Seats", "Fans", "Lights", "Pitch"],
    category: "Futbol",
  ),
  WordCard(
    word: "TRAINING",
    tabooWords: ["Practice", "Session", "Coach", "Fitness", "Drill"],
    category: "Futbol",
  ),
  WordCard(
    word: "COACH",
    tabooWords: ["Manager", "Tactics", "Bench", "Instructions", "Plan"],
    category: "Futbol",
  ),
  WordCard(
    word: "ASSISTANT REF",
    tabooWords: ["Line", "Flag", "Offside", "Referee", "Side"],
    category: "Futbol",
  ),
  WordCard(
    word: "CHAMPIONSHIP",
    tabooWords: ["Cup", "Title", "Winner", "Season", "Celebrate"],
    category: "Futbol",
  ),
  WordCard(
    word: "TROPHY",
    tabooWords: ["Final", "Lift", "Champion", "Prize", "Tournament"],
    category: "Futbol",
  ),
  WordCard(
    word: "SEASON",
    tabooWords: ["Fixtures", "Matches", "Table", "League", "Year"],
    category: "Futbol",
  ),
  WordCard(
    word: "LEAGUE TABLE",
    tabooWords: ["Ranking", "Points", "Table", "Average", "Top"],
    category: "Futbol",
  ),
  WordCard(
    word: "GOLDEN BOOT",
    tabooWords: ["Top Scorer", "Goals", "Award", "Season", "Striker"],
    category: "Futbol",
  ),
  WordCard(
    word: "FIXTURE",
    tabooWords: ["Schedule", "Matches", "Calendar", "Order", "List"],
    category: "Futbol",
  ),
  WordCard(
    word: "GOALPOST",
    tabooWords: ["Bar", "Frame", "Woodwork", "Crossbar", "Shot"],
    category: "Futbol",
  ),
  WordCard(
    word: "WALL",
    tabooWords: ["Free Kick", "Players", "Block", "Stand", "Barrier"],
    category: "Futbol",
  ),
  WordCard(
    word: "FREE KICK",
    tabooWords: ["Foul", "Referee", "Shot", "Wall", "Direct"],
    category: "Futbol",
  ),
  WordCard(
    word: "CLUB",
    tabooWords: ["Colors", "Community", "Fans", "Team", "History"],
    category: "Futbol",
  ),
  WordCard(
    word: "CLUB CHAIRMAN",
    tabooWords: ["Executive", "In Charge", "Transfer", "Resign", "Supporter"],
    category: "Futbol",
  ),
  WordCard(
    word: "GOAL KICK",
    tabooWords: ["Keeper", "Six-yard", "Restart", "Out", "Kick"],
    category: "Futbol",
  ),
  WordCard(
    word: "CENTER BACK",
    tabooWords: ["Defender", "Middle", "Back Line", "Stopper", "Tackle"],
    category: "Futbol",
  ),
  WordCard(
    word: "CHAMPIONS LEAGUE",
    tabooWords: ["UEFA", "Europe", "Final", "Big Clubs", "Trophy"],
    category: "Futbol",
  ),
  WordCard(
    word: "SUPER CUP",
    tabooWords: [
      "Winner",
      "Champions League",
      "Final",
      "European League",
      "Trophy",
    ],
    category: "Futbol",
  ),
  WordCard(
    word: "ASSIST",
    tabooWords: ["Pass", "Middle", "Shot", "Goal", "Score"],
    category: "Futbol",
  ),
  // 90s Nostalgia (EN)
  WordCard(
    word: "WALKMAN",
    tabooWords: ["Music", "Headphones", "Cassette", "Belt", "Portable"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "CASSETTE",
    tabooWords: ["Tape", "Music", "Player", "Wind", "Plastic"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "FLOPPY DISK",
    tabooWords: ["Save", "Drive", "Computer", "Square", "Files"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "DIAL-UP",
    tabooWords: ["Modem", "Phone Line", "Sound", "Connect", "Internet"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "NOKIA 3310",
    tabooWords: ["Phone", "Snake", "Buttons", "Battery", "Brick"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "GAME BOY",
    tabooWords: ["Nintendo", "Handheld", "Cartridge", "Pokemon", "Screen"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "ATARI",
    tabooWords: ["Console", "Joystick", "Cartridge", "8-bit", "Games"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "ANTENNA",
    tabooWords: ["Roof", "Signal", "TV", "Adjust", "Channel"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "MARBLE",
    tabooWords: ["Glass", "Game", "Round", "Child", "Shoot"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "JACKS",
    tabooWords: ["Stones", "Throw", "Catch", "Game", "Floor"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "POGS",
    tabooWords: ["Disks", "Stack", "Collect", "Slammer", "Game"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "POKEMON CARDS",
    tabooWords: ["Collect", "Trade", "Holographic", "Deck", "Battle"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "SPICE GIRLS",
    tabooWords: ["Girl Band", "Wannabe", "Britpop", "90s", "Pop"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "BACKSTREET BOYS",
    tabooWords: ["Boyband", "I Want It That Way", "Pop", "90s", "Group"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "NIRVANA",
    tabooWords: [
      "Grunge",
      "Kurt Cobain",
      "Smells Like Teen Spirit",
      "Band",
      "90s",
    ],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "FRIENDS",
    tabooWords: ["Sitcom", "Ross", "Rachel", "Central Perk", "90s"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "TITANIC",
    tabooWords: ["Ship", "Jack", "Rose", "Movie", "Iceberg"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "JURASSIC PARK",
    tabooWords: ["Dinosaurs", "Movie", "Island", "T-Rex", "Spielberg"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "THE MATRIX",
    tabooWords: ["Neo", "Red Pill", "Sci-Fi", "1999", "Bullet Time"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "HOME ALONE",
    tabooWords: ["Kevin", "Thieves", "Christmas", "Trap", "Movie"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "MACARENA",
    tabooWords: ["Dance", "Song", "Hands", "Chorus", "90s"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "MSN MESSENGER",
    tabooWords: ["Chat", "Nudge", "Status", "Email", "Online"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "ICQ",
    tabooWords: ["Uh-oh", "Chat", "Number", "Messenger", "90s"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "CHAT ROOM",
    tabooWords: ["Internet", "Anonymous", "Talk", "Nickname", "Typing"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "INTERNET CAFE",
    tabooWords: ["Computer", "Pay", "Game", "Chat", "LAN"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "PAGER",
    tabooWords: ["Beep", "Number", "Message", "Pocket", "90s"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "ROLLERBLADES",
    tabooWords: ["Skates", "Wheels", "Inline", "Park", "Helmet"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "POLAROID",
    tabooWords: ["Instant", "Photo", "Camera", "Print", "Shake"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "DISCMAN",
    tabooWords: ["CD", "Portable", "Skip", "Music", "Headphones"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "BURNED CD",
    tabooWords: ["Copy", "Computer", "Music", "Blank", "Record"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "WINDOWS 98",
    tabooWords: ["Start", "PC", "Desktop", "Microsoft", "Update"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "Y2K",
    tabooWords: ["Bug", "2000", "Computers", "Fear", "Millennium"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "BEANIE BABY",
    tabooWords: ["Collectible", "Toy", "Stuffed", "Tag", "Hype"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "FANNY PACK",
    tabooWords: ["Belt", "Bag", "Waist", "Travel", "Zip"],
    category: "90'lar Nostalji",
  ),
  WordCard(
    word: "WALKIE-TALKIE",
    tabooWords: ["Two-way", "Radio", "Button", "Static", "Kids"],
    category: "90'lar Nostalji",
  ),
  // Hard Mode (EN)
  WordCard(
    word: "PHOTOSYNTHESIS",
    tabooWords: ["Plants", "Sunlight", "Chlorophyll", "Energy", "Oxygen"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "ENTROPY",
    tabooWords: ["Chaos", "Thermodynamics", "Energy", "Disorder", "Heat"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "PARADOX",
    tabooWords: ["Contradiction", "Logic", "Impossible", "Loop", "Think"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "LABYRINTH",
    tabooWords: ["Maze", "Paths", "Lost", "Complex", "Turns"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "OXYMORON",
    tabooWords: ["Opposite", "Words", "Jumbo Shrimp", "Phrase", "Irony"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "METAMORPHOSIS",
    tabooWords: ["Change", "Butterfly", "Caterpillar", "Transform", "Stage"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "ANTIMATTER",
    tabooWords: ["Opposite", "Particle", "Physics", "Matter", "Collider"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "BIOSPHERE",
    tabooWords: ["Earth", "Life", "Ecosystem", "Environment", "Planet"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "CAMOUFLAGE",
    tabooWords: ["Blend", "Hide", "Pattern", "Military", "Color"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "CHRONOLOGY",
    tabooWords: ["Timeline", "Order", "Dates", "History", "Sequence"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "HYPOTHESIS",
    tabooWords: ["Science", "Test", "Idea", "Assumption", "Experiment"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "INFRARED",
    tabooWords: ["Light", "Heat", "Thermal", "Camera", "Wave"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "COGNITIVE",
    tabooWords: ["Brain", "Mental", "Thinking", "Process", "Mind"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "SYMMETRY",
    tabooWords: ["Mirror", "Equal", "Shape", "Balance", "Sides"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "KALEIDOSCOPE",
    tabooWords: ["Colors", "Pattern", "Tube", "Mirror", "Shapes"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "DICHOTOMY",
    tabooWords: ["Two", "Divide", "Opposite", "Split", "Contrast"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "POLYMORPHISM",
    tabooWords: ["OOP", "Change", "Forms", "Programming", "Shape"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "ANTHROPOLOGY",
    tabooWords: ["Humans", "Culture", "Study", "Society", "Science"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "ARCHETYPE",
    tabooWords: ["Model", "Pattern", "Original", "Symbol", "Story"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "SYNCHRONIZE",
    tabooWords: ["Same Time", "Align", "Together", "Clock", "Match"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "ALGORITHM",
    tabooWords: ["Steps", "Code", "Solve", "Computer", "Logic"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "ANESTHESIA",
    tabooWords: ["Surgery", "Sleep", "Doctor", "Numb", "Injection"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "HIERARCHY",
    tabooWords: ["Ranking", "Top", "Bottom", "Order", "Level"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "CATACLYSM",
    tabooWords: ["Disaster", "Massive", "Event", "Change", "Destruction"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "AMBIDEXTROUS",
    tabooWords: ["Both Hands", "Write", "Skill", "Left", "Right"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "EPIPHANY",
    tabooWords: ["Realization", "Sudden", "Insight", "Idea", "Moment"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "AURORA",
    tabooWords: ["Northern Lights", "Sky", "Color", "Pole", "Night"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "TECTONIC PLATE",
    tabooWords: ["Earth", "Move", "Earthquake", "Crust", "Shift"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "HEMISPHERE",
    tabooWords: ["North", "South", "Globe", "Half", "Earth"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "OSMOSIS",
    tabooWords: ["Water", "Membrane", "Balance", "Cells", "Science"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "NANOTECHNOLOGY",
    tabooWords: ["Tiny", "Science", "Material", "Small", "Future"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "BLOCKCHAIN",
    tabooWords: ["Crypto", "Chain", "Ledger", "Bitcoin", "Data"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "RENAISSANCE",
    tabooWords: ["Art", "Europe", "Rebirth", "Da Vinci", "Period"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "HYPERSPACE",
    tabooWords: ["Sci-Fi", "Faster", "Light", "Travel", "Space"],
    category: "Zor Seviye",
  ),
  WordCard(
    word: "DARK MATTER",
    tabooWords: ["Space", "Invisible", "Gravity", "Universe", "Mystery"],
    category: "Zor Seviye",
  ),
  // Midnight Category
  WordCard(
    word: "FOREPLAY",
    tabooWords: [
      "Touching",
      "Kissing",
      "Warming Up",
      "Beginning",
      "Getting Wet",
    ],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "FANTASY",
    tabooWords: ["Imagination", "Role", "Desire", "Dream", "Scenario"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "HORNY",
    tabooWords: ["Wanting", "Desiring", "Arousal", "Burning", "Losing Control"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "GETTING HARD",
    tabooWords: ["Teasing", "Male", "Penis", "Erection", "Stood Upright"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "GETTING WET",
    tabooWords: ["Woman", "Teasing", "Horny", "Dripping", "Soaking"],
    category: "Gece Yarısı",
  ),

  WordCard(
    word: "MAKE LOVE",
    tabooWords: ["Sexual", "Together", "Intimacy", "Skin", "Sex"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "FRENCH KISS",
    tabooWords: ["Tongue", "Mouth", "Deep", "Kissing", "Passionate"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "AROUSAL",
    tabooWords: [
      "Getting Horny",
      "Awakening",
      "Provoking",
      "Desire",
      "Affecting",
    ],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "SEXUAL TENSION",
    tabooWords: [
      "Anticipation",
      "Not Touching",
      "Eye Contact",
      "Silence",
      "Chemistry",
    ],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "CUMMING",
    tabooWords: ["Climax", "Relaxing", "Happy Ending", "Trembling", "Moaning"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "ORGASM",
    tabooWords: ["Climax", "Cumming", "Contracting", "Trembling", "Pleasure"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "ROLE PLAY",
    tabooWords: ["Character", "Fantasy", "Game", "Scenario", "Acting"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "SEXUAL ATTRACTION",
    tabooWords: ["Chemistry", "Electricity", "Desire", "Want", "Magnet"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "QUICKIE",
    tabooWords: [
      "Rush",
      "Not Holding Back",
      "Sudden",
      "Excited",
      "Uncontrolled",
    ],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "ONE NIGHT STAND",
    tabooWords: ["Night", "Bed", "Secret", "Sudden", "Passionate"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "PERFORMANCE ANXIETY",
    tabooWords: ["Nerves", "First Time", "Stress", "Overthinking", "Pressure"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "MISSIONARY",
    tabooWords: ["On Top", "Face To Face", "Bed", "Classic", "Position"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "MOANING",
    tabooWords: [
      "Moaning Sounds",
      "Voice",
      "Shouting",
      "Can’t Hold Back",
      "Pleasure",
    ],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "SHOWER SEX",
    tabooWords: ["Bath", "Wet", "Slippery", "On Foot", "Close"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "ORAL",
    tabooWords: ["Mouth", "Tongue", "Down There", "Pleasure", "Licking"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "ANAL",
    tabooWords: ["From Behind", "Different", "Tight", "Risk", "Pleasure"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "SEXTING",
    tabooWords: ["Messaging", "Texting", "Phone", "Implying", "Teasing"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "NUDE",
    tabooWords: ["Naked", "Photo", "Phone", "Woman", "Secret"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "DICK PIC",
    tabooWords: ["Photo", "Phone", "Male", "Sending", "Penis"],
    category: "Gece Yarısı",
  ),
  WordCard(
    word: "SPANKING",
    tabooWords: ["Hand", "Butt", "Sound", "Slap", "Flush"],
    category: "Gece Yarısı",
  ),
];
