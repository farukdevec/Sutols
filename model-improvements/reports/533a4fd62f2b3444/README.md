# Anıtkabir — r1 aday incelemesi

**Durum: candidate. Yayın ve uygulamadaki paket dosyası değiştirilmedi.**

`anitkabir` kimliği Dart paket kataloğunda doğrulandı. `https://sutols.web.app/models/anitkabir.glb` dosyasının SHA-256 değeri yerel kaynak ve katalogla aynı. Firestore alias mutabakatı yapılamadı; R2 anahtarı uydurulmadı. Yayındaki temel sürümün revizyon alanı bilinmiyor; temel sürüm içerik özetiyle tanımlandı.

## Somut düzeltme

Yapı, arazi ve direk sabit kalıyor. Kaynak GLB'de kumaş, ön ay-yıldız ve arka ay-yıldız üç ayrı animasyon klibiydi. İlk klibin oynatıldığı yakın planda kumaş, sabit sembolün bir kısmını örtüyordu. Adayda üç düğüm aynı morph sampler üzerinden ilk ve tek `Sutols_Functional_Loop` klibinde birlikte hareket ediyor. Zaman anahtarları 0,041667–4,041667 yerine 0–4 saniye; ilk bekleme kaldırıldı. Yeni hareket geometrisi eklenmedi.

[Önce: sembol kaybı](before/flag-1.png) · [Sonra: sembol kumaşla birlikte](after/flag-1.png) · [Genel görünüm](after/three-quarter.png) · [Yeni küçük resim](anitkabir-r1-thumbnail.webp)

[model-viewer belgesi](https://modelviewer.dev/docs/index.html) ve [glTF animasyon sözleşmesi](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#animations) esas alındı. Render incelemesi uygulamanın kullandığı model-viewer 4.3.1 sürümündedir.

## Ölçümler

| Alan | Kaynak | r1 |
| --- | ---: | ---: |
| Dosya byte | 3.507.628 | 3.507.296 |
| Boyut X/Y/Z | 500 / 34,96999994 / 235,00001526 | Aynı |
| Merkez X/Y/Z | -105 / 13,93500002 / 0 | Aynı |
| Taban Y | -3,54999995 | Aynı |
| Benzersiz mesh üçgeni | 58.472 | 58.472 |
| Düğüm / mesh / primitive | 2.001 / 272 / 275 | Aynı |
| Sahnedeki primitive örneği | 2.074 | 2.074 |
| Materyal / doku | 26 / 6 | Aynı |
| Doku çözünürlüğü | 6 × 512 × 512 | Aynı |
| RGBA+mipmap bellek tahmini | Yaklaşık 8 MiB | Aynı |
| Klip / eşzamanlı kanal | 3 / ilk klipte 1 | 1 / 3 |

Primitive örneği ölçülmüş GPU draw call sayısı değildir. GPU bellek değeri hesap tahminidir. 97 anahtar zamanı üzerinde doğrusal morph hareketinin zarfı hesaplandı; tüm modelin hareket zarfında büyüme yok. UV, rig durumu, materyal, doku, node isimleri ve kök dönüşümleri korunuyor. Binary değişikliği yalnız 388 byte zaman accessor bölgesinde; diğer binary içerik aynı.

Temel SHA-256: `15f5d50eb5dd9c433a458d77d09a55c40cc390134a67c018c070ff5ebf5348eb`.

r1 SHA-256: `e87627a22ff27accbd0dd0ec043d0800474bc3e499ed9dd932648634d5e7f274`.

[Aday GLB](anitkabir-r1-e87627a22ff27accbd0dd0ec043d0800474bc3e499ed9dd932648634d5e7f274.glb) · [Değişmezlik kontrolleri](invariants.json) · [Üretim kanıtı](candidate-build.json)

## Doğrulama ve açık kapılar

- Validator önce/sonra **0 hata, 73 aynı uyarı**. Uyarılar eksik tangent verisinin renderer tarafından üretilmesiyle ilgili. Her uyarının yolu ve değerlendirmesi [warning-review.json](warning-review.json) içinde; platformlar arası sonuç doğrulanmadığından genel kabul verilmedi. Üç dejenere üçgen bildirimi bilgi seviyesinde, kaynakla aynı.
- Ön/yan/üç çeyrek ve bayrak yakın planları alındı. Adaydaki sembolün 1. ve 3. saniye görüntüleri görünür; döngü ucu morph ağırlıkları birebir eşit. Materyal gerçekçiliğinde bu revizyonda değişiklik yapılmadı.
- Seri Chrome testinde **duraklat/devam ve üç gerçek döngü geçti**: duraklatılmış zaman 0,45 saniyede sabit, devam sonrası 0,4667; 241 oynatma zamanı örneğinde üç başa dönüş ölçüldü. [Tarayıcı kanıtı](after/browser.json), [üç döngü görüntü dizisi](after/three-loop-contact-sheet.png) ve [video referansı](after/video-reference.json). Genel kadraj ve yakın plandaki sembol görünürlüğü incelendi. İlk testlerdeki FFmpeg eksikliği, yazılım render ölçümü ve `loop` olayı zaman aşımı [qa-attempts.json](qa-attempts.json) içinde korunuyor. `loop` olayı gelmezken gerçek zamanın ilerlediği doğrulandı; QA gerçek zaman dönüşünü esas alacak şekilde düzeltildi.
- Gerçek Sutols editör/önizleme, kaydet–kapat–aç, HTML/PDF dışa aktarma, tur/kamera, eski önbellek, süresi dolan URL, çevrimdışı ve slayta geri dönme testleri `not_run`.
- Hedef cihazda tek/üç model yükleme ve kare süresi karşılaştırması `not_run`. Performans bütçesi geçmiş sayılmadı.
- Koşullu bulut yayın ve otomatik eskiye dönüş koruması `not_implemented`. Canlı dosya/paket metadata değiştirilmedi.

Sonraki adım: yetkili Sutols oturumunda uygulama ve performans kapıları. Bunlar bitmeden `validated` veya `published` yapılmamalı. Bir sonraki oturum bu r1 adayı ve kayıtlı temel özeti kullanmalı.
