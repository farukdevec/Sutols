# Sutol — Şehir Yaşamı & Kentsel Altyapı Kategorisi Animasyonlu Bileşenleri (20 Adet)

Aşağıda "Şehir Yaşamı & Kentsel Altyapı" kategorisi için üretilmiş, her biri tek dosya/tek `<div>` kökünde çalışan, dış kaynak kullanmayan, şeffaf arka planlı 20 animasyonlu HTML bileşeni bulunmaktadır. Her bileşen `sutol-kent-NN-...` öneki ile kapsüllenmiştir, `prefers-reduced-motion` desteği içerir ve sandbox'a uyumludur.

---

## Bileşen 1: Gökdelen Silueti

**Etiketler (keyword eşleşmesi için):** gökdelen, akıllı şehir, şehir meydanı, aydınlatma direği
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Pencereleri rastgele aralıklarla yanıp sönen, farklı yüksekliklerde gökdelenlerden oluşan bir şehir silueti.

```html
<div class="sutol-kent-01-siluet">
  <svg viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="70" width="30" height="90" fill="#3d4d68"/>
    <rect x="45" y="40" width="34" height="120" fill="#4a5a7a"/>
    <rect x="84" y="60" width="26" height="100" fill="#3d4d68"/>
    <rect x="115" y="25" width="32" height="135" fill="#5a6a8a"/>
    <rect x="152" y="55" width="28" height="105" fill="#4a5a7a"/>
    <g class="sutol-kent-01-windows" fill="#f5d76e">
      <rect x="16" y="80" width="5" height="7" class="sutol-kent-01-w sutol-kent-01-w1"/>
      <rect x="27" y="95" width="5" height="7" class="sutol-kent-01-w sutol-kent-01-w2"/>
      <rect x="53" y="55" width="5" height="7" class="sutol-kent-01-w sutol-kent-01-w3"/>
      <rect x="65" y="80" width="5" height="7" class="sutol-kent-01-w sutol-kent-01-w4"/>
      <rect x="90" y="75" width="5" height="7" class="sutol-kent-01-w sutol-kent-01-w5"/>
      <rect x="122" y="40" width="5" height="7" class="sutol-kent-01-w sutol-kent-01-w6"/>
      <rect x="135" y="70" width="5" height="7" class="sutol-kent-01-w sutol-kent-01-w7"/>
      <rect x="160" y="70" width="5" height="7" class="sutol-kent-01-w sutol-kent-01-w8"/>
    </g>
  </svg>
</div>
<style>
.sutol-kent-01-siluet{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-kent-01-siluet svg{width:100%;height:100%;}
.sutol-kent-01-w{animation:sutolKent01Blink 4s ease-in-out infinite;}
.sutol-kent-01-w2{animation-delay:0.5s;}
.sutol-kent-01-w3{animation-delay:1s;}
.sutol-kent-01-w4{animation-delay:1.5s;}
.sutol-kent-01-w5{animation-delay:2s;}
.sutol-kent-01-w6{animation-delay:2.5s;}
.sutol-kent-01-w7{animation-delay:3s;}
.sutol-kent-01-w8{animation-delay:3.5s;}
@keyframes sutolKent01Blink{0%,100%{opacity:0.2;}50%{opacity:1;}}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-01-w{animation-duration:20s;}
}
</style>
```

---

## Bileşen 2: Metro İstasyonuna Giren Tren

**Etiketler (keyword eşleşmesi için):** metro istasyonu, toplu taşıma, akıllı şehir, altyapı ağı
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Yeraltı istasyonuna yaklaşıp peronun önünde duran bir metro treni. (Teknik: SVG SMIL `animateMotion`)

```html
<div class="sutol-kent-02-metro">
  <svg viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="0" width="200" height="120" fill="#2a2a35"/>
    <rect x="0" y="85" width="200" height="10" fill="#5f5f6a"/>
    <rect x="10" y="60" width="180" height="25" fill="#3d3d48"/>
    <circle cx="30" cy="72" r="2.5" fill="#f5d76e"/>
    <circle cx="90" cy="72" r="2.5" fill="#f5d76e"/>
    <circle cx="150" cy="72" r="2.5" fill="#f5d76e"/>
    <g class="sutol-kent-02-train">
      <animateMotion dur="6s" repeatCount="indefinite"
        keyPoints="0;0.75;0.78;0.78;1" keyTimes="0;0.6;0.68;0.9;1"
        path="M-60,0 L120,0"/>
      <rect x="-30" y="-16" width="60" height="16" rx="4" fill="#5b8ad6"/>
      <rect x="-24" y="-11" width="12" height="7" fill="#cfe0f5"/>
      <rect x="-6" y="-11" width="12" height="7" fill="#cfe0f5"/>
      <rect x="12" y="-11" width="12" height="7" fill="#cfe0f5"/>
    </g>
  </svg>
</div>
<style>
.sutol-kent-02-metro{width:100%;height:100%;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-kent-02-metro svg{width:100%;height:100%;transform:translateY(-5px);}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-02-train animateMotion{dur:26s;}
}
</style>
```

---
## Bileşen 3: Kentsel Dönüşüm

**Etiketler (keyword eşleşmesi için):** kentsel dönüşüm, gökdelen, altyapı ağı, akıllı şehir
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Eski, alçak bir binanın yerini modern bir gökdeleneye bıraktığı bir kentsel dönüşüm (yenileme) döngüsü.

```html
<div class="sutol-kent-03-donusum">
  <svg viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="130" width="200" height="30" fill="#8a8a8a"/>
    <g class="sutol-kent-03-old">
      <rect x="70" y="90" width="60" height="40" fill="#a08a6a" stroke="#6a5a40" stroke-width="2"/>
      <rect x="80" y="100" width="10" height="10" fill="#5a4a30"/>
      <rect x="110" y="100" width="10" height="10" fill="#5a4a30"/>
    </g>
    <g class="sutol-kent-03-new">
      <rect x="75" y="30" width="50" height="100" fill="#5a6a8a" stroke="#3a4a68" stroke-width="2"/>
      <rect x="82" y="40" width="8" height="10" fill="#cfe0f5"/>
      <rect x="96" y="40" width="8" height="10" fill="#cfe0f5"/>
      <rect x="110" y="40" width="8" height="10" fill="#cfe0f5"/>
      <rect x="82" y="60" width="8" height="10" fill="#cfe0f5"/>
      <rect x="96" y="60" width="8" height="10" fill="#cfe0f5"/>
      <rect x="110" y="60" width="8" height="10" fill="#cfe0f5"/>
    </g>
  </svg>
</div>
<style>
.sutol-kent-03-donusum{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-kent-03-donusum svg{width:100%;height:100%;}
.sutol-kent-03-old{transform-box:fill-box;transform-origin:bottom center;animation:sutolKent03Old 8s ease-in-out infinite;}
.sutol-kent-03-new{transform-box:fill-box;transform-origin:bottom center;animation:sutolKent03New 8s ease-in-out infinite;}
@keyframes sutolKent03Old{
  0%,35%{opacity:1;transform:scaleY(1);}
  50%,100%{opacity:0;transform:scaleY(0);}
}
@keyframes sutolKent03New{
  0%,35%{opacity:0;transform:scaleY(0);}
  55%,100%{opacity:1;transform:scaleY(1);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-03-old,.sutol-kent-03-new{animation-duration:34s;}
}
</style>
```

---

## Bileşen 4: Park Alanında Yürüyüş

**Etiketler (keyword eşleşmesi için):** park alanı, şehir meydanı, bisiklet yolu, yaya geçidi
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Rüzgârda sallanan ağaçların altında yolda yürüyen bir kişi figürü bulunan bir şehir parkı sahnesi.

```html
<div class="sutol-kent-04-park">
  <svg viewBox="0 0 200 140" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="100" width="200" height="40" fill="#8fbf7a"/>
    <rect x="20" y="115" width="160" height="10" fill="#c9b89a"/>
    <g class="sutol-kent-04-tree sutol-kent-04-t1" transform="translate(40,90)">
      <rect x="-3" y="0" width="6" height="20" fill="#7a5a3a"/>
      <circle cy="-15" r="20" fill="#4a9a5a"/>
    </g>
    <g class="sutol-kent-04-tree sutol-kent-04-t2" transform="translate(160,90)">
      <rect x="-3" y="0" width="6" height="20" fill="#7a5a3a"/>
      <circle cy="-15" r="18" fill="#5aa868"/>
    </g>
    <g class="sutol-kent-04-walker">
      <circle cx="0" cy="-20" r="5" fill="#e0a878"/>
      <rect x="-4" y="-15" width="8" height="12" rx="2" fill="#5b8ad6"/>
      <line x1="-3" y1="-3" x2="-5" y2="10" stroke="#3a3a3a" stroke-width="2.5"/>
      <line x1="3" y1="-3" x2="5" y2="10" stroke="#3a3a3a" stroke-width="2.5"/>
    </g>
  </svg>
</div>
<style>
.sutol-kent-04-park{width:100%;height:100%;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-kent-04-park svg{width:100%;height:100%;}
.sutol-kent-04-tree{animation:sutolKent04Sway 4s ease-in-out infinite;transform-box:fill-box;}
.sutol-kent-04-t2{animation-delay:0.7s;}
.sutol-kent-04-walker{transform:translate(20,120);animation:sutolKent04Walk 6s linear infinite;}
@keyframes sutolKent04Sway{0%,100%{rotate:-2deg;}50%{rotate:2deg;}}
@keyframes sutolKent04Walk{from{transform:translate(20px,120px);}to{transform:translate(180px,120px);}}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-04-tree,.sutol-kent-04-walker{animation-duration:24s;}
}
</style>
```

---
## Bileşen 5: Şehir Köprüsü

**Etiketler (keyword eşleşmesi için):** köprü, toplu taşıma, altyapı ağı, akıllı şehir
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Askı kabloları hafifçe titreşen bir asma köprü üzerinde soldan sağa geçen araçlar.

```html
<div class="sutol-kent-05-kopru">
  <svg viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="90" width="200" height="8" fill="#5f5f6a"/>
    <rect x="30" y="20" width="8" height="70" fill="#3d4d68"/>
    <rect x="162" y="20" width="8" height="70" fill="#3d4d68"/>
    <path d="M34,25 Q100,60 166,25" fill="none" stroke="#8a8a94" stroke-width="2"/>
    <g class="sutol-kent-05-cables" stroke="#8a8a94" stroke-width="1.5">
      <line x1="50" y1="90" x2="45" y2="30"/>
      <line x1="70" y1="90" x2="60" y2="45"/>
      <line x1="90" y1="90" x2="80" y2="55"/>
      <line x1="110" y1="90" x2="120" y2="55"/>
      <line x1="130" y1="90" x2="140" y2="45"/>
      <line x1="150" y1="90" x2="155" y2="30"/>
    </g>
    <rect class="sutol-kent-05-car sutol-kent-05-c1" x="-20" y="80" width="20" height="10" rx="2" fill="#d65b5b"/>
    <rect class="sutol-kent-05-car sutol-kent-05-c2" x="-20" y="80" width="20" height="10" rx="2" fill="#5b8ad6"/>
  </svg>
</div>
<style>
.sutol-kent-05-kopru{width:100%;height:100%;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-kent-05-kopru svg{width:100%;height:100%;}
.sutol-kent-05-cables{animation:sutolKent05Sway 5s ease-in-out infinite;transform-origin:100px 60px;}
.sutol-kent-05-car{animation:sutolKent05Drive 5s linear infinite;}
.sutol-kent-05-c2{animation-delay:2.5s;}
@keyframes sutolKent05Sway{0%,100%{transform:scaleY(1);}50%{transform:scaleY(1.015);}}
@keyframes sutolKent05Drive{from{transform:translateX(0);}to{transform:translateX(240px);}}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-05-cables,.sutol-kent-05-car{animation-duration:24s;}
}
</style>
```

---

## Bileşen 6: Sokak Aydınlatma Direği

**Etiketler (keyword eşleşmesi için):** aydınlatma direği, akıllı şehir, şehir meydanı, yaya geçidi
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Alacakaranlıkta yanan ve çevresine yumuşak ışık halesi yayan bir sokak lambası.

```html
<div class="sutol-kent-06-direk">
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="0" width="200" height="200" fill="#1a2035"/>
    <rect x="96" y="60" width="8" height="120" fill="#3d3d48"/>
    <path d="M96,60 L70,50 L70,44 L96,50 Z" fill="#3d3d48"/>
    <circle class="sutol-kent-06-glow" cx="70" cy="47" r="35" fill="#f5d76e" opacity="0.15"/>
    <ellipse cx="70" cy="47" rx="8" ry="5" fill="#f5e08a" class="sutol-kent-06-bulb"/>
  </svg>
</div>
<style>
.sutol-kent-06-direk{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-kent-06-direk svg{width:100%;height:100%;}
.sutol-kent-06-glow{animation:sutolKent06Glow 4s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
.sutol-kent-06-bulb{animation:sutolKent06Bulb 4s ease-in-out infinite;}
@keyframes sutolKent06Glow{0%,100%{opacity:0.1;transform:scale(1);}50%{opacity:0.35;transform:scale(1.15);}}
@keyframes sutolKent06Bulb{0%,100%{opacity:0.75;}50%{opacity:1;}}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-06-glow,.sutol-kent-06-bulb{animation-duration:20s;}
}
</style>
```

---
## Bileşen 7: Akıllı Şehir Veri Ağı

**Etiketler (keyword eşleşmesi için):** akıllı şehir, altyapı ağı, gökdelen, aydınlatma direği
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Binalar arasında sürekli veri sinyalleri dolaşan, birbirine bağlı bir akıllı şehir ağı. (Teknik: Canvas + `requestAnimationFrame`)

```html
<div class="sutol-kent-07-akillisehir">
  <canvas class="sutol-kent-07-canvas"></canvas>
</div>
<style>
.sutol-kent-07-akillisehir{width:100%;height:100%;position:relative;}
.sutol-kent-07-canvas{width:100%;height:100%;display:block;}
</style>
<script>
(function(){
  var root = document.currentScript.previousElementSibling;
  var canvas = root.querySelector('.sutol-kent-07-canvas');
  var ctx = canvas.getContext('2d');
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function resize(){
    var rect = root.getBoundingClientRect();
    canvas.width = Math.max(rect.width,1) * (window.devicePixelRatio || 1);
    canvas.height = Math.max(rect.height,1) * (window.devicePixelRatio || 1);
  }
  resize();
  window.addEventListener('resize', resize);

  var buildings = [
    {x:0.15,y:0.75,h:0.35},{x:0.35,y:0.6,h:0.5},{x:0.55,y:0.7,h:0.4},
    {x:0.75,y:0.5,h:0.6},{x:0.9,y:0.72,h:0.38}
  ];
  var edges = [[0,1],[1,2],[2,3],[3,4],[1,3]];
  var t = 0;
  var speed = reduceMotion ? 0.0015 : 0.006;

  function topOf(b){ return {x:b.x, y:1-b.h}; }

  function draw(){
    var w = canvas.width, h = canvas.height;
    ctx.clearRect(0,0,w,h);

    buildings.forEach(function(b){
      ctx.fillStyle = '#3d4d68';
      ctx.fillRect(b.x*w - w*0.035, (1-b.h)*h, w*0.07, b.h*h);
    });

    ctx.strokeStyle = 'rgba(127,214,240,0.35)';
    ctx.lineWidth = w*0.004;
    edges.forEach(function(e){
      var a = topOf(buildings[e[0]]), b = topOf(buildings[e[1]]);
      ctx.beginPath();
      ctx.moveTo(a.x*w,a.y*h);
      ctx.lineTo(b.x*w,b.y*h);
      ctx.stroke();
    });

    edges.forEach(function(e,i){
      var a = topOf(buildings[e[0]]), b = topOf(buildings[e[1]]);
      var frac = (t + i*0.2) % 1;
      var x = a.x + (b.x-a.x)*frac, y = a.y + (b.y-a.y)*frac;
      ctx.fillStyle = '#7fd6f0';
      ctx.beginPath();
      ctx.arc(x*w,y*h,w*0.012,0,Math.PI*2);
      ctx.fill();
    });

    t += speed;
    requestAnimationFrame(draw);
  }
  requestAnimationFrame(draw);
})();
</script>
```

---

## Bileşen 8: Toplu Taşıma Durağı

**Etiketler (keyword eşleşmesi için):** toplu taşıma, şehir meydanı, akıllı şehir, aydınlatma direği
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Durağa yaklaşıp kapılarını açan ve yolcu bindiren bir şehir otobüsü.

```html
<div class="sutol-kent-08-durak">
  <svg viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="95" width="200" height="6" fill="#8a8a8a"/>
    <rect x="140" y="55" width="4" height="45" fill="#5f5f6a"/>
    <rect x="140" y="50" width="45" height="5" fill="#5f5f6a"/>
    <rect x="140" y="55" width="45" height="30" fill="#cfe0f5" opacity="0.4"/>
    <g class="sutol-kent-08-bus">
      <rect x="0" y="55" width="70" height="35" rx="6" fill="#e0c04a"/>
      <rect x="8" y="62" width="14" height="14" fill="#cfe0f5"/>
      <rect x="26" y="62" width="14" height="14" fill="#cfe0f5"/>
      <rect class="sutol-kent-08-door" x="46" y="62" width="14" height="20" fill="#8a8a94"/>
      <circle cx="14" cy="92" r="6" fill="#2a2a2a"/>
      <circle cx="56" cy="92" r="6" fill="#2a2a2a"/>
    </g>
    <circle class="sutol-kent-08-passenger" cx="150" cy="85" r="5" fill="#e0a878"/>
  </svg>
</div>
<style>
.sutol-kent-08-durak{width:100%;height:100%;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-kent-08-durak svg{width:100%;height:100%;}
.sutol-kent-08-bus{animation:sutolKent08Move 6s ease-in-out infinite;}
.sutol-kent-08-door{animation:sutolKent08Door 6s ease-in-out infinite;transform-box:fill-box;transform-origin:left;}
.sutol-kent-08-passenger{animation:sutolKent08Board 6s ease-in-out infinite;}
@keyframes sutolKent08Move{0%,15%{transform:translateX(0);}40%,75%{transform:translateX(75px);}100%{transform:translateX(220px);}}
@keyframes sutolKent08Door{0%,20%,90%,100%{transform:scaleX(1);}35%,80%{transform:scaleX(0.1);}}
@keyframes sutolKent08Board{0%,40%{opacity:1;transform:translate(0,0);}55%,100%{opacity:0;transform:translate(-30px,3px);}}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-08-bus,.sutol-kent-08-door,.sutol-kent-08-passenger{animation-duration:26s;}
}
</style>
```

---
## Bileşen 9: Şehir Meydanı Çeşmesi

**Etiketler (keyword eşleşmesi için):** şehir meydanı, park alanı, akıllı şehir, aydınlatma direği
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Ortasından sürekli su fışkırtan, meydanın merkezinde yer alan taş bir çeşme.

```html
<div class="sutol-kent-09-cesme">
  <svg viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <ellipse cx="100" cy="130" rx="70" ry="16" fill="#cfd6de" stroke="#9aa4b0" stroke-width="2"/>
    <rect x="90" y="80" width="20" height="50" fill="#b8c0c9"/>
    <path class="sutol-kent-09-jet sutol-kent-09-j1" d="M100,80 Q90,55 70,45" fill="none" stroke="#8fd6f0" stroke-width="4" stroke-linecap="round"/>
    <path class="sutol-kent-09-jet sutol-kent-09-j2" d="M100,80 Q100,45 100,30" fill="none" stroke="#8fd6f0" stroke-width="4" stroke-linecap="round"/>
    <path class="sutol-kent-09-jet sutol-kent-09-j3" d="M100,80 Q110,55 130,45" fill="none" stroke="#8fd6f0" stroke-width="4" stroke-linecap="round"/>
  </svg>
</div>
<style>
.sutol-kent-09-cesme{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-kent-09-cesme svg{width:100%;height:100%;}
.sutol-kent-09-jet{stroke-dasharray:60;stroke-dashoffset:60;animation:sutolKent09Spray 2s ease-out infinite;}
.sutol-kent-09-j2{animation-delay:0.3s;}
.sutol-kent-09-j3{animation-delay:0.6s;}
@keyframes sutolKent09Spray{
  0%{stroke-dashoffset:60;opacity:0;}
  30%{opacity:1;}
  70%{stroke-dashoffset:0;opacity:1;}
  100%{stroke-dashoffset:-60;opacity:0;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-09-jet{animation-duration:10s;}
}
</style>
```

---

## Bileşen 10: Yeraltı Altyapı Ağı

**Etiketler (keyword eşleşmesi için):** altyapı ağı, kanalizasyon sistemi, akıllı şehir, gökdelen
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Şehrin yüzeyinin altında uzanan boru ve kablo hattının çizilip üzerinden sinyallerin aktığı bir altyapı şeması. (Teknik: `stroke-dasharray` yol çizimi + CSS `offset-path`)

```html
<div class="sutol-kent-10-altyapi">
  <svg viewBox="0 0 200 140" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="0" width="200" height="30" fill="#8fbf9a"/>
    <rect x="20" y="0" width="14" height="30" fill="#5a6a8a"/>
    <rect x="90" y="0" width="14" height="30" fill="#5a6a8a"/>
    <rect x="160" y="0" width="14" height="30" fill="#5a6a8a"/>
    <path class="sutol-kent-10-pipe" d="M27,30 L27,60 L97,60 L97,90 L167,90 L167,30"
          fill="none" stroke="#8a8a94" stroke-width="8" stroke-linecap="round"/>
  </svg>
  <div class="sutol-kent-10-signal"></div>
</div>
<style>
.sutol-kent-10-altyapi{position:relative;width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-kent-10-altyapi svg{width:100%;height:100%;}
.sutol-kent-10-pipe{
  stroke-dasharray:230;
  stroke-dashoffset:230;
  animation:sutolKent10Draw 6s ease-in-out infinite;
}
.sutol-kent-10-signal::before{
  content:'';position:absolute;width:8px;height:8px;border-radius:50%;background:#7fd6a0;
  offset-path:path('M27,30 L27,60 L97,60 L97,90 L167,90 L167,30');
  animation:sutolKent10Flow 6s ease-in-out infinite;
}
@keyframes sutolKent10Draw{
  0%{stroke-dashoffset:230;}
  50%,100%{stroke-dashoffset:0;}
}
@keyframes sutolKent10Flow{
  0%,50%{offset-distance:0%;opacity:0;}
  60%{opacity:1;}
  95%{opacity:1;}
  100%{offset-distance:100%;opacity:0;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-10-pipe{animation-duration:26s;}
  .sutol-kent-10-signal::before{animation-duration:26s;}
}
</style>
```

---
## Bileşen 11: Kanalizasyon Sistemi

**Etiketler (keyword eşleşmesi için):** kanalizasyon sistemi, altyapı ağı, kentsel dönüşüm, akıllı şehir
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Yeraltı borularında sürekli akan ve bir menfeze doğru ilerleyen atık su akışı. (Teknik: CSS `offset-path`)

```html
<div class="sutol-kent-11-kanalizasyon">
  <svg viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="20" y="20" width="160" height="26" rx="13" fill="#5a5a64" stroke="#3a3a42" stroke-width="2"/>
    <rect x="20" y="70" width="160" height="26" rx="13" fill="#5a5a64" stroke="#3a3a42" stroke-width="2"/>
    <path d="M180,33 C195,33 195,83 180,83" fill="none" stroke="#3a3a42" stroke-width="4"/>
  </svg>
  <div class="sutol-kent-11-water">
    <span class="sutol-kent-11-w1"></span>
    <span class="sutol-kent-11-w2"></span>
  </div>
</div>
<style>
.sutol-kent-11-kanalizasyon{position:relative;width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-kent-11-kanalizasyon svg{width:100%;height:100%;}
.sutol-kent-11-water span{
  position:absolute;width:10px;height:10px;border-radius:50%;background:#6a8a6a;
  offset-path:path('M20,33 L170,33 C185,33 185,83 170,83 L20,83');
  animation:sutolKent11Flow 4s linear infinite;
}
.sutol-kent-11-w2{animation-delay:2s;}
@keyframes sutolKent11Flow{
  0%{offset-distance:0%;opacity:0.9;}
  100%{offset-distance:100%;opacity:0.9;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-11-water span{animation-duration:18s;}
}
</style>
```

---

## Bileşen 12: Yaya Geçidi

**Etiketler (keyword eşleşmesi için):** yaya geçidi, şehir meydanı, toplu taşıma, aydınlatma direği
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Yaya ışığı yeşile döndüğünde zebra çizgilerinden karşıya geçen bir yaya figürü.

```html
<div class="sutol-kent-12-yayagecidi">
  <svg viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="60" width="200" height="40" fill="#4a4a52"/>
    <g fill="#eaeaea">
      <rect x="20" y="65" width="16" height="30"/>
      <rect x="52" y="65" width="16" height="30"/>
      <rect x="84" y="65" width="16" height="30"/>
      <rect x="116" y="65" width="16" height="30"/>
      <rect x="148" y="65" width="16" height="30"/>
    </g>
    <rect x="175" y="30" width="12" height="30" fill="#2a2a2a"/>
    <circle cx="181" cy="38" r="4" class="sutol-kent-12-red" fill="#d65b5b"/>
    <circle cx="181" cy="50" r="4" class="sutol-kent-12-green" fill="#5bd68a"/>
    <g class="sutol-kent-12-walker">
      <circle cx="0" cy="-14" r="4" fill="#e0a878"/>
      <rect x="-3" y="-10" width="6" height="9" rx="1.5" fill="#d65b8a"/>
      <line x1="-2" y1="-1" x2="-4" y2="8" stroke="#3a3a3a" stroke-width="2"/>
      <line x1="2" y1="-1" x2="4" y2="8" stroke="#3a3a3a" stroke-width="2"/>
    </g>
  </svg>
</div>
<style>
.sutol-kent-12-yayagecidi{width:100%;height:100%;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-kent-12-yayagecidi svg{width:100%;height:100%;}
.sutol-kent-12-red{animation:sutolKent12Red 6s ease-in-out infinite;}
.sutol-kent-12-green{animation:sutolKent12Green 6s ease-in-out infinite;}
.sutol-kent-12-walker{transform:translate(15,88);animation:sutolKent12Walk 6s ease-in-out infinite;}
@keyframes sutolKent12Red{0%,60%{opacity:1;}61%,100%{opacity:0.25;}}
@keyframes sutolKent12Green{0%,60%{opacity:0.25;}61%,100%{opacity:1;}}
@keyframes sutolKent12Walk{
  0%,60%{transform:translate(15px,88px);opacity:0;}
  65%{opacity:1;}
  100%{transform:translate(175px,88px);opacity:1;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-12-red,.sutol-kent-12-green,.sutol-kent-12-walker{animation-duration:26s;}
}
</style>
```

---

## Bileşen 13: Bisiklet Yolunda İlerleyen Bisikletli

**Etiketler (keyword eşleşmesi için):** bisiklet yolu, park alanı, akıllı şehir, toplu taşıma
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Ayrılmış bir bisiklet şeridi üzerinde tekerlekleri dönerek ilerleyen bir bisikletli. (Teknik: SVG SMIL `animateMotion`)

```html
<div class="sutol-kent-13-bisiklet">
  <svg viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="85" width="200" height="20" fill="#7fd6a0" opacity="0.4"/>
    <line x1="0" y1="95" x2="200" y2="95" stroke="#ffffff" stroke-width="2" stroke-dasharray="8 6"/>
    <g class="sutol-kent-13-bike">
      <animateMotion dur="6s" repeatCount="indefinite" path="M-20,0 L220,0"/>
      <circle cx="-6" cy="10" r="8" fill="none" stroke="#3d3d48" stroke-width="2.5" class="sutol-kent-13-wheel"/>
      <circle cx="12" cy="10" r="8" fill="none" stroke="#3d3d48" stroke-width="2.5" class="sutol-kent-13-wheel"/>
      <path d="M-6,10 L2,-4 L12,10 M2,-4 L-2,-10 M2,-4 L6,-10" stroke="#5b8ad6" stroke-width="2.5" fill="none"/>
      <circle cx="2" cy="-14" r="4" fill="#e0a878"/>
    </g>
  </svg>
</div>
<style>
.sutol-kent-13-bisiklet{width:100%;height:100%;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-kent-13-bisiklet svg{width:100%;height:100%;transform:translateY(-5px);}
.sutol-kent-13-wheel{animation:sutolKent13Spin 0.6s linear infinite;transform-box:fill-box;transform-origin:center;}
@keyframes sutolKent13Spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-13-bike animateMotion{dur:26s;}
  .sutol-kent-13-wheel{animation-duration:6s;}
}
</style>
```

---

## Bileşen 14: Gökdelen İnşaatı

**Etiketler (keyword eşleşmesi için):** gökdelen, kentsel dönüşüm, altyapı ağı, akıllı şehir
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Bir inşaat vinci eşliğinde kat kat yükselerek tamamlanan bir gökdelen inşaatı. (Teknik: CSS `clip-path`/SVG `clipPath`)

```html
<div class="sutol-kent-14-insaat">
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="180" width="200" height="20" fill="#8a8a8a"/>
    <rect x="30" y="20" width="6" height="160" fill="#e0546f"/>
    <rect x="15" y="15" width="90" height="6" fill="#e0546f"/>
    <line class="sutol-kent-14-cable" x1="70" y1="21" x2="70" y2="60" stroke="#5f5f6a" stroke-width="2"/>
    <clipPath id="sutolKent14Clip">
      <rect x="60" y="0" width="80" height="180" class="sutol-kent-14-reveal"/>
    </clipPath>
    <g clip-path="url(#sutolKent14Clip)">
      <rect x="70" y="60" width="60" height="120" fill="#5a6a8a"/>
      <rect x="78" y="70" width="10" height="12" fill="#cfe0f5"/>
      <rect x="95" y="70" width="10" height="12" fill="#cfe0f5"/>
      <rect x="112" y="70" width="10" height="12" fill="#cfe0f5"/>
      <rect x="78" y="95" width="10" height="12" fill="#cfe0f5"/>
      <rect x="95" y="95" width="10" height="12" fill="#cfe0f5"/>
      <rect x="112" y="95" width="10" height="12" fill="#cfe0f5"/>
      <rect x="78" y="120" width="10" height="12" fill="#cfe0f5"/>
      <rect x="95" y="120" width="10" height="12" fill="#cfe0f5"/>
      <rect x="112" y="120" width="10" height="12" fill="#cfe0f5"/>
    </g>
  </svg>
</div>
<style>
.sutol-kent-14-insaat{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-kent-14-insaat svg{width:100%;height:100%;}
.sutol-kent-14-reveal{animation:sutolKent14Reveal 5s ease-in-out infinite;}
.sutol-kent-14-cable{animation:sutolKent14Cable 5s ease-in-out infinite;}
@keyframes sutolKent14Reveal{
  0%{y:180;height:0;}
  70%,100%{y:60;height:120;}
}
@keyframes sutolKent14Cable{
  0%{transform:translateY(0);}
  70%,100%{transform:translateY(40px);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-14-reveal,.sutol-kent-14-cable{animation-duration:22s;}
}
</style>
```

---
## Bileşen 15: Alacakaranlıkta Şehir Işıkları

**Etiketler (keyword eşleşmesi için):** gökdelen, aydınlatma direği, akıllı şehir, şehir meydanı
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Gökyüzü kararırken binaların pencerelerinin sırayla ışığa boğulduğu bir alacakaranlık şehir manzarası.

```html
<div class="sutol-kent-15-geceisik">
  <svg viewBox="0 0 200 140" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect class="sutol-kent-15-sky" x="0" y="0" width="200" height="140" fill="#8fb0d6"/>
    <rect x="15" y="60" width="30" height="80" fill="#2a2a35"/>
    <rect x="55" y="35" width="35" height="105" fill="#33334a"/>
    <rect x="100" y="55" width="25" height="85" fill="#2a2a35"/>
    <rect x="135" y="25" width="32" height="115" fill="#33334a"/>
    <g class="sutol-kent-15-windows" fill="#f5d76e">
      <rect x="20" y="70" width="5" height="6" class="sutol-kent-15-w sutol-kent-15-w1"/>
      <rect x="32" y="90" width="5" height="6" class="sutol-kent-15-w sutol-kent-15-w2"/>
      <rect x="63" y="50" width="5" height="6" class="sutol-kent-15-w sutol-kent-15-w3"/>
      <rect x="75" y="75" width="5" height="6" class="sutol-kent-15-w sutol-kent-15-w4"/>
      <rect x="106" y="65" width="5" height="6" class="sutol-kent-15-w sutol-kent-15-w5"/>
      <rect x="142" y="40" width="5" height="6" class="sutol-kent-15-w sutol-kent-15-w6"/>
      <rect x="155" y="60" width="5" height="6" class="sutol-kent-15-w sutol-kent-15-w7"/>
    </g>
  </svg>
</div>
<style>
.sutol-kent-15-geceisik{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-kent-15-geceisik svg{width:100%;height:100%;}
.sutol-kent-15-sky{animation:sutolKent15Sky 10s ease-in-out infinite;}
.sutol-kent-15-w{opacity:0;animation:sutolKent15Win 10s ease-in-out infinite;}
.sutol-kent-15-w2{animation-delay:0.3s;}
.sutol-kent-15-w3{animation-delay:0.6s;}
.sutol-kent-15-w4{animation-delay:0.9s;}
.sutol-kent-15-w5{animation-delay:1.2s;}
.sutol-kent-15-w6{animation-delay:1.5s;}
.sutol-kent-15-w7{animation-delay:1.8s;}
@keyframes sutolKent15Sky{0%,45%{fill:#8fb0d6;}70%,100%{fill:#1a2035;}}
@keyframes sutolKent15Win{0%,50%{opacity:0;}70%,100%{opacity:1;}}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-15-sky,.sutol-kent-15-w{animation-duration:40s;}
}
</style>
```

---

## Bileşen 16: Akıllı Ulaşım Ağı

**Etiketler (keyword eşleşmesi için):** toplu taşıma, akıllı şehir, altyapı ağı, metro istasyonu
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Otobüs, tramvay ve metro hatlarının aynı anda izlendiği canlı bir şehir içi ulaşım ağı haritası. (Teknik: Canvas + `requestAnimationFrame`)

```html
<div class="sutol-kent-16-ulasimagi">
  <canvas class="sutol-kent-16-canvas"></canvas>
</div>
<style>
.sutol-kent-16-ulasimagi{width:100%;height:100%;position:relative;}
.sutol-kent-16-canvas{width:100%;height:100%;display:block;}
</style>
<script>
(function(){
  var root = document.currentScript.previousElementSibling;
  var canvas = root.querySelector('.sutol-kent-16-canvas');
  var ctx = canvas.getContext('2d');
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function resize(){
    var rect = root.getBoundingClientRect();
    canvas.width = Math.max(rect.width,1) * (window.devicePixelRatio || 1);
    canvas.height = Math.max(rect.height,1) * (window.devicePixelRatio || 1);
  }
  resize();
  window.addEventListener('resize', resize);

  var lines = [
    {y:0.25, color:'#5b8ad6'},
    {y:0.5, color:'#5bd68a'},
    {y:0.75, color:'#e0a05b'}
  ];
  var t = 0;
  var speed = reduceMotion ? 0.0015 : 0.006;

  function draw(){
    var w = canvas.width, h = canvas.height;
    ctx.clearRect(0,0,w,h);

    lines.forEach(function(l,i){
      ctx.strokeStyle = 'rgba(150,150,160,0.3)';
      ctx.lineWidth = w*0.008;
      ctx.beginPath();
      ctx.moveTo(w*0.05,l.y*h);
      ctx.lineTo(w*0.95,l.y*h);
      ctx.stroke();

      for(var s=0;s<4;s++){
        ctx.fillStyle = '#8a8a94';
        ctx.beginPath();
        ctx.arc(w*(0.05 + s*0.3), l.y*h, w*0.012, 0, Math.PI*2);
        ctx.fill();
      }

      var frac = (t + i*0.3) % 1;
      var x = w*0.05 + frac*w*0.9;
      ctx.fillStyle = l.color;
      ctx.beginPath();
      ctx.arc(x, l.y*h, w*0.02, 0, Math.PI*2);
      ctx.fill();
    });

    t += speed;
    requestAnimationFrame(draw);
  }
  requestAnimationFrame(draw);
})();
</script>
```

---

## Bileşen 17: Bisiklet Paylaşım İstasyonu

**Etiketler (keyword eşleşmesi için):** bisiklet yolu, akıllı şehir, toplu taşıma, park alanı
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Bisikletlerin sırayla teslim alınıp yeniden bırakıldığı bir bisiklet paylaşım (bike-share) istasyonu.

```html
<div class="sutol-kent-17-bisikletistasyon">
  <svg viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="90" width="180" height="8" fill="#8a8a8a"/>
    <rect x="20" y="60" width="6" height="35" fill="#3d3d48"/>
    <rect x="60" y="60" width="6" height="35" fill="#3d3d48"/>
    <rect x="100" y="60" width="6" height="35" fill="#3d3d48"/>
    <rect x="140" y="60" width="6" height="35" fill="#3d3d48"/>
    <g class="sutol-kent-17-bike sutol-kent-17-b1" transform="translate(23,80)">
      <circle cx="-6" cy="0" r="7" fill="none" stroke="#5b8ad6" stroke-width="2"/>
      <circle cx="10" cy="0" r="7" fill="none" stroke="#5b8ad6" stroke-width="2"/>
      <path d="M-6,0 L2,-10 L10,0 M2,-10 L-1,-14" stroke="#5b8ad6" stroke-width="2" fill="none"/>
    </g>
    <g class="sutol-kent-17-bike sutol-kent-17-b2" transform="translate(103,80)">
      <circle cx="-6" cy="0" r="7" fill="none" stroke="#5bd68a" stroke-width="2"/>
      <circle cx="10" cy="0" r="7" fill="none" stroke="#5bd68a" stroke-width="2"/>
      <path d="M-6,0 L2,-10 L10,0 M2,-10 L-1,-14" stroke="#5bd68a" stroke-width="2" fill="none"/>
    </g>
  </svg>
</div>
<style>
.sutol-kent-17-bisikletistasyon{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-kent-17-bisikletistasyon svg{width:100%;height:100%;}
.sutol-kent-17-bike{animation:sutolKent17Cycle 7s ease-in-out infinite;transform-box:fill-box;}
.sutol-kent-17-b2{animation-delay:3.5s;}
@keyframes sutolKent17Cycle{
  0%,10%{opacity:1;transform:scale(1);}
  25%,75%{opacity:0;transform:scale(0.6);}
  90%,100%{opacity:1;transform:scale(1);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-17-bike{animation-duration:28s;}
}
</style>
```

---

## Bileşen 18: Yeşil Çatı ve Dikey Bahçe

**Etiketler (keyword eşleşmesi için):** kentsel dönüşüm, park alanı, gökdelen, akıllı şehir
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Bir bina cephesindeki dikey bahçenin yapraklarının sürekli tomurcuklanıp büyüdüğü sürdürülebilir bir kentsel yeşillendirme sahnesi.

```html
<div class="sutol-kent-18-yesilcati">
  <svg viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="20" y="10" width="100" height="150" fill="#c9c9d2" stroke="#9aa0aa" stroke-width="2"/>
    <g class="sutol-kent-18-leaf sutol-kent-18-l1"><circle cx="40" cy="40" r="10" fill="#5aa868"/></g>
    <g class="sutol-kent-18-leaf sutol-kent-18-l2"><circle cx="70" cy="55" r="9" fill="#6fbf7a"/></g>
    <g class="sutol-kent-18-leaf sutol-kent-18-l3"><circle cx="45" cy="80" r="11" fill="#4a9a5a"/></g>
    <g class="sutol-kent-18-leaf sutol-kent-18-l4"><circle cx="80" cy="95" r="9" fill="#5aa868"/></g>
    <g class="sutol-kent-18-leaf sutol-kent-18-l5"><circle cx="50" cy="120" r="10" fill="#6fbf7a"/></g>
    <g class="sutol-kent-18-leaf sutol-kent-18-l6"><circle cx="85" cy="135" r="9" fill="#4a9a5a"/></g>
  </svg>
</div>
<style>
.sutol-kent-18-yesilcati{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-kent-18-yesilcati svg{width:100%;height:100%;}
.sutol-kent-18-leaf{opacity:0;transform-box:fill-box;transform-origin:center;animation:sutolKent18Grow 6s ease-in-out infinite;}
.sutol-kent-18-l2{animation-delay:0.5s;}
.sutol-kent-18-l3{animation-delay:1s;}
.sutol-kent-18-l4{animation-delay:1.5s;}
.sutol-kent-18-l5{animation-delay:2s;}
.sutol-kent-18-l6{animation-delay:2.5s;}
@keyframes sutolKent18Grow{
  0%,10%{opacity:0;transform:scale(0);}
  40%,100%{opacity:1;transform:scale(1);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-18-leaf{animation-duration:26s;}
}
</style>
```

---
## Bileşen 19: Şehir Meydanında İnsan Akışı

**Etiketler (keyword eşleşmesi için):** şehir meydanı, toplu taşıma, park alanı, akıllı şehir
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Kalabalık bir şehir meydanının farklı köşelerinden merkeze doğru akan yaya trafiğini gösteren bir insan akışı şeması. (Teknik: Canvas + `requestAnimationFrame`)

```html
<div class="sutol-kent-19-insanakisi">
  <canvas class="sutol-kent-19-canvas"></canvas>
</div>
<style>
.sutol-kent-19-insanakisi{width:100%;height:100%;position:relative;}
.sutol-kent-19-canvas{width:100%;height:100%;display:block;}
</style>
<script>
(function(){
  var root = document.currentScript.previousElementSibling;
  var canvas = root.querySelector('.sutol-kent-19-canvas');
  var ctx = canvas.getContext('2d');
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function resize(){
    var rect = root.getBoundingClientRect();
    canvas.width = Math.max(rect.width,1) * (window.devicePixelRatio || 1);
    canvas.height = Math.max(rect.height,1) * (window.devicePixelRatio || 1);
  }
  resize();
  window.addEventListener('resize', resize);

  var corners = [{x:0.1,y:0.1},{x:0.9,y:0.1},{x:0.1,y:0.9},{x:0.9,y:0.9}];
  var center = {x:0.5,y:0.5};
  var people = [];
  for(var i=0;i<12;i++){
    people.push({corner: i%4, phase: Math.random(), off: (Math.random()-0.5)*0.15});
  }
  var t = 0;
  var speed = reduceMotion ? 0.0015 : 0.005;

  function draw(){
    var w = canvas.width, h = canvas.height;
    ctx.clearRect(0,0,w,h);

    ctx.fillStyle = 'rgba(180,180,190,0.5)';
    ctx.beginPath();
    ctx.arc(center.x*w, center.y*h, w*0.06, 0, Math.PI*2);
    ctx.fill();

    people.forEach(function(p){
      var c = corners[p.corner];
      var frac = (t + p.phase) % 1;
      var x = c.x + (center.x - c.x)*frac + p.off*(1-frac);
      var y = c.y + (center.y - c.y)*frac + p.off*(1-frac);
      ctx.fillStyle = '#5b8ad6';
      ctx.beginPath();
      ctx.arc(x*w, y*h, w*0.011, 0, Math.PI*2);
      ctx.fill();
    });

    t += speed;
    requestAnimationFrame(draw);
  }
  requestAnimationFrame(draw);
})();
</script>
```

---

## Bileşen 20: Şehir Sensör Ağı

**Etiketler (keyword eşleşmesi için):** akıllı şehir, altyapı ağı, aydınlatma direği, yaya geçidi
**Kategori:** Şehir Yaşamı & Kentsel Altyapı
**Açıklama:** Sokak lambaları, trafik ışıkları ve yaya geçitlerine yerleştirilmiş sensörlerin merkezi bir kontrol noktasına veri gönderdiği bir akıllı şehir sensör ağı.

```html
<div class="sutol-kent-20-sensorveri">
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <g stroke="#8fa8d6" stroke-width="1.5" opacity="0.5">
      <line x1="100" y1="100" x2="40" y2="50"/>
      <line x1="100" y1="100" x2="160" y2="50"/>
      <line x1="100" y1="100" x2="40" y2="150"/>
      <line x1="100" y1="100" x2="160" y2="150"/>
    </g>
    <rect x="88" y="88" width="24" height="24" rx="4" fill="#3d4d68"/>
    <g class="sutol-kent-20-sensor sutol-kent-20-s1" transform="translate(40,50)">
      <circle r="8" fill="#e0546f"/>
      <circle r="8" fill="none" stroke="#e0546f" stroke-width="2" class="sutol-kent-20-wave"/>
    </g>
    <g class="sutol-kent-20-sensor sutol-kent-20-s2" transform="translate(160,50)">
      <circle r="8" fill="#5bd68a"/>
      <circle r="8" fill="none" stroke="#5bd68a" stroke-width="2" class="sutol-kent-20-wave"/>
    </g>
    <g class="sutol-kent-20-sensor sutol-kent-20-s3" transform="translate(40,150)">
      <circle r="8" fill="#e0a05b"/>
      <circle r="8" fill="none" stroke="#e0a05b" stroke-width="2" class="sutol-kent-20-wave"/>
    </g>
    <g class="sutol-kent-20-sensor sutol-kent-20-s4" transform="translate(160,150)">
      <circle r="8" fill="#5b8ad6"/>
      <circle r="8" fill="none" stroke="#5b8ad6" stroke-width="2" class="sutol-kent-20-wave"/>
    </g>
  </svg>
</div>
<style>
.sutol-kent-20-sensorveri{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-kent-20-sensorveri svg{width:100%;height:100%;}
.sutol-kent-20-wave{transform-box:fill-box;transform-origin:center;animation:sutolKent20Wave 4s ease-out infinite;}
.sutol-kent-20-s2 .sutol-kent-20-wave{animation-delay:1s;}
.sutol-kent-20-s3 .sutol-kent-20-wave{animation-delay:2s;}
.sutol-kent-20-s4 .sutol-kent-20-wave{animation-delay:3s;}
@keyframes sutolKent20Wave{0%{transform:scale(1);opacity:0.8;}100%{transform:scale(2.6);opacity:0;}}
@media (prefers-reduced-motion: reduce){
  .sutol-kent-20-wave{animation-duration:20s;}
}
</style>
```

---

## Kalite Kontrol Özeti

1. **Gökdelen Silueti** — CSS keyframes (pencere `opacity` yanıp sönmesi, kademeli gecikmeler).
2. **Metro İstasyonuna Giren Tren** — SVG SMIL `animateMotion` (`keyPoints`/`keyTimes` ile yavaşlayıp duran tren).
3. **Kentsel Dönüşüm** — CSS keyframes `scaleY`/`opacity` çapraz geçiş (eski bina → yeni gökdelen).
4. **Park Alanında Yürüyüş** — CSS keyframes ağaç `rotate` sallanması + yürüyüş figürü `translateX`.
5. **Şehir Köprüsü** — CSS keyframes kablo `scaleY` titreşimi + araç `translateX` geçişi.
6. **Sokak Aydınlatma Direği** — CSS keyframes ışık halesi `scale`/`opacity` parıltısı.
7. **Akıllı Şehir Veri Ağı** — Canvas + `requestAnimationFrame`, bina-arası hareketli sinyal noktaları.
8. **Toplu Taşıma Durağı** — CSS keyframes otobüs `translateX` + kapı `scaleX` + yolcu `opacity`/`translate`.
9. **Şehir Meydanı Çeşmesi** — CSS keyframes `stroke-dasharray`/`opacity` fışkırma döngüsü.
10. **Yeraltı Altyapı Ağı** — `stroke-dasharray` yol çizimi + CSS `offset-path` sinyal akışı.
11. **Kanalizasyon Sistemi** — CSS `offset-path` (iki bağımsız su parçacığı akışı).
12. **Yaya Geçidi** — CSS keyframes ışık `opacity` döngüsü + yaya `translateX` geçişi.
13. **Bisiklet Yolunda İlerleyen Bisikletli** — SVG SMIL `animateMotion` + CSS tekerlek `rotate` dönüşü.
14. **Gökdelen İnşaatı** — SVG `clipPath` rect yüksekliği animasyonu + vinç kablosu `translateY`.
15. **Alacakaranlıkta Şehir Işıkları** — CSS keyframes gökyüzü `fill` rengi geçişi + pencere `opacity` sıralı yanması.
16. **Akıllı Ulaşım Ağı** — Canvas + `requestAnimationFrame`, üç hat üzerinde bağımsız hareketli araçlar.
17. **Bisiklet Paylaşım İstasyonu** — CSS keyframes `opacity`/`scale` ile bisikletlerin görünüp kaybolması.
18. **Yeşil Çatı ve Dikey Bahçe** — CSS keyframes kademeli `scale`/`opacity` büyüme döngüsü.
19. **Şehir Meydanında İnsan Akışı** — Canvas + `requestAnimationFrame`, dört köşeden merkeze akan parçacıklar.
20. **Şehir Sensör Ağı** — CSS keyframes çoklu dalga (`scale`/`opacity`), kademeli gecikmeler.

**Genel performans notu:** Tüm bileşenler `transform`, `opacity`, `fill` ve `stroke-dash*` gibi GPU dostu/hafif özellikleri kullanır; `setInterval` kullanılmamıştır. Canvas tabanlı bileşenler (7, 16, 19) `devicePixelRatio` ile ölçeklenir ve `resize` olayına duyarlıdır. Tüm bileşenlerde `prefers-reduced-motion: reduce` sorgusu animasyon sürelerini belirgin biçimde uzatarak hareketi en aza indirir. Hiçbir bileşen dış kaynak, sabit metin veya global CSS seçici içermez; tüm sınıflar `sutol-kent-NN-...` öneki ile kapsüllenmiştir.
