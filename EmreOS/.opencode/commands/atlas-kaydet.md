---
description: Oturumdaki kararlari, isleri ve �grenilenleri Atlas hafizasina kaydet
---

Bu oturumu Atlas i�in kalicilastir. �nce `AGENTS.md` ile ilgili d�g�m notlarini oku.
Konusmadaki kararlari, arastirma bulgularini, a�ik isleri ve sonraki adimi kisa,
somut maddeler h�linde uygun d�g�m dosyasina ekle. Sonra PowerShell'de su komutu
�alistirarak g�nl�k kaydi olustur:

`powershell -ExecutionPolicy Bypass -File .\.atlas\atlas.ps1 Save -Title "OpenCode oturumu" -Summary "$ARGUMENTS"`

En son `memory/Last-Session.md` ve `memory/Threads.md` dosyalarini g�ncelle.
