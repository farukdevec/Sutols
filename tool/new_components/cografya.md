## Bileşen 21: Deprem Sismografı

**Etiketler (keyword eşleşmesi için):** deprem, sismograf, yerkabuğu, hareket
**Kategori:** Coğrafya
**Açıklama:** Canlı bir sismografın kağıt üzerinde çizdiği deprem dalgalanmalarını gösteren bir görüntü.

```html
<div class="sutol-geo21-wrap">
  <canvas class="sutol-geo21-canvas"></canvas>
  <style>
  .sutol-geo21-wrap{position:relative;width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-geo21-canvas{width:100%;height:100%;display:block;}
  @media (prefers-reduced-motion: reduce){
    .sutol-geo21-wrap{ }
  }
  </style>
  <script>
  (function(){
    var script = document.currentScript;
    var wrap = script.closest('.sutol-geo21-wrap');
    var canvas = wrap.querySelector('.sutol-geo21-canvas');
    var ctx = canvas.getContext('2d');
    var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var t = 0;
    function resize(){
      var rect = wrap.getBoundingClientRect();
      canvas.width = rect.width;
      canvas.height = rect.height;
    }
    resize();
    window.addEventListener('resize', resize);
    function draw(){
      var w = canvas.width, h = canvas.height;
      ctx.clearRect(0,0,w,h);
      ctx.strokeStyle = '#E63946';
      ctx.lineWidth = 2;
      ctx.beginPath();
      var mid = h/2;
      var step = reduce ? (2/3) : 2;
      t += step;
      var n = Math.floor(w);
      for(var x=0;x<n;x++){
        var phase = (x - t);
        var spike = Math.sin(phase*0.05) * 6 + Math.sin(phase*0.13) * 10 * Math.exp(-Math.pow(((phase%240)-40)/20,2));
        var y = mid + spike;
        if(x===0){ ctx.moveTo(x,y); } else { ctx.lineTo(x,y); }
      }
      ctx.stroke();
      requestAnimationFrame(draw);
    }
    requestAnimationFrame(draw);
  })();
  </script>
</div>
```

---

## Bileşen 22: Çöl Kum Tepeleri

**Etiketler (keyword eşleşmesi için):** çöl, kum, kayaç, iklim
**Kategori:** Coğrafya
**Açıklama:** Güneş altında yavaşça kayan katmanlı kum tepeleriyle bir çöl manzarası.

```html
<div class="sutol-geo22-wrap">
  <svg class="sutol-geo22-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-geo22-dune d1" d="M0,300 Q100,260 200,300 T400,300 V400 H0 Z" fill="#E9C46A"/>
    <path class="sutol-geo22-dune d2" d="M0,330 Q100,300 200,330 T400,330 V400 H0 Z" fill="#F4A261" opacity="0.85"/>
    <path class="sutol-geo22-dune d3" d="M0,360 Q100,340 200,360 T400,360 V400 H0 Z" fill="#E76F51" opacity="0.7"/>
    <circle class="sutol-geo22-sun" cx="330" cy="80" r="30" fill="#FFB703"/>
  </svg>
  <style>
  .sutol-geo22-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo22-svg{width:100%;height:100%;display:block;}
  .sutol-geo22-dune{animation: sutol-geo22-drift 8s ease-in-out infinite;}
  .sutol-geo22-dune.d2{animation-duration:11s;animation-direction:reverse;}
  .sutol-geo22-dune.d3{animation-duration:14s;}
  @keyframes sutol-geo22-drift{
    0%{transform:translateX(0);}
    50%{transform:translateX(-20px);}
    100%{transform:translateX(0);}
  }
  .sutol-geo22-sun{animation: sutol-geo22-glow 4s ease-in-out infinite;}
  @keyframes sutol-geo22-glow{0%,100%{opacity:0.85;}50%{opacity:1;}}
  @media (prefers-reduced-motion: reduce){
    .sutol-geo22-dune{animation-duration:30s;}
    .sutol-geo22-sun{animation-duration:12s;}
  }
  </style>
</div>
```

---

## Bileşen 23: Ozon Tabakası Deliği

**Etiketler (keyword eşleşmesi için):** atmosfer, ozon tabakası, iklim
**Kategori:** Coğrafya
**Açıklama:** Büyüyüp küçülen bir deliğin görüldüğü, dünyayı saran ozon tabakası kesiti.

```html
<div class="sutol-geo23-wrap">
  <svg class="sutol-geo23-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <defs>
      <radialGradient id="sutol-geo23-grad" cx="50%" cy="50%" r="50%">
        <stop offset="0%" stop-color="#A8DADC" stop-opacity="0.9"/>
        <stop offset="70%" stop-color="#457B9D" stop-opacity="0.5"/>
        <stop offset="100%" stop-color="#1D3557" stop-opacity="0.2"/>
      </radialGradient>
    </defs>
    <circle cx="200" cy="200" r="160" fill="url(#sutol-geo23-grad)"/>
    <circle cx="200" cy="200" r="90" fill="none" stroke="#2A9D8F" stroke-width="2" stroke-dasharray="4 6"/>
    <circle class="sutol-geo23-hole" cx="200" cy="120" r="30" fill="#0D1B2A"/>
  </svg>
  <style>
  .sutol-geo23-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo23-svg{width:100%;height:100%;display:block;}
  .sutol-geo23-hole{transform-box:fill-box;transform-origin:center;animation: sutol-geo23-pulse 6s ease-in-out infinite;}
  @keyframes sutol-geo23-pulse{
    0%{transform:scale(1);opacity:0.9;}
    50%{transform:scale(1.6);opacity:0.5;}
    100%{transform:scale(1);opacity:0.9;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-geo23-hole{animation-duration:20s;}
  }
  </style>
</div>
```

---

## Bileşen 24: Tektonik Plaka Çarpışması

**Etiketler (keyword eşleşmesi için):** yerkabuğu, jeoloji, dağ silsilesi
**Kategori:** Coğrafya
**Açıklama:** Birbirine yaklaşıp çarpışarak dağ sırtı oluşturan iki tektonik levha.

```html
<div class="sutol-geo24-wrap">
  <div class="sutol-geo24-scene">
    <div class="sutol-geo24-plate left"></div>
    <div class="sutol-geo24-plate right"></div>
    <div class="sutol-geo24-ridge"></div>
  </div>
  <style>
  .sutol-geo24-wrap{width:100%;height:100%;background:transparent;perspective:600px;}
  .sutol-geo24-scene{position:relative;width:100%;height:100%;transform-style:preserve-3d;transform:rotateX(35deg);}
  .sutol-geo24-plate{position:absolute;top:55%;width:38%;height:14%;background:#6C757D;border-radius:4px;}
  .sutol-geo24-plate.left{left:2%;animation: sutol-geo24-moveLeft 4s ease-in-out infinite;}
  .sutol-geo24-plate.right{right:2%;background:#495057;animation: sutol-geo24-moveRight 4s ease-in-out infinite;}
  .sutol-geo24-ridge{position:absolute;top:48%;left:48%;width:4%;height:4%;background:#E76F51;border-radius:50%;animation: sutol-geo24-ridgeUp 4s ease-in-out infinite;}
  @keyframes sutol-geo24-moveLeft{0%,100%{transform:translateX(0);}50%{transform:translateX(20%);}}
  @keyframes sutol-geo24-moveRight{0%,100%{transform:translateX(0);}50%{transform:translateX(-20%);}}
  @keyframes sutol-geo24-ridgeUp{0%,40%{transform:scale(0) translateZ(0);}50%{transform:scale(1) translateZ(20px);}100%{transform:scale(0) translateZ(0);}}
  @media (prefers-reduced-motion: reduce){
    .sutol-geo24-plate.left, .sutol-geo24-plate.right, .sutol-geo24-ridge{animation-duration:16s;}
  }
  </style>
</div>
```

---

## Bileşen 25: Rüzgar Gülü Pusulası

**Etiketler (keyword eşleşmesi için):** rüzgar, hava durumu, iklim
**Kategori:** Coğrafya
**Açıklama:** Yön ibresi sürekli dönen, rüzgar yönlerini gösteren bir pusula.

```html
<div class="sutol-geo25-wrap">
  <svg class="sutol-geo25-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <circle cx="200" cy="200" r="150" fill="none" stroke="#264653" stroke-width="3"/>
    <g class="sutol-geo25-ticks" stroke="#264653" stroke-width="4">
      <line x1="200" y1="50" x2="200" y2="80"/>
      <line x1="200" y1="320" x2="200" y2="350"/>
      <line x1="50" y1="200" x2="80" y2="200"/>
      <line x1="320" y1="200" x2="350" y2="200"/>
    </g>
    <g class="sutol-geo25-needle">
      <polygon points="200,80 214,200 200,320 186,200" fill="#E76F51"/>
    </g>
    <circle cx="200" cy="200" r="10" fill="#264653"/>
  </svg>
  <style>
  .sutol-geo25-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo25-svg{width:100%;height:100%;display:block;}
  .sutol-geo25-needle{transform-box:fill-box;transform-origin:center;animation: sutol-geo25-spin 9s linear infinite;}
  @keyframes sutol-geo25-spin{
    0%{transform:rotate(0deg);}
    25%{transform:rotate(95deg);}
    50%{transform:rotate(180deg);}
    75%{transform:rotate(260deg);}
    100%{transform:rotate(360deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-geo25-needle{animation-duration:36s;}
  }
  </style>
</div>
```

---

## Bileşen 26: Fırtına Bulutu ve Şimşek

**Etiketler (keyword eşleşmesi için):** fırtına, bulut, hava durumu
**Kategori:** Coğrafya
**Açıklama:** Aralıklarla şimşek çakan koyu renkli bir fırtına bulutu.

```html
<div class="sutol-geo26-wrap">
  <svg class="sutol-geo26-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <circle class="sutol-geo26-flash" cx="200" cy="150" r="150" fill="#FFD60A"/>
    <ellipse cx="200" cy="150" rx="140" ry="60" fill="#6C757D"/>
    <ellipse cx="140" cy="130" rx="70" ry="45" fill="#495057"/>
    <ellipse cx="260" cy="130" rx="75" ry="48" fill="#343A40"/>
    <polygon class="sutol-geo26-bolt" points="210,190 180,260 205,260 175,340 240,240 210,240" fill="#FFD60A"/>
  </svg>
  <style>
  .sutol-geo26-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo26-svg{width:100%;height:100%;display:block;}
  .sutol-geo26-bolt{opacity:0;animation: sutol-geo26-flashBolt 3s ease-in-out infinite;}
  .sutol-geo26-flash{opacity:0;animation: sutol-geo26-flashBg 3s ease-in-out infinite;}
  @keyframes sutol-geo26-flashBolt{
    0%,35%{opacity:0;}
    40%{opacity:1;}
    45%{opacity:0.3;}
    50%{opacity:1;}
    55%,100%{opacity:0;}
  }
  @keyframes sutol-geo26-flashBg{
    0%,35%{opacity:0;}
    40%{opacity:0.25;}
    45%,100%{opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-geo26-bolt, .sutol-geo26-flash{animation-duration:12s;}
  }
  </style>
</div>
```

---

## Bileşen 27: Kıyı Erozyonu

**Etiketler (keyword eşleşmesi için):** erozyon, kıyı, kıyı şeridi
**Kategori:** Coğrafya
**Açıklama:** Dalgaların aşındırdığı bir kayalık kıyıdan zamanla kopup düşen kaya parçaları.

```html
<div class="sutol-geo27-wrap">
  <svg class="sutol-geo27-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <rect x="0" y="260" width="400" height="140" fill="#A8DADC" opacity="0.4"/>
    <rect class="sutol-geo27-cliff" x="0" y="120" width="280" height="150" fill="#8D6E63"/>
    <g class="sutol-geo27-debris">
      <circle class="sutol-geo27-rock r1" cx="270" cy="150" r="6" fill="#5C4433"/>
      <circle class="sutol-geo27-rock r2" cx="290" cy="130" r="4" fill="#6D4C41"/>
      <circle class="sutol-geo27-rock r3" cx="250" cy="170" r="5" fill="#5C4433"/>
    </g>
  </svg>
  <style>
  .sutol-geo27-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo27-svg{width:100%;height:100%;display:block;}
  .sutol-geo27-cliff{transform-box:fill-box;transform-origin:left center;animation: sutol-geo27-shrink 10s ease-in-out infinite;}
  @keyframes sutol-geo27-shrink{
    0%{transform:scaleX(1);}
    50%{transform:scaleX(0.85);}
    100%{transform:scaleX(1);}
  }
  .sutol-geo27-rock{animation: sutol-geo27-fall 5s ease-in infinite;opacity:0;}
  .sutol-geo27-rock.r2{animation-delay:1.5s;}
  .sutol-geo27-rock.r3{animation-delay:3s;}
  @keyframes sutol-geo27-fall{
    0%{transform:translateY(0);opacity:1;}
    70%{transform:translateY(90px);opacity:1;}
    100%{transform:translateY(100px);opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-geo27-cliff{animation-duration:30s;}
    .sutol-geo27-rock{animation-duration:15s;}
  }
  </style>
</div>
```

---

## Bileşen 28: Göl Yüzeyinde Halkalar

**Etiketler (keyword eşleşmesi için):** göl, su kaynağı, doğal kaynak
**Kategori:** Coğrafya
**Açıklama:** Durgun bir göl yüzeyinde birbiri ardına genişleyip kaybolan su halkaları.

```html
<div class="sutol-geo28-wrap">
  <canvas class="sutol-geo28-canvas"></canvas>
  <style>
  .sutol-geo28-wrap{position:relative;width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-geo28-canvas{width:100%;height:100%;display:block;}
  @media (prefers-reduced-motion: reduce){
    .sutol-geo28-wrap{ }
  }
  </style>
  <script>
  (function(){
    var script = document.currentScript;
    var wrap = script.closest('.sutol-geo28-wrap');
    var canvas = wrap.querySelector('.sutol-geo28-canvas');
    var ctx = canvas.getContext('2d');
    var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var speed = reduce ? 0.3 : 1;
    var origins = [{x:0.3,y:0.5},{x:0.65,y:0.35},{x:0.5,y:0.7}];
    var startTimes = [0, 1.3, 2.6];
    var period = 4;
    var t0 = performance.now();
    function resize(){
      var rect = wrap.getBoundingClientRect();
      canvas.width = rect.width;
      canvas.height = rect.height;
    }
    resize();
    window.addEventListener('resize', resize);
    function draw(now){
      var elapsed = (now - t0)/1000 * speed;
      var w = canvas.width, h = canvas.height;
      ctx.clearRect(0,0,w,h);
      var maxR = Math.min(w,h)*0.35;
      for(var i=0;i<origins.length;i++){
        var local = (elapsed - startTimes[i]) % period;
        if(local < 0){ local += period; }
        var progress = local/period;
        var r = progress*maxR;
        var alpha = (1-progress)*0.6;
        ctx.beginPath();
        ctx.strokeStyle = 'rgba(69,123,157,'+alpha+')';
        ctx.lineWidth = 2;
        ctx.arc(origins[i].x*w, origins[i].y*h, r, 0, Math.PI*2);
        ctx.stroke();
      }
      requestAnimationFrame(draw);
    }
    requestAnimationFrame(draw);
  })();
  </script>
</div>
```

---

## Bileşen 29: Nüfus Yoğunluğu Haritası

**Etiketler (keyword eşleşmesi için):** nüfus, kentleşme, coğrafi bölge
**Kategori:** Coğrafya
**Açıklama:** Bir bölge haritası üzerinde büyüklükleri nüfus yoğunluğunu temsil eden nabız gibi atan noktalar.

```html
<div class="sutol-geo29-wrap">
  <svg class="sutol-geo29-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <rect x="20" y="20" width="360" height="360" fill="none" stroke="#ADB5BD" stroke-width="1" stroke-dasharray="4 6"/>
    <circle class="sutol-geo29-dot" style="animation-delay:0s" cx="100" cy="120" r="22" fill="#E76F51" opacity="0.7"/>
    <circle class="sutol-geo29-dot" style="animation-delay:0.4s" cx="260" cy="100" r="14" fill="#F4A261" opacity="0.7"/>
    <circle class="sutol-geo29-dot" style="animation-delay:0.8s" cx="180" cy="220" r="30" fill="#E63946" opacity="0.7"/>
    <circle class="sutol-geo29-dot" style="animation-delay:1.2s" cx="300" cy="260" r="10" fill="#F4A261" opacity="0.7"/>
    <circle class="sutol-geo29-dot" style="animation-delay:1.6s" cx="90" cy="300" r="16" fill="#F4A261" opacity="0.7"/>
    <circle class="sutol-geo29-dot" style="animation-delay:2s" cx="230" cy="330" r="20" fill="#E76F51" opacity="0.7"/>
  </svg>
  <style>
  .sutol-geo29-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo29-svg{width:100%;height:100%;display:block;}
  .sutol-geo29-dot{transform-box:fill-box;transform-origin:center;animation: sutol-geo29-pulse 3.6s ease-in-out infinite;}
  @keyframes sutol-geo29-pulse{
    0%,100%{transform:scale(0.9);opacity:0.5;}
    50%{transform:scale(1.15);opacity:0.9;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-geo29-dot{animation-duration:14.4s;}
  }
  </style>
</div>
```

---

## Bileşen 30: Atmosfer Katmanları Kesiti

**Etiketler (keyword eşleşmesi için):** atmosfer, dünya, küre
**Kategori:** Coğrafya
**Açıklama:** Dünyanın çevresinde farklı hızlarda dönen, katmanlı atmosfer halkalarının üç boyutlu kesiti.

```html
<div class="sutol-geo30-wrap">
  <div class="sutol-geo30-scene">
    <div class="sutol-geo30-core"></div>
    <div class="sutol-geo30-ring r1"></div>
    <div class="sutol-geo30-ring r2"></div>
    <div class="sutol-geo30-ring r3"></div>
  </div>
  <style>
  .sutol-geo30-wrap{width:100%;height:100%;background:transparent;perspective:800px;display:flex;align-items:center;justify-content:center;}
  .sutol-geo30-scene{position:relative;width:60%;height:60%;transform-style:preserve-3d;}
  .sutol-geo30-core{position:absolute;inset:35%;border-radius:50%;background:#457B9D;}
  .sutol-geo30-ring{position:absolute;inset:0;border-radius:50%;border:3px dashed;box-sizing:border-box;}
  .sutol-geo30-ring.r1{border-color:#A8DADC;animation: sutol-geo30-spin 8s linear infinite;}
  .sutol-geo30-ring.r2{inset:12%;border-color:#F4A261;animation: sutol-geo30-spin 12s linear infinite reverse;}
  .sutol-geo30-ring.r3{inset:24%;border-color:#E76F51;animation: sutol-geo30-spin 16s linear infinite;}
  @keyframes sutol-geo30-spin{0%{transform:rotateY(0deg);}100%{transform:rotateY(360deg);}}
  @media (prefers-reduced-motion: reduce){
    .sutol-geo30-ring{animation-duration:40s;}
  }
  </style>
</div>
```

---

## Bileşen 31: Kıtaların Ayrılması

**Etiketler (keyword eşleşmesi için):** kıta, yerkabuğu, dünya
**Kategori:** Coğrafya
**Açıklama:** Birbirinden yavaşça uzaklaşan kara parçalarıyla bir süper kıtanın bölünüşü.

```html
<div class="sutol-geo31-wrap">
  <svg class="sutol-geo31-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-geo31-land a" d="M150,150 Q170,120 210,140 Q230,160 210,190 Q180,210 150,190 Z" fill="#588157"/>
    <path class="sutol-geo31-land b" d="M210,190 Q240,180 260,210 Q270,240 240,250 Q210,240 210,210 Z" fill="#3A5A40"/>
    <path class="sutol-geo31-land c" d="M150,190 Q140,220 110,225 Q90,215 100,190 Q125,175 150,190 Z" fill="#588157"/>
  </svg>
  <style>
  .sutol-geo31-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo31-svg{width:100%;height:100%;display:block;}
  .sutol-geo31-land{transform-box:fill-box;transform-origin:center;}
  .sutol-geo31-land.a{animation: sutol-geo31-driftA 7s ease-in-out infinite;}
  .sutol-geo31-land.b{animation: sutol-geo31-driftB 7s ease-in-out infinite;}
  .sutol-geo31-land.c{animation: sutol-geo31-driftC 7s ease-in-out infinite;}
  @keyframes sutol-geo31-driftA{0%,100%{transform:translate(0,0);}50%{transform:translate(0,-6px);}}
  @keyframes sutol-geo31-driftB{0%,100%{transform:translate(0,0);}50%{transform:translate(18px,14px);}}
  @keyframes sutol-geo31-driftC{0%,100%{transform:translate(0,0);}50%{transform:translate(-16px,12px);}}
  @media (prefers-reduced-motion: reduce){
    .sutol-geo31-land{animation-duration:28s;}
  }
  </style>
</div>
```

---

## Bileşen 32: Bozkır Rüzgarında Otlar

**Etiketler (keyword eşleşmesi için):** bitki örtüsü, rüzgar, coğrafi bölge
**Kategori:** Coğrafya
**Açıklama:** Esen rüzgarla birlikte dalga dalga sallanan bir bozkır otlağı.

```html
<div class="sutol-geo32-wrap">
  <svg class="sutol-geo32-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <rect x="0" y="300" width="400" height="100" fill="#DDA15E" opacity="0.3"/>
    <g class="sutol-geo32-grass" stroke="#606C38" stroke-width="5" fill="none" stroke-linecap="round">
      <path class="sutol-geo32-blade" style="animation-delay:0s" d="M40,340 Q46,300 36,260"/>
      <path class="sutol-geo32-blade" style="animation-delay:0.2s" d="M80,340 Q88,290 76,250"/>
      <path class="sutol-geo32-blade" style="animation-delay:0.4s" d="M120,340 Q128,295 118,255"/>
      <path class="sutol-geo32-blade" style="animation-delay:0.6s" d="M160,340 Q168,300 158,260"/>
      <path class="sutol-geo32-blade" style="animation-delay:0.8s" d="M200,340 Q208,290 198,250"/>
      <path class="sutol-geo32-blade" style="animation-delay:1s" d="M240,340 Q248,300 238,260"/>
      <path class="sutol-geo32-blade" style="animation-delay:1.2s" d="M280,340 Q288,295 278,255"/>
      <path class="sutol-geo32-blade" style="animation-delay:1.4s" d="M320,340 Q328,300 318,260"/>
      <path class="sutol-geo32-blade" style="animation-delay:1.6s" d="M360,340 Q368,290 358,250"/>
    </g>
  </svg>
  <style>
  .sutol-geo32-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo32-svg{width:100%;height:100%;display:block;}
  .sutol-geo32-blade{transform-box:fill-box;transform-origin:bottom center;animation: sutol-geo32-sway 2.6s ease-in-out infinite;}
  @keyframes sutol-geo32-sway{0%,100%{transform:rotate(-6deg);}50%{transform:rotate(8deg);}}
  @media (prefers-reduced-motion: reduce){
    .sutol-geo32-blade{animation-duration:10.4s;}
  }
  </style>
</div>
```

---

## Bileşen 33: Karstik Mağara Damlaları

**Etiketler (keyword eşleşmesi için):** kayaç, erozyon, yerkabuğu
**Kategori:** Coğrafya
**Açıklama:** Tavandan sarkan bir sarkıtın büyümesi ve düzenli aralıklarla düşen su damlaları.

```html
<div class="sutol-geo33-wrap">
  <svg class="sutol-geo33-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-geo33-stalactite" d="M170,20 L170,110 Q170,140 190,140 Q210,140 210,110 L210,20 Z" fill="#8D99AE" stroke="#495057" stroke-width="2" pathLength="100" stroke-dasharray="100" stroke-dashoffset="100"/>
    <path class="sutol-geo33-stalagmite" d="M170,380 L170,300 Q170,270 190,270 Q210,270 210,300 L210,380 Z" fill="#8D99AE" opacity="0.85"/>
  </svg>
  <div class="sutol-geo33-drop"></div>
  <style>
  .sutol-geo33-wrap{position:relative;width:100%;height:100%;background:transparent;}
  .sutol-geo33-svg{position:absolute;inset:0;width:100%;height:100%;display:block;}
  .sutol-geo33-stalactite{animation: sutol-geo33-grow 6s ease-in-out infinite;}
  @keyframes sutol-geo33-grow{
    0%{stroke-dashoffset:100;}
    30%{stroke-dashoffset:0;}
    100%{stroke-dashoffset:0;}
  }
  .sutol-geo33-drop{position:absolute;width:2.5%;height:2.5%;border-radius:50%;background:#457B9D;top:35%;left:47%;offset-path: path("M0,0 C10,60 -10,140 0,220");offset-rotate:0deg;animation: sutol-geo33-fall 3s ease-in infinite;opacity:0;}
  @keyframes sutol-geo33-fall{
    0%{offset-distance:0%;opacity:0;}
    10%{opacity:1;}
    90%{opacity:1;}
    100%{offset-distance:100%;opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-geo33-stalactite{animation-duration:20s;}
    .sutol-geo33-drop{animation-duration:10s;}
  }
  </style>
</div>
```

---

## Bileşen 34: Coğrafi Konum İşaretleyicisi

**Etiketler (keyword eşleşmesi için):** harita, coğrafi bölge, enlem
**Kategori:** Coğrafya
**Açıklama:** Bir ızgara harita üzerine sekerek inen ve konumunu halkalarla işaretleyen bir yer imi.

```html
<div class="sutol-geo34-wrap">
  <svg class="sutol-geo34-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <g stroke="#ADB5BD" stroke-width="1" opacity="0.5">
      <line x1="0" y1="100" x2="400" y2="100"/>
      <line x1="0" y1="200" x2="400" y2="200"/>
      <line x1="0" y1="300" x2="400" y2="300"/>
      <line x1="100" y1="0" x2="100" y2="400"/>
      <line x1="200" y1="0" x2="200" y2="400"/>
      <line x1="300" y1="0" x2="300" y2="400"/>
    </g>
    <circle class="sutol-geo34-ripple" cx="200" cy="320" r="10" fill="none" stroke="#E63946" stroke-width="3"/>
    <path class="sutol-geo34-pin" d="M200,80 C170,80 150,102 150,132 C150,172 200,230 200,230 C200,230 250,172 250,132 C250,102 230,80 200,80 Z" fill="#E63946"/>
    <circle class="sutol-geo34-pin-hole" cx="200" cy="130" r="16" fill="#FFFFFF"/>
  </svg>
  <style>
  .sutol-geo34-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo34-svg{width:100%;height:100%;display:block;}
  .sutol-geo34-pin, .sutol-geo34-pin-hole{transform-box:fill-box;transform-origin:bottom center;animation: sutol-geo34-drop 2.4s cubic-bezier(.34,1.56,.64,1) infinite;}
  @keyframes sutol-geo34-drop{
    0%{transform:translateY(-140px);opacity:0;}
    55%{transform:translateY(0);opacity:1;}
    70%{transform:translateY(-14px);}
    85%{transform:translateY(0);}
    100%{transform:translateY(0);opacity:1;}
  }
  .sutol-geo34-ripple{transform-box:fill-box;transform-origin:center;animation: sutol-geo34-ring 2.4s ease-out infinite;}
  @keyframes sutol-geo34-ring{
    0%,54%{transform:scale(0);opacity:0;}
    60%{transform:scale(0.4);opacity:0.8;}
    100%{transform:scale(2.2);opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-geo34-pin, .sutol-geo34-pin-hole, .sutol-geo34-ripple{animation-duration:9.6s;}
  }
  </style>
</div>
```

---

## Bileşen 35: Dünya Zaman Dilimleri

**Etiketler (keyword eşleşmesi için):** dünya, boylam, küre
**Kategori:** Coğrafya
**Açıklama:** Bir küre üzerinde sırayla aydınlanan dikey zaman dilimi şeritleri.

```html
<div class="sutol-geo35-wrap">
  <svg class="sutol-geo35-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <circle cx="200" cy="200" r="150" fill="#1D3557" opacity="0.15"/>
    <defs>
      <clipPath id="sutol-geo35-clip"><circle cx="200" cy="200" r="150"/></clipPath>
    </defs>
    <g clip-path="url(#sutol-geo35-clip)">
      <rect class="sutol-geo35-band" style="animation-delay:0s" x="50" y="50" width="30" height="300" fill="#F4A261"/>
      <rect class="sutol-geo35-band" style="animation-delay:0.3s" x="90" y="50" width="30" height="300" fill="#F4A261"/>
      <rect class="sutol-geo35-band" style="animation-delay:0.6s" x="130" y="50" width="30" height="300" fill="#F4A261"/>
      <rect class="sutol-geo35-band" style="animation-delay:0.9s" x="170" y="50" width="30" height="300" fill="#F4A261"/>
      <rect class="sutol-geo35-band" style="animation-delay:1.2s" x="210" y="50" width="30" height="300" fill="#F4A261"/>
      <rect class="sutol-geo35-band" style="animation-delay:1.5s" x="250" y="50" width="30" height="300" fill="#F4A261"/>
      <rect class="sutol-geo35-band" style="animation-delay:1.8s" x="290" y="50" width="30" height="300" fill="#F4A261"/>
      <rect class="sutol-geo35-band" style="animation-delay:2.1s" x="330" y="50" width="30" height="300" fill="#F4A261"/>
    </g>
    <circle cx="200" cy="200" r="150" fill="none" stroke="#264653" stroke-width="3"/>
  </svg>
  <style>
  .sutol-geo35-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo35-svg{width:100%;height:100%;display:block;}
  .sutol-geo35-band{opacity:0.12;animation: sutol-geo35-light 2.4s ease-in-out infinite;}
  @keyframes sutol-geo35-light{0%,80%,100%{opacity:0.12;}40%{opacity:0.75;}}
  @media (prefers-reduced-motion: reduce){
    .sutol-geo35-band{animation-duration:9.6s;}
  }
  </style>
</div>
```

---

## Bileşen 36: Buz Kütlesi Erimesi

**Etiketler (keyword eşleşmesi için):** buzul, kutup, iklim
**Kategori:** Coğrafya
**Açıklama:** Giderek küçülen bir buz kütlesinin altında yükselen erime suları.

```html
<div class="sutol-geo36-wrap">
  <svg class="sutol-geo36-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <rect class="sutol-geo36-water" x="0" y="260" width="400" height="140" fill="#457B9D" opacity="0.6"/>
    <polygon class="sutol-geo36-ice" points="120,300 150,180 220,180 260,220 240,300" fill="#E8F1F2"/>
    <g class="sutol-geo36-drops">
      <circle class="sutol-geo36-drip" style="animation-delay:0s" cx="170" cy="230" r="3" fill="#A8DADC"/>
      <circle class="sutol-geo36-drip" style="animation-delay:1s" cx="210" cy="220" r="3" fill="#A8DADC"/>
    </g>
  </svg>
  <style>
  .sutol-geo36-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo36-svg{width:100%;height:100%;display:block;}
  .sutol-geo36-ice{transform-box:fill-box;transform-origin:bottom center;animation: sutol-geo36-melt 8s ease-in-out infinite;}
  @keyframes sutol-geo36-melt{
    0%{transform:scaleY(1) scaleX(1);}
    50%{transform:scaleY(0.7) scaleX(1.1);}
    100%{transform:scaleY(1) scaleX(1);}
  }
  .sutol-geo36-water{transform-box:fill-box;transform-origin:bottom;animation: sutol-geo36-rise 8s ease-in-out infinite;}
  @keyframes sutol-geo36-rise{
    0%{transform:translateY(0);}
    50%{transform:translateY(-12px);}
    100%{transform:translateY(0);}
  }
  .sutol-geo36-drip{animation: sutol-geo36-drop 2s ease-in infinite;opacity:0;}
  @keyframes sutol-geo36-drop{
    0%{transform:translateY(0);opacity:0;}
    10%{opacity:1;}
    80%{transform:translateY(60px);opacity:1;}
    100%{transform:translateY(70px);opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-geo36-ice, .sutol-geo36-water{animation-duration:32s;}
    .sutol-geo36-drip{animation-duration:8s;}
  }
  </style>
</div>
```

---

## Bileşen 37: Coğrafi Kesit / Yükselti Profili

**Etiketler (keyword eşleşmesi için):** dağ silsilesi, yerkabuğu, coğrafi bölge
**Kategori:** Coğrafya
**Açıklama:** Bir arazinin yükselti değişimini gösteren, çizilerek beliren bir topografya çizgisi.

```html
<div class="sutol-geo37-wrap">
  <svg class="sutol-geo37-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-geo37-fill" d="M0,320 L40,300 L90,340 L140,220 L190,260 L240,150 L290,200 L340,120 L400,180 L400,400 L0,400 Z" fill="#81B29A" opacity="0.35"/>
    <path class="sutol-geo37-line" d="M0,320 L40,300 L90,340 L140,220 L190,260 L240,150 L290,200 L340,120 L400,180" fill="none" stroke="#2A6F55" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" pathLength="100" stroke-dasharray="100" stroke-dashoffset="100"/>
  </svg>
  <style>
  .sutol-geo37-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo37-svg{width:100%;height:100%;display:block;}
  .sutol-geo37-line{animation: sutol-geo37-draw 4s ease-in-out infinite;}
  @keyframes sutol-geo37-draw{
    0%{stroke-dashoffset:100;}
    60%{stroke-dashoffset:0;}
    100%{stroke-dashoffset:0;}
  }
  .sutol-geo37-fill{opacity:0;animation: sutol-geo37-fade 4s ease-in-out infinite;}
  @keyframes sutol-geo37-fade{0%,40%{opacity:0;}80%,100%{opacity:0.35;}}
  @media (prefers-reduced-motion: reduce){
    .sutol-geo37-line, .sutol-geo37-fill{animation-duration:16s;}
  }
  </style>
</div>
```

---

## Bileşen 38: Mercator Projeksiyon Izgarası

**Etiketler (keyword eşleşmesi için):** harita, boylam, enlem
**Kategori:** Coğrafya
**Açıklama:** Üç boyutlu uzayda eğilip bükülerek harita projeksiyon çarpıtmasını gösteren bir ızgara.

```html
<div class="sutol-geo38-wrap">
  <div class="sutol-geo38-scene">
    <div class="sutol-geo38-grid"></div>
  </div>
  <style>
  .sutol-geo38-wrap{width:100%;height:100%;background:transparent;perspective:700px;display:flex;align-items:center;justify-content:center;}
  .sutol-geo38-scene{width:70%;height:70%;transform-style:preserve-3d;}
  .sutol-geo38-grid{
    width:100%;height:100%;
    background-image:
      repeating-linear-gradient(to right, #457B9D 0, #457B9D 2px, transparent 2px, transparent 14%),
      repeating-linear-gradient(to bottom, #457B9D 0, #457B9D 2px, transparent 2px, transparent 14%);
    animation: sutol-geo38-warp 10s ease-in-out infinite;
  }
  @keyframes sutol-geo38-warp{
    0%,100%{transform:rotateX(0deg) rotateY(0deg);}
    25%{transform:rotateX(20deg) rotateY(15deg);}
    50%{transform:rotateX(0deg) rotateY(-20deg);}
    75%{transform:rotateX(-15deg) rotateY(10deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-geo38-grid{animation-duration:40s;}
  }
  </style>
</div>
```

---

## Bileşen 39: Yarımada ve Boğaz Akıntısı

**Etiketler (keyword eşleşmesi için):** boğaz, yarımada, deniz
**Kategori:** Coğrafya
**Açıklama:** İki kara parçası arasındaki dar bir boğazdan akan su akıntısı okları.

```html
<div class="sutol-geo39-wrap">
  <svg class="sutol-geo39-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <path d="M40,80 C120,60 140,140 100,200 C60,260 60,320 130,360" fill="#588157" opacity="0.5"/>
    <path d="M360,60 C280,50 260,140 300,200 C340,260 340,320 270,370" fill="#588157" opacity="0.5"/>
    <path class="sutol-geo39-channel" d="M150,40 C170,140 170,260 150,380" fill="none" stroke="#A8DADC" stroke-width="30" opacity="0.4"/>
  </svg>
  <div class="sutol-geo39-arrow a1"></div>
  <div class="sutol-geo39-arrow a2"></div>
  <div class="sutol-geo39-arrow a3"></div>
  <style>
  .sutol-geo39-wrap{position:relative;width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-geo39-svg{position:absolute;inset:0;width:100%;height:100%;display:block;}
  .sutol-geo39-arrow{position:absolute;width:14px;height:8px;background:#1D3557;clip-path:polygon(0 0,100% 50%,0 100%);
    offset-path: path("M150,40 C170,140 170,260 150,380");
    offset-rotate:auto;
    animation: sutol-geo39-flow 3s linear infinite;
    opacity:0;
  }
  .sutol-geo39-arrow.a2{animation-delay:1s;}
  .sutol-geo39-arrow.a3{animation-delay:2s;}
  @keyframes sutol-geo39-flow{
    0%{offset-distance:0%;opacity:0;}
    10%{opacity:1;}
    90%{opacity:1;}
    100%{offset-distance:100%;opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-geo39-arrow{animation-duration:12s;}
  }
  </style>
</div>
```

---

## Bileşen 40: Yeraltı Suyu Akiferi

**Etiketler (keyword eşleşmesi için):** doğal kaynak, yerkabuğu, su kaynağı
**Kategori:** Coğrafya
**Açıklama:** Yağmur sularının toprak katmanlarından süzülüp yeraltı su tablasına ulaştığı bir akifer kesiti.

```html
<div class="sutol-geo40-wrap">
  <svg class="sutol-geo40-svg" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">
    <rect x="0" y="0" width="400" height="150" fill="#8D6E63" opacity="0.3"/>
    <rect x="0" y="150" width="400" height="120" fill="#BC8A5F" opacity="0.5"/>
    <rect class="sutol-geo40-aquifer" x="0" y="270" width="400" height="130" fill="#457B9D" opacity="0.55"/>
    <line class="sutol-geo40-table" x1="0" y1="270" x2="400" y2="270" stroke="#1D3557" stroke-width="3"/>
    <g class="sutol-geo40-infiltration">
      <circle class="sutol-geo40-dot" style="animation-delay:0s" cx="80" cy="20" r="4" fill="#A8DADC"/>
      <circle class="sutol-geo40-dot" style="animation-delay:0.7s" cx="180" cy="20" r="4" fill="#A8DADC"/>
      <circle class="sutol-geo40-dot" style="animation-delay:1.4s" cx="280" cy="20" r="4" fill="#A8DADC"/>
      <circle class="sutol-geo40-dot" style="animation-delay:2.1s" cx="340" cy="20" r="4" fill="#A8DADC"/>
    </g>
  </svg>
  <style>
  .sutol-geo40-wrap{width:100%;height:100%;background:transparent;}
  .sutol-geo40-svg{width:100%;height:100%;display:block;}
  .sutol-geo40-dot{animation: sutol-geo40-seep 4.2s ease-in infinite;opacity:0;}
  @keyframes sutol-geo40-seep{
    0%{transform:translateY(0);opacity:0;}
    5%{opacity:1;}
    85%{transform:translateY(250px);opacity:1;}
    100%{transform:translateY(260px);opacity:0;}
  }
  .sutol-geo40-table{animation: sutol-geo40-fluct 6s ease-in-out infinite;}
  @keyframes sutol-geo40-fluct{
    0%,100%{transform:translateY(0);}
    50%{transform:translateY(-10px);}
  }
  .sutol-geo40-aquifer{animation: sutol-geo40-aqfluct 6s ease-in-out infinite;}
  @keyframes sutol-geo40-aqfluct{
    0%,100%{transform:translateY(0);}
    50%{transform:translateY(-10px);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-geo40-dot{animation-duration:16.8s;}
    .sutol-geo40-table, .sutol-geo40-aquifer{animation-duration:24s;}
  }
  </style>
</div>
```

---

===BULLETS===
- Bileşen 21 (Deprem Sismografı): Canvas + requestAnimationFrame ile sürekli çizilen dalga formu; ağır DOM manipülasyonu yok, sadece canvas çizimi, reduced-motion'da hız 1/3'e düşer.
- Bileşen 22 (Çöl Kum Tepeleri): CSS transform (translateX) keyframe animasyonlu katmanlı SVG path'ler; GPU dostu, reduced-motion'da süre ~3.7x uzar.
- Bileşen 23 (Ozon Tabakası Deliği): CSS transform scale + opacity keyframe ile "delik" büyüyüp küçülür; radialGradient statik, hafif render yükü.
- Bileşen 24 (Tektonik Plaka Çarpışması): CSS 3D perspective/rotateX + translateX/translateZ keyframe animasyonu; transform-only, GPU hızlandırmalı.
- Bileşen 25 (Rüzgar Gülü Pusulası): CSS transform rotate keyframe ile ibre dönüşü; tek eleman animasyonu, düşük maliyetli.
- Bileşen 26 (Fırtına Bulutu ve Şimşek): CSS opacity keyframe ile şimşek flaş efekti; statik şekiller üzerinde sadece opacity değişimi, düşük maliyetli.
- Bileşen 27 (Kıyı Erozyonu): CSS transform scaleX (uçurum) + translateY/opacity (düşen kayalar) keyframe animasyonu; transform/opacity only.
- Bileşen 28 (Göl Yüzeyinde Halkalar): Canvas + requestAnimationFrame ile çoklu genişleyen halka çizimi; reduced-motion'da hız 0.3x'e düşer.
- Bileşen 29 (Nüfus Yoğunluğu Haritası): CSS transform scale + opacity keyframe, staggered animation-delay ile nabız efekti; transform-box:fill-box kullanır.
- Bileşen 30 (Atmosfer Katmanları Kesiti): CSS 3D perspective + rotateY keyframe ile farklı hızlarda dönen halkalar; transform-only, GPU dostu.
- Bileşen 31 (Kıtaların Ayrılması): CSS transform translate keyframe ile SVG path'lerin ayrılma animasyonu; transform-box:fill-box, düşük maliyetli.
- Bileşen 32 (Bozkır Rüzgarında Otlar): CSS transform rotate keyframe, staggered delay ile çoklu ot yaprağı sallanması; transform-box:fill-box.
- Bileşen 33 (Karstik Mağara Damlaları): SVG stroke-dashoffset keyframe (sarkıt büyümesi) + CSS offset-path (motion-path) ile damla düşüşü; iki farklı teknik birleşimi.
- Bileşen 34 (Coğrafi Konum İşaretleyicisi): CSS transform translateY + cubic-bezier keyframe (zıplama) ve scale keyframe (halka); transform/opacity only.
- Bileşen 35 (Dünya Zaman Dilimleri): CSS opacity keyframe, staggered animation-delay ile sıralı aydınlanan şeritler; clipPath ile küre sınırlaması, düşük maliyetli.
- Bileşen 36 (Buz Kütlesi Erimesi): CSS transform scaleY/scaleX (erime) + translateY (su yükselmesi, damla düşüşü) keyframe animasyonu; transform-box:fill-box.
- Bileşen 37 (Coğrafi Kesit / Yükselti Profili): SVG stroke-dasharray/dashoffset (pathLength ile) keyframe ile çizgi çizilme efekti + opacity fade; düşük maliyetli.
- Bileşen 38 (Mercator Projeksiyon Izgarası): CSS 3D perspective + rotateX/rotateY keyframe ile arka plan gradient ızgara çarpıtması; transform-only, GPU dostu.
- Bileşen 39 (Yarımada ve Boğaz Akıntısı): CSS offset-path (motion-path) ile eğrisel yol boyunca hareket eden ok elemanları; staggered animation-delay.
- Bileşen 40 (Yeraltı Suyu Akiferi): CSS transform translateY keyframe, staggered delay ile sızan damla noktaları + su tablası dalgalanması; transform/opacity only.
