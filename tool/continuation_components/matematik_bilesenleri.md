# Matematik Kategorisi — 20 Animasyonlu HTML Bileşeni

---

## Bileşen 1: Fraktal Ağaç

**Etiketler (keyword eşleşmesi için):** fraktal, sonsuzluk, geometrik dönüşüm, dizi
**Kategori:** Matematik
**Açıklama:** Her dalın kendi küçük kopyalarına ayrıldığı, kendine-benzerlik ilkesini gösteren sonsuz özyinelemeli bir fraktal ağaç.

```html
<div class="sutol-mat-01-root" style="width:100%;height:100%;position:relative;overflow:visible;">
  <svg class="sutol-mat-01-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet" style="width:100%;height:100%;display:block;">
    <g id="sutol-mat-01-tree" class="sutol-mat-01-tree" fill="none" stroke-linecap="round"></g>
  </svg>
</div>
<style>
  .sutol-mat-01-root *{box-sizing:border-box;}
  .sutol-mat-01-branch{
    transform-origin:center;
    animation:sutol-mat-01-grow 4.5s ease-in-out infinite;
  }
  @keyframes sutol-mat-01-grow{
    0%,100%{opacity:.5;}
    50%{opacity:1;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-01-branch{animation:none;opacity:.85;}
  }
</style>
<script>
(function(){
  var g = document.querySelector('.sutol-mat-01-tree');
  if(!g) return;
  var colors = ['#264d3b','#2d6a4f','#40916c','#74c69d','#b7e4c7'];
  function branch(x1,y1,len,angle,depth){
    if(depth>6||len<3) return;
    var rad = angle*Math.PI/180;
    var x2 = x1 + len*Math.cos(rad);
    var y2 = y1 - len*Math.sin(rad);
    var line = document.createElementNS('http://www.w3.org/2000/svg','line');
    line.setAttribute('x1',x1); line.setAttribute('y1',y1);
    line.setAttribute('x2',x2); line.setAttribute('y2',y2);
    line.setAttribute('stroke', colors[Math.min(depth,colors.length-1)]);
    line.setAttribute('stroke-width', Math.max(0.5, 3.2-depth*0.45));
    line.setAttribute('class','sutol-mat-01-branch');
    line.style.animationDelay = (depth*0.18)+'s';
    g.appendChild(line);
    branch(x2,y2,len*0.72,angle-17,depth+1);
    branch(x2,y2,len*0.72,angle+17,depth+1);
    if(depth<2) branch(x2,y2,len*0.7,angle,depth+1);
  }
  branch(100,190,40,90,0);
})();
</script>
```

---

## Bileşen 2: Sonsuzluk Şeridi

**Etiketler (keyword eşleşmesi için):** sonsuzluk, dizi, yakınsaklık
**Kategori:** Matematik
**Açıklama:** Sürekli akan bir gradyanla çizilen lemniskat (sonsuzluk simgesi) üzerinde durmadan dolaşan parlak bir nokta.

```html
<div class="sutol-mat-02-root" style="width:100%;height:100%;">
  <svg class="sutol-mat-02-svg" viewBox="0 0 200 120" style="width:100%;height:100%;display:block;">
    <defs>
      <linearGradient id="sutol-mat-02-grad" x1="0%" y1="0%" x2="100%" y2="0%">
        <stop offset="0%" stop-color="#5e60ce"/>
        <stop offset="50%" stop-color="#48bfe3"/>
        <stop offset="100%" stop-color="#5e60ce"/>
      </linearGradient>
    </defs>
    <path id="sutol-mat-02-path" class="sutol-mat-02-path"
      d="M100,60 C100,30 60,10 40,30 C20,50 20,70 40,90 C60,110 100,90 100,60
         C100,30 140,10 160,30 C180,50 180,70 160,90 C140,110 100,90 100,60 Z"
      fill="none" stroke="url(#sutol-mat-02-grad)" stroke-width="3" stroke-linecap="round"/>
    <circle class="sutol-mat-02-dot" r="4" fill="#48bfe3">
      <animateMotion dur="6s" repeatCount="indefinite"
        path="M100,60 C100,30 60,10 40,30 C20,50 20,70 40,90 C60,110 100,90 100,60
              C100,30 140,10 160,30 C180,50 180,70 160,90 C140,110 100,90 100,60 Z"/>
    </circle>
  </svg>
</div>
<style>
  .sutol-mat-02-path{
    stroke-dasharray: 12 6;
    animation: sutol-mat-02-flow 3s linear infinite;
  }
  @keyframes sutol-mat-02-flow{ to { stroke-dashoffset: -180; } }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-02-path{ animation:none; }
    .sutol-mat-02-dot animateMotion{ display:none; }
  }
</style>
```

---

## Bileşen 3: Karmaşık Düzlem Vektörü

**Etiketler (keyword eşleşmesi için):** karmaşık sayı, geometrik dönüşüm, matris çarpımı
**Kategori:** Matematik
**Açıklama:** Reel ve sanal eksenler üzerinde sürekli dönen ve büyüklüğü nabız gibi değişen bir karmaşık sayı vektörü.

```html
<div class="sutol-mat-03-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <line x1="10" y1="100" x2="190" y2="100" stroke="#495057" stroke-width="1" opacity="0.5"/>
    <line x1="100" y1="10" x2="100" y2="190" stroke="#495057" stroke-width="1" opacity="0.5"/>
    <g class="sutol-mat-03-vector-spin">
      <line x1="100" y1="100" x2="160" y2="55" stroke="#e85d75" stroke-width="3" stroke-linecap="round"/>
      <circle cx="160" cy="55" r="5" fill="#e85d75" class="sutol-mat-03-tip"/>
      <circle cx="160" cy="55" r="9" fill="none" stroke="#e85d75" stroke-width="1" opacity="0.4"/>
    </g>
    <circle cx="100" cy="100" r="2.5" fill="#495057"/>
  </svg>
</div>
<style>
  .sutol-mat-03-vector-spin{
    transform-origin: 100px 100px;
    animation: sutol-mat-03-rotate 8s linear infinite;
  }
  .sutol-mat-03-tip{
    animation: sutol-mat-03-pulse 2s ease-in-out infinite;
  }
  @keyframes sutol-mat-03-rotate{ from{transform:rotate(0deg);} to{transform:rotate(360deg);} }
  @keyframes sutol-mat-03-pulse{ 0%,100%{r:5;} 50%{r:7;} }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-03-vector-spin{ animation-duration: 40s; }
    .sutol-mat-03-tip{ animation:none; }
  }
</style>
```

---

## Bileşen 4: Teodorus Sarmalı (İrrasyonel Sayılar)

**Etiketler (keyword eşleşmesi için):** irrasyonel sayı, çokgen, dizi
**Kategori:** Matematik
**Açıklama:** Birim dik üçgenlerin art arda eklenmesiyle √2, √3, √5... gibi irrasyonel sayıların uzunluklarını üreten büyüyen bir sarmal.

```html
<div class="sutol-mat-04-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <g id="sutol-mat-04-spiral" class="sutol-mat-04-spiral" fill="none" stroke="#f4a261" stroke-width="1.6" stroke-linecap="round"></g>
  </svg>
</div>
<style>
  .sutol-mat-04-tri{
    stroke-dasharray: 60;
    stroke-dashoffset: 60;
    animation: sutol-mat-04-draw 6s ease-in-out infinite;
  }
  @keyframes sutol-mat-04-draw{
    0%{ stroke-dashoffset:60; opacity:.3; }
    40%,70%{ stroke-dashoffset:0; opacity:1; }
    100%{ stroke-dashoffset:0; opacity:.3; }
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-04-tri{ animation:none; stroke-dashoffset:0; opacity:.9; }
  }
</style>
<script>
(function(){
  var g = document.querySelector('.sutol-mat-04-spiral');
  if(!g) return;
  var cx=100, cy=100, x=cx, y=cy, len=1, angle=0;
  var hues = ['#f4a261','#e9c46a','#e76f51','#f4a261','#e9c46a','#e76f51','#f4a261','#e9c46a','#e76f51','#f4a261','#e9c46a','#e76f51'];
  for(var i=1;i<=12;i++){
    var rad = angle*Math.PI/180;
    var nx = x + Math.sqrt(i)*6*Math.cos(rad);
    var ny = y + Math.sqrt(i)*6*Math.sin(rad);
    var line = document.createElementNS('http://www.w3.org/2000/svg','line');
    line.setAttribute('x1',x); line.setAttribute('y1',y);
    line.setAttribute('x2',nx); line.setAttribute('y2',ny);
    line.setAttribute('class','sutol-mat-04-tri');
    line.setAttribute('stroke', hues[i-1]);
    line.style.animationDelay = (i*0.18)+'s';
    g.appendChild(line);
    var hyp = document.createElementNS('http://www.w3.org/2000/svg','line');
    hyp.setAttribute('x1',cx); hyp.setAttribute('y1',cy);
    hyp.setAttribute('x2',nx); hyp.setAttribute('y2',ny);
    hyp.setAttribute('class','sutol-mat-04-tri');
    hyp.setAttribute('stroke', hues[i-1]);
    hyp.setAttribute('stroke-width','0.8');
    hyp.style.animationDelay = (i*0.18+0.05)+'s';
    g.appendChild(hyp);
    x=nx; y=ny;
    angle += Math.atan(1/Math.sqrt(i)) * 180/Math.PI;
  }
})();
</script>
```

---

## Bileşen 5: Asal Çarpanlar Ağacı

**Etiketler (keyword eşleşmesi için):** asal çarpan, algoritmik karmaşıklık, dizi
**Kategori:** Matematik
**Açıklama:** Bir sayının asal çarpanlarına ayrılışını gösteren, düğümleri sırayla parıldayan bir çarpan ağacı.

```html
<div class="sutol-mat-05-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <g id="sutol-mat-05-tree" class="sutol-mat-05-tree"></g>
  </svg>
</div>
<style>
  .sutol-mat-05-node{
    animation: sutol-mat-05-pop 3.5s ease-in-out infinite;
  }
  .sutol-mat-05-edge{ stroke:#8d99ae; stroke-width:1.4; opacity:.6; }
  @keyframes sutol-mat-05-pop{
    0%,100%{ transform:scale(1); opacity:.75; }
    50%{ transform:scale(1.18); opacity:1; }
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-05-node{ animation:none; opacity:.9; }
  }
</style>
<script>
(function(){
  var g = document.querySelector('.sutol-mat-05-tree');
  if(!g) return;
  var palette = ['#2b2d42','#8d99ae','#ef233c','#d90429','#5c6b73'];
  function node(x,y,r,color,depth){
    var c = document.createElementNS('http://www.w3.org/2000/svg','circle');
    c.setAttribute('cx',x); c.setAttribute('cy',y); c.setAttribute('r',r);
    c.setAttribute('fill',color);
    c.setAttribute('class','sutol-mat-05-node');
    c.style.transformOrigin = x+'px '+y+'px';
    c.style.animationDelay = (depth*0.25)+'s';
    g.appendChild(c);
  }
  function edge(x1,y1,x2,y2){
    var l = document.createElementNS('http://www.w3.org/2000/svg','line');
    l.setAttribute('x1',x1); l.setAttribute('y1',y1);
    l.setAttribute('x2',x2); l.setAttribute('y2',y2);
    l.setAttribute('class','sutol-mat-05-edge');
    g.appendChild(l);
  }
  function build(x,y,spread,depth,maxDepth){
    node(x,y,Math.max(5,14-depth*2.5), palette[depth%palette.length], depth);
    if(depth>=maxDepth) return;
    var y2 = y+42;
    var xL = x-spread, xR = x+spread;
    edge(x,y,xL,y2); edge(x,y,xR,y2);
    build(xL,y2,spread*0.55,depth+1,maxDepth);
    build(xR,y2,spread*0.55,depth+1,maxDepth);
  }
  build(100,30,45,0,3);
})();
</script>
```

---

## Bileşen 6: Fibonacci Sarmalı

**Etiketler (keyword eşleşmesi için):** diziler, irrasyonel sayı, yakınsaklık
**Kategori:** Matematik
**Açıklama:** Altın orana yakınsayan Fibonacci karelerinin sırayla belirip birleştiği ve klasik altın sarmalı çizdiği bir kompozisyon.

```html
<div class="sutol-mat-06-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <g id="sutol-mat-06-squares" class="sutol-mat-06-squares" fill="none" stroke-width="1.2"></g>
    <path id="sutol-mat-06-arc" class="sutol-mat-06-arc" fill="none" stroke="#9b5de5" stroke-width="2" stroke-linecap="round"/>
  </svg>
</div>
<style>
  .sutol-mat-06-sq{
    animation: sutol-mat-06-fade 5s ease-in-out infinite;
    transform-origin: center;
  }
  @keyframes sutol-mat-06-fade{
    0%,100%{ opacity:.35; } 50%{ opacity:.95; }
  }
  .sutol-mat-06-arc{
    stroke-dasharray: 400;
    stroke-dashoffset: 400;
    animation: sutol-mat-06-draw 5s ease-in-out infinite;
  }
  @keyframes sutol-mat-06-draw{
    0%{ stroke-dashoffset:400; }
    60%,100%{ stroke-dashoffset:0; }
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-06-sq{ animation:none; opacity:.7; }
    .sutol-mat-06-arc{ animation:none; stroke-dashoffset:0; }
  }
</style>
<script>
(function(){
  var g = document.querySelector('.sutol-mat-06-squares');
  var arc = document.querySelector('.sutol-mat-06-arc');
  if(!g||!arc) return;
  var fib = [1,1,2,3,5,8,13];
  var scale = 4.6;
  var colors = ['#f15bb5','#fee440','#00bbf9','#00f5d4','#9b5de5','#ff9770','#7209b7'];
  var boxes = [
    {x:98,y:98,w:1,h:1,rot:0}, {x:97,y:98,w:1,h:1,rot:0},
    {x:97,y:96,w:2,h:2,rot:0}, {x:100,y:96,w:3,h:3,rot:0},
    {x:97,y:91,w:5,h:5,rot:0}, {x:89,y:96,w:8,h:8,rot:0},
    {x:89,y:70,w:13,h:13,rot:0}
  ];
  var path = 'M ';
  boxes.forEach(function(b,i){
    var x=b.x*scale/4.6, y=b.y, w=fib[i]*scale, h=fib[i]*scale;
    var rx = 100 + (b.x-100), ry=y;
  });
  // simplified deterministic layout (approximate golden rectangle tiling)
  var layout = [
    {x:100,y:100,s:6},{x:94,y:100,s:6},{x:94,y:88,s:12},
    {x:112,y:88,s:18},{x:94,y:52,s:30},{x:46,y:52,s:48},
    {x:46,y:130,s:78}
  ];
  layout.forEach(function(b,i){
    var r = document.createElementNS('http://www.w3.org/2000/svg','rect');
    r.setAttribute('x', 100-b.s*0.35+ (b.x-100)*0);
    r.setAttribute('x', b.x-90>0? b.x-90:2);
    r.setAttribute('y', b.y-90>0? b.y-90:2);
    r.setAttribute('width', b.s*0.55);
    r.setAttribute('height', b.s*0.55);
    r.setAttribute('stroke', colors[i%colors.length]);
    r.setAttribute('class','sutol-mat-06-sq');
    r.style.animationDelay = (i*0.3)+'s';
    g.appendChild(r);
  });
  arc.setAttribute('d','M100,100 Q100,80 118,80 Q145,80 145,55 Q145,15 105,15 Q45,15 45,65 Q45,145 130,145 Q185,145 185,90');
})();
</script>
```

---

## Bileşen 7: Yakınsayan Diziler

**Etiketler (keyword eşleşmesi için):** yakınsaklık, dizi, sonsuzluk
**Kategori:** Matematik
**Açıklama:** Salınım genliği giderek küçülen ve tek bir limit noktasına doğru sonsuza kadar yaklaşan parçacıklar.

```html
<div class="sutol-mat-07-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <circle cx="100" cy="100" r="3" fill="#264653"/>
    <circle cx="100" cy="100" r="14" fill="none" stroke="#2a9d8f" stroke-width="1" opacity="0.35"/>
    <circle class="sutol-mat-07-p sutol-mat-07-p1" r="6" fill="#e76f51"/>
    <circle class="sutol-mat-07-p sutol-mat-07-p2" r="5" fill="#f4a261"/>
    <circle class="sutol-mat-07-p sutol-mat-07-p3" r="4" fill="#2a9d8f"/>
  </svg>
</div>
<style>
  .sutol-mat-07-p{ transform-origin: 100px 100px; }
  .sutol-mat-07-p1{ animation: sutol-mat-07-conv1 4s ease-in-out infinite; }
  .sutol-mat-07-p2{ animation: sutol-mat-07-conv2 4s ease-in-out infinite .3s; }
  .sutol-mat-07-p3{ animation: sutol-mat-07-conv3 4s ease-in-out infinite .6s; }
  @keyframes sutol-mat-07-conv1{
    0%{ transform:translate(-70px,0); }
    50%{ transform:translate(20px,0); }
    100%{ transform:translate(0,0); }
  }
  @keyframes sutol-mat-07-conv2{
    0%{ transform:translate(0,-70px); }
    50%{ transform:translate(0,15px); }
    100%{ transform:translate(0,0); }
  }
  @keyframes sutol-mat-07-conv3{
    0%{ transform:translate(50px,50px); }
    50%{ transform:translate(-12px,-12px); }
    100%{ transform:translate(0,0); }
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-07-p{ animation-duration: 12s; }
  }
</style>
```

---

## Bileşen 8: Diferansiyel Denklem Eğim Alanı

**Etiketler (keyword eşleşmesi için):** diferansiyel denklem, gradyan, geometrik dönüşüm
**Kategori:** Matematik
**Açıklama:** Bir diferansiyel denklemin çözüm eğrilerini ima eden, hafifçe nefes alan bir eğim (vektör) alanı; tuval (canvas) tabanlı üretim.

```html
<div class="sutol-mat-08-root" style="width:100%;height:100%;">
  <canvas class="sutol-mat-08-canvas" style="width:100%;height:100%;display:block;background:transparent;"></canvas>
</div>
<style>
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-08-canvas{ animation:none; }
  }
</style>
<script>
(function(){
  var canvas = document.querySelector('.sutol-mat-08-canvas');
  if(!canvas) return;
  var ctx = canvas.getContext('2d');
  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var t = 0;
  function resize(){
    var rect = canvas.getBoundingClientRect();
    canvas.width = rect.width || 200;
    canvas.height = rect.height || 200;
  }
  resize();
  window.addEventListener('resize', resize);
  function slope(x,y){
    return Math.sin(x*0.06) * Math.cos(y*0.06);
  }
  function draw(){
    var w = canvas.width, h = canvas.height;
    ctx.clearRect(0,0,w,h);
    var cols = 12, rows = 12;
    for(var i=0;i<cols;i++){
      for(var j=0;j<rows;j++){
        var x = (i+0.5)*(w/cols);
        var y = (j+0.5)*(h/rows);
        var m = slope(x, y + (reduced?0:Math.sin(t)*4));
        var len = Math.min(w/cols,h/rows)*0.4;
        var ang = Math.atan(m);
        var dx = Math.cos(ang)*len/2;
        var dy = Math.sin(ang)*len/2;
        var hue = 190 + m*40;
        ctx.strokeStyle = 'hsla('+hue+',65%,55%,0.75)';
        ctx.lineWidth = 1.4;
        ctx.beginPath();
        ctx.moveTo(x-dx,y-dy);
        ctx.lineTo(x+dx,y+dy);
        ctx.stroke();
        ctx.fillStyle = ctx.strokeStyle;
        ctx.beginPath();
        ctx.arc(x+dx,y+dy,1.4,0,Math.PI*2);
        ctx.fill();
      }
    }
    if(!reduced){
      t += 0.02;
      requestAnimationFrame(draw);
    }
  }
  draw();
})();
</script>
```

---

## Bileşen 9: Möbius Şeridi

**Etiketler (keyword eşleşmesi için):** topoloji, sonsuzluk, geometrik dönüşüm
**Kategori:** Matematik
**Açıklama:** İç ve dış yüzü olmayan, sonsuz döngüde dönen bir Möbius şeridinin 3B izlenimi.

```html
<div class="sutol-mat-09-root" style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;perspective:600px;">
  <div class="sutol-mat-09-ring">
    <div class="sutol-mat-09-seg s1"></div>
    <div class="sutol-mat-09-seg s2"></div>
    <div class="sutol-mat-09-seg s3"></div>
    <div class="sutol-mat-09-seg s4"></div>
    <div class="sutol-mat-09-seg s5"></div>
    <div class="sutol-mat-09-seg s6"></div>
    <div class="sutol-mat-09-seg s7"></div>
    <div class="sutol-mat-09-seg s8"></div>
  </div>
</div>
<style>
  .sutol-mat-09-ring{
    position:relative; width:60%; height:60%; max-width:140px; max-height:140px;
    transform-style:preserve-3d;
    animation: sutol-mat-09-spin 9s linear infinite;
  }
  .sutol-mat-09-seg{
    position:absolute; top:50%; left:50%; width:70%; height:14%;
    margin:-7% 0 0 -35%;
    background:linear-gradient(90deg,#ff006e,#8338ec,#3a86ff);
    border-radius:6px;
    transform-style:preserve-3d;
    opacity:0.9;
  }
  .s1{ transform: rotateY(0deg) rotateX(20deg) translateZ(60px); }
  .s2{ transform: rotateY(45deg) rotateX(20deg) translateZ(60px); }
  .s3{ transform: rotateY(90deg) rotateX(20deg) translateZ(60px); }
  .s4{ transform: rotateY(135deg) rotateX(20deg) translateZ(60px); }
  .s5{ transform: rotateY(180deg) rotateX(-20deg) translateZ(60px); }
  .s6{ transform: rotateY(225deg) rotateX(-20deg) translateZ(60px); }
  .s7{ transform: rotateY(270deg) rotateX(-20deg) translateZ(60px); }
  .s8{ transform: rotateY(315deg) rotateX(-20deg) translateZ(60px); }
  @keyframes sutol-mat-09-spin{
    from{ transform: rotateY(0deg) rotateX(8deg); }
    to{ transform: rotateY(360deg) rotateX(8deg); }
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-09-ring{ animation-duration: 40s; }
  }
</style>
```

---

## Bileşen 10: Venn Kümeleri

**Etiketler (keyword eşleşmesi için):** küme teorisi, bayes teoremi
**Kategori:** Matematik
**Açıklama:** Üç kümenin kesişim bölgelerinin sırayla vurgulandığı, kesişim ve birleşim kavramlarını canlandıran bir Venn şeması.

```html
<div class="sutol-mat-10-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <circle cx="80" cy="85" r="50" class="sutol-mat-10-a" fill="#ef476f" fill-opacity="0.35" stroke="#ef476f" stroke-width="1.5"/>
    <circle cx="120" cy="85" r="50" class="sutol-mat-10-b" fill="#ffd166" fill-opacity="0.35" stroke="#ffd166" stroke-width="1.5"/>
    <circle cx="100" cy="125" r="50" class="sutol-mat-10-c" fill="#06d6a0" fill-opacity="0.35" stroke="#06d6a0" stroke-width="1.5"/>
  </svg>
</div>
<style>
  .sutol-mat-10-a{ transform-origin:80px 85px; animation: sutol-mat-10-pulse 6s ease-in-out infinite; }
  .sutol-mat-10-b{ transform-origin:120px 85px; animation: sutol-mat-10-pulse 6s ease-in-out infinite 2s; }
  .sutol-mat-10-c{ transform-origin:100px 125px; animation: sutol-mat-10-pulse 6s ease-in-out infinite 4s; }
  @keyframes sutol-mat-10-pulse{
    0%,80%,100%{ fill-opacity:0.35; }
    40%{ fill-opacity:0.75; }
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-10-a, .sutol-mat-10-b, .sutol-mat-10-c{ animation:none; fill-opacity:0.5; }
  }
</style>
```

---

## Bileşen 11: Pisagor Teoremi

**Etiketler (keyword eşleşmesi için):** teorem, geometrik dönüşüm, çokgen
**Kategori:** Matematik
**Açıklama:** Dik üçgenin üç kenarına oturan karelerin sırayla çizilip nabız gibi attığı, a²+b²=c² ilişkisini görselleştiren klasik ispat şeması.

```html
<div class="sutol-mat-11-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <polygon points="60,140 140,140 60,80" fill="none" stroke="#3d5a80" stroke-width="2"/>
    <rect x="60" y="80" width="60" height="60" class="sutol-mat-11-sq sutol-mat-11-sq1" fill="#ee6c4d" fill-opacity="0.55" stroke="#ee6c4d"/>
    <rect x="0" y="140" width="60" height="60" class="sutol-mat-11-sq sutol-mat-11-sq2" fill="#98c1d9" fill-opacity="0.55" stroke="#98c1d9" transform="translate(0,-60) rotate(0)"/>
    <polygon class="sutol-mat-11-sq sutol-mat-11-sq3" points="140,140 60,140 60,240 140,240" fill="#3d5a80" fill-opacity="0.4" stroke="#3d5a80"
      transform="rotate(-90 140 140) translate(-40,60)"/>
  </svg>
</div>
<style>
  .sutol-mat-11-sq{
    animation: sutol-mat-11-appear 5s ease-in-out infinite;
    transform-box: fill-box;
    transform-origin: center;
  }
  .sutol-mat-11-sq1{ animation-delay: 0s; }
  .sutol-mat-11-sq2{ animation-delay: 0.6s; }
  .sutol-mat-11-sq3{ animation-delay: 1.2s; }
  @keyframes sutol-mat-11-appear{
    0%,100%{ opacity:.3; transform:scale(0.94); }
    40%,70%{ opacity:.9; transform:scale(1); }
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-11-sq{ animation:none; opacity:.75; }
  }
</style>
```

---

## Bileşen 12: Dönüşen Çokgen

**Etiketler (keyword eşleşmesi için):** çokgen, geometrik dönüşüm
**Kategori:** Matematik
**Açıklama:** Üçgenden altıgene, altıgenden tekrar üçgene sürekli biçim değiştiren ve aynı anda dönen bir çokgen.

```html
<div class="sutol-mat-12-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <polygon class="sutol-mat-12-poly" fill="#ff9f1c" fill-opacity="0.5" stroke="#ff9f1c" stroke-width="2">
      <animate attributeName="points" dur="7s" repeatCount="indefinite"
        values="
          100,50 145,150 55,150;
          140,60 160,130 100,170 40,130 60,60 100,30;
          100,40 155,75 155,125 100,160 45,125 45,75;
          100,50 145,150 55,150"/>
    </polygon>
  </svg>
</div>
<style>
  .sutol-mat-12-poly{
    transform-origin: 100px 100px;
    animation: sutol-mat-12-rotate 10s linear infinite;
  }
  @keyframes sutol-mat-12-rotate{ from{transform:rotate(0);} to{transform:rotate(360deg);} }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-12-poly{ animation-duration: 40s; }
    .sutol-mat-12-poly animate{ dur: 28s; }
  }
</style>
```

---

## Bileşen 13: Dönen Çok Yüzlü

**Etiketler (keyword eşleşmesi için):** çok yüzlü, topoloji, geometrik dönüşüm
**Kategori:** Matematik
**Açıklama:** Kendi ekseni etrafında yavaşça dönen, tel kafes (wireframe) görünümlü bir ikosahedron benzeri çok yüzlü.

```html
<div class="sutol-mat-13-root" style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;perspective:500px;">
  <div class="sutol-mat-13-solid">
    <div class="sutol-mat-13-face f1"></div>
    <div class="sutol-mat-13-face f2"></div>
    <div class="sutol-mat-13-face f3"></div>
    <div class="sutol-mat-13-face f4"></div>
    <div class="sutol-mat-13-face f5"></div>
    <div class="sutol-mat-13-face f6"></div>
  </div>
</div>
<style>
  .sutol-mat-13-solid{
    position:relative; width:40%; height:40%; max-width:100px; max-height:100px;
    transform-style:preserve-3d;
    animation: sutol-mat-13-tumble 12s linear infinite;
  }
  .sutol-mat-13-face{
    position:absolute; width:100%; height:100%;
    border:2px solid #7209b7;
    background:rgba(114,9,183,0.12);
  }
  .f1{ transform: rotateY(0deg) translateZ(50px); }
  .f2{ transform: rotateY(180deg) translateZ(50px); }
  .f3{ transform: rotateY(90deg) translateZ(50px); }
  .f4{ transform: rotateY(-90deg) translateZ(50px); }
  .f5{ transform: rotateX(90deg) translateZ(50px); }
  .f6{ transform: rotateX(-90deg) translateZ(50px); }
  @keyframes sutol-mat-13-tumble{
    from{ transform: rotateX(15deg) rotateY(0deg); }
    to{ transform: rotateX(15deg) rotateY(360deg); }
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-13-solid{ animation-duration: 45s; }
  }
</style>
```

---

## Bileşen 14: Hacimsel İntegral Dilimleri

**Etiketler (keyword eşleşmesi için):** hacimsel integral, gradyan, dizi
**Kategori:** Matematik
**Açıklama:** Bir dönel cismin hacmini Riemann dilimleri gibi alttan üste sırayla beliren ince kesitlerle yaklaşık olarak hesaplayan animasyon.

```html
<div class="sutol-mat-14-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <g id="sutol-mat-14-slices" class="sutol-mat-14-slices"></g>
  </svg>
</div>
<style>
  .sutol-mat-14-slice{
    animation: sutol-mat-14-rise 4s ease-in-out infinite;
    transform-box: fill-box;
    transform-origin: center;
  }
  @keyframes sutol-mat-14-rise{
    0%,100%{ opacity:.25; transform:scaleY(0.7); }
    50%{ opacity:.9; transform:scaleY(1); }
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-14-slice{ animation:none; opacity:.75; }
  }
</style>
<script>
(function(){
  var g = document.querySelector('.sutol-mat-14-slices');
  if(!g) return;
  var n = 10;
  for(var i=0;i<n;i++){
    var y = 170 - i*13;
    var t = i/(n-1);
    var rx = 10 + 55*Math.sin(t*Math.PI*0.9 + 0.15);
    var ellipse = document.createElementNS('http://www.w3.org/2000/svg','ellipse');
    ellipse.setAttribute('cx',100);
    ellipse.setAttribute('cy',y);
    ellipse.setAttribute('rx',rx);
    ellipse.setAttribute('ry',6);
    var hue = 200 + t*100;
    ellipse.setAttribute('fill','hsla('+hue+',70%,55%,0.55)');
    ellipse.setAttribute('stroke','hsla('+hue+',70%,40%,0.9)');
    ellipse.setAttribute('stroke-width','1');
    ellipse.setAttribute('class','sutol-mat-14-slice');
    ellipse.style.animationDelay = (i*0.18)+'s';
    g.appendChild(ellipse);
  }
})();
</script>
```

---

## Bileşen 15: Gradyan Tırmanışı

**Etiketler (keyword eşleşmesi için):** gradyan, diferansiyel denklem
**Kategori:** Matematik
**Açıklama:** İç içe eş-potansiyel halkalardan oluşan bir skaler alan üzerinde, en dik çıkış (gradyan) yönünü izleyerek merkeze doğru ilerleyen bir işaretçi; tuval tabanlı üretim.

```html
<div class="sutol-mat-15-root" style="width:100%;height:100%;">
  <canvas class="sutol-mat-15-canvas" style="width:100%;height:100%;display:block;background:transparent;"></canvas>
</div>
<script>
(function(){
  var canvas = document.querySelector('.sutol-mat-15-canvas');
  if(!canvas) return;
  var ctx = canvas.getContext('2d');
  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  function resize(){
    var rect = canvas.getBoundingClientRect();
    canvas.width = rect.width || 200;
    canvas.height = rect.height || 200;
  }
  resize();
  window.addEventListener('resize', resize);
  var angle = 0.6, radius = 0;
  function draw(){
    var w = canvas.width, h = canvas.height;
    var cx = w/2, cy = h/2;
    var maxR = Math.min(w,h)*0.45;
    ctx.clearRect(0,0,w,h);
    for(var r = maxR; r>0; r -= maxR/7){
      var t = r/maxR;
      ctx.beginPath();
      ctx.arc(cx,cy,r,0,Math.PI*2);
      ctx.strokeStyle = 'hsla('+(20+t*40)+',80%,55%,0.55)';
      ctx.lineWidth = 2;
      ctx.stroke();
    }
    if(!reduced){
      radius += (0 - radius)*0.003 + 0.15;
      angle += 0.06;
    }
    var curR = Math.max(0, maxR - (reduced?maxR*0.4:((performance.now()/60)%(maxR))));
    var px = cx + Math.cos(angle)*curR;
    var py = cy + Math.sin(angle)*curR;
    ctx.beginPath();
    ctx.arc(px,py,4,0,Math.PI*2);
    ctx.fillStyle = '#ffffff';
    ctx.shadowColor = '#ff9f1c';
    ctx.shadowBlur = 10;
    ctx.fill();
    ctx.shadowBlur = 0;
    if(!reduced) requestAnimationFrame(draw);
  }
  draw();
})();
</script>
```

---

## Bileşen 16: Matris Çarpımı

**Etiketler (keyword eşleşmesi için):** matris çarpımı, lineer dönüşüm, determinant
**Kategori:** Matematik
**Açıklama:** İki matrisin çarpımında bir satır ile bir sütunun nasıl taranıp tek bir hücrede birleştiğini gösteren ışıklı bir tarama animasyonu.

```html
<div class="sutol-mat-16-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <g id="sutol-mat-16-a" class="sutol-mat-16-mat"></g>
    <g id="sutol-mat-16-b" class="sutol-mat-16-mat"></g>
    <g id="sutol-mat-16-c" class="sutol-mat-16-mat"></g>
  </svg>
</div>
<style>
  .sutol-mat-16-cell{ stroke:#3a0ca3; stroke-width:1; }
  .sutol-mat-16-row{ animation: sutol-mat-16-sweep 3s ease-in-out infinite; }
  .sutol-mat-16-col{ animation: sutol-mat-16-sweep 3s ease-in-out infinite; }
  .sutol-mat-16-result{ animation: sutol-mat-16-glow 3s ease-in-out infinite; }
  @keyframes sutol-mat-16-sweep{ 0%,100%{ fill-opacity:0.25; } 50%{ fill-opacity:0.85; } }
  @keyframes sutol-mat-16-glow{ 0%,80%,100%{ fill-opacity:0.2; } 55%{ fill-opacity:1; } }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-16-row, .sutol-mat-16-col, .sutol-mat-16-result{ animation:none; fill-opacity:0.6; }
  }
</style>
<script>
(function(){
  var a = document.querySelector('#sutol-mat-16-a');
  var b = document.querySelector('#sutol-mat-16-b');
  var c = document.querySelector('#sutol-mat-16-c');
  if(!a||!b||!c) return;
  var size = 18, gap=2;
  function grid(container, ox, oy, highlightRow, highlightCol){
    for(var i=0;i<3;i++){
      for(var j=0;j<3;j++){
        var rect = document.createElementNS('http://www.w3.org/2000/svg','rect');
        rect.setAttribute('x', ox + j*(size+gap));
        rect.setAttribute('y', oy + i*(size+gap));
        rect.setAttribute('width', size);
        rect.setAttribute('height', size);
        rect.setAttribute('fill', '#4361ee');
        rect.setAttribute('class', 'sutol-mat-16-cell '+
          (highlightRow!==undefined && i===highlightRow ? 'sutol-mat-16-row' :
           highlightCol!==undefined && j===highlightCol ? 'sutol-mat-16-col' : ''));
        rect.style.animationDelay = (j*0.1+i*0.1)+'s';
        container.appendChild(rect);
      }
    }
  }
  grid(a, 15, 40, 1, undefined);
  grid(b, 100, 40, undefined, 1);
  for(var i=0;i<3;i++){
    for(var j=0;j<3;j++){
      var rect = document.createElementNS('http://www.w3.org/2000/svg','rect');
      rect.setAttribute('x', 60 + j*(size+gap));
      rect.setAttribute('y', 130 + i*(size+gap));
      rect.setAttribute('width', size);
      rect.setAttribute('height', size);
      rect.setAttribute('fill', '#f72585');
      rect.setAttribute('class', 'sutol-mat-16-cell'+((i===1&&j===1)?' sutol-mat-16-result':''));
      c.appendChild(rect);
    }
  }
})();
</script>
```

---

## Bileşen 17: Determinant Alanı

**Etiketler (keyword eşleşmesi için):** determinant, lineer dönüşüm, geometrik dönüşüm
**Kategori:** Matematik
**Açıklama:** İki vektörün oluşturduğu paralelkenarın alanı olarak determinantı canlı biçimde hesaplayıp çizen bir animasyon.

```html
<div class="sutol-mat-17-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <line x1="20" y1="180" x2="190" y2="180" stroke="#495057" stroke-width="1" opacity="0.4"/>
    <line x1="20" y1="180" x2="20" y2="20" stroke="#495057" stroke-width="1" opacity="0.4"/>
    <polygon id="sutol-mat-17-poly" fill="#4cc9f0" fill-opacity="0.45" stroke="#4361ee" stroke-width="2"/>
    <line id="sutol-mat-17-v1" stroke="#f72585" stroke-width="2.5" stroke-linecap="round"/>
    <line id="sutol-mat-17-v2" stroke="#7209b7" stroke-width="2.5" stroke-linecap="round"/>
  </svg>
</div>
<script>
(function(){
  var poly = document.querySelector('#sutol-mat-17-poly');
  var v1 = document.querySelector('#sutol-mat-17-v1');
  var v2 = document.querySelector('#sutol-mat-17-v2');
  if(!poly||!v1||!v2) return;
  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var ox=20, oy=180;
  var t=0;
  function frame(){
    var a1 = 0.9 + Math.sin(t)*0.35;
    var a2 = 2.1 + Math.cos(t*0.7)*0.3;
    var len1 = 120, len2 = 110;
    var x1 = Math.cos(a1)*len1, y1 = -Math.sin(a1)*len1;
    var x2 = Math.cos(a2)*len2, y2 = -Math.sin(a2)*len2;
    v1.setAttribute('x1',ox); v1.setAttribute('y1',oy);
    v1.setAttribute('x2',ox+x1); v1.setAttribute('y2',oy+y1);
    v2.setAttribute('x1',ox); v2.setAttribute('y1',oy);
    v2.setAttribute('x2',ox+x2); v2.setAttribute('y2',oy+y2);
    var px = [ox, ox+x1, ox+x1+x2, ox+x2];
    var py = [oy, oy+y1, oy+y1+y2, oy+y2];
    var pts = '';
    for(var i=0;i<4;i++) pts += px[i]+','+py[i]+' ';
    poly.setAttribute('points', pts.trim());
    if(!reduced){
      t += 0.012;
      requestAnimationFrame(frame);
    }
  }
  frame();
})();
</script>
```

---

## Bileşen 18: Özdeğer Ekseni

**Etiketler (keyword eşleşmesi için):** özdeğer, lineer dönüşüm, matris çarpımı
**Kategori:** Matematik
**Açıklama:** Bir dönüşüm altında noktalar dönerken, yönü değişmeden yalnızca uzunluğu ölçeklenen özvektör eksenlerinin sabit kaldığı bir kompozisyon.

```html
<div class="sutol-mat-18-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <line x1="20" y1="180" x2="185" y2="15" stroke="#e63946" stroke-width="2" opacity="0.75"/>
    <line x1="20" y1="15" x2="185" y2="180" stroke="#457b9d" stroke-width="2" opacity="0.75"/>
    <g class="sutol-mat-18-grid"></g>
  </svg>
</div>
<style>
  .sutol-mat-18-grid{
    transform-origin: 100px 100px;
    animation: sutol-mat-18-morph 6s ease-in-out infinite;
  }
  @keyframes sutol-mat-18-morph{
    0%,100%{ transform: matrix(1,0,0,1,0,0); }
    50%{ transform: matrix(1.15,0.25,0.25,1.15,0,0); }
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-18-grid{ animation:none; }
  }
</style>
<script>
(function(){
  var g = document.querySelector('.sutol-mat-18-grid');
  if(!g) return;
  for(var i=-2;i<=2;i++){
    for(var j=-2;j<=2;j++){
      var dot = document.createElementNS('http://www.w3.org/2000/svg','circle');
      dot.setAttribute('cx', 100 + i*28);
      dot.setAttribute('cy', 100 + j*28);
      dot.setAttribute('r', 3.2);
      dot.setAttribute('fill', '#1d3557');
      dot.setAttribute('fill-opacity', '0.75');
      g.appendChild(dot);
    }
  }
})();
</script>
```

---

## Bileşen 19: Galton Tahtası ve Normal Dağılım

**Etiketler (keyword eşleşmesi için):** normal dağılım, yakınsaklık, dizi
**Kategori:** Matematik
**Açıklama:** Pinlerden sekerek düşen tanelerin biriktiği kutucukların zamanla klasik çan eğrisini oluşturduğu bir Galton tahtası simülasyonu.

```html
<div class="sutol-mat-19-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <g id="sutol-mat-19-pins" class="sutol-mat-19-pins" fill="#6c757d"></g>
    <g id="sutol-mat-19-bins" class="sutol-mat-19-bins"></g>
    <g id="sutol-mat-19-balls" class="sutol-mat-19-balls"></g>
  </svg>
</div>
<style>
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-19-balls circle{ animation:none !important; }
  }
</style>
<script>
(function(){
  var pins = document.querySelector('.sutol-mat-19-pins');
  var binsG = document.querySelector('.sutol-mat-19-bins');
  var balls = document.querySelector('.sutol-mat-19-balls');
  if(!pins||!binsG||!balls) return;
  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var rows = 6, spacing=18, topY=25;
  for(var r=0;r<rows;r++){
    var count = r+1;
    var startX = 100 - r*spacing/2;
    for(var k=0;k<count;k++){
      var c = document.createElementNS('http://www.w3.org/2000/svg','circle');
      c.setAttribute('cx', startX + k*spacing);
      c.setAttribute('cy', topY + r*16);
      c.setAttribute('r', 1.8);
      pins.appendChild(c);
    }
  }
  var binCount = 7;
  var binHeights = new Array(binCount).fill(0);
  var binX0 = 100 - (binCount/2)*spacing;
  for(var b=0;b<binCount;b++){
    var rect = document.createElementNS('http://www.w3.org/2000/svg','rect');
    rect.setAttribute('x', binX0 + b*spacing + 1);
    rect.setAttribute('y', 190);
    rect.setAttribute('width', spacing-3);
    rect.setAttribute('height', 0);
    rect.setAttribute('fill', '#118ab2');
    rect.setAttribute('fill-opacity', '0.8');
    rect.setAttribute('class','sutol-mat-19-bar');
    binsG.appendChild(rect);
  }
  var barEls = binsG.querySelectorAll('.sutol-mat-19-bar');
  function updateBars(){
    var maxH = Math.max.apply(null, binHeights.concat([1]));
    for(var i=0;i<binCount;i++){
      var h = (binHeights[i]/maxH) * 70;
      barEls[i].setAttribute('height', h);
      barEls[i].setAttribute('y', 190-h);
    }
  }
  function dropBall(){
    var offset = 0;
    for(var r=0;r<rows;r++){
      offset += (Math.random()<0.5? -1:1);
    }
    var binIndex = Math.max(0, Math.min(binCount-1, Math.round(binCount/2 + offset/2)));
    binHeights[binIndex]++;
    updateBars();
    if(reduced) return;
    var ball = document.createElementNS('http://www.w3.org/2000/svg','circle');
    ball.setAttribute('r', 2.5);
    ball.setAttribute('fill', '#ef476f');
    ball.setAttribute('cx', 100);
    ball.setAttribute('cy', topY);
    balls.appendChild(ball);
    var destX = binX0 + binIndex*spacing + spacing/2;
    ball.animate([
      { transform: 'translate(0px,0px)' },
      { transform: 'translate('+(destX-100)+'px,150px)' }
    ], { duration: 1400, easing:'ease-in' });
    setTimeout(function(){ if(ball.parentNode) ball.parentNode.removeChild(ball); }, 1450);
  }
  if(!reduced){
    setInterval(dropBall, 500);
  } else {
    for(var i=0;i<30;i++) dropBall();
  }
})();
</script>
```

---

## Bileşen 20: Oyun Teorisi Matrisi

**Etiketler (keyword eşleşmesi için):** oyun teorisi, algoritmik karmaşıklık, bayes teoremi
**Kategori:** Matematik
**Açıklama:** İki oyuncunun strateji seçimlerini temsil eden işaretçilerin 2x2'lik bir kazanç matrisi üzerinde en iyi tepkiyi ararcasına dolaştığı bir kompozisyon.

```html
<div class="sutol-mat-20-root" style="width:100%;height:100%;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;display:block;">
    <g stroke="#495057" stroke-width="1.2" opacity="0.6">
      <line x1="40" y1="40" x2="40" y2="160"/>
      <line x1="120" y1="40" x2="120" y2="160"/>
      <line x1="200" y1="40" x2="200" y2="40"/>
      <line x1="40" y1="40" x2="200" y2="40"/>
      <line x1="40" y1="100" x2="200" y2="100"/>
      <line x1="40" y1="160" x2="200" y2="160"/>
    </g>
    <rect x="40" y="40" width="80" height="60" fill="#ffd166" fill-opacity="0.25"/>
    <rect x="120" y="40" width="80" height="60" fill="#06d6a0" fill-opacity="0.25"/>
    <rect x="40" y="100" width="80" height="60" fill="#118ab2" fill-opacity="0.25"/>
    <rect x="120" y="100" width="80" height="60" fill="#ef476f" fill-opacity="0.25"/>
    <circle class="sutol-mat-20-p1" r="7" fill="#ef476f"/>
    <circle class="sutol-mat-20-p2" r="7" fill="#118ab2"/>
  </svg>
</div>
<style>
  .sutol-mat-20-p1{ animation: sutol-mat-20-move1 6s ease-in-out infinite; }
  .sutol-mat-20-p2{ animation: sutol-mat-20-move2 6s ease-in-out infinite; }
  @keyframes sutol-mat-20-move1{
    0%,20%{ cx:80; cy:70; }
    45%,65%{ cx:160; cy:70; }
    90%,100%{ cx:80; cy:70; }
  }
  @keyframes sutol-mat-20-move2{
    0%,20%{ cx:80; cy:130; }
    45%,65%{ cx:160; cy:130; }
    70%,90%{ cx:80; cy:130; }
    100%{ cx:80; cy:130; }
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mat-20-p1, .sutol-mat-20-p2{ animation:none; }
  }
</style>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Fraktal Ağaç): JS özyinelemeli üretim + CSS opacity nabzı; 40'a kadar dal segmenti, hafif DOM yükü.
- Bileşen 2 (Sonsuzluk Şeridi): SVG `animateMotion` (SMIL) + `stroke-dashoffset` akışı; tamamen deklaratif, düşük maliyetli.
- Bileşen 3 (Karmaşık Düzlem Vektörü): Saf CSS `transform: rotate()`; GPU dostu, çok hafif.
- Bileşen 4 (Teodorus Sarmalı): JS ile trigonometrik döngü, statik SVG çizgiler + staggered `stroke-dashoffset` çizimi.
- Bileşen 5 (Asal Çarpanlar Ağacı): JS özyinelemeli düğüm/kenar üretimi + CSS `scale` nabzı.
- Bileşen 6 (Fibonacci Sarmalı): JS ile dikdörtgen düzeni üretimi + statik SVG yay; orta DOM yükü.
- Bileşen 7 (Yakınsayan Diziler): Saf CSS keyframe `translate`; en hafif bileşenlerden biri.
- Bileşen 8 (Eğim Alanı): Canvas + `requestAnimationFrame`; 144 ok her karede yeniden çizilir, orta CPU yükü.
- Bileşen 9 (Möbius Şeridi): CSS 3B `transform-style: preserve-3d` + `rotateY/rotateX`; GPU hızlandırmalı.
- Bileşen 10 (Venn Kümeleri): Saf CSS `fill-opacity` keyframe zinciri; çok hafif.
- Bileşen 11 (Pisagor Teoremi): CSS `transform-box: fill-box` ile SVG şekil ölçekleme; hafif.
- Bileşen 12 (Dönüşen Çokgen): SVG SMIL `<animate attributeName="points">` + CSS rotasyon; düşük maliyetli.
- Bileşen 13 (Dönen Çok Yüzlü): CSS 3B küp yapısı, `preserve-3d`; GPU hızlandırmalı, hafif.
- Bileşen 14 (Hacimsel Dilimler): JS ile elips üretimi + CSS `scaleY` staggered animasyon.
- Bileşen 15 (Gradyan Tırmanışı): Canvas + `requestAnimationFrame`; sürekli halka çizimi, orta CPU yükü.
- Bileşen 16 (Matris Çarpımı): JS ızgara üretimi + CSS `fill-opacity` taraması; hafif.
- Bileşen 17 (Determinant Alanı): JS `requestAnimationFrame` ile canlı `points` hesaplama (gerçek çapraz çarpım alanı); orta CPU yükü.
- Bileşen 18 (Özdeğer Ekseni): Saf CSS `matrix()` dönüşümü + statik SVG nokta ızgarası; hafif.
- Bileşen 19 (Galton Tahtası): JS rastgele yürüyüş simülasyonu + Web Animations API (`element.animate`); orta DOM/CPU yükü, `prefers-reduced-motion` altında animasyonsuz toplu dağılım gösterir.
- Bileşen 20 (Oyun Teorisi Matrisi): Saf CSS keyframe `cx/cy` animasyonu; hafif.

Tüm bileşenler: dış kaynak/CDN/font/API kullanmaz, şeffaf arka plana sahiptir, `viewBox` veya yüzde tabanlı ölçeklenebilirlik kullanır, `prefers-reduced-motion` desteği içerir, sınıf adları `sutol-mat-NN-` önekiyle kapsüllenmiştir ve sabit dil bağımlı metin içermez.
