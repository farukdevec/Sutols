---
id: 01M45SEAYJ0RC83Y989SDSQ3C2
class: convention
scope: team
status: active
priority: advisory
title: "Oturum protokolü"
created: 2026-10-05
supersedes: []
tags:
  - imported
  - "source:AGENTS.md"
ttl_days: null
---

## Oturum protokolü

- Dış dizin izni yoksa başlangıç dosyalarını okumaya çalışma.
- Anlamlı bir karar, araştırma bulgusu, proje kilometre taşı veya açık iş oluştuğunda
  ilgili Atlas düğüm notunu güncelle.
- Oturum bitmeden önce şu komutla günlük kaydı bırak:

  powershell -ExecutionPolicy Bypass -NoProfile -File "C:\Users\Emre\Documents\EmreOS\.atlas\atlas.ps1" Save -Title "Sutols / Codex" -Summary "Bu oturumda yapılanları, kararları ve sonraki adımı kısa yaz."

- Atlas bağlamını güncel tutmak için gerekirse:

  powershell -ExecutionPolicy Bypass -NoProfile -File "C:\Users\Emre\Documents\EmreOS\.atlas\atlas.ps1" Compile

Bu kayıtlar yalnızca Emre'nin yerel Atlas vault'unda tutulur.
