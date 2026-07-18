# Fotoğrafçılık Kategorisi — 20 Animasyonlu HTML Bileşeni

---

## Bileşen 1: Objektif Odak Halkaları

**Etiketler (keyword eşleşmesi için):** objektif, pozlama, kompozisyon kuralı
**Kategori:** Fotoğrafçılık
**Açıklama:** İç içe mercek halkalarının hafifçe döner şekilde yakınlaşıp uzaklaşması, bir objektifin odaklanma sürecini simgeler.

```html
<div class="sutol-foto-01-wrap">
  <svg class="sutol-foto-01-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-01-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-01-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-01-ring { fill: none; stroke: #3a3a3a; stroke-width: 2; transform-box: fill-box; transform-origin: 100px 70px; }
      .sutol-foto-01-r1 { animation: sutol-foto-01-focus 4s ease-in-out infinite; }
      .sutol-foto-01-r2 { animation: sutol-foto-01-focus 4s ease-in-out infinite 0.3s; stroke: #6b6b6b; }
      .sutol-foto-01-r3 { animation: sutol-foto-01-focus 4s ease-in-out infinite 0.6s; stroke: #9b9b9b; }
      .sutol-foto-01-glass { fill: #a8dadc; opacity: 0.4; animation: sutol-foto-01-shine 4s ease-in-out infinite; }
      @keyframes sutol-foto-01-focus {
        0%, 100% { transform: scale(1) rotate(0deg); }
        50% { transform: scale(0.85) rotate(20deg); }
      }
      @keyframes sutol-foto-01-shine { 0%, 100% { opacity: 0.25; } 50% { opacity: 0.55; } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-01-ring, .sutol-foto-01-glass { animation-duration: 12s; }
      }
    </style>
    <circle class="sutol-foto-01-glass" cx="100" cy="70" r="34"/>
    <circle class="sutol-foto-01-ring sutol-foto-01-r1" cx="100" cy="70" r="34"/>
    <circle class="sutol-foto-01-ring sutol-foto-01-r2" cx="100" cy="70" r="24"/>
    <circle class="sutol-foto-01-ring sutol-foto-01-r3" cx="100" cy="70" r="14"/>
  </svg>
</div>
```

---

## Bileşen 2: Açılıp Kapanan Diyafram

**Etiketler (keyword eşleşmesi için):** diyafram, objektif, pozlama
**Kategori:** Fotoğrafçılık
**Açıklama:** Altıgen diyafram yapraklarının merkezi bir deliği açıp kapatarak nefes alması, ışık miktarını ayarlayan diyafram mekanizmasını canlandırır.

```html
<div class="sutol-foto-02-wrap">
  <svg class="sutol-foto-02-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-02-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-02-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-02-blade { fill: #2b2b2b; transform-box: fill-box; transform-origin: 100px 70px; animation: sutol-foto-02-iris 3.6s ease-in-out infinite; }
      .sutol-foto-02-b1 { animation-delay: 0s; }
      .sutol-foto-02-b2 { animation-delay: 0s; transform: rotate(60deg); }
      .sutol-foto-02-b3 { animation-delay: 0s; transform: rotate(120deg); }
      .sutol-foto-02-b4 { animation-delay: 0s; transform: rotate(180deg); }
      .sutol-foto-02-b5 { animation-delay: 0s; transform: rotate(240deg); }
      .sutol-foto-02-b6 { animation-delay: 0s; transform: rotate(300deg); }
      @keyframes sutol-foto-02-iris {
        0%, 100% { transform: scale(1) rotate(0deg); }
        50% { transform: scale(0.55) rotate(18deg); }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-02-blade { animation-duration: 12s; }
      }
    </style>
    <circle fill="#e5e5e5" cx="100" cy="70" r="36"/>
    <g class="sutol-foto-02-blade sutol-foto-02-b1"><polygon points="100,40 118,66 100,72 82,66"/></g>
    <g class="sutol-foto-02-blade sutol-foto-02-b2" style="animation:sutol-foto-02-iris 3.6s ease-in-out infinite; transform-origin:100px 70px;"><polygon points="100,40 118,66 100,72 82,66" transform="rotate(60 100 70)"/></g>
    <g class="sutol-foto-02-blade sutol-foto-02-b3" style="animation:sutol-foto-02-iris 3.6s ease-in-out infinite; transform-origin:100px 70px;"><polygon points="100,40 118,66 100,72 82,66" transform="rotate(120 100 70)"/></g>
    <g class="sutol-foto-02-blade sutol-foto-02-b4" style="animation:sutol-foto-02-iris 3.6s ease-in-out infinite; transform-origin:100px 70px;"><polygon points="100,40 118,66 100,72 82,66" transform="rotate(180 100 70)"/></g>
    <g class="sutol-foto-02-blade sutol-foto-02-b5" style="animation:sutol-foto-02-iris 3.6s ease-in-out infinite; transform-origin:100px 70px;"><polygon points="100,40 118,66 100,72 82,66" transform="rotate(240 100 70)"/></g>
    <g class="sutol-foto-02-blade sutol-foto-02-b6" style="animation:sutol-foto-02-iris 3.6s ease-in-out infinite; transform-origin:100px 70px;"><polygon points="100,40 118,66 100,72 82,66" transform="rotate(300 100 70)"/></g>
  </svg>
</div>
```

---

## Bileşen 3: Pozlama Üçgeni Dengesi

**Etiketler (keyword eşleşmesi için):** pozlama, diyafram, ışık ölçer
**Kategori:** Fotoğrafçılık
**Açıklama:** Bir üçgenin üç köşesindeki noktaların (diyafram, hız, ISO) sırayla parlayıp sönmesi, doğru pozlamanın dengesini simgeler.

```html
<div class="sutol-foto-03-wrap">
  <svg class="sutol-foto-03-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-03-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-03-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-03-tri { fill: none; stroke: #ced4da; stroke-width: 1.5; }
      .sutol-foto-03-node { animation: sutol-foto-03-pulse 3.6s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
      .sutol-foto-03-n1 { fill: #e9c46a; animation-delay: 0s; }
      .sutol-foto-03-n2 { fill: #2a9d8f; animation-delay: 1.2s; }
      .sutol-foto-03-n3 { fill: #e76f51; animation-delay: 2.4s; }
      @keyframes sutol-foto-03-pulse {
        0%, 100% { transform: scale(1); opacity: 0.5; }
        15% { transform: scale(1.5); opacity: 1; }
        30% { transform: scale(1); opacity: 0.5; }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-03-node { animation-duration: 12s; }
      }
    </style>
    <path class="sutol-foto-03-tri" d="M100 30 L150 105 L50 105 Z"/>
    <circle class="sutol-foto-03-node sutol-foto-03-n1" cx="100" cy="30" r="7"/>
    <circle class="sutol-foto-03-node sutol-foto-03-n2" cx="150" cy="105" r="7"/>
    <circle class="sutol-foto-03-node sutol-foto-03-n3" cx="50" cy="105" r="7"/>
  </svg>
</div>
```

---

## Bileşen 4: Karanlık Oda Banyo Teknesi

**Etiketler (keyword eşleşmesi için):** karanlık oda, film negatifi, enstantane
**Kategori:** Fotoğrafçılık
**Açıklama:** Bir banyo teknesindeki fotoğraf kağıdının üzerinde görüntünün yavaşça belirmesi, karanlık oda banyo sürecini canlandırır.

```html
<div class="sutol-foto-04-wrap">
  <svg class="sutol-foto-04-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-04-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-04-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-04-tray { fill: #6b1a22; opacity: 0.35; }
      .sutol-foto-04-liquid { fill: #b23a48; opacity: 0.25; animation: sutol-foto-04-ripple 3s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
      .sutol-foto-04-paper { fill: #f4ede1; stroke: #b0a08a; stroke-width: 1; }
      .sutol-foto-04-image { fill: #2b2b2b; animation: sutol-foto-04-appear 5s ease-in-out infinite; }
      @keyframes sutol-foto-04-ripple { 0%, 100% { transform: scaleX(1); } 50% { transform: scaleX(1.04); } }
      @keyframes sutol-foto-04-appear {
        0%, 15% { opacity: 0; }
        55%, 100% { opacity: 0.85; }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-04-liquid, .sutol-foto-04-image { animation-duration: 14s; }
      }
    </style>
    <ellipse class="sutol-foto-04-tray" cx="100" cy="90" rx="70" ry="24"/>
    <ellipse class="sutol-foto-04-liquid" cx="100" cy="88" rx="62" ry="18"/>
    <rect class="sutol-foto-04-paper" x="65" y="55" width="70" height="45" rx="2"/>
    <g class="sutol-foto-04-image">
      <circle cx="88" cy="72" r="8"/>
      <path d="M75 92 Q88 75 100 88 Q112 78 122 92 Z"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 5: Kayan Film Negatifi Şeridi

**Etiketler (keyword eşleşmesi için):** film negatifi, enstantane
**Kategori:** Fotoğrafçılık
**Açıklama:** Delikli bir film şeridinin kareler halinde sürekli kayması, analog fotoğrafçılığın ritmini simgeler.

```html
<div class="sutol-foto-05-wrap">
  <svg class="sutol-foto-05-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-05-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; overflow: hidden; }
      .sutol-foto-05-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-05-strip { fill: #1d1d1d; }
      .sutol-foto-05-hole { fill: #f4ede1; }
      .sutol-foto-05-frame { fill: #cbd5e1; opacity: 0.7; }
      .sutol-foto-05-track { animation: sutol-foto-05-scroll 4s linear infinite; }
      @keyframes sutol-foto-05-scroll { 0% { transform: translateX(0); } 100% { transform: translateX(-90px); } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-05-track { animation-duration: 16s; }
      }
    </style>
    <clipPath id="sutol-foto-05-clip"><rect x="10" y="35" width="180" height="70"/></clipPath>
    <g clip-path="url(#sutol-foto-05-clip)">
      <g class="sutol-foto-05-track">
        <rect class="sutol-foto-05-strip" x="0" y="35" width="270" height="70"/>
        <rect class="sutol-foto-05-frame" x="18" y="48" width="60" height="44" rx="2"/>
        <rect class="sutol-foto-05-frame" x="108" y="48" width="60" height="44" rx="2"/>
        <rect class="sutol-foto-05-frame" x="198" y="48" width="60" height="44" rx="2"/>
        <circle class="sutol-foto-05-hole" cx="10" cy="42" r="3"/>
        <circle class="sutol-foto-05-hole" cx="10" cy="98" r="3"/>
        <circle class="sutol-foto-05-hole" cx="55" cy="42" r="3"/>
        <circle class="sutol-foto-05-hole" cx="55" cy="98" r="3"/>
        <circle class="sutol-foto-05-hole" cx="100" cy="42" r="3"/>
        <circle class="sutol-foto-05-hole" cx="100" cy="98" r="3"/>
        <circle class="sutol-foto-05-hole" cx="145" cy="42" r="3"/>
        <circle class="sutol-foto-05-hole" cx="145" cy="98" r="3"/>
        <circle class="sutol-foto-05-hole" cx="190" cy="42" r="3"/>
        <circle class="sutol-foto-05-hole" cx="190" cy="98" r="3"/>
        <circle class="sutol-foto-05-hole" cx="235" cy="42" r="3"/>
        <circle class="sutol-foto-05-hole" cx="235" cy="98" r="3"/>
      </g>
    </g>
  </svg>
</div>
```

---

## Bileşen 6: Enstantane Flaş Anı

**Etiketler (keyword eşleşmesi için):** enstantane, flaş
**Kategori:** Fotoğrafçılık
**Açıklama:** Bir fotoğraf makinesinin deklanşörüne basılıp beyaz bir flaş ışığının anlık olarak parlaması, hızlı bir kareyi yakalama anını canlandırır.

```html
<div class="sutol-foto-06-wrap">
  <svg class="sutol-foto-06-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-06-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-06-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-06-body { fill: #2b2b2b; }
      .sutol-foto-06-lens { fill: #4a4a4a; stroke: #1a1a1a; stroke-width: 1.5; }
      .sutol-foto-06-btn { fill: #e63946; animation: sutol-foto-06-press 2.6s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
      .sutol-foto-06-flash { fill: #fffbe8; opacity: 0; animation: sutol-foto-06-burst 2.6s ease-in-out infinite; transform-box: fill-box; transform-origin: 100px 55px; }
      @keyframes sutol-foto-06-press { 0%, 40%, 100% { transform: translateY(0); } 45% { transform: translateY(2px); } }
      @keyframes sutol-foto-06-burst {
        0%, 42% { opacity: 0; transform: scale(0.3); }
        50% { opacity: 1; transform: scale(2.4); }
        62%, 100% { opacity: 0; transform: scale(0.3); }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-06-btn, .sutol-foto-06-flash { animation-duration: 8s; }
      }
    </style>
    <circle class="sutol-foto-06-flash" cx="100" cy="55" r="10"/>
    <rect class="sutol-foto-06-body" x="55" y="60" width="90" height="45" rx="6"/>
    <circle class="sutol-foto-06-lens" cx="100" cy="83" r="20"/>
    <circle fill="#8fd3d9" cx="100" cy="83" r="11"/>
    <rect class="sutol-foto-06-btn" x="122" y="48" width="14" height="10" rx="3"/>
  </svg>
</div>
```

---

## Bileşen 7: Panoramik Tarama Çubuğu

**Etiketler (keyword eşleşmesi için):** panoramik çekim, kompozisyon kuralı
**Kategori:** Fotoğrafçılık
**Açıklama:** Dikey bir tarama çubuğunun geniş bir manzara üzerinde yatay olarak kayması, panoramik çekimin tarama hareketini simgeler.

```html
<div class="sutol-foto-07-wrap">
  <svg class="sutol-foto-07-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-07-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-07-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-07-frame { fill: none; stroke: #adb5bd; stroke-width: 2; }
      .sutol-foto-07-hill { fill: #a8dadc; opacity: 0.5; }
      .sutol-foto-07-hill2 { fill: #457b9d; opacity: 0.35; }
      .sutol-foto-07-scan { fill: #ffffff; opacity: 0.5; animation: sutol-foto-07-sweep 4s ease-in-out infinite; }
      @keyframes sutol-foto-07-sweep {
        0% { transform: translateX(0); }
        50% { transform: translateX(150px); }
        100% { transform: translateX(0); }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-07-scan { animation-duration: 14s; }
      }
    </style>
    <rect class="sutol-foto-07-frame" x="20" y="45" width="160" height="50" rx="3"/>
    <path class="sutol-foto-07-hill" d="M20 90 Q60 60 100 85 Q140 60 180 90 L180 95 L20 95 Z"/>
    <path class="sutol-foto-07-hill2" d="M20 95 Q70 78 120 92 Q150 82 180 95 L180 95 L20 95 Z"/>
    <rect class="sutol-foto-07-scan" x="20" y="45" width="10" height="50"/>
  </svg>
</div>
```

---

## Bileşen 8: Flaş Işık Patlaması

**Etiketler (keyword eşleşmesi için):** flaş, pozlama
**Kategori:** Fotoğrafçılık
**Açıklama:** Bir flaş biriminden yayılan ışın demetlerinin döngüsel olarak parlaması, ani aydınlatma etkisini simgeler.

```html
<div class="sutol-foto-08-wrap">
  <svg class="sutol-foto-08-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-08-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-08-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-08-unit { fill: #2b2b2b; }
      .sutol-foto-08-ray { stroke: #ffe066; stroke-width: 3; stroke-linecap: round; opacity: 0; animation: sutol-foto-08-flash 2.8s ease-in-out infinite; transform-box: fill-box; transform-origin: 100px 65px; }
      @keyframes sutol-foto-08-flash {
        0%, 38% { opacity: 0; transform: scale(0.4); }
        48% { opacity: 1; transform: scale(1); }
        62%, 100% { opacity: 0; transform: scale(1.4); }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-08-ray { animation-duration: 9s; }
      }
    </style>
    <rect class="sutol-foto-08-unit" x="85" y="70" width="30" height="34" rx="4"/>
    <rect class="sutol-foto-08-unit" x="93" y="60" width="14" height="12" rx="2"/>
    <g class="sutol-foto-08-ray">
      <line x1="100" y1="35" x2="100" y2="20"/>
      <line x1="70" y1="45" x2="58" y2="35"/>
      <line x1="130" y1="45" x2="142" y2="35"/>
      <line x1="60" y1="65" x2="45" y2="65"/>
      <line x1="140" y1="65" x2="155" y2="65"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 9: Tripod Sabit Denge

**Etiketler (keyword eşleşmesi için):** tripod, pozlama
**Kategori:** Fotoğrafçılık
**Açıklama:** Üç ayaklı bir tripodun üzerine yerleştirilen bir makinenin, uzun pozlama boyunca sabitliğini vurgulayan hafif bir nefes animasyonuyla durması.

```html
<div class="sutol-foto-09-wrap">
  <svg class="sutol-foto-09-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-09-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-09-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-09-leg { stroke: #6b6b6b; stroke-width: 3; stroke-linecap: round; }
      .sutol-foto-09-head { fill: #3a3a3a; }
      .sutol-foto-09-cam { fill: #2b2b2b; animation: sutol-foto-09-breathe 4s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
      .sutol-foto-09-ring { fill: none; stroke: #06d6a0; stroke-width: 1.5; opacity: 0; animation: sutol-foto-09-ring 4s ease-out infinite; transform-box: fill-box; transform-origin: 100px 55px; }
      @keyframes sutol-foto-09-breathe { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.02); } }
      @keyframes sutol-foto-09-ring { 0%, 50% { transform: scale(0.7); opacity: 0; } 60% { opacity: 0.6; } 100% { transform: scale(1.6); opacity: 0; } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-09-cam, .sutol-foto-09-ring { animation-duration: 14s; }
      }
    </style>
    <line class="sutol-foto-09-leg" x1="100" y1="70" x2="55" y2="120"/>
    <line class="sutol-foto-09-leg" x1="100" y1="70" x2="100" y2="122"/>
    <line class="sutol-foto-09-leg" x1="100" y1="70" x2="145" y2="120"/>
    <circle class="sutol-foto-09-ring" cx="100" cy="55" r="20"/>
    <rect class="sutol-foto-09-head" x="90" y="65" width="20" height="10" rx="2"/>
    <g class="sutol-foto-09-cam">
      <rect x="75" y="42" width="50" height="28" rx="5"/>
      <circle fill="#557" cx="100" cy="56" r="10"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 10: Üçler Kuralı Izgarası

**Etiketler (keyword eşleşmesi için):** kompozisyon kuralı, portre çekimi
**Kategori:** Fotoğrafçılık
**Açıklama:** Ekranı dokuza bölen ızgara çizgileri üzerinde bir odak noktasının kesişim noktalarından birine kayması, doğru kompozisyon kuralını gösterir.

```html
<div class="sutol-foto-10-wrap">
  <svg class="sutol-foto-10-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-10-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-10-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-10-frame { fill: none; stroke: #adb5bd; stroke-width: 2; }
      .sutol-foto-10-grid { stroke: #ced4da; stroke-width: 1; }
      .sutol-foto-10-focus {
        fill: none; stroke: #e63946; stroke-width: 2.5;
        offset-path: path('M100 70 L73 55 L127 55 L127 85 L73 85 Z');
        animation: sutol-foto-10-move 5s ease-in-out infinite;
      }
      @keyframes sutol-foto-10-move {
        0%, 15% { offset-distance: 0%; }
        30%, 45% { offset-distance: 25%; }
        60%, 75% { offset-distance: 75%; }
        90%, 100% { offset-distance: 0%; }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-10-focus { animation-duration: 14s; }
      }
    </style>
    <rect class="sutol-foto-10-frame" x="20" y="20" width="160" height="100" rx="2"/>
    <line class="sutol-foto-10-grid" x1="73" y1="20" x2="73" y2="120"/>
    <line class="sutol-foto-10-grid" x1="127" y1="20" x2="127" y2="120"/>
    <line class="sutol-foto-10-grid" x1="20" y1="53" x2="180" y2="53"/>
    <line class="sutol-foto-10-grid" x1="20" y1="87" x2="180" y2="87"/>
    <g class="sutol-foto-10-focus">
      <circle r="10"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 11: Portre Odak Çerçevesi

**Etiketler (keyword eşleşmesi için):** portre çekimi, objektif
**Kategori:** Fotoğrafçılık
**Açıklama:** Bir yüz siluetinin çevresinde beliren köşeli odak parantezlerinin daralıp kilitlenmesi, portre çekiminde net odaklamayı canlandırır.

```html
<div class="sutol-foto-11-wrap">
  <svg class="sutol-foto-11-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-11-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-11-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-11-face { fill: #3a3a55; }
      .sutol-foto-11-bracket { fill: none; stroke: #ffd166; stroke-width: 3; stroke-linecap: round; transform-box: fill-box; transform-origin: 100px 65px; animation: sutol-foto-11-lock 3.4s ease-in-out infinite; }
      @keyframes sutol-foto-11-lock {
        0%, 15% { transform: scale(1.5); opacity: 0; }
        35% { transform: scale(1); opacity: 1; }
        80%, 100% { transform: scale(1); opacity: 1; }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-11-bracket { animation-duration: 10s; }
      }
    </style>
    <circle class="sutol-foto-11-face" cx="100" cy="55" r="16"/>
    <path class="sutol-foto-11-face" d="M75 105 Q75 68 100 68 Q125 68 125 105 Z"/>
    <g class="sutol-foto-11-bracket">
      <path d="M65 35 L65 25 L75 25"/>
      <path d="M135 35 L135 25 L125 25"/>
      <path d="M65 95 L65 105 L75 105"/>
      <path d="M135 95 L135 105 L125 105"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 12: Makro Büyüteç Detayı

**Etiketler (keyword eşleşmesi için):** makro çekim, objektif
**Kategori:** Fotoğrafçılık
**Açıklama:** Bir büyütecin küçük bir çiy damlasının üzerinde gezinip detayları büyütmesi, makro çekimin yakınlaşma etkisini simgeler.

```html
<div class="sutol-foto-12-wrap">
  <svg class="sutol-foto-12-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-12-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-12-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-12-leaf { fill: #52b788; }
      .sutol-foto-12-drop { fill: #90e0ef; opacity: 0.75; }
      .sutol-foto-12-glass {
        fill: none; stroke: #3a3a3a; stroke-width: 3;
        offset-path: path('M70 60 Q100 40 130 60 Q100 80 70 60');
        animation: sutol-foto-12-hover 5s ease-in-out infinite;
      }
      .sutol-foto-12-handle { stroke: #6b4226; stroke-width: 3; }
      .sutol-foto-12-zoom { fill: #90e0ef; opacity: 0.2; }
      @keyframes sutol-foto-12-hover { 0% { offset-distance: 0%; } 100% { offset-distance: 100%; } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-12-glass { animation-duration: 16s; }
      }
    </style>
    <path class="sutol-foto-12-leaf" d="M40 100 Q60 70 100 80 Q140 70 160 100 Q100 120 40 100 Z"/>
    <circle class="sutol-foto-12-drop" cx="100" cy="85" r="8"/>
    <g class="sutol-foto-12-glass">
      <circle r="16"/>
      <line class="sutol-foto-12-handle" x1="11" y1="11" x2="22" y2="22"/>
      <circle class="sutol-foto-12-zoom" r="14"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 13: Fotoğraf Albümü Sayfaları

**Etiketler (keyword eşleşmesi için):** fotoğraf albümü, enstantane
**Kategori:** Fotoğrafçılık
**Açıklama:** Bir albümün sayfalarının sırayla çevrilip içindeki fotoğraf çerçevelerinin belirmesi, biriken anıları canlandırır.

```html
<div class="sutol-foto-13-wrap">
  <svg class="sutol-foto-13-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-13-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-13-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-13-cover { fill: #8a5a3b; }
      .sutol-foto-13-photo { fill: #f4ede1; stroke: #b0a08a; stroke-width: 1; }
      .sutol-foto-13-pic { fill: #90e0ef; }
      .sutol-foto-13-page {
        transform-box: fill-box; transform-origin: 100px 30px;
        animation: sutol-foto-13-flip 5s ease-in-out infinite;
      }
      @keyframes sutol-foto-13-flip {
        0%, 20% { transform: rotateY(0deg); }
        50%, 70% { transform: rotateY(-170deg); }
        100% { transform: rotateY(-170deg); }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-13-page { animation-duration: 16s; }
      }
    </style>
    <rect class="sutol-foto-13-cover" x="30" y="30" width="140" height="80" rx="3"/>
    <g class="sutol-foto-13-photo">
      <rect x="40" y="40" width="45" height="35" rx="2"/>
      <rect x="115" y="40" width="45" height="35" rx="2"/>
      <circle class="sutol-foto-13-pic" cx="62" cy="57" r="10"/>
      <circle class="sutol-foto-13-pic" cx="137" cy="57" r="10"/>
    </g>
    <g class="sutol-foto-13-page">
      <rect class="sutol-foto-13-photo" x="100" y="38" width="55" height="65" rx="2"/>
      <circle class="sutol-foto-13-pic" cx="127" cy="65" r="14"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 14: Işık Ölçer İbresi

**Etiketler (keyword eşleşmesi için):** ışık ölçer, pozlama
**Kategori:** Fotoğrafçılık
**Açıklama:** Bir ışık ölçüm göstergesinin ibresinin karanlıktan aydınlığa doğru salınması, doğru pozlama değerini bulma sürecini simgeler.

```html
<div class="sutol-foto-14-wrap">
  <svg class="sutol-foto-14-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-14-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-14-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-14-scale { fill: none; stroke: #adb5bd; stroke-width: 2; }
      .sutol-foto-14-tick { stroke: #adb5bd; stroke-width: 1.5; }
      .sutol-foto-14-needle {
        stroke: #e63946; stroke-width: 3; stroke-linecap: round;
        transform-box: fill-box; transform-origin: 100px 100px;
        animation: sutol-foto-14-swing 4s ease-in-out infinite;
      }
      .sutol-foto-14-hub { fill: #e63946; }
      @keyframes sutol-foto-14-swing {
        0%, 100% { transform: rotate(-50deg); }
        50% { transform: rotate(50deg); }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-14-needle { animation-duration: 12s; }
      }
    </style>
    <path class="sutol-foto-14-scale" d="M40 100 A60 60 0 0 1 160 100"/>
    <line class="sutol-foto-14-tick" x1="40" y1="100" x2="46" y2="92"/>
    <line class="sutol-foto-14-tick" x1="100" y1="40" x2="100" y2="48"/>
    <line class="sutol-foto-14-tick" x1="160" y1="100" x2="154" y2="92"/>
    <line class="sutol-foto-14-needle" x1="100" y1="100" x2="100" y2="52"/>
    <circle class="sutol-foto-14-hub" cx="100" cy="100" r="6"/>
  </svg>
</div>
```

---

## Bileşen 15: Perde Mekanizması Açılışı

**Etiketler (keyword eşleşmesi için):** pozlama, objektif
**Kategori:** Fotoğrafçılık
**Açıklama:** İki yatay perdenin merkez çizgiden hızlıca açılıp kapanması, deklanşör mekanizmasının çalışma anını canlandırır.

```html
<div class="sutol-foto-15-wrap">
  <svg class="sutol-foto-15-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-15-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; overflow: hidden; }
      .sutol-foto-15-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-15-frame { fill: none; stroke: #adb5bd; stroke-width: 2; }
      .sutol-foto-15-curtain { fill: #2b2b2b; transform-box: fill-box; }
      .sutol-foto-15-top { transform-origin: top; animation: sutol-foto-15-openTop 3s ease-in-out infinite; }
      .sutol-foto-15-bottom { transform-origin: bottom; animation: sutol-foto-15-openBottom 3s ease-in-out infinite; }
      .sutol-foto-15-light { fill: #fffbe8; opacity: 0; animation: sutol-foto-15-flash 3s ease-in-out infinite; }
      @keyframes sutol-foto-15-openTop {
        0%, 30% { transform: scaleY(1); }
        50%, 65% { transform: scaleY(0.1); }
        100% { transform: scaleY(1); }
      }
      @keyframes sutol-foto-15-openBottom {
        0%, 30% { transform: scaleY(1); }
        50%, 65% { transform: scaleY(0.1); }
        100% { transform: scaleY(1); }
      }
      @keyframes sutol-foto-15-flash { 0%, 45% { opacity: 0; } 55% { opacity: 0.8; } 70%, 100% { opacity: 0; } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-15-top, .sutol-foto-15-bottom, .sutol-foto-15-light { animation-duration: 10s; }
      }
    </style>
    <rect class="sutol-foto-15-frame" x="50" y="30" width="100" height="80" rx="2"/>
    <rect class="sutol-foto-15-light" x="52" y="32" width="96" height="76"/>
    <rect class="sutol-foto-15-curtain sutol-foto-15-top" x="52" y="32" width="96" height="37"/>
    <rect class="sutol-foto-15-curtain sutol-foto-15-bottom" x="52" y="71" width="96" height="37"/>
  </svg>
</div>
```

---

## Bileşen 16: Çift Pozlama Katmanları

**Etiketler (keyword eşleşmesi için):** pozlama, portre çekimi
**Kategori:** Fotoğrafçılık
**Açıklama:** Bir siluetin ve bir manzara şeklinin iç içe geçerek karşılıklı belirip solması, çift pozlama tekniğinin katmanlı görüntüsünü simgeler.

```html
<div class="sutol-foto-16-wrap">
  <svg class="sutol-foto-16-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-16-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-16-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-16-layer { transform-box: fill-box; transform-origin: center; }
      .sutol-foto-16-a { fill: #3a3a55; animation: sutol-foto-16-a 4.4s ease-in-out infinite; }
      .sutol-foto-16-b { fill: #e9c46a; animation: sutol-foto-16-b 4.4s ease-in-out infinite; }
      @keyframes sutol-foto-16-a { 0%, 40% { opacity: 0.85; } 50%, 90% { opacity: 0.25; } 100% { opacity: 0.85; } }
      @keyframes sutol-foto-16-b { 0%, 40% { opacity: 0.25; } 50%, 90% { opacity: 0.85; } 100% { opacity: 0.25; } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-16-a, .sutol-foto-16-b { animation-duration: 13s; }
      }
    </style>
    <g class="sutol-foto-16-layer sutol-foto-16-a">
      <circle cx="100" cy="45" r="14"/>
      <path d="M75 110 Q75 65 100 65 Q125 65 125 110 Z"/>
    </g>
    <g class="sutol-foto-16-layer sutol-foto-16-b">
      <path d="M30 100 Q60 65 90 90 Q120 60 170 100 Z"/>
      <circle cx="150" cy="45" r="10"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 17: Kontakt Film Galerisi

**Etiketler (keyword eşleşmesi için):** film negatifi, fotoğraf albümü
**Kategori:** Fotoğrafçılık
**Açıklama:** Bir kontakt baskı sayfasındaki küçük film karelerinin sırayla parlayıp seçilmesi, en iyi kareyi bulma sürecini simgeler.

```html
<div class="sutol-foto-17-wrap">
  <svg class="sutol-foto-17-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-17-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-17-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-17-sheet { fill: #f4ede1; stroke: #c9c9c9; stroke-width: 1; }
      .sutol-foto-17-cell { fill: #2b2b2b; animation: sutol-foto-17-select 4.8s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
      @keyframes sutol-foto-17-select {
        0%, 100% { opacity: 0.75; transform: scale(1); }
        8% { opacity: 1; transform: scale(1.08); filter: brightness(1.4); }
        16% { opacity: 0.75; transform: scale(1); }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-17-cell { animation-duration: 14s; }
      }
    </style>
    <rect class="sutol-foto-17-sheet" x="25" y="25" width="150" height="90" rx="3"/>
    <rect class="sutol-foto-17-cell" x="35" y="35" width="35" height="24" style="animation-delay:0s"/>
    <rect class="sutol-foto-17-cell" x="82" y="35" width="35" height="24" style="animation-delay:0.6s"/>
    <rect class="sutol-foto-17-cell" x="129" y="35" width="35" height="24" style="animation-delay:1.2s"/>
    <rect class="sutol-foto-17-cell" x="35" y="65" width="35" height="24" style="animation-delay:1.8s"/>
    <rect class="sutol-foto-17-cell" x="82" y="65" width="35" height="24" style="animation-delay:2.4s"/>
    <rect class="sutol-foto-17-cell" x="129" y="65" width="35" height="24" style="animation-delay:3s"/>
  </svg>
</div>
```

---

## Bileşen 18: Uzun Pozlama Işık İzi

**Etiketler (keyword eşleşmesi için):** pozlama, tripod
**Kategori:** Fotoğrafçılık
**Açıklama:** Karanlıkta hareket eden bir ışık noktasının arkasında parlak bir iz bırakması, uzun pozlama tekniğinin karakteristik görüntüsünü simgeler.

```html
<div class="sutol-foto-18-wrap">
  <svg class="sutol-foto-18-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-18-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-18-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-18-trail {
        fill: none; stroke: #ffd166; stroke-width: 3; stroke-linecap: round;
        stroke-dasharray: 200; stroke-dashoffset: 200;
        animation: sutol-foto-18-draw 4s ease-in-out infinite;
      }
      .sutol-foto-18-head {
        fill: #fff3b0;
        offset-path: path('M20 100 Q70 30 100 70 T180 40');
        animation: sutol-foto-18-move 4s ease-in-out infinite;
      }
      @keyframes sutol-foto-18-draw {
        0% { stroke-dashoffset: 200; opacity: 1; }
        70% { stroke-dashoffset: 0; opacity: 1; }
        85%, 100% { opacity: 0.15; stroke-dashoffset: 0; }
      }
      @keyframes sutol-foto-18-move {
        0% { offset-distance: 0%; opacity: 1; }
        70% { offset-distance: 100%; opacity: 1; }
        85%, 100% { opacity: 0; }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-18-trail, .sutol-foto-18-head { animation-duration: 14s; }
      }
    </style>
    <path class="sutol-foto-18-trail" d="M20 100 Q70 30 100 70 T180 40"/>
    <circle class="sutol-foto-18-head" r="5"/>
  </svg>
</div>
```

---

## Bileşen 19: Lens Parlaması Halesi

**Etiketler (keyword eşleşmesi için):** objektif, flaş
**Kategori:** Fotoğrafçılık
**Açıklama:** Bir ışık kaynağından yayılan çember şeklindeki lens parlamalarının çapraz olarak süzülmesi, güçlü bir ışık kaynağının objektife çarpma etkisini simgeler.

```html
<div class="sutol-foto-19-wrap">
  <svg class="sutol-foto-19-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-19-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-19-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-19-src { fill: #fff3b0; animation: sutol-foto-19-core 3.4s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
      .sutol-foto-19-flare { fill: none; stroke-width: 2; opacity: 0.6; animation: sutol-foto-19-drift 3.4s ease-in-out infinite; transform-box: fill-box; }
      .sutol-foto-19-f1 { stroke: #90e0ef; }
      .sutol-foto-19-f2 { stroke: #ffb703; }
      .sutol-foto-19-f3 { stroke: #ef476f; }
      @keyframes sutol-foto-19-core { 0%, 100% { transform: scale(1); opacity: 0.8; } 50% { transform: scale(1.3); opacity: 1; } }
      @keyframes sutol-foto-19-drift { 0%, 100% { transform: translate(0,0) scale(1); } 50% { transform: translate(-10px,4px) scale(1.15); } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-19-src, .sutol-foto-19-flare { animation-duration: 12s; }
      }
    </style>
    <circle class="sutol-foto-19-src" cx="150" cy="35" r="10"/>
    <circle class="sutol-foto-19-flare sutol-foto-19-f1" cx="120" cy="55" r="8"/>
    <circle class="sutol-foto-19-flare sutol-foto-19-f2" cx="95" cy="72" r="12"/>
    <circle class="sutol-foto-19-flare sutol-foto-19-f3" cx="65" cy="92" r="6"/>
    <circle class="sutol-foto-19-flare sutol-foto-19-f2" cx="45" cy="105" r="4"/>
  </svg>
</div>
```

---

## Bileşen 20: Bokeh Arka Planlı Portre

**Etiketler (keyword eşleşmesi için):** portre çekimi, diyafram, makro çekim
**Kategori:** Fotoğrafçılık
**Açıklama:** Bulanık arka plan dairelerinin (bokeh) yumuşakça parlayıp sönmesi ve önde net bir siluetin durması, sığ alan derinliğini simgeler.

```html
<div class="sutol-foto-20-wrap">
  <svg class="sutol-foto-20-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-foto-20-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-foto-20-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-foto-20-bokeh { animation: sutol-foto-20-glow 3.6s ease-in-out infinite; transform-box: fill-box; transform-origin: center; filter: blur(1.5px); }
      .sutol-foto-20-b1 { fill: #ffd166; animation-delay: 0s; }
      .sutol-foto-20-b2 { fill: #ef476f; animation-delay: 0.5s; }
      .sutol-foto-20-b3 { fill: #06d6a0; animation-delay: 1s; }
      .sutol-foto-20-b4 { fill: #90e0ef; animation-delay: 1.5s; }
      .sutol-foto-20-b5 { fill: #ffd166; animation-delay: 2s; }
      .sutol-foto-20-figure { fill: #22223b; }
      @keyframes sutol-foto-20-glow { 0%, 100% { opacity: 0.3; transform: scale(1); } 50% { opacity: 0.8; transform: scale(1.15); } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-foto-20-bokeh { animation-duration: 12s; }
      }
    </style>
    <circle class="sutol-foto-20-bokeh sutol-foto-20-b1" cx="35" cy="35" r="12"/>
    <circle class="sutol-foto-20-bokeh sutol-foto-20-b2" cx="165" cy="45" r="16"/>
    <circle class="sutol-foto-20-bokeh sutol-foto-20-b3" cx="30" cy="95" r="10"/>
    <circle class="sutol-foto-20-bokeh sutol-foto-20-b4" cx="170" cy="100" r="14"/>
    <circle class="sutol-foto-20-bokeh sutol-foto-20-b5" cx="150" cy="20" r="8"/>
    <g class="sutol-foto-20-figure">
      <circle cx="100" cy="55" r="15"/>
      <path d="M75 115 Q75 72 100 72 Q125 72 125 115 Z"/>
    </g>
  </svg>
</div>
```

---

## Kalite Kontrol Özeti

- **Bileşen 1:** İç içe `scale/rotate` odak halkaları.
- **Bileşen 2:** Altı yaprağın senkronize `scale/rotate` iris hareketi.
- **Bileşen 3:** Üç köşe noktasının sıralı `scale/opacity` nabzı.
- **Bileşen 4:** Sıvı `scaleX` dalgalanması + görüntünün kademeli `opacity` belirmesi.
- **Bileşen 5:** `clip-path` içinde sonsuz `translateX` kayan film şeridi.
- **Bileşen 6:** Buton `translateY` basımı + ani `scale/opacity` flaş patlaması.
- **Bileşen 7:** `translateX` yatay tarama çubuğu hareketi.
- **Bileşen 8:** Gecikmeli `scale/opacity` flaş ışını patlaması.
- **Bileşen 9:** Hafif `scale` nefes efekti + genişleyen `scale/opacity` denge halkası.
- **Bileşen 10:** `offset-path` üzerinde kesişim noktalarına atlayan odak dairesi.
- **Bileşen 11:** `scale/opacity` ile kilitlenen köşeli odak parantezleri.
- **Bileşen 12:** `offset-path` boyunca gezinen büyüteç.
- **Bileşen 13:** `rotateY` 3D sayfa çevirme animasyonu.
- **Bileşen 14:** `rotate` gösterge ibresi salınımı.
- **Bileşen 15:** Zıt yönlü `scaleY` perde açılışı + senkronize `opacity` flaş.
- **Bileşen 16:** Çapraz `opacity` geçişli iki katman (çift pozlama).
- **Bileşen 17:** Sıralı `scale/opacity/brightness` seçili kare vurgusu.
- **Bileşen 18:** `stroke-dashoffset` iz çizimi + `offset-path` hareketli ışık başı.
- **Bileşen 19:** `scale` merkez parlaması + `translate/scale` süzülen lens flare halkaları.
- **Bileşen 20:** Gecikmeli `scale/opacity` bulanık bokeh daireleri + net siluet.

**Genel notlar:** Tüm bileşenler `viewBox` tabanlı SVG kullanır, sabit piksel boyutu yoktur; tüm sınıflar `.sutol-foto-NN-` önekiyle kapsüllenmiştir; hiçbir global seçici veya dış kaynak kullanılmamıştır; her bileşende `prefers-reduced-motion` desteği mevcuttur ve tüm animasyonlar döngüseldir (`infinite`).
