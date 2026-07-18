# Sutol — El Sanatları & Zanaat Kategorisi Animasyonlu HTML Bileşenleri

## Bileşen 1: Çömlekçi Çarkı

**Etiketler (keyword eşleşmesi için):** çömlekçi çarkı, seramik fırını
**Kategori:** El Sanatları & Zanaat
**Açıklama:** Dönen çömlekçi çarkı üzerinde kilin yavaşça bir vazo formuna doğru yükselmesini, yanındaki fırının hafifçe parlamasını gösterir.

```html
<div class="sutol-sanat-01-wrap">
<style>
.sutol-sanat-01-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-sanat-01-wrap svg{width:100%;height:100%;}
.sutol-sanat-01-wheel{fill:#8a6a4a;transform-box:fill-box;transform-origin:center;animation:sutol-sanat-01-spin 1.4s linear infinite;}
.sutol-sanat-01-clay{fill:#c98a52;transform-box:fill-box;transform-origin:bottom;animation:sutol-sanat-01-grow 4s ease-in-out infinite;}
.sutol-sanat-01-kiln{fill:#e0994d;opacity:0.3;animation:sutol-sanat-01-glow 2.4s ease-in-out infinite;}
.sutol-sanat-01-kiln-body{fill:none;stroke:#8a94a6;stroke-width:2;}
@keyframes sutol-sanat-01-spin{from{transform:rotate(0deg) scaleY(0.28);}to{transform:rotate(360deg) scaleY(0.28);}}
@keyframes sutol-sanat-01-grow{0%,10%{transform:scaleY(0.3);}45%,80%{transform:scaleY(1);}95%,100%{transform:scaleY(0.3);}}
@keyframes sutol-sanat-01-glow{0%,100%{opacity:0.15;}50%{opacity:0.5;}}
@media (prefers-reduced-motion: reduce){
  .sutol-sanat-01-wheel{animation-duration:6s;}
  .sutol-sanat-01-clay,.sutol-sanat-01-kiln{animation-duration:14s;}
}
</style>
<svg viewBox="0 0 300 260">
  <rect class="sutol-sanat-01-kiln-body" x="220" y="120" width="50" height="60" rx="4"/>
  <rect class="sutol-sanat-01-kiln" x="228" y="128" width="34" height="44" rx="3"/>
  <ellipse class="sutol-sanat-01-wheel" cx="130" cy="190" rx="55" ry="16"/>
  <path class="sutol-sanat-01-clay" d="M115,190 Q110,140 130,110 Q150,140 145,190 Z"/>
</svg>
</div>
```

---

## Bileşen 2: Dokuma Tezgahı ve Halı Dokuma

**Etiketler (keyword eşleşmesi için):** dokuma tezgahı, halı dokuma
**Kategori:** El Sanatları & Zanaat
**Açıklama:** Dikey çözgü iplikleri arasında mekiğin gidip gelmesini ve renkli halı sıralarının alttan üste doğru oluşmasını gösterir.

```html
<div class="sutol-sanat-02-wrap">
<style>
.sutol-sanat-02-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-sanat-02-wrap svg{width:100%;height:100%;}
.sutol-sanat-02-warp{stroke:#b7c0cc;stroke-width:1.5;}
.sutol-sanat-02-row{transform-box:fill-box;transform-origin:left;animation:sutol-sanat-02-row 5s ease-in-out infinite;}
.sutol-sanat-02-r1{fill:#c9622e;animation-delay:0s;}
.sutol-sanat-02-r2{fill:#e0a24d;animation-delay:0.4s;}
.sutol-sanat-02-r3{fill:#5a9bd8;animation-delay:0.8s;}
.sutol-sanat-02-r4{fill:#5aa87a;animation-delay:1.2s;}
@keyframes sutol-sanat-02-row{0%,8%{transform:scaleX(0);opacity:0;}25%{opacity:1;}40%,85%{transform:scaleX(1);opacity:1;}95%,100%{opacity:0;}}
.sutol-sanat-02-shuttle{fill:#3d4b66;animation:sutol-sanat-02-move 1.6s ease-in-out infinite;}
@keyframes sutol-sanat-02-move{0%,100%{transform:translateX(0);}50%{transform:translateX(220px);}}
@media (prefers-reduced-motion: reduce){
  .sutol-sanat-02-row{animation-duration:16s;}
  .sutol-sanat-02-shuttle{animation-duration:6s;}
}
</style>
<svg viewBox="0 0 320 220">
  <line class="sutol-sanat-02-warp" x1="40" y1="20" x2="40" y2="200"/>
  <line class="sutol-sanat-02-warp" x1="80" y1="20" x2="80" y2="200"/>
  <line class="sutol-sanat-02-warp" x1="120" y1="20" x2="120" y2="200"/>
  <line class="sutol-sanat-02-warp" x1="160" y1="20" x2="160" y2="200"/>
  <line class="sutol-sanat-02-warp" x1="200" y1="20" x2="200" y2="200"/>
  <line class="sutol-sanat-02-warp" x1="240" y1="20" x2="240" y2="200"/>
  <line class="sutol-sanat-02-warp" x1="280" y1="20" x2="280" y2="200"/>
  <rect class="sutol-sanat-02-row sutol-sanat-02-r1" x="40" y="170" width="240" height="16"/>
  <rect class="sutol-sanat-02-row sutol-sanat-02-r2" x="40" y="150" width="240" height="16"/>
  <rect class="sutol-sanat-02-row sutol-sanat-02-r3" x="40" y="130" width="240" height="16"/>
  <rect class="sutol-sanat-02-row sutol-sanat-02-r4" x="40" y="110" width="240" height="16"/>
  <rect class="sutol-sanat-02-shuttle" x="30" y="88" width="20" height="8" rx="3"/>
</svg>
</div>
```

---

## Bileşen 3: Cam Üfleme

**Etiketler (keyword eşleşmesi için):** cam üfleme
**Kategori:** El Sanatları & Zanaat
**Açıklama:** Üfleme borusunun ucunda kor halindeki cam baloncuğunun dönerek büyümesini gösterir.

```html
<div class="sutol-sanat-03-wrap">
<style>
.sutol-sanat-03-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-sanat-03-wrap svg{width:100%;height:100%;}
.sutol-sanat-03-pipe{stroke:#8a94a6;stroke-width:6;stroke-linecap:round;}
.sutol-sanat-03-bubble{fill:url(#sutol-sanat-03-grad);transform-box:fill-box;transform-origin:center;animation:sutol-sanat-03-grow 4s ease-in-out infinite;}
@keyframes sutol-sanat-03-grow{0%,10%{transform:scale(0.4) rotate(0deg);}50%{transform:scale(1) rotate(180deg);}90%,100%{transform:scale(0.4) rotate(360deg);}}
@media (prefers-reduced-motion: reduce){.sutol-sanat-03-bubble{animation-duration:14s;}}
</style>
<svg viewBox="0 0 300 200">
  <defs>
    <radialGradient id="sutol-sanat-03-grad" cx="40%" cy="35%" r="65%">
      <stop offset="0%" stop-color="#ffdca0"/>
      <stop offset="55%" stop-color="#e8843d"/>
      <stop offset="100%" stop-color="#c9622e"/>
    </radialGradient>
  </defs>
  <line class="sutol-sanat-03-pipe" x1="20" y1="100" x2="180" y2="100"/>
  <circle class="sutol-sanat-03-bubble" cx="210" cy="100" r="45"/>
</svg>
</div>
```

---

## Bileşen 4: Ahşap Oyma ve Deri İşleme

**Etiketler (keyword eşleşmesi için):** ahşap oyma, deri işleme, kalemişi
**Kategori:** El Sanatları & Zanaat
**Açıklama:** Bir kalemin ahşap veya deri yüzey üzerinde süslü bir desen izleyerek oyma çizgisi bırakmasını gösterir.

```html
<div class="sutol-sanat-04-wrap">
<style>
.sutol-sanat-04-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-sanat-04-wrap svg{width:100%;height:100%;overflow:visible;}
.sutol-sanat-04-block{fill:#c9a06a;stroke:#8a6a3f;stroke-width:2;}
.sutol-sanat-04-groove{fill:none;stroke:#6b4a2a;stroke-width:2.5;stroke-linecap:round;stroke-dasharray:260;stroke-dashoffset:260;animation:sutol-sanat-04-carve 4s ease-in-out infinite;}
.sutol-sanat-04-tool{fill:#5a5f6b;offset-path:path('M60,150 Q120,90 180,120 T300,110');animation:sutol-sanat-04-move 4s ease-in-out infinite;}
@keyframes sutol-sanat-04-carve{0%,8%{stroke-dashoffset:260;}80%,100%{stroke-dashoffset:0;}}
@keyframes sutol-sanat-04-move{0%{offset-distance:0%;}80%,100%{offset-distance:100%;}}
@media (prefers-reduced-motion: reduce){
  .sutol-sanat-04-groove{animation-duration:14s;}
  .sutol-sanat-04-tool{animation-duration:14s;}
}
</style>
<svg viewBox="0 0 320 200">
  <rect class="sutol-sanat-04-block" x="40" y="60" width="260" height="110" rx="4"/>
  <path class="sutol-sanat-04-groove" d="M60,150 Q120,90 180,120 T300,110"/>
  <polygon class="sutol-sanat-04-tool" points="0,-6 14,0 0,6"/>
</svg>
</div>
```

---

## Bileşen 5: Telkari İşçiliği

**Etiketler (keyword eşleşmesi için):** telkari
**Kategori:** El Sanatları & Zanaat
**Açıklama:** İnce tellerden oluşan iç içe kıvrımlı bir telkari deseninin kendini yavaşça çizmesini gösterir.

```html
<div class="sutol-sanat-05-wrap">
<style>
.sutol-sanat-05-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-sanat-05-wrap svg{width:100%;height:100%;}
.sutol-sanat-05-wire{fill:none;stroke:#d4af6a;stroke-width:2.5;stroke-linecap:round;stroke-dasharray:520;stroke-dashoffset:520;animation:sutol-sanat-05-draw 5s ease-in-out infinite;}
@keyframes sutol-sanat-05-draw{0%,8%{stroke-dashoffset:520;}70%,90%{stroke-dashoffset:0;}100%{stroke-dashoffset:-520;}}
@media (prefers-reduced-motion: reduce){.sutol-sanat-05-wire{animation-duration:16s;}}
</style>
<svg viewBox="0 0 300 300">
  <path class="sutol-sanat-05-wire" d="M150,150 m-70,0 a70,70 0 1,1 140,0 a50,50 0 1,1 -100,0 a30,30 0 1,1 60,0 a12,12 0 1,1 -24,0"/>
</svg>
</div>
```

---

## Bileşen 6: Nakış, Örgü ve Mozaik Döşeme

**Etiketler (keyword eşleşmesi için):** nakış, örgü, mozaik döşeme
**Kategori:** El Sanatları & Zanaat
**Açıklama:** Bir iğnenin kumaş üzerinde ileri geri geçerek dikiş desenini tamamlamasını, yanında ise renkli karoların tek tek yerine yerleşerek mozaik oluşturmasını gösterir.

```html
<div class="sutol-sanat-06-wrap">
<style>
.sutol-sanat-06-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-sanat-06-wrap svg{width:100%;height:100%;overflow:visible;}
.sutol-sanat-06-fabric{fill:none;stroke:#b7c0cc;stroke-width:1;}
.sutol-sanat-06-stitch{fill:none;stroke:#c9622e;stroke-width:3;stroke-linecap:round;stroke-dasharray:12 10;animation:sutol-sanat-06-run 2s linear infinite;}
.sutol-sanat-06-needle{fill:#8a94a6;offset-path:path('M40,60 Q70,20 100,60 Q130,100 160,60 Q190,20 220,60');animation:sutol-sanat-06-move 3s ease-in-out infinite;}
@keyframes sutol-sanat-06-run{to{stroke-dashoffset:-44;}}
@keyframes sutol-sanat-06-move{0%{offset-distance:0%;}100%{offset-distance:100%;}}
.sutol-sanat-06-tile{opacity:0;transform-box:fill-box;transform-origin:center;animation:sutol-sanat-06-place 4s ease-in-out infinite;}
.sutol-sanat-06-t1{fill:#5a9bd8;animation-delay:0s;}
.sutol-sanat-06-t2{fill:#e0a24d;animation-delay:0.3s;}
.sutol-sanat-06-t3{fill:#5aa87a;animation-delay:0.6s;}
.sutol-sanat-06-t4{fill:#c975c9;animation-delay:0.9s;}
@keyframes sutol-sanat-06-place{0%,10%{opacity:0;transform:scale(0.4);}30%,80%{opacity:1;transform:scale(1);}95%,100%{opacity:0;transform:scale(0.4);}}
@media (prefers-reduced-motion: reduce){
  .sutol-sanat-06-stitch,.sutol-sanat-06-needle,.sutol-sanat-06-tile{animation-duration:14s;}
}
</style>
<svg viewBox="0 0 300 200">
  <rect class="sutol-sanat-06-fabric" x="20" y="30" width="220" height="70"/>
  <path class="sutol-sanat-06-stitch" d="M40,60 Q70,20 100,60 Q130,100 160,60 Q190,20 220,60"/>
  <polygon class="sutol-sanat-06-needle" points="0,-3 16,0 0,3"/>
  <rect class="sutol-sanat-06-tile sutol-sanat-06-t1" x="250" y="120" width="18" height="18"/>
  <rect class="sutol-sanat-06-tile sutol-sanat-06-t2" x="270" y="120" width="18" height="18"/>
  <rect class="sutol-sanat-06-tile sutol-sanat-06-t3" x="250" y="140" width="18" height="18"/>
  <rect class="sutol-sanat-06-tile sutol-sanat-06-t4" x="270" y="140" width="18" height="18"/>
</svg>
</div>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Çömlekçi Çarkı): `rotate()` + `scaleY` ile çark dönüşü, ayrı `scaleY` ile kil yükselişi, `opacity` nabzı ile fırın parıltısı; hafif.
- Bileşen 2 (Dokuma Tezgahı): Gecikmeli `scaleX` ile sıraların dokunma animasyonu, `translateX` ile mekik hareketi; hafif.
- Bileşen 3 (Cam Üfleme): `scale + rotate` kombinasyonu ile baloncuk büyümesi, radyal gradyan ile kor efekti; hafif.
- Bileşen 4 (Ahşap Oyma/Deri İşleme): `stroke-dashoffset` ile oyma çizgisi belirmesi, CSS `offset-path` ile kalemin çizgiyi takip etmesi; orta maliyetli, modern tarayıcı desteği gerektirir.
- Bileşen 5 (Telkari): Çok segmentli `stroke-dasharray/dashoffset` ile iç içe kıvrımlı telin çizilmesi; hafif.
- Bileşen 6 (Nakış/Örgü/Mozaik): `stroke-dashoffset` ile dikiş çizgisi, `offset-path` ile iğne hareketi, gecikmeli `scale/opacity` ile mozaik karolarının belirmesi; orta maliyetli.
- Tüm bileşenler: `prefers-reduced-motion` desteklenir, sabit metin yok, dış kaynak/CDN/font/API çağrısı yok, sınıf adları `sutol-sanat-0N-` önekiyle kapsüllenmiş, kök öğe arka planı `transparent`.
