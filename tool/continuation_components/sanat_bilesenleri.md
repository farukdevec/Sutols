# Sutol — Sanat Kategorisi Animasyonlu Bileşenler (20 Adet)

Aşağıda "Sanat" kategorisi için üretilmiş 20 adet bağımsız, şeffaf arka planlı, sandbox-uyumlu animasyonlu HTML bileşeni yer almaktadır. Her bileşen tek başına `<div>` kökü içinde çalışacak şekilde tasarlanmıştır; dış kaynak, font veya API kullanılmamıştır.

---

## Bileşen 1: Performans Anı

**Etiketler (keyword eşleşmesi için):** performans sanatı, beden, canlı gösteri, tekrar
**Kategori:** Sanat
**Açıklama:** Bir spot ışığı altında dairesel hareketle tekrar eden soyut bir figürün, performans sanatının anlık ve bedensel doğasını anlattığı bir animasyon.

```html
<div class="sutol-art-01-root">
  <style>
    .sutol-art-01-root { width:100%; height:100%; position:relative; }
    .sutol-art-01-root svg { width:100%; height:100%; display:block; }
    .sutol-art-01-figure { animation: sutol-art-01-move 4s ease-in-out infinite; transform-origin: 200px 200px; }
    .sutol-art-01-spot { animation: sutol-art-01-pulse 4s ease-in-out infinite; transform-origin: 200px 150px; }
    @keyframes sutol-art-01-move {
      0%, 100% { transform: translateX(-30px) rotate(-6deg); }
      50% { transform: translateX(30px) rotate(6deg); }
    }
    @keyframes sutol-art-01-pulse {
      0%, 100% { opacity: .35; transform: scale(1); }
      50% { opacity: .6; transform: scale(1.1); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-01-figure, .sutol-art-01-spot { animation: none; opacity: .8; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <ellipse class="sutol-art-01-spot" cx="200" cy="150" rx="90" ry="120" fill="#f2c14e"/>
    <g class="sutol-art-01-figure" fill="#3d3d3d">
      <circle cx="200" cy="150" r="14"/>
      <rect x="192" y="164" width="16" height="55" rx="6"/>
      <rect x="178" y="220" width="14" height="40" rx="5"/>
      <rect x="208" y="220" width="14" height="40" rx="5"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 2: Asılı Formlar

**Etiketler (keyword eşleşmesi için):** enstalasyon sanatı, mekan, asılı obje, üç boyutlu düzenleme
**Kategori:** Sanat
**Açıklama:** Bir mekanda farklı yüksekliklerde asılı duran geometrik formların hafifçe salınarak mekansal bir düzenleme oluşturduğu bir enstalasyon animasyonu.

```html
<div class="sutol-art-02-root">
  <style>
    .sutol-art-02-root { width:100%; height:100%; position:relative; }
    .sutol-art-02-root svg { width:100%; height:100%; display:block; }
    .sutol-art-02-shape { animation: sutol-art-02-sway 5s ease-in-out infinite; transform-origin: top center; }
    .sutol-art-02-shape:nth-child(2) { animation-delay: .6s; }
    .sutol-art-02-shape:nth-child(3) { animation-delay: 1.2s; }
    @keyframes sutol-art-02-sway {
      0%, 100% { transform: rotate(-4deg); }
      50% { transform: rotate(4deg); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-02-shape { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-art-02-shape" transform="translate(140,60)">
      <line x1="0" y1="0" x2="0" y2="50" stroke="#8a8a8a" stroke-width="1"/>
      <polygon points="-18,50 18,50 0,90" fill="#c1440e"/>
    </g>
    <g class="sutol-art-02-shape" transform="translate(220,40)">
      <line x1="0" y1="0" x2="0" y2="70" stroke="#8a8a8a" stroke-width="1"/>
      <circle cx="0" cy="90" r="18" fill="#2e5fa3"/>
    </g>
    <g class="sutol-art-02-shape" transform="translate(280,55)">
      <line x1="0" y1="0" x2="0" y2="40" stroke="#8a8a8a" stroke-width="1"/>
      <rect x="-16" y="40" width="32" height="32" fill="#e0b84b"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 3: Piksel Akışı

**Etiketler (keyword eşleşmesi için):** dijital sanat, piksel, kod, glitch
**Kategori:** Sanat
**Açıklama:** Renkli bir piksel ızgarasının rastgele hücreleri değiştirerek sürekli dönüştüğü, dijital yaratım sürecini simgeleyen bir grid animasyonu.

```html
<div class="sutol-art-03-root">
  <style>
    .sutol-art-03-root { width:100%; height:100%; position:relative; }
    .sutol-art-03-root svg { width:100%; height:100%; display:block; }
    .sutol-art-03-cell { animation: sutol-art-03-flicker 3s ease-in-out infinite; }
    @keyframes sutol-art-03-flicker {
      0%, 40%, 100% { opacity: .3; }
      20% { opacity: 1; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-03-cell { animation: none; opacity: .65; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <rect class="sutol-art-03-cell" x="130" y="90" width="24" height="24" fill="#c1440e" style="animation-delay:.0s"/>
    <rect class="sutol-art-03-cell" x="156" y="90" width="24" height="24" fill="#2e5fa3" style="animation-delay:.3s"/>
    <rect class="sutol-art-03-cell" x="182" y="90" width="24" height="24" fill="#e0b84b" style="animation-delay:.6s"/>
    <rect class="sutol-art-03-cell" x="208" y="90" width="24" height="24" fill="#7a9b3e" style="animation-delay:.9s"/>
    <rect class="sutol-art-03-cell" x="234" y="90" width="24" height="24" fill="#a24ba2" style="animation-delay:1.2s"/>
    <rect class="sutol-art-03-cell" x="130" y="116" width="24" height="24" fill="#e0b84b" style="animation-delay:.4s"/>
    <rect class="sutol-art-03-cell" x="156" y="116" width="24" height="24" fill="#c1440e" style="animation-delay:.8s"/>
    <rect class="sutol-art-03-cell" x="182" y="116" width="24" height="24" fill="#2e5fa3" style="animation-delay:1.1s"/>
    <rect class="sutol-art-03-cell" x="208" y="116" width="24" height="24" fill="#a24ba2" style="animation-delay:.2s"/>
    <rect class="sutol-art-03-cell" x="234" y="116" width="24" height="24" fill="#7a9b3e" style="animation-delay:1.6s"/>
    <rect class="sutol-art-03-cell" x="130" y="142" width="24" height="24" fill="#7a9b3e" style="animation-delay:1.4s"/>
    <rect class="sutol-art-03-cell" x="156" y="142" width="24" height="24" fill="#a24ba2" style="animation-delay:.5s"/>
    <rect class="sutol-art-03-cell" x="182" y="142" width="24" height="24" fill="#c1440e" style="animation-delay:1.9s"/>
    <rect class="sutol-art-03-cell" x="208" y="142" width="24" height="24" fill="#e0b84b" style="animation-delay:.7s"/>
    <rect class="sutol-art-03-cell" x="234" y="142" width="24" height="24" fill="#2e5fa3" style="animation-delay:2.1s"/>
  </svg>
</div>
```

---

## Bileşen 4: Duvar Şablonu

**Etiketler (keyword eşleşmesi için):** sokak sanatı, sprey, şablon, grafiti
**Kategori:** Sanat
**Açıklama:** Bir duvar üzerinde şablon aracılığıyla sprey boyanın sıçrayarak bir siluet oluşturduğu, damlaların yavaşça aşağı süzüldüğü bir sokak sanatı animasyonu.

```html
<div class="sutol-art-04-root">
  <style>
    .sutol-art-04-root { width:100%; height:100%; position:relative; }
    .sutol-art-04-root svg { width:100%; height:100%; display:block; }
    .sutol-art-04-shape { animation: sutol-art-04-spray 5s ease-in-out infinite; transform-origin: 200px 150px; }
    .sutol-art-04-drip { animation: sutol-art-04-drip 5s ease-in infinite; }
    @keyframes sutol-art-04-spray {
      0%, 15% { opacity: 0; transform: scale(.7); }
      35%, 100% { opacity: 1; transform: scale(1); }
    }
    @keyframes sutol-art-04-drip {
      0%, 40% { transform: scaleY(0); opacity: 0; }
      55% { opacity: .7; }
      100% { transform: scaleY(1); opacity: .4; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-04-shape, .sutol-art-04-drip { animation: none; opacity: .8; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-art-04-shape" transform="translate(200,150)">
      <path d="M-50,40 C-50,-10 -20,-40 0,-40 C20,-40 50,-10 50,40 Z" fill="#c1440e"/>
      <circle cx="-18" cy="0" r="6" fill="#0d0d0d"/>
      <circle cx="18" cy="0" r="6" fill="#0d0d0d"/>
    </g>
    <line class="sutol-art-04-drip" x1="150" y1="190" x2="150" y2="230" stroke="#c1440e" stroke-width="3" style="transform-origin:150px 190px;"/>
    <line class="sutol-art-04-drip" x1="250" y1="190" x2="250" y2="215" stroke="#c1440e" stroke-width="3" style="transform-origin:250px 190px; animation-delay:.5s;"/>
  </svg>
</div>
```

---

## Bileşen 5: Toprak Spirali

**Etiketler (keyword eşleşmesi için):** land art, doğa, spiral, manzara müdahalesi
**Kategori:** Sanat
**Açıklama:** Bir arazi üzerine yerleştirilmiş taşlardan oluşan spiral bir desenin yavaşça çizilerek belirdiği, doğayla iç içe büyük ölçekli sanatı anlatan bir animasyon.

```html
<div class="sutol-art-05-root">
  <style>
    .sutol-art-05-root { width:100%; height:100%; position:relative; }
    .sutol-art-05-root svg { width:100%; height:100%; display:block; }
    .sutol-art-05-path { stroke-dasharray: 500; stroke-dashoffset: 500; animation: sutol-art-05-draw 6s ease-in-out infinite; }
    @keyframes sutol-art-05-draw {
      0%, 10% { stroke-dashoffset: 500; }
      70%, 100% { stroke-dashoffset: 0; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-05-path { animation: none; stroke-dashoffset: 0; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <ellipse cx="200" cy="180" rx="150" ry="60" fill="#c9a15a" opacity=".3"/>
    <path class="sutol-art-05-path" d="M200,150 m0,0 a10,10 0 1,1 -0.1,0 a25,25 0 1,1 0.2,0 a45,45 0 1,1 -0.3,0 a65,65 0 1,1 0.4,0" fill="none" stroke="#5b4636" stroke-width="6" stroke-linecap="round"/>
  </svg>
</div>
```

---

## Bileşen 6: Dengeli Mobil

**Etiketler (keyword eşleşmesi için):** kinetik sanat, hareket, denge, mobil heykel
**Kategori:** Sanat
**Açıklama:** Birbirine bağlı geometrik parçaların farklı hızlarda dönerek sürekli bir denge kurduğu, hareketin kendisinin sanat eseri olduğu bir kinetik heykel animasyonu.

```html
<div class="sutol-art-06-root">
  <style>
    .sutol-art-06-root { width:100%; height:100%; position:relative; }
    .sutol-art-06-root svg { width:100%; height:100%; display:block; }
    .sutol-art-06-armA { animation: sutol-art-06-spinA 6s linear infinite; transform-origin: 200px 130px; }
    .sutol-art-06-armB { animation: sutol-art-06-spinB 4s linear infinite; transform-origin: 150px 170px; }
    @keyframes sutol-art-06-spinA { to { transform: rotate(360deg); } }
    @keyframes sutol-art-06-spinB { to { transform: rotate(-360deg); } }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-06-armA, .sutol-art-06-armB { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <line x1="200" y1="60" x2="200" y2="130" stroke="#8a8a8a" stroke-width="2"/>
    <g class="sutol-art-06-armA">
      <line x1="150" y1="130" x2="250" y2="130" stroke="#8a8a8a" stroke-width="2"/>
      <circle cx="250" cy="130" r="10" fill="#c1440e"/>
      <g class="sutol-art-06-armB" transform="translate(0,0)">
        <line x1="150" y1="130" x2="150" y2="170" stroke="#8a8a8a" stroke-width="2"/>
        <line x1="115" y1="170" x2="185" y2="170" stroke="#8a8a8a" stroke-width="2"/>
        <circle cx="115" cy="170" r="8" fill="#2e5fa3"/>
        <circle cx="185" cy="170" r="8" fill="#e0b84b"/>
      </g>
    </g>
  </svg>
</div>
```

---

## Bileşen 7: Pop Nokta Deseni

**Etiketler (keyword eşleşmesi için):** pop art, benday noktaları, canlı renk, popüler kültür
**Kategori:** Sanat
**Açıklama:** Canlı renkli benday noktalarından oluşan bir desenin nabız gibi büyüyüp küçülerek pop art'ın enerjik ve tekrar eden estetiğini anlattığı bir animasyon.

```html
<div class="sutol-art-07-root">
  <style>
    .sutol-art-07-root { width:100%; height:100%; position:relative; }
    .sutol-art-07-root svg { width:100%; height:100%; display:block; }
    .sutol-art-07-dot { animation: sutol-art-07-pulse 2.2s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
    @keyframes sutol-art-07-pulse {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.35); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-07-dot { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <g>
      <circle class="sutol-art-07-dot" cx="140" cy="110" r="14" fill="#c1440e" style="animation-delay:0s"/>
      <circle class="sutol-art-07-dot" cx="180" cy="110" r="14" fill="#2e5fa3" style="animation-delay:.15s"/>
      <circle class="sutol-art-07-dot" cx="220" cy="110" r="14" fill="#e0b84b" style="animation-delay:.3s"/>
      <circle class="sutol-art-07-dot" cx="260" cy="110" r="14" fill="#c1440e" style="animation-delay:.45s"/>
      <circle class="sutol-art-07-dot" cx="160" cy="150" r="14" fill="#e0b84b" style="animation-delay:.6s"/>
      <circle class="sutol-art-07-dot" cx="200" cy="150" r="14" fill="#2e5fa3" style="animation-delay:.75s"/>
      <circle class="sutol-art-07-dot" cx="240" cy="150" r="14" fill="#c1440e" style="animation-delay:.9s"/>
      <circle class="sutol-art-07-dot" cx="140" cy="190" r="14" fill="#2e5fa3" style="animation-delay:1.05s"/>
      <circle class="sutol-art-07-dot" cx="180" cy="190" r="14" fill="#c1440e" style="animation-delay:1.2s"/>
      <circle class="sutol-art-07-dot" cx="220" cy="190" r="14" fill="#e0b84b" style="animation-delay:1.35s"/>
      <circle class="sutol-art-07-dot" cx="260" cy="190" r="14" fill="#2e5fa3" style="animation-delay:1.5s"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 8: Dada Kolajı

**Etiketler (keyword eşleşmesi için):** dadaizm, kolaj, tesadüf, anti-sanat
**Kategori:** Sanat
**Açıklama:** Rastgele kesilmiş kağıt parçalarının sürekli yer değiştirip yeniden düzenlendiği, mantık dışı ve tesadüfi kompozisyonuyla dadaist ruhu yansıtan bir kolaj animasyonu.

```html
<div class="sutol-art-08-root">
  <style>
    .sutol-art-08-root { width:100%; height:100%; position:relative; }
    .sutol-art-08-root svg { width:100%; height:100%; display:block; }
    .sutol-art-08-piece { animation: sutol-art-08-shift 6s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
    @keyframes sutol-art-08-shift {
      0%, 100% { transform: translate(0,0) rotate(0deg); }
      25% { transform: translate(10px,-6px) rotate(8deg); }
      50% { transform: translate(-8px,4px) rotate(-6deg); }
      75% { transform: translate(4px,8px) rotate(4deg); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-08-piece { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <rect class="sutol-art-08-piece" x="130" y="100" width="60" height="40" fill="#e8d9b5" transform="rotate(-8 160 120)" style="animation-delay:0s"/>
    <rect class="sutol-art-08-piece" x="200" y="90" width="45" height="70" fill="#c1440e" transform="rotate(6 222 125)" style="animation-delay:.4s"/>
    <circle class="sutol-art-08-piece" cx="180" cy="180" r="26" fill="#2e5fa3" style="animation-delay:.8s"/>
    <polygon class="sutol-art-08-piece" points="250,170 280,210 220,210" fill="#e0b84b" style="animation-delay:1.2s"/>
    <rect class="sutol-art-08-piece" x="150" y="200" width="30" height="30" fill="#3d3d3d" transform="rotate(20 165 215)" style="animation-delay:1.6s"/>
  </svg>
</div>
```

---

## Bileşen 9: Duygu Girdabı

**Etiketler (keyword eşleşmesi için):** ekspresyonizm, duygu, fırça darbesi, iç dünya
**Kategori:** Sanat
**Açıklama:** Birbirine dolanan yoğun renkli eğri çizgilerin sürekli dalgalandığı, ekspresyonizmin ham duygusal yoğunluğunu anlatan soyut bir fırça darbesi animasyonu.

```html
<div class="sutol-art-09-root">
  <style>
    .sutol-art-09-root { width:100%; height:100%; position:relative; }
    .sutol-art-09-root svg { width:100%; height:100%; display:block; }
    .sutol-art-09-line { stroke-dasharray: 300; animation: sutol-art-09-flow 5s ease-in-out infinite; }
    @keyframes sutol-art-09-flow {
      0%, 100% { stroke-dashoffset: 0; }
      50% { stroke-dashoffset: 120; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-09-line { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-art-09-line" d="M60,180 Q120,80 200,150 Q280,220 340,100" fill="none" stroke="#c1440e" stroke-width="6" stroke-linecap="round"/>
    <path class="sutol-art-09-line" d="M60,140 Q140,220 220,110 Q290,40 340,160" fill="none" stroke="#2e5fa3" stroke-width="5" stroke-linecap="round" style="animation-delay:.4s"/>
    <path class="sutol-art-09-line" d="M80,220 Q160,140 240,200 Q300,240 350,180" fill="none" stroke="#e0b84b" stroke-width="4" stroke-linecap="round" style="animation-delay:.8s"/>
  </svg>
</div>
```

---

## Bileşen 10: Tek Çizgi

**Etiketler (keyword eşleşmesi için):** minimalizm, sadelik, boşluk, form
**Kategori:** Sanat
**Açıklama:** Boş bir zemin üzerinde yavaşça nefes alıp veren tek bir geometrik formun, minimalizmin "az çoktur" ilkesini anlattığı son derece sade bir animasyon.

```html
<div class="sutol-art-10-root">
  <style>
    .sutol-art-10-root { width:100%; height:100%; position:relative; }
    .sutol-art-10-root svg { width:100%; height:100%; display:block; }
    .sutol-art-10-square { animation: sutol-art-10-breathe 4s ease-in-out infinite; transform-origin: 200px 150px; }
    @keyframes sutol-art-10-breathe {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.06); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-10-square { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <rect class="sutol-art-10-square" x="150" y="100" width="100" height="100" fill="#3d3d3d"/>
  </svg>
</div>
```

---

## Bileşen 11: Organik Sarmaşık

**Etiketler (keyword eşleşmesi için):** art nouveau, organik form, sarmaşık, süsleme
**Kategori:** Sanat
**Açıklama:** Kıvrılarak büyüyen organik bir sarmaşık çizgisinin uçlarında çiçek formlarının belirdiği, art nouveau'nun doğadan ilham alan akıcı çizgilerini anlatan bir animasyon.

```html
<div class="sutol-art-11-root">
  <style>
    .sutol-art-11-root { width:100%; height:100%; position:relative; }
    .sutol-art-11-root svg { width:100%; height:100%; display:block; }
    .sutol-art-11-vine { stroke-dasharray: 260; stroke-dashoffset: 260; animation: sutol-art-11-grow 6s ease-in-out infinite; }
    .sutol-art-11-flower { animation: sutol-art-11-bloom 6s ease-in-out infinite; transform-origin: center; transform-box: fill-box; }
    @keyframes sutol-art-11-grow {
      0%, 10% { stroke-dashoffset: 260; }
      70%, 100% { stroke-dashoffset: 0; }
    }
    @keyframes sutol-art-11-bloom {
      0%, 60% { opacity: 0; transform: scale(.3); }
      85%, 100% { opacity: 1; transform: scale(1); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-11-vine { animation: none; stroke-dashoffset: 0; }
      .sutol-art-11-flower { animation: none; opacity: .9; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-art-11-vine" d="M80,240 C120,200 100,160 140,140 C180,120 160,80 210,70 C260,60 250,100 300,90" fill="none" stroke="#7a9b3e" stroke-width="4" stroke-linecap="round"/>
    <circle class="sutol-art-11-flower" cx="140" cy="140" r="10" fill="#c1440e"/>
    <circle class="sutol-art-11-flower" cx="210" cy="70" r="10" fill="#e0b84b"/>
    <circle class="sutol-art-11-flower" cx="300" cy="90" r="10" fill="#a24ba2"/>
  </svg>
</div>
```

---

## Bileşen 12: Barok Işık Oyunu

**Etiketler (keyword eşleşmesi için):** barok, dramatik ışık, altın süsleme, ihtişam
**Kategori:** Sanat
**Açıklama:** Altın rengi kıvrımlı bir çerçevenin ortasından yayılan dramatik ışık huzmelerinin nabız gibi parladığı, barok sanatının görkemini anlatan bir animasyon.

```html
<div class="sutol-art-12-root">
  <style>
    .sutol-art-12-root { width:100%; height:100%; position:relative; }
    .sutol-art-12-root svg { width:100%; height:100%; display:block; }
    .sutol-art-12-ray { animation: sutol-art-12-glow 3s ease-in-out infinite; transform-origin: 200px 150px; }
    .sutol-art-12-frame { animation: sutol-art-12-shimmer 4s ease-in-out infinite; }
    @keyframes sutol-art-12-glow {
      0%, 100% { opacity: .25; transform: scale(1) rotate(0deg); }
      50% { opacity: .55; transform: scale(1.08) rotate(3deg); }
    }
    @keyframes sutol-art-12-shimmer {
      0%, 100% { opacity: .8; }
      50% { opacity: 1; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-12-ray, .sutol-art-12-frame { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-art-12-ray" stroke="#f2c14e" stroke-width="3">
      <line x1="200" y1="150" x2="200" y2="60"/>
      <line x1="200" y1="150" x2="270" y2="90"/>
      <line x1="200" y1="150" x2="300" y2="150"/>
      <line x1="200" y1="150" x2="270" y2="210"/>
      <line x1="200" y1="150" x2="200" y2="240"/>
      <line x1="200" y1="150" x2="130" y2="210"/>
      <line x1="200" y1="150" x2="100" y2="150"/>
      <line x1="200" y1="150" x2="130" y2="90"/>
    </g>
    <ellipse class="sutol-art-12-frame" cx="200" cy="150" rx="55" ry="70" fill="none" stroke="#c9a15a" stroke-width="8"/>
  </svg>
</div>
```

---

## Bileşen 13: Gotik Pencere

**Etiketler (keyword eşleşmesi için):** gotik sanat, sivri kemer, vitray, katedral
**Kategori:** Sanat
**Açıklama:** Sivri kemerli bir gotik pencerenin içindeki renkli vitray parçalarının sırayla ışıldayarak katedral atmosferini yansıttığı bir animasyon.

```html
<div class="sutol-art-13-root">
  <style>
    .sutol-art-13-root { width:100%; height:100%; position:relative; }
    .sutol-art-13-root svg { width:100%; height:100%; display:block; }
    .sutol-art-13-glass { animation: sutol-art-13-glow 4s ease-in-out infinite; }
    @keyframes sutol-art-13-glow {
      0%, 60%, 100% { opacity: .5; }
      30% { opacity: 1; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-13-glass { animation: none; opacity: .8; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <path d="M150,240 L150,140 Q200,70 250,140 L250,240 Z" fill="#2e2016"/>
    <g clip-path="url(#sutol-art-13-clip)">
      <rect class="sutol-art-13-glass" x="150" y="150" width="34" height="45" fill="#c1440e" style="animation-delay:0s"/>
      <rect class="sutol-art-13-glass" x="184" y="150" width="32" height="45" fill="#2e5fa3" style="animation-delay:.4s"/>
      <rect class="sutol-art-13-glass" x="216" y="150" width="34" height="45" fill="#e0b84b" style="animation-delay:.8s"/>
      <rect class="sutol-art-13-glass" x="150" y="195" width="50" height="40" fill="#7a9b3e" style="animation-delay:1.2s"/>
      <rect class="sutol-art-13-glass" x="200" y="195" width="50" height="40" fill="#a24ba2" style="animation-delay:1.6s"/>
      <circle class="sutol-art-13-glass" cx="200" cy="120" r="20" fill="#e0b84b" style="animation-delay:2s"/>
    </g>
    <defs>
      <clipPath id="sutol-art-13-clip">
        <path d="M150,240 L150,140 Q200,70 250,140 L250,240 Z"/>
      </clipPath>
    </defs>
    <path d="M150,240 L150,140 Q200,70 250,140 L250,240 Z" fill="none" stroke="#4a3728" stroke-width="6"/>
  </svg>
</div>
```

---

## Bileşen 14: Fresk Katmanları

**Etiketler (keyword eşleşmesi için):** fresk tekniği, sıva, pigment, duvar resmi
**Kategori:** Sanat
**Açıklama:** Islak sıva üzerine sürülen pigment fırça darbelerinin katman katman belirerek bir duvar freskini oluşturduğu bir yaratım animasyonu.

```html
<div class="sutol-art-14-root">
  <style>
    .sutol-art-14-root { width:100%; height:100%; position:relative; }
    .sutol-art-14-root svg { width:100%; height:100%; display:block; }
    .sutol-art-14-stroke { stroke-dasharray: 120; stroke-dashoffset: 120; animation: sutol-art-14-paint 5s ease-in-out infinite; }
    @keyframes sutol-art-14-paint {
      0%, 10% { stroke-dashoffset: 120; }
      60%, 100% { stroke-dashoffset: 0; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-14-stroke { animation: none; stroke-dashoffset: 0; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <rect x="120" y="90" width="160" height="120" fill="#e8d9b5"/>
    <path class="sutol-art-14-stroke" d="M140,180 Q200,120 260,180" fill="none" stroke="#4a7a8c" stroke-width="10" stroke-linecap="round"/>
    <path class="sutol-art-14-stroke" d="M150,150 Q200,190 250,150" fill="none" stroke="#c1440e" stroke-width="8" stroke-linecap="round" style="animation-delay:.6s"/>
    <path class="sutol-art-14-stroke" d="M160,200 Q200,160 240,200" fill="none" stroke="#e0b84b" stroke-width="6" stroke-linecap="round" style="animation-delay:1.2s"/>
  </svg>
</div>
```

---

## Bileşen 15: Gravür Çizgileri

**Etiketler (keyword eşleşmesi için):** gravür baskı, çapraz tarama, baskı plakası, çoğaltma
**Kategori:** Sanat
**Açıklama:** Bir metal plaka üzerine kazınan ince çapraz tarama çizgilerinin sırayla belirerek gölgeli bir doku oluşturduğu bir gravür baskı animasyonu.

```html
<div class="sutol-art-15-root">
  <style>
    .sutol-art-15-root { width:100%; height:100%; position:relative; }
    .sutol-art-15-root svg { width:100%; height:100%; display:block; }
    .sutol-art-15-line { stroke-dasharray: 40; stroke-dashoffset: 40; animation: sutol-art-15-etch 4s ease-in-out infinite; }
    @keyframes sutol-art-15-etch {
      0%, 5% { stroke-dashoffset: 40; opacity: .3; }
      50%, 100% { stroke-dashoffset: 0; opacity: 1; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-15-line { animation: none; stroke-dashoffset: 0; opacity: .8; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <rect x="130" y="90" width="140" height="120" fill="#d8d0c0"/>
    <g stroke="#3d3d3d" stroke-width="1.5">
      <line class="sutol-art-15-line" x1="140" y1="100" x2="180" y2="140" style="animation-delay:0s"/>
      <line class="sutol-art-15-line" x1="160" y1="100" x2="200" y2="140" style="animation-delay:.15s"/>
      <line class="sutol-art-15-line" x1="180" y1="100" x2="220" y2="140" style="animation-delay:.3s"/>
      <line class="sutol-art-15-line" x1="200" y1="100" x2="240" y2="140" style="animation-delay:.45s"/>
      <line class="sutol-art-15-line" x1="180" y1="140" x2="140" y2="180" style="animation-delay:.6s"/>
      <line class="sutol-art-15-line" x1="200" y1="140" x2="160" y2="180" style="animation-delay:.75s"/>
      <line class="sutol-art-15-line" x1="220" y1="140" x2="180" y2="180" style="animation-delay:.9s"/>
      <line class="sutol-art-15-line" x1="240" y1="140" x2="200" y2="180" style="animation-delay:1.05s"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 16: Erimiş Bronz

**Etiketler (keyword eşleşmesi için):** bronz döküm, erimiş metal, kalıp, heykel üretimi
**Kategori:** Sanat
**Açıklama:** Turuncu parlak erimiş bronzun bir kalıba akarak yavaşça katılaşıp bir heykel formuna dönüştüğü, canvas üzerinde çizilen bir döküm animasyonu.

```html
<div class="sutol-art-16-root">
  <style>
    .sutol-art-16-root { width:100%; height:100%; position:relative; }
    .sutol-art-16-root canvas { width:100%; height:100%; display:block; }
  </style>
  <canvas class="sutol-art-16-canvas" width="400" height="300"></canvas>
  <script>
    (function(){
      var root = document.currentScript.closest('.sutol-art-16-root');
      var canvas = root.querySelector('.sutol-art-16-canvas');
      var ctx = canvas.getContext('2d');
      var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      var t0 = null;
      function draw(ts){
        if (t0 === null) t0 = ts;
        var t = reduced ? 0.5 : ((ts - t0) / 1000) % 5 / 5;
        ctx.clearRect(0,0,400,300);
        ctx.fillStyle = '#6b6b6b';
        ctx.beginPath();
        ctx.moveTo(160,240); ctx.lineTo(160,140); ctx.lineTo(200,110); ctx.lineTo(240,140); ctx.lineTo(240,240);
        ctx.closePath(); ctx.globalAlpha = .25; ctx.fill(); ctx.globalAlpha = 1;
        var fillLevel = Math.min(1, t * 1.6);
        var topY = 240 - fillLevel * 100;
        ctx.save();
        ctx.beginPath();
        ctx.moveTo(160,240); ctx.lineTo(160,140); ctx.lineTo(200,110); ctx.lineTo(240,140); ctx.lineTo(240,240);
        ctx.closePath(); ctx.clip();
        ctx.fillStyle = '#e0641c';
        ctx.fillRect(150, topY, 100, 250);
        ctx.restore();
        if (t < 0.6) {
          ctx.strokeStyle = '#f2a20c';
          ctx.lineWidth = 4;
          ctx.beginPath();
          ctx.moveTo(190,60); ctx.lineTo(198, topY);
          ctx.stroke();
        }
        if (!reduced) requestAnimationFrame(draw);
      }
      requestAnimationFrame(draw);
    })();
  </script>
</div>
```

---

## Bileşen 17: Mermerden Doğuş

**Etiketler (keyword eşleşmesi için):** mermer oyma, heykeltıraşlık, keski, form arama
**Kategori:** Sanat
**Açıklama:** Ham bir mermer bloğundan küçük yontma parçalarının dökülerek altından pürüzsüz bir formun ortaya çıktığı bir heykeltıraşlık animasyonu.

```html
<div class="sutol-art-17-root">
  <style>
    .sutol-art-17-root { width:100%; height:100%; position:relative; }
    .sutol-art-17-root svg { width:100%; height:100%; display:block; }
    .sutol-art-17-chip { animation: sutol-art-17-fall 3s ease-in infinite; }
    .sutol-art-17-chip:nth-child(2) { animation-delay: .5s; }
    .sutol-art-17-chip:nth-child(3) { animation-delay: 1s; }
    .sutol-art-17-chip:nth-child(4) { animation-delay: 1.5s; }
    .sutol-art-17-form { animation: sutol-art-17-reveal 3s ease-in-out infinite; }
    @keyframes sutol-art-17-fall {
      0% { transform: translate(0,0) rotate(0deg); opacity: 1; }
      100% { transform: translate(-10px,40px) rotate(60deg); opacity: 0; }
    }
    @keyframes sutol-art-17-reveal {
      0%, 100% { opacity: .85; }
      50% { opacity: 1; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-17-chip { animation: none; opacity: 0; }
      .sutol-art-17-form { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <rect x="150" y="80" width="100" height="150" fill="#e2ddd2" opacity=".3"/>
    <path class="sutol-art-17-form" d="M175,225 Q160,150 190,100 Q200,85 210,100 Q240,150 225,225 Z" fill="#e8e2d5" stroke="#c9c2b3" stroke-width="1.5"/>
    <polygon class="sutol-art-17-chip" points="150,110 165,115 155,130" fill="#d8d0c0"/>
    <polygon class="sutol-art-17-chip" points="245,140 260,148 248,158" fill="#d8d0c0"/>
    <polygon class="sutol-art-17-chip" points="155,180 170,185 158,195" fill="#d8d0c0"/>
    <polygon class="sutol-art-17-chip" points="240,190 255,198 243,205" fill="#d8d0c0"/>
  </svg>
</div>
```

---

## Bileşen 18: Sergi Duvarı

**Etiketler (keyword eşleşmesi için):** küratörlük, sergi, galeri, spot ışığı
**Kategori:** Sanat
**Açıklama:** Bir galeri duvarındaki asılı çerçevelerin üzerinde gezinen bir spot ışığının, küratöryel bakışın eserleri sırayla öne çıkardığını anlattığı bir sergi animasyonu.

```html
<div class="sutol-art-18-root">
  <style>
    .sutol-art-18-root { width:100%; height:100%; position:relative; }
    .sutol-art-18-root svg { width:100%; height:100%; display:block; }
    .sutol-art-18-spot { offset-path: path('M100,80 L200,80 L300,80'); animation: sutol-art-18-move 6s ease-in-out infinite alternate; }
    @keyframes sutol-art-18-move {
      0% { offset-distance: 0%; }
      100% { offset-distance: 100%; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-18-spot { animation: none; offset-distance: 50%; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <rect x="80" y="120" width="70" height="90" fill="none" stroke="#8b6f4e" stroke-width="6"/>
    <rect x="90" y="130" width="50" height="70" fill="#c1440e"/>
    <rect x="185" y="110" width="70" height="100" fill="none" stroke="#8b6f4e" stroke-width="6"/>
    <rect x="195" y="120" width="50" height="80" fill="#2e5fa3"/>
    <rect x="290" y="125" width="70" height="85" fill="none" stroke="#8b6f4e" stroke-width="6"/>
    <rect x="300" y="135" width="50" height="65" fill="#e0b84b"/>
    <ellipse class="sutol-art-18-spot" cx="100" cy="80" rx="45" ry="18" fill="#fff3c4" opacity=".35"/>
  </svg>
</div>
```

---

## Bileşen 19: Atölye Penceresi

**Etiketler (keyword eşleşmesi için):** sanat rezidansı, atölye, üretim süreci, ilham
**Kategori:** Sanat
**Açıklama:** Bir atölye penceresinden içeri süzülen ışığın altında duran bir şövale üzerinde tuvalin yavaşça renk kazandığı, uzun soluklu bir yaratım sürecini anlatan bir animasyon.

```html
<div class="sutol-art-19-root">
  <style>
    .sutol-art-19-root { width:100%; height:100%; position:relative; }
    .sutol-art-19-root svg { width:100%; height:100%; display:block; }
    .sutol-art-19-stroke { animation: sutol-art-19-appear 6s ease-in-out infinite; }
    .sutol-art-19-light { animation: sutol-art-19-shift 8s ease-in-out infinite; }
    @keyframes sutol-art-19-appear {
      0%, 8% { opacity: 0; }
      25%, 100% { opacity: 1; }
    }
    @keyframes sutol-art-19-shift {
      0%, 100% { opacity: .2; }
      50% { opacity: .4; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-19-stroke, .sutol-art-19-light { animation: none; opacity: .8; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <polygon class="sutol-art-19-light" points="60,40 160,40 200,220 20,220" fill="#fff3c4"/>
    <line x1="180" y1="230" x2="140" y2="90" stroke="#8b6f4e" stroke-width="5"/>
    <line x1="260" y1="230" x2="180" y2="90" stroke="#8b6f4e" stroke-width="5"/>
    <line x1="150" y1="150" x2="250" y2="150" stroke="#8b6f4e" stroke-width="5"/>
    <rect x="165" y="95" width="70" height="90" fill="#f5ecd8" stroke="#c9a15a" stroke-width="3"/>
    <path class="sutol-art-19-stroke" d="M175,160 Q200,120 225,160" fill="none" stroke="#4a7a8c" stroke-width="8" stroke-linecap="round" style="animation-delay:0s"/>
    <path class="sutol-art-19-stroke" d="M180,140 Q200,175 220,140" fill="none" stroke="#c1440e" stroke-width="6" stroke-linecap="round" style="animation-delay:1.2s"/>
  </svg>
</div>
```

---

## Bileşen 20: Renk Karışım Anı

**Etiketler (keyword eşleşmesi için):** sanat, yaratıcılık, fırça, renk paleti
**Kategori:** Sanat
**Açıklama:** Bir paletin üzerinde farklı renklerin fırça darbeleriyle karışarak dönüştüğü, sanatsal yaratımın başlangıç anını simgeleyen genel bir animasyon.

```html
<div class="sutol-art-20-root">
  <style>
    .sutol-art-20-root { width:100%; height:100%; position:relative; }
    .sutol-art-20-root svg { width:100%; height:100%; display:block; }
    .sutol-art-20-blob { animation: sutol-art-20-morph 5s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
    .sutol-art-20-brush { animation: sutol-art-20-dip 5s ease-in-out infinite; transform-origin: 210px 90px; }
    @keyframes sutol-art-20-morph {
      0%, 100% { transform: scale(1) rotate(0deg); }
      50% { transform: scale(1.1) rotate(6deg); }
    }
    @keyframes sutol-art-20-dip {
      0%, 100% { transform: translate(0,0) rotate(-20deg); }
      40% { transform: translate(-40px,60px) rotate(-45deg); }
      60% { transform: translate(-40px,60px) rotate(-45deg); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-art-20-blob, .sutol-art-20-brush { animation: none; }
    }
  </style>
  <svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
    <ellipse cx="180" cy="190" rx="90" ry="55" fill="#e8d9b5"/>
    <circle class="sutol-art-20-blob" cx="140" cy="175" r="16" fill="#c1440e"/>
    <circle class="sutol-art-20-blob" cx="180" cy="200" r="14" fill="#2e5fa3" style="animation-delay:.4s"/>
    <circle class="sutol-art-20-blob" cx="220" cy="175" r="15" fill="#e0b84b" style="animation-delay:.8s"/>
    <circle class="sutol-art-20-blob" cx="200" cy="215" r="12" fill="#7a9b3e" style="animation-delay:1.2s"/>
    <g class="sutol-art-20-brush" transform="translate(210,90)">
      <rect x="-4" y="-40" width="8" height="60" fill="#8b6f4e"/>
      <polygon points="-6,20 6,20 0,34" fill="#3d3d3d"/>
    </g>
  </svg>
</div>
```

---

## Kalite Kontrol Özeti

- **Bileşen 1 (Performans Anı):** CSS `translateX/rotate` figür hareketi + spot `opacity/scale` pulse — hafif.
- **Bileşen 2 (Asılı Formlar):** Gecikmeli `rotate` sway animasyonu, üç bağımsız obje — hafif.
- **Bileşen 3 (Piksel Akışı):** 15 hücreli grid, her biri farklı `animation-delay` ile `opacity` flicker — hafif, statik grid.
- **Bileşen 4 (Duvar Şablonu):** `scale/opacity` şablon belirişi + `scaleY` damla animasyonu — hafif.
- **Bileşen 5 (Toprak Spirali):** `stroke-dasharray/dashoffset` ile spiral çizim efekti — hafif.
- **Bileşen 6 (Dengeli Mobil):** İç içe `rotate` (saat yönü/tersi) kinetik heykel simülasyonu — hafif, GPU dostu.
- **Bileşen 7 (Pop Nokta Deseni):** 11 nokta, `fill-box` transform-origin ile bağımsız `scale` pulse — hafif.
- **Bileşen 8 (Dada Kolajı):** Çoklu `translate/rotate` ile rastgele hissi veren kolaj hareketi — hafif.
- **Bileşen 9 (Duygu Girdabı):** `stroke-dashoffset` ile "akan" fırça çizgisi hissi, üç katman — hafif.
- **Bileşen 10 (Tek Çizgi):** Tek `scale` breathing animasyonu — çok hafif.
- **Bileşen 11 (Organik Sarmaşık):** `stroke-dashoffset` çizim + gecikmeli çiçek `scale/opacity` — hafif.
- **Bileşen 12 (Barok Işık Oyunu):** `scale/rotate/opacity` ışın pulse + çerçeve shimmer — hafif.
- **Bileşen 13 (Gotik Pencere):** `clipPath` içinde sıralı `opacity` vitray parıltısı — hafif.
- **Bileşen 14 (Fresk Katmanları):** `stroke-dashoffset` ile sıralı fırça darbesi belirme — hafif.
- **Bileşen 15 (Gravür Çizgileri):** 8 çizgi, sıralı `stroke-dashoffset/opacity` çapraz tarama — hafif.
- **Bileşen 16 (Erimiş Bronz):** Canvas + `requestAnimationFrame`, `clip` ile dolum efekti — orta düzey, `reduced motion`'da rAF durduruluyor.
- **Bileşen 17 (Mermerden Doğuş):** Gecikmeli `translate/rotate/opacity` yonga düşüşü — hafif.
- **Bileşen 18 (Sergi Duvarı):** `offset-path` ile spot ışığın çerçeveler arasında gezinmesi — hafif.
- **Bileşen 19 (Atölye Penceresi):** `opacity` ışık geçişi + sıralı fırça darbesi belirme — hafif.
- **Bileşen 20 (Renk Karışım Anı):** `fill-box` transform ile renk lekesi morph + fırça daldırma hareketi — hafif.

Tüm bileşenler `prefers-reduced-motion: reduce` sorgusunu destekler, global CSS seçici kullanmaz, sabit metin içermez ve iframe/sandbox ortamında dış kaynak gerektirmeden çalışacak şekilde tasarlanmıştır.
