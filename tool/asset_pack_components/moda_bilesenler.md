# Sutol — Moda & Stil Kategorisi Bileşen Kütüphanesi (20 Bileşen)

Kategori: **Moda & Stil**
Anahtar kelime havuzu: kumaş, dikiş, terzi, moda podyumu, aksesuar, defile, tekstil deseni, renk paleti, sezon koleksiyonu, ayakkabı tasarımı, takı, kürk, iplik, dokuma tezgahı, stil ikonu, vitrin, mankeni, moda haftası, sürdürülebilir moda

---

## Bileşen 1: Dalgalanan Kumaş

**Etiketler (keyword eşleşmesi için):** kumaş, tekstil deseni
**Kategori:** Moda & Stil
**Açıklama:** Rüzgarda hafifçe dalgalanan, akıcı bir kumaş parçasının kıvrımları.

```html
<div class="sutol-mod01-root">
  <svg class="sutol-mod01-svg" viewBox="0 0 300 160" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-mod01-fabric" d="M20,60 Q80,20 140,60 T260,60 L260,140 Q200,110 140,140 T20,140 Z" fill="#E64980" opacity="0.85"/>
  </svg>
</div>
<style>
  .sutol-mod01-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod01-svg{width:100%;height:100%;display:block;}
  .sutol-mod01-fabric{animation:sutol-mod01-wave 4s ease-in-out infinite;}
  @keyframes sutol-mod01-wave{
    0%,100%{d:path("M20,60 Q80,20 140,60 T260,60 L260,140 Q200,110 140,140 T20,140 Z");}
    50%{d:path("M20,70 Q80,100 140,70 T260,70 L260,150 Q200,130 140,150 T20,150 Z");}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod01-fabric{animation-duration:14s;}
  }
</style>
```

---

## Bileşen 2: İğne İplik Dikişi

**Etiketler (keyword eşleşmesi için):** dikiş, iplik
**Kategori:** Moda & Stil
**Açıklama:** Bir kumaş üzerinde ileri geri hareket ederek dikiş izi bırakan bir iğne.

```html
<div class="sutol-mod02-root">
  <svg class="sutol-mod02-svg" viewBox="0 0 300 100" preserveAspectRatio="xMidYMid meet">
    <line x1="20" y1="60" x2="280" y2="60" stroke="#495057" stroke-width="1" stroke-dasharray="10 8" opacity="0.5"/>
    <path class="sutol-mod02-stitch" d="M20,60 L280,60" stroke="#F06595" stroke-width="3" stroke-dasharray="10 8" fill="none" stroke-dashoffset="0"/>
    <g class="sutol-mod02-needle">
      <line x1="0" y1="30" x2="0" y2="90" stroke="#ADB5BD" stroke-width="3" stroke-linecap="round"/>
      <ellipse cx="0" cy="30" rx="3" ry="6" fill="none" stroke="#ADB5BD" stroke-width="2"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod02-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod02-svg{width:100%;height:100%;display:block;}
  .sutol-mod02-stitch{animation:sutol-mod02-sew 3s linear infinite;}
  .sutol-mod02-needle{animation:sutol-mod02-move 3s ease-in-out infinite;}
  @keyframes sutol-mod02-sew{
    0%{stroke-dashoffset:260;}
    100%{stroke-dashoffset:0;}
  }
  @keyframes sutol-mod02-move{
    0%{transform:translate(20px,0) rotate(-10deg);}
    50%{transform:translate(150px,20px) rotate(10deg);}
    100%{transform:translate(280px,0) rotate(-10deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod02-stitch,.sutol-mod02-needle{animation-duration:10s;}
  }
</style>
```

---

## Bileşen 3: Sarılan Terzi Mezurası

**Etiketler (keyword eşleşmesi için):** terzi, dikiş
**Kategori:** Moda & Stil
**Açıklama:** Bir terzi mezurasının hafifçe sallanarak ölçüm alıyormuş hissi vermesi.

```html
<div class="sutol-mod03-root">
  <svg class="sutol-mod03-svg" viewBox="0 0 220 140" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-mod03-tape" style="transform-origin:40px 40px;">
      <path d="M40,40 Q120,20 180,80 Q140,90 100,110" fill="none" stroke="#FFD8A8" stroke-width="14" stroke-linecap="round"/>
      <g stroke="#495057" stroke-width="2">
        <line x1="55" y1="34" x2="55" y2="44"/>
        <line x1="80" y1="27" x2="80" y2="37"/>
        <line x1="110" y1="26" x2="110" y2="36"/>
        <line x1="140" y1="35" x2="140" y2="45"/>
        <line x1="160" y1="55" x2="168" y2="62"/>
      </g>
    </g>
  </svg>
</div>
<style>
  .sutol-mod03-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod03-svg{width:100%;height:100%;display:block;}
  .sutol-mod03-tape{animation:sutol-mod03-sway 3.6s ease-in-out infinite;}
  @keyframes sutol-mod03-sway{
    0%,100%{transform:rotate(-4deg);}
    50%{transform:rotate(4deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod03-tape{animation-duration:12s;}
  }
</style>
```

---

## Bileşen 4: Podyumda Yürüyen Silüet

**Etiketler (keyword eşleşmesi için):** moda podyumu, defile
**Kategori:** Moda & Stil
**Açıklama:** Bir podyum hattı boyunca soldan sağa süzülerek ilerleyen soyut bir model silüeti.

```html
<div class="sutol-mod04-root">
  <svg class="sutol-mod04-svg" viewBox="0 0 300 160" preserveAspectRatio="xMidYMid meet">
    <rect x="10" y="130" width="280" height="8" fill="#DEE2E6"/>
    <g class="sutol-mod04-figure">
      <circle cx="0" cy="30" r="10" fill="#212529"/>
      <path d="M-14,45 C -14,80 -10,100 0,130 C 10,100 14,80 14,45 Z" fill="#212529"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod04-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod04-svg{width:100%;height:100%;display:block;}
  .sutol-mod04-figure{animation:sutol-mod04-walk 5s ease-in-out infinite;}
  @keyframes sutol-mod04-walk{
    0%{transform:translateX(20px);opacity:0;}
    10%{opacity:1;}
    90%{opacity:1;}
    100%{transform:translateX(270px);opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod04-figure{animation-duration:16s;}
  }
</style>
```

---

## Bileşen 5: Dönen Aksesuar Kolyesi

**Etiketler (keyword eşleşmesi için):** aksesuar, takı
**Kategori:** Moda & Stil
**Açıklama:** Kendi ekseninde yavaşça dönen, ışıltılı boncuklardan oluşan bir kolye.

```html
<div class="sutol-mod05-root">
  <svg class="sutol-mod05-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-mod05-necklace" style="transform-origin:100px 100px;">
      <path d="M50,60 Q100,140 150,60" fill="none" stroke="#FFD43B" stroke-width="4"/>
      <circle cx="60" cy="70" r="7" fill="#FFD43B"/>
      <circle cx="80" cy="105" r="7" fill="#F6AD55"/>
      <circle cx="100" cy="118" r="9" fill="#FA5252"/>
      <circle cx="120" cy="105" r="7" fill="#F6AD55"/>
      <circle cx="140" cy="70" r="7" fill="#FFD43B"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod05-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod05-svg{width:100%;height:100%;display:block;}
  .sutol-mod05-necklace{animation:sutol-mod05-spin 6s ease-in-out infinite;}
  @keyframes sutol-mod05-spin{
    0%,100%{transform:rotateY(0deg) scaleX(1);}
    50%{transform:scaleX(0.85);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod05-necklace{animation-duration:16s;}
  }
</style>
```

---

## Bileşen 6: Defile Podyum Işıkları

**Etiketler (keyword eşleşmesi için):** defile, moda podyumu
**Kategori:** Moda & Stil
**Açıklama:** Bir podyumu aydınlatarak sağa sola tarayan iki spot ışığı hüzmesi.

```html
<div class="sutol-mod06-root">
  <svg class="sutol-mod06-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet">
    <rect x="20" y="170" width="260" height="10" fill="#343A40"/>
    <g class="sutol-mod06-beam sutol-mod06-a">
      <polygon points="90,0 150,0 200,170 40,170" fill="#FFF3BF" opacity="0.3"/>
    </g>
    <g class="sutol-mod06-beam sutol-mod06-b">
      <polygon points="150,0 210,0 260,170 100,170" fill="#FFC9DE" opacity="0.28"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod06-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod06-svg{width:100%;height:100%;display:block;}
  .sutol-mod06-beam{transform-origin:150px 0px;animation:sutol-mod06-sweep 5s ease-in-out infinite;}
  .sutol-mod06-b{animation-duration:6.2s;animation-direction:reverse;}
  @keyframes sutol-mod06-sweep{
    0%,100%{transform:rotate(-14deg);}
    50%{transform:rotate(14deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod06-beam{animation-duration:16s;}
  }
</style>
```

---

## Bileşen 7: Kayan Tekstil Deseni

**Etiketler (keyword eşleşmesi için):** tekstil deseni, renk paleti
**Kategori:** Moda & Stil
**Açıklama:** Sürekli kayan, tekrar eden geometrik bir tekstil desen dokusu.

```html
<div class="sutol-mod07-root">
  <svg class="sutol-mod07-svg" viewBox="0 0 240 120" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-mod07-pattern">
      <g fill="#5F3DC4">
        <circle cx="10" cy="10" r="6"/><circle cx="50" cy="10" r="6"/><circle cx="90" cy="10" r="6"/><circle cx="130" cy="10" r="6"/><circle cx="170" cy="10" r="6"/><circle cx="210" cy="10" r="6"/><circle cx="250" cy="10" r="6"/>
        <circle cx="30" cy="40" r="6"/><circle cx="70" cy="40" r="6"/><circle cx="110" cy="40" r="6"/><circle cx="150" cy="40" r="6"/><circle cx="190" cy="40" r="6"/><circle cx="230" cy="40" r="6"/>
        <circle cx="10" cy="70" r="6"/><circle cx="50" cy="70" r="6"/><circle cx="90" cy="70" r="6"/><circle cx="130" cy="70" r="6"/><circle cx="170" cy="70" r="6"/><circle cx="210" cy="70" r="6"/><circle cx="250" cy="70" r="6"/>
        <circle cx="30" cy="100" r="6"/><circle cx="70" cy="100" r="6"/><circle cx="110" cy="100" r="6"/><circle cx="150" cy="100" r="6"/><circle cx="190" cy="100" r="6"/><circle cx="230" cy="100" r="6"/>
      </g>
    </g>
  </svg>
</div>
<style>
  .sutol-mod07-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod07-svg{width:100%;height:100%;display:block;}
  .sutol-mod07-pattern{animation:sutol-mod07-slide 6s linear infinite;}
  @keyframes sutol-mod07-slide{
    0%{transform:translateX(0);}
    100%{transform:translateX(-40px);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod07-pattern{animation-duration:20s;}
  }
</style>
```

---

## Bileşen 8: Döngüsel Renk Paleti

**Etiketler (keyword eşleşmesi için):** renk paleti, sezon koleksiyonu
**Kategori:** Moda & Stil
**Açıklama:** Sırayla büyüyüp küçülen, bir moda koleksiyonu renk paletini temsil eden renkli daireler.

```html
<div class="sutol-mod08-root">
  <svg class="sutol-mod08-svg" viewBox="0 0 260 100" preserveAspectRatio="xMidYMid meet">
    <circle class="sutol-mod08-c sutol-mod08-c1" cx="40" cy="50" r="24" fill="#F06595"/>
    <circle class="sutol-mod08-c sutol-mod08-c2" cx="100" cy="50" r="24" fill="#FAB005"/>
    <circle class="sutol-mod08-c sutol-mod08-c3" cx="160" cy="50" r="24" fill="#20C997"/>
    <circle class="sutol-mod08-c sutol-mod08-c4" cx="220" cy="50" r="24" fill="#5C7CFA"/>
  </svg>
</div>
<style>
  .sutol-mod08-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod08-svg{width:100%;height:100%;display:block;}
  .sutol-mod08-c{transform-box:fill-box;transform-origin:center;animation:sutol-mod08-pop 3.2s ease-in-out infinite;}
  .sutol-mod08-c2{animation-delay:0.3s;}
  .sutol-mod08-c3{animation-delay:0.6s;}
  .sutol-mod08-c4{animation-delay:0.9s;}
  @keyframes sutol-mod08-pop{
    0%,100%{transform:scale(0.85);}
    50%{transform:scale(1.15);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod08-c{animation-duration:10s;}
  }
</style>
```

---

## Bileşen 9: Dönen Mevsim Koleksiyonu İkonları

**Etiketler (keyword eşleşmesi için):** sezon koleksiyonu, sürdürülebilir moda
**Kategori:** Moda & Stil
**Açıklama:** Yaprak, güneş, kar tanesi ve çiçek simgelerinin sırayla belirip kaybolarak mevsim koleksiyonlarını temsil etmesi.

```html
<div class="sutol-mod09-root">
  <svg class="sutol-mod09-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-mod09-icon sutol-mod09-spring" fill="#F783AC">
      <circle cx="100" cy="80" r="10"/>
      <circle cx="80" cy="100" r="10"/>
      <circle cx="120" cy="100" r="10"/>
      <circle cx="100" cy="120" r="10"/>
    </g>
    <g class="sutol-mod09-icon sutol-mod09-summer" fill="#FAB005">
      <circle cx="100" cy="100" r="18"/>
    </g>
    <g class="sutol-mod09-icon sutol-mod09-autumn" fill="#E8590C">
      <path d="M100,70 C 120,80 125,110 100,130 C 75,110 80,80 100,70 Z"/>
    </g>
    <g class="sutol-mod09-icon sutol-mod09-winter" stroke="#4DABF7" stroke-width="5" stroke-linecap="round">
      <line x1="100" y1="75" x2="100" y2="125"/>
      <line x1="75" y1="100" x2="125" y2="100"/>
      <line x1="82" y1="82" x2="118" y2="118"/>
      <line x1="118" y1="82" x2="82" y2="118"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod09-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod09-svg{width:100%;height:100%;display:block;}
  .sutol-mod09-icon{transform-box:fill-box;transform-origin:center;opacity:0;animation:sutol-mod09-cycle 8s ease-in-out infinite;}
  .sutol-mod09-summer{animation-delay:2s;}
  .sutol-mod09-autumn{animation-delay:4s;}
  .sutol-mod09-winter{animation-delay:6s;}
  @keyframes sutol-mod09-cycle{
    0%,20%{opacity:0;transform:scale(0.6);}
    25%,45%{opacity:1;transform:scale(1);}
    50%,100%{opacity:0;transform:scale(0.6);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod09-icon{animation-duration:24s;}
  }
</style>
```

---

## Bileşen 10: Ayakkabı Tasarım Taslağı

**Etiketler (keyword eşleşmesi için):** ayakkabı tasarımı, terzi
**Kategori:** Moda & Stil
**Açıklama:** Bir topuklu ayakkabı taslağının çizgi çizgi belirerek tamamlanması.

```html
<div class="sutol-mod10-root">
  <svg class="sutol-mod10-svg" viewBox="0 0 220 140" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-mod10-shoe" d="M20,110 L20,80 Q40,60 70,65 L140,50 Q160,45 170,60 L180,90 Q185,110 165,115 L30,115 Q20,115 20,110 Z"
      fill="none" stroke="#862E9C" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
</div>
<style>
  .sutol-mod10-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod10-svg{width:100%;height:100%;display:block;}
  .sutol-mod10-shoe{stroke-dasharray:520;stroke-dashoffset:520;animation:sutol-mod10-draw 5s ease-in-out infinite;}
  @keyframes sutol-mod10-draw{
    0%{stroke-dashoffset:520;}
    40%,80%{stroke-dashoffset:0;}
    100%{stroke-dashoffset:-520;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod10-shoe{animation-duration:16s;}
  }
</style>
```

---

## Bileşen 11: Parlayan Takı Taşı

**Etiketler (keyword eşleşmesi için):** takı, aksesuar
**Kategori:** Moda & Stil
**Açıklama:** Yüzeyinde ışıltı çizgileri beliren, çok yönlü kesimli bir mücevher taşı.

```html
<div class="sutol-mod11-root">
  <svg class="sutol-mod11-svg" viewBox="0 0 160 160" preserveAspectRatio="xMidYMid meet">
    <polygon points="80,20 120,60 100,130 60,130 40,60" fill="#4DABF7" stroke="#1971C2" stroke-width="2"/>
    <polygon points="80,20 120,60 80,80 40,60" fill="#74C0FC" opacity="0.6"/>
    <g class="sutol-mod11-sparkle">
      <line x1="115" y1="35" x2="115" y2="50" stroke="#FFF3BF" stroke-width="3" stroke-linecap="round"/>
      <line x1="107" y1="43" x2="123" y2="43" stroke="#FFF3BF" stroke-width="3" stroke-linecap="round"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod11-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod11-svg{width:100%;height:100%;display:block;}
  .sutol-mod11-sparkle{transform-box:fill-box;transform-origin:center;animation:sutol-mod11-shine 2.2s ease-in-out infinite;}
  @keyframes sutol-mod11-shine{
    0%,100%{opacity:0.1;transform:scale(0.6) rotate(0deg);}
    50%{opacity:1;transform:scale(1.3) rotate(45deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod11-sparkle{animation-duration:8s;}
  }
</style>
```

---

## Bileşen 12: Dalgalanan Kürk Dokusu

**Etiketler (keyword eşleşmesi için):** kürk, tekstil deseni
**Kategori:** Moda & Stil
**Açıklama:** Yumuşak bir kürk yüzeyini andıran, hafifçe dalgalanan tüy çizgileri.

```html
<div class="sutol-mod12-root">
  <svg class="sutol-mod12-svg" viewBox="0 0 240 100" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-mod12-fur" stroke="#DEB887" stroke-width="4" stroke-linecap="round">
      <path d="M20,80 Q22,50 18,20"/>
      <path d="M45,80 Q48,48 42,18"/>
      <path d="M70,80 Q73,52 68,22"/>
      <path d="M95,80 Q98,50 92,20"/>
      <path d="M120,80 Q123,48 118,18"/>
      <path d="M145,80 Q148,52 142,22"/>
      <path d="M170,80 Q173,50 168,20"/>
      <path d="M195,80 Q198,48 192,18"/>
      <path d="M220,80 Q223,52 218,22"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod12-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod12-svg{width:100%;height:100%;display:block;}
  .sutol-mod12-fur path{transform-box:fill-box;transform-origin:bottom center;animation:sutol-mod12-sway 3s ease-in-out infinite;}
  .sutol-mod12-fur path:nth-child(2n){animation-delay:0.2s;}
  .sutol-mod12-fur path:nth-child(3n){animation-delay:0.4s;}
  @keyframes sutol-mod12-sway{
    0%,100%{transform:rotate(-4deg);}
    50%{transform:rotate(4deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod12-fur path{animation-duration:10s;}
  }
</style>
```

---

## Bileşen 13: Sarılan İplik Makarası

**Etiketler (keyword eşleşmesi için):** iplik, dikiş
**Kategori:** Moda & Stil
**Açıklama:** Kendi ekseninde dönerek iplik saran bir makara ve ondan sarkan uzayan bir iplik ucu.

```html
<div class="sutol-mod13-root">
  <svg class="sutol-mod13-svg" viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet">
    <rect x="70" y="20" width="60" height="14" rx="4" fill="#495057"/>
    <rect x="70" y="106" width="60" height="14" rx="4" fill="#495057"/>
    <g class="sutol-mod13-spool" style="transform-origin:100px 70px;">
      <rect x="80" y="34" width="40" height="72" fill="#F06595"/>
      <line x1="80" y1="50" x2="120" y2="50" stroke="#E64980" stroke-width="2"/>
      <line x1="80" y1="70" x2="120" y2="70" stroke="#E64980" stroke-width="2"/>
      <line x1="80" y1="90" x2="120" y2="90" stroke="#E64980" stroke-width="2"/>
    </g>
    <path class="sutol-mod13-thread" d="M100,120 Q110,135 100,150" fill="none" stroke="#F06595" stroke-width="3" stroke-linecap="round"/>
  </svg>
</div>
<style>
  .sutol-mod13-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod13-svg{width:100%;height:100%;display:block;}
  .sutol-mod13-spool{animation:sutol-mod13-spin 4s linear infinite;}
  .sutol-mod13-thread{animation:sutol-mod13-length 4s ease-in-out infinite;}
  @keyframes sutol-mod13-spin{
    0%{transform:scaleX(1);}
    50%{transform:scaleX(0.9);}
    100%{transform:scaleX(1);}
  }
  @keyframes sutol-mod13-length{
    0%,100%{d:path("M100,120 Q110,135 100,150");}
    50%{d:path("M100,120 Q90,140 105,155");}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod13-spool,.sutol-mod13-thread{animation-duration:12s;}
  }
</style>
```

---

## Bileşen 14: Dokuma Tezgahı Çaprazlaması

**Etiketler (keyword eşleşmesi için):** dokuma tezgahı, kumaş
**Kategori:** Moda & Stil
**Açıklama:** Dikey ve yatay ipliklerin dokuma tezgahında sırayla üst üste geçmesi.

```html
<div class="sutol-mod14-root">
  <svg class="sutol-mod14-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <g stroke="#845EF7" stroke-width="3" opacity="0.5">
      <line x1="30" y1="20" x2="30" y2="180"/>
      <line x1="70" y1="20" x2="70" y2="180"/>
      <line x1="110" y1="20" x2="110" y2="180"/>
      <line x1="150" y1="20" x2="150" y2="180"/>
    </g>
    <g class="sutol-mod14-weft" stroke="#FAB005" stroke-width="5" stroke-linecap="round">
      <line x1="10" y1="60" x2="190" y2="60"/>
      <line x1="10" y1="100" x2="190" y2="100"/>
      <line x1="10" y1="140" x2="190" y2="140"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod14-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod14-svg{width:100%;height:100%;display:block;}
  .sutol-mod14-weft line{transform-box:fill-box;transform-origin:center;animation:sutol-mod14-cross 2.4s ease-in-out infinite;}
  .sutol-mod14-weft line:nth-child(2){animation-delay:0.4s;}
  .sutol-mod14-weft line:nth-child(3){animation-delay:0.8s;}
  @keyframes sutol-mod14-cross{
    0%,100%{transform:translateY(0);}
    50%{transform:translateY(-6px) scaleY(1.4);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod14-weft line{animation-duration:9s;}
  }
</style>
```

---

## Bileşen 15: Parıldayan Stil İkonu

**Etiketler (keyword eşleşmesi için):** stil ikonu, moda haftası
**Kategori:** Moda & Stil
**Açıklama:** Zarif bir siluet figürünün etrafında beliren yıldız/ışıltı parçacıkları.

```html
<div class="sutol-mod15-root">
  <svg class="sutol-mod15-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <circle cx="100" cy="60" r="16" fill="#212529"/>
    <path d="M75,180 C 75,130 85,105 100,105 C 115,105 125,130 125,180 Z" fill="#212529"/>
    <g class="sutol-mod15-star sutol-mod15-s1" fill="#FFD43B">
      <polygon points="0,-8 2,-2 8,0 2,2 0,8 -2,2 -8,0 -2,-2"/>
    </g>
    <g class="sutol-mod15-star sutol-mod15-s2" fill="#FFD43B">
      <polygon points="0,-6 1.5,-1.5 6,0 1.5,1.5 0,6 -1.5,1.5 -6,0 -1.5,-1.5"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod15-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod15-svg{width:100%;height:100%;display:block;}
  .sutol-mod15-star{transform-box:fill-box;transform-origin:center;opacity:0;animation:sutol-mod15-twinkle 3s ease-in-out infinite;}
  .sutol-mod15-s1{transform:translate(140px,60px);}
  .sutol-mod15-s2{transform:translate(55px,90px);animation-delay:1s;}
  @keyframes sutol-mod15-twinkle{
    0%,100%{opacity:0;transform:scale(0.5) translate(140px,60px);}
    50%{opacity:1;transform:scale(1.2) translate(140px,60px);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod15-star{animation-duration:10s;}
  }
</style>
```

---

## Bileşen 16: Dönen Vitrin Sergisi

**Etiketler (keyword eşleşmesi için):** vitrin, moda podyumu
**Kategori:** Moda & Stil
**Açıklama:** Bir mağaza vitrini çerçevesi içinde yavaşça dönen bir kıyafet/aksesuar sergisi.

```html
<div class="sutol-mod16-root">
  <svg class="sutol-mod16-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <rect x="20" y="20" width="160" height="160" rx="8" fill="none" stroke="#495057" stroke-width="6"/>
    <g class="sutol-mod16-item" style="transform-origin:100px 100px;">
      <path d="M100,50 L130,80 L118,150 L82,150 L70,80 Z" fill="#E64980"/>
      <circle cx="100" cy="45" r="10" fill="#E64980"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod16-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod16-svg{width:100%;height:100%;display:block;}
  .sutol-mod16-item{animation:sutol-mod16-turn 5s ease-in-out infinite;}
  @keyframes sutol-mod16-turn{
    0%,100%{transform:scaleX(1);}
    50%{transform:scaleX(0.15);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod16-item{animation-duration:16s;}
  }
</style>
```

---

## Bileşen 17: Manken Üzerinde Kumaş Draperisi

**Etiketler (keyword eşleşmesi için):** mankeni, kumaş
**Kategori:** Moda & Stil
**Açıklama:** Bir terzi mankeni üzerine yavaşça sarılan/oturan bir kumaş draperisi.

```html
<div class="sutol-mod17-root">
  <svg class="sutol-mod17-svg" viewBox="0 0 160 200" preserveAspectRatio="xMidYMid meet">
    <line x1="80" y1="120" x2="80" y2="180" stroke="#495057" stroke-width="6"/>
    <ellipse cx="80" cy="185" rx="30" ry="8" fill="#495057"/>
    <ellipse cx="80" cy="60" rx="34" ry="50" fill="#F1F3F5" stroke="#CED4DA" stroke-width="3"/>
    <path class="sutol-mod17-drape" d="M50,60 Q80,90 110,60 L115,130 Q80,150 45,130 Z" fill="#748FFC" opacity="0.9"/>
  </svg>
</div>
<style>
  .sutol-mod17-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod17-svg{width:100%;height:100%;display:block;}
  .sutol-mod17-drape{animation:sutol-mod17-settle 4.5s ease-in-out infinite;}
  @keyframes sutol-mod17-settle{
    0%,100%{d:path("M50,60 Q80,90 110,60 L115,130 Q80,150 45,130 Z");}
    50%{d:path("M50,65 Q80,95 110,65 L120,135 Q80,155 40,135 Z");}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod17-drape{animation-duration:14s;}
  }
</style>
```

---

## Bileşen 18: Moda Haftası Takvimi

**Etiketler (keyword eşleşmesi için):** moda haftası, defile
**Kategori:** Moda & Stil
**Açıklama:** Sayfaları sırayla çevrilerek yaklaşan bir moda haftası etkinliğini simgeleyen bir takvim.

```html
<div class="sutol-mod18-root">
  <svg class="sutol-mod18-svg" viewBox="0 0 160 180" preserveAspectRatio="xMidYMid meet">
    <rect x="20" y="30" width="120" height="130" rx="8" fill="#F8F9FA" stroke="#CED4DA" stroke-width="3"/>
    <rect x="20" y="30" width="120" height="30" rx="8" fill="#E64980"/>
    <line x1="45" y1="18" x2="45" y2="40" stroke="#495057" stroke-width="5" stroke-linecap="round"/>
    <line x1="115" y1="18" x2="115" y2="40" stroke="#495057" stroke-width="5" stroke-linecap="round"/>
    <g class="sutol-mod18-page">
      <rect x="30" y="70" width="100" height="10" rx="4" fill="#DEE2E6"/>
      <rect x="30" y="90" width="100" height="10" rx="4" fill="#DEE2E6"/>
      <rect x="30" y="110" width="60" height="10" rx="4" fill="#DEE2E6"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod18-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod18-svg{width:100%;height:100%;display:block;}
  .sutol-mod18-page{transform-box:fill-box;transform-origin:left center;animation:sutol-mod18-flip 4s ease-in-out infinite;}
  @keyframes sutol-mod18-flip{
    0%,40%{transform:scaleX(1);opacity:1;}
    50%{transform:scaleX(0.05);opacity:0.4;}
    60%,100%{transform:scaleX(1);opacity:1;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod18-page{animation-duration:12s;}
  }
</style>
```

---

## Bileşen 19: Sürdürülebilir Moda Geri Dönüşümü

**Etiketler (keyword eşleşmesi için):** sürdürülebilir moda, kumaş
**Kategori:** Moda & Stil
**Açıklama:** Bir yaprak ve geri dönüşüm oklarının birlikte döndüğü, sürdürülebilir üretimi simgeleyen bir işaret.

```html
<div class="sutol-mod19-root">
  <svg class="sutol-mod19-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <path d="M100,60 C 130,70 140,110 100,140 C 60,110 70,70 100,60 Z" fill="#40C057"/>
    <g class="sutol-mod19-arrows" style="transform-origin:100px 100px;" fill="none" stroke="#94D82D" stroke-width="5" stroke-linecap="round">
      <path d="M100,35 A65,65 0 0,1 160,75"/>
      <path d="M160,125 A65,65 0 0,1 100,165"/>
      <path d="M40,75 A65,65 0 0,1 40,125"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod19-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod19-svg{width:100%;height:100%;display:block;}
  .sutol-mod19-arrows{animation:sutol-mod19-rotate 6s linear infinite;}
  @keyframes sutol-mod19-rotate{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
  @media (prefers-reduced-motion: reduce){
    .sutol-mod19-arrows{animation-duration:20s;}
  }
</style>
```

---

## Bileşen 20: Makasla Kumaş Kesimi

**Etiketler (keyword eşleşmesi için):** dikiş, terzi, kumaş
**Kategori:** Moda & Stil
**Açıklama:** Bir kumaş parçası üzerinde ileri doğru ilerleyerek kesim yapan bir terzi makası.

```html
<div class="sutol-mod20-root">
  <svg class="sutol-mod20-svg" viewBox="0 0 300 120" preserveAspectRatio="xMidYMid meet">
    <rect x="10" y="50" width="280" height="30" fill="#63E6BE" opacity="0.6"/>
    <line x1="10" y1="65" x2="290" y2="65" stroke="#0CA678" stroke-width="2" stroke-dasharray="6 6"/>
    <g class="sutol-mod20-scissors">
      <path class="sutol-mod20-blade sutol-mod20-b1" d="M0,0 L40,-12 L44,-6 L6,4 Z" fill="#495057"/>
      <path class="sutol-mod20-blade sutol-mod20-b2" d="M0,0 L40,12 L44,6 L6,-4 Z" fill="#495057"/>
      <circle cx="0" cy="0" r="6" fill="#212529"/>
    </g>
  </svg>
</div>
<style>
  .sutol-mod20-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-mod20-svg{width:100%;height:100%;display:block;}
  .sutol-mod20-scissors{animation:sutol-mod20-move 3s linear infinite;}
  .sutol-mod20-blade{transform-box:fill-box;transform-origin:left center;animation:sutol-mod20-snip 0.5s ease-in-out infinite alternate;}
  .sutol-mod20-b2{animation-delay:0.05s;}
  @keyframes sutol-mod20-move{
    0%{transform:translate(20px,65px);}
    100%{transform:translate(260px,65px);}
  }
  @keyframes sutol-mod20-snip{
    0%{transform:rotate(0deg);}
    100%{transform:rotate(6deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-mod20-scissors{animation-duration:10s;}
    .sutol-mod20-blade{animation-duration:2s;}
  }
</style>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Dalgalanan Kumaş): SVG `d` path morfing animasyonu, yumuşak kumaş kıvrımı hissi.
- Bileşen 2 (İğne İplik Dikişi): SVG `stroke-dashoffset` dikiş çizimi + iğnenin `translate/rotate` hareketi.
- Bileşen 3 (Terzi Mezurası): SVG grup `rotate` sarkaç sallanması.
- Bileşen 4 (Podyumda Yürüyen Silüet): SVG grup `translateX+opacity` yürüyüş geçişi.
- Bileşen 5 (Aksesuar Kolyesi): SVG grup `scaleX` 3D dönüş illüzyonu.
- Bileşen 6 (Defile Podyum Işıkları): SVG poligon `rotate` taraması, iki bağımsız hüzme.
- Bileşen 7 (Kayan Tekstil Deseni): SVG grup `translateX` kayan desen dokusu.
- Bileşen 8 (Döngüsel Renk Paleti): SVG `scale` nabız animasyonu, 4 renkli daire gecikmeli.
- Bileşen 9 (Mevsim Koleksiyonu İkonları): SVG `opacity+scale` sıralı beliren/kaybolan 4 ikon.
- Bileşen 10 (Ayakkabı Tasarım Taslağı): SVG `stroke-dasharray/dashoffset` çizim animasyonu.
- Bileşen 11 (Takı Taşı): SVG `scale+rotate+opacity` ışıltı animasyonu.
- Bileşen 12 (Kürk Dokusu): SVG çoklu path `rotate` gecikmeli dalgalanma.
- Bileşen 13 (İplik Makarası): SVG `scaleX` dönüş illüzyonu + `d` path iplik uzama animasyonu.
- Bileşen 14 (Dokuma Tezgahı): SVG `translateY+scaleY` çapraz geçiş animasyonu, gecikmeli iplik hatları.
- Bileşen 15 (Stil İkonu): SVG `scale+opacity+translate` yıldız parıltısı, gecikmeli çift yıldız.
- Bileşen 16 (Vitrin Sergisi): SVG `scaleX` dönüş illüzyonu, statik çerçeve içinde.
- Bileşen 17 (Manken Draperisi): SVG `d` path morfing animasyonu, yumuşak kumaş oturma hissi.
- Bileşen 18 (Moda Haftası Takvimi): SVG `scaleX+opacity` sayfa çevirme animasyonu.
- Bileşen 19 (Sürdürülebilir Moda): SVG grup `rotate` sürekli dönen geri dönüşüm okları.
- Bileşen 20 (Makasla Kumaş Kesimi): SVG grup `translate` ilerleme + `rotate` makas açma/kapama hareketi.

Genel notlar: Tüm bileşenler `transparent` kök arka plana sahiptir, dış kaynak/CDN/font/API kullanılmamıştır, tüm CSS sınıfları `sutol-modXX-` önekiyle kapsüllenmiştir, sabit metin içermezler ve her biri `prefers-reduced-motion: reduce` sorgusunda animasyon süresini belirgin şekilde uzatarak hareketi azaltır.
