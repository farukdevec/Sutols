# Atlas / EmreOS

Atlas, Codex ve OpenCode'un aynı Markdown hafızasını paylaşması için kuruldu.

## Açmak

Masaüstündeki **Atlas** kısayoluna çift tıkla. Bu artık bir Windows masaüstü uygulamasıdır:
merkez HUD'u, bağlam ağı, süreç düğümleri ve okuma paneli tek pencerededir.

## Codex

Masaüstünde veya bu klasörde `Atlas-Codex.cmd` dosyasını aç. `AGENTS.md` Atlas'ın
kalıcı çalışma kurallarını yükler.
Her anlamlı oturumdan sonra:

```powershell
powershell -ExecutionPolicy Bypass -File .\.atlas\atlas.ps1 Save -Title "Kısa başlık" -Summary "Karar, bulgu ve sonraki adım"
```

## OpenCode

Bu klasörde `Atlas-OpenCode.cmd` dosyasını aç. `AGENTS.md`, `.opencode/skills/atlas`
ve şu komutlar otomatik keşfedilir:

- `/atlas-kaydet <özet>`
- `/atlas-derle`

Not: OpenCode ilk açılışta kullanıcı yapılandırmasında hata verirse Atlas dosyalarına
dokunma; önce OpenCode kurulumunu onar. Proje adaptörü hazırdır.

## Bakım

```powershell
powershell -ExecutionPolicy Bypass -File .\.atlas\atlas.ps1 Status
powershell -ExecutionPolicy Bypass -File .\.atlas\atlas.ps1 Compile
```

`Compile`, düğüm notlarından `knowledge/index.md` dosyasını yeniden üretir.
