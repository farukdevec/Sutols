## Bileşen 21: Kalem Ucu Yazı Çizgisi

**Etiketler (keyword eşleşmesi için):** kalem, yazma, öğrenme, ders
**Kategori:** Eğitim
**Açıklama:** Bir kalem ucunun kıvrımlı bir çizgi üzerinde ilerleyerek arkasında el yazısı gibi bir iz bıraktığı animasyon.

```html
<div class="sutol-edu21-wrap">
  <style>
    .sutol-edu21-wrap{width:100%;height:100%;background:transparent;position:relative;}
    .sutol-edu21-svg{width:100%;height:100%;display:block;}
    .sutol-edu21-line{fill:none;stroke:#3a6df0;stroke-width:2.5;stroke-linecap:round;stroke-dasharray:220;stroke-dashoffset:220;animation:sutol-edu21-draw 4s ease-in-out infinite;}
    .sutol-edu21-tip{fill:#f0973a;animation:sutol-edu21-move 4s ease-in-out infinite;}
    @keyframes sutol-edu21-draw{0%{stroke-dashoffset:220;}70%{stroke-dashoffset:0;}100%{stroke-dashoffset:0;}}
    @keyframes sutol-edu21-move{
      0%{transform:translate(8px,45px);}
      20%{transform:translate(20px,10px);}
      40%{transform:translate(35px,50px);}
      55%{transform:translate(50px,25px);}
      70%{transform:translate(62px,5px);}
      85%{transform:translate(75px,40px);}
      100%{transform:translate(92px,15px);}
    }
    @media (prefers-reduced-motion: reduce){
      .sutol-edu21-line{animation-duration:14s;}
      .sutol-edu21-tip{animation-duration:14s;}
    }
  </style>
  <svg class="sutol-edu21-svg" viewBox="0 0 100 60" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-edu21-line" d="M8,45 C20,10 35,50 50,25 C62,5 75,40 92,15"/>
    <circle class="sutol-edu21-tip" r="3"/>
  </svg>
</div>
```

---

## Bileşen 22: Kara Tahta Tebeşir İzi

**Etiketler (keyword eşleşmesi için):** öğretmen, tahta, ders, sınıf
**Kategori:** Eğitim
**Açıklama:** Koyu yeşil bir tahta üzerinde tebeşirle çizilen kıvrımlı bir çizginin belirip silinmesi.

```html
<div class="sutol-edu22-wrap">
  <style>
    .sutol-edu22-wrap{width:100%;height:100%;background:transparent;}
    .sutol-edu22-svg{width:100%;height:100%;display:block;}
    .sutol-edu22-board{fill:#1f4d3d;stroke:#8a5a2b;stroke-width:2;}
    .sutol-edu22-chalk{fill:none;stroke:#f5f5f0;stroke-width:2;stroke-linecap:round;stroke-dasharray:180;stroke-dashoffset:180;animation:sutol-edu22-write 5s linear infinite;}
    @keyframes sutol-edu22-write{
      0%{stroke-dashoffset:180;opacity:1;}
      60%{stroke-dashoffset:0;opacity:1;}
      85%{opacity:1;}
      100%{stroke-dashoffset:0;opacity:0;}
    }
    @media (prefers-reduced-motion: reduce){.sutol-edu22-chalk{animation-duration:15s;}}
  </style>
  <svg class="sutol-edu22-svg" viewBox="0 0 100 60" preserveAspectRatio="xMidYMid meet">
    <rect class="sutol-edu22-board" x="4" y="4" width="92" height="52" rx="3"/>
    <path class="sutol-edu22-chalk" d="M15,40 Q30,15 45,35 Q60,50 75,20 Q82,10 88,25"/>
  </svg>
</div>
```

---

## Bileşen 23: Sınıf Sırası Tarama Işığı

**Etiketler (keyword eşleşmesi için):** sınıf, öğrenci, ders, dikkat
**Kategori:** Eğitim
**Açıklama:** Bir sınıf düzenindeki sıraların üzerinden soldan sağa kayan yumuşak bir dikkat ışığı huzmesi.

```html
<div class="sutol-edu23-wrap">
  <style>
    .sutol-edu23-wrap{width:100%;height:100%;background:transparent;position:relative;overflow:hidden;}
    .sutol-edu23-grid{position:absolute;inset:10%;display:grid;grid-template-columns:repeat(3,1fr);grid-template-rows:repeat(2,1fr);gap:8%;}
    .sutol-edu23-desk{background:#5b6b8c;border-radius:12%;}
    .sutol-edu23-scan{position:absolute;top:0;bottom:0;width:18%;background:linear-gradient(90deg,transparent,rgba(255,214,90,0.55),transparent);animation:sutol-edu23-sweep 3.2s ease-in-out infinite;}
    @keyframes sutol-edu23-sweep{0%{left:-20%;}100%{left:100%;}}
    @media (prefers-reduced-motion: reduce){.sutol-edu23-scan{animation-duration:10s;}}
  </style>
  <div class="sutol-edu23-grid">
    <div class="sutol-edu23-desk"></div><div class="sutol-edu23-desk"></div><div class="sutol-edu23-desk"></div>
    <div class="sutol-edu23-desk"></div><div class="sutol-edu23-desk"></div><div class="sutol-edu23-desk"></div>
  </div>
  <div class="sutol-edu23-scan"></div>
</div>
```

---

## Bileşen 24: Uçan Mezuniyet Kurdelesi

**Etiketler (keyword eşleşmesi için):** mezuniyet, başarı, kariyer, kutlama
**Kategori:** Eğitim
**Açıklama:** Renkli bir kurdelenin kavisli bir yörünge boyunca süzülerek uçtan uca ilerlemesi.

```html
<div class="sutol-edu24-wrap">
  <style>
    .sutol-edu24-wrap{width:100%;height:100%;background:transparent;position:relative;}
    .sutol-edu24-track{width:100%;height:100%;display:block;position:absolute;inset:0;}
    .sutol-edu24-path{fill:none;stroke:none;}
    .sutol-edu24-ribbon{position:absolute;width:14%;height:6%;background:linear-gradient(90deg,#d63384,#f0973a);border-radius:2px;offset-path:path("M10,80 C30,20 70,20 90,80");offset-rotate:auto;animation:sutol-edu24-fly 4s linear infinite;}
    @keyframes sutol-edu24-fly{0%{offset-distance:0%;opacity:0;}10%{opacity:1;}90%{opacity:1;}100%{offset-distance:100%;opacity:0;}}
    @media (prefers-reduced-motion: reduce){.sutol-edu24-ribbon{animation-duration:12s;}}
  </style>
  <svg class="sutol-edu24-track" viewBox="0 0 100 100">
    <path class="sutol-edu24-path" d="M10,80 C30,20 70,20 90,80"/>
  </svg>
  <div class="sutol-edu24-ribbon"></div>
</div>
```

---

## Bileşen 25: Beyin Fırtınası Kabarcıkları

**Etiketler (keyword eşleşmesi için):** beyin fırtınası, fikir, yaratıcılık, grup çalışması
**Kategori:** Eğitim
**Açıklama:** Farklı boyutlarda parlak fikir kabarcıklarının aşağıdan yukarıya doğru süzülerek yükselmesi.

```html
<div class="sutol-edu25-wrap">
  <style>
    .sutol-edu25-wrap{width:100%;height:100%;background:transparent;position:relative;overflow:hidden;}
    .sutol-edu25-bubble{position:absolute;bottom:-10%;width:16%;height:16%;border-radius:50%;background:radial-gradient(circle at 30% 30%,#ffd65a,#f0973a);opacity:0;animation:sutol-edu25-rise 4.5s ease-in infinite;}
    .sutol-edu25-bubble.b1{left:8%;animation-delay:0s;}
    .sutol-edu25-bubble.b2{left:28%;animation-delay:0.7s;width:12%;height:12%;}
    .sutol-edu25-bubble.b3{left:48%;animation-delay:1.4s;width:20%;height:20%;}
    .sutol-edu25-bubble.b4{left:68%;animation-delay:2.1s;width:10%;height:10%;}
    .sutol-edu25-bubble.b5{left:85%;animation-delay:2.8s;width:14%;height:14%;}
    @keyframes sutol-edu25-rise{
      0%{transform:translateY(0) scale(0.6);opacity:0;}
      15%{opacity:0.9;}
      90%{opacity:0.4;}
      100%{transform:translateY(-120%) scale(1.1);opacity:0;}
    }
    @media (prefers-reduced-motion: reduce){.sutol-edu25-bubble{animation-duration:14s;}}
  </style>
  <div class="sutol-edu25-bubble b1"></div>
  <div class="sutol-edu25-bubble b2"></div>
  <div class="sutol-edu25-bubble b3"></div>
  <div class="sutol-edu25-bubble b4"></div>
  <div class="sutol-edu25-bubble b5"></div>
</div>
```

---

## Bileşen 26: Öğrenme Eğrisi Çizgisi

**Etiketler (keyword eşleşmesi için):** öğrenme, gelişim, beceri, ilerleme
**Kategori:** Eğitim
**Açıklama:** Bir eksen üzerinde yükselen öğrenme eğrisinin çizilmesi ve üzerinde ilerleyen küçük bir noktanın gösterimi.

```html
<div class="sutol-edu26-wrap">
  <style>
    .sutol-edu26-wrap{width:100%;height:100%;background:transparent;}
    .sutol-edu26-svg{width:100%;height:100%;display:block;}
    .sutol-edu26-axis{fill:none;stroke:#9aa5b1;stroke-width:1.2;}
    .sutol-edu26-curve{fill:none;stroke:#2fa365;stroke-width:2.4;stroke-linecap:round;stroke-dasharray:130;stroke-dashoffset:130;animation:sutol-edu26-draw 4s ease-in-out infinite;}
    .sutol-edu26-dot{fill:#2fa365;animation:sutol-edu26-dotmove 4s ease-in-out infinite;}
    @keyframes sutol-edu26-draw{0%{stroke-dashoffset:130;}70%{stroke-dashoffset:0;}100%{stroke-dashoffset:0;}}
    @keyframes sutol-edu26-dotmove{
      0%{transform:translate(8px,50px);}
      25%{transform:translate(30px,45px);}
      50%{transform:translate(45px,25px);}
      75%{transform:translate(65px,10px);}
      100%{transform:translate(92px,8px);}
    }
    @media (prefers-reduced-motion: reduce){
      .sutol-edu26-curve{animation-duration:14s;}
      .sutol-edu26-dot{animation-duration:14s;}
    }
  </style>
  <svg class="sutol-edu26-svg" viewBox="0 0 100 60" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-edu26-axis" d="M8,52 L8,6 M8,52 L94,52"/>
    <path class="sutol-edu26-curve" d="M8,50 C20,48 30,45 40,32 C52,16 65,10 92,8"/>
    <circle class="sutol-edu26-dot" r="2.6"/>
  </svg>
</div>
```

---

## Bileşen 27: Öğrenci Halkası Dönüşü

**Etiketler (keyword eşleşmesi için):** öğrenci, grup çalışması, işbirliği, topluluk
**Kategori:** Eğitim
**Açıklama:** Merkezdeki bir noktanın etrafında dairesel biçimde dizilmiş öğrenci temsili noktaların yavaşça dönmesi.

```html
<div class="sutol-edu27-wrap">
  <style>
    .sutol-edu27-wrap{width:100%;height:100%;background:transparent;}
    .sutol-edu27-svg{width:100%;height:100%;display:block;}
    .sutol-edu27-ring{transform-origin:50px 50px;animation:sutol-edu27-spin 8s linear infinite;}
    .sutol-edu27-node{fill:#3a6df0;}
    .sutol-edu27-center{fill:#f0973a;}
    @keyframes sutol-edu27-spin{to{transform:rotate(360deg);}}
    @media (prefers-reduced-motion: reduce){.sutol-edu27-ring{animation-duration:32s;}}
  </style>
  <svg class="sutol-edu27-svg" viewBox="0 0 100 100">
    <g class="sutol-edu27-ring">
      <circle class="sutol-edu27-node" cx="50" cy="10" r="6"/>
      <circle class="sutol-edu27-node" cx="85" cy="35" r="6"/>
      <circle class="sutol-edu27-node" cx="72" cy="80" r="6"/>
      <circle class="sutol-edu27-node" cx="28" cy="80" r="6"/>
      <circle class="sutol-edu27-node" cx="15" cy="35" r="6"/>
    </g>
    <circle class="sutol-edu27-center" cx="50" cy="50" r="8"/>
  </svg>
</div>
```

---

## Bileşen 28: Akan Veri Ekranı

**Etiketler (keyword eşleşmesi için):** dijital eğitim, uzaktan eğitim, teknoloji, veri
**Kategori:** Eğitim
**Açıklama:** Dijital bir ekranda yukarıdan aşağıya akan soyut veri çubuklarının canvas üzerinde sürekli hareketi.

```html
<div class="sutol-edu28-wrap">
  <style>
    .sutol-edu28-wrap{width:100%;height:100%;background:transparent;position:relative;--sutol-edu28-speed:1;}
    .sutol-edu28-canvas{width:100%;height:100%;display:block;}
    @media (prefers-reduced-motion: reduce){
      .sutol-edu28-wrap{--sutol-edu28-speed:0.25;}
    }
  </style>
  <canvas class="sutol-edu28-canvas"></canvas>
  <script>
    (function(){
      var wrap = document.currentScript.parentElement;
      var canvas = wrap.querySelector('.sutol-edu28-canvas');
      var ctx = canvas.getContext('2d');
      var cols = [];
      function speed(){
        var v = parseFloat(getComputedStyle(wrap).getPropertyValue('--sutol-edu28-speed'));
        return isNaN(v) ? 1 : v;
      }
      function resize(){
        var r = wrap.getBoundingClientRect();
        canvas.width = r.width; canvas.height = r.height;
        var count = Math.max(6, Math.floor(canvas.width/24));
        cols = [];
        for(var i=0;i<count;i++){
          cols.push({x:(i+0.5)*canvas.width/count, y:Math.random()*canvas.height, base:0.6+Math.random()*0.8});
        }
      }
      resize();
      window.addEventListener('resize', resize);
      function draw(){
        var s = speed();
        ctx.clearRect(0,0,canvas.width,canvas.height);
        ctx.fillStyle = '#4fd1c5';
        for(var i=0;i<cols.length;i++){
          var c = cols[i];
          c.y += c.base * s;
          if(c.y > canvas.height+20) c.y = -20;
          ctx.globalAlpha = 0.85;
          ctx.fillRect(c.x-1.5, c.y-8, 3, 16);
        }
        requestAnimationFrame(draw);
      }
      requestAnimationFrame(draw);
    })();
  </script>
</div>
```

---

## Bileşen 29: Rehberlik Pusulası

**Etiketler (keyword eşleşmesi için):** rehberlik, danışmanlık, kariyer, yön
**Kategori:** Eğitim
**Açıklama:** Bir pusula ibresinin sağa sola sallanarak yön arayışını simgeleyen sürekli salınımı.

```html
<div class="sutol-edu29-wrap">
  <style>
    .sutol-edu29-wrap{width:100%;height:100%;background:transparent;}
    .sutol-edu29-svg{width:100%;height:100%;display:block;}
    .sutol-edu29-ring{fill:none;stroke:#8a5a2b;stroke-width:3;}
    .sutol-edu29-needle polygon{fill:#d63384;}
    .sutol-edu29-needle{transform-origin:50px 50px;animation:sutol-edu29-swing 5s ease-in-out infinite;}
    .sutol-edu29-hub{fill:#2b2b2b;}
    @keyframes sutol-edu29-swing{
      0%{transform:rotate(-25deg);}
      50%{transform:rotate(35deg);}
      100%{transform:rotate(-25deg);}
    }
    @media (prefers-reduced-motion: reduce){.sutol-edu29-needle{animation-duration:16s;}}
  </style>
  <svg class="sutol-edu29-svg" viewBox="0 0 100 100">
    <circle class="sutol-edu29-ring" cx="50" cy="50" r="42"/>
    <g class="sutol-edu29-needle">
      <polygon points="50,14 56,50 50,86 44,50"/>
    </g>
    <circle class="sutol-edu29-hub" cx="50" cy="50" r="4"/>
  </svg>
</div>
```

---

## Bileşen 30: Araştırma Büyüteci Taraması

**Etiketler (keyword eşleşmesi için):** araştırma, akademik, inceleme, bilim insanı
**Kategori:** Eğitim
**Açıklama:** Bir büyütecin satır satır düzenlenmiş belge çizgileri üzerinde köşeden köşeye gezinerek tarama yapması.

```html
<div class="sutol-edu30-wrap">
  <style>
    .sutol-edu30-wrap{width:100%;height:100%;background:transparent;}
    .sutol-edu30-svg{width:100%;height:100%;display:block;}
    .sutol-edu30-doc rect{fill:#9aa5b1;}
    .sutol-edu30-lens circle{fill:rgba(58,109,240,0.15);stroke:#3a6df0;stroke-width:3;}
    .sutol-edu30-lens line{stroke:#3a6df0;stroke-width:4;stroke-linecap:round;}
    .sutol-edu30-lens{animation:sutol-edu30-scan 4.5s ease-in-out infinite;}
    @keyframes sutol-edu30-scan{
      0%{transform:translate(25px,25px);}
      25%{transform:translate(70px,25px);}
      50%{transform:translate(70px,70px);}
      75%{transform:translate(25px,70px);}
      100%{transform:translate(25px,25px);}
    }
    @media (prefers-reduced-motion: reduce){.sutol-edu30-lens{animation-duration:16s;}}
  </style>
  <svg class="sutol-edu30-svg" viewBox="0 0 100 100">
    <g class="sutol-edu30-doc">
      <rect x="10" y="15" width="80" height="6" rx="2"/>
      <rect x="10" y="30" width="60" height="6" rx="2"/>
      <rect x="10" y="45" width="70" height="6" rx="2"/>
      <rect x="10" y="60" width="50" height="6" rx="2"/>
      <rect x="10" y="75" width="65" height="6" rx="2"/>
    </g>
    <g class="sutol-edu30-lens">
      <circle cx="0" cy="0" r="14"/>
      <line x1="10" y1="10" x2="20" y2="20"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 31: Beceri Rozetleri Sırası

**Etiketler (keyword eşleşmesi için):** beceri, yetenek, başarı, rozet
**Kategori:** Eğitim
**Açıklama:** Sıralı biçimde art arda büyüyüp beliren dört parlak beceri rozetinin oluşum animasyonu.

```html
<div class="sutol-edu31-wrap">
  <style>
    .sutol-edu31-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:space-evenly;}
    .sutol-edu31-badge{width:18%;height:36%;border-radius:50%;background:radial-gradient(circle at 35% 30%,#ffe08a,#e0a52c);opacity:0;transform:scale(0.4);animation:sutol-edu31-pop 3.6s ease-in-out infinite;}
    .sutol-edu31-badge:nth-child(1){animation-delay:0s;}
    .sutol-edu31-badge:nth-child(2){animation-delay:0.4s;}
    .sutol-edu31-badge:nth-child(3){animation-delay:0.8s;}
    .sutol-edu31-badge:nth-child(4){animation-delay:1.2s;}
    @keyframes sutol-edu31-pop{
      0%{opacity:0;transform:scale(0.4);}
      15%{opacity:1;transform:scale(1.1);}
      25%{transform:scale(1);}
      80%{opacity:1;transform:scale(1);}
      100%{opacity:0.15;transform:scale(0.9);}
    }
    @media (prefers-reduced-motion: reduce){.sutol-edu31-badge{animation-duration:12s;}}
  </style>
  <div class="sutol-edu31-badge"></div>
  <div class="sutol-edu31-badge"></div>
  <div class="sutol-edu31-badge"></div>
  <div class="sutol-edu31-badge"></div>
</div>
```

---

## Bileşen 32: Kariyer Yol Haritası

**Etiketler (keyword eşleşmesi için):** kariyer, hedef, yol haritası, gelişim
**Kategori:** Eğitim
**Açıklama:** Kesikli bir yol çizgisi üzerinde duraklardan geçerek ilerleyen küçük bir noktanın kariyer yolculuğunu temsil etmesi.

```html
<div class="sutol-edu32-wrap">
  <style>
    .sutol-edu32-wrap{width:100%;height:100%;background:transparent;position:relative;}
    .sutol-edu32-svg{width:100%;height:100%;display:block;position:absolute;inset:0;}
    .sutol-edu32-road{fill:none;stroke:#9aa5b1;stroke-width:2;stroke-dasharray:4 3;}
    .sutol-edu32-stop{fill:#2fa365;}
    .sutol-edu32-runner{position:absolute;width:5%;height:8%;border-radius:50%;background:#f0973a;offset-path:path("M5,50 C20,50 20,20 35,20 C50,20 50,45 65,45 C80,45 80,15 95,15");offset-rotate:0deg;animation:sutol-edu32-run 5s linear infinite;}
    @keyframes sutol-edu32-run{0%{offset-distance:0%;}100%{offset-distance:100%;}}
    @media (prefers-reduced-motion: reduce){.sutol-edu32-runner{animation-duration:18s;}}
  </style>
  <svg class="sutol-edu32-svg" viewBox="0 0 100 60">
    <path class="sutol-edu32-road" d="M5,50 C20,50 20,20 35,20 C50,20 50,45 65,45 C80,45 80,15 95,15"/>
    <circle class="sutol-edu32-stop" cx="5" cy="50" r="3"/>
    <circle class="sutol-edu32-stop" cx="35" cy="20" r="3"/>
    <circle class="sutol-edu32-stop" cx="65" cy="45" r="3"/>
    <circle class="sutol-edu32-stop" cx="95" cy="15" r="3"/>
  </svg>
  <div class="sutol-edu32-runner"></div>
</div>
```

---

## Bileşen 33: Değerlendirme Onay Çizimi

**Etiketler (keyword eşleşmesi için):** değerlendirme, sınav, not, başarı
**Kategori:** Eğitim
**Açıklama:** Bir dairenin çizilmesinin ardından içinde bir onay işaretinin çizilerek tamamlanan değerlendirme animasyonu.

```html
<div class="sutol-edu33-wrap">
  <style>
    .sutol-edu33-wrap{width:100%;height:100%;background:transparent;}
    .sutol-edu33-svg{width:100%;height:100%;display:block;}
    .sutol-edu33-circle{fill:none;stroke:#2fa365;stroke-width:5;stroke-dasharray:260;stroke-dashoffset:260;animation:sutol-edu33-ring 4s ease-in-out infinite;}
    .sutol-edu33-check{fill:none;stroke:#2fa365;stroke-width:6;stroke-linecap:round;stroke-linejoin:round;stroke-dasharray:70;stroke-dashoffset:70;animation:sutol-edu33-tick 4s ease-in-out infinite;}
    @keyframes sutol-edu33-ring{0%{stroke-dashoffset:260;}55%{stroke-dashoffset:0;}100%{stroke-dashoffset:0;}}
    @keyframes sutol-edu33-tick{0%{stroke-dashoffset:70;}55%{stroke-dashoffset:70;}90%{stroke-dashoffset:0;}100%{stroke-dashoffset:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-edu33-circle{animation-duration:14s;}
      .sutol-edu33-check{animation-duration:14s;}
    }
  </style>
  <svg class="sutol-edu33-svg" viewBox="0 0 100 100">
    <circle class="sutol-edu33-circle" cx="50" cy="50" r="40"/>
    <path class="sutol-edu33-check" d="M30,52 L45,68 L72,34"/>
  </svg>
</div>
```

---

## Bileşen 34: Video Ders İlerleme Çubuğu

**Etiketler (keyword eşleşmesi için):** uzaktan eğitim, dijital eğitim, ders, video
**Kategori:** Eğitim
**Açıklama:** Nabız gibi büyüyüp küçülen bir oynat simgesi ve altında sürekli dolup boşalan bir video ilerleme çubuğu.

```html
<div class="sutol-edu34-wrap">
  <style>
    .sutol-edu34-wrap{width:100%;height:100%;background:transparent;display:flex;flex-direction:column;justify-content:center;align-items:center;gap:6%;}
    .sutol-edu34-screen{width:70%;height:60%;border-radius:6%;background:#1d2733;display:flex;align-items:center;justify-content:center;}
    .sutol-edu34-playicon{width:30%;height:30%;animation:sutol-edu34-pulse 2.4s ease-in-out infinite;}
    .sutol-edu34-playicon polygon{fill:#4fd1c5;}
    .sutol-edu34-progress{width:70%;height:6%;background:#2b3646;border-radius:10px;overflow:hidden;}
    .sutol-edu34-fill{height:100%;width:0%;background:#4fd1c5;animation:sutol-edu34-load 4s linear infinite;}
    @keyframes sutol-edu34-pulse{0%,100%{transform:scale(1);opacity:0.85;}50%{transform:scale(1.15);opacity:1;}}
    @keyframes sutol-edu34-load{0%{width:0%;}100%{width:100%;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-edu34-playicon{animation-duration:8s;}
      .sutol-edu34-fill{animation-duration:14s;}
    }
  </style>
  <div class="sutol-edu34-screen">
    <svg class="sutol-edu34-playicon" viewBox="0 0 100 100">
      <polygon points="35,25 35,75 75,50"/>
    </svg>
  </div>
  <div class="sutol-edu34-progress"><div class="sutol-edu34-fill"></div></div>
</div>
```

---

## Bileşen 35: Kalem Kutusu Açılışı

**Etiketler (keyword eşleşmesi için):** okul, malzeme, ders, hazırlık
**Kategori:** Eğitim
**Açıklama:** Bir kalem kutusunun kapağının üç boyutlu olarak açılıp içinden renkli kalemlerin yükselmesi.

```html
<div class="sutol-edu35-wrap">
  <style>
    .sutol-edu35-wrap{width:100%;height:100%;background:transparent;perspective:600px;display:flex;align-items:center;justify-content:center;}
    .sutol-edu35-scene{position:relative;width:70%;height:50%;}
    .sutol-edu35-box{position:absolute;inset:0;background:#8a5a2b;border-radius:4%;}
    .sutol-edu35-lid{position:absolute;top:0;left:0;right:0;height:40%;background:#b07a3e;border-radius:4% 4% 0 0;transform-origin:top;animation:sutol-edu35-open 4s ease-in-out infinite;}
    .sutol-edu35-pencil{position:absolute;bottom:10%;width:8%;height:60%;border-radius:20% 20% 0 0;animation:sutol-edu35-slide 4s ease-in-out infinite;}
    .sutol-edu35-pencil.p1{left:25%;background:#f0973a;animation-delay:0.1s;}
    .sutol-edu35-pencil.p2{left:46%;background:#3a6df0;animation-delay:0.25s;}
    .sutol-edu35-pencil.p3{left:67%;background:#2fa365;animation-delay:0.4s;}
    @keyframes sutol-edu35-open{0%{transform:rotateX(0deg);}30%{transform:rotateX(-110deg);}80%{transform:rotateX(-110deg);}100%{transform:rotateX(0deg);}}
    @keyframes sutol-edu35-slide{
      0%,20%{transform:translateY(0);opacity:0.9;}
      45%{transform:translateY(-40%);opacity:1;}
      75%{transform:translateY(-40%);opacity:1;}
      100%{transform:translateY(0);opacity:0.9;}
    }
    @media (prefers-reduced-motion: reduce){
      .sutol-edu35-lid{animation-duration:14s;}
      .sutol-edu35-pencil{animation-duration:14s;}
    }
  </style>
  <div class="sutol-edu35-scene">
    <div class="sutol-edu35-box"></div>
    <div class="sutol-edu35-lid"></div>
    <div class="sutol-edu35-pencil p1"></div>
    <div class="sutol-edu35-pencil p2"></div>
    <div class="sutol-edu35-pencil p3"></div>
  </div>
</div>
```

---

## Bileşen 36: Ders Takvimi Sayfa Çevirme

**Etiketler (keyword eşleşmesi için):** müfredat, ders programı, planlama, sınıf
**Kategori:** Eğitim
**Açıklama:** Bir takvim yaprağının üç boyutlu olarak öne doğru dönerek altındaki gün ızgarasını ortaya çıkarması.

```html
<div class="sutol-edu36-wrap">
  <style>
    .sutol-edu36-wrap{width:100%;height:100%;background:transparent;perspective:500px;display:flex;align-items:center;justify-content:center;}
    .sutol-edu36-calendar{position:relative;width:65%;height:65%;}
    .sutol-edu36-grid{position:absolute;inset:15% 8% 8% 8%;display:grid;grid-template-columns:repeat(4,1fr);gap:8%;}
    .sutol-edu36-grid span{background:#c9d3e0;border-radius:15%;}
    .sutol-edu36-grid span:nth-child(5){background:#f0973a;}
    .sutol-edu36-page{position:absolute;top:0;left:0;width:100%;height:100%;background:#e8583a;border-radius:6%;transform-origin:top;backface-visibility:hidden;animation:sutol-edu36-flip 5s ease-in-out infinite;}
    @keyframes sutol-edu36-flip{
      0%{transform:rotateX(0deg);}
      40%{transform:rotateX(-180deg);}
      60%{transform:rotateX(-180deg);}
      100%{transform:rotateX(-360deg);}
    }
    @media (prefers-reduced-motion: reduce){.sutol-edu36-page{animation-duration:16s;}}
  </style>
  <div class="sutol-edu36-calendar">
    <div class="sutol-edu36-page"></div>
    <div class="sutol-edu36-grid">
      <span></span><span></span><span></span><span></span>
      <span></span><span></span><span></span><span></span>
    </div>
  </div>
</div>
```

---

## Bileşen 37: Konferans Kürsüsü Ses Halkaları

**Etiketler (keyword eşleşmesi için):** seminer, konferans, mentorluk, sunum
**Kategori:** Eğitim
**Açıklama:** Bir kürsü üzerindeki mikrofondan dışa doğru genişleyerek kaybolan eş merkezli ses halkaları.

```html
<div class="sutol-edu37-wrap">
  <style>
    .sutol-edu37-wrap{width:100%;height:100%;background:transparent;}
    .sutol-edu37-svg{width:100%;height:100%;display:block;}
    .sutol-edu37-podium{fill:#5b6b8c;}
    .sutol-edu37-mic{fill:#f0973a;}
    .sutol-edu37-wave{fill:none;stroke:#f0973a;stroke-width:2;opacity:0;transform-origin:50px 45px;animation:sutol-edu37-expand 3s ease-out infinite;}
    .sutol-edu37-wave.w2{animation-delay:1s;}
    .sutol-edu37-wave.w3{animation-delay:2s;}
    @keyframes sutol-edu37-expand{0%{transform:scale(0.3);opacity:0.8;}100%{transform:scale(2.2);opacity:0;}}
    @media (prefers-reduced-motion: reduce){.sutol-edu37-wave{animation-duration:9s;}}
  </style>
  <svg class="sutol-edu37-svg" viewBox="0 0 100 100">
    <rect class="sutol-edu37-podium" x="40" y="55" width="20" height="35" rx="2"/>
    <circle class="sutol-edu37-mic" cx="50" cy="45" r="6"/>
    <circle class="sutol-edu37-wave w1" cx="50" cy="45" r="10"/>
    <circle class="sutol-edu37-wave w2" cx="50" cy="45" r="10"/>
    <circle class="sutol-edu37-wave w3" cx="50" cy="45" r="10"/>
  </svg>
</div>
```

---

## Bileşen 38: Not Defteri Sayfa Kayması

**Etiketler (keyword eşleşmesi için):** not, ödev, ders, kayıt
**Kategori:** Eğitim
**Açıklama:** Üst üste duran üç defter sayfasının sırayla yana kayıp yerine karşıdan gelerek döngüsel biçimde değişmesi.

```html
<div class="sutol-edu38-wrap">
  <style>
    .sutol-edu38-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
    .sutol-edu38-stack{position:relative;width:60%;height:70%;}
    .sutol-edu38-page{position:absolute;inset:0;border-radius:4%;background:#f5f0e6;border:2px solid #c9c0ab;}
    .sutol-edu38-page.pg1{animation:sutol-edu38-cycle 6s ease-in-out infinite;}
    .sutol-edu38-page.pg2{animation:sutol-edu38-cycle 6s ease-in-out infinite;animation-delay:2s;background:#eef3ff;}
    .sutol-edu38-page.pg3{animation:sutol-edu38-cycle 6s ease-in-out infinite;animation-delay:4s;background:#eafff2;}
    @keyframes sutol-edu38-cycle{
      0%{transform:translateX(0) rotate(0deg);opacity:1;z-index:3;}
      30%{transform:translateX(-120%) rotate(-12deg);opacity:0;}
      30.01%{transform:translateX(120%) rotate(12deg);opacity:0;z-index:1;}
      60%{transform:translateX(0) rotate(0deg);opacity:1;z-index:3;}
      100%{transform:translateX(0) rotate(0deg);opacity:1;z-index:3;}
    }
    @media (prefers-reduced-motion: reduce){.sutol-edu38-page{animation-duration:20s;}}
  </style>
  <div class="sutol-edu38-stack">
    <div class="sutol-edu38-page pg1"></div>
    <div class="sutol-edu38-page pg2"></div>
    <div class="sutol-edu38-page pg3"></div>
  </div>
</div>
```

---

## Bileşen 39: Mentorluk Birleşen Daireler

**Etiketler (keyword eşleşmesi için):** mentorluk, danışmanlık, işbirliği, rehberlik
**Kategori:** Eğitim
**Açıklama:** İki renkli dairenin birbirine yaklaşıp örtüşerek tekrar ayrılmasıyla mentor-öğrenci etkileşiminin simgelenmesi.

```html
<div class="sutol-edu39-wrap">
  <style>
    .sutol-edu39-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;position:relative;}
    .sutol-edu39-circle{position:absolute;width:36%;height:36%;border-radius:50%;mix-blend-mode:multiply;}
    .sutol-edu39-circle.c1{background:rgba(58,109,240,0.7);animation:sutol-edu39-left 5s ease-in-out infinite;}
    .sutol-edu39-circle.c2{background:rgba(240,151,58,0.7);animation:sutol-edu39-right 5s ease-in-out infinite;}
    @keyframes sutol-edu39-left{0%,100%{transform:translateX(-30%);}50%{transform:translateX(-6%);}}
    @keyframes sutol-edu39-right{0%,100%{transform:translateX(30%);}50%{transform:translateX(6%);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-edu39-circle.c1{animation-duration:15s;}
      .sutol-edu39-circle.c2{animation-duration:15s;}
    }
  </style>
  <div class="sutol-edu39-circle c1"></div>
  <div class="sutol-edu39-circle c2"></div>
</div>
```

---

## Bileşen 40: Müfredat Çember Yörüngesi

**Etiketler (keyword eşleşmesi için):** müfredat, akademik, planlama, ders programı
**Kategori:** Eğitim
**Açıklama:** Merkezi altıgen bir çekirdeğin etrafında farklı hızlarda dönen küçük ders sembollerinin yörünge çizimi.

```html
<div class="sutol-edu40-wrap">
  <style>
    .sutol-edu40-wrap{width:100%;height:100%;background:transparent;--sutol-edu40-mult:1;}
    .sutol-edu40-svg{width:100%;height:100%;display:block;}
    .sutol-edu40-hub{fill:#7c5cff;}
    .sutol-edu40-shape{fill:#4fd1c5;}
    .sutol-edu40-shape2{fill:#f0973a;}
    @media (prefers-reduced-motion: reduce){
      .sutol-edu40-wrap{--sutol-edu40-mult:5;}
    }
  </style>
  <svg class="sutol-edu40-svg" viewBox="0 0 100 100">
    <polygon class="sutol-edu40-hub" points="50,20 78,35 78,65 50,80 22,65 22,35"/>
    <g class="sutol-edu40-orbitA">
      <rect class="sutol-edu40-shape" x="47" y="4" width="6" height="6"/>
      <animateTransform id="sutol-edu40-anim" attributeName="transform" type="rotate" from="0 50 50" to="360 50 50" dur="6s" repeatCount="indefinite"/>
    </g>
    <g class="sutol-edu40-orbitB">
      <circle class="sutol-edu40-shape2" cx="50" cy="94" r="3.2"/>
      <animateTransform id="sutol-edu40-anim2" attributeName="transform" type="rotate" from="360 50 50" to="0 50 50" dur="9s" repeatCount="indefinite"/>
    </g>
  </svg>
  <script>
    (function(){
      var wrap = document.currentScript.parentElement;
      var a1 = wrap.querySelector('#sutol-edu40-anim');
      var a2 = wrap.querySelector('#sutol-edu40-anim2');
      function apply(){
        var v = parseFloat(getComputedStyle(wrap).getPropertyValue('--sutol-edu40-mult'));
        var mult = isNaN(v) ? 1 : v;
        if(a1){ a1.setAttribute('dur', (6*mult) + 's'); }
        if(a2){ a2.setAttribute('dur', (9*mult) + 's'); }
      }
      apply();
    })();
  </script>
</div>
```

---

===BULLETS===
- Bileşen 21 (Kalem Ucu Yazı Çizgisi): SVG `stroke-dashoffset` ile çizgi çizimi + CSS `transform` keyframes ile uç hareketi; GPU dostu, düşük maliyetli.
- Bileşen 22 (Kara Tahta Tebeşir İzi): Tek path üzerinde `stroke-dasharray/dashoffset` döngüsü; DOM'a dokunmadan tamamen CSS animasyonu.
- Bileşen 23 (Sınıf Sırası Tarama Işığı): `linear-gradient` huzmesinin `left` özelliğiyle taranması; basit grid düzeni, hafif render yükü.
- Bileşen 24 (Uçan Mezuniyet Kurdelesi): CSS `offset-path`/`offset-distance` (motion-path) tekniği; `transform`/`opacity` bazlı olduğundan GPU hızlandırmalı.
- Bileşen 25 (Beyin Fırtınası Kabarcıkları): Çoklu `div` üzerinde gecikmeli `translateY`+`opacity` keyframes; her katman bağımsız, reflow yok.
- Bileşen 26 (Öğrenme Eğrisi Çizgisi): SVG path çizim animasyonu + senkronize nokta hareketi; sadece `stroke-dashoffset` ve `transform` kullanır.
- Bileşen 27 (Öğrenci Halkası Dönüşü): SVG `<g>` grubuna uygulanan CSS `rotate` keyframes; tek katman dönüşü ile ucuz render.
- Bileşen 28 (Akan Veri Ekranı): `canvas` + `requestAnimationFrame` ile parçacık simülasyonu; hız CSS özel değişkeninden okunarak reduced-motion'a uyum sağlar.
- Bileşen 29 (Rehberlik Pusulası): Tek grup üzerinde `rotate` salınım keyframes; minimal DOM, düşük CPU kullanımı.
- Bileşen 30 (Araştırma Büyüteci Taraması): `transform: translate` ile çoklu nokta (waypoint) keyframes; SVG statik belge + hareketli mercek grubu.
- Bileşen 31 (Beceri Rozetleri Sırası): `animation-delay` ile kademeli `scale`/`opacity` keyframes; her rozet bağımsız katman.
- Bileşen 32 (Kariyer Yol Haritası): CSS motion-path (`offset-path`) ile nokta hareketi + statik SVG kesikli yol; GPU dostu transform tabanlı.
- Bileşen 33 (Değerlendirme Onay Çizimi): İki ayrı `stroke-dasharray` animasyonunun zamanlanmış sırayla tetiklenmesi; saf SVG/CSS.
- Bileşen 34 (Video Ders İlerleme Çubuğu): `scale` nabız animasyonu + `width` geçişli ilerleme çubuğu; basit, düşük maliyetli iki animasyon.
- Bileşen 35 (Kalem Kutusu Açılışı): CSS `perspective`+`rotateX` ile 3B kapak açılışı, senkron `translateY` kalem çıkışı; donanım hızlandırmalı 3B dönüşüm.
- Bileşen 36 (Ders Takvimi Sayfa Çevirme): `perspective`+`rotateX(-360deg)` ile kesintisiz döngüsel sayfa çevirme; `backface-visibility` optimizasyonu.
- Bileşen 37 (Konferans Kürsüsü Ses Halkaları): Gecikmeli `scale`+`opacity` genişleyen halka keyframes; SVG statik kürsü + üç bağımsız halka katmanı.
- Bileşen 38 (Not Defteri Sayfa Kayması): Gecikmeli `translateX`+`rotate` döngüsü ile kart değişim efekti; sadece transform/opacity kullanır.
- Bileşen 39 (Mentorluk Birleşen Daireler): `mix-blend-mode` ile örtüşen iki dairenin `translateX` salınımı; hafif, iki katmanlı animasyon.
- Bileşen 40 (Müfredat Çember Yörüngesi): SVG native `<animateTransform>` (SMIL) ile yörünge dönüşü; süre CSS özel değişkeninden JS ile okunarak reduced-motion desteklenir.
