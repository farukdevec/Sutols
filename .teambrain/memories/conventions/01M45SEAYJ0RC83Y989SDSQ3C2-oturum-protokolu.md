---
id: 01M45SEAYJ0RC83Y989SDSQ3C2
class: convention
scope: team
status: active
priority: advisory
title: "Sutols TeamBrain çalışma protokolü"
created: 2026-10-05
supersedes: []
tags:
  - sutols
  - teambrain
  - workflow
ttl_days: null
---

## Sutols TeamBrain çalışma protokolü

- Sutols ekip belleğinin kaynak doğrusu bu repodaki `.teambrain/` dizinidir.
- Oturum başında TeamBrain bağlamı kullanılmalı; geçmiş kararlar gerektiğinde
  `memory_search` ile aranmalıdır.
- Kalıcı değeri olan şaşırtıcı karar, tekrar eden hata, proje haritası veya çalışma
  kuralı `memory_propose` ya da `tb propose` ile aday gösterilmelidir.
- Bellek değişiklikleri inceleme sürecinden geçmelidir. Geçici çalışma ayrıntıları,
  kolayca koddan çıkarılabilen bilgiler ve doğrulanmamış varsayımlar kaydedilmemelidir.
- API anahtarı, erişim belirteci, kişisel veri veya başka sırlar belleğe yazılmamalıdır.
- `priority: required` yalnızca her oturumda zorunlu olan az sayıdaki kural için
  kullanılmalı; diğer kayıtlar `advisory` kalmalıdır.
- Bellek değişikliklerinden sonra `tb lint .teambrain` çalıştırılmalıdır.
