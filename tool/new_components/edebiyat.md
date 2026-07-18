## Bileşen 21: Kafiye Zinciri Halkaları

**Etiketler (keyword eşleşmesi için):** şiir, kafiye, dize, ritim
**Kategori:** Edebiyat
**Açıklama:** Birbirine kesikli çizgilerle bağlı dört halkanın sırayla nabız gibi büyüyüp küçülerek şiirsel kafiye bağını simgelemesi.

```html
<div class="sutol-edeb21-wrap">
  <svg class="sutol-edeb21-svg" viewBox="0 0 240 100" preserveAspectRatio="xMidYMid meet">
    <line class="sutol-edeb21-link" x1="30" y1="50" x2="90" y2="50"></line>
    <line class="sutol-edeb21-link sutol-edeb21-d1" x1="90" y1="50" x2="150" y2="50"></line>
    <line class="sutol-edeb21-link sutol-edeb21-d2" x1="150" y1="50" x2="210" y2="50"></line>
    <circle class="sutol-edeb21-node" cx="30" cy="50" r="14"></circle>
    <circle class="sutol-edeb21-node sutol-edeb21-d1" cx="90" cy="50" r="14"></circle>
    <circle class="sutol-edeb21-node sutol-edeb21-d2" cx="150" cy="50" r="14"></circle>
    <circle class="sutol-edeb21-node sutol-edeb21-d3" cx="210" cy="50" r="14"></circle>
  </svg>
</div>
<style>
.sutol-edeb21-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-edeb21-svg{width:100%;height:100%;}
.sutol-edeb21-link{stroke:#8a5fb0;stroke-width:2;stroke-dasharray:6 6;opacity:.55;animation:sutol-edeb21-flow 2s linear infinite;}
.sutol-edeb21-node{fill:#6a3fa0;transform-box:fill-box;transform-origin:center;animation:sutol-edeb21-pulse 2s ease-in-out infinite;}
.sutol-edeb21-d1{animation-delay:.3s;}
.sutol-edeb21-d2{animation-delay:.6s;}
.sutol-edeb21-d3{animation-delay:.9s;}
@keyframes sutol-edeb21-flow{to{stroke-dashoffset:-24;}}
@keyframes sutol-edeb21-pulse{0%,100%{transform:scale(1);opacity:.7;}50%{transform:scale(1.3);opacity:1;}}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb21-link,.sutol-edeb21-node{animation-duration:8s;}
}
</style>
```

---

## Bileşen 22: Roman Zaman Sarmalı

**Etiketler (keyword eşleşmesi için):** roman, olay örgüsü, anlatı, zaman
**Kategori:** Edebiyat
**Açıklama:** Bir romanın kronolojik akışını temsil eden dalgalı sarmal bir çizgi üzerinde parlayan bir noktanın baştan sona süzülmesi.

```html
<div class="sutol-edeb22-wrap">
  <svg class="sutol-edeb22-svg" viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet">
    <path id="sutol-edeb22-path" class="sutol-edeb22-path"
      d="M20,60 C20,20 70,20 70,60 C70,100 130,100 130,60 C130,20 180,20 180,60"></path>
    <circle class="sutol-edeb22-dot" r="5">
      <animateMotion dur="4s" repeatCount="indefinite" rotate="auto">
        <mpath href="#sutol-edeb22-path"></mpath>
      </animateMotion>
    </circle>
  </svg>
</div>
<style>
.sutol-edeb22-wrap{width:100%;height:100%;background:transparent;}
.sutol-edeb22-svg{width:100%;height:100%;}
.sutol-edeb22-path{fill:none;stroke:#b08968;stroke-width:2;opacity:.6;}
.sutol-edeb22-dot{fill:#7f4f24;}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb22-dot animateMotion{}
}
</style>
```

---

## Bileşen 23: Kitap Kulesi İnşası

**Etiketler (keyword eşleşmesi için):** kitap, kütüphane, sayfa, edebiyat
**Kategori:** Edebiyat
**Açıklama:** Farklı renkteki kitap dikdörtgenlerinin sırayla alttan üste istiflenip sonra yeniden çözülerek sonsuz bir kule inşa döngüsü oluşturması.

```html
<div class="sutol-edeb23-wrap">
  <div class="sutol-edeb23-tower">
    <div class="sutol-edeb23-book sutol-edeb23-b1"></div>
    <div class="sutol-edeb23-book sutol-edeb23-b2"></div>
    <div class="sutol-edeb23-book sutol-edeb23-b3"></div>
    <div class="sutol-edeb23-book sutol-edeb23-b4"></div>
  </div>
</div>
<style>
.sutol-edeb23-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:flex-end;justify-content:center;}
.sutol-edeb23-tower{width:60%;height:70%;display:flex;flex-direction:column-reverse;align-items:center;gap:4%;}
.sutol-edeb23-book{width:80%;height:18%;border-radius:6%;opacity:0;transform:translateY(40%) scaleX(.7);animation:sutol-edeb23-stack 3.2s ease-in-out infinite;}
.sutol-edeb23-b1{background:#9c6644;animation-delay:0s;}
.sutol-edeb23-b2{background:#c08552;animation-delay:.3s;}
.sutol-edeb23-b3{background:#dda15e;animation-delay:.6s;}
.sutol-edeb23-b4{background:#e9c46a;animation-delay:.9s;}
@keyframes sutol-edeb23-stack{
  0%{opacity:0;transform:translateY(40%) scaleX(.7);}
  20%,70%{opacity:1;transform:translateY(0) scaleX(1);}
  90%,100%{opacity:0;transform:translateY(-20%) scaleX(.7);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb23-book{animation-duration:10s;}
}
</style>
```

---

## Bileşen 24: Daktilo Tuşları Dansı

**Etiketler (keyword eşleşmesi için):** yazar, üslup, dil, edebiyat
**Kategori:** Edebiyat
**Açıklama:** Bir yazarın satır boyunca dizilmiş daktilo tuşlarının dalga halinde art arda basılıp kalkması.

```html
<div class="sutol-edeb24-wrap">
  <div class="sutol-edeb24-row">
    <span class="sutol-edeb24-key" style="animation-delay:0s"></span>
    <span class="sutol-edeb24-key" style="animation-delay:.1s"></span>
    <span class="sutol-edeb24-key" style="animation-delay:.2s"></span>
    <span class="sutol-edeb24-key" style="animation-delay:.3s"></span>
    <span class="sutol-edeb24-key" style="animation-delay:.4s"></span>
    <span class="sutol-edeb24-key" style="animation-delay:.5s"></span>
    <span class="sutol-edeb24-key" style="animation-delay:.6s"></span>
  </div>
</div>
<style>
.sutol-edeb24-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-edeb24-row{width:80%;height:30%;display:flex;justify-content:space-between;align-items:flex-end;}
.sutol-edeb24-key{width:11%;height:60%;background:#495057;border-radius:15%;animation:sutol-edeb24-press 1.4s ease-in-out infinite;}
@keyframes sutol-edeb24-press{
  0%,100%{transform:translateY(0);background:#495057;}
  30%{transform:translateY(35%);background:#212529;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb24-key{animation-duration:5s;}
}
</style>
```

---

## Bileşen 25: Söz Sanatları Prizması

**Etiketler (keyword eşleşmesi için):** metafor, sembol, üslup, edebi akım
**Kategori:** Edebiyat
**Açıklama:** Bir üçgen prizmadan içeri giren tek bir ışığın, farklı söz sanatlarını simgeleyen renkli şeritlere ayrışarak fan gibi açılması.

```html
<div class="sutol-edeb25-wrap">
  <svg class="sutol-edeb25-svg" viewBox="0 0 200 100" preserveAspectRatio="xMidYMid meet">
    <rect class="sutol-edeb25-beam" x="0" y="46" width="70" height="8"></rect>
    <polygon class="sutol-edeb25-prism" points="70,30 70,70 105,50"></polygon>
    <rect class="sutol-edeb25-ray sutol-edeb25-r1" x="105" y="20" width="90" height="4"></rect>
    <rect class="sutol-edeb25-ray sutol-edeb25-r2" x="105" y="38" width="90" height="4"></rect>
    <rect class="sutol-edeb25-ray sutol-edeb25-r3" x="105" y="58" width="90" height="4"></rect>
    <rect class="sutol-edeb25-ray sutol-edeb25-r4" x="105" y="76" width="90" height="4"></rect>
  </svg>
</div>
<style>
.sutol-edeb25-wrap{width:100%;height:100%;background:transparent;}
.sutol-edeb25-svg{width:100%;height:100%;}
.sutol-edeb25-beam{fill:#f1faee;opacity:.85;}
.sutol-edeb25-prism{fill:#a8dadc;opacity:.5;stroke:#457b9d;stroke-width:1;}
.sutol-edeb25-ray{transform-box:fill-box;transform-origin:left center;transform:scaleX(0);animation:sutol-edeb25-fan 2.4s ease-in-out infinite;}
.sutol-edeb25-r1{fill:#e63946;animation-delay:.1s;}
.sutol-edeb25-r2{fill:#f4a261;animation-delay:.25s;}
.sutol-edeb25-r3{fill:#2a9d8f;animation-delay:.4s;}
.sutol-edeb25-r4{fill:#1d3557;animation-delay:.55s;}
@keyframes sutol-edeb25-fan{
  0%{transform:scaleX(0);opacity:0;}
  40%,70%{transform:scaleX(1);opacity:1;}
  100%{transform:scaleX(0);opacity:0;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb25-ray{animation-duration:7s;}
}
</style>
```

---

## Bileşen 26: Anlatıcı Bakış Açısı Merceği

**Etiketler (keyword eşleşmesi için):** anlatı, karakter, roman, eleştiri
**Kategori:** Edebiyat
**Açıklama:** Bir kamera diyaframı gibi açılıp kapanan iç içe halkaların, hikâyeyi anlatan bakış açısının daralıp genişlemesini simgelemesi.

```html
<div class="sutol-edeb26-wrap">
  <div class="sutol-edeb26-iris">
    <div class="sutol-edeb26-ring sutol-edeb26-r1"></div>
    <div class="sutol-edeb26-ring sutol-edeb26-r2"></div>
    <div class="sutol-edeb26-ring sutol-edeb26-r3"></div>
    <div class="sutol-edeb26-core"></div>
  </div>
</div>
<style>
.sutol-edeb26-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-edeb26-iris{position:relative;width:60%;height:60%;}
.sutol-edeb26-ring{position:absolute;inset:0;border-radius:50%;border:2px solid #6d597a;animation:sutol-edeb26-aperture 3s ease-in-out infinite;}
.sutol-edeb26-r1{animation-delay:0s;}
.sutol-edeb26-r2{inset:12%;border-color:#b56576;animation-delay:.3s;}
.sutol-edeb26-r3{inset:24%;border-color:#e56b6f;animation-delay:.6s;}
.sutol-edeb26-core{position:absolute;inset:40%;border-radius:50%;background:#eaac8b;animation:sutol-edeb26-pulse 3s ease-in-out infinite;}
@keyframes sutol-edeb26-aperture{
  0%,100%{clip-path:circle(50% at 50% 50%);}
  50%{clip-path:circle(20% at 50% 50%);}
}
@keyframes sutol-edeb26-pulse{
  0%,100%{transform:scale(1);}
  50%{transform:scale(.5);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb26-ring,.sutol-edeb26-core{animation-duration:9s;}
}
</style>
```

---

## Bileşen 27: Şiirsel İmge Bulutu

**Etiketler (keyword eşleşmesi için):** şiir, imge, sembol, dil
**Kategori:** Edebiyat
**Açıklama:** Canvas üzerinde yumuşak, yarı saydam baloncukların şiirsel imgeler gibi ağır ağır yükselip sallanarak yeniden doğması.

```html
<div class="sutol-edeb27-wrap">
  <canvas class="sutol-edeb27-canvas"></canvas>
</div>
<style>
.sutol-edeb27-wrap{width:100%;height:100%;background:transparent;position:relative;}
.sutol-edeb27-canvas{width:100%;height:100%;display:block;}
</style>
<script>
(function(){
  var wrap = document.currentScript.previousElementSibling ? null : null;
  var container = document.currentScript.closest ? document.currentScript.closest('.sutol-edeb27-wrap') : document.currentScript.parentElement;
  var canvas = container.querySelector('.sutol-edeb27-canvas');
  var ctx = canvas.getContext('2d');
  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var particles = [];
  var count = 7;
  function resize(){
    canvas.width = canvas.clientWidth || 300;
    canvas.height = canvas.clientHeight || 150;
  }
  function init(){
    resize();
    particles = [];
    for(var i=0;i<count;i++){
      particles.push({
        x: Math.random()*canvas.width,
        y: canvas.height + Math.random()*canvas.height,
        r: 10 + Math.random()*18,
        speed: 0.15 + Math.random()*0.25,
        phase: Math.random()*Math.PI*2,
        hue: 250 + i*10
      });
    }
  }
  var t = 0;
  function draw(){
    ctx.clearRect(0,0,canvas.width,canvas.height);
    t += reduced ? 0.003 : 0.01;
    for(var i=0;i<particles.length;i++){
      var p = particles[i];
      p.y -= p.speed;
      if(p.y < -p.r){ p.y = canvas.height + p.r; p.x = Math.random()*canvas.width; }
      var wob = Math.sin(t*2 + p.phase) * 8;
      ctx.beginPath();
      ctx.arc(p.x + wob, p.y, p.r, 0, Math.PI*2);
      ctx.fillStyle = 'hsla(' + p.hue + ',60%,65%,0.35)';
      ctx.fill();
    }
    requestAnimationFrame(draw);
  }
  init();
  window.addEventListener('resize', resize);
  requestAnimationFrame(draw);
})();
</script>
```

---

## Bileşen 28: Kahramanın Yolculuğu Çemberi

**Etiketler (keyword eşleşmesi için):** destan, olay örgüsü, karakter, mitoloji
**Kategori:** Edebiyat
**Açıklama:** Dairesel bir yol üzerinde ilerleyen parlak bir noktanın, kahramanın yolculuğundaki durakları temsil eden sabit işaretlerin arasından geçmesi.

```html
<div class="sutol-edeb28-wrap">
  <div class="sutol-edeb28-track">
    <span class="sutol-edeb28-stop" style="top:2%;left:48%"></span>
    <span class="sutol-edeb28-stop" style="top:48%;left:96%"></span>
    <span class="sutol-edeb28-stop" style="top:94%;left:48%"></span>
    <span class="sutol-edeb28-stop" style="top:48%;left:0%"></span>
    <div class="sutol-edeb28-runner"></div>
  </div>
</div>
<style>
.sutol-edeb28-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-edeb28-track{position:relative;width:60%;height:60%;border-radius:50%;border:2px dashed #3a5a40;}
.sutol-edeb28-stop{position:absolute;width:8%;height:8%;margin:-4% 0 0 -4%;border-radius:50%;background:#588157;}
.sutol-edeb28-runner{position:absolute;width:10%;height:10%;border-radius:50%;background:#dad7cd;box-shadow:0 0 8px 2px #a3b18a;offset-path:circle(50% at 50% 50%);animation:sutol-edeb28-orbit 5s linear infinite;}
@keyframes sutol-edeb28-orbit{
  0%{offset-distance:0%;}
  100%{offset-distance:100%;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb28-runner{animation-duration:18s;}
}
</style>
```

---

## Bileşen 29: Nesir-Nazım Terazisi

**Etiketler (keyword eşleşmesi için):** şiir, roman, dil, eleştiri
**Kategori:** Edebiyat
**Açıklama:** Bir ucu şiiri, diğer ucu düzyazıyı temsil eden iki kefeli bir terazi kolunun yavaşça sağa sola sallanması.

```html
<div class="sutol-edeb29-wrap">
  <svg class="sutol-edeb29-svg" viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet">
    <line class="sutol-edeb29-stand" x1="100" y1="20" x2="100" y2="100"></line>
    <g class="sutol-edeb29-beam">
      <line x1="40" y1="30" x2="160" y2="30"></line>
      <line x1="40" y1="30" x2="40" y2="55"></line>
      <line x1="160" y1="30" x2="160" y2="55"></line>
      <rect class="sutol-edeb29-panLeft" x="25" y="55" width="30" height="8" rx="3"></rect>
      <rect class="sutol-edeb29-panRight" x="145" y="55" width="30" height="8" rx="3"></rect>
    </g>
  </svg>
</div>
<style>
.sutol-edeb29-wrap{width:100%;height:100%;background:transparent;}
.sutol-edeb29-svg{width:100%;height:100%;}
.sutol-edeb29-stand{stroke:#606c38;stroke-width:4;}
.sutol-edeb29-beam{stroke:#283618;stroke-width:3;fill:none;transform-box:view-box;transform-origin:100px 30px;animation:sutol-edeb29-tilt 4s ease-in-out infinite;}
.sutol-edeb29-panLeft{fill:#bc6c25;}
.sutol-edeb29-panRight{fill:#dda15e;}
@keyframes sutol-edeb29-tilt{
  0%,100%{transform:rotate(-6deg);}
  50%{transform:rotate(6deg);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb29-beam{animation-duration:14s;}
}
</style>
```

---

## Bileşen 30: Papirüs Tomarının Açılışı

**Etiketler (keyword eşleşmesi için):** destan, mitoloji, biyografi, edebiyat
**Kategori:** Edebiyat
**Açıklama:** İki ucundaki silindirlerden ortaya doğru açılıp yeniden kapanan eski bir papirüs tomarının döngüsel hareketi.

```html
<div class="sutol-edeb30-wrap">
  <div class="sutol-edeb30-scroll">
    <div class="sutol-edeb30-rodLeft"></div>
    <div class="sutol-edeb30-sheet"></div>
    <div class="sutol-edeb30-rodRight"></div>
  </div>
</div>
<style>
.sutol-edeb30-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-edeb30-scroll{position:relative;width:70%;height:40%;display:flex;align-items:center;}
.sutol-edeb30-rodLeft,.sutol-edeb30-rodRight{width:6%;height:100%;border-radius:40%;background:#6f4518;z-index:2;}
.sutol-edeb30-sheet{height:78%;background:#e9dcc3;border:1px solid #cbb994;flex:1;transform-origin:left center;transform:scaleX(0);animation:sutol-edeb30-unroll 4.5s ease-in-out infinite;}
@keyframes sutol-edeb30-unroll{
  0%{transform:scaleX(0);}
  40%,60%{transform:scaleX(1);}
  100%{transform:scaleX(0);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb30-sheet{animation-duration:15s;}
}
</style>
```

---

## Bileşen 31: Sayfalardan Uçuşan Kelebekler

**Etiketler (keyword eşleşmesi için):** hikaye, masal, imge, sembol
**Kategori:** Edebiyat
**Açıklama:** Açık bir kitabın sayfalarından süzülen küçük kelebeklerin kanat çırparak yukarı doğru süzülmesiyle hayal gücünün canlanması.

```html
<div class="sutol-edeb31-wrap">
  <svg class="sutol-edeb31-svg" viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-edeb31-book" d="M40,100 L100,90 L160,100 L160,108 L100,98 L40,108 Z"></path>
    <g class="sutol-edeb31-fly1">
      <path id="sutol-edeb31-m1" d="M100,90 C90,60 70,30 60,10" opacity="0"></path>
      <g class="sutol-edeb31-wingWrap">
        <polygon class="sutol-edeb31-wing" points="0,0 -8,-6 -8,6"></polygon>
        <polygon class="sutol-edeb31-wing" points="0,0 8,-6 8,6"></polygon>
      </g>
      <animateMotion dur="4s" repeatCount="indefinite" rotate="auto">
        <mpath href="#sutol-edeb31-m1"></mpath>
      </animateMotion>
    </g>
    <g class="sutol-edeb31-fly2">
      <path id="sutol-edeb31-m2" d="M100,90 C115,55 140,35 150,15" opacity="0"></path>
      <g class="sutol-edeb31-wingWrap">
        <polygon class="sutol-edeb31-wing sutol-edeb31-wing2" points="0,0 -7,-5 -7,5"></polygon>
        <polygon class="sutol-edeb31-wing sutol-edeb31-wing2" points="0,0 7,-5 7,5"></polygon>
      </g>
      <animateMotion dur="3.4s" begin="0.6s" repeatCount="indefinite" rotate="auto">
        <mpath href="#sutol-edeb31-m2"></mpath>
      </animateMotion>
    </g>
  </svg>
</div>
<style>
.sutol-edeb31-wrap{width:100%;height:100%;background:transparent;}
.sutol-edeb31-svg{width:100%;height:100%;}
.sutol-edeb31-book{fill:#f4e3c1;stroke:#8b5e34;stroke-width:1;}
.sutol-edeb31-wing{fill:#e07a5f;transform-box:fill-box;transform-origin:0 0;animation:sutol-edeb31-flap .35s ease-in-out infinite alternate;}
.sutol-edeb31-wing2{fill:#81b29a;}
@keyframes sutol-edeb31-flap{
  0%{transform:scaleX(1);}
  100%{transform:scaleX(.3);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb31-wing{animation-duration:1.4s;}
  .sutol-edeb31-fly1 animateMotion, .sutol-edeb31-fly2 animateMotion{}
}
</style>
```

---

## Bileşen 32: Trajik Kahramanın Düşüşü

**Etiketler (keyword eşleşmesi için):** trajedi, drama, karakter, olay örgüsü
**Kategori:** Edebiyat
**Açıklama:** Yükseklerden aşağı düşen koyu bir siluetin ardında dağılan küçük parçaların, trajik kahramanın çöküşünü simgelemesi.

```html
<div class="sutol-edeb32-wrap">
  <div class="sutol-edeb32-stage">
    <div class="sutol-edeb32-figure"></div>
    <div class="sutol-edeb32-shard sutol-edeb32-s1"></div>
    <div class="sutol-edeb32-shard sutol-edeb32-s2"></div>
    <div class="sutol-edeb32-shard sutol-edeb32-s3"></div>
  </div>
</div>
<style>
.sutol-edeb32-wrap{width:100%;height:100%;background:transparent;overflow:hidden;position:relative;}
.sutol-edeb32-stage{position:absolute;inset:0;}
.sutol-edeb32-figure{position:absolute;top:5%;left:46%;width:8%;height:18%;background:#22223b;border-radius:30% 30% 10% 10%;animation:sutol-edeb32-fall 3.6s ease-in infinite;}
.sutol-edeb32-shard{position:absolute;top:70%;width:5%;height:5%;background:#4a4e69;opacity:0;animation:sutol-edeb32-scatter 3.6s ease-out infinite;}
.sutol-edeb32-s1{left:42%;animation-delay:2.4s;}
.sutol-edeb32-s2{left:50%;animation-delay:2.5s;}
.sutol-edeb32-s3{left:58%;animation-delay:2.6s;}
@keyframes sutol-edeb32-fall{
  0%{top:5%;transform:rotate(0deg);}
  65%{top:70%;transform:rotate(200deg);}
  70%,100%{top:70%;transform:rotate(200deg);opacity:0;}
}
@keyframes sutol-edeb32-scatter{
  0%,64%{opacity:0;transform:translate(0,0);}
  70%{opacity:1;}
  100%{opacity:0;transform:translate(var(--dx,10px),30px);}
}
.sutol-edeb32-s1{--dx:-18px;}
.sutol-edeb32-s3{--dx:18px;}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb32-figure,.sutol-edeb32-shard{animation-duration:12s;}
}
</style>
```

---

## Bileşen 33: Efsane Yıldız Haritası

**Etiketler (keyword eşleşmesi için):** mitoloji, destan, ejderha, sembol
**Kategori:** Edebiyat
**Açıklama:** Karanlıkta dağınık duran yıldız noktalarının, çizilen çizgilerle birleşerek efsanevi bir takımyıldız şekli oluşturması.

```html
<div class="sutol-edeb33-wrap">
  <svg class="sutol-edeb33-svg" viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-edeb33-line" d="M30,90 L70,40 L110,60 L150,20 L170,55"></path>
    <circle class="sutol-edeb33-star" cx="30" cy="90" r="3.5"></circle>
    <circle class="sutol-edeb33-star" cx="70" cy="40" r="3.5"></circle>
    <circle class="sutol-edeb33-star" cx="110" cy="60" r="3.5"></circle>
    <circle class="sutol-edeb33-star" cx="150" cy="20" r="3.5"></circle>
    <circle class="sutol-edeb33-star" cx="170" cy="55" r="3.5"></circle>
  </svg>
</div>
<style>
.sutol-edeb33-wrap{width:100%;height:100%;background:transparent;}
.sutol-edeb33-svg{width:100%;height:100%;}
.sutol-edeb33-line{fill:none;stroke:#ffd166;stroke-width:1.5;stroke-dasharray:260;stroke-dashoffset:260;animation:sutol-edeb33-draw 3.5s ease-in-out infinite;}
.sutol-edeb33-star{fill:#f8f9fa;animation:sutol-edeb33-twinkle 1.8s ease-in-out infinite;}
@keyframes sutol-edeb33-draw{
  0%{stroke-dashoffset:260;}
  55%,80%{stroke-dashoffset:0;}
  100%{stroke-dashoffset:-260;}
}
@keyframes sutol-edeb33-twinkle{
  0%,100%{opacity:.5;}
  50%{opacity:1;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb33-line{animation-duration:12s;}
  .sutol-edeb33-star{animation-duration:6s;}
}
</style>
```

---

## Bileşen 34: Kalem Ucundan Dökülen Şekil Yağmuru

**Etiketler (keyword eşleşmesi için):** dil, üslup, şiir dizesi, edebiyat
**Kategori:** Edebiyat
**Açıklama:** Sabit bir kalem ucundan aşağı doğru sürekli dökülen küçük soyut işaretlerin, yazının akışını simgeleyen bir yağmur gibi düşmesi.

```html
<div class="sutol-edeb34-wrap">
  <canvas class="sutol-edeb34-canvas"></canvas>
</div>
<style>
.sutol-edeb34-wrap{width:100%;height:100%;background:transparent;}
.sutol-edeb34-canvas{width:100%;height:100%;display:block;}
</style>
<script>
(function(){
  var container = document.currentScript.closest('.sutol-edeb34-wrap');
  var canvas = container.querySelector('.sutol-edeb34-canvas');
  var ctx = canvas.getContext('2d');
  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var marks = [];
  var n = 12;
  function resize(){
    canvas.width = canvas.clientWidth || 300;
    canvas.height = canvas.clientHeight || 150;
  }
  function init(){
    resize();
    marks = [];
    for(var i=0;i<n;i++){
      marks.push({
        x: canvas.width*0.5 + (Math.random()-0.5)*canvas.width*0.5,
        y: Math.random()*canvas.height,
        speed: (reduced?0.3:1) * (0.6 + Math.random()*0.8),
        w: 3 + Math.random()*4,
        h: 8 + Math.random()*8,
        rot: Math.random()*Math.PI
      });
    }
  }
  function draw(){
    ctx.clearRect(0,0,canvas.width,canvas.height);
    for(var i=0;i<marks.length;i++){
      var m = marks[i];
      m.y += m.speed;
      if(m.y > canvas.height){ m.y = -10; m.x = canvas.width*0.5 + (Math.random()-0.5)*canvas.width*0.5; }
      ctx.save();
      ctx.translate(m.x, m.y);
      ctx.rotate(m.rot);
      ctx.fillStyle = 'rgba(58,42,32,0.55)';
      ctx.fillRect(-m.w/2, -m.h/2, m.w, m.h);
      ctx.restore();
    }
    requestAnimationFrame(draw);
  }
  init();
  window.addEventListener('resize', resize);
  requestAnimationFrame(draw);
})();
</script>
```

---

## Bileşen 35: Anlatıcı Sesi Yankı Halkaları

**Etiketler (keyword eşleşmesi için):** anlatı, diyalog, dil, roman
**Kategori:** Edebiyat
**Açıklama:** Merkezden dışa doğru genişleyip sönümlenen eşmerkezli halkaların, bir anlatıcının sesinin yankılanmasını simgelemesi.

```html
<div class="sutol-edeb35-wrap">
  <div class="sutol-edeb35-center">
    <span class="sutol-edeb35-ring" style="animation-delay:0s"></span>
    <span class="sutol-edeb35-ring" style="animation-delay:.6s"></span>
    <span class="sutol-edeb35-ring" style="animation-delay:1.2s"></span>
    <span class="sutol-edeb35-dot"></span>
  </div>
</div>
<style>
.sutol-edeb35-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-edeb35-center{position:relative;width:20%;height:20%;}
.sutol-edeb35-ring{position:absolute;inset:0;border-radius:50%;border:2px solid #4361ee;opacity:0;animation:sutol-edeb35-echo 2.4s ease-out infinite;}
.sutol-edeb35-dot{position:absolute;inset:35%;border-radius:50%;background:#3a0ca3;}
@keyframes sutol-edeb35-echo{
  0%{transform:scale(1);opacity:.8;}
  100%{transform:scale(3.2);opacity:0;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb35-ring{animation-duration:9s;}
}
</style>
```

---

## Bileşen 36: Kurgu Dünyası Döner Küresi

**Etiketler (keyword eşleşmesi için):** roman, hikaye, anlatı, sembol
**Kategori:** Edebiyat
**Açıklama:** Kurgusal bir dünyayı temsil eden, birbirini kesen enlem-boylam halkalarıyla oluşturulmuş bir kürenin üç boyutlu olarak sürekli dönmesi.

```html
<div class="sutol-edeb36-wrap">
  <div class="sutol-edeb36-scene">
    <div class="sutol-edeb36-globe">
      <div class="sutol-edeb36-ring sutol-edeb36-r1"></div>
      <div class="sutol-edeb36-ring sutol-edeb36-r2"></div>
      <div class="sutol-edeb36-ring sutol-edeb36-r3"></div>
      <div class="sutol-edeb36-core"></div>
    </div>
  </div>
</div>
<style>
.sutol-edeb36-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;perspective:600px;}
.sutol-edeb36-scene{width:50%;height:50%;transform-style:preserve-3d;}
.sutol-edeb36-globe{position:relative;width:100%;height:100%;transform-style:preserve-3d;animation:sutol-edeb36-spin 6s linear infinite;}
.sutol-edeb36-ring{position:absolute;inset:0;border:2px solid #219ebc;border-radius:50%;}
.sutol-edeb36-r1{transform:rotateY(0deg);}
.sutol-edeb36-r2{transform:rotateY(60deg);border-color:#8ecae6;}
.sutol-edeb36-r3{transform:rotateX(60deg);border-color:#023047;}
.sutol-edeb36-core{position:absolute;inset:30%;border-radius:50%;background:#ffb703;opacity:.8;}
@keyframes sutol-edeb36-spin{
  0%{transform:rotateY(0deg) rotateX(10deg);}
  100%{transform:rotateY(360deg) rotateX(10deg);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb36-globe{animation-duration:24s;}
}
</style>
```

---

## Bileşen 37: Şiirin Nabzı Ritim Çizgisi

**Etiketler (keyword eşleşmesi için):** şiir, ritim, şiir dizesi, üslup
**Kategori:** Edebiyat
**Açıklama:** Bir kalp atışı çizgisini andıran zikzaklı bir hattın, şiirin ölçü ve ritmini vurgulayarak soldan sağa sürekli akması.

```html
<div class="sutol-edeb37-wrap">
  <svg class="sutol-edeb37-svg" viewBox="0 0 200 60" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-edeb37-line" d="M0,30 L30,30 L40,10 L50,50 L60,20 L70,30 L100,30 L110,10 L120,50 L130,20 L140,30 L200,30"></path>
  </svg>
</div>
<style>
.sutol-edeb37-wrap{width:100%;height:100%;background:transparent;}
.sutol-edeb37-svg{width:100%;height:100%;}
.sutol-edeb37-line{fill:none;stroke:#d62828;stroke-width:2.5;stroke-linejoin:round;stroke-linecap:round;stroke-dasharray:60 400;stroke-dashoffset:0;animation:sutol-edeb37-travel 2.6s linear infinite;}
@keyframes sutol-edeb37-travel{
  to{stroke-dashoffset:-460;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb37-line{animation-duration:9s;}
}
</style>
```

---

## Bileşen 38: Karakter Gelişim Merdiveni

**Etiketler (keyword eşleşmesi için):** karakter, roman, olay örgüsü, eleştiri
**Kategori:** Edebiyat
**Açıklama:** Yükselen basamaklar boyunca tırmanan parlak bir noktanın, bir karakterin zaman içindeki gelişimini adım adım göstermesi.

```html
<div class="sutol-edeb38-wrap">
  <div class="sutol-edeb38-stairs">
    <div class="sutol-edeb38-step" style="left:0%;bottom:0%"></div>
    <div class="sutol-edeb38-step" style="left:20%;bottom:15%"></div>
    <div class="sutol-edeb38-step" style="left:40%;bottom:30%"></div>
    <div class="sutol-edeb38-step" style="left:60%;bottom:45%"></div>
    <div class="sutol-edeb38-step" style="left:80%;bottom:60%"></div>
    <div class="sutol-edeb38-climber"></div>
  </div>
</div>
<style>
.sutol-edeb38-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:flex-end;justify-content:center;}
.sutol-edeb38-stairs{position:relative;width:80%;height:80%;}
.sutol-edeb38-step{position:absolute;width:18%;height:12%;background:#4a4e69;border-radius:8%;}
.sutol-edeb38-climber{position:absolute;width:8%;height:8%;left:0%;bottom:8%;border-radius:50%;background:#f2e9e4;box-shadow:0 0 6px 2px #9a8c98;animation:sutol-edeb38-climb 4s ease-in-out infinite;}
@keyframes sutol-edeb38-climb{
  0%{left:0%;bottom:8%;}
  20%{left:20%;bottom:23%;}
  40%{left:40%;bottom:38%;}
  60%{left:60%;bottom:53%;}
  80%,100%{left:80%;bottom:68%;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb38-climber{animation-duration:14s;}
}
</style>
```

---

## Bileşen 39: Sonsuz Öykü Möbius Şeridi

**Etiketler (keyword eşleşmesi için):** hikaye, anlatı, destan, sembol
**Kategori:** Edebiyat
**Açıklama:** Halka biçiminde dizilmiş şerit parçalarının üç boyutlu düzlemde dönerek başı sonu olmayan bir öykü döngüsü izlenimi vermesi.

```html
<div class="sutol-edeb39-wrap">
  <div class="sutol-edeb39-scene">
    <div class="sutol-edeb39-loop">
      <div class="sutol-edeb39-face" style="transform:rotateY(0deg) translateZ(40px)"></div>
      <div class="sutol-edeb39-face" style="transform:rotateY(45deg) translateZ(40px)"></div>
      <div class="sutol-edeb39-face" style="transform:rotateY(90deg) translateZ(40px)"></div>
      <div class="sutol-edeb39-face" style="transform:rotateY(135deg) translateZ(40px)"></div>
      <div class="sutol-edeb39-face" style="transform:rotateY(180deg) translateZ(40px)"></div>
      <div class="sutol-edeb39-face" style="transform:rotateY(225deg) translateZ(40px)"></div>
      <div class="sutol-edeb39-face" style="transform:rotateY(270deg) translateZ(40px)"></div>
      <div class="sutol-edeb39-face" style="transform:rotateY(315deg) translateZ(40px)"></div>
    </div>
  </div>
</div>
<style>
.sutol-edeb39-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;perspective:500px;}
.sutol-edeb39-scene{width:50%;height:50%;transform-style:preserve-3d;}
.sutol-edeb39-loop{position:relative;width:100%;height:100%;transform-style:preserve-3d;animation:sutol-edeb39-turn 8s linear infinite;}
.sutol-edeb39-face{position:absolute;top:40%;left:10%;width:80%;height:20%;background:linear-gradient(90deg,#6a4c93,#b892ff);border-radius:20%;opacity:.85;}
@keyframes sutol-edeb39-turn{
  0%{transform:rotateX(20deg) rotateY(0deg);}
  100%{transform:rotateX(20deg) rotateY(360deg);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb39-loop{animation-duration:28s;}
}
</style>
```

---

## Bileşen 40: Edebi Mirasın Ağaç Halkaları

**Etiketler (keyword eşleşmesi için):** edebi akım, biyografi, eleştiri, edebiyat
**Kategori:** Edebiyat
**Açıklama:** Bir ağaç gövdesi kesitindeki büyüme halkaları gibi, merkezden dışa doğru sırayla beliren eşmerkezli çemberlerin edebi mirasın katmanlarını simgelemesi.

```html
<div class="sutol-edeb40-wrap">
  <svg class="sutol-edeb40-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <circle cx="50" cy="50" r="0" fill="none" stroke="#7f5539" stroke-width="2">
      <animate attributeName="r" values="0;10;10" keyTimes="0;0.4;1" dur="4s" begin="0s" repeatCount="indefinite"></animate>
      <animate attributeName="opacity" values="0;1;1;0" keyTimes="0;0.1;0.9;1" dur="4s" begin="0s" repeatCount="indefinite"></animate>
    </circle>
    <circle cx="50" cy="50" r="0" fill="none" stroke="#9c6644" stroke-width="2">
      <animate attributeName="r" values="0;20;20" keyTimes="0;0.4;1" dur="4s" begin="0.5s" repeatCount="indefinite"></animate>
      <animate attributeName="opacity" values="0;1;1;0" keyTimes="0;0.1;0.9;1" dur="4s" begin="0.5s" repeatCount="indefinite"></animate>
    </circle>
    <circle cx="50" cy="50" r="0" fill="none" stroke="#c08552" stroke-width="2">
      <animate attributeName="r" values="0;30;30" keyTimes="0;0.4;1" dur="4s" begin="1s" repeatCount="indefinite"></animate>
      <animate attributeName="opacity" values="0;1;1;0" keyTimes="0;0.1;0.9;1" dur="4s" begin="1s" repeatCount="indefinite"></animate>
    </circle>
    <circle cx="50" cy="50" r="0" fill="none" stroke="#ddb892" stroke-width="2">
      <animate attributeName="r" values="0;40;40" keyTimes="0;0.4;1" dur="4s" begin="1.5s" repeatCount="indefinite"></animate>
      <animate attributeName="opacity" values="0;1;1;0" keyTimes="0;0.1;0.9;1" dur="4s" begin="1.5s" repeatCount="indefinite"></animate>
    </circle>
  </svg>
</div>
<style>
.sutol-edeb40-wrap{width:100%;height:100%;background:transparent;}
.sutol-edeb40-svg{width:100%;height:100%;}
@media (prefers-reduced-motion: reduce){
  .sutol-edeb40-svg animate{}
}
</style>
```

---

===BULLETS===
- Bileşen 21 (Kafiye Zinciri Halkaları): SVG stroke-dasharray akışı + CSS transform-box:fill-box ile ölçek nabzı; az sayıda düğüm olduğundan hafif.
- Bileşen 22 (Roman Zaman Sarmalı): SVG native `animateMotion` + `mpath` ile path üzerinde hareket; tek path/tek nokta olduğundan performans maliyeti düşük.
- Bileşen 23 (Kitap Kulesi İnşası): CSS `transform`/`opacity` keyframes ile staggered animasyon; GPU dostu, DOM manipülasyonu yok.
- Bileşen 24 (Daktilo Tuşları Dansı): CSS `transform: translateY` keyframes ile staggered "tuş basma"; düşük maliyetli, sadece transform kullanır.
- Bileşen 25 (Söz Sanatları Prizması): CSS `transform: scaleX` + `opacity` keyframes, `transform-origin:left`; SVG statik şekiller üzerine hafif animasyon katmanı.
- Bileşen 26 (Anlatıcı Bakış Açısı Merceği): CSS `clip-path: circle()` animasyonu + `transform: scale`; clip-path animasyonu bazı tarayıcılarda hafif CPU maliyetli olabilir ama eleman sayısı azdır.
- Bileşen 27 (Şiirsel İmge Bulutu): Canvas + `requestAnimationFrame`; `prefers-reduced-motion` kontrolüyle hız düşürülüyor, `resize` dinleyicisi ile responsive.
- Bileşen 28 (Kahramanın Yolculuğu Çemberi): CSS motion-path (`offset-path`/`offset-distance`) ile dairesel hareket; tek eleman animasyonu olduğundan performanslı.
- Bileşen 29 (Nesir-Nazım Terazisi): SVG üzerinde CSS `transform: rotate` ile pivot animasyonu (`transform-box:view-box`); hafif ve sürekli.
- Bileşen 30 (Papirüs Tomarının Açılışı): CSS `transform: scaleX` keyframes ile "açılma" efekti; tek elemanlı transform, düşük maliyetli.
- Bileşen 31 (Sayfalardan Uçuşan Kelebekler): SVG native `animateMotion`/`mpath` + CSS `transform: scaleX` kanat çırpma; birkaç eleman ile sınırlı, hafif.
- Bileşen 32 (Trajik Kahramanın Düşüşü): CSS `transform: translate/rotate` + `opacity` keyframes, gecikmeli parça dağılma efekti; sadece transform/opacity kullanır.
- Bileşen 33 (Efsane Yıldız Haritası): SVG `stroke-dasharray`/`stroke-dashoffset` çizim animasyonu + CSS `opacity` titreşimi; az eleman, performanslı.
- Bileşen 34 (Kalem Ucundan Dökülen Şekil Yağmuru): Canvas + `requestAnimationFrame`, döngüsel parçacık sistemi; `prefers-reduced-motion` ile hız azaltma, `resize` desteği.
- Bileşen 35 (Anlatıcı Sesi Yankı Halkaları): CSS `transform: scale` + `opacity` keyframes, staggered "sonar" halkaları; düşük maliyetli GPU animasyonu.
- Bileşen 36 (Kurgu Dünyası Döner Küresi): Saf CSS 3D (`perspective`, `preserve-3d`, `rotateY/rotateX`) döner küre; sadece transform kullanıldığından GPU hızlandırmalı.
- Bileşen 37 (Şiirin Nabzı Ritim Çizgisi): SVG `stroke-dasharray`/`stroke-dashoffset` ile hareketli çizgi efekti (EKG tarzı); tek path, hafif.
- Bileşen 38 (Karakter Gelişim Merdiveni): CSS çok adımlı `keyframes` ile `left`/`bottom` konum değişimi; basit statik basamaklar üzerinde tek hareketli eleman.
- Bileşen 39 (Sonsuz Öykü Möbius Şeridi): Saf CSS 3D (`perspective`, `preserve-3d`, `rotateX/rotateY`, `translateZ`) halka dönüşü; 8 yüzeyle sınırlı, GPU dostu transform.
- Bileşen 40 (Edebi Mirasın Ağaç Halkaları): SVG native `<animate>` ile `r` ve `opacity` özniteliklerinin zincirlenmiş (`begin` gecikmeli) animasyonu; deklaratif SVG animasyonu, JS gerektirmez.
