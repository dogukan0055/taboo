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
  }) : id = id ?? "${word}_${DateTime.now().microsecondsSinceEpoch}";
}

class RoundEvent {
  final WordCard card;
  final CardStatus status;

  RoundEvent({required this.card, required this.status});
}

// --- DUMMY DATA ---
final List<WordCard> initialDeck = [
  // Genel Kategori
  WordCard(
    word: "KALEM",
    tabooWords: ["Yazmak", "Kâğıt", "Mürekkep", "Silgi", "Okul"],
    category: "Genel",
  ),
  WordCard(
    word: "GÜNEŞ",
    tabooWords: ["Işık", "Sıcak", "Gökyüzü", "Yıldız", "Gün"],
    category: "Genel",
  ),
  WordCard(
    word: "SAAT",
    tabooWords: ["Zaman", "Dakika", "Kol", "Alarm", "Akrep"],
    category: "Genel",
  ),
  WordCard(
    word: "AYNA",
    tabooWords: ["Yansıma", "Cam", "Bakmak", "Görüntü", "Banyo"],
    category: "Genel",
  ),

  // Sanat Kategori
  WordCard(
    word: "PİKASSO",
    tabooWords: ["Ressam", "Tablo", "Kübizm", "İspanya", "Modern"],
    category: "Sanat",
  ),
  WordCard(
    word: "HEYKEL",
    tabooWords: ["Heykeltraş", "Mermer", "Sanat", "Üç Boyutlu", "Yontu"],
    category: "Sanat",
  ),
  WordCard(
    word: "TÜRKÜ",
    tabooWords: ["Şarkı", "Halk", "Söylemek", "Bağlama", "Ezgi"],
    category: "Sanat",
  ),
  WordCard(
    word: "BALETİ",
    tabooWords: ["Dans", "Sahne", "Tutu", "Parmak", "Ucu"],
    category: "Sanat",
  ),

  // Bilim Kategori
  WordCard(
    word: "MIKROSKOP",
    tabooWords: ["Bakteri", "Küçük", "Mercek", "Laboratuvar", "Görmek"],
    category: "Bilim",
  ),
  WordCard(
    word: "ATOM",
    tabooWords: ["Küçük", "Proton", "Nötron", "Çekirdek", "Molekül"],
    category: "Bilim",
  ),
  WordCard(
    word: "GÜNEŞ SİSTEMİ",
    tabooWords: ["Gezegen", "Dünya", "Mars", "Uzay", "Yörünge"],
    category: "Bilim",
  ),
  WordCard(
    word: "EVRİM",
    tabooWords: ["Darwin", "Tür", "Değişim", "Adaptasyon", "Doğal Seçilim"],
    category: "Bilim",
  ),

  // Yemek Kategori
  WordCard(
    word: "MANTI",
    tabooWords: ["Hamur", "Kıyma", "Yoğurt", "Kayısı", "Susamak"],
    category: "Yemek",
  ),
  WordCard(
    word: "KÖFTE",
    tabooWords: ["Et", "Kıyma", "Yuvarlak", "Izgara", "Pişirmek"],
    category: "Yemek",
  ),
  WordCard(
    word: "LAHMACUN",
    tabooWords: ["İnce", "Kıyma", "Fırın", "Limon", "Maydanoz"],
    category: "Yemek",
  ),
  WordCard(
    word: "KÜNEFE",
    tabooWords: ["Tatlı", "Peynir", "Kadayıf", "Şerbet", "Antep"],
    category: "Yemek",
  ),

  // Spor Kategori
  WordCard(
    word: "FUTBOL",
    tabooWords: ["Top", "Kale", "Gol", "Maç", "Saha"],
    category: "Spor",
  ),
  WordCard(
    word: "YÜZME",
    tabooWords: ["Havuz", "Su", "Spor", "Kulübe", "Mayı"],
    category: "Spor",
  ),
  WordCard(
    word: "ŞAMPİYON",
    tabooWords: ["Birinci", "Kazanmak", "Madalya", "Kupa", "Yarışma"],
    category: "Spor",
  ),
  WordCard(
    word: "BASKETBOL",
    tabooWords: ["Top", "Potya", "Sayı", "Smaç", "Saha"],
    category: "Spor",
  ),

  // Doğa Kategori
  WordCard(
    word: "ORMAN",
    tabooWords: ["Ağaç", "Yeşil", "Yaprak", "Hayvan", "Doğa"],
    category: "Doğa",
  ),
  WordCard(
    word: "DENİZ",
    tabooWords: ["Su", "Tuzlu", "Dalga", "Kum", "Yüzmek"],
    category: "Doğa",
  ),
  WordCard(
    word: "KELEBEK",
    tabooWords: ["Uçmak", "Kanat", "Renkli", "Böcek", "Çiçek"],
    category: "Doğa",
  ),
  WordCard(
    word: "GÖKKUŞAĞI",
    tabooWords: ["Renk", "Yağmur", "Gökyüzü", "Güneş", "Işık"],
    category: "Doğa",
  ),

  // Teknoloji Kategori
  WordCard(
    word: "BİLGİSAYAR",
    tabooWords: ["Klavye", "Ekran", "Fare", "İnternet", "Program"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "TELEFON",
    tabooWords: ["Aramak", "Akıllı", "Ekran", "Mobil", "Uygulama"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "ROBOT",
    tabooWords: ["Makine", "Yapay Zeka", "Metal", "Otomasyon", "Gelecek"],
    category: "Teknoloji",
  ),
  WordCard(
    word: "İNTERNET",
    tabooWords: ["Ağ", "Web", "Tarayıcı", "Wifi", "Bağlantı"],
    category: "Teknoloji",
  ),

  // Tarih Kategori
  WordCard(
    word: "ATATÜRK",
    tabooWords: ["Cumhuriyet", "Lider", "Türkiye", "Kurtuluş", "Mustafa Kemal"],
    category: "Tarih",
  ),
  WordCard(
    word: "PİRAMİT",
    tabooWords: ["Mısır", "Firavun", "Üçgen", "Eski", "Mezar"],
    category: "Tarih",
  ),
  WordCard(
    word: "OSMANLISI",
    tabooWords: ["İmparatorluk", "Padişah", "İstanbul", "Tarih", "Devlet"],
    category: "Tarih",
  ),
  WordCard(
    word: "VİKİNG",
    tabooWords: ["Savaşçı", "Gemi", "Kuzey", "Yağma", "Kask"],
    category: "Tarih",
  ),
];
