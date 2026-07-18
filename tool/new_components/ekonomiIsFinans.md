## Bileşen 21: Tasarruf Kumbarası Dolumu

**Etiketler (keyword eşleşmesi için):** tasarruf, bütçe, gelir, birikim
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Kumbara silüetine düşen bir madeni paranın ardından kumbara içindeki dolum seviyesinin yavaşça yükselmesi.

```html
<div class="sutol-ekon21-wrap">
  <svg class="sutol-ekon21-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <defs>
      <clipPath id="sutol-ekon21-clip">
        <ellipse cx="50" cy="55" rx="32" ry="24"/>
      </clipPath>
    </defs>
    <rect class="sutol-ekon21-fill" x="18" y="30" width="64" height="50" clip-path="url(#sutol-ekon21-clip)" fill="currentColor" opacity="0.45"/>
    <ellipse class="sutol-ekon21-body" cx="50" cy="55" rx="32" ry="24" fill="none" stroke="currentColor" stroke-width="2"/>
    <rect class="sutol-ekon21-slot" x="46" y="31" width="8" height="3" rx="1" fill="currentColor"/>
    <circle class="sutol-ekon21-leg1" cx="35" cy="78" r="3" fill="currentColor"/>
    <circle class="sutol-ekon21-leg2" cx="65" cy="78" r="3" fill="currentColor"/>
    <circle class="sutol-ekon21-coin" cx="50" cy="8" r="5" fill="currentColor"/>
  </svg>
</div>
<style>
.sutol-ekon21-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #2e8b57; }
.sutol-ekon21-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon21-coin { animation: sutol-ekon21-drop 2.4s ease-in infinite; }
.sutol-ekon21-fill { animation: sutol-ekon21-rise 9.6s ease-in-out infinite; }
@keyframes sutol-ekon21-drop {
  0% { transform: translateY(0); opacity: 1; }
  68% { transform: translateY(40px); opacity: 1; }
  82% { transform: translateY(44px); opacity: 0; }
  100% { transform: translateY(0); opacity: 0; }
}
@keyframes sutol-ekon21-rise {
  0% { transform: translateY(22px); }
  100% { transform: translateY(0px); }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon21-coin { animation-duration: 12s; }
  .sutol-ekon21-fill { animation-duration: 30s; }
}
</style>
```

---

## Bileşen 22: Sermaye Likidite Havuzu Dalgası

**Etiketler (keyword eşleşmesi için):** sermaye, fon, yatırım, likidite
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Bir havuz çerçevesi içinde SMIL ile şekli sürekli değişen dalgalı bir sıvı yüzeyinin salınması.

```html
<div class="sutol-ekon22-wrap">
  <svg class="sutol-ekon22-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <rect x="10" y="15" width="80" height="70" rx="4" fill="none" stroke="currentColor" stroke-width="2"/>
    <clipPath id="sutol-ekon22-clip">
      <rect x="10" y="15" width="80" height="70" rx="4"/>
    </clipPath>
    <g clip-path="url(#sutol-ekon22-clip)">
      <path class="sutol-ekon22-wave" fill="currentColor" opacity="0.5">
        <animate attributeName="d" dur="4s" repeatCount="indefinite"
          values="M10,60 Q30,50 50,60 T90,60 V90 H10 Z;
                   M10,60 Q30,70 50,60 T90,60 V90 H10 Z;
                   M10,60 Q30,50 50,60 T90,60 V90 H10 Z"/>
      </path>
    </g>
  </svg>
</div>
<style>
.sutol-ekon22-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #1976d2; }
.sutol-ekon22-svg { width: 100%; height: 100%; display: block; }
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon22-wrap .sutol-ekon22-wave animate { }
}
</style>
```

---

## Bileşen 23: Kredi Limit Çubuğu

**Etiketler (keyword eşleşmesi için):** kredi, borç, harcama, limit
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Bir kartın yatay bir yol üzerinde kaydırılması ve buna eşlik eden limit çubuğunun dolup boşalması.

```html
<div class="sutol-ekon23-wrap">
  <svg class="sutol-ekon23-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <rect x="15" y="70" width="70" height="8" rx="4" fill="none" stroke="currentColor" stroke-width="1.5"/>
    <rect class="sutol-ekon23-bar" x="15" y="70" width="0" height="8" rx="4" fill="currentColor" opacity="0.6"/>
    <rect class="sutol-ekon23-card" x="0" y="25" width="26" height="16" rx="3" fill="currentColor"/>
  </svg>
</div>
<style>
.sutol-ekon23-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #6a1b9a; }
.sutol-ekon23-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon23-card {
  offset-path: path("M0,33 L74,33");
  animation: sutol-ekon23-slide 3s ease-in-out infinite;
}
.sutol-ekon23-bar { animation: sutol-ekon23-fill 3s ease-in-out infinite; }
@keyframes sutol-ekon23-slide {
  0% { offset-distance: 0%; }
  50% { offset-distance: 100%; }
  100% { offset-distance: 100%; }
}
@keyframes sutol-ekon23-fill {
  0% { width: 0; }
  50% { width: 70px; }
  100% { width: 70px; }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon23-card, .sutol-ekon23-bar { animation-duration: 10s; }
}
</style>
```

---

## Bileşen 24: Enflasyon Küçülen Banknot

**Etiketler (keyword eşleşmesi için):** enflasyon, satın alma gücü, fiyat, para birimi
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Bir banknot dikdörtgeninin zamanla küçülerek satın alma gücündeki erimeyi simgelemesi ve tekrar büyüyerek döngüyü yenilemesi.

```html
<div class="sutol-ekon24-wrap">
  <svg class="sutol-ekon24-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-ekon24-note">
      <rect x="20" y="35" width="60" height="30" rx="3" fill="none" stroke="currentColor" stroke-width="2"/>
      <circle cx="50" cy="50" r="8" fill="none" stroke="currentColor" stroke-width="1.5"/>
    </g>
  </svg>
</div>
<style>
.sutol-ekon24-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #c62828; }
.sutol-ekon24-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon24-note {
  transform-origin: 50px 50px;
  animation: sutol-ekon24-shrink 4s ease-in-out infinite;
}
@keyframes sutol-ekon24-shrink {
  0% { transform: scale(1); opacity: 1; }
  70% { transform: scale(0.45); opacity: 0.6; }
  100% { transform: scale(1); opacity: 1; }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon24-note { animation-duration: 14s; }
}
</style>
```

---

## Bileşen 25: Bileşik Faiz Büyüme Sarmalı

**Etiketler (keyword eşleşmesi için):** faiz oranı, bileşik faiz, büyüme, sermaye
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** İçten dışa doğru genişleyen bir spiral çizginin çizilerek bileşik büyümeyi görselleştirmesi.

```html
<div class="sutol-ekon25-wrap">
  <svg class="sutol-ekon25-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-ekon25-spiral" d="M50,50 
      m0,-2 a2,2 0 1,1 0,4 a6,6 0 1,1 0,-12 a12,12 0 1,1 0,24 a18,18 0 1,1 0,-36 a24,24 0 1,1 0,48"
      fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
  </svg>
</div>
<style>
.sutol-ekon25-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #ef6c00; }
.sutol-ekon25-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon25-spiral {
  stroke-dasharray: 220;
  stroke-dashoffset: 220;
  animation: sutol-ekon25-draw 4s ease-in-out infinite;
}
@keyframes sutol-ekon25-draw {
  0% { stroke-dashoffset: 220; }
  70% { stroke-dashoffset: 0; }
  100% { stroke-dashoffset: 0; opacity: 0; }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon25-spiral { animation-duration: 14s; }
}
</style>
```

---

## Bileşen 26: Vergi Dilimi Pasta Grafiği

**Etiketler (keyword eşleşmesi için):** vergi, gelir, kamu maliyesi, dağılım
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Canvas üzerinde çizilen bir pasta grafiğin dilimlerinin sırayla büyüyerek tamamlanması.

```html
<div class="sutol-ekon26-wrap">
  <canvas class="sutol-ekon26-canvas"></canvas>
</div>
<script>
(function() {
  var wraps = document.querySelectorAll('.sutol-ekon26-wrap');
  wraps.forEach(function(wrap) {
    var canvas = wrap.querySelector('.sutol-ekon26-canvas');
    var ctx = canvas.getContext('2d');
    var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var speed = reduced ? 0.15 : 0.7;
    var t = 0;
    var slices = [0.35, 0.25, 0.2, 0.2];
    var colors = ['#1565c0', '#2e7d32', '#f9a825', '#6a1b9a'];
    function resize() {
      var rect = wrap.getBoundingClientRect();
      canvas.width = rect.width;
      canvas.height = rect.height;
    }
    resize();
    window.addEventListener('resize', resize);
    function draw() {
      var w = canvas.width, h = canvas.height;
      ctx.clearRect(0, 0, w, h);
      var cx = w / 2, cy = h / 2, r = Math.min(w, h) * 0.35;
      var progress = (Math.sin(t) + 1) / 2;
      var start = -Math.PI / 2;
      slices.forEach(function(s, i) {
        var end = start + s * 2 * Math.PI * progress;
        ctx.beginPath();
        ctx.moveTo(cx, cy);
        ctx.arc(cx, cy, r, start, end);
        ctx.closePath();
        ctx.fillStyle = colors[i % colors.length];
        ctx.fill();
        start += s * 2 * Math.PI;
      });
      t += 0.01 * speed;
      requestAnimationFrame(draw);
    }
    requestAnimationFrame(draw);
  });
})();
</script>
<style>
.sutol-ekon26-wrap { position: relative; width: 100%; height: 100%; background: transparent; }
.sutol-ekon26-canvas { width: 100%; height: 100%; display: block; }
</style>
```

---

## Bileşen 27: Küresel Ticaret Ağı Bağlantısı

**Etiketler (keyword eşleşmesi için):** ticaret, ihracat, ithalat, küresel ağ
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Birbirine bağlı düğüm noktaları arasında sırayla çizilen çizgilerle küresel ticaret ağının kurulması.

```html
<div class="sutol-ekon27-wrap">
  <svg class="sutol-ekon27-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-ekon27-lines" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round">
      <path class="sutol-ekon27-l1" d="M20,25 L50,50"/>
      <path class="sutol-ekon27-l2" d="M50,50 L80,25"/>
      <path class="sutol-ekon27-l3" d="M50,50 L25,78"/>
      <path class="sutol-ekon27-l4" d="M50,50 L78,75"/>
    </g>
    <circle class="sutol-ekon27-node" cx="20" cy="25" r="4" fill="currentColor"/>
    <circle class="sutol-ekon27-node" cx="80" cy="25" r="4" fill="currentColor"/>
    <circle class="sutol-ekon27-node sutol-ekon27-center" cx="50" cy="50" r="5" fill="currentColor"/>
    <circle class="sutol-ekon27-node" cx="25" cy="78" r="4" fill="currentColor"/>
    <circle class="sutol-ekon27-node" cx="78" cy="75" r="4" fill="currentColor"/>
  </svg>
</div>
<style>
.sutol-ekon27-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #00695c; }
.sutol-ekon27-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon27-lines path {
  stroke-dasharray: 60;
  stroke-dashoffset: 60;
  animation: sutol-ekon27-draw 5s ease-in-out infinite;
}
.sutol-ekon27-l2 { animation-delay: 0.4s; }
.sutol-ekon27-l3 { animation-delay: 0.8s; }
.sutol-ekon27-l4 { animation-delay: 1.2s; }
.sutol-ekon27-center { animation: sutol-ekon27-pulse 2.5s ease-in-out infinite; }
@keyframes sutol-ekon27-draw {
  0% { stroke-dashoffset: 60; opacity: 0; }
  20% { opacity: 1; }
  60% { stroke-dashoffset: 0; opacity: 1; }
  100% { stroke-dashoffset: 0; opacity: 0.2; }
}
@keyframes sutol-ekon27-pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.3); }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon27-lines path { animation-duration: 16s; }
  .sutol-ekon27-center { animation-duration: 9s; }
}
</style>
```

---

## Bileşen 28: Tedarik Zinciri Domino Akışı

**Etiketler (keyword eşleşmesi için):** tedarik zinciri, lojistik, üretim, akış
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Yan yana dizili dikdörtgen bloklarının sırayla devrilip ardından toparlanmasıyla tedarik zincirindeki akışın simgelenmesi.

```html
<div class="sutol-ekon28-wrap">
  <svg class="sutol-ekon28-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <g fill="currentColor">
      <rect class="sutol-ekon28-block" x="12" y="55" width="10" height="30"/>
      <rect class="sutol-ekon28-block" x="28" y="55" width="10" height="30"/>
      <rect class="sutol-ekon28-block" x="44" y="55" width="10" height="30"/>
      <rect class="sutol-ekon28-block" x="60" y="55" width="10" height="30"/>
      <rect class="sutol-ekon28-block" x="76" y="55" width="10" height="30"/>
    </g>
  </svg>
</div>
<style>
.sutol-ekon28-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #4527a0; }
.sutol-ekon28-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon28-block {
  transform-box: fill-box;
  transform-origin: bottom center;
  animation: sutol-ekon28-topple 3s ease-in-out infinite;
}
.sutol-ekon28-block:nth-child(2) { animation-delay: 0.2s; }
.sutol-ekon28-block:nth-child(3) { animation-delay: 0.4s; }
.sutol-ekon28-block:nth-child(4) { animation-delay: 0.6s; }
.sutol-ekon28-block:nth-child(5) { animation-delay: 0.8s; }
@keyframes sutol-ekon28-topple {
  0%, 20% { transform: rotate(0deg); }
  35% { transform: rotate(65deg); }
  55% { transform: rotate(65deg); }
  75%, 100% { transform: rotate(0deg); }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon28-block { animation-duration: 10s; }
}
</style>
```

---

## Bileşen 29: Girişimcilik Kıvılcım Ampulü

**Etiketler (keyword eşleşmesi için):** girişimcilik, startup, inovasyon, fikir
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Bir ampul şeklinin içinde beliren kıvılcımın parlayıp sönmesiyle yeni bir fikrin doğuşunun canlandırılması.

```html
<div class="sutol-ekon29-wrap">
  <svg class="sutol-ekon29-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <circle cx="50" cy="42" r="20" fill="none" stroke="currentColor" stroke-width="2"/>
    <rect x="43" y="60" width="14" height="10" rx="2" fill="none" stroke="currentColor" stroke-width="2"/>
    <line x1="46" y1="72" x2="54" y2="72" stroke="currentColor" stroke-width="2"/>
    <path class="sutol-ekon29-spark" d="M50,32 L53,42 L48,42 L51,52" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
    <circle class="sutol-ekon29-glow" cx="50" cy="42" r="20" fill="currentColor" opacity="0"/>
  </svg>
</div>
<style>
.sutol-ekon29-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #f57f17; }
.sutol-ekon29-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon29-spark {
  stroke-dasharray: 40;
  stroke-dashoffset: 40;
  animation: sutol-ekon29-flash 2.6s ease-in-out infinite;
}
.sutol-ekon29-glow { animation: sutol-ekon29-fade 2.6s ease-in-out infinite; }
@keyframes sutol-ekon29-flash {
  0% { stroke-dashoffset: 40; }
  40% { stroke-dashoffset: 0; }
  100% { stroke-dashoffset: 0; }
}
@keyframes sutol-ekon29-fade {
  0%, 35% { opacity: 0; }
  55% { opacity: 0.35; }
  75%, 100% { opacity: 0; }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon29-spark, .sutol-ekon29-glow { animation-duration: 9s; }
}
</style>
```

---

## Bileşen 30: Marka Değer Yıldızı

**Etiketler (keyword eşleşmesi için):** marka, itibar, pazarlama, değer
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Merkezdeki bir yıldız şeklinin dönerek büyümesi ve etrafında parıldayan küçük yıldızların belirip kaybolması.

```html
<div class="sutol-ekon30-wrap">
  <svg class="sutol-ekon30-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <polygon class="sutol-ekon30-star" points="50,30 55,45 71,45 58,55 63,70 50,61 37,70 42,55 29,45 45,45" fill="currentColor"/>
    <circle class="sutol-ekon30-twinkle sutol-ekon30-t1" cx="25" cy="30" r="2" fill="currentColor"/>
    <circle class="sutol-ekon30-twinkle sutol-ekon30-t2" cx="75" cy="35" r="2" fill="currentColor"/>
    <circle class="sutol-ekon30-twinkle sutol-ekon30-t3" cx="30" cy="70" r="2" fill="currentColor"/>
    <circle class="sutol-ekon30-twinkle sutol-ekon30-t4" cx="72" cy="68" r="2" fill="currentColor"/>
  </svg>
</div>
<style>
.sutol-ekon30-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #ad1457; }
.sutol-ekon30-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon30-star {
  transform-box: fill-box;
  transform-origin: center;
  animation: sutol-ekon30-spin 5s ease-in-out infinite;
}
.sutol-ekon30-twinkle { animation: sutol-ekon30-blink 2s ease-in-out infinite; }
.sutol-ekon30-t2 { animation-delay: 0.4s; }
.sutol-ekon30-t3 { animation-delay: 0.8s; }
.sutol-ekon30-t4 { animation-delay: 1.2s; }
@keyframes sutol-ekon30-spin {
  0%, 100% { transform: rotate(0deg) scale(1); }
  50% { transform: rotate(180deg) scale(1.25); }
}
@keyframes sutol-ekon30-blink {
  0%, 100% { opacity: 0.1; }
  50% { opacity: 1; }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon30-star { animation-duration: 16s; }
  .sutol-ekon30-twinkle { animation-duration: 7s; }
}
</style>
```

---

## Bileşen 31: Rekabet Satranç Hamlesi

**Etiketler (keyword eşleşmesi için):** rekabet, strateji, pazar payı, oyun teorisi
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Bir satranç taşının dama tahtası üzerinde köşegen bir yol boyunca ilerleyip başlangıç konumuna dönmesi.

```html
<div class="sutol-ekon31-wrap">
  <svg class="sutol-ekon31-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-ekon31-board">
      <rect x="10" y="10" width="80" height="80" fill="none" stroke="currentColor" stroke-width="1.5"/>
      <rect x="10" y="10" width="20" height="20" fill="currentColor" opacity="0.15"/>
      <rect x="50" y="10" width="20" height="20" fill="currentColor" opacity="0.15"/>
      <rect x="30" y="30" width="20" height="20" fill="currentColor" opacity="0.15"/>
      <rect x="70" y="30" width="20" height="20" fill="currentColor" opacity="0.15"/>
      <rect x="10" y="50" width="20" height="20" fill="currentColor" opacity="0.15"/>
      <rect x="50" y="50" width="20" height="20" fill="currentColor" opacity="0.15"/>
      <rect x="30" y="70" width="20" height="20" fill="currentColor" opacity="0.15"/>
      <rect x="70" y="70" width="20" height="20" fill="currentColor" opacity="0.15"/>
    </g>
    <path class="sutol-ekon31-piece" d="M0,-6 L4,4 L-4,4 Z" fill="currentColor" transform="translate(20,20)"/>
  </svg>
</div>
<style>
.sutol-ekon31-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #263238; }
.sutol-ekon31-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon31-piece {
  offset-path: path("M20,20 L80,80 L20,20");
  animation: sutol-ekon31-move 4s ease-in-out infinite;
}
@keyframes sutol-ekon31-move {
  0% { offset-distance: 0%; }
  50% { offset-distance: 50%; }
  100% { offset-distance: 100%; }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon31-piece { animation-duration: 14s; }
}
</style>
```

---

## Bileşen 32: İşsizlik Boş Masa Sırası

**Etiketler (keyword eşleşmesi için):** işsizlik, istihdam, iş gücü, ekonomi
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Sıra halindeki ofis masası simgelerinin birer birer solup tekrar belirmesiyle iş gücündeki dalgalanmanın anlatılması.

```html
<div class="sutol-ekon32-wrap">
  <svg class="sutol-ekon32-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <g fill="none" stroke="currentColor" stroke-width="2">
      <g class="sutol-ekon32-desk">
        <rect x="10" y="55" width="14" height="4"/>
        <line x1="12" y1="59" x2="12" y2="70"/>
        <line x1="22" y1="59" x2="22" y2="70"/>
      </g>
      <g class="sutol-ekon32-desk">
        <rect x="32" y="55" width="14" height="4"/>
        <line x1="34" y1="59" x2="34" y2="70"/>
        <line x1="44" y1="59" x2="44" y2="70"/>
      </g>
      <g class="sutol-ekon32-desk">
        <rect x="54" y="55" width="14" height="4"/>
        <line x1="56" y1="59" x2="56" y2="70"/>
        <line x1="66" y1="59" x2="66" y2="70"/>
      </g>
      <g class="sutol-ekon32-desk">
        <rect x="76" y="55" width="14" height="4"/>
        <line x1="78" y1="59" x2="78" y2="70"/>
        <line x1="88" y1="59" x2="88" y2="70"/>
      </g>
    </g>
  </svg>
</div>
<style>
.sutol-ekon32-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #37474f; }
.sutol-ekon32-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon32-desk { animation: sutol-ekon32-fade 4s ease-in-out infinite; }
.sutol-ekon32-desk:nth-child(2) { animation-delay: 0.6s; }
.sutol-ekon32-desk:nth-child(3) { animation-delay: 1.2s; }
.sutol-ekon32-desk:nth-child(4) { animation-delay: 1.8s; }
@keyframes sutol-ekon32-fade {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.15; }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon32-desk { animation-duration: 13s; }
}
</style>
```

---

## Bileşen 33: Ekonomik Kriz Çatlayan Zemin

**Etiketler (keyword eşleşmesi için):** ekonomik kriz, resesyon, kırılganlık, çöküş
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Zemini temsil eden bir çizginin ortasından yayılan çatlakların çizilerek belirmesi ve ardından yeniden kapanması.

```html
<div class="sutol-ekon33-wrap">
  <svg class="sutol-ekon33-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <line x1="10" y1="80" x2="90" y2="80" stroke="currentColor" stroke-width="2"/>
    <path class="sutol-ekon33-crack" d="M50,80 L45,68 L55,60 L48,48 L58,38"
      fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    <path class="sutol-ekon33-crack sutol-ekon33-crack2" d="M50,80 L58,70 L50,58 L60,50"
      fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
</div>
<style>
.sutol-ekon33-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #b71c1c; }
.sutol-ekon33-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon33-crack {
  stroke-dasharray: 70;
  stroke-dashoffset: 70;
  animation: sutol-ekon33-spread 4s ease-in-out infinite;
}
.sutol-ekon33-crack2 { animation-delay: 0.3s; }
@keyframes sutol-ekon33-spread {
  0% { stroke-dashoffset: 70; opacity: 1; }
  45% { stroke-dashoffset: 0; opacity: 1; }
  80% { stroke-dashoffset: 0; opacity: 1; }
  100% { stroke-dashoffset: 70; opacity: 0; }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon33-crack { animation-duration: 14s; }
}
</style>
```

---

## Bileşen 34: Verimlilik Enerji Çubuğu

**Etiketler (keyword eşleşmesi için):** verimlilik, performans, üretkenlik, optimizasyon
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Dikey bir çubuğun taban seviyesinden yükselerek dolması ve tepesinde beliren bir parlama etkisiyle performans artışının vurgulanması.

```html
<div class="sutol-ekon34-wrap">
  <svg class="sutol-ekon34-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <rect x="42" y="15" width="16" height="70" rx="6" fill="none" stroke="currentColor" stroke-width="2"/>
    <rect class="sutol-ekon34-fill" x="44" y="17" width="12" height="0" rx="4" fill="currentColor"/>
    <circle class="sutol-ekon34-glow" cx="50" cy="15" r="6" fill="currentColor" opacity="0"/>
  </svg>
</div>
<style>
.sutol-ekon34-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #2e7d32; }
.sutol-ekon34-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon34-fill {
  transform-box: fill-box;
  transform-origin: bottom;
  animation: sutol-ekon34-grow 3.5s ease-in-out infinite;
}
.sutol-ekon34-glow { animation: sutol-ekon34-flash 3.5s ease-in-out infinite; }
@keyframes sutol-ekon34-grow {
  0% { height: 0; y: 85; }
  70% { height: 66px; y: 17; }
  100% { height: 66px; y: 17; }
}
@keyframes sutol-ekon34-flash {
  0%, 60% { opacity: 0; }
  75% { opacity: 0.6; }
  100% { opacity: 0; }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon34-fill, .sutol-ekon34-glow { animation-duration: 12s; }
}
</style>
```

---

## Bileşen 35: Piyasa Arz-Talep Dalga Osilasyonu

**Etiketler (keyword eşleşmesi için):** piyasa, arz, talep, denge noktası
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Birbirini kesen iki dalga eğrisinin sürekli şekil değiştirerek arz ve talebin dinamik dengesini canlandırması.

```html
<div class="sutol-ekon35-wrap">
  <svg class="sutol-ekon35-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <path fill="none" stroke="currentColor" stroke-width="2">
      <animate attributeName="d" dur="3.5s" repeatCount="indefinite"
        values="M10,30 Q35,50 60,35 T90,45;
                 M10,45 Q35,25 60,55 T90,30;
                 M10,30 Q35,50 60,35 T90,45"/>
    </path>
    <path fill="none" stroke="currentColor" stroke-width="2" opacity="0.6">
      <animate attributeName="d" dur="3.5s" repeatCount="indefinite"
        values="M10,60 Q35,40 60,65 T90,50;
                 M10,50 Q35,70 60,45 T90,65;
                 M10,60 Q35,40 60,65 T90,50"/>
    </path>
  </svg>
</div>
<style>
.sutol-ekon35-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #4e342e; }
.sutol-ekon35-svg { width: 100%; height: 100%; display: block; }
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon35-wrap {}
}
</style>
```

---

## Bileşen 36: Borç Kartopu Büyümesi

**Etiketler (keyword eşleşmesi için):** borç, faiz, kredi, birikmiş yük
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Bir dairenin eğimli bir yol boyunca yuvarlanırken giderek büyümesiyle biriken borç yükünün simgelenmesi.

```html
<div class="sutol-ekon36-wrap">
  <svg class="sutol-ekon36-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <line x1="10" y1="20" x2="85" y2="85" stroke="currentColor" stroke-width="1.5" stroke-dasharray="3,3"/>
    <circle class="sutol-ekon36-ball" r="5" fill="currentColor"/>
  </svg>
</div>
<style>
.sutol-ekon36-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #d84315; }
.sutol-ekon36-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon36-ball {
  offset-path: path("M10,20 L85,85");
  animation: sutol-ekon36-roll 4s linear infinite;
}
@keyframes sutol-ekon36-roll {
  0% { offset-distance: 0%; transform: scale(0.4) rotate(0deg); }
  100% { offset-distance: 100%; transform: scale(1.6) rotate(720deg); }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon36-ball { animation-duration: 14s; }
}
</style>
```

---

## Bileşen 37: Portföy Çeşitlendirme Halkası

**Etiketler (keyword eşleşmesi için):** hisse senedi, portföy, yatırım, çeşitlendirme
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** İç içe bir halka grafiğin renkli segmentlerinin dönerek portföydeki dağılımın dinamik biçimde vurgulanması.

```html
<div class="sutol-ekon37-wrap">
  <svg class="sutol-ekon37-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-ekon37-ring" transform-origin="50 50">
      <circle cx="50" cy="50" r="30" fill="none" stroke="#1565c0" stroke-width="10" stroke-dasharray="47 141" stroke-dashoffset="0"/>
      <circle cx="50" cy="50" r="30" fill="none" stroke="#2e7d32" stroke-width="10" stroke-dasharray="38 141" stroke-dashoffset="-47"/>
      <circle cx="50" cy="50" r="30" fill="none" stroke="#f9a825" stroke-width="10" stroke-dasharray="30 141" stroke-dashoffset="-85"/>
      <circle cx="50" cy="50" r="30" fill="none" stroke="#6a1b9a" stroke-width="10" stroke-dasharray="26 141" stroke-dashoffset="-115"/>
    </g>
  </svg>
</div>
<style>
.sutol-ekon37-wrap { position: relative; width: 100%; height: 100%; background: transparent; }
.sutol-ekon37-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon37-ring { animation: sutol-ekon37-spin 8s linear infinite; }
@keyframes sutol-ekon37-spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon37-ring { animation-duration: 26s; }
}
</style>
```

---

## Bileşen 38: Kâr Marjı Termometresi

**Etiketler (keyword eşleşmesi için):** kâr, marj, performans, finansal sağlık
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Bir termometre şeklinin içindeki sıvı seviyesinin yükselip alçalarak kâr marjındaki değişimin gösterilmesi.

```html
<div class="sutol-ekon38-wrap">
  <svg class="sutol-ekon38-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <defs>
      <clipPath id="sutol-ekon38-clip">
        <rect x="44" y="18" width="12" height="52" rx="6"/>
        <circle cx="50" cy="78" r="10"/>
      </clipPath>
    </defs>
    <g fill="none" stroke="currentColor" stroke-width="2">
      <rect x="44" y="18" width="12" height="52" rx="6"/>
      <circle cx="50" cy="78" r="10"/>
    </g>
    <rect class="sutol-ekon38-liquid" x="40" y="30" width="20" height="60" clip-path="url(#sutol-ekon38-clip)" fill="currentColor"/>
  </svg>
</div>
<style>
.sutol-ekon38-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #ad1457; }
.sutol-ekon38-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon38-liquid { animation: sutol-ekon38-level 4.5s ease-in-out infinite; }
@keyframes sutol-ekon38-level {
  0% { transform: translateY(45px); }
  50% { transform: translateY(5px); }
  100% { transform: translateY(45px); }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon38-liquid { animation-duration: 15s; }
}
</style>
```

---

## Bileşen 39: Nakit Akışı Boru Hattı

**Etiketler (keyword eşleşmesi için):** nakit akışı, likidite, bütçe, gelir gider
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** Bir boru hattı boyunca hareket eden küçük parçacıkların akışkan nakit akışını temsil etmesi.

```html
<div class="sutol-ekon39-wrap">
  <svg class="sutol-ekon39-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <path d="M10,50 L35,50 L45,25 L65,75 L75,50 L90,50" fill="none" stroke="currentColor" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" opacity="0.35"/>
    <circle class="sutol-ekon39-drop" r="3" fill="currentColor"/>
    <circle class="sutol-ekon39-drop sutol-ekon39-d2" r="3" fill="currentColor"/>
    <circle class="sutol-ekon39-drop sutol-ekon39-d3" r="3" fill="currentColor"/>
  </svg>
</div>
<style>
.sutol-ekon39-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #00838f; }
.sutol-ekon39-svg { width: 100%; height: 100%; display: block; }
.sutol-ekon39-drop {
  offset-path: path("M10,50 L35,50 L45,25 L65,75 L75,50 L90,50");
  animation: sutol-ekon39-flow 3s linear infinite;
}
.sutol-ekon39-d2 { animation-delay: 1s; }
.sutol-ekon39-d3 { animation-delay: 2s; }
@keyframes sutol-ekon39-flow {
  0% { offset-distance: 0%; opacity: 0; }
  10% { opacity: 1; }
  90% { opacity: 1; }
  100% { offset-distance: 100%; opacity: 0; }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon39-drop { animation-duration: 11s; }
}
</style>
```

---

## Bileşen 40: Küresel Pazar Küresi

**Etiketler (keyword eşleşmesi için):** küresel ticaret, pazar, ihracat, ağ
**Kategori:** Ekonomi / İş / Finans
**Açıklama:** 3B perspektifle dönen bir küre etrafında yörüngede dolaşan küçük noktaların küresel pazar bağlantılarını temsil etmesi.

```html
<div class="sutol-ekon40-wrap">
  <div class="sutol-ekon40-scene">
    <div class="sutol-ekon40-globe">
      <div class="sutol-ekon40-ring sutol-ekon40-ring1"></div>
      <div class="sutol-ekon40-ring sutol-ekon40-ring2"></div>
      <div class="sutol-ekon40-ring sutol-ekon40-ring3"></div>
    </div>
    <div class="sutol-ekon40-orbit sutol-ekon40-orbit1"><div class="sutol-ekon40-sat"></div></div>
    <div class="sutol-ekon40-orbit sutol-ekon40-orbit2"><div class="sutol-ekon40-sat"></div></div>
  </div>
</div>
<style>
.sutol-ekon40-wrap { position: relative; width: 100%; height: 100%; background: transparent; color: #1565c0; }
.sutol-ekon40-scene {
  position: relative;
  width: 100%;
  height: 100%;
  perspective: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.sutol-ekon40-globe {
  position: relative;
  width: 55%;
  height: 55%;
  transform-style: preserve-3d;
  animation: sutol-ekon40-rotate 9s linear infinite;
  border-radius: 50%;
  border: 2px solid currentColor;
}
.sutol-ekon40-ring {
  position: absolute;
  inset: 0;
  border: 1px solid currentColor;
  border-radius: 50%;
  opacity: 0.5;
}
.sutol-ekon40-ring1 { transform: rotateY(60deg); }
.sutol-ekon40-ring2 { transform: rotateY(120deg); }
.sutol-ekon40-ring3 { transform: rotateX(60deg); }
.sutol-ekon40-orbit {
  position: absolute;
  border: 1px dashed currentColor;
  border-radius: 50%;
  opacity: 0.4;
  transform-style: preserve-3d;
}
.sutol-ekon40-orbit1 {
  width: 80%;
  height: 80%;
  animation: sutol-ekon40-spin 6s linear infinite;
}
.sutol-ekon40-orbit2 {
  width: 95%;
  height: 95%;
  transform: rotateX(70deg);
  animation: sutol-ekon40-spin 10s linear infinite reverse;
}
.sutol-ekon40-sat {
  position: absolute;
  top: -3%;
  left: 50%;
  width: 6%;
  height: 6%;
  margin-left: -3%;
  background: currentColor;
  border-radius: 50%;
}
@keyframes sutol-ekon40-rotate {
  0% { transform: rotateY(0deg); }
  100% { transform: rotateY(360deg); }
}
@keyframes sutol-ekon40-spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
.sutol-ekon40-orbit2 {
  animation-name: sutol-ekon40-spin2;
}
@keyframes sutol-ekon40-spin2 {
  0% { transform: rotateX(70deg) rotate(0deg); }
  100% { transform: rotateX(70deg) rotate(-360deg); }
}
@media (prefers-reduced-motion: reduce) {
  .sutol-ekon40-globe, .sutol-ekon40-orbit1, .sutol-ekon40-orbit2 { animation-duration: 30s; }
}
</style>
```

===BULLETS===
- Bileşen 21 (Tasarruf Kumbarası Dolumu): CSS keyframes ile senkronize düşen madeni para ve clip-path'li dolum seviyesi; SVG düğüm sayısı düşük, GPU dostu transform/opacity kullanır.
- Bileşen 22 (Sermaye Likidite Havuzu Dalgası): SVG SMIL `animate` ile path `d` özniteliği morph edilir; tek path elemanı olduğundan hafif, reduced-motion'da doğası gereği yavaş algılanan döngüsel bir dalga.
- Bileşen 23 (Kredi Limit Çubuğu): CSS `offset-path` ile kart yatay hareket eder, limit çubuğu genişlik animasyonuyla senkronludur; sade DOM, düşük maliyetli.
- Bileşen 24 (Enflasyon Küçülen Banknot): Tek grup üzerinde `transform: scale` keyframes kullanır; en hafif bileşenlerden biri, layout tetiklemez.
- Bileşen 25 (Bileşik Faiz Büyüme Sarmalı): `stroke-dasharray/dashoffset` ile spiral path çizim animasyonu; tek path, GPU maliyeti düşük.
- Bileşen 26 (Vergi Dilimi Pasta Grafiği): Canvas + `requestAnimationFrame` ile pasta dilimleri her karede yeniden çizilir; `prefers-reduced-motion` kontrolü JS içinde hız çarpanı olarak uygulanır, resize dinleyicisi ile responsive kalır.
- Bileşen 27 (Küresel Ticaret Ağı Bağlantısı): `stroke-dasharray/dashoffset` ile gecikmeli (staggered) çizgi çizimi ve merkez düğümde `transform: scale` nabız animasyonu; tamamen CSS tabanlı, hafif.
- Bileşen 28 (Tedarik Zinciri Domino Akışı): `transform-box: fill-box` ile her blok kendi tabanından döner, `animation-delay` ile domino etkisi; sadece transform kullanır, reflow yok.
- Bileşen 29 (Girişimcilik Kıvılcım Ampulü): `stroke-dashoffset` çizim animasyonu ile opacity tabanlı parlama efekti birleşiktir; düşük karmaşıklıkta SVG.
- Bileşen 30 (Marka Değer Yıldızı): Merkezi yıldızda `transform: rotate/scale`, çevresindeki noktalarda gecikmeli opacity blink; tamamen transform/opacity, GPU dostu.
- Bileşen 31 (Rekabet Satranç Hamlesi): `offset-path` ile satranç taşı köşegen yol boyunca ilerler; statik tahta arka planı yeniden çizilmez, tek hareketli eleman.
- Bileşen 32 (İşsizlik Boş Masa Sırası): Gecikmeli `opacity` keyframes ile sıralı solma; saf CSS, DOM manipülasyonu yok.
- Bileşen 33 (Ekonomik Kriz Çatlayan Zemin): `stroke-dasharray/dashoffset` ile çatlağın belirip kaybolması; iki path'te farklı gecikme, hafif SVG.
- Bileşen 34 (Verimlilik Enerji Çubuğu): SVG rect üzerinde `height/y` animasyonu (transform-box fill-box) ve tepe noktasında opacity parlama; orta düzey maliyetli ama sınırlı eleman sayısı.
- Bileşen 35 (Piyasa Arz-Talep Dalga Osilasyonu): İki bağımsız path üzerinde SMIL `animate` ile `d` morph; DOM'a dokunmadan sürekli osilasyon sağlar.
- Bileşen 36 (Borç Kartopu Büyümesi): `offset-path` boyunca hareket eden dairede eşzamanlı `scale` ve `rotate` transform'u; tek eleman, performanslı.
- Bileşen 37 (Portföy Çeşitlendirme Halkası): Sabit `stroke-dasharray` segmentli halka grafiğin grup halinde `rotate` ile döndürülmesi; tek transform animasyonu, çok ucuz.
- Bileşen 38 (Kâr Marjı Termometresi): clip-path ile sınırlanan sıvı dikdörtgeninin `translateY` ile yükselip alçalması; GPU dostu transform, sabit clip-path maliyeti düşük.
- Bileşen 39 (Nakit Akışı Boru Hattı): `offset-path` üzerinde üç parçacığın gecikmeli akışı; path tek kez çizilir, parçacıklar sadece transform/opacity kullanır.
- Bileşen 40 (Küresel Pazar Küresi): Saf CSS `perspective`/`rotateY`/`rotateX` ile 3B küre ve yörüngeler; tamamen transform tabanlı, DOM sade tutularak GPU katmanlarında ucuz çalışır.
