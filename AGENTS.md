# Atlas çalışma alanı bağlantısı

Bu proje Emre'nin Atlas ikinci beynine bağlıdır. Atlas vault yolu:
C:\Users\Emre\Documents\EmreOS

## Oturum protokolü

- Başlarken C:\Users\Emre\Documents\EmreOS\AGENTS.md ve
  C:\Users\Emre\Documents\EmreOS\memory\Last-Session.md dosyalarını oku.
- Anlamlı bir karar, araştırma bulgusu, proje kilometre taşı veya açık iş oluştuğunda
  ilgili Atlas düğüm notunu güncelle.
- Oturum bitmeden önce şu komutla günlük kaydı bırak:

  powershell -ExecutionPolicy Bypass -NoProfile -File "C:\Users\Emre\Documents\EmreOS\.atlas\atlas.ps1" Save -Title "Sutols / Codex" -Summary "Bu oturumda yapılanları, kararları ve sonraki adımı kısa yaz."

- Atlas bağlamını güncel tutmak için gerekirse:

  powershell -ExecutionPolicy Bypass -NoProfile -File "C:\Users\Emre\Documents\EmreOS\.atlas\atlas.ps1" Compile

Bu kayıtlar yalnızca Emre'nin yerel Atlas vault'unda tutulur.
