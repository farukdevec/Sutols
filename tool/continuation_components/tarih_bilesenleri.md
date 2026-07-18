# Sutol — Tarih Kategorisi Animasyonlu Bileşenler (20 Adet)

Aşağıda "Tarih" kategorisi için üretilmiş 20 adet bağımsız, şeffaf arka planlı, sandbox-uyumlu animasyonlu HTML bileşeni yer almaktadır. Her bileşen tek başına `<div>` kökü içinde çalışacak şekilde tasarlanmıştır; dış kaynak, font veya API kullanılmamıştır.

---

## Bileşen 1: Feodal Piramit

**Etiketler (keyword eşleşmesi için):** feodal sistem, hiyerarşi, kral, soylular, köylüler
**Kategori:** Tarih
**Açıklama:** Kraldan köylüye doğru katmanlı bir toplumsal piramidin, her katmanın sırayla ışıldamasıyla hiyerarşiyi anlattığı bir SVG animasyonu.

```html
<div class="sutol-tar-01-root">
  <style>
    .sutol-tar-01-root { width:100%; height:100%; position:relative; }
    .sutol-tar-01-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-01-layer { transform-origin: center; animation: sutol-tar-01-glow 6s ease-in-out infinite; }
    .sutol-tar-01-layer.l1 { animation-delay: 0s; }
    .sutol-tar-01-layer.l2 { animation-delay: .6s; }
    .sutol-tar-01-layer.l3 { animation-delay: 1.2s; }
    .sutol-tar-01-layer.l4 { animation-delay: 1.8s; }
    .sutol-tar-01-crown { animation: sutol-tar-01-bob 3s ease-in-out infinite; transform-origin: center; }
    @keyframes sutol-tar-01-glow {
      0%, 70%, 100% { opacity: .55; }
      15% { opacity: 1; }
    }
    @keyframes sutol-tar-01-bob {
      0%, 100% { transform: translateY(0); }
      50% { transform: translateY(-4px); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-01-layer, .sutol-tar-01-crown { animation: none !important; opacity: .85; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <polygon class="sutol-tar-01-layer l4" points="200,230 60,280 340,280" fill="#8b5a2b"/>
    <polygon class="sutol-tar-01-layer l3" points="200,175 95,225 305,225" fill="#b5651d"/>
    <polygon class="sutol-tar-01-layer l2" points="200,120 130,170 270,170" fill="#d98e29"/>
    <polygon class="sutol-tar-01-layer l1" points="200,70 165,115 235,115" fill="#f2c14e"/>
    <g class="sutol-tar-01-crown" transform="translate(200,55)">
      <polygon points="-14,10 -14,-6 -7,4 0,-10 7,4 14,-6 14,10" fill="#f2c14e" stroke="#8b5a2b" stroke-width="1.5"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 2: Haçlı Sefer Rotası

**Etiketler (keyword eşleşmesi için):** haçlı seferleri, kutsal topraklar, sefer yolu, orta çağ
**Kategori:** Tarih
**Açıklama:** Kesikli bir deniz rotası üzerinde ilerleyen küçük bir yelkenli gemi ve rotanın ucundaki kalkan-haç sembolünün nabız gibi parladığı bir yolculuk animasyonu.

```html
<div class="sutol-tar-02-root">
  <style>
    .sutol-tar-02-root { width:100%; height:100%; position:relative; }
    .sutol-tar-02-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-02-path { stroke-dasharray: 6 8; animation: sutol-tar-02-dash 4s linear infinite; }
    .sutol-tar-02-ship { offset-path: path('M40,220 C120,180 180,240 260,150 S 340,90 360,70'); animation: sutol-tar-02-move 7s ease-in-out infinite; }
    .sutol-tar-02-emblem { animation: sutol-tar-02-pulse 2.5s ease-in-out infinite; transform-origin: 360px 70px; }
    @keyframes sutol-tar-02-dash { to { stroke-dashoffset: -140; } }
    @keyframes sutol-tar-02-move {
      0% { offset-distance: 0%; }
      100% { offset-distance: 100%; }
    }
    @keyframes sutol-tar-02-pulse {
      0%, 100% { opacity: .6; transform: scale(1); }
      50% { opacity: 1; transform: scale(1.15); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-02-path { animation: none; }
      .sutol-tar-02-ship { animation: none; offset-distance: 60%; }
      .sutol-tar-02-emblem { animation: none; opacity: .9; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-tar-02-path" d="M40,220 C120,180 180,240 260,150 S 340,90 360,70" fill="none" stroke="#7a5230" stroke-width="2"/>
    <g class="sutol-tar-02-emblem" transform="translate(360,70)">
      <path d="M-16,-4 h13 v-10 h6 v10 h13 v10 h-13 v14 c0,4 -3,7 -9.5,10 c-6.5,-3 -9.5,-6 -9.5,-10 v-14 z" fill="#c1440e"/>
    </g>
    <g class="sutol-tar-02-ship">
      <path d="M-10,4 L10,4 L6,10 L-6,10 Z" fill="#5b3a29"/>
      <line x1="0" y1="4" x2="0" y2="-14" stroke="#3d2818" stroke-width="1.5"/>
      <path d="M0,-13 L11,-3 L0,-3 Z" fill="#e8d9b5"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 3: Reform Işığı

**Etiketler (keyword eşleşmesi için):** reform hareketi, aydınlanma, değişim, kilise
**Kategori:** Tarih
**Açıklama:** Kapalı bir kapının yavaşça aralanmasıyla içeriden yayılan ışık huzmelerinin genişlediği, değişimi simgeleyen bir animasyon.

```html
<div class="sutol-tar-03-root">
  <style>
    .sutol-tar-03-root { width:100%; height:100%; position:relative; }
    .sutol-tar-03-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-03-doorL { transform-origin: 170px 220px; animation: sutol-tar-03-openL 5s ease-in-out infinite; }
    .sutol-tar-03-doorR { transform-origin: 230px 220px; animation: sutol-tar-03-openR 5s ease-in-out infinite; }
    .sutol-tar-03-ray { animation: sutol-tar-03-fade 5s ease-in-out infinite; transform-origin: 200px 220px; }
    @keyframes sutol-tar-03-openL {
      0%, 15% { transform: rotateY(0deg) skewY(0deg) scaleX(1); }
      50% { transform: skewY(-8deg) scaleX(.85) translateX(-8px); }
      85%,100% { transform: rotateY(0deg) skewY(0deg) scaleX(1); }
    }
    @keyframes sutol-tar-03-openR {
      0%, 15% { transform: skewY(0deg) scaleX(1); }
      50% { transform: skewY(8deg) scaleX(.85) translateX(8px); }
      85%,100% { transform: skewY(0deg) scaleX(1); }
    }
    @keyframes sutol-tar-03-fade {
      0%, 15% { opacity: 0; transform: scale(.4); }
      50% { opacity: .9; transform: scale(1); }
      85%,100% { opacity: 0; transform: scale(.4); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-03-doorL, .sutol-tar-03-doorR, .sutol-tar-03-ray { animation: none; }
      .sutol-tar-03-ray { opacity: .5; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-tar-03-ray">
      <polygon points="200,220 130,60 270,60" fill="#ffe08a" opacity=".5"/>
    </g>
    <rect x="130" y="120" width="140" height="100" fill="#4a3728"/>
    <rect class="sutol-tar-03-doorL" x="130" y="120" width="70" height="100" fill="#6b4c34" stroke="#2e2016" stroke-width="1"/>
    <rect class="sutol-tar-03-doorR" x="200" y="120" width="70" height="100" fill="#6b4c34" stroke="#2e2016" stroke-width="1"/>
  </svg>
</div>
```

---

## Bileşen 4: Yeni Kıyı

**Etiketler (keyword eşleşmesi için):** kolonileşme, keşif, yeni dünya, bayrak dikme
**Kategori:** Tarih
**Açıklama:** Dalgalar üzerinde ilerleyen bir yelkenlinin kıyıya ulaşıp, kıyıdaki bir direğe bayrağın yükselerek çekildiği bir keşif animasyonu.

```html
<div class="sutol-tar-04-root">
  <style>
    .sutol-tar-04-root { width:100%; height:100%; position:relative; }
    .sutol-tar-04-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-04-wave { animation: sutol-tar-04-wave 3s linear infinite; }
    .sutol-tar-04-ship { animation: sutol-tar-04-sail 6s ease-in-out infinite; }
    .sutol-tar-04-flag { animation: sutol-tar-04-rise 6s ease-in-out infinite; transform-origin: 330px 200px; }
    @keyframes sutol-tar-04-wave {
      0% { transform: translateX(0); }
      100% { transform: translateX(-40px); }
    }
    @keyframes sutol-tar-04-sail {
      0% { transform: translateX(-120px) translateY(0); }
      60% { transform: translateX(180px) translateY(-4px); }
      100% { transform: translateX(180px) translateY(-4px); }
    }
    @keyframes sutol-tar-04-rise {
      0%, 55% { transform: translateY(30px); opacity: 0; }
      80%, 100% { transform: translateY(0); opacity: 1; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-04-wave, .sutol-tar-04-ship { animation: none; }
      .sutol-tar-04-ship { transform: translateX(180px); }
      .sutol-tar-04-flag { animation: none; transform: translateY(0); opacity: 1; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <path d="M270,230 Q330,190 400,220 L400,300 L270,300 Z" fill="#8c7853"/>
    <g class="sutol-tar-04-flag" transform="translate(330,200)">
      <rect x="-1.5" y="-40" width="3" height="40" fill="#5b4636"/>
      <polygon points="1.5,-40 26,-33 1.5,-26" fill="#c1440e"/>
    </g>
    <g class="sutol-tar-04-wave">
      <path d="M-40,230 Q0,222 40,230 T120,230 T200,230 T280,230 T360,230 T440,230" fill="none" stroke="#4a8fb5" stroke-width="4" opacity=".6"/>
      <path d="M-40,245 Q0,237 40,245 T120,245 T200,245 T280,245 T360,245 T440,245" fill="none" stroke="#3c78a0" stroke-width="4" opacity=".5"/>
    </g>
    <g class="sutol-tar-04-ship">
      <path d="M180,225 L220,225 L212,238 L188,238 Z" fill="#5b3a29"/>
      <line x1="200" y1="225" x2="200" y2="195" stroke="#3d2818" stroke-width="2"/>
      <path d="M200,196 L222,215 L200,215 Z" fill="#e8d9b5"/>
      <path d="M200,196 L182,213 L200,213 Z" fill="#d9c79e"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 5: Soğuk Savaş Dengesi

**Etiketler (keyword eşleşmesi için):** soğuk savaş, iki kutuplu dünya, gerginlik, güç dengesi
**Kategori:** Tarih
**Açıklama:** Ortadaki bir çizgiyle ayrılan iki karşıt rengin, sırayla büyüyüp küçülerek gerilimli bir denge kurduğu simetrik bir animasyon.

```html
<div class="sutol-tar-05-root">
  <style>
    .sutol-tar-05-root { width:100%; height:100%; position:relative; }
    .sutol-tar-05-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-05-left { animation: sutol-tar-05-pulseL 4s ease-in-out infinite; transform-origin: 120px 150px; }
    .sutol-tar-05-right { animation: sutol-tar-05-pulseR 4s ease-in-out infinite; transform-origin: 280px 150px; }
    .sutol-tar-05-div { animation: sutol-tar-05-flicker 2s ease-in-out infinite; }
    @keyframes sutol-tar-05-pulseL {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.12); }
    }
    @keyframes sutol-tar-05-pulseR {
      0%, 100% { transform: scale(1.12); }
      50% { transform: scale(1); }
    }
    @keyframes sutol-tar-05-flicker {
      0%, 100% { opacity: .7; }
      50% { opacity: 1; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-05-left, .sutol-tar-05-right, .sutol-tar-05-div { animation: none; opacity: .9; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <circle class="sutol-tar-05-left" cx="120" cy="150" r="55" fill="#c0392b"/>
    <circle class="sutol-tar-05-right" cx="280" cy="150" r="55" fill="#2e5fa3"/>
    <line class="sutol-tar-05-div" x1="200" y1="60" x2="200" y2="240" stroke="#e5e5e5" stroke-width="3" stroke-dasharray="4 6"/>
  </svg>
</div>
```

---

## Bileşen 6: Demir Perde

**Etiketler (keyword eşleşmesi için):** demir perde, ayrım, bölünme, sınır
**Kategori:** Tarih
**Açıklama:** Birbirine kenetlenmiş dikey demir çubukların yavaşça aralanıp kapanarak ortada dar bir ışık aralığı bıraktığı bir bölünme animasyonu.

```html
<div class="sutol-tar-06-root">
  <style>
    .sutol-tar-06-root { width:100%; height:100%; position:relative; }
    .sutol-tar-06-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-06-bar { animation: sutol-tar-06-sway 5s ease-in-out infinite; transform-origin: center top; }
    .sutol-tar-06-glow { animation: sutol-tar-06-glow 5s ease-in-out infinite; }
    @keyframes sutol-tar-06-sway {
      0%, 100% { transform: translateX(0); }
      50% { transform: translateX(var(--sutol-shift, 0px)); }
    }
    @keyframes sutol-tar-06-glow {
      0%, 100% { opacity: .15; }
      50% { opacity: .45; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-06-bar, .sutol-tar-06-glow { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <rect class="sutol-tar-06-glow" x="190" y="40" width="20" height="220" fill="#ffe9a8"/>
    <g fill="#4b4b4b">
      <rect class="sutol-tar-06-bar" style="--sutol-shift:-3px" x="60" y="40" width="14" height="220"/>
      <rect class="sutol-tar-06-bar" style="--sutol-shift:-5px" x="90" y="40" width="14" height="220"/>
      <rect class="sutol-tar-06-bar" style="--sutol-shift:-8px" x="120" y="40" width="14" height="220"/>
      <rect class="sutol-tar-06-bar" style="--sutol-shift:-12px" x="150" y="40" width="14" height="220"/>
      <rect class="sutol-tar-06-bar" style="--sutol-shift:12px" x="236" y="40" width="14" height="220"/>
      <rect class="sutol-tar-06-bar" style="--sutol-shift:8px" x="266" y="40" width="14" height="220"/>
      <rect class="sutol-tar-06-bar" style="--sutol-shift:5px" x="296" y="40" width="14" height="220"/>
      <rect class="sutol-tar-06-bar" style="--sutol-shift:3px" x="326" y="40" width="14" height="220"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 7: Silahlanma Yarışı

**Etiketler (keyword eşleşmesi için):** silahlanma yarışı, rekabet, teknoloji yarışı, yükseliş
**Kategori:** Tarih
**Açıklama:** İki rengin karşılıklı olarak birbirini geçmeye çalıştığı, canvas üzerinde JavaScript ile çizilen yükselen iki ok/roket yarışı animasyonu.

```html
<div class="sutol-tar-07-root">
  <style>
    .sutol-tar-07-root { width:100%; height:100%; position:relative; }
    .sutol-tar-07-root canvas { width:100%; height:100%; display:block; }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-07-root canvas { animation-play-state: paused; }
    }
  </style>
  <canvas class="sutol-tar-07-canvas" width="400" height="300"></canvas>
  <script>
    (function(){
      var root = document.currentScript.closest('.sutol-tar-07-root');
      var canvas = root.querySelector('.sutol-tar-07-canvas');
      var ctx = canvas.getContext('2d');
      var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      var t0 = null;
      function draw(ts){
        if (t0 === null) t0 = ts;
        var t = reduced ? 0.3 : ((ts - t0) / 1000) % 6 / 6;
        ctx.clearRect(0,0,400,300);
        function rocket(x, colorA, phase){
          var p = (t + phase) % 1;
          var y = 250 - p * 190;
          ctx.save();
          ctx.translate(x, y);
          ctx.fillStyle = colorA;
          ctx.beginPath();
          ctx.moveTo(0,-16); ctx.lineTo(8,10); ctx.lineTo(-8,10); ctx.closePath();
          ctx.fill();
          ctx.globalAlpha = .35;
          ctx.beginPath();
          ctx.moveTo(-4,10); ctx.lineTo(4,10); ctx.lineTo(0, 30 + p*10); ctx.closePath();
          ctx.fill();
          ctx.restore();
        }
        rocket(150, '#c0392b', 0);
        rocket(250, '#2e5fa3', 0.15);
        ctx.strokeStyle = 'rgba(120,120,120,.5)';
        ctx.setLineDash([4,6]);
        ctx.beginPath(); ctx.moveTo(40,60); ctx.lineTo(360,60); ctx.stroke();
        if (!reduced) requestAnimationFrame(draw);
      }
      requestAnimationFrame(draw);
    })();
  </script>
</div>
```

---

## Bileşen 8: Kırılan Zincir

**Etiketler (keyword eşleşmesi için):** sömürgecilik sonrası dönem, bağımsızlık, özgürleşme, yeni ulus
**Kategori:** Tarih
**Açıklama:** Ortadan kopan bir zincirin halkalarının iki yana ayrılması ve aralarından yükselen bir bayrağın bağımsızlığı simgelediği bir animasyon.

```html
<div class="sutol-tar-08-root">
  <style>
    .sutol-tar-08-root { width:100%; height:100%; position:relative; }
    .sutol-tar-08-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-08-linkL { animation: sutol-tar-08-partL 6s ease-in-out infinite; }
    .sutol-tar-08-linkR { animation: sutol-tar-08-partR 6s ease-in-out infinite; }
    .sutol-tar-08-flagpole { animation: sutol-tar-08-rise 6s ease-in-out infinite; transform-origin: 200px 220px; }
    @keyframes sutol-tar-08-partL {
      0%, 20% { transform: translateX(0) rotate(0deg); }
      60%,100% { transform: translateX(-18px) rotate(-12deg); }
    }
    @keyframes sutol-tar-08-partR {
      0%, 20% { transform: translateX(0) rotate(0deg); }
      60%,100% { transform: translateX(18px) rotate(12deg); }
    }
    @keyframes sutol-tar-08-rise {
      0%, 30% { transform: translateY(40px); opacity: 0; }
      70%,100% { transform: translateY(0); opacity: 1; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-08-linkL, .sutol-tar-08-linkR, .sutol-tar-08-flagpole { animation: none; }
      .sutol-tar-08-linkL { transform: translateX(-18px) rotate(-12deg); }
      .sutol-tar-08-linkR { transform: translateX(18px) rotate(12deg); }
      .sutol-tar-08-flagpole { transform: translateY(0); opacity: 1; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-tar-08-linkL" fill="none" stroke="#8a8a8a" stroke-width="8">
      <ellipse cx="150" cy="150" rx="16" ry="22"/>
      <ellipse cx="178" cy="150" rx="16" ry="22"/>
    </g>
    <g class="sutol-tar-08-linkR" fill="none" stroke="#8a8a8a" stroke-width="8">
      <ellipse cx="222" cy="150" rx="16" ry="22"/>
      <ellipse cx="250" cy="150" rx="16" ry="22"/>
    </g>
    <g class="sutol-tar-08-flagpole" transform="translate(200,220)">
      <rect x="-1.5" y="-90" width="3" height="90" fill="#5b4636"/>
      <polygon points="1.5,-90 30,-80 1.5,-70" fill="#2e8b57"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 9: Dalgalanan Bayrak

**Etiketler (keyword eşleşmesi için):** milliyetçilik akımı, ulus bilinci, bayrak, birlik
**Kategori:** Tarih
**Açıklama:** Rüzgarda dalgalanan soyut bir bayrağın CSS 3D dönüşümleriyle canlandırıldığı, etrafında yayılan ince ışın çizgilerinin bulunduğu bir animasyon.

```html
<div class="sutol-tar-09-root">
  <style>
    .sutol-tar-09-root { width:100%; height:100%; position:relative; perspective: 400px; }
    .sutol-tar-09-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-09-stripe { animation: sutol-tar-09-wave 3s ease-in-out infinite; transform-origin: left center; }
    .sutol-tar-09-stripe:nth-child(2) { animation-delay: .1s; }
    .sutol-tar-09-stripe:nth-child(3) { animation-delay: .2s; }
    .sutol-tar-09-ray { animation: sutol-tar-09-spread 4s ease-in-out infinite; transform-origin: 120px 150px; }
    @keyframes sutol-tar-09-wave {
      0%, 100% { transform: skewY(0deg) scaleX(1); }
      50% { transform: skewY(4deg) scaleX(.97); }
    }
    @keyframes sutol-tar-09-spread {
      0%, 100% { opacity: .2; transform: scale(1); }
      50% { opacity: .5; transform: scale(1.06); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-09-stripe, .sutol-tar-09-ray { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <circle class="sutol-tar-09-ray" cx="120" cy="150" r="70" fill="none" stroke="#c1440e" stroke-width="2"/>
    <line x1="120" y1="80" x2="120" y2="220" stroke="#5b4636" stroke-width="4"/>
    <g transform="translate(120,90)">
      <rect class="sutol-tar-09-stripe" x="0" y="0" width="140" height="15" fill="#c1440e"/>
      <rect class="sutol-tar-09-stripe" x="0" y="15" width="140" height="15" fill="#e8d9b5"/>
      <rect class="sutol-tar-09-stripe" x="0" y="30" width="140" height="15" fill="#c1440e"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 10: Aydınlanmanın Işığı

**Etiketler (keyword eşleşmesi için):** aydınlanma filozofları, akıl çağı, bilgi, kitap
**Kategori:** Tarih
**Açıklama:** Açık bir kitabın üzerinde parlayan bir mumun alevinin titreşmesi ve yükselen ince ışık parçacıklarının bilgiyi simgelediği bir animasyon.

```html
<div class="sutol-tar-10-root">
  <style>
    .sutol-tar-10-root { width:100%; height:100%; position:relative; }
    .sutol-tar-10-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-10-flame { animation: sutol-tar-10-flicker 1.6s ease-in-out infinite; transform-origin: 200px 130px; }
    .sutol-tar-10-spark { animation: sutol-tar-10-rise 3.5s ease-in infinite; }
    .sutol-tar-10-spark:nth-child(2) { animation-delay: .8s; }
    .sutol-tar-10-spark:nth-child(3) { animation-delay: 1.6s; }
    .sutol-tar-10-spark:nth-child(4) { animation-delay: 2.4s; }
    @keyframes sutol-tar-10-flicker {
      0%, 100% { transform: scaleY(1) scaleX(1); }
      50% { transform: scaleY(1.15) scaleX(.9); }
    }
    @keyframes sutol-tar-10-rise {
      0% { transform: translateY(0); opacity: 0; }
      20% { opacity: 1; }
      100% { transform: translateY(-70px); opacity: 0; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-10-flame, .sutol-tar-10-spark { animation: none; opacity: .8; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <circle class="sutol-tar-10-spark" cx="196" cy="200" r="2.5" fill="#ffd873"/>
    <circle class="sutol-tar-10-spark" cx="206" cy="200" r="2" fill="#ffd873"/>
    <circle class="sutol-tar-10-spark" cx="200" cy="200" r="2.2" fill="#ffd873"/>
    <circle class="sutol-tar-10-spark" cx="210" cy="200" r="1.8" fill="#ffd873"/>
    <rect x="196" y="150" width="8" height="50" rx="2" fill="#e8d9b5"/>
    <g class="sutol-tar-10-flame" transform="translate(200,140)">
      <path d="M0,-16 C8,-6 8,4 0,10 C-8,4 -8,-6 0,-16 Z" fill="#f2a20c"/>
      <path d="M0,-8 C4,-2 4,4 0,7 C-4,4 -4,-2 0,-8 Z" fill="#ffe08a"/>
    </g>
    <path d="M120,210 L280,210 L270,225 L130,225 Z" fill="#8b5a2b"/>
    <path d="M125,208 Q200,196 275,208 L275,212 Q200,200 125,212 Z" fill="#f5ecd8"/>
  </svg>
</div>
```

---

## Bileşen 11: Tarımın Uyanışı

**Etiketler (keyword eşleşmesi için):** tarım devrimi, buğday, üretim, değirmen
**Kategori:** Tarih
**Açıklama:** Rüzgarda sallanan buğday başaklarının önünde dönen bir yel değirmeninin, üretim ve bolluğu anlattığı bir tarla animasyonu.

```html
<div class="sutol-tar-11-root">
  <style>
    .sutol-tar-11-root { width:100%; height:100%; position:relative; }
    .sutol-tar-11-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-11-blades { animation: sutol-tar-11-spin 4s linear infinite; transform-origin: 300px 90px; }
    .sutol-tar-11-stalk { animation: sutol-tar-11-sway 3s ease-in-out infinite; transform-origin: bottom center; }
    .sutol-tar-11-stalk:nth-child(odd) { animation-delay: .3s; }
    @keyframes sutol-tar-11-spin { to { transform: rotate(360deg); } }
    @keyframes sutol-tar-11-sway {
      0%, 100% { transform: rotate(-4deg); }
      50% { transform: rotate(4deg); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-11-blades, .sutol-tar-11-stalk { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <rect x="296" y="90" width="6" height="90" fill="#8b5a2b"/>
    <g class="sutol-tar-11-blades">
      <rect x="297" y="55" width="4" height="70" fill="#c9a15a"/>
      <rect x="265" y="88" width="70" height="4" fill="#c9a15a"/>
    </g>
    <g stroke="#7a9b3e" stroke-width="3" fill="none">
      <g class="sutol-tar-11-stalk"><line x1="60" y1="240" x2="60" y2="180"/><circle cx="60" cy="176" r="7" fill="#e0b84b"/></g>
      <g class="sutol-tar-11-stalk"><line x1="90" y1="240" x2="90" y2="170"/><circle cx="90" cy="166" r="7" fill="#e0b84b"/></g>
      <g class="sutol-tar-11-stalk"><line x1="120" y1="240" x2="120" y2="185"/><circle cx="120" cy="181" r="7" fill="#e0b84b"/></g>
      <g class="sutol-tar-11-stalk"><line x1="150" y1="240" x2="150" y2="175"/><circle cx="150" cy="171" r="7" fill="#e0b84b"/></g>
      <g class="sutol-tar-11-stalk"><line x1="180" y1="240" x2="180" y2="180"/><circle cx="180" cy="176" r="7" fill="#e0b84b"/></g>
      <g class="sutol-tar-11-stalk"><line x1="210" y1="240" x2="210" y2="170"/><circle cx="210" cy="166" r="7" fill="#e0b84b"/></g>
    </g>
  </svg>
</div>
```

---

## Bileşen 12: Kervan Yolu

**Etiketler (keyword eşleşmesi için):** kervan yolu, ticaret yolu, deve kervanı, çöl
**Kategori:** Tarih
**Açıklama:** Kum tepeleri üzerinde kıvrılan bir yol boyunca ilerleyen küçük deve siluetlerinin, uzun mesafeli ticaret yolculuğunu anlattığı bir animasyon.

```html
<div class="sutol-tar-12-root">
  <style>
    .sutol-tar-12-root { width:100%; height:100%; position:relative; }
    .sutol-tar-12-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-12-camel { offset-path: path('M20,230 Q100,190 160,220 T300,190 Q350,175 380,190'); animation: sutol-tar-12-move 8s linear infinite; }
    .sutol-tar-12-camel:nth-child(2) { animation-delay: -1.3s; }
    .sutol-tar-12-camel:nth-child(3) { animation-delay: -2.6s; }
    @keyframes sutol-tar-12-move {
      0% { offset-distance: 0%; }
      100% { offset-distance: 100%; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-12-camel { animation: none; offset-distance: 40%; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <path d="M0,240 Q100,210 200,235 T400,220 L400,300 L0,300 Z" fill="#d9b877"/>
    <path d="M20,230 Q100,190 160,220 T300,190 Q350,175 380,190" fill="none" stroke="#b5905a" stroke-width="1.5" stroke-dasharray="3 5" opacity=".6"/>
    <g class="sutol-tar-12-camel" fill="#6b4c34">
      <path d="M-10,4 q3,-10 6,-3 q2,-9 5,-2 q3,2 3,5 h4 v6 h-18 z"/>
      <rect x="-11" y="9" width="3" height="6"/><rect x="-2" y="9" width="3" height="6"/>
    </g>
    <g class="sutol-tar-12-camel" fill="#5b3f28">
      <path d="M-10,4 q3,-10 6,-3 q2,-9 5,-2 q3,2 3,5 h4 v6 h-18 z"/>
      <rect x="-11" y="9" width="3" height="6"/><rect x="-2" y="9" width="3" height="6"/>
    </g>
    <g class="sutol-tar-12-camel" fill="#7a5940">
      <path d="M-10,4 q3,-10 6,-3 q2,-9 5,-2 q3,2 3,5 h4 v6 h-18 z"/>
      <rect x="-11" y="9" width="3" height="6"/><rect x="-2" y="9" width="3" height="6"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 13: Yazının Doğuşu

**Etiketler (keyword eşleşmesi için):** yazının icadı, çivi yazısı, kil tablet, kayıt tutma
**Kategori:** Tarih
**Açıklama:** Bir kil tablet üzerinde stroke-dasharray tekniğiyle sırayla beliren çivi yazısı benzeri işaretlerin, bilgi kaydının doğuşunu anlattığı bir animasyon.

```html
<div class="sutol-tar-13-root">
  <style>
    .sutol-tar-13-root { width:100%; height:100%; position:relative; }
    .sutol-tar-13-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-13-mark { stroke-dasharray: 20; stroke-dashoffset: 20; animation: sutol-tar-13-write 6s ease-in-out infinite; }
    .sutol-tar-13-mark:nth-child(2) { animation-delay: .3s; }
    .sutol-tar-13-mark:nth-child(3) { animation-delay: .6s; }
    .sutol-tar-13-mark:nth-child(4) { animation-delay: .9s; }
    .sutol-tar-13-mark:nth-child(5) { animation-delay: 1.2s; }
    .sutol-tar-13-mark:nth-child(6) { animation-delay: 1.5s; }
    .sutol-tar-13-stylus { animation: sutol-tar-13-tip 6s ease-in-out infinite; }
    @keyframes sutol-tar-13-write {
      0%, 4% { stroke-dashoffset: 20; opacity: .3; }
      18%, 80% { stroke-dashoffset: 0; opacity: 1; }
      95%,100% { stroke-dashoffset: 20; opacity: .3; }
    }
    @keyframes sutol-tar-13-tip {
      0% { transform: translate(100px,90px); }
      100% { transform: translate(270px,190px); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-13-mark { animation: none; stroke-dashoffset: 0; opacity: .85; }
      .sutol-tar-13-stylus { animation: none; transform: translate(180px,140px); }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <rect x="90" y="80" width="220" height="140" rx="6" fill="#c9a15a"/>
    <g stroke="#7a5230" stroke-width="4" stroke-linecap="round" fill="none">
      <line class="sutol-tar-13-mark" x1="115" y1="105" x2="140" y2="105"/>
      <line class="sutol-tar-13-mark" x1="150" y1="105" x2="150" y2="130"/>
      <line class="sutol-tar-13-mark" x1="165" y1="110" x2="190" y2="120"/>
      <line class="sutol-tar-13-mark" x1="115" y1="150" x2="140" y2="160"/>
      <line class="sutol-tar-13-mark" x1="155" y1="150" x2="155" y2="175"/>
      <line class="sutol-tar-13-mark" x1="175" y1="155" x2="200" y2="150"/>
    </g>
    <circle class="sutol-tar-13-stylus" r="4" fill="#3d2818"/>
  </svg>
</div>
```

---

## Bileşen 14: Matbaanın Baskısı

**Etiketler (keyword eşleşmesi için):** matbaanın icadı, baskı makinesi, çoğaltma, bilgi yayılımı
**Kategori:** Tarih
**Açıklama:** Yukarı-aşağı hareket eden bir baskı plakasının kağıda temas ettiği anda üzerinde satır çizgilerinin belirdiği tekrar eden bir matbaa animasyonu.

```html
<div class="sutol-tar-14-root">
  <style>
    .sutol-tar-14-root { width:100%; height:100%; position:relative; }
    .sutol-tar-14-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-14-press { animation: sutol-tar-14-stamp 2.4s ease-in-out infinite; transform-origin: 200px 100px; }
    .sutol-tar-14-line { animation: sutol-tar-14-appear 2.4s ease-in-out infinite; }
    @keyframes sutol-tar-14-stamp {
      0%, 20% { transform: translateY(0); }
      40% { transform: translateY(38px); }
      60%,100% { transform: translateY(0); }
    }
    @keyframes sutol-tar-14-appear {
      0%, 45% { opacity: 0; }
      55%,100% { opacity: 1; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-14-press { animation: none; transform: translateY(38px); }
      .sutol-tar-14-line { animation: none; opacity: 1; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <rect x="150" y="190" width="100" height="70" fill="#f5ecd8" stroke="#c9a15a" stroke-width="2"/>
    <g stroke="#8b6f4e" stroke-width="2">
      <line class="sutol-tar-14-line" x1="165" y1="205" x2="235" y2="205"/>
      <line class="sutol-tar-14-line" x1="165" y1="215" x2="225" y2="215"/>
      <line class="sutol-tar-14-line" x1="165" y1="225" x2="235" y2="225"/>
      <line class="sutol-tar-14-line" x1="165" y1="235" x2="215" y2="235"/>
    </g>
    <g class="sutol-tar-14-press">
      <rect x="160" y="60" width="80" height="20" fill="#4a3728"/>
      <rect x="190" y="80" width="20" height="100" fill="#6b4c34"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 15: İmparatorluk Yankısı

**Etiketler (keyword eşleşmesi için):** imparatorluk mirası, kalıcı iz, sütun, miras
**Kategori:** Tarih
**Açıklama:** Merkezdeki bir sütundan dışarıya doğru genişleyen halkaların, bir imparatorluğun etkisinin zaman içinde nasıl yayıldığını simgelediği bir animasyon.

```html
<div class="sutol-tar-15-root">
  <style>
    .sutol-tar-15-root { width:100%; height:100%; position:relative; }
    .sutol-tar-15-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-15-ring { animation: sutol-tar-15-expand 4s ease-out infinite; transform-origin: 200px 150px; }
    .sutol-tar-15-ring:nth-child(2) { animation-delay: 1.3s; }
    .sutol-tar-15-ring:nth-child(3) { animation-delay: 2.6s; }
    @keyframes sutol-tar-15-expand {
      0% { transform: scale(.2); opacity: .8; }
      100% { transform: scale(1.6); opacity: 0; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-15-ring { animation: none; opacity: .3; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <circle class="sutol-tar-15-ring" cx="200" cy="150" r="60" fill="none" stroke="#c9a15a" stroke-width="3"/>
    <circle class="sutol-tar-15-ring" cx="200" cy="150" r="60" fill="none" stroke="#c9a15a" stroke-width="3"/>
    <circle class="sutol-tar-15-ring" cx="200" cy="150" r="60" fill="none" stroke="#c9a15a" stroke-width="3"/>
    <rect x="190" y="110" width="20" height="80" fill="#8b6f4e"/>
    <rect x="180" y="100" width="40" height="12" fill="#a4835a"/>
    <rect x="180" y="188" width="40" height="12" fill="#a4835a"/>
  </svg>
</div>
```

---

## Bileşen 16: Göçebe Rota

**Etiketler (keyword eşleşmesi için):** göçebe topluluk, otağ, mevsimlik göç, konar-göçer
**Kategori:** Tarih
**Açıklama:** Kıvrımlı bir göç yolu üzerinde ilerleyen küçük bir kervan noktası ve arka planda duran bir otağ/çadır ikonunun, sürekli hareket halindeki yaşamı anlattığı bir animasyon.

```html
<div class="sutol-tar-16-root">
  <style>
    .sutol-tar-16-root { width:100%; height:100%; position:relative; }
    .sutol-tar-16-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-16-dot { offset-path: path('M40,120 Q120,60 200,120 T360,100'); animation: sutol-tar-16-move 6s linear infinite; }
    .sutol-tar-16-trail { stroke-dasharray: 5 7; animation: sutol-tar-16-dash 3s linear infinite; }
    .sutol-tar-16-tent { animation: sutol-tar-16-sway 4s ease-in-out infinite; transform-origin: 200px 220px; }
    @keyframes sutol-tar-16-move {
      0% { offset-distance: 0%; }
      100% { offset-distance: 100%; }
    }
    @keyframes sutol-tar-16-dash { to { stroke-dashoffset: -24; } }
    @keyframes sutol-tar-16-sway {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.03); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-16-dot { animation: none; offset-distance: 50%; }
      .sutol-tar-16-trail, .sutol-tar-16-tent { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-tar-16-trail" d="M40,120 Q120,60 200,120 T360,100" fill="none" stroke="#a4835a" stroke-width="2"/>
    <circle class="sutol-tar-16-dot" r="6" fill="#c1440e"/>
    <g class="sutol-tar-16-tent" transform="translate(200,220)">
      <path d="M-40,40 L0,-40 L40,40 Z" fill="#8b6f4e"/>
      <path d="M-40,40 L0,-40 L0,40 Z" fill="#6b5238"/>
      <rect x="-6" y="20" width="12" height="20" fill="#3d2818"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 17: Şehir Devletinin Surları

**Etiketler (keyword eşleşmesi için):** şehir devleti, sur, kale kapısı, savunma
**Kategori:** Tarih
**Açıklama:** İki kuleli bir şehir suru ve yavaşça açılıp kapanan bir kapı ile üzerindeki bayrağın hafifçe dalgalandığı bir yerleşim animasyonu.

```html
<div class="sutol-tar-17-root">
  <style>
    .sutol-tar-17-root { width:100%; height:100%; position:relative; }
    .sutol-tar-17-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-17-gateL { animation: sutol-tar-17-openL 6s ease-in-out infinite; transform-origin: 185px 230px; }
    .sutol-tar-17-gateR { animation: sutol-tar-17-openR 6s ease-in-out infinite; transform-origin: 215px 230px; }
    .sutol-tar-17-flag { animation: sutol-tar-17-wave 2.4s ease-in-out infinite; transform-origin: left center; }
    @keyframes sutol-tar-17-openL {
      0%, 20% { transform: rotateY(0); }
      50% { transform: skewY(-6deg) translateX(-4px); }
      80%,100% { transform: rotateY(0); }
    }
    @keyframes sutol-tar-17-openR {
      0%, 20% { transform: rotateY(0); }
      50% { transform: skewY(6deg) translateX(4px); }
      80%,100% { transform: rotateY(0); }
    }
    @keyframes sutol-tar-17-wave {
      0%, 100% { transform: skewY(0deg); }
      50% { transform: skewY(8deg); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-17-gateL, .sutol-tar-17-gateR, .sutol-tar-17-flag { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <rect x="60" y="170" width="280" height="70" fill="#9c8b6d"/>
    <rect x="60" y="150" width="30" height="20" fill="#9c8b6d"/>
    <rect x="90" y="150" width="30" height="20" fill="#9c8b6d"/>
    <rect x="120" y="150" width="30" height="20" fill="#9c8b6d"/>
    <rect x="250" y="150" width="30" height="20" fill="#9c8b6d"/>
    <rect x="280" y="150" width="30" height="20" fill="#9c8b6d"/>
    <rect x="310" y="150" width="30" height="20" fill="#9c8b6d"/>
    <rect x="70" y="100" width="30" height="80" fill="#7a6b52"/>
    <rect x="300" y="100" width="30" height="80" fill="#7a6b52"/>
    <polygon points="70,100 85,80 100,100" fill="#5b4c38"/>
    <polygon points="300,100 315,80 330,100" fill="#5b4c38"/>
    <rect class="sutol-tar-17-gateL" x="155" y="200" width="30" height="40" fill="#4a3728"/>
    <rect class="sutol-tar-17-gateR" x="215" y="200" width="30" height="40" fill="#4a3728"/>
    <line x1="85" y1="80" x2="85" y2="55" stroke="#3d2818" stroke-width="2"/>
    <polygon class="sutol-tar-17-flag" points="85,55 105,60 85,65" fill="#c1440e"/>
  </svg>
</div>
```

---

## Bileşen 18: Teokratik Ziggurat

**Etiketler (keyword eşleşmesi için):** teokrasi, ziggurat, tapınak, kutsal yönetim
**Kategori:** Tarih
**Açıklama:** Basamaklı bir ziggurat/tapınak üzerinde asılı duran bir güneş sembolünün nabız gibi ışıklar yaydığı, dini ve siyasi otoritenin birleşimini simgeleyen bir animasyon.

```html
<div class="sutol-tar-18-root">
  <style>
    .sutol-tar-18-root { width:100%; height:100%; position:relative; }
    .sutol-tar-18-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-18-sun { animation: sutol-tar-18-pulse 3s ease-in-out infinite; transform-origin: 200px 90px; }
    .sutol-tar-18-beam { animation: sutol-tar-18-fade 3s ease-in-out infinite; transform-origin: 200px 90px; }
    @keyframes sutol-tar-18-pulse {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.15); }
    }
    @keyframes sutol-tar-18-fade {
      0%, 100% { opacity: .25; }
      50% { opacity: .6; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-18-sun, .sutol-tar-18-beam { animation: none; opacity: .8; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-tar-18-beam" fill="#f2c14e">
      <line x1="200" y1="90" x2="200" y2="40" stroke="#f2c14e" stroke-width="3"/>
      <line x1="200" y1="90" x2="160" y2="55" stroke="#f2c14e" stroke-width="3"/>
      <line x1="200" y1="90" x2="240" y2="55" stroke="#f2c14e" stroke-width="3"/>
    </g>
    <circle class="sutol-tar-18-sun" cx="200" cy="90" r="18" fill="#f2c14e"/>
    <polygon points="140,240 260,240 245,205 155,205" fill="#8b6f4e"/>
    <polygon points="155,205 245,205 232,175 168,175" fill="#a4835a"/>
    <polygon points="168,175 232,175 220,148 180,148" fill="#c9a15a"/>
    <polygon points="180,148 220,148 200,122 200,122" fill="#dcb977"/>
  </svg>
</div>
```

---

## Bileşen 19: Kırılan Halkalar

**Etiketler (keyword eşleşmesi için):** köle ticareti, insanlık dışı sistem, direniş, özgürleşme
**Kategori:** Tarih
**Açıklama:** Ağır bir zincirin halkalarının teker teker kırılıp yükselerek dağılması ve yerini yavaşça yükselen özgür bir kuş silüetine bırakmasıyla acıyı ve direnişi anlatan sade, sembolik bir animasyon.

```html
<div class="sutol-tar-19-root">
  <style>
    .sutol-tar-19-root { width:100%; height:100%; position:relative; }
    .sutol-tar-19-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-19-link { animation: sutol-tar-19-drift 7s ease-in-out infinite; }
    .sutol-tar-19-link:nth-child(1) { transform-origin: 130px 190px; animation-delay: 0s; }
    .sutol-tar-19-link:nth-child(2) { transform-origin: 165px 190px; animation-delay: .4s; }
    .sutol-tar-19-link:nth-child(3) { transform-origin: 235px 190px; animation-delay: .8s; }
    .sutol-tar-19-link:nth-child(4) { transform-origin: 270px 190px; animation-delay: 1.2s; }
    .sutol-tar-19-bird { animation: sutol-tar-19-fly 7s ease-in-out infinite; transform-origin: 200px 190px; }
    @keyframes sutol-tar-19-drift {
      0%, 15% { transform: translateY(0) rotate(0deg); opacity: .9; }
      70%, 100% { transform: translateY(-30px) rotate(20deg); opacity: .15; }
    }
    @keyframes sutol-tar-19-fly {
      0%, 30% { transform: translateY(20px); opacity: 0; }
      75%, 100% { transform: translateY(-60px); opacity: .9; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-19-link, .sutol-tar-19-bird { animation: none; }
      .sutol-tar-19-link { opacity: .5; }
      .sutol-tar-19-bird { opacity: .8; transform: translateY(-20px); }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <g fill="none" stroke="#6b6b6b" stroke-width="6">
      <ellipse class="sutol-tar-19-link" cx="130" cy="190" rx="14" ry="19"/>
      <ellipse class="sutol-tar-19-link" cx="165" cy="190" rx="14" ry="19"/>
      <ellipse class="sutol-tar-19-link" cx="235" cy="190" rx="14" ry="19"/>
      <ellipse class="sutol-tar-19-link" cx="270" cy="190" rx="14" ry="19"/>
    </g>
    <path class="sutol-tar-19-bird" d="M200,190 Q185,178 170,182 Q188,186 194,192 Q170,192 160,200 Q188,198 200,190 Q212,198 240,200 Q230,192 206,192 Q212,186 230,182 Q215,178 200,190 Z" fill="#4a7a8c"/>
  </svg>
</div>
```

---

## Bileşen 20: Direniş Meşalesi

**Etiketler (keyword eşleşmesi için):** direniş hareketi, mücadele, kararlılık, meşale
**Kategori:** Tarih
**Açıklama:** Yükselen bir yumruk sembolünün etrafında yayılan nabız halkaları ve yanında titreşen bir meşale alevinin kararlılığı ve direnişi anlattığı sade, geometrik bir animasyon.

```html
<div class="sutol-tar-20-root">
  <style>
    .sutol-tar-20-root { width:100%; height:100%; position:relative; }
    .sutol-tar-20-root svg { width:100%; height:100%; display:block; }
    .sutol-tar-20-fist { animation: sutol-tar-20-rise 3.2s ease-in-out infinite; transform-origin: 180px 200px; }
    .sutol-tar-20-pulse { animation: sutol-tar-20-ring 3.2s ease-out infinite; transform-origin: 180px 170px; }
    .sutol-tar-20-flame { animation: sutol-tar-20-flicker 1.4s ease-in-out infinite; transform-origin: 280px 160px; }
    @keyframes sutol-tar-20-rise {
      0%, 100% { transform: translateY(0); }
      50% { transform: translateY(-8px); }
    }
    @keyframes sutol-tar-20-ring {
      0% { transform: scale(.6); opacity: .6; }
      100% { transform: scale(1.6); opacity: 0; }
    }
    @keyframes sutol-tar-20-flicker {
      0%, 100% { transform: scaleY(1) scaleX(1); }
      50% { transform: scaleY(1.12) scaleX(.92); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tar-20-fist, .sutol-tar-20-pulse, .sutol-tar-20-flame { animation: none; opacity: .85; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <circle class="sutol-tar-20-pulse" cx="180" cy="170" r="40" fill="none" stroke="#c1440e" stroke-width="3"/>
    <g class="sutol-tar-20-fist" fill="#3d3d3d">
      <rect x="165" y="150" width="30" height="34" rx="8"/>
      <rect x="158" y="160" width="10" height="20" rx="4"/>
      <rect x="192" y="160" width="10" height="20" rx="4"/>
      <rect x="172" y="184" width="16" height="22" rx="4"/>
    </g>
    <rect x="276" y="170" width="8" height="55" fill="#8b5a2b"/>
    <g class="sutol-tar-20-flame" transform="translate(280,160)">
      <path d="M0,-18 C9,-7 9,5 0,12 C-9,5 -9,-7 0,-18 Z" fill="#f2a20c"/>
      <path d="M0,-9 C4,-2 4,5 0,8 C-4,5 -4,-2 0,-9 Z" fill="#ffe08a"/>
    </g>
  </svg>
</div>
```

---

## Kalite Kontrol Özeti

- **Bileşen 1 (Feodal Piramit):** CSS keyframe opacity/transform, gecikmeli sıralı katman animasyonu — performans notu yok, hafif.
- **Bileşen 2 (Haçlı Sefer Rotası):** SVG `offset-path` ile yol boyunca hareket + `stroke-dasharray` rota çizgisi — modern tarayıcı desteği gerektirir, performans hafif.
- **Bileşen 3 (Reform Işığı):** CSS `skewY`/`scaleX` dönüşümleriyle kapı açılışı — sade, GPU dostu.
- **Bileşen 4 (Yeni Kıyı):** CSS transform tabanlı gemi hareketi + dalga path animasyonu — hafif, sorunsuz.
- **Bileşen 5 (Soğuk Savaş Dengesi):** Basit `scale` pulse animasyonu, çok hafif.
- **Bileşen 6 (Demir Perde):** CSS değişkenleriyle (`--sutol-shift`) çubuk bazlı sway animasyonu — hafif.
- **Bileşen 7 (Silahlanma Yarışı):** Canvas + `requestAnimationFrame` tabanlı JS animasyonu, `prefers-reduced-motion` içinde rAF döngüsü durduruluyor — orta düzey CPU kullanımı, optimize edilmiş çizim.
- **Bileşen 8 (Kırılan Zincir):** CSS transform tabanlı zincir ayrışması + bayrak yükselişi — hafif.
- **Bileşen 9 (Dalgalanan Bayrak):** `perspective` + `skewY` ile kumaş dalgalanma efekti — hafif, GPU dostu.
- **Bileşen 10 (Aydınlanmanın Işığı):** Çoklu gecikmeli `opacity`/`translateY` kıvılcım animasyonu — hafif.
- **Bileşen 11 (Tarımın Uyanışı):** `rotate` tabanlı değirmen ve başak sway animasyonu — hafif.
- **Bileşen 12 (Kervan Yolu):** SVG `offset-path` ile üç deve, negatif `animation-delay` ile aralıklı — hafif-orta.
- **Bileşen 13 (Yazının Doğuşu):** `stroke-dasharray/dashoffset` ile "yazma" efekti, sıralı gecikmeler — hafif.
- **Bileşen 14 (Matbaanın Baskısı):** `translateY` stamp animasyonu + `opacity` satır belirme — hafif.
- **Bileşen 15 (İmparatorluk Yankısı):** `scale`/`opacity` genişleyen halka animasyonu, üç kademeli gecikme — hafif.
- **Bileşen 16 (Göçebe Rota):** SVG `offset-path` nokta hareketi + `stroke-dashoffset` kervan izi — hafif.
- **Bileşen 17 (Şehir Devletinin Surları):** `skewY` kapı açılışı + bayrak sallanma — hafif.
- **Bileşen 18 (Teokratik Ziggurat):** `scale`/`opacity` pulse güneş sembolü — hafif.
- **Bileşen 19 (Kırılan Halkalar):** Gecikmeli `translateY`/`rotate`/`opacity` ile zincir dağılması ve kuş yükselişi — sembolik, figüratif insan tasviri içermez, hafif.
- **Bileşen 20 (Direniş Meşalesi):** `scale` pulse halkası + geometrik yumruk ikonuyla `translateY` + alev `scaleY/scaleX` titreşimi — soyut/geometrik, hafif.

Tüm bileşenler `prefers-reduced-motion: reduce` sorgusunu destekler, global CSS seçici kullanmaz, sabit metin içermez ve iframe/sandbox ortamında dış kaynak gerektirmeden çalışacak şekilde tasarlanmıştır.
