# Sutol — Biyoloji Kategorisi — 20 Animasyonlu Bileşen

---

## Bileşen 1: Gen İfadesi Merkezi

**Etiketler (keyword eşleşmesi için):** gen ifadesi, protein sentezi, transkripsiyon, translasyon
**Kategori:** Biyoloji
**Açıklama:** Çift sarmal DNA'dan mRNA'nın kopyalanıp ribozomda amino asit zincirine dönüştüğü döngüsel bir süreç animasyonu.

```html
<div class="sutol-bio-01-root">
  <style>
    .sutol-bio-01-root { width:100%; height:100%; position:relative; }
    .sutol-bio-01-svg { width:100%; height:100%; display:block; }
    .sutol-bio-01-strand1, .sutol-bio-01-strand2 {
      fill:none; stroke-width:3; stroke-linecap:round;
    }
    .sutol-bio-01-strand1 { stroke:#5b8bf7; }
    .sutol-bio-01-strand2 { stroke:#f76b8b; }
    .sutol-bio-01-rung { stroke:#c9d6f2; stroke-width:2; }
    .sutol-bio-01-mrna {
      fill:none; stroke:#ffb020; stroke-width:3; stroke-linecap:round;
      stroke-dasharray:6 6;
      animation: sutol-bio-01-flow 3s linear infinite;
    }
    .sutol-bio-01-ribo {
      fill:#38b28a;
      transform-origin:center;
      animation: sutol-bio-01-move 6s ease-in-out infinite;
    }
    .sutol-bio-01-bead {
      animation: sutol-bio-01-pop 6s ease-in-out infinite;
    }
    @keyframes sutol-bio-01-flow { to { stroke-dashoffset:-24; } }
    @keyframes sutol-bio-01-move { 0%{transform:translateX(0)} 50%{transform:translateX(160px)} 100%{transform:translateX(0)} }
    @keyframes sutol-bio-01-pop { 0%,20%{opacity:0} 30%{opacity:1} 100%{opacity:1} }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-01-mrna, .sutol-bio-01-ribo, .sutol-bio-01-bead { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-01-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-bio-01-strand1" d="M20,20 C40,50 0,70 20,100 C40,130 0,150 20,180"/>
    <path class="sutol-bio-01-strand2" d="M35,20 C15,50 55,70 35,100 C15,130 55,150 35,180"/>
    <g class="sutol-bio-01-rung">
      <line x1="20" y1="30" x2="35" y2="30"/>
      <line x1="16" y1="55" x2="39" y2="55"/>
      <line x1="20" y1="80" x2="35" y2="80"/>
      <line x1="16" y1="105" x2="39" y2="105"/>
      <line x1="20" y1="130" x2="35" y2="130"/>
      <line x1="16" y1="155" x2="39" y2="155"/>
    </g>
    <path class="sutol-bio-01-mrna" d="M60,100 H340"/>
    <g class="sutol-bio-01-ribo">
      <ellipse cx="80" cy="100" rx="22" ry="16"/>
      <ellipse cx="80" cy="118" rx="16" ry="10"/>
    </g>
    <g fill="#ffb020">
      <circle class="sutol-bio-01-bead" style="animation-delay:0s" cx="110" cy="150" r="6"/>
      <circle class="sutol-bio-01-bead" style="animation-delay:.6s" cx="126" cy="150" r="6"/>
      <circle class="sutol-bio-01-bead" style="animation-delay:1.2s" cx="142" cy="150" r="6"/>
      <circle class="sutol-bio-01-bead" style="animation-delay:1.8s" cx="158" cy="150" r="6"/>
      <circle class="sutol-bio-01-bead" style="animation-delay:2.4s" cx="174" cy="150" r="6"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 2: Hücre Bölünmesi — Mitoz

**Etiketler (keyword eşleşmesi için):** hücre bölünmesi, mitoz, genom
**Kategori:** Biyoloji
**Açıklama:** Tek bir hücrenin kromozomlarını ayırıp ikiye bölünerek iki özdeş yavru hücre oluşturduğu döngüsel animasyon.

```html
<div class="sutol-bio-02-root">
  <style>
    .sutol-bio-02-root { width:100%; height:100%; }
    .sutol-bio-02-svg { width:100%; height:100%; display:block; }
    .sutol-bio-02-cell {
      fill:rgba(91,199,178,0.25); stroke:#2ea88a; stroke-width:3;
      animation: sutol-bio-02-split 6s ease-in-out infinite;
      transform-origin: 200px 100px;
    }
    .sutol-bio-02-chrom {
      fill:#e0546e;
      animation: sutol-bio-02-chromsplit 6s ease-in-out infinite;
    }
    @keyframes sutol-bio-02-split {
      0%,10% { rx:70; }
      45% { rx:90; }
      55%,90% { rx:45; }
      100% { rx:70; }
    }
    @keyframes sutol-bio-02-chromsplit {
      0%,10% { transform:translateX(0) scale(1); opacity:1; }
      45% { transform:translateX(0) scale(1.1); }
      55%,90% { opacity:1; }
      100% { transform:translateX(0) scale(1); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-02-cell, .sutol-bio-02-chrom { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-02-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <ellipse class="sutol-bio-02-cell" cx="140" cy="100" rx="70" ry="55"/>
    <ellipse class="sutol-bio-02-cell" style="animation-delay:0s" cx="260" cy="100" rx="70" ry="55"/>
    <g class="sutol-bio-02-chrom">
      <rect x="130" y="85" width="10" height="30" rx="5"/>
      <rect x="150" y="85" width="10" height="30" rx="5"/>
      <rect x="250" y="85" width="10" height="30" rx="5"/>
      <rect x="270" y="85" width="10" height="30" rx="5"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 3: Kromozom Dansı — Mayoz

**Etiketler (keyword eşleşmesi için):** mayoz, gen ifadesi, genom
**Kategori:** Biyoloji
**Açıklama:** Bir ana hücrenin iki aşamalı bölünmeyle dört farklı yavru hücreye ayrıldığı ve kromozomların çaprazlaştığı animasyon.

```html
<div class="sutol-bio-03-root">
  <style>
    .sutol-bio-03-root { width:100%; height:100%; }
    .sutol-bio-03-svg { width:100%; height:100%; display:block; }
    .sutol-bio-03-cell { fill:rgba(120,140,240,0.2); stroke:#5b6bf2; stroke-width:2.5; }
    .sutol-bio-03-g1 { animation: sutol-bio-03-stage1 8s ease-in-out infinite; }
    .sutol-bio-03-g2 { animation: sutol-bio-03-stage2 8s ease-in-out infinite; opacity:0; }
    .sutol-bio-03-cross {
      stroke:#f2a65b; stroke-width:2.5;
      stroke-dasharray:40; stroke-dashoffset:40;
      animation: sutol-bio-03-cross 8s ease-in-out infinite;
    }
    @keyframes sutol-bio-03-stage1 { 0%,40%{opacity:1} 50%,100%{opacity:0} }
    @keyframes sutol-bio-03-stage2 { 0%,45%{opacity:0} 55%,95%{opacity:1} 100%{opacity:0} }
    @keyframes sutol-bio-03-cross { 0%{stroke-dashoffset:40} 30%{stroke-dashoffset:0} 45%{stroke-dashoffset:-40} 100%{stroke-dashoffset:-40} }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-03-g1, .sutol-bio-03-g2, .sutol-bio-03-cross { animation-play-state: paused; opacity:1; }
    }
  </style>
  <svg class="sutol-bio-03-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-bio-03-g1">
      <ellipse class="sutol-bio-03-cell" cx="200" cy="100" rx="80" ry="60"/>
      <line class="sutol-bio-03-cross" x1="170" y1="80" x2="230" y2="120"/>
      <line class="sutol-bio-03-cross" x1="230" y1="80" x2="170" y2="120"/>
    </g>
    <g class="sutol-bio-03-g2">
      <ellipse class="sutol-bio-03-cell" cx="90" cy="70" rx="45" ry="35"/>
      <ellipse class="sutol-bio-03-cell" cx="90" cy="150" rx="45" ry="35"/>
      <ellipse class="sutol-bio-03-cell" cx="310" cy="70" rx="45" ry="35"/>
      <ellipse class="sutol-bio-03-cell" cx="310" cy="150" rx="45" ry="35"/>
      <circle fill="#5b6bf2" cx="90" cy="70" r="6"/>
      <circle fill="#5b6bf2" cx="90" cy="150" r="6"/>
      <circle fill="#f2a65b" cx="310" cy="70" r="6"/>
      <circle fill="#f2a65b" cx="310" cy="150" r="6"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 4: Epigenetik Anahtarlar

**Etiketler (keyword eşleşmesi için):** epigenetik, gen ifadesi, genom
**Kategori:** Biyoloji
**Açıklama:** DNA sarmalı üzerinde metil grubu etiketlerinin yanıp sönerek genleri "açıp kapattığı" bir anahtarlama animasyonu.

```html
<div class="sutol-bio-04-root">
  <style>
    .sutol-bio-04-root { width:100%; height:100%; }
    .sutol-bio-04-svg { width:100%; height:100%; display:block; }
    .sutol-bio-04-helix { fill:none; stroke:#8a6de0; stroke-width:3; }
    .sutol-bio-04-tag {
      fill:#e0546e;
      animation: sutol-bio-04-blink 4s ease-in-out infinite;
      transform-origin:center;
    }
    .sutol-bio-04-glow {
      fill:#ffd166; opacity:0;
      animation: sutol-bio-04-light 4s ease-in-out infinite;
    }
    @keyframes sutol-bio-04-blink { 0%,100%{transform:scale(1); opacity:1;} 50%{transform:scale(1.4); opacity:0.6;} }
    @keyframes sutol-bio-04-light { 0%,40%{opacity:0} 55%{opacity:.9} 100%{opacity:0} }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-04-tag, .sutol-bio-04-glow { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-04-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-bio-04-helix" d="M40,20 C90,60 -10,100 40,140 C90,180 -10,190 40,200"/>
    <path class="sutol-bio-04-helix" d="M60,20 C10,60 110,100 60,140 C10,180 110,190 60,200"/>
    <circle class="sutol-bio-04-glow" cx="50" cy="50" r="18"/>
    <circle class="sutol-bio-04-glow" style="animation-delay:1.3s" cx="50" cy="110" r="18"/>
    <circle class="sutol-bio-04-glow" style="animation-delay:2.6s" cx="50" cy="170" r="18"/>
    <circle class="sutol-bio-04-tag" style="animation-delay:0s" cx="50" cy="50" r="7"/>
    <circle class="sutol-bio-04-tag" style="animation-delay:1.3s" cx="50" cy="110" r="7"/>
    <circle class="sutol-bio-04-tag" style="animation-delay:2.6s" cx="50" cy="170" r="7"/>
  </svg>
</div>
```

---

## Bileşen 5: Yaşam Ağacı

**Etiketler (keyword eşleşmesi için):** filogenetik ağaç, ortak ata, genom
**Kategori:** Biyoloji
**Açıklama:** Ortak bir atadan başlayarak dallanan bir filogenetik ağacın çizgi çizgi büyüdüğü animasyon.

```html
<div class="sutol-bio-05-root">
  <style>
    .sutol-bio-05-root { width:100%; height:100%; }
    .sutol-bio-05-svg { width:100%; height:100%; display:block; }
    .sutol-bio-05-branch {
      fill:none; stroke:#3aa17e; stroke-width:3; stroke-linecap:round;
      stroke-dasharray:200; stroke-dashoffset:200;
      animation: sutol-bio-05-grow 5s ease-in-out infinite;
    }
    .sutol-bio-05-node {
      fill:#ffb020; opacity:0;
      animation: sutol-bio-05-nodefade 5s ease-in-out infinite;
    }
    .sutol-bio-05-root-node { fill:#e0546e; }
    @keyframes sutol-bio-05-grow { 0%{stroke-dashoffset:200} 60%,100%{stroke-dashoffset:0} }
    @keyframes sutol-bio-05-nodefade { 0%,50%{opacity:0} 65%,100%{opacity:1} }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-05-branch, .sutol-bio-05-node { animation-play-state: paused; stroke-dashoffset:0; opacity:1; }
    }
  </style>
  <svg class="sutol-bio-05-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-bio-05-branch" d="M40,180 L140,100"/>
    <path class="sutol-bio-05-branch" style="animation-delay:.4s" d="M140,100 L100,40"/>
    <path class="sutol-bio-05-branch" style="animation-delay:.4s" d="M140,100 L200,50"/>
    <path class="sutol-bio-05-branch" style="animation-delay:.8s" d="M200,50 L260,20"/>
    <path class="sutol-bio-05-branch" style="animation-delay:.8s" d="M200,50 L280,70"/>
    <path class="sutol-bio-05-branch" style="animation-delay:1.2s" d="M280,70 L360,50"/>
    <path class="sutol-bio-05-branch" style="animation-delay:1.2s" d="M280,70 L350,110"/>
    <circle class="sutol-bio-05-node sutol-bio-05-root-node" style="animation-delay:0s;opacity:1" cx="40" cy="180" r="8"/>
    <circle class="sutol-bio-05-node" style="animation-delay:.6s" cx="100" cy="40" r="6"/>
    <circle class="sutol-bio-05-node" style="animation-delay:1s" cx="260" cy="20" r="6"/>
    <circle class="sutol-bio-05-node" style="animation-delay:1.4s" cx="360" cy="50" r="6"/>
    <circle class="sutol-bio-05-node" style="animation-delay:1.4s" cx="350" cy="110" r="6"/>
  </svg>
</div>
```

---

## Bileşen 6: Denge Terazisi — Homeostazi

**Etiketler (keyword eşleşmesi için):** homeostazi, endokrin sistem
**Kategori:** Biyoloji
**Açıklama:** Bir gösterge ibresinin sürekli merkezî dengeye dönmeye çalıştığı, vücut dengesini simgeleyen bir terazi/gösterge animasyonu.

```html
<div class="sutol-bio-06-root">
  <style>
    .sutol-bio-06-root { width:100%; height:100%; }
    .sutol-bio-06-svg { width:100%; height:100%; display:block; }
    .sutol-bio-06-arc { fill:none; stroke:#cfe0f7; stroke-width:10; stroke-linecap:round; }
    .sutol-bio-06-needle {
      stroke:#e0546e; stroke-width:4; stroke-linecap:round;
      transform-origin:200px 140px;
      animation: sutol-bio-06-swing 5s ease-in-out infinite;
    }
    .sutol-bio-06-pivot { fill:#3a4a6b; }
    .sutol-bio-06-zone { fill:#38b28a; opacity:.35; }
    @keyframes sutol-bio-06-swing {
      0%,100% { transform:rotate(-25deg); }
      25% { transform:rotate(18deg); }
      50% { transform:rotate(-4deg); }
      75% { transform:rotate(10deg); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-06-needle { animation-play-state: paused; transform:rotate(0deg); }
    }
  </style>
  <svg class="sutol-bio-06-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-bio-06-arc" d="M80,140 A120,120 0 0,1 320,140"/>
    <path class="sutol-bio-06-zone" d="M170,45 A120,120 0 0,1 230,45 L220,60 A100,100 0 0,0 180,60 Z"/>
    <line class="sutol-bio-06-needle" x1="200" y1="140" x2="200" y2="40"/>
    <circle class="sutol-bio-06-pivot" cx="200" cy="140" r="10"/>
  </svg>
</div>
```

---

## Bileşen 7: Nöron Ateşleme Zinciri

**Etiketler (keyword eşleşmesi için):** sinaps, nöron, akson, refleks
**Kategori:** Biyoloji
**Açıklama:** Bir uyaranın akson boyunca ilerleyip sinaps aralığından atlayarak zincirleme sinyal ilettiği refleks animasyonu.

```html
<div class="sutol-bio-07-root">
  <style>
    .sutol-bio-07-root { width:100%; height:100%; }
    .sutol-bio-07-svg { width:100%; height:100%; display:block; }
    .sutol-bio-07-axon { fill:none; stroke:#5b8bf7; stroke-width:4; stroke-linecap:round; }
    .sutol-bio-07-soma { fill:#5b8bf7; }
    .sutol-bio-07-pulse {
      fill:#ffd166;
      offset-path: path('M40,100 C120,60 180,140 260,100 C300,80 320,100 340,100');
      animation: sutol-bio-07-travel 2.5s linear infinite;
    }
    .sutol-bio-07-spark {
      fill:#f2a65b; opacity:0;
      animation: sutol-bio-07-spark 2.5s linear infinite;
    }
    @keyframes sutol-bio-07-travel { 0%{offset-distance:0%; opacity:1;} 92%{opacity:1;} 100%{offset-distance:100%; opacity:0;} }
    @keyframes sutol-bio-07-spark { 0%,85%{opacity:0; transform:scale(.5);} 90%{opacity:1; transform:scale(1.6);} 100%{opacity:0; transform:scale(.5);} }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-07-pulse, .sutol-bio-07-spark { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-07-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <ellipse class="sutol-bio-07-soma" cx="35" cy="100" rx="22" ry="18"/>
    <path class="sutol-bio-07-axon" d="M40,100 C120,60 180,140 260,100 C300,80 320,100 340,100"/>
    <g fill="#5b8bf7">
      <path d="M340,100 L365,85 L365,95 L385,95 L385,105 L365,105 L365,115 Z"/>
    </g>
    <circle class="sutol-bio-07-pulse" r="7"/>
    <circle class="sutol-bio-07-spark" cx="370" cy="100" r="10"/>
  </svg>
</div>
```

---

## Bileşen 8: Hormon Kurye Sistemi

**Etiketler (keyword eşleşmesi için):** endokrin sistem, homeostazi
**Kategori:** Biyoloji
**Açıklama:** Bir bezden salınan hormon moleküllerinin kan dolaşımını temsil eden bir kanaldan hedef hücreye taşındığı canvas tabanlı parçacık animasyonu.

```html
<div class="sutol-bio-08-root">
  <style>
    .sutol-bio-08-root { width:100%; height:100%; position:relative; }
    .sutol-bio-08-canvas { width:100%; height:100%; display:block; }
  </style>
  <canvas class="sutol-bio-08-canvas"></canvas>
  <script>
    (function(){
      const root = document.currentScript.parentElement;
      const canvas = root.querySelector('.sutol-bio-08-canvas');
      const ctx = canvas.getContext('2d');
      let w,h,dpr;
      function resize(){
        dpr = window.devicePixelRatio || 1;
        w = root.clientWidth; h = root.clientHeight;
        canvas.width = w*dpr; canvas.height = h*dpr;
        ctx.setTransform(dpr,0,0,dpr,0,0);
      }
      resize();
      window.addEventListener('resize', resize);
      const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      let particles = [];
      function spawn(){
        particles.push({ t:0, speed: 0.006 + Math.random()*0.004, y: 0.35 + Math.random()*0.3 });
      }
      let last = 0;
      function frame(ts){
        if(!last) last = ts;
        const dt = ts-last; last = ts;
        ctx.clearRect(0,0,w,h);
        const glandX = w*0.12, glandY = h*0.5;
        const targetX = w*0.85, targetY = h*0.5;
        ctx.fillStyle = '#f7b955';
        ctx.beginPath(); ctx.ellipse(glandX, glandY, w*0.08, h*0.22, 0, 0, Math.PI*2); ctx.fill();
        ctx.fillStyle = '#5bc2c9';
        ctx.beginPath(); ctx.arc(targetX, targetY, Math.min(w,h)*0.12, 0, Math.PI*2); ctx.fill();
        ctx.strokeStyle = 'rgba(150,170,220,0.35)';
        ctx.lineWidth = Math.max(2, h*0.06);
        ctx.beginPath(); ctx.moveTo(glandX+w*0.08, glandY); ctx.lineTo(targetX-Math.min(w,h)*0.12, targetY); ctx.stroke();
        if(!reduce){
          if(Math.random() < 0.03) spawn();
          particles.forEach(p => p.t += p.speed*dt*0.06);
          particles = particles.filter(p => p.t < 1);
        }
        ctx.fillStyle = '#ff6b6b';
        particles.forEach(p => {
          const x = glandX + (targetX-glandX)*p.t;
          const y = glandY + Math.sin(p.t*Math.PI*3)*10;
          ctx.beginPath(); ctx.arc(x,y,4,0,Math.PI*2); ctx.fill();
        });
        requestAnimationFrame(frame);
      }
      requestAnimationFrame(frame);
    })();
  </script>
</div>
```

---

## Bileşen 9: Kas Lifi Kasılması

**Etiketler (keyword eşleşmesi için):** kas lifi, iskelet sistemi, refleks
**Kategori:** Biyoloji
**Açıklama:** Aktin ve miyozin filamentlerinin birbiri üzerinden kayarak kas lifini kısalttığı kasılma animasyonu.

```html
<div class="sutol-bio-09-root">
  <style>
    .sutol-bio-09-root { width:100%; height:100%; }
    .sutol-bio-09-svg { width:100%; height:100%; display:block; }
    .sutol-bio-09-thick { fill:#c9536b; }
    .sutol-bio-09-thin {
      fill:#5b8bf7;
      animation: sutol-bio-09-slide 3s ease-in-out infinite;
    }
    @keyframes sutol-bio-09-slide {
      0%,100% { transform:translateX(0); }
      50% { transform:translateX(24px); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-09-thin { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-09-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <rect class="sutol-bio-09-thick" x="60" y="90" width="280" height="20" rx="6"/>
    <g class="sutol-bio-09-thin">
      <rect x="30" y="70" width="90" height="12" rx="4"/>
      <rect x="150" y="130" width="90" height="12" rx="4"/>
      <rect x="270" y="70" width="90" height="12" rx="4"/>
    </g>
    <g class="sutol-bio-09-thin" style="animation-delay:1.5s">
      <rect x="30" y="130" width="90" height="12" rx="4"/>
      <rect x="150" y="70" width="90" height="12" rx="4"/>
      <rect x="270" y="130" width="90" height="12" rx="4"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 10: İskelet Kaldıraç Sistemi

**Etiketler (keyword eşleşmesi için):** iskelet sistemi, kas lifi
**Kategori:** Biyoloji
**Açıklama:** Bir eklem etrafında dönen kemik/kaldıraç kolunun kas kasılmasıyla açı değiştirdiği mekanik bir animasyon.

```html
<div class="sutol-bio-10-root">
  <style>
    .sutol-bio-10-root { width:100%; height:100%; }
    .sutol-bio-10-svg { width:100%; height:100%; display:block; }
    .sutol-bio-10-bone { fill:#e8e2d6; stroke:#b7ad98; stroke-width:2; }
    .sutol-bio-10-forearm {
      transform-origin:180px 100px;
      animation: sutol-bio-10-flex 4s ease-in-out infinite;
    }
    .sutol-bio-10-joint { fill:#8a6de0; }
    .sutol-bio-10-muscle {
      fill:#e0546e; opacity:.7;
      animation: sutol-bio-10-bulge 4s ease-in-out infinite;
      transform-origin:140px 90px;
    }
    @keyframes sutol-bio-10-flex { 0%,100%{transform:rotate(0deg);} 50%{transform:rotate(-70deg);} }
    @keyframes sutol-bio-10-bulge { 0%,100%{transform:scale(1);} 50%{transform:scale(1.35);} }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-10-forearm, .sutol-bio-10-muscle { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-10-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <rect class="sutol-bio-10-bone" x="40" y="90" width="140" height="20" rx="10"/>
    <ellipse class="sutol-bio-10-muscle" cx="120" cy="95" rx="45" ry="14"/>
    <circle class="sutol-bio-10-joint" cx="180" cy="100" r="10"/>
    <g class="sutol-bio-10-forearm">
      <rect class="sutol-bio-10-bone" x="180" y="90" width="120" height="20" rx="10"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 11: Embriyonik Gelişim Yolculuğu

**Etiketler (keyword eşleşmesi için):** embriyonik gelişim, hücre bölünmesi
**Kategori:** Biyoloji
**Açıklama:** Tek bir zigotun art arda bölünerek blastula ve basit embriyo aşamalarına dönüştüğü sıralı morfoloji animasyonu.

```html
<div class="sutol-bio-11-root">
  <style>
    .sutol-bio-11-root { width:100%; height:100%; }
    .sutol-bio-11-svg { width:100%; height:100%; display:block; }
    .sutol-bio-11-stage { opacity:0; }
    .sutol-bio-11-s1 { animation: sutol-bio-11-fade1 8s ease-in-out infinite; }
    .sutol-bio-11-s2 { animation: sutol-bio-11-fade2 8s ease-in-out infinite; }
    .sutol-bio-11-s3 { animation: sutol-bio-11-fade3 8s ease-in-out infinite; }
    .sutol-bio-11-s4 { animation: sutol-bio-11-fade4 8s ease-in-out infinite; }
    circle, ellipse { fill:#f2a2c4; stroke:#c9536b; stroke-width:2; }
    @keyframes sutol-bio-11-fade1 { 0%,5%{opacity:0} 10%,20%{opacity:1} 25%{opacity:0} 100%{opacity:0} }
    @keyframes sutol-bio-11-fade2 { 0%,25%{opacity:0} 30%,45%{opacity:1} 50%{opacity:0} 100%{opacity:0} }
    @keyframes sutol-bio-11-fade3 { 0%,50%{opacity:0} 55%,70%{opacity:1} 75%{opacity:0} 100%{opacity:0} }
    @keyframes sutol-bio-11-fade4 { 0%,75%{opacity:0} 80%,95%{opacity:1} 100%{opacity:0} }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-11-stage { animation-play-state: paused; }
      .sutol-bio-11-s1 { opacity:1; }
    }
  </style>
  <svg class="sutol-bio-11-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-bio-11-stage sutol-bio-11-s1"><circle cx="200" cy="100" r="40"/></g>
    <g class="sutol-bio-11-stage sutol-bio-11-s2">
      <circle cx="180" cy="90" r="24"/><circle cx="220" cy="90" r="24"/>
      <circle cx="180" cy="120" r="24"/><circle cx="220" cy="120" r="24"/>
    </g>
    <g class="sutol-bio-11-stage sutol-bio-11-s3">
      <circle cx="170" cy="80" r="14"/><circle cx="200" cy="75" r="14"/><circle cx="230" cy="80" r="14"/>
      <circle cx="170" cy="110" r="14"/><circle cx="200" cy="115" r="14"/><circle cx="230" cy="110" r="14"/>
      <circle cx="185" cy="135" r="14"/><circle cx="215" cy="135" r="14"/>
    </g>
    <g class="sutol-bio-11-stage sutol-bio-11-s4">
      <ellipse cx="200" cy="100" rx="55" ry="38"/>
      <circle cx="230" cy="85" r="18" fill="#f7b955"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 12: Başkalaşım Döngüsü

**Etiketler (keyword eşleşmesi için):** başkalaşım, embriyonik gelişim
**Kategori:** Biyoloji
**Açıklama:** Tırtıldan kozaya, kozadan kelebeğe dönüşen ve döngüsel olarak tekrar eden bir başkalaşım animasyonu.

```html
<div class="sutol-bio-12-root">
  <style>
    .sutol-bio-12-root { width:100%; height:100%; }
    .sutol-bio-12-svg { width:100%; height:100%; display:block; }
    .sutol-bio-12-cat { animation: sutol-bio-12-catfade 9s ease-in-out infinite; transform-origin:center; }
    .sutol-bio-12-cocoon { animation: sutol-bio-12-cocfade 9s ease-in-out infinite; transform-origin:center; }
    .sutol-bio-12-wing {
      fill:#f7b955;
      animation: sutol-bio-12-flap 0.6s ease-in-out infinite alternate, sutol-bio-12-buttfade 9s ease-in-out infinite;
      transform-origin:200px 100px;
    }
    @keyframes sutol-bio-12-catfade { 0%,25%{opacity:1} 33%,100%{opacity:0} }
    @keyframes sutol-bio-12-cocfade { 0%,30%{opacity:0} 38%,58%{opacity:1} 66%,100%{opacity:0} }
    @keyframes sutol-bio-12-buttfade { 0%,63%{opacity:0} 71%,95%{opacity:1} 100%{opacity:0} }
    @keyframes sutol-bio-12-flap { from{transform:scaleX(1) rotate(0deg);} to{transform:scaleX(1) rotate(12deg);} }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-12-cat, .sutol-bio-12-cocoon, .sutol-bio-12-wing { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-12-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-bio-12-cat" fill="#8bc98a">
      <ellipse cx="140" cy="120" rx="18" ry="12"/>
      <ellipse cx="170" cy="120" rx="18" ry="12"/>
      <ellipse cx="200" cy="120" rx="18" ry="12"/>
      <ellipse cx="230" cy="120" rx="18" ry="12"/>
      <ellipse cx="260" cy="118" rx="16" ry="11"/>
    </g>
    <g class="sutol-bio-12-cocoon" fill="#c9a16b">
      <ellipse cx="200" cy="110" rx="30" ry="55"/>
    </g>
    <g class="sutol-bio-12-wing">
      <path d="M200,100 C160,60 120,80 130,120 C150,140 190,120 200,100 Z"/>
      <path d="M200,100 C240,60 280,80 270,120 C250,140 210,120 200,100 Z"/>
      <ellipse cx="200" cy="100" rx="6" ry="20" fill="#4a3b2a"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 13: Kış Uykusu Döngüsü

**Etiketler (keyword eşleşmesi için):** kış uykusu, homeostazi
**Kategori:** Biyoloji
**Açıklama:** Kıvrılmış bir yaratığın yavaş nefes alışıyla birlikte gece-gündüz/mevsim renk döngüsünün geçtiği sakin bir uyku animasyonu.

```html
<div class="sutol-bio-13-root">
  <style>
    .sutol-bio-13-root { width:100%; height:100%; }
    .sutol-bio-13-svg { width:100%; height:100%; display:block; }
    .sutol-bio-13-bg {
      animation: sutol-bio-13-season 12s ease-in-out infinite;
    }
    .sutol-bio-13-body {
      fill:#a9825c;
      animation: sutol-bio-13-breathe 4s ease-in-out infinite;
      transform-origin:200px 120px;
    }
    .sutol-bio-13-zzz {
      fill:#cfe0f7; opacity:0;
      animation: sutol-bio-13-float 4s ease-in-out infinite;
    }
    @keyframes sutol-bio-13-season {
      0%,100% { fill:#2b3a55; }
      50% { fill:#7d9bc9; }
    }
    @keyframes sutol-bio-13-breathe { 0%,100%{transform:scale(1);} 50%{transform:scale(1.04);} }
    @keyframes sutol-bio-13-float { 0%{opacity:0; transform:translateY(0);} 30%{opacity:.8;} 100%{opacity:0; transform:translateY(-30px);} }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-13-bg, .sutol-bio-13-body, .sutol-bio-13-zzz { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-13-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <rect class="sutol-bio-13-bg" x="0" y="0" width="400" height="200" opacity="0.15"/>
    <ellipse class="sutol-bio-13-body" cx="200" cy="130" rx="70" ry="45"/>
    <circle fill="#8a6a4a" cx="150" cy="105" r="16"/>
    <text class="sutol-bio-13-zzz" x="260" y="70" font-size="20" style="animation-delay:0s">z</text>
    <text class="sutol-bio-13-zzz" x="280" y="55" font-size="26" style="animation-delay:1s">z</text>
    <text class="sutol-bio-13-zzz" x="300" y="40" font-size="32" style="animation-delay:2s">z</text>
  </svg>
</div>
```

---

## Bileşen 14: Kamuflaj Ustası

**Etiketler (keyword eşleşmesi için):** kamuflaj, mimikri
**Kategori:** Biyoloji
**Açıklama:** Bir yaratığın vücut desenlerinin arka plandaki dokuya uyum sağlamak için sürekli renk/desen değiştirdiği animasyon.

```html
<div class="sutol-bio-14-root">
  <style>
    .sutol-bio-14-root { width:100%; height:100%; }
    .sutol-bio-14-svg { width:100%; height:100%; display:block; }
    .sutol-bio-14-patch {
      animation: sutol-bio-14-shift 6s ease-in-out infinite;
    }
    .sutol-bio-14-creature {
      animation: sutol-bio-14-blend 6s ease-in-out infinite;
    }
    @keyframes sutol-bio-14-shift {
      0%,100% { fill:#6b8f5a; }
      33% { fill:#8a7040; }
      66% { fill:#4a6b6b; }
    }
    @keyframes sutol-bio-14-blend {
      0%,100% { fill:#6b8f5a; opacity:0.9; }
      33% { fill:#8a7040; opacity:0.9; }
      66% { fill:#4a6b6b; opacity:0.9; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-14-patch, .sutol-bio-14-creature { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-14-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <rect class="sutol-bio-14-patch" x="0" y="0" width="130" height="200" opacity="0.3"/>
    <rect class="sutol-bio-14-patch" style="animation-delay:2s" x="130" y="0" width="140" height="200" opacity="0.3"/>
    <rect class="sutol-bio-14-patch" style="animation-delay:4s" x="270" y="0" width="130" height="200" opacity="0.3"/>
    <ellipse class="sutol-bio-14-creature" cx="200" cy="110" rx="60" ry="30"/>
    <circle class="sutol-bio-14-creature" cx="255" cy="100" r="14"/>
  </svg>
</div>
```

---

## Bileşen 15: Mimikri Oyunu

**Etiketler (keyword eşleşmesi için):** mimikri, kamuflaj
**Kategori:** Biyoloji
**Açıklama:** Zararsız bir türün, korunma amacıyla zehirli bir türün renk desenini taklit ettiği yan yana karşılaştırma animasyonu.

```html
<div class="sutol-bio-15-root">
  <style>
    .sutol-bio-15-root { width:100%; height:100%; }
    .sutol-bio-15-svg { width:100%; height:100%; display:block; }
    .sutol-bio-15-mimic {
      animation: sutol-bio-15-copy 5s ease-in-out infinite;
    }
    @keyframes sutol-bio-15-copy {
      0%,40% { fill:#8bc98a; }
      55%,100% { fill:#f2a65b; }
    }
    .sutol-bio-15-stripe {
      animation: sutol-bio-15-stripe 5s ease-in-out infinite;
      opacity:0;
    }
    @keyframes sutol-bio-15-stripe { 0%,45%{opacity:0} 60%,100%{opacity:1} }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-15-mimic, .sutol-bio-15-stripe { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-15-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <g>
      <ellipse fill="#333" cx="120" cy="100" rx="55" ry="26"/>
      <rect fill="#f2a65b" x="80" y="80" width="14" height="40"/>
      <rect fill="#f2a65b" x="120" y="80" width="14" height="40"/>
      <rect fill="#f2a65b" x="160" y="80" width="14" height="40"/>
    </g>
    <g>
      <ellipse class="sutol-bio-15-mimic" cx="280" cy="100" rx="55" ry="26"/>
      <rect class="sutol-bio-15-stripe" fill="#333" x="240" y="80" width="14" height="40"/>
      <rect class="sutol-bio-15-stripe" fill="#333" x="280" y="80" width="14" height="40"/>
      <rect class="sutol-bio-15-stripe" fill="#333" x="320" y="80" width="14" height="40"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 16: Tozlaşma Dansı

**Etiketler (keyword eşleşmesi için):** tozlaşma, mikrobiyom
**Kategori:** Biyoloji
**Açıklama:** Bir arının çiçekten çiçeğe uçarak polen taşıdığı, motion-path tabanlı döngüsel tozlaşma animasyonu.

```html
<div class="sutol-bio-16-root">
  <style>
    .sutol-bio-16-root { width:100%; height:100%; }
    .sutol-bio-16-svg { width:100%; height:100%; display:block; }
    .sutol-bio-16-petal { fill:#f2a2c4; }
    .sutol-bio-16-center { fill:#ffd166; }
    .sutol-bio-16-bee {
      offset-path: path('M60,80 C120,40 160,140 200,90 C240,40 280,140 340,80');
      animation: sutol-bio-16-fly 6s ease-in-out infinite;
    }
    .sutol-bio-16-pollen {
      fill:#ffd166; opacity:0;
      animation: sutol-bio-16-drop 6s ease-in-out infinite;
    }
    @keyframes sutol-bio-16-fly { 0%{offset-distance:0%;} 100%{offset-distance:100%;} }
    @keyframes sutol-bio-16-drop { 0%,15%{opacity:0} 20%{opacity:1} 30%{opacity:0} 100%{opacity:0} }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-16-bee, .sutol-bio-16-pollen { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-16-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <g transform="translate(60,80)">
      <circle class="sutol-bio-16-petal" cx="-14" cy="0" r="14"/>
      <circle class="sutol-bio-16-petal" cx="14" cy="0" r="14"/>
      <circle class="sutol-bio-16-petal" cx="0" cy="-14" r="14"/>
      <circle class="sutol-bio-16-petal" cx="0" cy="14" r="14"/>
      <circle class="sutol-bio-16-center" cx="0" cy="0" r="10"/>
    </g>
    <g transform="translate(200,90)">
      <circle class="sutol-bio-16-petal" cx="-14" cy="0" r="14"/>
      <circle class="sutol-bio-16-petal" cx="14" cy="0" r="14"/>
      <circle class="sutol-bio-16-petal" cx="0" cy="-14" r="14"/>
      <circle class="sutol-bio-16-petal" cx="0" cy="14" r="14"/>
      <circle class="sutol-bio-16-center" cx="0" cy="0" r="10"/>
    </g>
    <g transform="translate(340,80)">
      <circle class="sutol-bio-16-petal" cx="-14" cy="0" r="14"/>
      <circle class="sutol-bio-16-petal" cx="14" cy="0" r="14"/>
      <circle class="sutol-bio-16-petal" cx="0" cy="-14" r="14"/>
      <circle class="sutol-bio-16-petal" cx="0" cy="14" r="14"/>
      <circle class="sutol-bio-16-center" cx="0" cy="0" r="10"/>
    </g>
    <circle class="sutol-bio-16-pollen" style="animation-delay:0s" cx="60" cy="80" r="5"/>
    <circle class="sutol-bio-16-pollen" style="animation-delay:3s" cx="200" cy="90" r="5"/>
    <ellipse class="sutol-bio-16-bee" rx="14" ry="9" fill="#3a3a3a"/>
  </svg>
</div>
```

---

## Bileşen 17: Tohum Yayılım Rüzgarı

**Etiketler (keyword eşleşmesi için):** tohum yayılımı, tozlaşma
**Kategori:** Biyoloji
**Açıklama:** Kanatlı bir tohumun rüzgarda dönerek yükselip uzaklaştığı, sürekli tekrar eden bir tohum yayılımı animasyonu.

```html
<div class="sutol-bio-17-root">
  <style>
    .sutol-bio-17-root { width:100%; height:100%; }
    .sutol-bio-17-svg { width:100%; height:100%; display:block; }
    .sutol-bio-17-seed {
      animation: sutol-bio-17-drift 5s linear infinite;
      transform-origin:center;
    }
    .sutol-bio-17-seed2 { animation-delay:1.7s; }
    .sutol-bio-17-seed3 { animation-delay:3.3s; }
    @keyframes sutol-bio-17-drift {
      0% { transform:translate(0,140px) rotate(0deg); opacity:0; }
      10% { opacity:1; }
      90% { opacity:1; }
      100% { transform:translate(340px,-20px) rotate(720deg); opacity:0; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-17-seed { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-17-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-bio-17-seed">
      <ellipse fill="#d9c48a" cx="0" cy="0" rx="6" ry="4"/>
      <path fill="rgba(200,220,150,0.6)" d="M0,0 Q30,-10 34,-2 Q28,10 0,4 Z"/>
    </g>
    <g class="sutol-bio-17-seed sutol-bio-17-seed2">
      <ellipse fill="#d9c48a" cx="0" cy="0" rx="6" ry="4"/>
      <path fill="rgba(200,220,150,0.6)" d="M0,0 Q30,-10 34,-2 Q28,10 0,4 Z"/>
    </g>
    <g class="sutol-bio-17-seed sutol-bio-17-seed3">
      <ellipse fill="#d9c48a" cx="0" cy="0" rx="6" ry="4"/>
      <path fill="rgba(200,220,150,0.6)" d="M0,0 Q30,-10 34,-2 Q28,10 0,4 Z"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 18: Biyolüminesan Parıltı

**Etiketler (keyword eşleşmesi için):** biyolüminesans, mikrobiyom
**Kategori:** Biyoloji
**Açıklama:** Derin deniz canlılarını çağrıştıran, yumuşak ışık halkalarının nabız gibi parladığı canvas tabanlı bir ışıldama animasyonu.

```html
<div class="sutol-bio-18-root">
  <style>
    .sutol-bio-18-root { width:100%; height:100%; }
    .sutol-bio-18-canvas { width:100%; height:100%; display:block; }
  </style>
  <canvas class="sutol-bio-18-canvas"></canvas>
  <script>
    (function(){
      const root = document.currentScript.parentElement;
      const canvas = root.querySelector('.sutol-bio-18-canvas');
      const ctx = canvas.getContext('2d');
      let w,h,dpr;
      function resize(){
        dpr = window.devicePixelRatio||1;
        w = root.clientWidth; h = root.clientHeight;
        canvas.width = w*dpr; canvas.height = h*dpr;
        ctx.setTransform(dpr,0,0,dpr,0,0);
      }
      resize();
      window.addEventListener('resize', resize);
      const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      const orbs = Array.from({length:5}, (_,i) => ({
        x: 0.15+i*0.18, y: 0.3+((i%2)*0.35), phase: i*1.1
      }));
      let t0 = 0;
      function frame(ts){
        if(!t0) t0 = ts;
        const t = reduce ? 0 : (ts-t0)/1000;
        ctx.clearRect(0,0,w,h);
        orbs.forEach(o => {
          const pulse = 0.5 + 0.5*Math.sin(t*1.3 + o.phase);
          const cx = w*o.x, cy = h*o.y;
          const r = Math.min(w,h)*(0.06 + 0.03*pulse);
          const grad = ctx.createRadialGradient(cx,cy,0,cx,cy,r*3);
          grad.addColorStop(0, `rgba(120,255,220,${0.5+0.4*pulse})`);
          grad.addColorStop(1, 'rgba(120,255,220,0)');
          ctx.fillStyle = grad;
          ctx.beginPath(); ctx.arc(cx,cy,r*3,0,Math.PI*2); ctx.fill();
          ctx.fillStyle = `rgba(220,255,245,${0.7+0.3*pulse})`;
          ctx.beginPath(); ctx.arc(cx,cy,r*0.35,0,Math.PI*2); ctx.fill();
        });
        requestAnimationFrame(frame);
      }
      requestAnimationFrame(frame);
    })();
  </script>
</div>
```

---

## Bileşen 19: Mikrobiyom Ekosistemi

**Etiketler (keyword eşleşmesi için):** mikrobiyom, parazitizm
**Kategori:** Biyoloji
**Açıklama:** Farklı şekillerdeki bakteri/mikroorganizma temsillerinin bir ortamda serbestçe süzülerek etkileşimde bulunduğu canvas tabanlı bir ekosistem animasyonu.

```html
<div class="sutol-bio-19-root">
  <style>
    .sutol-bio-19-root { width:100%; height:100%; }
    .sutol-bio-19-canvas { width:100%; height:100%; display:block; }
  </style>
  <canvas class="sutol-bio-19-canvas"></canvas>
  <script>
    (function(){
      const root = document.currentScript.parentElement;
      const canvas = root.querySelector('.sutol-bio-19-canvas');
      const ctx = canvas.getContext('2d');
      let w,h,dpr;
      function resize(){
        dpr = window.devicePixelRatio||1;
        w = root.clientWidth; h = root.clientHeight;
        canvas.width = w*dpr; canvas.height = h*dpr;
        ctx.setTransform(dpr,0,0,dpr,0,0);
      }
      resize();
      window.addEventListener('resize', resize);
      const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      const colors = ['#7fb0ff','#ff9e7f','#8ae0a0','#e0a8ff'];
      const shapes = ['circle','rod','spiral'];
      const bugs = Array.from({length:14}, (_,i) => ({
        x: Math.random(), y: Math.random(),
        vx: (Math.random()-0.5)*0.0006, vy:(Math.random()-0.5)*0.0006,
        r: 0.02+Math.random()*0.02,
        color: colors[i%colors.length],
        shape: shapes[i%shapes.length],
        rot: Math.random()*Math.PI*2
      }));
      function frame(){
        ctx.clearRect(0,0,w,h);
        bugs.forEach(b => {
          if(!reduce){
            b.x += b.vx; b.y += b.vy; b.rot += 0.005;
            if(b.x<0||b.x>1) b.vx*=-1;
            if(b.y<0||b.y>1) b.vy*=-1;
          }
          const cx = b.x*w, cy = b.y*h, r = b.r*Math.min(w,h);
          ctx.save();
          ctx.translate(cx,cy); ctx.rotate(b.rot);
          ctx.fillStyle = b.color;
          if(b.shape==='circle'){
            ctx.beginPath(); ctx.arc(0,0,r,0,Math.PI*2); ctx.fill();
          } else if(b.shape==='rod'){
            ctx.beginPath(); ctx.ellipse(0,0,r*1.8,r*0.7,0,0,Math.PI*2); ctx.fill();
          } else {
            ctx.beginPath();
            for(let a=0;a<Math.PI*4;a+=0.3){
              const rr = r*(a/(Math.PI*4));
              const x = Math.cos(a)*rr, y = Math.sin(a)*rr;
              a===0 ? ctx.moveTo(x,y) : ctx.lineTo(x,y);
            }
            ctx.strokeStyle = b.color; ctx.lineWidth = 2; ctx.stroke();
          }
          ctx.restore();
        });
        requestAnimationFrame(frame);
      }
      requestAnimationFrame(frame);
    })();
  </script>
</div>
```

---

## Bileşen 20: Parazit–Konak İlişkisi

**Etiketler (keyword eşleşmesi için):** parazitizm, mikrobiyom, endokrin sistem
**Kategori:** Biyoloji
**Açıklama:** Küçük bir parazit şeklinin bir konak hücreye tutunup ondan enerji/kaynak çektiği, nabız gibi tekrar eden bir ilişki animasyonu.

```html
<div class="sutol-bio-20-root">
  <style>
    .sutol-bio-20-root { width:100%; height:100%; }
    .sutol-bio-20-svg { width:100%; height:100%; display:block; }
    .sutol-bio-20-host {
      fill:#8bc98a;
      animation: sutol-bio-20-shrink 5s ease-in-out infinite;
      transform-origin:150px 100px;
    }
    .sutol-bio-20-parasite {
      fill:#c9536b;
      animation: sutol-bio-20-grow 5s ease-in-out infinite;
      transform-origin:250px 100px;
    }
    .sutol-bio-20-flow {
      stroke:#f2a65b; stroke-width:3; fill:none;
      stroke-dasharray:8 6;
      animation: sutol-bio-20-transfer 1.2s linear infinite;
    }
    @keyframes sutol-bio-20-shrink { 0%,100%{transform:scale(1);} 50%{transform:scale(0.85);} }
    @keyframes sutol-bio-20-grow { 0%,100%{transform:scale(1);} 50%{transform:scale(1.2);} }
    @keyframes sutol-bio-20-transfer { to { stroke-dashoffset:-28; } }
    @media (prefers-reduced-motion: reduce) {
      .sutol-bio-20-host, .sutol-bio-20-parasite, .sutol-bio-20-flow { animation-play-state: paused; }
    }
  </style>
  <svg class="sutol-bio-20-svg" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
    <circle class="sutol-bio-20-host" cx="150" cy="100" r="55"/>
    <path class="sutol-bio-20-flow" d="M190,100 H230"/>
    <circle class="sutol-bio-20-parasite" cx="250" cy="100" r="26"/>
  </svg>
</div>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Gen İfadesi): SVG path + stroke-dash animasyonu, sıralı opacity ile boncuk efekti — düşük yük, akıcı.
- Bileşen 2 (Mitoz): CSS `rx` keyframe animasyonu ile hücre bölünmesi — hafif, GPU dostu değil ama basit geometri nedeniyle performans sorunu yok.
- Bileşen 3 (Mayoz): Aşamalı opacity geçişleriyle 1→4 hücre simülasyonu — orta karmaşıklık.
- Bileşen 4 (Epigenetik): Çift katmanlı opacity/scale animasyonu (metil etiket + parıltı) — hafif.
- Bileşen 5 (Yaşam Ağacı): `stroke-dashoffset` ile SVG çizgi büyütme — GPU dostu, zamanlamalı gecikmelerle sıralı.
- Bileşen 6 (Homeostazi): Tek `transform:rotate` animasyonu, pivot sabit — çok hafif.
- Bileşen 7 (Nöron): CSS `offset-path` ile hareket yolu animasyonu — modern tarayıcılarda GPU hızlandırmalı.
- Bileşen 8 (Hormon Kurye): Canvas + `requestAnimationFrame` parçacık sistemi — `prefers-reduced-motion` durumunda parçacık üretimi durur.
- Bileşen 9 (Kas Lifi): Basit `translateX` kayması — GPU dostu, düşük yük.
- Bileşen 10 (İskelet): `rotate` + `scale` transform kombinasyonu — hafif.
- Bileşen 11 (Embriyonik Gelişim): Sıralı opacity aşamaları (4 evre) — hafif, DOM sayısı düşük.
- Bileşen 12 (Başkalaşım): Üç aşamalı opacity geçişi + kanat çırpma alt-animasyonu — orta.
- Bileşen 13 (Kış Uykusu): Renk (fill) ve scale animasyonu — hafif, uzun döngü (12s) düşük CPU kullanımı.
- Bileşen 14 (Kamuflaj): `fill` renk geçişleri — hafif ama `fill` özelliği GPU hızlandırmalı değildir, düşük eleman sayısı ile telafi edilmiştir.
- Bileşen 15 (Mimikri): İki `fill` animasyonu + opacity — hafif.
- Bileşen 16 (Tozlaşma): `offset-path` ile arı hareketi + opacity polen efekti — orta.
- Bileşen 17 (Tohum Yayılımı): `transform: translate + rotate` ile tam yörünge — GPU dostu, 3 paralel örnek.
- Bileşen 18 (Biyolüminesans): Canvas radial gradient nabız efekti — `reduce motion` durumunda zaman sabitlenir, hesaplama devam eder ama görsel sabit kalır.
- Bileşen 19 (Mikrobiyom): Canvas çoklu nesne simülasyonu (14 obje) — `reduce motion` durumunda hareket durur, sadece statik konumlar çizilir.
- Bileşen 20 (Parazitizm): `scale` animasyonu + `stroke-dashoffset` akış çizgisi — hafif.

Tüm bileşenler: tek dosya, şeffaf arka plan, `viewBox` tabanlı ölçeklenebilirlik, sabit metin yok (yalnızca Bileşen 13'te dekoratif "z" sembolleri sembol niteliğindedir), `sutol-bio-XX-` önekli sınıflar, `prefers-reduced-motion` desteği ve sandbox-uyumlu (localStorage/çerez/window.top kullanımı yok) şekilde hazırlanmıştır.
