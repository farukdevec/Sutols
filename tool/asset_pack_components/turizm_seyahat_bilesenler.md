# Turizm / Seyahat Kategorisi — 20 Animasyonlu Bileşen

---

## Bileşen 1: Uçuş Rotası

**Etiketler (keyword eşleşmesi için):** seyahat, ulaşım, destinasyon, turizm
**Kategori:** Turizm / Seyahat
**Açıklama:** Noktalı bir rota üzerinde bir noktadan diğerine uçan küçük bir uçak simgesi.

```html
<div class="sutol-tr-01-root">
  <style>
    .sutol-tr-01-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-01-root svg{width:100%;height:100%;}
    .sutol-tr-01-route{fill:none;stroke:#7fa8d9;stroke-width:2;stroke-dasharray:4 5;opacity:.55;}
    .sutol-tr-01-plane{fill:#3d6ea5;animation:sutol-tr-01-fly 5s ease-in-out infinite;offset-path:path('M30,150 Q100,40 170,150');offset-rotate:auto;}
    .sutol-tr-01-pin{fill:#e0637a;}
    @keyframes sutol-tr-01-fly{0%{offset-distance:0%;opacity:0;}10%{opacity:1;}90%{opacity:1;}100%{offset-distance:100%;opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-01-plane{animation:none;opacity:0;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-tr-01-route" d="M30,150 Q100,40 170,150"/>
    <circle class="sutol-tr-01-pin" cx="30" cy="150" r="5"/>
    <circle class="sutol-tr-01-pin" cx="170" cy="150" r="5"/>
    <polygon class="sutol-tr-01-plane" points="-7,-3 7,0 -7,3 -3,0" transform="scale(2)"/>
  </svg>
</div>
```

---

## Bileşen 2: Pusula ve Harita

**Etiketler (keyword eşleşmesi için):** gezi, seyahat planı, rehber, tur
**Kategori:** Turizm / Seyahat
**Açıklama:** Yönünü ararcasına salınıp yeni bir rotada sabitlenen bir pusula ibresi.

```html
<div class="sutol-tr-02-root">
  <style>
    .sutol-tr-02-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-02-root svg{width:100%;height:100%;}
    .sutol-tr-02-needle{transform-origin:100px 100px;animation:sutol-tr-02-seek 5s ease-in-out infinite;}
    @keyframes sutol-tr-02-seek{
      0%{transform:rotate(0deg);}
      30%{transform:rotate(160deg);}
      55%{transform:rotate(90deg);}
      75%{transform:rotate(110deg);}
      100%{transform:rotate(100deg);}
    }
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-02-needle{animation:none;transform:rotate(100deg);}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <circle cx="100" cy="100" r="60" fill="none" stroke="#8a8f96" stroke-width="3" opacity="0.5"/>
    <g class="sutol-tr-02-needle">
      <polygon points="100,50 108,100 100,105 92,100" fill="#d1453a"/>
      <polygon points="100,150 108,100 100,95 92,100" fill="#c9d4e3"/>
    </g>
    <circle cx="100" cy="100" r="6" fill="#3d3d3d"/>
  </svg>
</div>
```

---

## Bileşen 3: Tatil Köyü Işıkları

**Etiketler (keyword eşleşmesi için):** otel, konaklama, tatil köyü
**Kategori:** Turizm / Seyahat
**Açıklama:** Akşam çöktükçe pencereleri sırayla ışıkla dolan bir otel binası.

```html
<div class="sutol-tr-03-root">
  <style>
    .sutol-tr-03-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-03-root svg{width:100%;height:100%;}
    .sutol-tr-03-window{fill:#f2c14e;opacity:.15;animation:sutol-tr-03-light 5s ease-in-out infinite;}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-03-window{animation:none;opacity:.6;}
    }
    @keyframes sutol-tr-03-light{0%,100%{opacity:.15;}50%{opacity:.9;}}
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <rect x="55" y="60" width="90" height="120" fill="#7f8a99" opacity="0.5"/>
    <rect class="sutol-tr-03-window" x="65" y="72" width="14" height="14" style="animation-delay:0s;"/>
    <rect class="sutol-tr-03-window" x="93" y="72" width="14" height="14" style="animation-delay:.3s;"/>
    <rect class="sutol-tr-03-window" x="121" y="72" width="14" height="14" style="animation-delay:.6s;"/>
    <rect class="sutol-tr-03-window" x="65" y="100" width="14" height="14" style="animation-delay:.9s;"/>
    <rect class="sutol-tr-03-window" x="93" y="100" width="14" height="14" style="animation-delay:1.2s;"/>
    <rect class="sutol-tr-03-window" x="121" y="100" width="14" height="14" style="animation-delay:1.5s;"/>
    <rect class="sutol-tr-03-window" x="65" y="128" width="14" height="14" style="animation-delay:1.8s;"/>
    <rect class="sutol-tr-03-window" x="93" y="128" width="14" height="14" style="animation-delay:2.1s;"/>
    <rect class="sutol-tr-03-window" x="121" y="128" width="14" height="14" style="animation-delay:2.4s;"/>
  </svg>
</div>
```

---

## Bileşen 4: Plaj Dalgaları

**Etiketler (keyword eşleşmesi için):** plaj, doğal güzellik, tatil
**Kategori:** Turizm / Seyahat
**Açıklama:** Kumsala vurup geri çekilen sakinleştirici deniz dalgaları ve parlayan bir güneş.

```html
<div class="sutol-tr-04-root">
  <style>
    .sutol-tr-04-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-04-sand{position:absolute;bottom:0;left:0;width:100%;height:18%;background:#e8d3a0;}
    .sutol-tr-04-wave{position:absolute;bottom:14%;left:0;width:100%;height:10%;background:linear-gradient(180deg,#7fc7d9,#4a9bb5);border-radius:50% 50% 0 0/100% 100% 0 0;animation:sutol-tr-04-roll 3.5s ease-in-out infinite;}
    .sutol-tr-04-sun{position:absolute;top:15%;right:18%;width:14%;aspect-ratio:1/1;border-radius:50%;background:radial-gradient(circle,#ffe08a,#f2a13c);animation:sutol-tr-04-glow 4s ease-in-out infinite;}
    @keyframes sutol-tr-04-roll{0%,100%{transform:translateY(0) scaleX(1);}50%{transform:translateY(-10px) scaleX(1.05);}}
    @keyframes sutol-tr-04-glow{0%,100%{opacity:.8;}50%{opacity:1;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-04-wave{animation:none;}
      .sutol-tr-04-sun{animation:none;}
    }
  </style>
  <div class="sutol-tr-04-sun"></div>
  <div class="sutol-tr-04-sand"></div>
  <div class="sutol-tr-04-wave"></div>
</div>
```

---

## Bileşen 5: Zirveye Tırmanış

**Etiketler (keyword eşleşmesi için):** dağcılık, macera turizmi, doğa turizmi
**Kategori:** Turizm / Seyahat
**Açıklama:** Dağın eteğinden zirvesine kadar ilerleyen ve sonunda bayrağı dikilen bir tırmanış rotası.

```html
<div class="sutol-tr-05-root">
  <style>
    .sutol-tr-05-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-05-root svg{width:100%;height:100%;}
    .sutol-tr-05-path{fill:none;stroke:#c9d4e3;stroke-width:2;stroke-dasharray:6 4;opacity:.6;}
    .sutol-tr-05-hiker{fill:#e0637a;offset-path:path('M50,175 L80,130 L110,150 L145,60');animation:sutol-tr-05-climb 6s ease-in-out infinite;}
    .sutol-tr-05-flag{opacity:0;animation:sutol-tr-05-plant 6s ease-in-out infinite;transform-origin:145px 60px;}
    @keyframes sutol-tr-05-climb{0%{offset-distance:0%;opacity:0;}10%{opacity:1;}88%{opacity:1;}95%,100%{offset-distance:100%;opacity:0;}}
    @keyframes sutol-tr-05-plant{0%,80%{opacity:0;transform:scale(.3);}92%,100%{opacity:1;transform:scale(1);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-05-hiker{animation:none;opacity:0;}
      .sutol-tr-05-flag{animation:none;opacity:1;transform:scale(1);}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <polygon points="20,180 100,40 180,180" fill="#8fa0ab" opacity="0.5"/>
    <path class="sutol-tr-05-path" d="M50,175 L80,130 L110,150 L145,60"/>
    <circle class="sutol-tr-05-hiker" r="6"/>
    <g class="sutol-tr-05-flag">
      <line x1="145" y1="60" x2="145" y2="35" stroke="#8a5a3c" stroke-width="2"/>
      <polygon points="145,35 165,42 145,49" fill="#d1453a"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 6: Kamp Ateşi

**Etiketler (keyword eşleşmesi için):** kamp, macera turizmi, doğa turizmi
**Kategori:** Turizm / Seyahat
**Açıklama:** Yıldızlı bir gökyüzü altında titreyerek yanan sıcak bir kamp ateşi.

```html
<div class="sutol-tr-06-root">
  <style>
    .sutol-tr-06-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-06-star{position:absolute;width:4px;height:4px;border-radius:50%;background:#fff;opacity:.4;animation:sutol-tr-06-twinkle 3s ease-in-out infinite;}
    .sutol-tr-06-logs{position:absolute;left:50%;bottom:20%;width:22%;height:5%;transform:translateX(-50%) rotate(-8deg);background:#6b4d31;border-radius:2px;}
    .sutol-tr-06-logs2{transform:translateX(-50%) rotate(8deg);}
    .sutol-tr-06-flame{position:absolute;left:50%;bottom:22%;width:14%;height:22%;transform:translateX(-50%);background:radial-gradient(ellipse at 50% 70%,#ffe08a,#f2994a 55%,#d1453a 90%);border-radius:50% 50% 50% 50% / 65% 65% 35% 35%;animation:sutol-tr-06-flicker 2s ease-in-out infinite;transform-origin:bottom center;}
    @keyframes sutol-tr-06-flicker{0%,100%{transform:translateX(-50%) scale(1,1);}40%{transform:translateX(-53%) scale(.9,1.1);}70%{transform:translateX(-47%) scale(1.1,.9);}}
    @keyframes sutol-tr-06-twinkle{0%,100%{opacity:.2;}50%{opacity:.9;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-06-flame{animation:none;}
      .sutol-tr-06-star{animation:none;opacity:.5;}
    }
  </style>
  <div class="sutol-tr-06-star" style="top:10%;left:20%;animation-delay:0s;"></div>
  <div class="sutol-tr-06-star" style="top:18%;left:70%;animation-delay:.8s;"></div>
  <div class="sutol-tr-06-star" style="top:8%;left:50%;animation-delay:1.6s;"></div>
  <div class="sutol-tr-06-star" style="top:25%;left:35%;animation-delay:.4s;"></div>
  <div class="sutol-tr-06-logs sutol-tr-06-logs2"></div>
  <div class="sutol-tr-06-logs"></div>
  <div class="sutol-tr-06-flame"></div>
</div>
```

---

## Bileşen 7: Ekoturizm Döngüsü

**Etiketler (keyword eşleşmesi için):** ekoturizm, doğa turizmi, doğal güzellik
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir yaprağın etrafında dönen ve doğayla uyumu simgeleyen ayak izi rotası.

```html
<div class="sutol-tr-07-root">
  <style>
    .sutol-tr-07-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-07-root svg{width:100%;height:100%;}
    .sutol-tr-07-leaf{animation:sutol-tr-07-breathe 4s ease-in-out infinite;transform-origin:100px 100px;}
    .sutol-tr-07-print{fill:#6ea852;opacity:0;animation:sutol-tr-07-step 4s ease-in-out infinite;}
    @keyframes sutol-tr-07-breathe{0%,100%{transform:scale(1);}50%{transform:scale(1.08);}}
    @keyframes sutol-tr-07-step{0%,100%{opacity:0;}50%{opacity:.7;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-07-leaf{animation:none;}
      .sutol-tr-07-print{animation:none;opacity:.4;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <ellipse class="sutol-tr-07-print" cx="60" cy="150" rx="6" ry="9" style="animation-delay:0s;"/>
    <ellipse class="sutol-tr-07-print" cx="80" cy="130" rx="6" ry="9" style="animation-delay:.4s;"/>
    <ellipse class="sutol-tr-07-print" cx="60" cy="110" rx="6" ry="9" style="animation-delay:.8s;"/>
    <path class="sutol-tr-07-leaf" d="M100,60 C140,70 150,120 100,150 C50,120 60,70 100,60 Z" fill="#7fc25c"/>
    <line x1="100" y1="150" x2="100" y2="70" stroke="#4f7a3c" stroke-width="2" opacity="0.5"/>
  </svg>
</div>
```

---

## Bileşen 8: Gastronomi Buharı

**Etiketler (keyword eşleşmesi için):** gastronomi, yerel kültür, deneyim
**Kategori:** Turizm / Seyahat
**Açıklama:** Sıcak bir yemek tabağından yükselen ve dağılan hoş buhar kıvrımları.

```html
<div class="sutol-tr-08-root">
  <style>
    .sutol-tr-08-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-08-plate{position:absolute;left:50%;bottom:20%;width:44%;height:10%;transform:translateX(-50%);background:#e8e0d0;border-radius:50%;}
    .sutol-tr-08-food{position:absolute;left:50%;bottom:24%;width:26%;height:8%;transform:translateX(-50%);background:#d18a4a;border-radius:50%;}
    .sutol-tr-08-steam{position:absolute;bottom:32%;width:3%;height:26%;border-radius:50%;background:linear-gradient(180deg,transparent,rgba(255,255,255,.7));animation:sutol-tr-08-rise 3s ease-in-out infinite;}
    @keyframes sutol-tr-08-rise{
      0%{opacity:0;transform:translateY(0) translateX(0) scaleX(1);}
      30%{opacity:.8;}
      100%{opacity:0;transform:translateY(-40px) translateX(10px) scaleX(1.6);}
    }
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-08-steam{animation:none;opacity:.3;}
    }
  </style>
  <div class="sutol-tr-08-steam" style="left:45%;animation-delay:0s;"></div>
  <div class="sutol-tr-08-steam" style="left:52%;animation-delay:.7s;"></div>
  <div class="sutol-tr-08-steam" style="left:58%;animation-delay:1.4s;"></div>
  <div class="sutol-tr-08-plate"></div>
  <div class="sutol-tr-08-food"></div>
</div>
```

---

## Bileşen 9: Kültürel Miras Anıtı

**Etiketler (keyword eşleşmesi için):** kültürel miras, tarihi yer, kültür turizmi
**Kategori:** Turizm / Seyahat
**Açıklama:** Üzerine yumuşak bir ışık düşen, sütunlu antik bir anıt yapı.

```html
<div class="sutol-tr-09-root">
  <style>
    .sutol-tr-09-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-09-root svg{width:100%;height:100%;}
    .sutol-tr-09-glow{opacity:.3;animation:sutol-tr-09-shine 5s ease-in-out infinite;}
    @keyframes sutol-tr-09-shine{0%,100%{opacity:.2;}50%{opacity:.6;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-09-glow{animation:none;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <ellipse class="sutol-tr-09-glow" cx="100" cy="60" rx="60" ry="30" fill="#f2c14e"/>
    <rect x="40" y="150" width="120" height="10" fill="#a89c8f"/>
    <rect x="50" y="80" width="10" height="70" fill="#c9c2b4"/>
    <rect x="75" y="80" width="10" height="70" fill="#c9c2b4"/>
    <rect x="100" y="80" width="10" height="70" fill="#c9c2b4"/>
    <rect x="125" y="80" width="10" height="70" fill="#c9c2b4"/>
    <rect x="150" y="80" width="10" height="70" fill="#c9c2b4"/>
    <rect x="38" y="68" width="124" height="12" fill="#a89c8f"/>
    <polygon points="38,68 100,40 162,68" fill="#8f8474"/>
  </svg>
</div>
```

---

## Bileşen 10: Tarihi Kalıntılar

**Etiketler (keyword eşleşmesi için):** tarihi yer, kültür turizmi, görülen
**Kategori:** Turizm / Seyahat
**Açıklama:** Ufukta yükselen güneşin ardında yükselen antik sütun kalıntıları.

```html
<div class="sutol-tr-10-root">
  <style>
    .sutol-tr-10-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-10-sun{position:absolute;left:50%;bottom:28%;width:26%;aspect-ratio:1/1;border-radius:50%;transform:translateX(-50%);background:radial-gradient(circle,#f2c14e,#e0a13c);animation:sutol-tr-10-rise 6s ease-in-out infinite;}
    .sutol-tr-10-ruin{position:absolute;bottom:20%;width:5%;background:#8f8474;border-radius:2px 2px 0 0;}
    @keyframes sutol-tr-10-rise{0%,100%{bottom:20%;opacity:.6;}50%{bottom:36%;opacity:1;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-10-sun{animation:none;opacity:.7;}
    }
  </style>
  <div class="sutol-tr-10-sun"></div>
  <div class="sutol-tr-10-ruin" style="left:25%;height:30%;"></div>
  <div class="sutol-tr-10-ruin" style="left:40%;height:40%;"></div>
  <div class="sutol-tr-10-ruin" style="left:55%;height:22%;"></div>
  <div class="sutol-tr-10-ruin" style="left:70%;height:35%;"></div>
</div>
```

---

## Bileşen 11: Pasaport Damgası

**Etiketler (keyword eşleşmesi için):** pasaport, vize, seyahat
**Kategori:** Turizm / Seyahat
**Açıklama:** Açık bir pasaport sayfasına vurulan ve giderek netleşen bir giriş damgası.

```html
<div class="sutol-tr-11-root">
  <style>
    .sutol-tr-11-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-11-root svg{width:100%;height:100%;}
    .sutol-tr-11-page{fill:#f5f0e3;}
    .sutol-tr-11-stamp{opacity:0;transform-origin:130px 100px;animation:sutol-tr-11-stampfx 4s ease-in-out infinite;}
    @keyframes sutol-tr-11-stampfx{
      0%,20%{opacity:0;transform:translate(20px,-20px) rotate(-25deg) scale(1.4);}
      35%{opacity:.9;transform:translate(0,0) rotate(-12deg) scale(1);}
      80%{opacity:.9;transform:translate(0,0) rotate(-12deg) scale(1);}
      100%{opacity:0;transform:translate(0,0) rotate(-12deg) scale(1);}
    }
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-11-stamp{animation:none;opacity:.7;transform:translate(0,0) rotate(-12deg) scale(1);}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <rect class="sutol-tr-11-page" x="35" y="55" width="130" height="95" rx="4"/>
    <line x1="100" y1="55" x2="100" y2="150" stroke="#d9d0bb" stroke-width="2"/>
    <line x1="50" y1="75" x2="85" y2="75" stroke="#c9c2b4" stroke-width="2"/>
    <line x1="50" y1="90" x2="85" y2="90" stroke="#c9c2b4" stroke-width="2"/>
    <line x1="50" y1="105" x2="85" y2="105" stroke="#c9c2b4" stroke-width="2"/>
    <g class="sutol-tr-11-stamp">
      <circle cx="130" cy="100" r="26" fill="none" stroke="#d1453a" stroke-width="3"/>
      <circle cx="130" cy="100" r="18" fill="none" stroke="#d1453a" stroke-width="1.5"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 12: Anı Karesi

**Etiketler (keyword eşleşmesi için):** turist, deneyim, gezi
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir konumu kareye alan ve flaşıyla anı yakalayan bir fotoğraf makinesi.

```html
<div class="sutol-tr-12-root">
  <style>
    .sutol-tr-12-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-12-root svg{width:100%;height:100%;}
    .sutol-tr-12-flash{opacity:0;animation:sutol-tr-12-shot 3.5s ease-in-out infinite;}
    .sutol-tr-12-lens{animation:sutol-tr-12-focus 3.5s ease-in-out infinite;transform-origin:100px 100px;}
    @keyframes sutol-tr-12-shot{0%,45%{opacity:0;}50%{opacity:.9;}60%,100%{opacity:0;}}
    @keyframes sutol-tr-12-focus{0%,40%{transform:scale(1);}50%{transform:scale(.85);}60%,100%{transform:scale(1);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-12-flash{animation:none;}
      .sutol-tr-12-lens{animation:none;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <rect x="60" y="80" width="80" height="55" rx="6" fill="#3d3d3d"/>
    <rect x="85" y="68" width="30" height="14" rx="3" fill="#3d3d3d"/>
    <circle class="sutol-tr-12-lens" cx="100" cy="108" r="20" fill="#7f8a99"/>
    <circle cx="100" cy="108" r="12" fill="#2a2a2a"/>
    <circle class="sutol-tr-12-flash" cx="100" cy="108" r="45" fill="#fff"/>
  </svg>
</div>
```

---

## Bileşen 13: Destinasyon Rotası

**Etiketler (keyword eşleşmesi için):** destinasyon, seyahat planı, tur
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir haritada birbirine bağlanan ve sırayla parlayan destinasyon işaretleri.

```html
<div class="sutol-tr-13-root">
  <style>
    .sutol-tr-13-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-13-root svg{width:100%;height:100%;}
    .sutol-tr-13-line{fill:none;stroke:#8a8f96;stroke-width:2;stroke-dasharray:5 4;opacity:.4;}
    .sutol-tr-13-pin{fill:#d1453a;opacity:.4;animation:sutol-tr-13-mark 4.5s ease-in-out infinite;}
    @keyframes sutol-tr-13-mark{0%,10%{opacity:.4;transform:scale(1);}20%,30%{opacity:1;transform:scale(1.3);}40%,100%{opacity:.4;transform:scale(1);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-13-pin{animation:none;opacity:.7;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-tr-13-line" d="M40,150 L90,100 L120,130 L165,60"/>
    <circle class="sutol-tr-13-pin" cx="40" cy="150" r="8" style="animation-delay:0s;transform-origin:40px 150px;"/>
    <circle class="sutol-tr-13-pin" cx="90" cy="100" r="8" style="animation-delay:1s;transform-origin:90px 100px;"/>
    <circle class="sutol-tr-13-pin" cx="120" cy="130" r="8" style="animation-delay:2s;transform-origin:120px 130px;"/>
    <circle class="sutol-tr-13-pin" cx="165" cy="60" r="8" style="animation-delay:3s;transform-origin:165px 60px;"/>
  </svg>
</div>
```

---

## Bileşen 14: Ulaşım Ağı

**Etiketler (keyword eşleşmesi için):** ulaşım, tur, gezi
**Kategori:** Turizm / Seyahat
**Açıklama:** Kıvrımlı bir yol üzerinde ilerleyen küçük bir taşıt simgesi.

```html
<div class="sutol-tr-14-root">
  <style>
    .sutol-tr-14-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-14-root svg{width:100%;height:100%;}
    .sutol-tr-14-road{fill:none;stroke:#8a8f96;stroke-width:8;stroke-linecap:round;opacity:.35;}
    .sutol-tr-14-lane{fill:none;stroke:#fff;stroke-width:2;stroke-dasharray:6 6;opacity:.5;}
    .sutol-tr-14-bus{fill:#f2c14e;offset-path:path('M20,170 C60,170 60,100 100,100 C140,100 140,40 180,40');animation:sutol-tr-14-drive 5s linear infinite;}
    @keyframes sutol-tr-14-drive{0%{offset-distance:0%;}100%{offset-distance:100%;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-14-bus{animation:none;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-tr-14-road" d="M20,170 C60,170 60,100 100,100 C140,100 140,40 180,40"/>
    <path class="sutol-tr-14-lane" d="M20,170 C60,170 60,100 100,100 C140,100 140,40 180,40"/>
    <rect class="sutol-tr-14-bus" width="16" height="10" rx="2" x="-8" y="-5"/>
  </svg>
</div>
```

---

## Bileşen 15: Doğa Turizmi Ormanı

**Etiketler (keyword eşleşmesi için):** doğa turizmi, doğal güzellik, ekoturizm
**Kategori:** Turizm / Seyahat
**Açıklama:** Hafifçe sallanan ağaçlar ve üzerlerinde süzülen bir kuş silueti.

```html
<div class="sutol-tr-15-root">
  <style>
    .sutol-tr-15-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-15-tree{position:absolute;bottom:12%;width:14%;transform-origin:bottom center;animation:sutol-tr-15-sway 4s ease-in-out infinite;}
    .sutol-tr-15-tree svg{width:100%;height:auto;display:block;}
    .sutol-tr-15-bird{position:absolute;top:18%;width:6%;animation:sutol-tr-15-glide 6s linear infinite;}
    @keyframes sutol-tr-15-sway{0%,100%{transform:rotate(-3deg);}50%{transform:rotate(3deg);}}
    @keyframes sutol-tr-15-glide{0%{left:-10%;}100%{left:105%;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-15-tree{animation:none;}
      .sutol-tr-15-bird{animation:none;left:45%;}
    }
  </style>
  <div class="sutol-tr-15-tree" style="left:15%;animation-delay:0s;">
    <svg viewBox="0 0 40 60"><rect x="16" y="40" width="8" height="20" fill="#6b4d31"/><circle cx="20" cy="28" r="20" fill="#6ea852"/></svg>
  </div>
  <div class="sutol-tr-15-tree" style="left:45%;animation-delay:.5s;">
    <svg viewBox="0 0 40 60"><rect x="16" y="40" width="8" height="20" fill="#6b4d31"/><circle cx="20" cy="28" r="22" fill="#7fc25c"/></svg>
  </div>
  <div class="sutol-tr-15-tree" style="left:70%;animation-delay:.25s;">
    <svg viewBox="0 0 40 60"><rect x="16" y="40" width="8" height="20" fill="#6b4d31"/><circle cx="20" cy="28" r="18" fill="#6ea852"/></svg>
  </div>
  <div class="sutol-tr-15-bird">
    <svg viewBox="0 0 30 12"><path d="M0,6 Q7,0 15,6 Q23,0 30,6" fill="none" stroke="#3d3d3d" stroke-width="2"/></svg>
  </div>
</div>
```

---

## Bileşen 16: Deneyim Yıldızları

**Etiketler (keyword eşleşmesi için):** deneyim, turist, tur
**Kategori:** Turizm / Seyahat
**Açıklama:** Sırayla parlayarak dolan, unutulmaz bir deneyimi puanlayan yıldızlar.

```html
<div class="sutol-tr-16-root">
  <style>
    .sutol-tr-16-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-16-root svg{width:100%;height:100%;}
    .sutol-tr-16-star{fill:#c9c2b4;animation:sutol-tr-16-fill 5s ease-in-out infinite;}
    @keyframes sutol-tr-16-fill{0%,100%{fill:#c9c2b4;transform:scale(1);}5%,60%{fill:#f2c14e;transform:scale(1.15);}70%,95%{fill:#f2c14e;transform:scale(1);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-16-star{animation:none;fill:#f2c14e;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-tr-16-star" style="animation-delay:0s;transform-origin:45px 100px;" d="M45,80 L51,95 L67,95 L54,105 L59,120 L45,111 L31,120 L36,105 L23,95 L39,95 Z"/>
    <path class="sutol-tr-16-star" style="animation-delay:.4s;transform-origin:80px 100px;" d="M80,80 L86,95 L102,95 L89,105 L94,120 L80,111 L66,120 L71,105 L58,95 L74,95 Z"/>
    <path class="sutol-tr-16-star" style="animation-delay:.8s;transform-origin:115px 100px;" d="M115,80 L121,95 L137,95 L124,105 L129,120 L115,111 L101,120 L106,105 L93,95 L109,95 Z"/>
    <path class="sutol-tr-16-star" style="animation-delay:1.2s;transform-origin:150px 100px;" d="M150,80 L156,95 L172,95 L159,105 L164,120 L150,111 L136,120 L141,105 L128,95 L144,95 Z"/>
  </svg>
</div>
```

---

## Bileşen 17: Tur Rehberi Bayrağı

**Etiketler (keyword eşleşmesi için):** rehber, tur, gezi
**Kategori:** Turizm / Seyahat
**Açıklama:** Havada sallanan bir rehber bayrağı ve arkasında toplanan küçük bir grup.

```html
<div class="sutol-tr-17-root">
  <style>
    .sutol-tr-17-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-17-root svg{width:100%;height:100%;}
    .sutol-tr-17-flag{transform-origin:60px 60px;animation:sutol-tr-17-wave 2.4s ease-in-out infinite;}
    .sutol-tr-17-person{fill:#7fa8d9;opacity:.8;animation:sutol-tr-17-bob 2.4s ease-in-out infinite;}
    @keyframes sutol-tr-17-wave{0%,100%{transform:rotate(0deg);}50%{transform:rotate(8deg);}}
    @keyframes sutol-tr-17-bob{0%,100%{transform:translateY(0);}50%{transform:translateY(-3px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-17-flag{animation:none;}
      .sutol-tr-17-person{animation:none;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <line x1="60" y1="60" x2="60" y2="140" stroke="#6b4d31" stroke-width="3"/>
    <polygon class="sutol-tr-17-flag" points="60,60 95,68 60,80" fill="#d1453a"/>
    <circle class="sutol-tr-17-person" cx="100" cy="130" r="9" style="animation-delay:0s;"/>
    <circle class="sutol-tr-17-person" cx="120" cy="140" r="9" style="animation-delay:.4s;"/>
    <circle class="sutol-tr-17-person" cx="140" cy="128" r="9" style="animation-delay:.8s;"/>
  </svg>
</div>
```

---

## Bileşen 18: Yerel Kültür Motifi

**Etiketler (keyword eşleşmesi için):** yerel kültür, kültür turizmi, gastronomi
**Kategori:** Turizm / Seyahat
**Açıklama:** Yavaşça dönen, geometrik el sanatı desenlerinden oluşan soyut bir motif.

```html
<div class="sutol-tr-18-root">
  <style>
    .sutol-tr-18-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-18-root svg{width:100%;height:100%;}
    .sutol-tr-18-group{transform-origin:100px 100px;animation:sutol-tr-18-spin 16s linear infinite;}
    .sutol-tr-18-shape{fill:none;stroke:#d18a4a;stroke-width:2;opacity:.75;}
    @keyframes sutol-tr-18-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-18-group{animation:none;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-tr-18-group">
      <polygon class="sutol-tr-18-shape" points="100,50 130,100 100,150 70,100"/>
      <circle class="sutol-tr-18-shape" cx="100" cy="100" r="45"/>
      <polygon class="sutol-tr-18-shape" points="100,65 122,100 100,135 78,100" stroke="#c9436b"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 19: Macera Turizmi Rafting

**Etiketler (keyword eşleşmesi için):** macera turizmi, doğa turizmi, deneyim
**Kategori:** Turizm / Seyahat
**Açıklama:** Dalgalı bir nehir üzerinde ilerleyen küçük bir kano/rafting teknesi.

```html
<div class="sutol-tr-19-root">
  <style>
    .sutol-tr-19-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-19-root svg{width:100%;height:100%;}
    .sutol-tr-19-river{fill:none;stroke:#5fa8d3;stroke-width:14;stroke-linecap:round;opacity:.4;}
    .sutol-tr-19-boat{fill:#e0637a;offset-path:path('M20,60 C60,90 80,40 120,70 C150,90 160,60 180,80');animation:sutol-tr-19-paddle 5s ease-in-out infinite;}
    @keyframes sutol-tr-19-paddle{0%{offset-distance:0%;opacity:0;}10%{opacity:1;}90%{opacity:1;}100%{offset-distance:100%;opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-19-boat{animation:none;opacity:0;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-tr-19-river" d="M20,60 C60,90 80,40 120,70 C150,90 160,60 180,80"/>
    <ellipse class="sutol-tr-19-boat" rx="10" ry="5"/>
  </svg>
</div>
```

---

## Bileşen 20: Seyahat Planı Takvimi

**Etiketler (keyword eşleşmesi için):** seyahat planı, tatil, vize
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir takvim üzerinde sırayla beliren ve tatil planını tamamlayan onay işaretleri.

```html
<div class="sutol-tr-20-root">
  <style>
    .sutol-tr-20-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-tr-20-root svg{width:100%;height:100%;}
    .sutol-tr-20-check{stroke-dasharray:20;stroke-dashoffset:20;opacity:0;animation:sutol-tr-20-tick 5s ease-in-out infinite;}
    @keyframes sutol-tr-20-tick{0%,10%{opacity:0;stroke-dashoffset:20;}20%,80%{opacity:1;stroke-dashoffset:0;}90%,100%{opacity:0;stroke-dashoffset:20;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-tr-20-check{animation:none;opacity:.7;stroke-dashoffset:0;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <rect x="40" y="50" width="120" height="110" rx="8" fill="#f5f0e3" stroke="#c9c2b4" stroke-width="2"/>
    <rect x="40" y="50" width="120" height="24" rx="8" fill="#7fa8d9"/>
    <line x1="70" y1="42" x2="70" y2="60" stroke="#3d6ea5" stroke-width="4" stroke-linecap="round"/>
    <line x1="130" y1="42" x2="130" y2="60" stroke="#3d6ea5" stroke-width="4" stroke-linecap="round"/>
    <rect x="55" y="90" width="20" height="20" rx="3" fill="none" stroke="#c9c2b4" stroke-width="2"/>
    <path class="sutol-tr-20-check" d="M58,100 L64,106 L72,92" fill="none" stroke="#6ea852" stroke-width="3" stroke-linecap="round" style="animation-delay:0s;"/>
    <rect x="90" y="90" width="20" height="20" rx="3" fill="none" stroke="#c9c2b4" stroke-width="2"/>
    <path class="sutol-tr-20-check" d="M93,100 L99,106 L107,92" fill="none" stroke="#6ea852" stroke-width="3" stroke-linecap="round" style="animation-delay:1.2s;"/>
    <rect x="125" y="90" width="20" height="20" rx="3" fill="none" stroke="#c9c2b4" stroke-width="2"/>
    <path class="sutol-tr-20-check" d="M128,100 L134,106 L142,92" fill="none" stroke="#6ea852" stroke-width="3" stroke-linecap="round" style="animation-delay:2.4s;"/>
  </svg>
</div>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Uçuş Rotası): CSS/SVG `offset-path` ile eğri rota üzerinde uçan uçak.
- Bileşen 2 (Pusula ve Harita): SVG `transform-origin` rotate ile yön arama salınımı.
- Bileşen 3 (Tatil Köyü Işıkları): SVG `opacity` keyframe ile pencerelerin kademeli aydınlanması.
- Bileşen 4 (Plaj Dalgaları): CSS `translateY`/`scaleX` dalga yuvarlanması + güneş `opacity` parlaması.
- Bileşen 5 (Zirveye Tırmanış): SVG `offset-path` tırmanış + bayrak `scale`/`opacity` dikilme animasyonu.
- Bileşen 6 (Kamp Ateşi): CSS `scale`/skew alev titreşimi + yıldız `opacity` twinkle.
- Bileşen 7 (Ekoturizm Döngüsü): SVG `scale` nabız + ayak izi `opacity` sıralı belirme.
- Bileşen 8 (Gastronomi Buharı): CSS `translateY`/`scaleX`/`opacity` yükselen buhar kıvrımı.
- Bileşen 9 (Kültürel Miras Anıtı): SVG statik yapı + `opacity` keyframe ışık parıltısı.
- Bileşen 10 (Tarihi Kalıntılar): CSS `bottom`/`opacity` güneş doğuşu animasyonu.
- Bileşen 11 (Pasaport Damgası): SVG `translate`/`rotate`/`scale`/`opacity` damga vurma efekti.
- Bileşen 12 (Anı Karesi): SVG `scale` odaklanma + `opacity` flaş efekti.
- Bileşen 13 (Destinasyon Rotası): SVG `scale`/`opacity` sıralı pin vurgulama.
- Bileşen 14 (Ulaşım Ağı): SVG `offset-path` ile yol üzerinde ilerleyen taşıt.
- Bileşen 15 (Doğa Turizmi Ormanı): CSS `rotate` ağaç sallanması + `left` kuş uçuşu.
- Bileşen 16 (Deneyim Yıldızları): SVG `fill`/`scale` keyframe ile sıralı yıldız doldurma.
- Bileşen 17 (Tur Rehberi Bayrağı): SVG `rotate` bayrak dalgalanması + grup `translateY` bob animasyonu.
- Bileşen 18 (Yerel Kültür Motifi): SVG grup `rotate`, sembolden bağımsız geometrik desen.
- Bileşen 19 (Macera Turizmi Rafting): SVG `offset-path` ile dalgalı nehir üzerinde tekne hareketi.
- Bileşen 20 (Seyahat Planı Takvimi): SVG `stroke-dashoffset`/`opacity` ile sıralı onay işareti çizimi.

Tüm bileşenler: tek dosya bağımsız HTML/CSS/SVG, şeffaf arka plan, `viewBox` veya % tabanlı ölçeklenebilir boyutlandırma, `prefers-reduced-motion` desteği, sandbox uyumlu (dış kaynak/localStorage/çerez/`window.top` erişimi yok), sabit dil metni içermeyen, kendine özgü `.sutol-tr-XX-` sınıf önekleriyle kapsüllenmiş CSS kullanır.
