# Atlas MCP — bilinçli entegrasyon

Atlas'ın grafik ve arama katmanı doğrudan yerel Markdown dosyalarından çalışır; bunun için MCP ya da API anahtarı gerekmez.

`atlas-notes-mcp.js`, aynı kasayı Codex için üç küçük araç olarak açar: `atlas_search_notes`, `atlas_read_note` ve `atlas_recent_notes`. Bu, yalnızca aranan notu bağlama alarak gereksiz token tüketimini azaltır.

## Codex

Codex, Atlas kasasını doğrudan çalışma alanı olarak okuyabilir. MCP yalnızca Obsidian uygulamasını uzaktan yönetmek veya başka servisleri bağlamak gerektiğinde eklenmelidir.

## Obsidian Local REST API (isteğe bağlı)

`cyanheads/obsidian-mcp-server` gibi sunucular Obsidian'ın Local REST API eklentisi ve onun erişim anahtarını ister. Anahtar kişisel bir sırdır; bu depoya veya Atlas ayarlarına yazılmamalıdır. Emre anahtarı sağladığında sunucu, yalnızca bu kasaya sınırlandırılarak Codex'e eklenebilir.

## Token ilkesi

- Dosya tarama, bağlantı çıkarma, özet kartı ve grafik: sıfır model çağrısı.
- Atlas'a Sor: yalnızca seçili notun ilk 5.000 karakteri gönderilir.
- Kalıcı bilgi: önce uygun Markdown notuna yazılır, günlük kayda bağlantısı eklenir.
