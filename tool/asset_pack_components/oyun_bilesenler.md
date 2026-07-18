# Sutol — Oyun & Eğlence Dünyası Kategorisi Bileşen Kütüphanesi (20 Bileşen)

Kategori: **Oyun & Eğlence Dünyası**
Anahtar kelime havuzu: zar, satranç tahtası, bulmaca parçası, oyun kartı, joystick, puan tablosu, ödül kutusu, labirent oyunu, yapboz, macera haritası, e-spor arenası, sanal gerçeklik gözlüğü

---

## Bileşen 1: Yuvarlanan Zar

**Etiketler (keyword eşleşmesi için):** zar
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Kendi ekseninde sürekli yuvarlanan, farklı yüzlerini gösteren bir zar.

```html
<div class="sutol-oyu01-root">
  <svg class="sutol-oyu01-svg" viewBox="0 0 160 160" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-oyu01-die" style="transform-origin:80px 80px;">
      <rect x="30" y="30" width="100" height="100" rx="14" fill="#F1F3F5" stroke="#495057" stroke-width="4"/>
      <circle cx="80" cy="80" r="9" fill="#E03131"/>
      <circle cx="52" cy="52" r="7" fill="#E03131"/>
      <circle cx="108" cy="108" r="7" fill="#E03131"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu01-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu01-svg{width:100%;height:100%;display:block;}
  .sutol-oyu01-die{animation:sutol-oyu01-tumble 3s ease-in-out infinite;}
  @keyframes sutol-oyu01-tumble{
    0%{transform:rotate(0deg) scale(1);}
    25%{transform:rotate(95deg) scale(0.85);}
    50%{transform:rotate(180deg) scale(1);}
    75%{transform:rotate(275deg) scale(0.85);}
    100%{transform:rotate(360deg) scale(1);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu01-die{animation-duration:12s;}
  }
</style>
```

---

## Bileşen 2: Sıçrayan Çift Zar

**Etiketler (keyword eşleşmesi için):** zar
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Bir zemine düşüp sekerek duran iki oyun zarı.

```html
<div class="sutol-oyu02-root">
  <svg class="sutol-oyu02-svg" viewBox="0 0 220 140" preserveAspectRatio="xMidYMid meet">
    <ellipse cx="110" cy="125" rx="80" ry="10" fill="#495057" opacity="0.2"/>
    <g class="sutol-oyu02-die sutol-oyu02-d1">
      <rect x="0" y="0" width="50" height="50" rx="8" fill="#4C6EF5" stroke="#364FC7" stroke-width="3"/>
      <circle cx="25" cy="25" r="5" fill="#F1F3F5"/>
    </g>
    <g class="sutol-oyu02-die sutol-oyu02-d2">
      <rect x="0" y="0" width="50" height="50" rx="8" fill="#F76707" stroke="#D9480F" stroke-width="3"/>
      <circle cx="15" cy="15" r="5" fill="#FFF3BF"/>
      <circle cx="35" cy="35" r="5" fill="#FFF3BF"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu02-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu02-svg{width:100%;height:100%;display:block;}
  .sutol-oyu02-d1{animation:sutol-oyu02-bounce1 2.4s ease-in-out infinite;}
  .sutol-oyu02-d2{animation:sutol-oyu02-bounce2 2.4s ease-in-out infinite;animation-delay:0.2s;}
  @keyframes sutol-oyu02-bounce1{
    0%{transform:translate(50px,-40px) rotate(0deg);}
    40%{transform:translate(60px,90px) rotate(120deg);}
    55%{transform:translate(62px,80px) rotate(140deg);}
    70%{transform:translate(64px,90px) rotate(160deg);}
    100%{transform:translate(64px,90px) rotate(160deg);}
  }
  @keyframes sutol-oyu02-bounce2{
    0%{transform:translate(130px,-60px) rotate(0deg);}
    45%{transform:translate(120px,90px) rotate(-100deg);}
    60%{transform:translate(118px,78px) rotate(-120deg);}
    75%{transform:translate(120px,90px) rotate(-140deg);}
    100%{transform:translate(120px,90px) rotate(-140deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu02-d1,.sutol-oyu02-d2{animation-duration:9s;}
  }
</style>
```

---

## Bileşen 3: Hareket Eden Satranç Taşı

**Etiketler (keyword eşleşmesi için):** satranç tahtası
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Bir satranç tahtası üzerinde kareden kareye ilerleyen bir at (knight) taşı.

```html
<div class="sutol-oyu03-root">
  <svg class="sutol-oyu03-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <g>
      <rect x="0" y="0" width="200" height="200" fill="#F1F3F5"/>
      <g fill="#495057">
        <rect x="0" y="0" width="50" height="50"/><rect x="100" y="0" width="50" height="50"/>
        <rect x="50" y="50" width="50" height="50"/><rect x="150" y="50" width="50" height="50"/>
        <rect x="0" y="100" width="50" height="50"/><rect x="100" y="100" width="50" height="50"/>
        <rect x="50" y="150" width="50" height="50"/><rect x="150" y="150" width="50" height="50"/>
      </g>
    </g>
    <g class="sutol-oyu03-knight">
      <path d="M0,20 C -2,5 8,-8 20,-6 C 28,-4 30,4 26,10 L34,10 L34,20 L-10,20 Z" fill="#212529"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu03-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu03-svg{width:100%;height:100%;display:block;}
  .sutol-oyu03-knight{animation:sutol-oyu03-move 4s ease-in-out infinite;}
  @keyframes sutol-oyu03-move{
    0%,15%{transform:translate(50px,130px);}
    45%,60%{transform:translate(120px,60px);}
    100%{transform:translate(50px,130px);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu03-knight{animation-duration:12s;}
  }
</style>
```

---

## Bileşen 4: Dizilen Satranç Piyonları

**Etiketler (keyword eşleşmesi için):** satranç tahtası
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Bir satranç tahtası hattı üzerinde sırayla beliren piyon taşları.

```html
<div class="sutol-oyu04-root">
  <svg class="sutol-oyu04-svg" viewBox="0 0 300 100" preserveAspectRatio="xMidYMid meet">
    <line x1="0" y1="85" x2="300" y2="85" stroke="#CED4DA" stroke-width="2"/>
    <g class="sutol-oyu04-pawn" fill="#495057">
      <circle cx="40" cy="60" r="10"/><path d="M28,70 L52,70 L48,85 L32,85 Z"/>
    </g>
    <g class="sutol-oyu04-pawn sutol-oyu04-p2" fill="#495057">
      <circle cx="100" cy="60" r="10"/><path d="M88,70 L112,70 L108,85 L92,85 Z"/>
    </g>
    <g class="sutol-oyu04-pawn sutol-oyu04-p3" fill="#495057">
      <circle cx="160" cy="60" r="10"/><path d="M148,70 L172,70 L168,85 L152,85 Z"/>
    </g>
    <g class="sutol-oyu04-pawn sutol-oyu04-p4" fill="#495057">
      <circle cx="220" cy="60" r="10"/><path d="M208,70 L232,70 L228,85 L212,85 Z"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu04-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu04-svg{width:100%;height:100%;display:block;}
  .sutol-oyu04-pawn{transform-box:fill-box;transform-origin:bottom center;opacity:0;animation:sutol-oyu04-appear 4s ease-in-out infinite;}
  .sutol-oyu04-p2{animation-delay:0.5s;}
  .sutol-oyu04-p3{animation-delay:1s;}
  .sutol-oyu04-p4{animation-delay:1.5s;}
  @keyframes sutol-oyu04-appear{
    0%{transform:translateY(15px) scale(0.6);opacity:0;}
    20%,75%{transform:translateY(0) scale(1);opacity:1;}
    100%{transform:translateY(15px) scale(0.6);opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu04-pawn{animation-duration:12s;}
  }
</style>
```

---

## Bileşen 5: Yerine Oturan Bulmaca Parçası

**Etiketler (keyword eşleşmesi için):** bulmaca parçası, yapboz
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Bir bulmaca çerçevesindeki boşluğa süzülerek yerleşen tek bir parça.

```html
<div class="sutol-oyu05-root">
  <svg class="sutol-oyu05-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <rect x="40" y="40" width="120" height="120" rx="8" fill="none" stroke="#ADB5BD" stroke-width="3" stroke-dasharray="6 5"/>
    <g class="sutol-oyu05-piece">
      <path d="M0,0 h50 v20 a10,10 0 0 1 0,20 v10 h-50 v-20 a10,10 0 0 0 0,-20 Z" fill="#FA5252"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu05-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu05-svg{width:100%;height:100%;display:block;}
  .sutol-oyu05-piece{animation:sutol-oyu05-fit 3.4s ease-in-out infinite;}
  @keyframes sutol-oyu05-fit{
    0%{transform:translate(120px,10px) rotate(-8deg);opacity:0;}
    35%{opacity:1;}
    55%,80%{transform:translate(65px,65px) rotate(0deg);opacity:1;}
    100%{transform:translate(120px,10px) rotate(-8deg);opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu05-piece{animation-duration:12s;}
  }
</style>
```

---

## Bileşen 6: Kayan Bulmaca Parçaları

**Etiketler (keyword eşleşmesi için):** bulmaca parçası
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Bir kayar bulmaca (sliding puzzle) çerçevesinde yer değiştiren kareler.

```html
<div class="sutol-oyu06-root">
  <svg class="sutol-oyu06-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <rect x="20" y="20" width="160" height="160" rx="6" fill="none" stroke="#495057" stroke-width="4"/>
    <rect x="30" y="30" width="65" height="65" rx="4" fill="#5C7CFA"/>
    <rect x="105" y="30" width="65" height="65" rx="4" fill="#20C997"/>
    <rect class="sutol-oyu06-slide" x="30" y="105" width="65" height="65" rx="4" fill="#FAB005"/>
  </svg>
</div>
<style>
  .sutol-oyu06-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu06-svg{width:100%;height:100%;display:block;}
  .sutol-oyu06-slide{animation:sutol-oyu06-move 3.6s ease-in-out infinite;}
  @keyframes sutol-oyu06-move{
    0%,20%{transform:translate(0,0);}
    50%,70%{transform:translate(75px,0);}
    100%{transform:translate(0,0);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu06-slide{animation-duration:12s;}
  }
</style>
```

---

## Bileşen 7: Çevrilen Oyun Kartı

**Etiketler (keyword eşleşmesi için):** oyun kartı
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Arka yüzünden ön yüzüne doğru sürekli çevrilen bir oyun kartı.

```html
<div class="sutol-oyu07-root">
  <svg class="sutol-oyu07-svg" viewBox="0 0 140 200" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-oyu07-card" style="transform-origin:70px 100px;">
      <rect x="20" y="20" width="100" height="160" rx="10" fill="#7048E8"/>
      <rect x="35" y="35" width="70" height="130" rx="6" fill="none" stroke="#B197FC" stroke-width="3"/>
      <circle cx="70" cy="100" r="18" fill="#B197FC"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu07-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu07-svg{width:100%;height:100%;display:block;}
  .sutol-oyu07-card{animation:sutol-oyu07-flip 3.4s ease-in-out infinite;}
  @keyframes sutol-oyu07-flip{
    0%,40%{transform:scaleX(1);}
    50%{transform:scaleX(0.05);}
    60%,100%{transform:scaleX(1);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu07-card{animation-duration:12s;}
  }
</style>
```

---

## Bileşen 8: Karıştırılan Kart Destesi

**Etiketler (keyword eşleşmesi için):** oyun kartı
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Yelpaze gibi açılıp kapanan bir oyun kartı destesi.

```html
<div class="sutol-oyu08-root">
  <svg class="sutol-oyu08-svg" viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-oyu08-fan" style="transform-origin:100px 140px;">
      <rect class="sutol-oyu08-card sutol-oyu08-c1" x="80" y="40" width="40" height="60" rx="6" fill="#E03131"/>
      <rect class="sutol-oyu08-card sutol-oyu08-c2" x="80" y="40" width="40" height="60" rx="6" fill="#1971C2"/>
      <rect class="sutol-oyu08-card sutol-oyu08-c3" x="80" y="40" width="40" height="60" rx="6" fill="#2F9E44"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu08-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu08-svg{width:100%;height:100%;display:block;}
  .sutol-oyu08-card{transform-box:fill-box;transform-origin:bottom center;animation:sutol-oyu08-spread 3.2s ease-in-out infinite;}
  .sutol-oyu08-c1{animation-name:sutol-oyu08-spread-l;}
  .sutol-oyu08-c3{animation-name:sutol-oyu08-spread-r;}
  @keyframes sutol-oyu08-spread{
    0%,100%{transform:rotate(0deg);}
    50%{transform:rotate(0deg);}
  }
  @keyframes sutol-oyu08-spread-l{
    0%,100%{transform:rotate(0deg);}
    50%{transform:rotate(-22deg);}
  }
  @keyframes sutol-oyu08-spread-r{
    0%,100%{transform:rotate(0deg);}
    50%{transform:rotate(22deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu08-card{animation-duration:10s;}
  }
</style>
```

---

## Bileşen 9: Dairesel Hareket Eden Joystick

**Etiketler (keyword eşleşmesi için):** joystick
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Tabanı sabit kalan bir oyun kolunun ucunun dairesel hareket etmesi.

```html
<div class="sutol-oyu09-root">
  <svg class="sutol-oyu09-svg" viewBox="0 0 160 160" preserveAspectRatio="xMidYMid meet">
    <rect x="30" y="110" width="100" height="30" rx="10" fill="#343A40"/>
    <g class="sutol-oyu09-stick">
      <line x1="80" y1="120" x2="80" y2="70" stroke="#495057" stroke-width="8" stroke-linecap="round"/>
      <circle cx="80" cy="60" r="16" fill="#FA5252"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu09-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu09-svg{width:100%;height:100%;display:block;}
  .sutol-oyu09-stick{transform-origin:80px 120px;animation:sutol-oyu09-circle 2.8s linear infinite;}
  @keyframes sutol-oyu09-circle{
    0%{transform:rotate(0deg) translateX(0);}
    25%{transform:rotate(0deg) translate(10px,0);}
    50%{transform:rotate(0deg) translate(0,10px);}
    75%{transform:rotate(0deg) translate(-10px,0);}
    100%{transform:rotate(0deg) translate(0,0);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu09-stick{animation-duration:10s;}
  }
</style>
```

---

## Bileşen 10: Işıklanan Joystick Düğmesi

**Etiketler (keyword eşleşmesi için):** joystick
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Basılıyormuş gibi ritmik olarak parlayan bir oyun kolu aksiyon düğmesi.

```html
<div class="sutol-oyu10-root">
  <svg class="sutol-oyu10-svg" viewBox="0 0 160 100" preserveAspectRatio="xMidYMid meet">
    <rect x="10" y="30" width="140" height="50" rx="25" fill="#343A40"/>
    <circle class="sutol-oyu10-btn sutol-oyu10-b1" cx="110" cy="45" r="12" fill="#37B24D"/>
    <circle class="sutol-oyu10-btn sutol-oyu10-b2" cx="130" cy="65" r="12" fill="#E03131"/>
  </svg>
</div>
<style>
  .sutol-oyu10-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu10-svg{width:100%;height:100%;display:block;}
  .sutol-oyu10-btn{animation:sutol-oyu10-press 1.4s ease-in-out infinite;}
  .sutol-oyu10-b2{animation-delay:0.7s;}
  @keyframes sutol-oyu10-press{
    0%,100%{transform:scale(1);filter:brightness(1);}
    50%{transform:scale(0.85);filter:brightness(1.4);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu10-btn{animation-duration:6s;}
  }
</style>
```

---

## Bileşen 11: Yükselen Puan Çubukları

**Etiketler (keyword eşleşmesi için):** puan tablosu
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Bir puan tablosunu simgeleyen, farklı yüksekliklerde sürekli değişen skor çubukları.

```html
<div class="sutol-oyu11-root">
  <svg class="sutol-oyu11-svg" viewBox="0 0 220 140" preserveAspectRatio="xMidYMid meet">
    <line x1="10" y1="130" x2="210" y2="130" stroke="#495057" stroke-width="2"/>
    <rect class="sutol-oyu11-bar sutol-oyu11-b1" x="30" y="70" width="30" height="60" fill="#4C6EF5"/>
    <rect class="sutol-oyu11-bar sutol-oyu11-b2" x="95" y="40" width="30" height="90" fill="#20C997"/>
    <rect class="sutol-oyu11-bar sutol-oyu11-b3" x="160" y="90" width="30" height="40" fill="#FAB005"/>
  </svg>
</div>
<style>
  .sutol-oyu11-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu11-svg{width:100%;height:100%;display:block;}
  .sutol-oyu11-bar{transform-box:fill-box;transform-origin:bottom center;animation:sutol-oyu11-grow 3.6s ease-in-out infinite;}
  .sutol-oyu11-b2{animation-delay:0.4s;}
  .sutol-oyu11-b3{animation-delay:0.8s;}
  @keyframes sutol-oyu11-grow{
    0%,100%{transform:scaleY(0.6);}
    50%{transform:scaleY(1.15);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu11-bar{animation-duration:12s;}
  }
</style>
```

---

## Bileşen 12: Açılan Ödül Kutusu

**Etiketler (keyword eşleşmesi için):** ödül kutusu
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Kapağı açılırken içinden parıltı yayılan bir ödül/hediye sandığı.

```html
<div class="sutol-oyu12-root">
  <svg class="sutol-oyu12-svg" viewBox="0 0 180 160" preserveAspectRatio="xMidYMid meet">
    <rect x="30" y="80" width="120" height="70" rx="6" fill="#F59F00"/>
    <rect x="30" y="80" width="120" height="16" fill="#E8590C"/>
    <g class="sutol-oyu12-lid" style="transform-origin:30px 80px;">
      <path d="M30,80 L150,80 L140,55 L40,55 Z" fill="#FFD43B"/>
    </g>
    <g class="sutol-oyu12-glow">
      <circle cx="90" cy="70" r="6" fill="#FFF3BF"/>
      <circle cx="70" cy="60" r="4" fill="#FFF3BF"/>
      <circle cx="110" cy="60" r="4" fill="#FFF3BF"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu12-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu12-svg{width:100%;height:100%;display:block;}
  .sutol-oyu12-lid{animation:sutol-oyu12-open 4s ease-in-out infinite;}
  .sutol-oyu12-glow{opacity:0;animation:sutol-oyu12-shine 4s ease-in-out infinite;}
  @keyframes sutol-oyu12-open{
    0%,15%{transform:rotate(0deg);}
    45%,65%{transform:rotate(-45deg) translate(-15px,-10px);}
    100%{transform:rotate(0deg);}
  }
  @keyframes sutol-oyu12-shine{
    0%,40%{opacity:0;transform:scale(0.5);}
    55%,70%{opacity:1;transform:scale(1.3);}
    100%{opacity:0;transform:scale(0.5);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu12-lid,.sutol-oyu12-glow{animation-duration:14s;}
  }
</style>
```

---

## Bileşen 13: Parlayan Ödül Kupası

**Etiketler (keyword eşleşmesi için):** ödül kutusu, puan tablosu
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Zafer/başarıyı simgeleyen, üzerinde ışıltı beliren bir kupa.

```html
<div class="sutol-oyu13-root">
  <svg class="sutol-oyu13-svg" viewBox="0 0 160 200" preserveAspectRatio="xMidYMid meet">
    <rect x="65" y="160" width="30" height="20" rx="4" fill="#495057"/>
    <rect x="50" y="176" width="60" height="12" rx="4" fill="#343A40"/>
    <path d="M55,60 L105,60 L98,130 L62,130 Z" fill="#FFD43B"/>
    <path d="M55,65 C 30,65 25,95 55,105" fill="none" stroke="#FFD43B" stroke-width="8"/>
    <path d="M105,65 C 130,65 135,95 105,105" fill="none" stroke="#FFD43B" stroke-width="8"/>
    <g class="sutol-oyu13-sparkle">
      <line x1="120" y1="45" x2="120" y2="58" stroke="#FFF3BF" stroke-width="3" stroke-linecap="round"/>
      <line x1="113" y1="51.5" x2="127" y2="51.5" stroke="#FFF3BF" stroke-width="3" stroke-linecap="round"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu13-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu13-svg{width:100%;height:100%;display:block;}
  .sutol-oyu13-sparkle{transform-box:fill-box;transform-origin:center;animation:sutol-oyu13-twinkle 2s ease-in-out infinite;}
  @keyframes sutol-oyu13-twinkle{
    0%,100%{opacity:0.2;transform:scale(0.6) rotate(0deg);}
    50%{opacity:1;transform:scale(1.3) rotate(30deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu13-sparkle{animation-duration:8s;}
  }
</style>
```

---

## Bileşen 14: Labirentte İlerleyen Nokta

**Etiketler (keyword eşleşmesi için):** labirent oyunu
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Bir labirent yolunu takip ederek girişten çıkışa ilerleyen bir işaretçi noktası.

```html
<div class="sutol-oyu14-root">
  <svg class="sutol-oyu14-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <g fill="none" stroke="#495057" stroke-width="6" stroke-linecap="square">
      <path d="M10,10 H190 V190 H10 V60 H150 V150 H60 V90 H110"/>
    </g>
    <circle class="sutol-oyu14-marker" r="8" fill="#FA5252"/>
  </svg>
</div>
<style>
  .sutol-oyu14-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu14-svg{width:100%;height:100%;display:block;}
  .sutol-oyu14-marker{offset-path:path("M10,10 H190 V190 H10 V60 H150 V150 H60 V90 H110");animation:sutol-oyu14-travel 6s linear infinite;}
  @keyframes sutol-oyu14-travel{
    0%{offset-distance:0%;}
    100%{offset-distance:100%;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu14-marker{animation-duration:20s;}
  }
</style>
```

---

## Bileşen 15: Değişen Labirent Duvarları

**Etiketler (keyword eşleşmesi için):** labirent oyunu
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Bir labirentin bazı duvar parçalarının belirip kaybolarak dinamik bir yapı oluşturması.

```html
<div class="sutol-oyu15-root">
  <svg class="sutol-oyu15-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <g fill="none" stroke="#868E96" stroke-width="5">
      <rect x="10" y="10" width="180" height="180"/>
      <line x1="60" y1="10" x2="60" y2="80"/>
      <line x1="140" y1="120" x2="140" y2="190"/>
    </g>
    <g class="sutol-oyu15-wall sutol-oyu15-w1" stroke="#5C7CFA" stroke-width="5">
      <line x1="60" y1="120" x2="60" y2="190"/>
    </g>
    <g class="sutol-oyu15-wall sutol-oyu15-w2" stroke="#5C7CFA" stroke-width="5">
      <line x1="140" y1="10" x2="140" y2="80"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu15-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu15-svg{width:100%;height:100%;display:block;}
  .sutol-oyu15-wall{opacity:0;animation:sutol-oyu15-shift 4s ease-in-out infinite;}
  .sutol-oyu15-w2{animation-delay:2s;}
  @keyframes sutol-oyu15-shift{
    0%,40%{opacity:0;}
    50%,90%{opacity:1;}
    100%{opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu15-wall{animation-duration:14s;}
  }
</style>
```

---

## Bileşen 16: Birleşen Yapboz Parçaları

**Etiketler (keyword eşleşmesi için):** yapboz
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Dört köşeden gelip merkezde birleşerek bütün bir resim oluşturan yapboz parçaları.

```html
<div class="sutol-oyu16-root">
  <svg class="sutol-oyu16-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <rect class="sutol-oyu16-piece sutol-oyu16-p1" width="70" height="70" fill="#4C6EF5" rx="6"/>
    <rect class="sutol-oyu16-piece sutol-oyu16-p2" width="70" height="70" fill="#20C997" rx="6"/>
    <rect class="sutol-oyu16-piece sutol-oyu16-p3" width="70" height="70" fill="#FAB005" rx="6"/>
    <rect class="sutol-oyu16-piece sutol-oyu16-p4" width="70" height="70" fill="#FA5252" rx="6"/>
  </svg>
</div>
<style>
  .sutol-oyu16-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu16-svg{width:100%;height:100%;display:block;}
  .sutol-oyu16-piece{animation-duration:4.5s;animation-iteration-count:infinite;animation-timing-function:ease-in-out;}
  .sutol-oyu16-p1{animation-name:sutol-oyu16-tl;}
  .sutol-oyu16-p2{animation-name:sutol-oyu16-tr;}
  .sutol-oyu16-p3{animation-name:sutol-oyu16-bl;}
  .sutol-oyu16-p4{animation-name:sutol-oyu16-br;}
  @keyframes sutol-oyu16-tl{
    0%{transform:translate(0,0);}
    40%,70%{transform:translate(64px,64px);}
    100%{transform:translate(0,0);}
  }
  @keyframes sutol-oyu16-tr{
    0%{transform:translate(200px,0);}
    40%,70%{transform:translate(136px,64px);}
    100%{transform:translate(200px,0);}
  }
  @keyframes sutol-oyu16-bl{
    0%{transform:translate(0,200px);}
    40%,70%{transform:translate(64px,136px);}
    100%{transform:translate(0,200px);}
  }
  @keyframes sutol-oyu16-br{
    0%{transform:translate(200px,200px);}
    40%,70%{transform:translate(136px,136px);}
    100%{transform:translate(200px,200px);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu16-piece{animation-duration:14s;}
  }
</style>
```

---

## Bileşen 17: Macera Haritasında İlerleyen Pusula

**Etiketler (keyword eşleşmesi için):** macera haritası
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Eski bir macera haritası üzerinde noktalı bir rota boyunca ilerleyen bir pusula işareti.

```html
<div class="sutol-oyu17-root">
  <svg class="sutol-oyu17-svg" viewBox="0 0 260 160" preserveAspectRatio="xMidYMid meet">
    <rect x="10" y="10" width="240" height="140" rx="8" fill="#F5E6C8" opacity="0.5"/>
    <path d="M30,120 Q100,40 150,90 T230,40" fill="none" stroke="#8B5A2B" stroke-width="2" stroke-dasharray="6 6"/>
    <circle cx="30" cy="120" r="6" fill="#2F9E44"/>
    <path d="M225,30 L235,40 L225,50 L215,40 Z" fill="#E8590C"/>
    <g class="sutol-oyu17-compass">
      <circle r="9" fill="#495057"/>
      <path d="M0,-9 L3,0 L0,9 L-3,0 Z" fill="#FA5252"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu17-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu17-svg{width:100%;height:100%;display:block;}
  .sutol-oyu17-compass{offset-path:path("M30,120 Q100,40 150,90 T230,40");animation:sutol-oyu17-travel 6s ease-in-out infinite;}
  @keyframes sutol-oyu17-travel{
    0%{offset-distance:0%;opacity:0;}
    10%{opacity:1;}
    90%{opacity:1;}
    100%{offset-distance:100%;opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu17-compass{animation-duration:18s;}
  }
</style>
```

---

## Bileşen 18: E-spor Arenası Ekran Parıltısı

**Etiketler (keyword eşleşmesi için):** e-spor arenası
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Bir e-spor arenasındaki dev ekranın nabız gibi parlayıp sönmesi.

```html
<div class="sutol-oyu18-root">
  <svg class="sutol-oyu18-svg" viewBox="0 0 260 160" preserveAspectRatio="xMidYMid meet">
    <rect x="20" y="20" width="220" height="120" rx="6" fill="#212529"/>
    <rect class="sutol-oyu18-glow" x="30" y="30" width="200" height="100" rx="4" fill="#5C7CFA"/>
    <rect x="115" y="140" width="30" height="16" fill="#495057"/>
  </svg>
</div>
<style>
  .sutol-oyu18-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu18-svg{width:100%;height:100%;display:block;}
  .sutol-oyu18-glow{animation:sutol-oyu18-pulse 2s ease-in-out infinite;}
  @keyframes sutol-oyu18-pulse{
    0%,100%{fill:#4C6EF5;opacity:0.7;}
    50%{fill:#748FFC;opacity:1;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu18-glow{animation-duration:8s;}
  }
</style>
```

---

## Bileşen 19: E-spor Arenası Kalabalık Dalgası

**Etiketler (keyword eşleşmesi için):** e-spor arenası
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Bir arenadaki seyirci koltuklarının dalga gibi sırayla yükselip alçalması.

```html
<div class="sutol-oyu19-root">
  <svg class="sutol-oyu19-svg" viewBox="0 0 260 80" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-oyu19-seats" fill="#748FFC">
      <circle class="sutol-oyu19-s" cx="20" cy="50" r="10"/>
      <circle class="sutol-oyu19-s" cx="55" cy="50" r="10"/>
      <circle class="sutol-oyu19-s" cx="90" cy="50" r="10"/>
      <circle class="sutol-oyu19-s" cx="125" cy="50" r="10"/>
      <circle class="sutol-oyu19-s" cx="160" cy="50" r="10"/>
      <circle class="sutol-oyu19-s" cx="195" cy="50" r="10"/>
      <circle class="sutol-oyu19-s" cx="230" cy="50" r="10"/>
    </g>
  </svg>
</div>
<style>
  .sutol-oyu19-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu19-svg{width:100%;height:100%;display:block;}
  .sutol-oyu19-s{transform-box:fill-box;transform-origin:center;animation:sutol-oyu19-wave 1.6s ease-in-out infinite;}
  .sutol-oyu19-s:nth-child(1){animation-delay:0s;}
  .sutol-oyu19-s:nth-child(2){animation-delay:0.1s;}
  .sutol-oyu19-s:nth-child(3){animation-delay:0.2s;}
  .sutol-oyu19-s:nth-child(4){animation-delay:0.3s;}
  .sutol-oyu19-s:nth-child(5){animation-delay:0.4s;}
  .sutol-oyu19-s:nth-child(6){animation-delay:0.5s;}
  .sutol-oyu19-s:nth-child(7){animation-delay:0.6s;}
  @keyframes sutol-oyu19-wave{
    0%,100%{transform:translateY(0);}
    50%{transform:translateY(-14px);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu19-s{animation-duration:6s;}
  }
</style>
```

---

## Bileşen 20: Parıldayan Sanal Gerçeklik Gözlüğü

**Etiketler (keyword eşleşmesi için):** sanal gerçeklik gözlüğü
**Kategori:** Oyun & Eğlence Dünyası
**Açıklama:** Lensleri sırayla parıldayan, dijital bir deneyimi simgeleyen bir VR gözlük.

```html
<div class="sutol-oyu20-root">
  <svg class="sutol-oyu20-svg" viewBox="0 0 220 120" preserveAspectRatio="xMidYMid meet">
    <rect x="20" y="30" width="180" height="70" rx="30" fill="#343A40"/>
    <line x1="10" y1="55" x2="20" y2="55" stroke="#495057" stroke-width="8" stroke-linecap="round"/>
    <line x1="200" y1="55" x2="210" y2="55" stroke="#495057" stroke-width="8" stroke-linecap="round"/>
    <circle class="sutol-oyu20-lens sutol-oyu20-l1" cx="75" cy="65" r="26" fill="#4DABF7"/>
    <circle class="sutol-oyu20-lens sutol-oyu20-l2" cx="145" cy="65" r="26" fill="#4DABF7"/>
  </svg>
</div>
<style>
  .sutol-oyu20-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-oyu20-svg{width:100%;height:100%;display:block;}
  .sutol-oyu20-lens{animation:sutol-oyu20-glow 2.4s ease-in-out infinite;}
  .sutol-oyu20-l2{animation-delay:1.2s;}
  @keyframes sutol-oyu20-glow{
    0%,100%{fill:#4DABF7;opacity:0.6;}
    50%{fill:#99E9F2;opacity:1;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-oyu20-lens{animation-duration:9s;}
  }
</style>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Yuvarlanan Zar): SVG grup `rotate+scale` yuvarlanma animasyonu.
- Bileşen 2 (Sıçrayan Çift Zar): SVG grup `translate+rotate` sekerek düşme animasyonu, iki bağımsız zar.
- Bileşen 3 (Hareket Eden Satranç Taşı): SVG grup `translate` kareden kareye ilerleme.
- Bileşen 4 (Dizilen Satranç Piyonları): SVG `opacity+translateY+scale` sıralı beliren taşlar.
- Bileşen 5 (Bulmaca Parçası Yerleşimi): SVG grup `translate+rotate+opacity` yerine oturma animasyonu.
- Bileşen 6 (Kayan Bulmaca Parçaları): SVG `translateX` kayar bulmaca hareketi.
- Bileşen 7 (Çevrilen Oyun Kartı): SVG grup `scaleX` kart çevirme illüzyonu.
- Bileşen 8 (Karıştırılan Kart Destesi): SVG çoklu grup `rotate` yelpaze açılma/kapanma.
- Bileşen 9 (Dairesel Joystick): CSS `transform:translate` dairesel hareket illüzyonu.
- Bileşen 10 (Joystick Düğmesi): SVG `scale+brightness filter` basma/parlama animasyonu.
- Bileşen 11 (Puan Çubukları): SVG `scaleY` gecikmeli yükselen skor çubukları.
- Bileşen 12 (Ödül Kutusu): SVG grup `rotate+translate` kapak açma + `opacity/scale` parıltı.
- Bileşen 13 (Ödül Kupası): SVG `scale+rotate+opacity` ışıltı animasyonu.
- Bileşen 14 (Labirent Yol Takibi): SVG `offset-path` CSS motion-path ile yol boyunca ilerleme.
- Bileşen 15 (Değişen Labirent Duvarları): SVG `opacity` beliren/kaybolan duvar parçaları.
- Bileşen 16 (Birleşen Yapboz Parçaları): SVG 4 bağımsız grup `translate` merkeze toplanma animasyonu.
- Bileşen 17 (Macera Haritası Pusulası): SVG `offset-path` yay boyunca ilerleyen pusula işareti.
- Bileşen 18 (E-spor Ekran Parıltısı): SVG `fill/opacity` nabız animasyonu.
- Bileşen 19 (E-spor Kalabalık Dalgası): SVG `translateY` gecikmeli dalga animasyonu, 7 koltuk.
- Bileşen 20 (VR Gözlük): SVG `fill/opacity` gecikmeli lens parıltısı.

Genel notlar: Tüm bileşenler `transparent` kök arka plana sahiptir, dış kaynak/CDN/font/API kullanılmamıştır, tüm CSS sınıfları `sutol-oyuXX-` önekiyle kapsüllenmiştir, sabit metin/rakam içermezler (skor gösterimleri rakam yerine çubuk grafiklerle temsil edilmiştir) ve her biri `prefers-reduced-motion: reduce` sorgusunda animasyon süresini belirgin şekilde uzatarak hareketi azaltır.
