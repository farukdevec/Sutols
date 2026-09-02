# Sanal tur düzenleme geliştirmesi — araştırma notu

**Tarih:** 29 Ağustos 2026  
**Kapsam:** Sutols editöründe Sanal Tur’un editör içi tam-boyut çalışması ve
klavye/fare ile serbest 3B gezinme.

## Sonuç

Sanal tur, ayrı bir pencere değil, editörün seçili 3B modeli tam sahneye
yerleştiren bir çalışma durumu olmalıdır. Gezinme hareketi fiziksel klavye
konumlarıyla, `keydown` başlangıcı ve `keyup` bitişiyle sürdürülmelidir.
Kamera hedefini model geometrisinin iç sınırına clamp etmek, kullanıcının
modelin içine veya ötesine ilerlemesini engellediği için kaldırılmalıdır;
uygulama katmanındaki mutlak güvenlik sınırı korunur.

## Kaynak-ledger

- [model-viewer: Staging & Cameras](https://modelviewer.dev/docs/index.html)
  — `camera-controls`, kamera interpolasyonu ve özelleştirilmiş etkileşim
  davranışları için birincil API referansı. Erişim: 29 Ağustos 2026.
- [model-viewer: Staging & Camera Control example](https://modelviewer.dev/examples/staging-and-camera-control.html)
  — kamera orbit’i ve kullanıcı etkileşimi için çalışma örneği. Erişim: 29
  Ağustos 2026.
- [W3C Pointer Lock](https://www.w3.org/TR/2016/REC-pointerlock-20161027/)
  — FPS/3B modelleme kullanımında sınırsız göreli fare hareketi; odak ve ESC
  ile çıkış davranışı. Erişim: 29 Ağustos 2026.
- [MDN: KeyboardEvent.code](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/code)
  — fiziksel tuş konumunun düzen bağımsız hareket denetimi için uygunluğu ve
  `keydown`/`keyup` tabanlı sürekli hareket yaklaşımı. Erişim: 29 Ağustos 2026.
- [model-viewer: Annotations](https://modelviewer.dev/examples/annotations.html)
  — durak/annotation koordinatlarının `camera-target` ile aynı model uzayını
  kullanması. Erişim: 29 Ağustos 2026.
- [W3C WCAG 2.2 — Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html)
  — işlevlerin klavye eşdeğerleriyle erişilebilir kalması. Erişim: 29 Ağustos
  2026.

## Uygulama doğrulama hedefleri

1. Sanal Tur tuşu editör içinde tur görünümünü açar; yeni pencere ya da başlık
   oluşturmaz.
2. Tur sahnesi yalnızca seçili 3B modeli tam boyutta gösterir; slaytın metin
   kutuları gizlenir.
3. WASD/ok tuşları aynı anda çapraz hareketi destekler; hedef konumu model
   bounding box’ına takılmaz.
4. Durak ekleme, koordinatla ekleme, durak düzenleme/silme, bağlantı durumu,
   turu sabitleme ve başlangıca dönme araçları editör içinde kalır.
