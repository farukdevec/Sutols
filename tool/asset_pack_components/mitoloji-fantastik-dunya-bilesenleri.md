# Mitoloji & Fantastik Dünya Kategorisi — 20 Animasyonlu HTML Bileşeni

---

## Bileşen 1: Ejderha Ateş Nefesi

**Etiketler (keyword eşleşmesi için):** ejderha, mitolojik canavar
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Bir ejderha başının ağzından dalgalanan bir alev huzmesinin sürekli olarak fışkırması, efsanevi gücü canlandırır.

```html
<div class="sutol-mito-01-wrap">
  <svg class="sutol-mito-01-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-01-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-01-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-01-head { fill: #3a5a40; }
      .sutol-mito-01-eye { fill: #ffd166; animation: sutol-mito-01-blink 4s ease-in-out infinite; }
      .sutol-mito-01-flame { fill: #f4a261; transform-box: fill-box; transform-origin: left center; animation: sutol-mito-01-breathe 1.4s ease-in-out infinite; }
      .sutol-mito-01-flame2 { fill: #e76f51; transform-box: fill-box; transform-origin: left center; animation: sutol-mito-01-breathe 1.4s ease-in-out infinite 0.2s; }
      @keyframes sutol-mito-01-breathe { 0%, 100% { transform: scaleX(0.7) scaleY(0.9); opacity: 0.7; } 50% { transform: scaleX(1.15) scaleY(1.05); opacity: 1; } }
      @keyframes sutol-mito-01-blink { 0%, 90%, 100% { opacity: 1; } 95% { opacity: 0.2; } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-01-flame, .sutol-mito-01-flame2 { animation-duration: 8s; }
      }
    </style>
    <path class="sutol-mito-01-head" d="M60 55 Q40 55 35 70 Q40 85 60 85 L85 78 L85 62 Z"/>
    <circle class="sutol-mito-01-eye" cx="60" cy="65" r="4"/>
    <path class="sutol-mito-01-flame" d="M85 62 Q120 55 150 65 Q125 70 110 70 Q135 75 155 85 Q120 82 85 78 Z"/>
    <path class="sutol-mito-01-flame2" d="M85 66 Q110 62 130 68 Q112 70 105 70 Q118 74 132 78 Q108 76 85 74 Z"/>
  </svg>
</div>
```

---

## Bileşen 2: Anka Kuşunun Yeniden Doğuşu

**Etiketler (keyword eşleşmesi için):** anka kuşu, efsanevi yaratık
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Alevlerin arasından yükselen bir kuş siluetinin kanat açması, anka kuşunun küllerinden yeniden doğuşunu simgeler.

```html
<div class="sutol-mito-02-wrap">
  <svg class="sutol-mito-02-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-02-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-02-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-02-ember { fill: #e76f51; opacity: 0.6; animation: sutol-mito-02-flicker 1.2s ease-in-out infinite alternate; transform-box: fill-box; transform-origin: bottom center; }
      .sutol-mito-02-bird { fill: #f4a261; animation: sutol-mito-02-rise 4.5s ease-in-out infinite; transform-box: fill-box; transform-origin: bottom center; }
      .sutol-mito-02-wing { fill: #ffd166; transform-box: fill-box; }
      .sutol-mito-02-wl { transform-origin: right center; animation: sutol-mito-02-flapL 1.1s ease-in-out infinite; }
      .sutol-mito-02-wr { transform-origin: left center; animation: sutol-mito-02-flapR 1.1s ease-in-out infinite; }
      @keyframes sutol-mito-02-rise { 0%, 10% { transform: translateY(20px) scale(0.7); opacity: 0.4; } 60%, 100% { transform: translateY(-6px) scale(1); opacity: 1; } }
      @keyframes sutol-mito-02-flicker { from { transform: scaleY(1); } to { transform: scaleY(1.2); } }
      @keyframes sutol-mito-02-flapL { 0%, 100% { transform: rotate(0deg); } 50% { transform: rotate(-22deg); } }
      @keyframes sutol-mito-02-flapR { 0%, 100% { transform: rotate(0deg); } 50% { transform: rotate(22deg); } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-02-bird, .sutol-mito-02-wl, .sutol-mito-02-wr, .sutol-mito-02-ember { animation-duration: 14s; }
      }
    </style>
    <path class="sutol-mito-02-ember" d="M70 118 Q80 95 90 118 Z"/>
    <path class="sutol-mito-02-ember" d="M100 120 Q112 90 124 120 Z"/>
    <path class="sutol-mito-02-ember" d="M130 118 Q140 100 150 118 Z"/>
    <g class="sutol-mito-02-bird">
      <path class="sutol-mito-02-wing sutol-mito-02-wl" d="M100 75 L60 55 L75 78 L58 85 L100 90 Z"/>
      <path class="sutol-mito-02-wing sutol-mito-02-wr" d="M100 75 L140 55 L125 78 L142 85 L100 90 Z"/>
      <path d="M92 60 Q100 45 108 60 Q104 78 100 90 Q96 78 92 60 Z"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 3: Çözülen Labirent Yolu

**Etiketler (keyword eşleşmesi için):** labirent, kahraman yolculuğu
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Bir labirentin duvarları arasında ışıklı bir çizginin sürekli olarak çıkışa doğru çizilmesi, kahramanın yolunu bulma sürecini canlandırır.

```html
<div class="sutol-mito-03-wrap">
  <svg class="sutol-mito-03-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-03-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-03-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-03-wall { fill: none; stroke: #6b6b6b; stroke-width: 2; }
      .sutol-mito-03-path {
        fill: none; stroke: #ffd166; stroke-width: 3; stroke-linecap: round;
        stroke-dasharray: 260; stroke-dashoffset: 260;
        animation: sutol-mito-03-solve 5s ease-in-out infinite;
      }
      @keyframes sutol-mito-03-solve {
        0%, 8% { stroke-dashoffset: 260; opacity: 1; }
        70% { stroke-dashoffset: 0; opacity: 1; }
        90%, 100% { stroke-dashoffset: 0; opacity: 0.15; }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-03-path { animation-duration: 16s; }
      }
    </style>
    <path class="sutol-mito-03-wall" d="M20 20 h160 v100 h-160 Z M40 20 v40 h40 v-20 h40 v60 h-60 M100 40 v40 h60 v-40 M120 100 h40 v-20"/>
    <path class="sutol-mito-03-path" d="M30 30 L30 90 L70 90 L70 50 L110 50 L110 110 L150 110 L150 60 L170 60"/>
  </svg>
</div>
```

---

## Bileşen 4: Kahraman Yolculuğu Haritası

**Etiketler (keyword eşleşmesi için):** kahraman yolculuğu, kehanet
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Kesikli bir harita yolu üzerindeki duraklardan geçen bir işaretin sürekli ilerlemesi, kahramanın destansı yolculuğunu simgeler.

```html
<div class="sutol-mito-04-wrap">
  <svg class="sutol-mito-04-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-04-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-04-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-04-route { fill: none; stroke: #b08968; stroke-width: 2; stroke-dasharray: 6 5; }
      .sutol-mito-04-node { fill: #7f5539; }
      .sutol-mito-04-marker {
        fill: #e63946;
        offset-path: path('M20 100 Q50 60 90 80 Q130 100 170 40');
        animation: sutol-mito-04-travel 5s ease-in-out infinite;
      }
      @keyframes sutol-mito-04-travel {
        0% { offset-distance: 0%; opacity: 0; }
        6% { opacity: 1; }
        94% { offset-distance: 100%; opacity: 1; }
        100% { offset-distance: 100%; opacity: 0; }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-04-marker { animation-duration: 15s; }
      }
    </style>
    <path class="sutol-mito-04-route" d="M20 100 Q50 60 90 80 Q130 100 170 40"/>
    <circle class="sutol-mito-04-node" cx="20" cy="100" r="5"/>
    <circle class="sutol-mito-04-node" cx="90" cy="80" r="5"/>
    <circle class="sutol-mito-04-node" cx="170" cy="40" r="5"/>
    <g class="sutol-mito-04-marker">
      <path d="M0 -8 Q6 -2 0 8 Q-6 -2 0 -8 Z"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 5: Tanrı Heykelinin Kutsal Işığı

**Etiketler (keyword eşleşmesi için):** tanrı heykeli, kadim tapınak
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Bir tanrı heykelinin üzerine tepeden süzülen ilahi bir ışık huzmesinin nabız gibi parlaması, kutsal bir varlığın gücünü simgeler.

```html
<div class="sutol-mito-05-wrap">
  <svg class="sutol-mito-05-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-05-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-05-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-05-statue { fill: #cbd5e1; stroke: #94a3b8; stroke-width: 1.5; }
      .sutol-mito-05-beam { fill: #fff3b0; opacity: 0.35; animation: sutol-mito-05-pulse 3.6s ease-in-out infinite; transform-box: fill-box; transform-origin: top center; }
      @keyframes sutol-mito-05-pulse { 0%, 100% { opacity: 0.2; transform: scaleX(1); } 50% { opacity: 0.55; transform: scaleX(1.2); } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-05-beam { animation-duration: 12s; }
      }
    </style>
    <path class="sutol-mito-05-beam" d="M85 15 L115 15 L140 115 L60 115 Z"/>
    <rect class="sutol-mito-05-statue" x="80" y="95" width="40" height="18" rx="2"/>
    <path class="sutol-mito-05-statue" d="M88 95 L88 60 Q100 50 112 60 L112 95 Z"/>
    <circle class="sutol-mito-05-statue" cx="100" cy="45" r="12"/>
  </svg>
</div>
```

---

## Bileşen 6: Büyülü Ormanın Parıldayan Ağacı

**Etiketler (keyword eşleşmesi için):** büyülü orman, gizemli sembol
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Bir ağacın gövdesinden yükselen büyülü parıltı taneciklerinin süzülerek yükselmesi, ormanın gizemli enerjisini simgeler.

```html
<div class="sutol-mito-06-wrap">
  <svg class="sutol-mito-06-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-06-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-06-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-06-trunk { fill: #4a3728; }
      .sutol-mito-06-crown { fill: #2d6a4f; }
      .sutol-mito-06-spark {
        fill: #b9fbc0; animation: sutol-mito-06-rise 3.6s ease-in infinite;
      }
      @keyframes sutol-mito-06-rise {
        0% { transform: translate(0,0) scale(0.4); opacity: 0; }
        20% { opacity: 1; }
        100% { transform: translate(var(--dx), -60px) scale(1); opacity: 0; }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-06-spark { animation-duration: 12s; }
      }
    </style>
    <rect class="sutol-mito-06-trunk" x="94" y="80" width="12" height="35" rx="3"/>
    <ellipse class="sutol-mito-06-crown" cx="100" cy="60" rx="38" ry="30"/>
    <circle class="sutol-mito-06-spark" cx="90" cy="65" r="3" style="--dx:-14px; animation-delay:0s"/>
    <circle class="sutol-mito-06-spark" cx="110" cy="60" r="2.5" style="--dx:10px; animation-delay:0.8s"/>
    <circle class="sutol-mito-06-spark" cx="100" cy="75" r="3" style="--dx:6px; animation-delay:1.6s"/>
    <circle class="sutol-mito-06-spark" cx="120" cy="70" r="2" style="--dx:16px; animation-delay:2.4s"/>
    <circle class="sutol-mito-06-spark" cx="80" cy="72" r="2" style="--dx:-20px; animation-delay:3.2s"/>
  </svg>
</div>
```

---

## Bileşen 7: Kristal Küredeki Kehanet

**Etiketler (keyword eşleşmesi için):** kristal küre, kehanet
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Bir kristal kürenin içinde dönen sisli bir görüntünün belirip kaybolması, geleceği görme kehanetini simgeler.

```html
<div class="sutol-mito-07-wrap">
  <svg class="sutol-mito-07-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-07-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-07-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-07-orb { fill: #cdb4db; opacity: 0.25; stroke: #9d4edd; stroke-width: 1.5; }
      .sutol-mito-07-stand { fill: #6b6b6b; }
      .sutol-mito-07-swirl { fill: none; stroke: #e0aaff; stroke-width: 2; opacity: 0.7; transform-box: fill-box; transform-origin: 100px 60px; animation: sutol-mito-07-spin 4s linear infinite; }
      .sutol-mito-07-vision { fill: #f3d9fa; animation: sutol-mito-07-show 4.4s ease-in-out infinite; }
      @keyframes sutol-mito-07-spin { to { transform: rotate(360deg); } }
      @keyframes sutol-mito-07-show { 0%, 20% { opacity: 0; } 50%, 70% { opacity: 0.8; } 100% { opacity: 0; } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-07-swirl { animation-duration: 12s; }
        .sutol-mito-07-vision { animation-duration: 14s; }
      }
    </style>
    <path class="sutol-mito-07-stand" d="M78 108 Q100 118 122 108 L118 112 Q100 120 82 112 Z"/>
    <circle class="sutol-mito-07-orb" cx="100" cy="60" r="36"/>
    <g class="sutol-mito-07-swirl">
      <path d="M70 55 Q100 40 130 55"/>
      <path d="M75 70 Q100 85 125 70"/>
    </g>
    <path class="sutol-mito-07-vision" d="M90 50 Q100 40 110 50 Q100 65 90 50 Z"/>
  </svg>
</div>
```

---

## Bileşen 8: Efsanevi Yaratık Silueti

**Etiketler (keyword eşleşmesi için):** efsanevi yaratık, mitolojik canavar
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Tek boynuzlu bir yaratığın silüetinin ormanda hafifçe salınarak nefes alması, efsanevi bir varlığın huzurlu gücünü canlandırır.

```html
<div class="sutol-mito-08-wrap">
  <svg class="sutol-mito-08-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-08-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-08-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-08-body { fill: #22223b; animation: sutol-mito-08-breathe 4s ease-in-out infinite; transform-box: fill-box; transform-origin: bottom center; }
      .sutol-mito-08-horn { fill: #e0aaff; opacity: 0.8; animation: sutol-mito-08-glow 4s ease-in-out infinite; transform-box: fill-box; transform-origin: bottom center; }
      @keyframes sutol-mito-08-breathe { 0%, 100% { transform: scaleY(1); } 50% { transform: scaleY(1.03); } }
      @keyframes sutol-mito-08-glow { 0%, 100% { opacity: 0.5; } 50% { opacity: 1; } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-08-body, .sutol-mito-08-horn { animation-duration: 12s; }
      }
    </style>
    <path class="sutol-mito-08-body" d="M50 100 Q40 80 60 70 L75 55 Q85 50 90 58 L100 68 Q130 65 150 85 Q145 100 120 100 L120 110 L110 110 L108 100 L70 100 L68 110 L58 110 L58 100 Z"/>
    <path class="sutol-mito-08-horn" d="M78 55 L82 30 L86 55 Z"/>
  </svg>
</div>
```

---

## Bileşen 9: Kadim Tapınağın Sütunlu Girişi

**Etiketler (keyword eşleşmesi için):** kadim tapınak, gizemli sembol
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Tapınak sütunlarının arasında yükselen toz zerreciklerinin süzülmesi ve sembolün hafifçe parlaması, kutsal ve kadim bir mekânın atmosferini simgeler.

```html
<div class="sutol-mito-09-wrap">
  <svg class="sutol-mito-09-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-09-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-09-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-09-col { fill: #d4c9b3; stroke: #a89574; stroke-width: 1; }
      .sutol-mito-09-roof { fill: #b8a888; }
      .sutol-mito-09-symbol { fill: none; stroke: #e9c46a; stroke-width: 2; animation: sutol-mito-09-glow 3.6s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
      @keyframes sutol-mito-09-glow { 0%, 100% { opacity: 0.4; } 50% { opacity: 1; filter: drop-shadow(0 0 3px #e9c46a); } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-09-symbol { animation-duration: 12s; }
      }
    </style>
    <path class="sutol-mito-09-roof" d="M35 45 L100 20 L165 45 Z"/>
    <rect class="sutol-mito-09-col" x="35" y="45" width="10" height="65"/>
    <rect class="sutol-mito-09-col" x="65" y="45" width="10" height="65"/>
    <rect class="sutol-mito-09-col" x="95" y="45" width="10" height="65"/>
    <rect class="sutol-mito-09-col" x="125" y="45" width="10" height="65"/>
    <rect class="sutol-mito-09-col" x="155" y="45" width="10" height="65"/>
    <circle class="sutol-mito-09-symbol" cx="100" cy="72" r="12"/>
    <path class="sutol-mito-09-symbol" d="M100 62 L100 82 M90 72 L110 72"/>
  </svg>
</div>
```

---

## Bileşen 10: Sihirli Değneğin Yıldız Tozu

**Etiketler (keyword eşleşmesi için):** sihirli değnek, gizemli sembol
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Bir değneğin ucundan saçılan ışıltılı yıldız tozunun yay çizerek dağılması, büyülü bir dokunuşun etkisini simgeler.

```html
<div class="sutol-mito-10-wrap">
  <svg class="sutol-mito-10-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-10-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-10-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-10-wand { stroke: #6b4226; stroke-width: 4; stroke-linecap: round; transform-box: fill-box; transform-origin: 45px 100px; animation: sutol-mito-10-wave 3.4s ease-in-out infinite; }
      .sutol-mito-10-tip { fill: #ffd166; transform-box: fill-box; transform-origin: 45px 100px; animation: sutol-mito-10-wave 3.4s ease-in-out infinite; }
      .sutol-mito-10-dust {
        fill: #fff3b0;
        offset-path: path('M120 45 Q150 60 175 90');
        animation: sutol-mito-10-scatter 3.4s ease-out infinite;
      }
      @keyframes sutol-mito-10-wave { 0%, 100% { transform: rotate(-15deg); } 50% { transform: rotate(15deg); } }
      @keyframes sutol-mito-10-scatter {
        0%, 40% { offset-distance: 0%; opacity: 0; }
        50% { opacity: 1; }
        100% { offset-distance: 100%; opacity: 0; }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-10-wand, .sutol-mito-10-tip, .sutol-mito-10-dust { animation-duration: 12s; }
      }
    </style>
    <line class="sutol-mito-10-wand" x1="45" y1="100" x2="115" y2="48"/>
    <circle class="sutol-mito-10-tip" cx="118" cy="46" r="5"/>
    <circle class="sutol-mito-10-dust" r="3" style="animation-delay:0s"/>
    <circle class="sutol-mito-10-dust" r="2.5" style="animation-delay:0.4s"/>
    <circle class="sutol-mito-10-dust" r="2" style="animation-delay:0.8s"/>
  </svg>
</div>
```

---

## Bileşen 11: Kehanet Yıldız Haritası

**Etiketler (keyword eşleşmesi için):** kehanet, gizemli sembol
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Gökyüzündeki yıldız noktalarının sırayla ışık çizgileriyle birbirine bağlanması, geleceği okuyan bir kehanet haritasını simgeler.

```html
<div class="sutol-mito-11-wrap">
  <svg class="sutol-mito-11-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-11-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-11-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-11-star { fill: #fff3b0; animation: sutol-mito-11-twinkle 3s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
      .sutol-mito-11-line {
        fill: none; stroke: #9d4edd; stroke-width: 1.5;
        stroke-dasharray: 200; stroke-dashoffset: 200;
        animation: sutol-mito-11-connect 5s ease-in-out infinite;
      }
      @keyframes sutol-mito-11-twinkle { 0%, 100% { opacity: 0.5; } 50% { opacity: 1; } }
      @keyframes sutol-mito-11-connect { 0%, 15% { stroke-dashoffset: 200; } 75%, 100% { stroke-dashoffset: 0; } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-11-line { animation-duration: 14s; }
      }
    </style>
    <path class="sutol-mito-11-line" d="M40 100 L70 60 L110 75 L150 35 L170 55"/>
    <circle class="sutol-mito-11-star" cx="40" cy="100" r="4" style="animation-delay:0s"/>
    <circle class="sutol-mito-11-star" cx="70" cy="60" r="4" style="animation-delay:0.4s"/>
    <circle class="sutol-mito-11-star" cx="110" cy="75" r="4" style="animation-delay:0.8s"/>
    <circle class="sutol-mito-11-star" cx="150" cy="35" r="4" style="animation-delay:1.2s"/>
    <circle class="sutol-mito-11-star" cx="170" cy="55" r="4" style="animation-delay:1.6s"/>
  </svg>
</div>
```

---

## Bileşen 12: Mitolojik Canavarın Gözü

**Etiketler (keyword eşleşmesi için):** mitolojik canavar, efsanevi yaratık
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Karanlıkta gizli bir canavarın kocaman gözünün yavaşça açılıp kapanması, tehdit edici ama büyülü bir varlığın varlığını hissettirir.

```html
<div class="sutol-mito-12-wrap">
  <svg class="sutol-mito-12-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-12-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-12-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-12-lid { fill: #1b1b2f; }
      .sutol-mito-12-eye {
        fill: #ef476f;
        transform-box: fill-box; transform-origin: 100px 70px;
        animation: sutol-mito-12-open 4.4s ease-in-out infinite;
      }
      .sutol-mito-12-pupil { fill: #1b1b2f; }
      @keyframes sutol-mito-12-open {
        0%, 20% { transform: scaleY(0.05); }
        45%, 75% { transform: scaleY(1); }
        95%, 100% { transform: scaleY(0.05); }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-12-eye { animation-duration: 13s; }
      }
    </style>
    <ellipse class="sutol-mito-12-eye" cx="100" cy="70" rx="38" ry="22"/>
    <ellipse class="sutol-mito-12-pupil" cx="100" cy="70" rx="8" ry="16"/>
  </svg>
</div>
```

---

## Bileşen 13: Gizemli Rün Sembolü

**Etiketler (keyword eşleşmesi için):** gizemli sembol, sihirli değnek
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Taş üzerine kazınmış eski bir rün sembolünün sürekli çizilerek parlaması, gizli bir gücün kilidini açan işareti simgeler.

```html
<div class="sutol-mito-13-wrap">
  <svg class="sutol-mito-13-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-13-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-13-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-13-stone { fill: #4a4e69; opacity: 0.4; }
      .sutol-mito-13-rune {
        fill: none; stroke: #9d4edd; stroke-width: 3; stroke-linecap: round;
        stroke-dasharray: 140; stroke-dashoffset: 140;
        animation: sutol-mito-13-draw 4.5s ease-in-out infinite;
      }
      @keyframes sutol-mito-13-draw {
        0%, 10% { stroke-dashoffset: 140; opacity: 1; }
        55% { stroke-dashoffset: 0; opacity: 1; }
        80%, 100% { stroke-dashoffset: 0; opacity: 0.3; }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-13-rune { animation-duration: 14s; }
      }
    </style>
    <circle class="sutol-mito-13-stone" cx="100" cy="70" r="42"/>
    <path class="sutol-mito-13-rune" d="M100 35 L100 105 M75 50 L100 70 L125 50 M75 90 L100 70 L125 90"/>
  </svg>
</div>
```

---

## Bileşen 14: Ejderha Kanadının Ay Işığındaki Gölgesi

**Etiketler (keyword eşleşmesi için):** ejderha, gizemli sembol
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Dolunayın önünden geçen bir ejderha silüetinin kanat çırparak süzülmesi, gece gökyüzündeki efsanevi bir uçuşu simgeler.

```html
<div class="sutol-mito-14-wrap">
  <svg class="sutol-mito-14-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-14-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-14-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-14-moon { fill: #fff3b0; opacity: 0.85; }
      .sutol-mito-14-silh {
        fill: #14213d;
        offset-path: path('M-20 60 Q60 90 100 60 Q140 30 220 55');
        animation: sutol-mito-14-fly 5s linear infinite;
      }
      .sutol-mito-14-wing { animation: sutol-mito-14-flap 0.5s ease-in-out infinite alternate; transform-box: fill-box; transform-origin: center; }
      @keyframes sutol-mito-14-fly { 0% { offset-distance: 0%; } 100% { offset-distance: 100%; } }
      @keyframes sutol-mito-14-flap { from { transform: scaleY(1); } to { transform: scaleY(0.6); } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-14-silh { animation-duration: 16s; }
        .sutol-mito-14-wing { animation-duration: 3s; }
      }
    </style>
    <circle class="sutol-mito-14-moon" cx="150" cy="35" r="24"/>
    <g class="sutol-mito-14-silh">
      <path class="sutol-mito-14-wing" d="M0 0 L-18 -10 L-6 0 L-18 8 Z"/>
      <path d="M0 0 Q10 -4 20 0 Q10 4 0 0 Z" transform="translate(10,2)"/>
      <path class="sutol-mito-14-wing" d="M20 0 L38 -10 L26 0 L38 8 Z"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 15: Anka Kuşunun Alevden Kanatları

**Etiketler (keyword eşleşmesi için):** anka kuşu, efsanevi yaratık
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Alevden örülü kanatların bir merkez etrafında açılıp kapanması, anka kuşunun ateşten doğan gücünü simgeler.

```html
<div class="sutol-mito-15-wrap">
  <svg class="sutol-mito-15-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-15-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-15-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-15-core { fill: #ffd166; animation: sutol-mito-15-glow 2.6s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
      .sutol-mito-15-wing { fill: #e76f51; transform-box: fill-box; }
      .sutol-mito-15-wl { transform-origin: right center; animation: sutol-mito-15-open 2.6s ease-in-out infinite; }
      .sutol-mito-15-wr { transform-origin: left center; animation: sutol-mito-15-open-r 2.6s ease-in-out infinite; }
      @keyframes sutol-mito-15-glow { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.2); } }
      @keyframes sutol-mito-15-open { 0%, 100% { transform: rotate(0deg); } 50% { transform: rotate(-25deg); } }
      @keyframes sutol-mito-15-open-r { 0%, 100% { transform: rotate(0deg); } 50% { transform: rotate(25deg); } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-15-core, .sutol-mito-15-wl, .sutol-mito-15-wr { animation-duration: 10s; }
      }
    </style>
    <g class="sutol-mito-15-wing sutol-mito-15-wl" transform="translate(100,70)">
      <path d="M0 0 L-50 -20 L-35 0 L-50 20 Z"/>
    </g>
    <g class="sutol-mito-15-wing sutol-mito-15-wr" transform="translate(100,70)">
      <path d="M0 0 L50 -20 L35 0 L50 20 Z"/>
    </g>
    <circle class="sutol-mito-15-core" cx="100" cy="70" r="14"/>
  </svg>
</div>
```

---

## Bileşen 16: Labirentin Kuşbakışı Duvarları

**Etiketler (keyword eşleşmesi için):** labirent, kadim tapınak
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Yukarıdan görünen labirent duvarlarının merkeze doğru sırayla parlaması, gizemli yapının katmanlarını ortaya çıkarır.

```html
<div class="sutol-mito-16-wrap">
  <svg class="sutol-mito-16-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-16-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-16-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-16-ring { fill: none; stroke: #6b6b6b; stroke-width: 3; animation: sutol-mito-16-pulse 4s ease-in-out infinite; transform-box: fill-box; transform-origin: 100px 70px; }
      .sutol-mito-16-r1 { animation-delay: 0s; }
      .sutol-mito-16-r2 { animation-delay: 0.4s; }
      .sutol-mito-16-r3 { animation-delay: 0.8s; }
      @keyframes sutol-mito-16-pulse { 0%, 100% { opacity: 0.4; } 30% { opacity: 1; } 60% { opacity: 0.4; } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-16-ring { animation-duration: 12s; }
      }
    </style>
    <circle class="sutol-mito-16-ring sutol-mito-16-r1" cx="100" cy="70" r="45" stroke-dasharray="16 6"/>
    <circle class="sutol-mito-16-ring sutol-mito-16-r2" cx="100" cy="70" r="30" stroke-dasharray="12 5"/>
    <circle class="sutol-mito-16-ring sutol-mito-16-r3" cx="100" cy="70" r="15" stroke-dasharray="8 4"/>
  </svg>
</div>
```

---

## Bileşen 17: Ormanın Uçuşan Peri Işıkları

**Etiketler (keyword eşleşmesi için):** büyülü orman, efsanevi yaratık
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Küçük ışık noktalarının orman zemininde rastgele dairesel yollarda süzülmesi, gizemli peri varlıklarının hareketini simgeler.

```html
<div class="sutol-mito-17-wrap">
  <svg class="sutol-mito-17-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-17-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-17-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-17-tree { fill: #1b4332; opacity: 0.5; }
      .sutol-mito-17-fairy {
        fill: #b9fbc0; animation: sutol-mito-17-drift 3.2s ease-in-out infinite;
      }
      .sutol-mito-17-f1 { offset-path: path('M40 90 Q60 50 90 80 Q110 40 140 70'); animation-delay: 0s; }
      .sutol-mito-17-f2 { offset-path: path('M150 95 Q120 60 100 90 Q80 50 50 75'); animation-delay: 0.6s; }
      .sutol-mito-17-f3 { offset-path: path('M70 100 Q100 70 130 100 Q150 60 170 85'); animation-delay: 1.2s; }
      @keyframes sutol-mito-17-drift {
        0% { offset-distance: 0%; opacity: 0; }
        20% { opacity: 1; }
        80% { opacity: 1; }
        100% { offset-distance: 100%; opacity: 0; }
      }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-17-fairy { animation-duration: 12s; }
      }
    </style>
    <ellipse class="sutol-mito-17-tree" cx="45" cy="60" rx="25" ry="35"/>
    <ellipse class="sutol-mito-17-tree" cx="155" cy="55" rx="28" ry="38"/>
    <circle class="sutol-mito-17-fairy sutol-mito-17-f1" r="3"/>
    <circle class="sutol-mito-17-fairy sutol-mito-17-f2" r="2.5"/>
    <circle class="sutol-mito-17-fairy sutol-mito-17-f3" r="3"/>
  </svg>
</div>
```

---

## Bileşen 18: Kristal Kürenin Enerji Halkaları

**Etiketler (keyword eşleşmesi için):** kristal küre, gizemli sembol
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Bir kürenin çevresinde art arda genişleyen enerji halkalarının yayılması, gizemli bir güç kaynağının nabzını simgeler.

```html
<div class="sutol-mito-18-wrap">
  <svg class="sutol-mito-18-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-18-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-18-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-18-core { fill: #e0aaff; animation: sutol-mito-18-pulse 3s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
      .sutol-mito-18-ring { fill: none; stroke: #9d4edd; stroke-width: 2; opacity: 0; animation: sutol-mito-18-expand 3s ease-out infinite; transform-box: fill-box; transform-origin: 100px 70px; }
      @keyframes sutol-mito-18-pulse { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.15); } }
      @keyframes sutol-mito-18-expand { 0% { transform: scale(0.4); opacity: 0.8; } 100% { transform: scale(2); opacity: 0; } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-18-core, .sutol-mito-18-ring { animation-duration: 10s; }
      }
    </style>
    <circle class="sutol-mito-18-ring" cx="100" cy="70" r="20" style="animation-delay:0s"/>
    <circle class="sutol-mito-18-ring" cx="100" cy="70" r="20" style="animation-delay:1s"/>
    <circle class="sutol-mito-18-ring" cx="100" cy="70" r="20" style="animation-delay:2s"/>
    <circle class="sutol-mito-18-core" cx="100" cy="70" r="16"/>
  </svg>
</div>
```

---

## Bileşen 19: Kadim Tapınağın Gizli Kapısı

**Etiketler (keyword eşleşmesi için):** kadim tapınak, sihirli değnek
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** Taş bir kapının ortadan ikiye ayrılarak açılması ve arkasından ışığın taşması, gizli bir tapınağın kapısının aralanma anını simgeler.

```html
<div class="sutol-mito-19-wrap">
  <svg class="sutol-mito-19-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-19-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; overflow: hidden; }
      .sutol-mito-19-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-19-frame { fill: #4a3728; }
      .sutol-mito-19-glow { fill: #fff3b0; opacity: 0; animation: sutol-mito-19-shine 5s ease-in-out infinite; }
      .sutol-mito-19-door { fill: #6b6b6b; transform-box: fill-box; }
      .sutol-mito-19-left { transform-origin: left center; animation: sutol-mito-19-openL 5s ease-in-out infinite; }
      .sutol-mito-19-right { transform-origin: right center; animation: sutol-mito-19-openR 5s ease-in-out infinite; }
      @keyframes sutol-mito-19-openL { 0%, 20% { transform: scaleX(1); } 55%, 85% { transform: scaleX(0.15); } 100% { transform: scaleX(1); } }
      @keyframes sutol-mito-19-openR { 0%, 20% { transform: scaleX(1); } 55%, 85% { transform: scaleX(0.15); } 100% { transform: scaleX(1); } }
      @keyframes sutol-mito-19-shine { 0%, 20% { opacity: 0; } 55%, 85% { opacity: 0.7; } 100% { opacity: 0; } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-19-left, .sutol-mito-19-right, .sutol-mito-19-glow { animation-duration: 16s; }
      }
    </style>
    <rect class="sutol-mito-19-frame" x="55" y="25" width="90" height="90" rx="4"/>
    <rect class="sutol-mito-19-glow" x="60" y="30" width="80" height="80"/>
    <rect class="sutol-mito-19-door sutol-mito-19-left" x="60" y="30" width="40" height="80"/>
    <rect class="sutol-mito-19-door sutol-mito-19-right" x="100" y="30" width="40" height="80"/>
  </svg>
</div>
```

---

## Bileşen 20: Dönen Gizemli Portal Geçidi

**Etiketler (keyword eşleşmesi için):** gizemli sembol, kehanet
**Kategori:** Mitoloji & Fantastik Dünya
**Açıklama:** İç içe dönen halkalardan oluşan bir portalın merkezinin parlayıp sönmesi, bilinmeyen bir diyara açılan büyülü bir geçidi simgeler.

```html
<div class="sutol-mito-20-wrap">
  <svg class="sutol-mito-20-svg" viewBox="0 0 200 140" xmlns="http://www.w3.org/2000/svg">
    <style>
      .sutol-mito-20-wrap { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: transparent; }
      .sutol-mito-20-svg { width: 100%; height: 100%; overflow: visible; }
      .sutol-mito-20-ring { fill: none; stroke-width: 3; transform-box: fill-box; transform-origin: 100px 70px; }
      .sutol-mito-20-r1 { stroke: #9d4edd; stroke-dasharray: 14 6; animation: sutol-mito-20-spin 4s linear infinite; }
      .sutol-mito-20-r2 { stroke: #5a189a; stroke-dasharray: 10 5; animation: sutol-mito-20-spin-rev 3s linear infinite; }
      .sutol-mito-20-core { fill: #e0aaff; animation: sutol-mito-20-pulse 2.4s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
      @keyframes sutol-mito-20-spin { to { transform: rotate(360deg); } }
      @keyframes sutol-mito-20-spin-rev { to { transform: rotate(-360deg); } }
      @keyframes sutol-mito-20-pulse { 0%, 100% { opacity: 0.5; transform: scale(1); } 50% { opacity: 1; transform: scale(1.2); } }
      @media (prefers-reduced-motion: reduce) {
        .sutol-mito-20-r1, .sutol-mito-20-r2 { animation-duration: 18s; }
        .sutol-mito-20-core { animation-duration: 10s; }
      }
    </style>
    <circle class="sutol-mito-20-ring sutol-mito-20-r1" cx="100" cy="70" r="36"/>
    <circle class="sutol-mito-20-ring sutol-mito-20-r2" cx="100" cy="70" r="24"/>
    <circle class="sutol-mito-20-core" cx="100" cy="70" r="10"/>
  </svg>
</div>
```

---

## Kalite Kontrol Özeti

- **Bileşen 1:** Gecikmeli `scaleX/scaleY` alev titreşimi + göz kırpma `opacity`.
- **Bileşen 2:** `translateY/scale` yükseliş + zıt yönlü kanat `rotate` çırpışı.
- **Bileşen 3:** `stroke-dashoffset` labirent çözüm çizimi.
- **Bileşen 4:** `offset-path` boyunca ilerleyen yolculuk işareti.
- **Bileşen 5:** `scaleX/opacity` nabız atan ilahi ışık huzmesi.
- **Bileşen 6:** Kademeli gecikmeli `translate/scale/opacity` yükselen parıltılar.
- **Bileşen 7:** `rotate` dönen sis girdabı + `opacity` beliren görüntü.
- **Bileşen 8:** Hafif `scaleY` nefes + `opacity` parlayan boynuz.
- **Bileşen 9:** `opacity/drop-shadow` nabız atan sembol.
- **Bileşen 10:** `rotate` değnek sallanışı + `offset-path` saçılan toz.
- **Bileşen 11:** `stroke-dashoffset` yıldızları birleştiren çizgi + `opacity` titreşen yıldızlar.
- **Bileşen 12:** `scaleY` açılıp kapanan göz kapağı.
- **Bileşen 13:** `stroke-dashoffset` rün çizimi + sönme `opacity`.
- **Bileşen 14:** `offset-path` uçuş rotası + hızlı `scaleY` kanat çırpışı.
- **Bileşen 15:** `rotate` açılan alev kanatları + `scale` parlayan çekirdek.
- **Bileşen 16:** Üç halkanın kademeli gecikmeli `opacity` nabzı.
- **Bileşen 17:** Üç ayrı `offset-path` üzerinde süzülen peri ışıkları.
- **Bileşen 18:** İç içe gecikmeli `scale/opacity` genişleyen enerji halkaları.
- **Bileşen 19:** Zıt yönlü `scaleX` kapı açılışı + senkronize `opacity` ışık taşması.
- **Bileşen 20:** Zıt yönlü `rotate` iki halka + `scale/opacity` nabız atan çekirdek.

**Genel notlar:** Tüm bileşenler `viewBox` tabanlı SVG kullanır, sabit piksel boyutu yoktur; tüm sınıflar `.sutol-mito-NN-` önekiyle kapsüllenmiştir; hiçbir global seçici veya dış kaynak kullanılmamıştır; her bileşende `prefers-reduced-motion` desteği mevcuttur ve tüm animasyonlar döngüseldir (`infinite`).
