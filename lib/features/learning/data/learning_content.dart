enum StageType { info, read, write }

class StageContent {
  final StageType type;
  final String title;
  final String? infoTitle;
  final String? infoText;
  final String? imagePath;
  final String? pegonText;
  final String? latinText;

  const StageContent({
    required this.type,
    required this.title,
    this.infoTitle,
    this.infoText,
    this.imagePath = 'assets/images/pegon.png',
    this.pegonText,
    this.latinText,
  });
}

class LevelContent {
  final int level;
  final String title;
  final String subtitle;
  final List<StageContent> stages;

  const LevelContent({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.stages,
  });
}

final List<LevelContent> learningLevels = [
  LevelContent(
    level: 1,
    title: 'Level 1: Aksara Pegon',
    subtitle: 'Pengenalan Aksara Pegon',
    stages: [
      StageContent(
        type: StageType.info,
        title: 'Fungsi Aksara Pegon',
        infoTitle: 'Aksara Pegon',
        infoText: 'Aksara pegon digunakan untuk menulis bahasa Jawa, Sunda, dan Indonesia, bukan bahasa Arab.',
      ),
      StageContent(
        type: StageType.info,
        title: 'Aturan Penulisan',
        infoTitle: 'Bahasa Arab',
        infoText: 'Penamaan orang, tempat, maupun tindakan dalam bahasa Arab tetap ditulis dalam bahasa Arab seperti Muhammad, Ali, Sholat, Romadhon, dll.',
        imagePath: 'assets/images/kitab.png',
      ),
      StageContent(
        type: StageType.info,
        title: 'Huruf & Harakat',
        infoTitle: 'Hijaiyah Modifikasi',
        infoText: 'Aksara pegon menggunakan aksara hijaiyah namun memiliki tambahan huruf dan harakat khusus.',
      ),
    ],
  ),
  LevelContent(
    level: 2,
    title: 'Level 2: Huruf Vokal',
    subtitle: 'Mengenal Harakat Vokal',
    stages: [
      StageContent(
        type: StageType.info,
        title: 'Mengenal Harakat',
        infoTitle: 'Harakat Vokal',
        infoText: 'Mengenal harakat pegon A, I, U, E, O dan cara menulisnya dalam kata.',
        imagePath: 'assets/images/vokal.png',
      ),
      StageContent(
        type: StageType.read,
        title: 'Tes Membaca (A)',
        pegonText: 'كَاكَكْ',
        latinText: 'kakak',
      ),
      StageContent(
        type: StageType.read,
        title: 'Tes Membaca (I)',
        pegonText: 'سِيسِكْ',
        latinText: 'sisik',
      ),
      StageContent(
        type: StageType.read,
        title: 'Tes Membaca (U)',
        pegonText: 'كُوتُو',
        latinText: 'kutu',
      ),
      StageContent(
        type: StageType.read,
        title: 'Tes Membaca (E)',
        pegonText: 'بࣤبࣤكْ',
        latinText: 'bebek',
      ),
      StageContent(
        type: StageType.read,
        title: 'Tes Membaca (O)',
        pegonText: 'اَوبَورْ',
        latinText: 'obor',
      ),
    ],
  ),
  LevelContent(
    level: 3,
    title: 'Level 3: Huruf Konsonan',
    subtitle: 'Mengenal Konsonan Tambahan',
    stages: [
      StageContent(
        type: StageType.info,
        title: 'Konsonan Tambahan',
        infoTitle: 'Tambahan Pegon',
        infoText: 'Aksara Pegon memiliki tambahan huruf yang tidak ada di hijaiyah, yaitu: C (چ), G (ڮ), P (ڤ), NG (ڠ), dan NY (ۑ).',
      ),
    ],
  ),
  LevelContent(
    level: 4,
    title: 'Level 4: Huruf C',
    subtitle: 'Membaca dan Menulis C',
    stages: [
      StageContent(
        type: StageType.info,
        title: 'Huruf C',
        infoTitle: 'Huruf C (چ)',
        infoText: 'Huruf C dalam Pegon ditulis dengan modifikasi huruf Jim (چ).',
        imagePath: 'assets/images/c.png',
      ),
      StageContent(
        type: StageType.read,
        title: 'Tes Membaca',
        pegonText: 'چُچِ',
        latinText: 'cuci',
      ),
      StageContent(
        type: StageType.write,
        title: 'Tes Menulis',
        latinText: 'suci',
      ),
    ],
  ),
  LevelContent(
    level: 5,
    title: 'Level 5: Huruf G',
    subtitle: 'Membaca dan Menulis G',
    stages: [
      StageContent(
        type: StageType.info,
        title: 'Huruf G',
        infoTitle: 'Huruf G (ڮ)',
        infoText: 'Huruf G ditulis dengan modifikasi huruf Kaf bersimbol (ڮ).',
        imagePath: 'assets/images/g.png',
      ),
      StageContent(
        type: StageType.read,
        title: 'Tes Membaca',
        pegonText: 'مَاڠْڮَا',
        latinText: 'mangga',
      ),
      StageContent(
        type: StageType.write,
        title: 'Tes Menulis',
        latinText: 'tangga',
      ),
    ],
  ),
  LevelContent(
    level: 6,
    title: 'Level 6: Huruf P',
    subtitle: 'Membaca dan Menulis P',
    stages: [
      StageContent(
        type: StageType.info,
        title: 'Huruf P',
        infoTitle: 'Huruf P (ڤ)',
        infoText: 'Huruf P ditulis dengan modifikasi huruf Fa (ڤ).',
        imagePath: 'assets/images/p.png',
      ),
      StageContent(
        type: StageType.read,
        title: 'Tes Membaca',
        pegonText: 'بَاڤَكْ',
        latinText: 'bapak',
      ),
      StageContent(
        type: StageType.write,
        title: 'Tes Menulis',
        latinText: 'pupuk',
      ),
    ],
  ),
  LevelContent(
    level: 7,
    title: 'Level 7: Huruf NG',
    subtitle: 'Membaca dan Menulis NG',
    stages: [
      StageContent(
        type: StageType.info,
        title: 'Huruf NG',
        infoTitle: 'Huruf NG (ڠ)',
        infoText: 'Huruf NG ditulis dengan modifikasi huruf Ain (ڠ).',
        imagePath: 'assets/images/ng.png',
      ),
      StageContent(
        type: StageType.read,
        title: 'Tes Membaca',
        pegonText: 'ڤَانْچِڠْ',
        latinText: 'pancing',
      ),
      StageContent(
        type: StageType.write,
        title: 'Tes Menulis',
        latinText: 'kucing',
      ),
    ],
  ),
  LevelContent(
    level: 8,
    title: 'Level 8: Huruf NY',
    subtitle: 'Membaca dan Menulis NY',
    stages: [
      StageContent(
        type: StageType.info,
        title: 'Huruf NY',
        infoTitle: 'Huruf NY (ۑ)',
        infoText: 'Huruf NY ditulis menggunakan modifikasi huruf Ya (ۑ).',
        imagePath: 'assets/images/ny.png',
      ),
      StageContent(
        type: StageType.read,
        title: 'Tes Membaca',
        pegonText: 'مۤۑَاڤُ',
        latinText: 'menyapu',
      ),
      StageContent(
        type: StageType.write,
        title: 'Tes Menulis',
        latinText: 'menyanyi',
      ),
    ],
  ),
  LevelContent(
    level: 9,
    title: 'Level 9: Tes Kecakapan',
    subtitle: 'Latihan Membaca & Menulis',
    stages: [
      StageContent(
        type: StageType.read,
        title: 'Membaca 1',
        pegonText: 'بَاڤَكْ مۤمْبۤلِي ڤَانْچِڠْ',
        latinText: 'bapak membeli pancing',
      ),
      StageContent(
        type: StageType.read,
        title: 'Membaca 2',
        pegonText: 'اِيبُو ڮُورُو مۤڠَاجَرْ دِي كۤلَاسْ',
        latinText: 'ibu guru mengajar di kelas',
      ),
      StageContent(
        type: StageType.read,
        title: 'Membaca 3',
        pegonText: 'بَامْبَاڠْ سُوكَا رَوتِي بَاكَارْ',
        latinText: 'bambang suka roti bakar',
      ),
      StageContent(
        type: StageType.read,
        title: 'Membaca 4',
        pegonText: 'اُودِينْ بۤرْۑَاۑِي دِي ڤۤنْتَاسْ',
        latinText: 'udin bernyanyi di pentas',
      ),
      StageContent(
        type: StageType.read,
        title: 'Membaca 5',
        pegonText: 'اِنْدَونۤسِيَا دَانْ مَالَيْسِيَا بۤرْدۤكَاتَانْ',
        latinText: 'indonesia dan malaysia berdekatan',
      ),
      StageContent(
        type: StageType.write,
        title: 'Menulis 1',
        latinText: 'makanan ini enak',
      ),
      StageContent(
        type: StageType.write,
        title: 'Menulis 2',
        latinText: 'gunung semeru meletus',
      ),
      StageContent(
        type: StageType.write,
        title: 'Menulis 3',
        latinText: 'ayam panggang pak kris',
      ),
      StageContent(
        type: StageType.write,
        title: 'Menulis 4',
        latinText: 'rudi menyiapkan makan siang',
      ),
      StageContent(
        type: StageType.write,
        title: 'Menulis 5',
        latinText: 'husni mengasah celurit',
      ),
    ],
  ),
];
