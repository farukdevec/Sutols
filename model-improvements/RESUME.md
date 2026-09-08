# Model geliştirme döngüsünü devam ettirme

> **Çalışma kullanıcı isteğiyle ertelendi.** Bu dosyalar ekip incelemesi ve daha sonra kaldığı yerden devam etmek içindir. Yeni kullanıcı talimatı gelmeden model geliştirmeye veya yayına devam etmeyin. Durum: [workflow-control.json](workflow-control.json).

Bu dosya, token/oturum kesintisinden sonra sırayı ve sürümleri korumak içindir.

## Her başlangıçta

1. Proje `AGENTS.md`, `prompt.md`, `README.md`, `events.jsonl` son olayları ve ilgili model kaydını oku. `git status --short` ile kullanıcı değişikliklerini koru.
2. Proje kökünde `python3 model-improvements/tools/work_queue.py verify` çalıştır. Hash uyuşmazlığı varsa eski ham dosyadan yeniden üretme.
3. `python3 model-improvements/tools/work_queue.py next` ile sıradaki işleri al. `checkpoint.json` okunabilir durum dökümüdür; işlem kuyruğu `queue.sqlite3`, model doğrulamasının otoritesi `records/*.json` dosyalarıdır.
4. Erişim şartları sağlandığında önce pilotları tamamla; sonra 5–10 modellik partilerde kuyruk sırasıyla ilerle. Tek otomatik animasyon reçetesi uygulama. Her modeli görsel olarak incele ve teknik gerekçesini ayrı yaz.
5. İşlem bitince veya engel ortaya çıkınca model kaydını ve eklemeli olayını güncelle; kuyrukta `checkpoint RECORD_KEY PHASE --next-action 'Somut işlem' --evidence model-improvements/...` komutuyla devam noktasını bırak. Gövdesinde sırf kuyruk değişimi olan olay, modelin incelendiğini veya geliştirildiğini ifade etmez.
6. Partiden sonra `status` çalıştır; aday / validated / published / gerçek inceleme engeli / henüz denenmemiş kaynak sayılarını ayrı raporla. Oturum limitinde bitmeyen modelin temel ve aday SHA-256/revizyonlarını koru.

## Kuyruk güvenilirliği

- Tek yazarlı dosya kilidi ve SQLite `synchronous=FULL` transaction kullanılır.
- Olay önce SQLite outbox'a kaydedilir, sonra `events.jsonl` sonuna fsync ile eklenir. İşlem arada kesilirse olay kimliğiyle tekrar ekleme önlenir.
- Model adayı var ise yeniden üretime alınmaz; uygulama doğrulaması bekler.
- Kaydedilmiş adayın dosya özeti değişmişse devam engellenir.
- Kuyruk, modeli kendi başına `validated` veya `published` yapamaz.
- Eksik/kısmi JSONL son satırı otomatik silinmez. Araç durur; mevcut günlüğü koruyan açık bir kurtarma işlemi gerekir.
- Bu korumalar yerel kuyruk içindir. Bulut yayınında koşullu katalog güncellemesi/rollback koruması henüz uygulanmış değildir.

Test: `python3 -m unittest discover -s model-improvements/tools -p test_work_queue.py -v`

## Mevcut devam noktası — 8 Eylül 2026

- Anıtkabir `533a4fd62f2b3444`, r1 aday: `e87627a22ff27accbd0dd0ec043d0800474bc3e499ed9dd932648634d5e7f274`. Yerel model-viewer kontrolleri var; gerçek Sutols ve hedef cihaz performans kapıları açık. Önceki ham dosyadan tekrar başlamayın.
- 1.040 uzak kaynak adayı `awaiting_access`. Beş pilotun önceki oturumsuz istekleri 403. Diğer 1.035 kaynak **tek tek istenmedi/incelenmedi**; ortak erişim önkoşulu nedeniyle ertelendi.
- 8 Eylül: Chrome hesabı girişli, canlı model araması çalışıyor. Ambulans seçimi model-viewer kaynağı oluşturuyor. GLB yerel alımı Cloudflare HTTP 403 / 1010; görsel render ve dosya içeriği doğrulanamadı. Girişli olmak toplu kaynak edinimini tek başına çözmedi.
- Yolcu Uçağı ve Gerçekçi Dünya paket kaynakları yerelde yok; katalogda yazan hosting yolları GLB yerine HTML döndürüyor.
- Sonraki somut ihtiyaç: mevcut projeye ait yetkili R2/Firestore geliştirme yapılandırması veya orijinal GLB kaynaklarının bulunduğu yerel klasör. Şifre/token günlükte tutulmamalı; imzalı URL kimlik olarak kullanılmamalı.

Bu kuyruk tek başına 3D modelleri düzenleyen arka plan servisi değildir. Model başına karar, inceleme ve kalite kapıları ajan tarafından yürütülür; tamamlanmamış iş sonraki oturumda aynı kayıttan sürdürülür.
