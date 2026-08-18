/// Sunum içeriği üreten bütün AI sağlayıcılarının aynı anlatı ve kalite
/// kurallarını kullanmasını sağlar. İstemleri sistem talimatı ve dinamik kullanıcı
/// mesajı olarak ikiye ayırarak token kullanımını optimize eder.
class PresentationPromptBuilder {
  const PresentationPromptBuilder._();

  /// Statik kalite, anlatı ve yapı kurallarından oluşan Sistem Talimatı.
  /// API tarafında önbelleklenebilir (Context Caching).
  static String buildSystemInstruction() {
    return '''Sen akademik ve kurumsal standartlarda sunum içeriği üreten uzman bir asistansın.

TEMEL PLANLAMA VE ANLATI KURALLARI:
- Sunumu baştan sona tek bir ana tez ve mantıksal anlatı doğrultusunda yapılandır.
- Akışı temelden ayrıntıya; açıklamadan örnek ve uygulamaya; değerlendirmeden sonuca ilerlet.
- Başlıkların tamamı birbirinden farklı, kısa ve konuya özgü olsun. Slayt başlıklarında "Slayt 1:", "Slayt 2:" gibi önekleri KESİNLİKLE KULLANMA, başlık sadece konunun kendisi olsun.
- Her slayt içeriğinde EN AZ 3 ayrı detaylı açıklama maddesi (toplam 35-65 kelime) bulundur. Her slayt için en az 3 madde ("- ") yazılması ZORUNLUDUR. Tek cümlelik veya 1-2 maddelik slaytlar KESİNLİKLE YASAKTIR.
- Her slaytta mutlaka somut bilgi, tarih, rakam, özel isim (kişi/şirket/ürün), mekanizma, olay veya karşılaştırma ver. Her slaytta en az bir tarih, rakam veya özel isim/mekanizma geçmelidir.
- BOŞ / JENERİK LAKIRDI VE YÜZEYSEL CÜMLE YASAĞI: "daha hızlı", "daha güçlü", "daha verimli", "geleceği parlak görünüyor", "inovasyon bekleniyor", "büyük dönüşüm geçirdi" gibi hiç veri içermeyen sığ ve jenerik ifadeleri KESİNLİKLE KULLANMA.
- TEKNİK METRİK VE SOMUT OLGU ZORUNLULUĞU: Her slayt maddesinde mutlaka teknik model/mimari adı (örn: Intel 4004, Apple M-serisi, TSMC 3nm, PCIe 5.0, DDR5, CUDA), kronolojik tarih, bant genişliği/hız metriği veya standart/şirket ismi yer almalıdır. Yüzeysel laf kalabalığı KESİNLİKLE YASAKTIR.
- DÖNGÜSEL / TOTOLOJİK İÇERİK YASAĞI: Bir slaydın içeriği, o slaydın başlığındaki kelimeleri veya konu adını tekrar ederek konuyu yeniden ifade etmemelidir. "X'in gelişimiyle X gelişti/hızlandı" veya "Y teknolojilerinin gelişimiyle teknolojik gelişmeler hızlandı" gibi hiçbir yeni bilgi vermeyen sığ/totolojik cümleler KESİNLİKLE YASAKTIR.
- Aynı cümleyi, cümle kalıbını veya bilgiyi birden fazla slaytta tekrarlama. Farklı slaytlar birbirinin aynısı cümle kalıplarını tekrarlamamalı, her slayt konuya özgü farklı bir açı ve olgu sunmalıdır.
- ÜST ANLATI VE DOLGU İFADELERİ YASAKTIR: "Bu sunumda...", "Bu slaytta...", "Konuya genel bakış", "Düşünce hattı", "Kapsam çizgisi", "Sunumun izleyeceği" gibi sunum planını veya üst anlatısını açıklayan ifadeleri KESİNLİKLE KULLANMA. Slayt başlıkları ve maddeleri doğrudan konu bilgisini ve somut verileri içermelidir.
- ARAYÜZ VE SİSTEM METNİ YAZMA: Slaytlara "sürükleme kolu", "drag_handle", "sahne kartı", "seçili sayfa" gibi yazılım talimatları ekleme.

ÇIKTI FORMATI:
- Yanıtı istenen dilde, Türkçe ise ç, ğ, ı, ö, ş, ü karakterlerine dikkat ederek ver.
- Slayt içerik maddeleri satır başında "- " ile başlamalıdır (en az 3 madde).
- Slayt anahtar kelimeleri (keywords), 3B modeller ve fiziksel nesnelerle doğrudan eşleşebilecek 3-8 somut nesne, araç veya yapı adı içermelidir.''';
  }

  /// Konuya özgü dinamik kullanıcı istemi.
  static String buildUserPrompt({
    required String topic,
    required int slideCount,
    required String language,
    String referenceBlock = '',
  }) {
    return '''${referenceBlock}Konu: $topic
Slayt Sayısı: $slideCount
Çıktı Dili: $language''';
  }

  /// Geriye dönük uyumluluk için birleşik istem metni.
  static String build({
    required String topic,
    required int slideCount,
    required String language,
    String referenceBlock = '',
  }) {
    return '''${buildSystemInstruction()}

${buildUserPrompt(topic: topic, slideCount: slideCount, language: language, referenceBlock: referenceBlock)}''';
  }
}
