# Arama değerlendirmesi

100 yerel modelden üretilen 450 sorguluk CSV bir **inceleme taslağıdır**. Agent'ın önerdiği model ID'leri
ve boş sonuç beklentileri insan etiketli gerçek kabul edilmez. TR/EN karşılıklar
aynı grupta kalır; grubun development/evaluation ayrımı sabit SHA-256 kuralıdır.
Kilitlemeden önce dil ve kullanıcı niyeti kontrol edilmeli; ilgili bütün yerel
model ID'leri `;` ile yazılmalıdır. Uygun model yoksa expected_none=true ve
relevant_ids boş olur. Belirsizlik her zaman “sonuç yok” anlamına gelmez.

```sh
python3 tool/search_benchmark/prepare.py draft build/search-review.csv
# İnsan incelemesi: query/etiketleri düzelt; review_status=reviewed, reviewer=ad.
python3 tool/search_benchmark/prepare.py lock build/search-review.csv build/search-locked.json
flutter test --no-pub tool/search_benchmark/evaluate_test.dart \
  --dart-define=SUTOLS_BENCHMARK_INPUT=build/search-locked.json \
  --dart-define=SUTOLS_BENCHMARK_OUTPUT=build/search-metrics.json
python3 -m unittest discover -s tool/search_benchmark -p 'test_*.py'
```

Araç mevcut dosyayı ezmez; 200'den az, incelenmemiş, tekrarlı veya çelişkili
etiketleri reddeder. Manuel arama ve otomatik yerleştirmenin güçlü eşleşme
kapısı ayrı ölçülür; ağdan katalog veya AI üretimi çağrılmaz. Kategori kapsamı
tam yerel birleşik katalogdur; üretim bulut kataloğunun ölçümü değildir.

Precision@3 sabit 3 paydalıdır; Recall@3, MRR@3, ilk seçimin doğruluğu ve boş
sonuçlarda yanlış pozitif ayrıca kaydedilir. Gecikme soğuk/sıcak sorguların
karışımıdır; GPU veya kullanıcı görev süresi değildir. Ham sorgu metni sonuç
loguna kopyalanmaz. Kabul eşikleri geliştirme setinde ayrıca kararlaştırılır;
evaluation setine bakarak eşik ayarlanmamalıdır. CSV sonradan değiştirilirse
yeni sürüm olarak tekrar incelenmeli; kilitli sonuçla birleştirilmemelidir.

Geliştirme setindeki sorgularla eşik ayarlandıktan sonra değerlendirme seti
bir kere çalıştırılıp hatalar konu/dil/arama türüyle incelenir. Ünite testindeki
synthetic-unit-fixture inceleyeni yalnızca kapı mantığını sınar; insan onayı
veya arama doğruluğu kanıtı değildir.
