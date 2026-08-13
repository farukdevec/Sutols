import 'gemini_presentation_service.dart';

/// AI sağlayıcıları kullanılamadığında sunumun sayfa sayısını ve anlatı
/// bütünlüğünü koruyan deterministik yedek üretici.
class FallbackSlideGenerator {
  static const Set<String> _stopWords = {
    'ama',
    'ancak',
    'artik',
    'bir',
    'bircok',
    'bu',
    'buna',
    'bunlara',
    'bunlari',
    'bunun',
    'cok',
    'daha',
    'da',
    'de',
    'den',
    'diye',
    'diyor',
    'ederek',
    'eden',
    'en',
    'gibi',
    'hakkinda',
    'her',
    'icin',
    'ile',
    'ise',
    'kadar',
    'ken',
    'ki',
    'kim',
    'nasi',
    'nasil',
    'ne',
    'neden',
    'nerde',
    'nere',
    'nereye',
    'neyle',
    'olarak',
    'oldugu',
    'oldugunu',
    'oldukca',
    'once',
    'sadece',
    'seyler',
    'sonra',
    'uzere',
    'uzerine',
    'uzerinde',
    've',
    'veya',
    'ya',
    'yani',
    'yapilan',
    'yeni',
    'zaman',
    'tum',
    'butun',
    'tumu',
    'nedir',
  };

  /// Konu metninden [slideCount] kadar, farklı görevleri olan slayt üretir.
  /// [slideCount] 1 ile 30 arasına kısıtlanır.
  static GeminiPresentation generatePresentation(
    String topic, {
    int slideCount = 5,
  }) {
    final subject = topic.trim().isEmpty ? 'Sunum konusu' : topic.trim();
    final count = slideCount.clamp(1, 30);
    final words = _meaningfulWords(subject);
    final outline = _isScienceTopic(subject)
        ? _scienceOutline(subject)
        : _generalOutline(subject, words);
    final selected = _selectAcrossOutline(outline, count);

    return GeminiPresentation(
      slides: selected
          .map(
            (item) => GeminiSlide(
              title: item.title,
              content: item.bullets.map((bullet) => '- $bullet').join('\n'),
              keywords: item.keywords,
            ),
          )
          .toList(growable: false),
    );
  }

  static bool _isScienceTopic(String topic) {
    final normalized = topic.toLowerCase();
    return RegExp(r'\bfen\b').hasMatch(normalized) ||
        normalized.contains('fen bilim') ||
        normalized.contains('science');
  }

  /// Kısa “fen” girdisinin 30 sayfada aynı cümleye dönüşmesini engelleyen,
  /// fen bilimlerinin ana disiplinlerini aşamalı biçimde kapsayan omurga.
  static List<_FallbackSlide> _scienceOutline(String subject) => [
        _slide(
            'Fen Bilimlerine Giriş',
            '$subject; doğayı gözlem, deney ve kanıtla anlamaya çalışan disiplinleri bir araya getirir.',
            'Fizik, kimya, biyoloji, yer ve uzay bilimleri ortak sorulara farklı ölçeklerden yaklaşır.',
            'Sunum, bilimsel düşünmeden günlük uygulamalara uzanan bir rota izler.',
            ['fen bilimleri', 'doğa', 'bilim', 'araştırma']),
        _slide(
            'Meraktan Araştırma Sorusuna',
            'Bilimsel süreç, gözlenen bir olay hakkında açık ve sınanabilir soru kurmakla başlar.',
            'İyi bir soru değişkenleri, incelenecek ilişkiyi ve ölçülebilir sonucu belirginleştirir.',
            'Merak böylece rastgele tahminden sistemli araştırmaya dönüşür.',
            ['merak', 'araştırma sorusu', 'gözlem', 'hipotez']),
        _slide(
            'Bilimsel Yöntemin Adımları',
            'Hipotez kurma, kontrollü deney tasarlama, veri toplama ve sonucu yorumlama birbirini izler.',
            'Bir bulgunun güvenilirliği, yöntemin başkaları tarafından tekrarlanabilmesine bağlıdır.',
            'Sonuç hipotezi desteklemese de araştırmaya yeni bir yön kazandırabilir.',
            ['bilimsel yöntem', 'deney', 'hipotez', 'sonuç']),
        _slide(
            'Gözlem, Ölçüm ve Birimler',
            'Nitel gözlemler özellikleri betimlerken nicel ölçümler sayı ve birimlerle karşılaştırma sağlar.',
            'Standart birimler farklı zaman ve yerlerde elde edilen verileri ortaklaştırır.',
            'Ölçüm araçlarının hassasiyeti, sonucun belirsizlik payını doğrudan etkiler.',
            ['ölçüm', 'birim', 'veri', 'ölçüm aracı']),
        _slide(
            'Fiziğin İncelediği Dünya',
            'Fizik; madde, enerji, hareket, kuvvet, ışık ve ses arasındaki ilişkileri inceler.',
            'Aynı ilkeler atom ölçeğinden gezegenlerin hareketine kadar farklı sistemlerde kullanılabilir.',
            'Modeller, karmaşık doğa olaylarını ölçülebilir ilişkilere dönüştürür.',
            ['fizik', 'madde', 'enerji', 'doğa yasaları']),
        _slide(
            'Kuvvet ve Hareket',
            'Bir cismin hareketindeki değişim, ona etki eden net kuvvetle ilişkilidir.',
            'Hız; alınan yolun zamana göre değişimini, ivme ise hızdaki değişimi açıklar.',
            'Sürtünme hem hareketi yavaşlatabilir hem de yürümeyi mümkün kılabilir.',
            ['kuvvet', 'hareket', 'hız', 'sürtünme']),
        _slide(
            'Enerji ve Dönüşümleri',
            'Enerji hareket, konum, ısı, ışık, elektrik ve kimyasal bağlar gibi biçimlerde bulunur.',
            'Bir sistemde enerji yok olmaz; aktarılır veya başka bir biçime dönüşür.',
            'Ampulün elektrik enerjisini ışık ve ısıya çevirmesi günlük bir örnektir.',
            ['enerji', 'enerji dönüşümü', 'elektrik', 'ısı']),
        _slide(
            'Isı ve Sıcaklık',
            'Sıcaklık taneciklerin ortalama hareketiyle, ısı ise enerji aktarımıyla ilişkilidir.',
            'İletim, taşınım ve ışınım farklı ısı aktarım yollarıdır.',
            'Yalıtım malzemeleri enerji aktarımını azaltarak verimliliği artırır.',
            ['ısı', 'sıcaklık', 'yalıtım', 'termometre']),
        _slide(
            'Işık, Ses ve Dalgalar',
            'Dalgalar enerjiyi bir noktadan diğerine taşırken ortamın tamamını taşımaz.',
            'Ses maddesel ortama ihtiyaç duyar; ışık boşlukta da ilerleyebilir.',
            'Yansıma ve kırılma, görüntüleme ve iletişim teknolojilerinin temelindedir.',
            ['ışık', 'ses', 'dalga', 'yansıma']),
        _slide(
            'Maddenin Tanecikli Yapısı',
            'Maddeler atom ve molekül gibi çok küçük taneciklerden oluşur.',
            'Katı, sıvı ve gaz hâllerinde taneciklerin düzeni ve hareketi farklıdır.',
            'Hâl değişiminde maddenin kimliği korunurken enerji alışverişi gerçekleşir.',
            ['madde', 'atom', 'molekül', 'hal değişimi']),
        _slide(
            'Elementler ve Periyodik Sistem',
            'Elementler aynı tür atomlardan oluşur ve kimyasal sembollerle gösterilir.',
            'Periyodik tablo, elementleri atom yapıları ve benzer özelliklerine göre düzenler.',
            'Tablodaki konum, bir elementin davranışı hakkında öngörü sağlar.',
            ['element', 'periyodik tablo', 'atom', 'kimya']),
        _slide(
            'Fiziksel ve Kimyasal Değişim',
            'Fiziksel değişimde biçim veya hâl değişirken yeni bir madde oluşmaz.',
            'Kimyasal tepkimede atomlar yeniden düzenlenir ve farklı özellikte maddeler ortaya çıkar.',
            'Paslanma, yanma ve pişme kimyasal değişime örnek verilebilir.',
            ['kimyasal tepkime', 'fiziksel değişim', 'paslanma', 'yanma']),
        _slide(
            'Canlılığın Ortak Özellikleri',
            'Canlılar beslenme, enerji kullanma, büyüme, üreme ve çevreye tepki verme özellikleri gösterir.',
            'Bu ortaklıkların gerçekleşme biçimi türler ve yaşam ortamları arasında değişebilir.',
            'Uyum özellikleri, canlıların belirli çevre koşullarında yaşamasına katkı sağlar.',
            ['canlılar', 'yaşam', 'uyum', 'üreme']),
        _slide(
            'Hücreden Organizmaya',
            'Hücre, canlıların yapı ve işlev bakımından en küçük temel birimidir.',
            'Benzer görevli hücreler dokuları; dokular organları; organlar sistemleri oluşturur.',
            'Bu örgütlenme, çok hücreli canlılarda görev paylaşımını mümkün kılar.',
            ['hücre', 'doku', 'organ', 'organizma']),
        _slide(
            'Kalıtım ve Çeşitlilik',
            'DNA, canlıların gelişimi ve işleyişi için gereken kalıtsal bilgiyi taşır.',
            'Genetik farklılıklar ve çevresel etkiler bireyler arasındaki çeşitliliğe katkı verir.',
            'Çeşitlilik, değişen koşullara uyum açısından popülasyonlara seçenek sunar.',
            ['DNA', 'gen', 'kalıtım', 'çeşitlilik']),
        _slide(
            'Ekosistemlerde İlişkiler',
            'Üreticiler, tüketiciler ve ayrıştırıcılar besin ağları içinde birbirine bağlıdır.',
            'Enerji ekosistemde tek yönlü aktarılırken madde döngüler hâlinde yeniden kullanılır.',
            'Bir türdeki değişim, ağdaki başka canlıları da etkileyebilir.',
            ['ekosistem', 'besin ağı', 'üretici', 'ayrıştırıcı']),
        _slide(
            'İnsan Vücudunda Sistemler',
            'Sindirim, dolaşım, solunum ve boşaltım sistemleri iç dengeyi korumak için birlikte çalışır.',
            'Organlar arasındaki madde ve bilgi alışverişi vücudun gereksinimlerini karşılar.',
            'Sağlıklı yaşam alışkanlıkları bu sistemlerin düzenli işleyişini destekler.',
            ['insan vücudu', 'dolaşım', 'solunum', 'organlar']),
        _slide(
            'Dünya’nın Yapısı',
            'Dünya kabuk, manto ve çekirdekten oluşan katmanlı bir gezegendir.',
            'Levha hareketleri deprem, volkanizma ve dağ oluşumu gibi süreçlerle ilişkilidir.',
            'Kayaçlar oluşum, parçalanma ve dönüşüm yoluyla kayaç döngüsüne katılır.',
            ['Dünya', 'yer kabuğu', 'levha', 'kayaç']),
        _slide(
            'Hava Olayları ve İklim',
            'Hava durumu kısa süreli atmosfer koşullarını, iklim uzun dönemli örüntüleri anlatır.',
            'Sıcaklık, basınç, nem ve rüzgâr hava olaylarının temel değişkenleridir.',
            'Uzun süreli ölçüm kayıtları iklim eğilimlerinin anlaşılmasını sağlar.',
            ['iklim', 'hava durumu', 'atmosfer', 'rüzgar']),
        _slide(
            'Su, Karbon ve Madde Döngüleri',
            'Su; buharlaşma, yoğunlaşma, yağış ve akış süreçleriyle yeryüzünde dolaşır.',
            'Karbon atmosfer, canlılar, okyanuslar ve kayaçlar arasında aktarılır.',
            'İnsan etkinlikleri bu doğal döngülerin hızını ve dengesini değiştirebilir.',
            ['su döngüsü', 'karbon döngüsü', 'yağış', 'atmosfer']),
        _slide(
            'Güneş Sistemi',
            'Güneş Sistemi, Güneş’in çekimi çevresinde hareket eden gezegenler ve küçük gök cisimlerinden oluşur.',
            'Gezegenlerin yapı, sıcaklık, atmosfer ve uydu özellikleri birbirinden farklıdır.',
            'Yörünge hareketleri gök cisimleri arasındaki çekim ilişkisini görünür kılar.',
            ['Güneş Sistemi', 'gezegen', 'yörünge', 'Güneş']),
        _slide(
            'Evreni Araştırmak',
            'Teleskoplar farklı dalga boylarını algılayarak uzak gök cisimleri hakkında veri toplar.',
            'Işığın sonlu hızı nedeniyle uzak uzaya bakmak geçmişe bakmak anlamına gelir.',
            'Uzay görevleri gözlem, ölçüm ve örnek analiziyle kuramları sınar.',
            ['teleskop', 'evren', 'uzay görevi', 'galaksi']),
        _slide(
            'Laboratuvar Güvenliği',
            'Deney öncesinde yönergeleri okumak, koruyucu ekipman kullanmak ve riskleri tanımak gerekir.',
            'Kimyasalların etiketlenmesi ve araçların doğru kullanımı kazaları önlemeye yardım eder.',
            'Beklenmeyen bir durumda deneyi durdurmak ve sorumlu kişiye haber vermek esastır.',
            ['laboratuvar', 'güvenlik', 'koruyucu gözlük', 'deney']),
        _slide(
            'Verileri Okumak',
            'Tablo ve grafikler çok sayıdaki ölçümü karşılaştırılabilir bir düzene dönüştürür.',
            'Eğilim, aykırı değer ve değişkenler arasındaki ilişki kanıta dayalı yorumun parçalarıdır.',
            'Korelasyon görülmesi tek başına neden-sonuç ilişkisini kanıtlamaz.',
            ['grafik', 'tablo', 'veri analizi', 'değişken']),
        _slide(
            'Bilimsel Model ve Sınırlılıkları',
            'Model; bir sistemin seçilmiş özelliklerini açıklayan fiziksel, görsel veya matematiksel temsildir.',
            'Modeller tahmin üretir, ancak gerçeğin bütün ayrıntılarını aynı anda içermez.',
            'Yeni kanıtlar ortaya çıktığında modelin kapsamı veya varsayımları güncellenebilir.',
            ['bilimsel model', 'simülasyon', 'tahmin', 'kanıt']),
        _slide(
            'Fen ve Günlük Yaşam',
            'Pişirme, aydınlatma, ulaşım ve iletişim süreçlerinde fen ilkeleri doğrudan kullanılır.',
            'Günlük bir problemi değişkenlerine ayırmak uygun çözümün seçilmesini kolaylaştırır.',
            'Bilimsel okuryazarlık, ürün ve sağlık iddialarını kanıt açısından değerlendirmeye yardım eder.',
            [
              'günlük yaşam',
              'teknoloji',
              'problem çözme',
              'bilimsel okuryazarlık'
            ]),
        _slide(
            'Çevre ve Sürdürülebilirlik',
            'Doğal kaynakların kullanım hızı ekosistemlerin yenilenme kapasitesiyle dengelenmelidir.',
            'Enerji verimliliği, atık azaltma ve döngüsel kullanım çevresel baskıyı düşürebilir.',
            'Çözümler geliştirilirken bilimsel veriler kadar yerel koşullar da dikkate alınır.',
            [
              'sürdürülebilirlik',
              'çevre',
              'geri dönüşüm',
              'enerji verimliliği'
            ]),
        _slide(
            'Bilim, Teknoloji ve Etik',
            'Bilim bilgi üretir; teknoloji bu bilgiyi ihtiyaçlara yönelik araç ve süreçlere dönüştürür.',
            'Bir yeniliğin yararı, erişilebilirlik, güvenlik, mahremiyet ve çevresel etkiyle birlikte değerlendirilir.',
            'Etik tartışma, yapılabilen ile yapılması uygun olan arasındaki farkı görünür kılar.',
            ['bilim etiği', 'teknoloji', 'sorumluluk', 'güvenlik']),
        _slide(
            'Geleceğin Fen Soruları',
            'İklim, temiz enerji, salgınlar ve uzay araştırmaları disiplinler arası çözümler gerektirir.',
            'Yeni sensörler ve hesaplama yöntemleri daha önce ölçülemeyen süreçleri incelemeyi sağlar.',
            'Gelecekteki ilerleme, nitelikli veri kadar eleştirel düşünme ve iş birliğine de bağlıdır.',
            ['gelecek', 'temiz enerji', 'uzay', 'araştırma']),
        _slide(
            'Ana Çıkarımlar',
            'Fen bilimleri gözlenebilir soruları kanıt, ölçüm ve sınanabilir açıklamalarla ele alır.',
            'Madde, enerji, canlılık, Dünya ve uzay konuları birbirinden kopuk değil; ortak sistemlerin parçalarıdır.',
            'Bilimsel bilgi yeni bulgularla gelişir ve bilinçli karar vermek için güçlü bir temel sunar.',
            ['fen bilimleri', 'kanıt', 'sistem', 'bilimsel düşünme']),
      ];

  static List<_FallbackSlide> _generalOutline(
    String subject,
    List<String> words,
  ) {
    final mainKeywords = words.take(6).toList(growable: false);
    const roles = <_GeneralRole>[
      _GeneralRole('Konuya Giriş', 'kapsamını ve temel sorusunu',
          'sunumun izleyeceği düşünce hattını'),
      _GeneralRole('Tanım ve Kapsam', 'ayırt edici özelliklerini',
          'konuya dâhil olan ve olmayan alanları'),
      _GeneralRole('Ortaya Çıkış Bağlamı', 'doğmasına yol açan koşulları',
          'dönemin ihtiyaç ve değişimlerini'),
      _GeneralRole('Tarihsel Gelişim', 'zaman içindeki önemli dönüşümlerini',
          'bugünkü biçime ulaşan süreci'),
      _GeneralRole('Temel Kavramlar', 'ana kavramlarını ve anlamlarını',
          'kavramlar arasındaki bağı'),
      _GeneralRole('Ana Bileşenler', 'sistemi oluşturan parçaları',
          'her parçanın üstlendiği görevi'),
      _GeneralRole('Sınıflandırma', 'başlıca tür ve kategorileri',
          'kategorileri ayıran ölçütleri'),
      _GeneralRole('İşleyiş Mekanizması', 'sürecin nasıl çalıştığını',
          'girdi, dönüşüm ve çıktı ilişkisini'),
      _GeneralRole('Nedenler', 'ortaya çıkmasını etkileyen etmenleri',
          'doğrudan ve dolaylı nedenleri'),
      _GeneralRole('Sonuçlar', 'kısa ve uzun vadeli etkileri',
          'farklı gruplar üzerindeki sonuçları'),
      _GeneralRole('Veri ve Kanıt', 'değerlendirmede kullanılan kanıtları',
          'güvenilir bulguyu ayırma ölçütlerini'),
      _GeneralRole('Ölçme ve Değerlendirme', 'başarıyı gösteren ölçütleri',
          'sonuçların nasıl yorumlanacağını'),
      _GeneralRole('Somut Bir Örnek', 'gerçek yaşamda görülen bir örneği',
          'kuram ile uygulama arasındaki bağı'),
      _GeneralRole(
          'Karşılaştırmalı Bakış',
          'benzer yaklaşımlarla ortak yönlerini',
          'temel farklılık ve ödünleşimleri'),
      _GeneralRole('Günlük Yaşamdaki Yeri', 'bireylerin yaşamına yansımasını',
          'gündelik kararlarla ilişkisini'),
      _GeneralRole(
          'Toplumsal Etkiler',
          'toplum ve kurumlar üzerindeki etkisini',
          'farklı paydaşların deneyimlerini'),
      _GeneralRole('Ekonomik Boyut', 'kaynak, maliyet ve değer boyutunu',
          'fırsatlarla maliyetler arasındaki dengeyi'),
      _GeneralRole('Çevresel Boyut', 'doğal sistemlerle etkileşimini',
          'uzun vadeli sürdürülebilirlik etkisini'),
      _GeneralRole('Teknolojiyle İlişkisi', 'teknolojinin sağladığı olanakları',
          'teknolojik bağımlılık ve sınırları'),
      _GeneralRole('Sağladığı Faydalar', 'öne çıkan kazanımları',
          'faydanın hangi koşullarda arttığını'),
      _GeneralRole('Riskler ve Sorunlar', 'ortaya çıkabilecek riskleri',
          'sorunların erken işaretlerini'),
      _GeneralRole('Sınırlılıklar', 'yaklaşımın açıklayamadığı noktaları',
          'geçerliliği azaltan koşulları'),
      _GeneralRole('Yaygın Yanılgılar', 'sık karşılaşılan yanlış kabulleri',
          'kanıtla desteklenen doğru çerçeveyi'),
      _GeneralRole('Çözüm Yaklaşımları', 'sorunlara yönelik seçenekleri',
          'uygulanabilir çözüm seçme ölçütlerini'),
      _GeneralRole('Uygulama Adımları', 'fikri eyleme dönüştüren adımları',
          'sorumluluk ve zaman sırasını'),
      _GeneralRole('Etik ve Sorumluluk', 'kararlardaki etik boyutu',
          'hak, güvenlik ve adalet dengesini'),
      _GeneralRole('Güncel Eğilimler', 'günümüzde öne çıkan yönelimleri',
          'değişimi hızlandıran etkenleri'),
      _GeneralRole('Gelecek Perspektifi', 'olası gelecek senaryolarını',
          'belirsizliklere karşı hazırlanmayı'),
      _GeneralRole('Ana Çıkarımlar', 'bölümlerden çıkan ortak sonuçları',
          'hatırlanması gereken temel bağlantıları'),
      _GeneralRole(
          'Sonuç ve Değerlendirme',
          'ana soruya verilen bütüncül yanıtı',
          'bilgiyi karara dönüştüren son çıkarımı'),
    ];

    return List.generate(roles.length, (index) {
      final role = roles[index];
      final rawBullets = _generalBullets(subject, role, index);
      final bullets = [
        rawBullets[0],
        '${rawBullets[1]} ${role.title} değerlendirmesinde ${role.connection}.',
        '${rawBullets[2]} Sonuç, ${role.focus} ile birlikte okunur.',
      ];
      return _slide(
        '${role.title}: $subject',
        bullets[0],
        bullets[1],
        bullets[2],
        <String>{...mainKeywords, role.title.toLowerCase()}
            .take(8)
            .toList(growable: false),
      );
    }, growable: false);
  }

  static List<String> _generalBullets(
    String subject,
    _GeneralRole role,
    int index,
  ) {
    switch (index % 10) {
      case 0:
        return [
          '$subject için başlangıç noktası, ${role.focus} açıklığa kavuşturmaktır.',
          'Kapsam çizgisi oluşturulurken ${role.connection} özellikle belirtilir.',
          'Böylece sonraki ayrıntılar ortak bir ana soruya bağlanabilir.',
        ];
      case 1:
        return [
          '${_capitalize(subject)} konusu ${role.focus} bakımından incelenir.',
          'Kavramların karışmaması için örnekler ve karşı örnekler birlikte düşünülür.',
          'Ortaya çıkan ayrım, ${role.connection} daha anlaşılır kılar.',
        ];
      case 2:
        return [
          'İncelemenin bu adımı ${role.focus} belirlemeye yöneliktir.',
          '$subject hakkındaki iddialar bağlam, koşul ve zaman boyutlarıyla sınanır.',
          'Elde edilen çerçeve ${role.connection} açıklayan bir dayanak oluşturur.',
        ];
      case 3:
        return [
          'Süreç boyunca ${role.focus} kronolojik ve neden-sonuçlu biçimde izlenir.',
          'Dönüm noktaları, önceki durumla sonraki değişim karşılaştırılarak seçilir.',
          '$subject açısından bu sıra, ${role.connection} ortaya çıkarır.',
        ];
      case 4:
        return [
          '${_capitalize(subject)} değerlendirilirken ${role.focus} ayrı başlıklar hâlinde çözümlemek gerekir.',
          'Her parçanın görevi, diğer parçalarla kurduğu ilişki üzerinden açıklanır.',
          'Bu sistem bakışı ${role.connection} tek bir bütün içinde gösterir.',
        ];
      case 5:
        return [
          'Bu bakış açısı ${role.focus} gözlenebilir sonuçlarla ilişkilendirir.',
          'Bir açıklamanın gücü, alternatif yorumlara karşı ne kadar kanıt sunduğuyla ölçülür.',
          '$subject için ${role.connection} destekleyen veriler öncelik kazanır.',
        ];
      case 6:
        return [
          'Uygulama düzeyinde ${role.focus} somut bir durum üzerinden ele alınır.',
          'Örnekteki aktörler, kaynaklar ve kararlar birbirinden ayrılarak incelenir.',
          'Bu çözümleme ${role.connection} günlük yaşamdaki karşılığını gösterir.',
        ];
      case 7:
        return [
          'Karşılaştırma için ${role.focus} ortak ölçütlere göre değerlendirilir.',
          'Benzerliklerin yanında maliyet, yarar ve sınırlılık farklılıkları da kaydedilir.',
          'Son seçim, $subject bağlamında ${role.connection} ne ölçüde karşıladığına dayanır.',
        ];
      case 8:
        return [
          'Eleştirel inceleme ${role.focus} görünür kılmayı amaçlar.',
          'Belirsizlikler saklanmadan varsayımlar, riskler ve eksik kanıtlar listelenir.',
          '$subject hakkında dengeli bir yargı için ${role.connection} hesaba katılır.',
        ];
      default:
        return [
          'İleriye dönük değerlendirme ${role.focus} olası değişimlerle birlikte ele alır.',
          'Farklı senaryoların gerçekleşmesini etkileyen fırsatlar ve engeller ayrıştırılır.',
          '$subject için önerilen yön, ${role.connection} sürdürülebilir biçimde güçlendirmelidir.',
        ];
    }
  }

  static List<_FallbackSlide> _selectAcrossOutline(
    List<_FallbackSlide> outline,
    int count,
  ) {
    if (count >= outline.length) return outline.take(count).toList();
    if (count == 1) return [outline.first];

    final selected = <_FallbackSlide>[];
    var previousIndex = -1;
    for (var i = 0; i < count; i += 1) {
      var index = ((i * (outline.length - 1)) / (count - 1)).round();
      if (index <= previousIndex) index = previousIndex + 1;
      selected.add(outline[index]);
      previousIndex = index;
    }
    return selected;
  }

  static _FallbackSlide _slide(
    String title,
    String first,
    String second,
    String third,
    List<String> keywords,
  ) =>
      _FallbackSlide(title, [first, second, third], keywords);

  static List<String> _meaningfulWords(String topic) {
    final tokens = topic
        .toLowerCase()
        .split(RegExp(r'[^a-zçğıöşü0-9]+'))
        .where((word) =>
            word.isNotEmpty && word.length >= 3 && !_stopWords.contains(word))
        .toSet()
        .toList();
    if (tokens.isEmpty && topic.trim().isNotEmpty) {
      return [topic.trim().toLowerCase()];
    }
    return tokens.isEmpty ? ['konu'] : tokens;
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    final first = text[0] == 'i' ? 'İ' : text[0].toUpperCase();
    return first + text.substring(1);
  }
}

class _FallbackSlide {
  const _FallbackSlide(this.title, this.bullets, this.keywords);

  final String title;
  final List<String> bullets;
  final List<String> keywords;
}

class _GeneralRole {
  const _GeneralRole(this.title, this.focus, this.connection);

  final String title;
  final String focus;
  final String connection;
}
