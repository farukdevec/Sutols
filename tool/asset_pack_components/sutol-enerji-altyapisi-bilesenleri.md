# Sutol — Enerji Altyapısı Kategorisi Animasyonlu HTML Bileşenleri

## Bileşen 1: Rüzgar Türbini

**Etiketler (keyword eşleşmesi için):** rüzgar türbini, enerji santrali
**Kategori:** Enerji Altyapısı
**Açıklama:** Rüzgarın estiği yönde sürekli dönen pervaneli bir rüzgar türbinini gösterir.

```html
<div class="sutol-enerji-01-wrap">
<style>
.sutol-enerji-01-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-enerji-01-wrap svg{width:100%;height:100%;}
.sutol-enerji-01-tower{fill:#c7ccd4;}
.sutol-enerji-01-base{fill:#a9b0bc;}
.sutol-enerji-01-hub{fill:#5a9bd8;}
.sutol-enerji-01-blades{transform-box:fill-box;transform-origin:center;animation:sutol-enerji-01-spin 3.5s linear infinite;}
.sutol-enerji-01-blade{fill:#e8edf2;stroke:#b7c0cc;stroke-width:1;}
.sutol-enerji-01-wind{stroke:#bcd4e8;stroke-width:2;stroke-dasharray:14 20;opacity:0.5;animation:sutol-enerji-01-flow 2.4s linear infinite;}
@keyframes sutol-enerji-01-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
@keyframes sutol-enerji-01-flow{to{stroke-dashoffset:-68;}}
@media (prefers-reduced-motion: reduce){
  .sutol-enerji-01-blades{animation-duration:14s;}
  .sutol-enerji-01-wind{animation-duration:10s;}
}
</style>
<svg viewBox="0 0 300 300">
  <line class="sutol-enerji-01-wind" x1="20" y1="70" x2="120" y2="70"/>
  <line class="sutol-enerji-01-wind" x1="20" y1="100" x2="110" y2="100"/>
  <polygon class="sutol-enerji-01-tower" points="147,110 153,110 160,260 140,260"/>
  <rect class="sutol-enerji-01-base" x="130" y="258" width="40" height="10" rx="2"/>
  <g class="sutol-enerji-01-blades">
    <polygon class="sutol-enerji-01-blade" points="150,108 158,60 142,60" transform="rotate(0 150 108)"/>
    <polygon class="sutol-enerji-01-blade" points="150,108 158,60 142,60" transform="rotate(120 150 108)"/>
    <polygon class="sutol-enerji-01-blade" points="150,108 158,60 142,60" transform="rotate(240 150 108)"/>
  </g>
  <circle class="sutol-enerji-01-hub" cx="150" cy="108" r="7"/>
</svg>
</div>
```

---

## Bileşen 2: Baraj ve Hidroelektrik Santrali

**Etiketler (keyword eşleşmesi için):** baraj, enerji santrali, jeneratör
**Kategori:** Enerji Altyapısı
**Açıklama:** Baraj gövdesinden akan suyun türbini döndürüp enerji üretmesini gösterir.

```html
<div class="sutol-enerji-02-wrap">
<style>
.sutol-enerji-02-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-enerji-02-wrap svg{width:100%;height:100%;}
.sutol-enerji-02-wall{fill:#9aa4b2;}
.sutol-enerji-02-water{fill:#5a9bd8;opacity:0.7;}
.sutol-enerji-02-spill{fill:none;stroke:#bcd4e8;stroke-width:4;stroke-linecap:round;stroke-dasharray:10 12;animation:sutol-enerji-02-fall 1.2s linear infinite;}
.sutol-enerji-02-turbine{transform-box:fill-box;transform-origin:center;animation:sutol-enerji-02-spin 1.6s linear infinite;}
.sutol-enerji-02-blade{fill:#3d4b66;}
.sutol-enerji-02-bolt{fill:#e8c168;opacity:0;animation:sutol-enerji-02-pulse 1.6s ease-in-out infinite;}
@keyframes sutol-enerji-02-fall{to{stroke-dashoffset:-44;}}
@keyframes sutol-enerji-02-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
@keyframes sutol-enerji-02-pulse{0%,100%{opacity:0;}50%{opacity:1;}}
@media (prefers-reduced-motion: reduce){
  .sutol-enerji-02-spill,.sutol-enerji-02-turbine,.sutol-enerji-02-bolt{animation-duration:8s;}
}
</style>
<svg viewBox="0 0 300 250">
  <rect class="sutol-enerji-02-water" x="20" y="60" width="90" height="130"/>
  <polygon class="sutol-enerji-02-wall" points="110,50 150,50 150,220 110,220"/>
  <path class="sutol-enerji-02-spill" d="M150,80 Q170,140 190,200"/>
  <g class="sutol-enerji-02-turbine">
    <circle cx="205" cy="205" r="16" fill="none" stroke="#3d4b66" stroke-width="2"/>
    <polygon class="sutol-enerji-02-blade" points="205,192 210,205 205,218 200,205"/>
    <polygon class="sutol-enerji-02-blade" points="192,205 205,200 218,205 205,210"/>
  </g>
  <polygon class="sutol-enerji-02-bolt" points="230,185 220,200 226,200 218,215 234,197 227,197"/>
</svg>
</div>
```

---

## Bileşen 3: Güneş Paneli Tarlası

**Etiketler (keyword eşleşmesi için):** güneş paneli tarlası, enerji santrali, enerji sayacı
**Kategori:** Enerji Altyapısı
**Açıklama:** Güneş ışınlarının panellere düşmesini ve üretilen enerjinin şebekeye doğru akmasını gösterir.

```html
<div class="sutol-enerji-03-wrap">
<style>
.sutol-enerji-03-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-enerji-03-wrap svg{width:100%;height:100%;}
.sutol-enerji-03-sun{fill:#f0c968;}
.sutol-enerji-03-ray{stroke:#f0c968;stroke-width:3;stroke-linecap:round;opacity:0.6;animation:sutol-enerji-03-pulse 2.6s ease-in-out infinite;}
.sutol-enerji-03-r1{animation-delay:0s;}
.sutol-enerji-03-r2{animation-delay:0.3s;}
.sutol-enerji-03-r3{animation-delay:0.6s;}
.sutol-enerji-03-panel{fill:#2f4a6b;stroke:#5a9bd8;stroke-width:1.5;}
.sutol-enerji-03-flow{fill:none;stroke:#5aa87a;stroke-width:3;stroke-dasharray:8 10;animation:sutol-enerji-03-run 1.8s linear infinite;}
@keyframes sutol-enerji-03-pulse{0%,100%{opacity:0.25;}50%{opacity:0.8;}}
@keyframes sutol-enerji-03-run{to{stroke-dashoffset:-36;}}
@media (prefers-reduced-motion: reduce){
  .sutol-enerji-03-ray,.sutol-enerji-03-flow{animation-duration:10s;}
}
</style>
<svg viewBox="0 0 400 220">
  <circle class="sutol-enerji-03-sun" cx="330" cy="50" r="24"/>
  <line class="sutol-enerji-03-ray sutol-enerji-03-r1" x1="330" y1="10" x2="330" y2="0"/>
  <line class="sutol-enerji-03-ray sutol-enerji-03-r2" x1="300" y1="65" x2="285" y2="80"/>
  <line class="sutol-enerji-03-ray sutol-enerji-03-r3" x1="360" y1="65" x2="375" y2="80"/>
  <polygon class="sutol-enerji-03-panel" points="30,150 130,150 110,190 10,190"/>
  <polygon class="sutol-enerji-03-panel" points="140,150 240,150 220,190 120,190"/>
  <polygon class="sutol-enerji-03-panel" points="250,150 350,150 330,190 230,190"/>
  <path class="sutol-enerji-03-flow" d="M70,190 Q100,205 130,205 T280,205 Q330,205 350,180"/>
</svg>
</div>
```

---

## Bileşen 4: Elektrik Şebekesi ve Trafo Merkezi

**Etiketler (keyword eşleşmesi için):** elektrik şebekesi, trafo merkezi, elektrik direği, şebeke dengesi, akü depolama
**Kategori:** Enerji Altyapısı
**Açıklama:** İki elektrik direği arasında akan elektriğin trafo merkezindeki akü deposunu şarj ederek şebekeyi dengelemesini gösterir.

```html
<div class="sutol-enerji-04-wrap">
<style>
.sutol-enerji-04-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-enerji-04-wrap svg{width:100%;height:100%;overflow:visible;}
.sutol-enerji-04-pole{stroke:#8a94a6;stroke-width:4;stroke-linecap:round;}
.sutol-enerji-04-arm{stroke:#8a94a6;stroke-width:3;stroke-linecap:round;}
.sutol-enerji-04-line{fill:none;stroke:#3d4b66;stroke-width:2;}
.sutol-enerji-04-pulse{fill:#5fd0e8;filter:drop-shadow(0 0 3px #5fd0e8);offset-path:path('M60,90 Q200,150 340,90');animation:sutol-enerji-04-run 3s linear infinite;}
.sutol-enerji-04-p2{animation-delay:-1s;}
.sutol-enerji-04-p3{animation-delay:-2s;}
.sutol-enerji-04-station{fill:none;stroke:#e0a24d;stroke-width:2.5;}
.sutol-enerji-04-batt{fill:#5aa87a;transform-box:fill-box;transform-origin:bottom;animation:sutol-enerji-04-charge 4s ease-in-out infinite;}
@keyframes sutol-enerji-04-run{0%{offset-distance:0%;}100%{offset-distance:100%;}}
@keyframes sutol-enerji-04-charge{0%,100%{transform:scaleY(0.3);}50%{transform:scaleY(1);}}
@media (prefers-reduced-motion: reduce){
  .sutol-enerji-04-pulse{animation-duration:10s;}
  .sutol-enerji-04-batt{animation-duration:12s;}
}
</style>
<svg viewBox="0 0 400 220">
  <line class="sutol-enerji-04-pole" x1="60" y1="90" x2="60" y2="200"/>
  <line class="sutol-enerji-04-arm" x1="35" y1="90" x2="85" y2="90"/>
  <line class="sutol-enerji-04-pole" x1="340" y1="90" x2="340" y2="200"/>
  <line class="sutol-enerji-04-arm" x1="315" y1="90" x2="365" y2="90"/>
  <path class="sutol-enerji-04-line" d="M60,90 Q200,150 340,90"/>
  <circle class="sutol-enerji-04-pulse" r="4"/>
  <circle class="sutol-enerji-04-pulse sutol-enerji-04-p2" r="4"/>
  <circle class="sutol-enerji-04-pulse sutol-enerji-04-p3" r="4"/>
  <rect class="sutol-enerji-04-station" x="170" y="185" width="60" height="30"/>
  <rect class="sutol-enerji-04-batt" x="182" y="195" width="12" height="18"/>
  <rect class="sutol-enerji-04-batt" x="198" y="195" width="12" height="18"/>
  <rect class="sutol-enerji-04-batt" x="214" y="195" width="12" height="18"/>
</svg>
</div>
```

---

## Bileşen 5: Doğalgaz Boru Hattı ve Yakıt İstasyonu

**Etiketler (keyword eşleşmesi için):** doğalgaz boru hattı, yakıt istasyonu, enerji sayacı, jeneratör
**Kategori:** Enerji Altyapısı
**Açıklama:** Boru hattından akan gazın bir yakıt tankına ulaşmasını ve gösterge ibresinin sürekli hareket etmesini gösterir.

```html
<div class="sutol-enerji-05-wrap">
<style>
.sutol-enerji-05-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-enerji-05-wrap svg{width:100%;height:100%;overflow:visible;}
.sutol-enerji-05-pipe{fill:none;stroke:#8a94a6;stroke-width:10;stroke-linecap:round;}
.sutol-enerji-05-flow{fill:none;stroke:#e0a24d;stroke-width:4;stroke-linecap:round;stroke-dasharray:16 22;animation:sutol-enerji-05-run 2.2s linear infinite;}
.sutol-enerji-05-tank{fill:#9aa4b2;stroke:#6b7280;stroke-width:2;}
.sutol-enerji-05-gauge{fill:none;stroke:#3d4b66;stroke-width:2;}
.sutol-enerji-05-needle{stroke:#3d4b66;stroke-width:2;transform-box:fill-box;transform-origin:center;animation:sutol-enerji-05-sway 3s ease-in-out infinite;}
@keyframes sutol-enerji-05-run{to{stroke-dashoffset:-76;}}
@keyframes sutol-enerji-05-sway{0%,100%{transform:rotate(-20deg);}50%{transform:rotate(20deg);}}
@media (prefers-reduced-motion: reduce){
  .sutol-enerji-05-flow{animation-duration:10s;}
  .sutol-enerji-05-needle{animation-duration:10s;}
}
</style>
<svg viewBox="0 0 400 180">
  <line class="sutol-enerji-05-pipe" x1="30" y1="110" x2="280" y2="110"/>
  <line class="sutol-enerji-05-flow" x1="30" y1="110" x2="280" y2="110"/>
  <rect class="sutol-enerji-05-tank" x="290" y="60" width="70" height="100" rx="6"/>
  <circle class="sutol-enerji-05-gauge" cx="325" cy="90" r="18"/>
  <line class="sutol-enerji-05-needle" x1="325" y1="90" x2="325" y2="76"/>
</svg>
</div>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Rüzgar Türbini): SVG grup `transform: rotate()` ile pervane dönüşü + `stroke-dashoffset` ile rüzgar akış çizgileri; hafif, GPU dostu.
- Bileşen 2 (Baraj): `stroke-dashoffset` ile su akışı, ayrı `rotate()` ile türbin dönüşü, faz kaydırmalı `opacity` ile enerji sembolü nabzı; orta yoğunluklu.
- Bileşen 3 (Güneş Paneli Tarlası): Gecikmeli `opacity` nabzı ile güneş ışınları + `stroke-dashoffset` ile enerji akış hattı; hafif.
- Bileşen 4 (Elektrik Şebekesi/Trafo Merkezi): CSS `offset-path` ile hat üzerinde akan akım parçacıkları, `scaleY` ile akü şarj/deşarj döngüsü; modern tarayıcı desteği gerektirir, orta maliyetli.
- Bileşen 5 (Doğalgaz Boru Hattı/Yakıt İstasyonu): `stroke-dashoffset` ile gaz akışı, `rotate()` ile gösterge ibresi salınımı; hafif.
- Tüm bileşenler: `prefers-reduced-motion` desteklenir, sabit metin yok, dış kaynak/CDN/font/API çağrısı yok, sınıf adları `sutol-enerji-0N-` önekiyle kapsüllenmiş, kök öğe arka planı `transparent`.
