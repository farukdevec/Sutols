# Sutol — Havacılık Kategorisi Bileşen Kütüphanesi (20 Bileşen)

Kategori: **Havacılık**
Anahtar kelime havuzu: pilot kabini, kanat, pist, kontrol kulesi, jet motoru, iniş takımı, radar ekranı, hava trafiği, kargo uçağı, helikopter pervanesi, uçuş rotası, türbülans, hangar

---

## Bileşen 1: Pistte Hızlanan Uçak

**Etiketler (keyword eşleşmesi için):** pist, kanat
**Kategori:** Havacılık
**Açıklama:** Bir pist hattı boyunca soldan sağa hızlanarak kalkışa geçen bir uçak silüeti.

```html
<div class="sutol-hav01-root">
  <svg class="sutol-hav01-svg" viewBox="0 0 300 140" preserveAspectRatio="xMidYMid meet">
    <line x1="0" y1="110" x2="300" y2="110" stroke="#495057" stroke-width="2" stroke-dasharray="18 14"/>
    <g class="sutol-hav01-plane">
      <path d="M0,0 L60,0 L75,-6 L80,0 L60,8 L45,26 L36,26 L44,8 L10,8 L2,16 L-6,16 L-2,2 Z" fill="#4C6EF5"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav01-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav01-svg{width:100%;height:100%;display:block;}
  .sutol-hav01-plane{animation:sutol-hav01-fly 4s ease-in infinite;}
  @keyframes sutol-hav01-fly{
    0%{transform:translate(10px,110px) scale(0.8);opacity:1;}
    60%{transform:translate(180px,105px) scale(0.9);opacity:1;}
    100%{transform:translate(320px,40px) scale(1.1);opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav01-plane{animation-duration:14s;}
  }
</style>
```

---

## Bileşen 2: Kanat Üzerinde Hava Akışı

**Etiketler (keyword eşleşmesi için):** kanat
**Kategori:** Havacılık
**Açıklama:** Bir uçak kanadı profilinin üzerinden akan aerodinamik hava akış çizgileri.

```html
<div class="sutol-hav02-root">
  <svg class="sutol-hav02-svg" viewBox="0 0 300 120" preserveAspectRatio="xMidYMid meet">
    <path d="M20,70 Q150,30 280,55 Q160,65 20,70 Z" fill="#748FFC"/>
    <g class="sutol-hav02-flow" stroke="#D0EBFF" stroke-width="3" fill="none" stroke-linecap="round">
      <path class="sutol-hav02-l sutol-hav02-l1" d="M0,40 Q100,25 200,32"/>
      <path class="sutol-hav02-l sutol-hav02-l2" d="M0,90 Q120,88 220,90"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav02-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav02-svg{width:100%;height:100%;display:block;}
  .sutol-hav02-l{stroke-dasharray:14 10;animation:sutol-hav02-move 1.6s linear infinite;}
  .sutol-hav02-l2{animation-delay:0.4s;}
  @keyframes sutol-hav02-move{
    0%{stroke-dashoffset:48;}
    100%{stroke-dashoffset:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav02-l{animation-duration:6s;}
  }
</style>
```

---

## Bileşen 3: Yanıp Sönen Kokpit Paneli

**Etiketler (keyword eşleşmesi için):** pilot kabini
**Kategori:** Havacılık
**Açıklama:** Bir uçak kokpitindeki gösterge ışıklarının sırayla yanıp sönmesi.

```html
<div class="sutol-hav03-root">
  <svg class="sutol-hav03-svg" viewBox="0 0 260 140" preserveAspectRatio="xMidYMid meet">
    <path d="M20,120 Q130,60 240,120 Z" fill="#343A40"/>
    <circle class="sutol-hav03-l sutol-hav03-l1" cx="80" cy="105" r="8" fill="#37B24D"/>
    <circle class="sutol-hav03-l sutol-hav03-l2" cx="130" cy="95" r="8" fill="#FAB005"/>
    <circle class="sutol-hav03-l sutol-hav03-l3" cx="180" cy="105" r="8" fill="#4DABF7"/>
    <rect x="50" y="112" width="160" height="8" rx="4" fill="#495057"/>
  </svg>
</div>
<style>
  .sutol-hav03-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav03-svg{width:100%;height:100%;display:block;}
  .sutol-hav03-l{animation:sutol-hav03-blink 2.4s ease-in-out infinite;}
  .sutol-hav03-l2{animation-delay:0.8s;}
  .sutol-hav03-l3{animation-delay:1.6s;}
  @keyframes sutol-hav03-blink{
    0%,100%{opacity:0.3;}
    50%{opacity:1;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav03-l{animation-duration:9s;}
  }
</style>
```

---

## Bileşen 4: Dönen Kontrol Kulesi Radarı

**Etiketler (keyword eşleşmesi için):** kontrol kulesi, radar ekranı
**Kategori:** Havacılık
**Açıklama:** Bir kontrol kulesinin tepesinde sürekli dönen bir radar anteni.

```html
<div class="sutol-hav04-root">
  <svg class="sutol-hav04-svg" viewBox="0 0 160 200" preserveAspectRatio="xMidYMid meet">
    <path d="M60,190 L100,190 L90,80 L70,80 Z" fill="#495057"/>
    <rect x="55" y="55" width="50" height="30" rx="4" fill="#748FFC"/>
    <g class="sutol-hav04-radar" style="transform-origin:80px 55px;">
      <line x1="80" y1="55" x2="80" y2="25" stroke="#20C997" stroke-width="4" stroke-linecap="round"/>
      <line x1="80" y1="55" x2="105" y2="35" stroke="#20C997" stroke-width="4" stroke-linecap="round"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav04-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav04-svg{width:100%;height:100%;display:block;}
  .sutol-hav04-radar{animation:sutol-hav04-spin 2.2s linear infinite;}
  @keyframes sutol-hav04-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
  @media (prefers-reduced-motion: reduce){
    .sutol-hav04-radar{animation-duration:10s;}
  }
</style>
```

---

## Bileşen 5: Dönen Jet Türbini

**Etiketler (keyword eşleşmesi için):** jet motoru
**Kategori:** Havacılık
**Açıklama:** Bir jet motorunun ön fan bıçaklarının yüksek hızda dönmesi.

```html
<div class="sutol-hav05-root">
  <svg class="sutol-hav05-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <circle cx="100" cy="100" r="90" fill="none" stroke="#495057" stroke-width="8"/>
    <g class="sutol-hav05-fan" style="transform-origin:100px 100px;">
      <g fill="#ADB5BD">
        <path d="M100,100 L100,25 Q118,60 100,100 Z"/>
        <path d="M100,100 L163,63 Q145,95 100,100 Z"/>
        <path d="M100,100 L163,137 Q140,110 100,100 Z"/>
        <path d="M100,100 L100,175 Q82,140 100,100 Z"/>
        <path d="M100,100 L37,137 Q60,105 100,100 Z"/>
        <path d="M100,100 L37,63 Q65,90 100,100 Z"/>
      </g>
      <circle cx="100" cy="100" r="16" fill="#495057"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav05-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav05-svg{width:100%;height:100%;display:block;}
  .sutol-hav05-fan{animation:sutol-hav05-spin 0.6s linear infinite;}
  @keyframes sutol-hav05-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
  @media (prefers-reduced-motion: reduce){
    .sutol-hav05-fan{animation-duration:6s;}
  }
</style>
```

---

## Bileşen 6: Açılıp Kapanan İniş Takımı

**Etiketler (keyword eşleşmesi için):** iniş takımı
**Kategori:** Havacılık
**Açıklama:** Bir uçak gövdesinden aşağı doğru açılan ve tekrar katlanan bir iniş takımı düzeneği.

```html
<div class="sutol-hav06-root">
  <svg class="sutol-hav06-svg" viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet">
    <ellipse cx="100" cy="60" rx="90" ry="30" fill="#4C6EF5"/>
    <g class="sutol-hav06-gear" style="transform-origin:100px 75px;">
      <rect x="94" y="75" width="12" height="45" rx="4" fill="#495057"/>
      <circle cx="100" cy="128" r="14" fill="#212529"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav06-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav06-svg{width:100%;height:100%;display:block;}
  .sutol-hav06-gear{animation:sutol-hav06-deploy 4s ease-in-out infinite;}
  @keyframes sutol-hav06-deploy{
    0%,15%{transform:rotate(-95deg) translateY(-10px);}
    50%,65%{transform:rotate(0deg) translateY(0);}
    100%{transform:rotate(-95deg) translateY(-10px);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav06-gear{animation-duration:12s;}
  }
</style>
```

---

## Bileşen 7: Radar Ekranı Taraması

**Etiketler (keyword eşleşmesi için):** radar ekranı, hava trafiği
**Kategori:** Havacılık
**Açıklama:** Yeşil bir radar ekranında dönen tarama çizgisi ve üzerinde beliren uçak sinyalleri.

```html
<div class="sutol-hav07-root">
  <svg class="sutol-hav07-svg" viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <circle cx="100" cy="100" r="90" fill="#0B2E13" stroke="#2F9E44" stroke-width="3"/>
    <circle cx="100" cy="100" r="60" fill="none" stroke="#2F9E44" stroke-width="1" opacity="0.5"/>
    <circle cx="100" cy="100" r="30" fill="none" stroke="#2F9E44" stroke-width="1" opacity="0.5"/>
    <g class="sutol-hav07-sweep" style="transform-origin:100px 100px;">
      <path d="M100,100 L100,10 A90,90 0 0,1 163,37 Z" fill="#40C057" opacity="0.35"/>
    </g>
    <circle class="sutol-hav07-blip sutol-hav07-b1" cx="130" cy="70" r="4" fill="#69DB7C"/>
    <circle class="sutol-hav07-blip sutol-hav07-b2" cx="70" cy="130" r="4" fill="#69DB7C"/>
  </svg>
</div>
<style>
  .sutol-hav07-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav07-svg{width:100%;height:100%;display:block;}
  .sutol-hav07-sweep{animation:sutol-hav07-spin 3s linear infinite;}
  @keyframes sutol-hav07-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
  .sutol-hav07-blip{animation:sutol-hav07-ping 3s ease-in-out infinite;}
  .sutol-hav07-b2{animation-delay:1.5s;}
  @keyframes sutol-hav07-ping{
    0%,100%{opacity:0.2;}
    50%{opacity:1;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav07-sweep{animation-duration:12s;}
    .sutol-hav07-blip{animation-duration:9s;}
  }
</style>
```

---

## Bileşen 8: Hava Trafiğinde Uçaklar

**Etiketler (keyword eşleşmesi için):** hava trafiği, uçuş rotası
**Kategori:** Havacılık
**Açıklama:** Farklı yönlerde kesişen rotalarda ilerleyen birden fazla uçak simgesi.

```html
<div class="sutol-hav08-root">
  <svg class="sutol-hav08-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet">
    <path d="M0,60 L300,140" stroke="#ADB5BD" stroke-width="1" stroke-dasharray="6 6"/>
    <path d="M0,150 L300,50" stroke="#ADB5BD" stroke-width="1" stroke-dasharray="6 6"/>
    <g class="sutol-hav08-plane sutol-hav08-p1" fill="#4C6EF5">
      <polygon points="0,0 14,4 0,8 4,4"/>
    </g>
    <g class="sutol-hav08-plane sutol-hav08-p2" fill="#F76707">
      <polygon points="0,0 14,4 0,8 4,4"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav08-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav08-svg{width:100%;height:100%;display:block;}
  .sutol-hav08-p1{offset-path:path("M0,60 L300,140");animation:sutol-hav08-fly1 6s linear infinite;}
  .sutol-hav08-p2{offset-path:path("M0,150 L300,50");animation:sutol-hav08-fly2 5s linear infinite;}
  @keyframes sutol-hav08-fly1{0%{offset-distance:0%;}100%{offset-distance:100%;}}
  @keyframes sutol-hav08-fly2{0%{offset-distance:0%;}100%{offset-distance:100%;}}
  @media (prefers-reduced-motion: reduce){
    .sutol-hav08-p1{animation-duration:18s;}
    .sutol-hav08-p2{animation-duration:16s;}
  }
</style>
```

---

## Bileşen 9: Kargo Uçağına Yükleme

**Etiketler (keyword eşleşmesi için):** kargo uçağı
**Kategori:** Havacılık
**Açıklama:** Açık kargo kapısından uçağın içine doğru sırayla giren yük kutuları.

```html
<div class="sutol-hav09-root">
  <svg class="sutol-hav09-svg" viewBox="0 0 300 140" preserveAspectRatio="xMidYMid meet">
    <path d="M20,110 Q40,40 150,40 Q260,40 280,110 Z" fill="#495057"/>
    <path d="M120,110 L120,70 L200,70 L200,110 Z" fill="#212529"/>
    <g class="sutol-hav09-boxes">
      <rect class="sutol-hav09-b sutol-hav09-b1" x="0" y="85" width="22" height="22" fill="#FAB005"/>
      <rect class="sutol-hav09-b sutol-hav09-b2" x="0" y="85" width="22" height="22" fill="#F76707"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav09-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav09-svg{width:100%;height:100%;display:block;}
  .sutol-hav09-b{animation:sutol-hav09-load 3s ease-in infinite;}
  .sutol-hav09-b2{animation-delay:1.5s;}
  @keyframes sutol-hav09-load{
    0%{transform:translateX(50px);opacity:0;}
    10%{opacity:1;}
    70%{transform:translateX(120px);opacity:1;}
    85%{opacity:0;}
    100%{transform:translateX(50px);opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav09-b{animation-duration:10s;}
  }
</style>
```

---

## Bileşen 10: Dönen Helikopter Pervanesi

**Etiketler (keyword eşleşmesi için):** helikopter pervanesi
**Kategori:** Havacılık
**Açıklama:** Bir helikopterin üst rotor pervanesinin yüksek hızda dönmesi.

```html
<div class="sutol-hav10-root">
  <svg class="sutol-hav10-svg" viewBox="0 0 220 160" preserveAspectRatio="xMidYMid meet">
    <ellipse cx="110" cy="110" rx="60" ry="26" fill="#495057"/>
    <rect x="104" y="60" width="12" height="30" fill="#343A40"/>
    <g class="sutol-hav10-rotor" style="transform-origin:110px 60px;">
      <ellipse cx="110" cy="60" rx="95" ry="6" fill="#868E96"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav10-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav10-svg{width:100%;height:100%;display:block;}
  .sutol-hav10-rotor{animation:sutol-hav10-spin 0.35s linear infinite;}
  @keyframes sutol-hav10-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
  @media (prefers-reduced-motion: reduce){
    .sutol-hav10-rotor{animation-duration:5s;}
  }
</style>
```

---

## Bileşen 11: Harita Üzerinde Uçuş Rotası

**Etiketler (keyword eşleşmesi için):** uçuş rotası
**Kategori:** Havacılık
**Açıklama:** Bir noktadan diğerine kesikli bir yay çizgisi boyunca ilerleyen bir uçak işaretçisi.

```html
<div class="sutol-hav11-root">
  <svg class="sutol-hav11-svg" viewBox="0 0 300 160" preserveAspectRatio="xMidYMid meet">
    <circle cx="30" cy="120" r="7" fill="#2F9E44"/>
    <circle cx="270" cy="120" r="7" fill="#E8590C"/>
    <path d="M30,120 Q150,20 270,120" fill="none" stroke="#ADB5BD" stroke-width="2" stroke-dasharray="8 8"/>
    <g class="sutol-hav11-plane" fill="#1971C2">
      <polygon points="0,-6 14,-2 0,10 4,-2"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav11-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav11-svg{width:100%;height:100%;display:block;}
  .sutol-hav11-plane{offset-path:path("M30,120 Q150,20 270,120");animation:sutol-hav11-travel 4s ease-in-out infinite;}
  @keyframes sutol-hav11-travel{
    0%{offset-distance:0%;opacity:0;}
    10%{opacity:1;}
    90%{opacity:1;}
    100%{offset-distance:100%;opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav11-plane{animation-duration:14s;}
  }
</style>
```

---

## Bileşen 12: Türbülansta Sarsılan Uçak

**Etiketler (keyword eşleşmesi için):** türbülans
**Kategori:** Havacılık
**Açıklama:** Hafif düzensiz sarsıntılarla titreşen, türbülansı simgeleyen bir uçak silüeti.

```html
<div class="sutol-hav12-root">
  <svg class="sutol-hav12-svg" viewBox="0 0 200 140" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-hav12-plane">
      <path d="M40,70 L150,70 L165,64 L170,70 L150,78 L135,96 L126,96 L134,78 L60,78 L52,86 L44,86 L48,72 Z" fill="#495057"/>
    </g>
    <g class="sutol-hav12-turb" stroke="#ADB5BD" stroke-width="2" fill="none" opacity="0.5">
      <path d="M20,50 Q40,45 60,50"/>
      <path d="M100,100 Q120,95 140,100"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav12-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav12-svg{width:100%;height:100%;display:block;}
  .sutol-hav12-plane{animation:sutol-hav12-shake 0.5s ease-in-out infinite;}
  @keyframes sutol-hav12-shake{
    0%,100%{transform:translate(0,0) rotate(0deg);}
    25%{transform:translate(-3px,2px) rotate(-1.5deg);}
    50%{transform:translate(2px,-3px) rotate(1deg);}
    75%{transform:translate(-2px,-1px) rotate(-1deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav12-plane{animation-duration:4s;transform:translate(0,0);}
  }
</style>
```

---

## Bileşen 13: Açılan Hangar Kapısı

**Etiketler (keyword eşleşmesi için):** hangar
**Kategori:** Havacılık
**Açıklama:** İçinde park edilmiş bir uçağı ortaya çıkaran, yavaşça açılan büyük bir hangar kapısı.

```html
<div class="sutol-hav13-root">
  <svg class="sutol-hav13-svg" viewBox="0 0 260 160" preserveAspectRatio="xMidYMid meet">
    <path d="M20,140 L20,50 Q130,10 240,50 L240,140 Z" fill="#5C6773"/>
    <path d="M60,120 L120,120 L110,90 L70,90 Z" fill="#748FFC"/>
    <rect class="sutol-hav13-door sutol-hav13-left" x="20" y="50" width="110" height="90" fill="#343A40"/>
    <rect class="sutol-hav13-door sutol-hav13-right" x="130" y="50" width="110" height="90" fill="#343A40"/>
  </svg>
</div>
<style>
  .sutol-hav13-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav13-svg{width:100%;height:100%;display:block;}
  .sutol-hav13-left{transform-origin:20px 95px;animation:sutol-hav13-open-l 6s ease-in-out infinite;}
  .sutol-hav13-right{transform-origin:240px 95px;animation:sutol-hav13-open-r 6s ease-in-out infinite;}
  @keyframes sutol-hav13-open-l{
    0%,15%{transform:scaleX(1);}
    50%,65%{transform:scaleX(0.15);}
    100%{transform:scaleX(1);}
  }
  @keyframes sutol-hav13-open-r{
    0%,15%{transform:scaleX(1);}
    50%,65%{transform:scaleX(0.15);}
    100%{transform:scaleX(1);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav13-left,.sutol-hav13-right{animation-duration:18s;}
  }
</style>
```

---

## Bileşen 14: Sıralı Yanan Pist Kenar Işıkları

**Etiketler (keyword eşleşmesi için):** pist
**Kategori:** Havacılık
**Açıklama:** Bir pist hattı boyunca sırayla yanıp sönen kenar aydınlatma ışıkları.

```html
<div class="sutol-hav14-root">
  <svg class="sutol-hav14-svg" viewBox="0 0 300 60" preserveAspectRatio="xMidYMid meet">
    <line x1="0" y1="30" x2="300" y2="30" stroke="#343A40" stroke-width="2"/>
    <g class="sutol-hav14-lights" fill="#FFD43B">
      <circle class="sutol-hav14-l" cx="20" cy="20" r="5"/>
      <circle class="sutol-hav14-l" cx="60" cy="20" r="5"/>
      <circle class="sutol-hav14-l" cx="100" cy="20" r="5"/>
      <circle class="sutol-hav14-l" cx="140" cy="20" r="5"/>
      <circle class="sutol-hav14-l" cx="180" cy="20" r="5"/>
      <circle class="sutol-hav14-l" cx="220" cy="20" r="5"/>
      <circle class="sutol-hav14-l" cx="260" cy="20" r="5"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav14-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav14-svg{width:100%;height:100%;display:block;}
  .sutol-hav14-l{opacity:0.2;animation:sutol-hav14-blink 1.4s linear infinite;}
  .sutol-hav14-l:nth-child(1){animation-delay:0s;}
  .sutol-hav14-l:nth-child(2){animation-delay:0.1s;}
  .sutol-hav14-l:nth-child(3){animation-delay:0.2s;}
  .sutol-hav14-l:nth-child(4){animation-delay:0.3s;}
  .sutol-hav14-l:nth-child(5){animation-delay:0.4s;}
  .sutol-hav14-l:nth-child(6){animation-delay:0.5s;}
  .sutol-hav14-l:nth-child(7){animation-delay:0.6s;}
  @keyframes sutol-hav14-blink{
    0%,85%,100%{opacity:0.2;}
    10%{opacity:1;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav14-l{animation-duration:5s;}
  }
</style>
```

---

## Bileşen 15: İnişte Açılan Kanat Flapları

**Etiketler (keyword eşleşmesi için):** kanat, iniş takımı
**Kategori:** Havacılık
**Açıklama:** İniş sırasında kanat arkasından aşağı doğru açılan flap yüzeyleri.

```html
<div class="sutol-hav15-root">
  <svg class="sutol-hav15-svg" viewBox="0 0 260 120" preserveAspectRatio="xMidYMid meet">
    <path d="M10,60 Q130,30 250,50 Q140,58 10,60 Z" fill="#4C6EF5"/>
    <g class="sutol-hav15-flap" style="transform-origin:180px 55px;">
      <rect x="180" y="48" width="60" height="14" rx="3" fill="#364FC7"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav15-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav15-svg{width:100%;height:100%;display:block;}
  .sutol-hav15-flap{animation:sutol-hav15-extend 4s ease-in-out infinite;}
  @keyframes sutol-hav15-extend{
    0%,20%{transform:rotate(0deg);}
    50%,70%{transform:rotate(30deg);}
    100%{transform:rotate(0deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav15-flap{animation-duration:12s;}
  }
</style>
```

---

## Bileşen 16: Jet Motoru Egzoz Isı Dalgası

**Etiketler (keyword eşleşmesi için):** jet motoru
**Kategori:** Havacılık
**Açıklama:** Bir jet motoru egzozundan arkaya doğru yayılan titreşimli ısı/enerji dalgaları.

```html
<div class="sutol-hav16-root">
  <svg class="sutol-hav16-svg" viewBox="0 0 260 100" preserveAspectRatio="xMidYMid meet">
    <ellipse cx="60" cy="50" rx="50" ry="30" fill="#495057"/>
    <circle cx="105" cy="50" r="8" fill="#212529"/>
    <g class="sutol-hav16-heat">
      <ellipse class="sutol-hav16-h sutol-hav16-h1" cx="130" cy="50" rx="20" ry="14" fill="#FF922B" opacity="0.5"/>
      <ellipse class="sutol-hav16-h sutol-hav16-h2" cx="160" cy="50" rx="24" ry="16" fill="#FFA94D" opacity="0.4"/>
      <ellipse class="sutol-hav16-h sutol-hav16-h3" cx="195" cy="50" rx="28" ry="18" fill="#FFC078" opacity="0.3"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav16-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav16-svg{width:100%;height:100%;display:block;}
  .sutol-hav16-h{transform-box:fill-box;transform-origin:center;animation:sutol-hav16-pulse 0.8s ease-in-out infinite;}
  .sutol-hav16-h2{animation-delay:0.15s;}
  .sutol-hav16-h3{animation-delay:0.3s;}
  @keyframes sutol-hav16-pulse{
    0%,100%{transform:scaleX(1);}
    50%{transform:scaleX(1.2);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav16-h{animation-duration:4s;}
  }
</style>
```

---

## Bileşen 17: Kontrol Kulesi İşaret Işığı (Beacon)

**Etiketler (keyword eşleşmesi için):** kontrol kulesi
**Kategori:** Havacılık
**Açıklama:** Bir kule tepesinde sürekli dönen kırmızı-beyaz uyarı ışığı hüzmesi.

```html
<div class="sutol-hav17-root">
  <svg class="sutol-hav17-svg" viewBox="0 0 160 200" preserveAspectRatio="xMidYMid meet">
    <path d="M65,190 L95,190 L88,90 L72,90 Z" fill="#495057"/>
    <rect x="60" y="65" width="40" height="26" rx="4" fill="#748FFC"/>
    <circle cx="80" cy="55" r="8" fill="#E03131"/>
    <g class="sutol-hav17-beam" style="transform-origin:80px 55px;">
      <polygon points="80,55 130,20 130,35" fill="#FFC9C9" opacity="0.4"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav17-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav17-svg{width:100%;height:100%;display:block;}
  .sutol-hav17-beam{animation:sutol-hav17-rotate 2s linear infinite;}
  @keyframes sutol-hav17-rotate{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
  @media (prefers-reduced-motion: reduce){
    .sutol-hav17-beam{animation-duration:9s;}
  }
</style>
```

---

## Bileşen 18: Bulutlar Arasında Yükselen Uçak

**Etiketler (keyword eşleşmesi için):** uçuş rotası, kanat
**Kategori:** Havacılık
**Açıklama:** Beyaz bulut kümeleri arasından yukarı doğru süzülerek yükselen bir yolcu uçağı.

```html
<div class="sutol-hav18-root">
  <svg class="sutol-hav18-svg" viewBox="0 0 260 200" preserveAspectRatio="xMidYMid meet">
    <g fill="#E9ECEF" opacity="0.8">
      <ellipse cx="60" cy="170" rx="35" ry="14"/>
      <ellipse cx="200" cy="120" rx="30" ry="12"/>
      <ellipse cx="90" cy="60" rx="26" ry="10"/>
    </g>
    <g class="sutol-hav18-plane" fill="#4C6EF5">
      <polygon points="0,0 60,10 70,4 76,10 60,18 40,42 30,42 40,18 10,18 2,26 -6,26 -2,10"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav18-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav18-svg{width:100%;height:100%;display:block;}
  .sutol-hav18-plane{animation:sutol-hav18-climb 5s ease-in-out infinite;}
  @keyframes sutol-hav18-climb{
    0%{transform:translate(20px,180px) rotate(-15deg);opacity:0;}
    15%{opacity:1;}
    100%{transform:translate(150px,10px) rotate(-25deg);opacity:0;}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav18-plane{animation-duration:16s;}
  }
</style>
```

---

## Bileşen 19: Pilot Kumanda Kolu Hareketi

**Etiketler (keyword eşleşmesi için):** pilot kabini
**Kategori:** Havacılık
**Açıklama:** Bir kokpitte uçuş kontrolünü simgeleyen, hafifçe ileri geri hareket eden bir kumanda kolu (yoke).

```html
<div class="sutol-hav19-root">
  <svg class="sutol-hav19-svg" viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet">
    <rect x="30" y="130" width="140" height="20" rx="6" fill="#343A40"/>
    <g class="sutol-hav19-yoke" style="transform-origin:100px 130px;">
      <rect x="94" y="60" width="12" height="70" fill="#495057"/>
      <path d="M50,60 Q100,30 150,60 Q100,75 50,60 Z" fill="#748FFC"/>
    </g>
  </svg>
</div>
<style>
  .sutol-hav19-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav19-svg{width:100%;height:100%;display:block;}
  .sutol-hav19-yoke{animation:sutol-hav19-tilt 3.2s ease-in-out infinite;}
  @keyframes sutol-hav19-tilt{
    0%,100%{transform:rotate(-8deg);}
    50%{transform:rotate(8deg);}
  }
  @media (prefers-reduced-motion: reduce){
    .sutol-hav19-yoke{animation-duration:10s;}
  }
</style>
```

---

## Bileşen 20: Helikopterin Pist İnişi

**Etiketler (keyword eşleşmesi için):** helikopter pervanesi, pist
**Kategori:** Havacılık
**Açıklama:** Pervanesi dönerken pist üzerine yavaşça inen bir helikopter.

```html
<div class="sutol-hav20-root">
  <svg class="sutol-hav20-svg" viewBox="0 0 220 200" preserveAspectRatio="xMidYMid meet">
    <line x1="20" y1="180" x2="200" y2="180" stroke="#495057" stroke-width="2" stroke-dasharray="10 8"/>
    <g class="sutol-hav20-heli">
      <ellipse cx="110" cy="0" rx="40" ry="18" fill="#20C997"/>
      <rect x="104" y="-30" width="10" height="20" fill="#343A40"/>
      <g class="sutol-hav20-rotor" style="transform-origin:110px -30px;">
        <ellipse cx="110" cy="-30" rx="65" ry="5" fill="#868E96"/>
      </g>
    </g>
  </svg>
</div>
<style>
  .sutol-hav20-root{width:100%;height:100%;background:transparent;overflow:hidden;}
  .sutol-hav20-svg{width:100%;height:100%;display:block;}
  .sutol-hav20-heli{animation:sutol-hav20-descend 5s ease-in-out infinite;}
  .sutol-hav20-rotor{animation:sutol-hav20-spin 0.3s linear infinite;}
  @keyframes sutol-hav20-descend{
    0%{transform:translateY(0);}
    50%{transform:translateY(178px);}
    85%{transform:translateY(178px);}
    100%{transform:translateY(0);}
  }
  @keyframes sutol-hav20-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
  @media (prefers-reduced-motion: reduce){
    .sutol-hav20-heli{animation-duration:16s;}
    .sutol-hav20-rotor{animation-duration:4s;}
  }
</style>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Pistte Hızlanan Uçak): SVG grup `translate+scale+opacity` kalkış hareketi.
- Bileşen 2 (Kanat Hava Akışı): SVG `stroke-dashoffset` akış çizgisi animasyonu, gecikmeli iki hat.
- Bileşen 3 (Kokpit Paneli): SVG `opacity` sıralı yanıp sönen gösterge ışıkları.
- Bileşen 4 (Kontrol Kulesi Radarı): SVG grup `rotate` sürekli dönen anten.
- Bileşen 5 (Jet Türbini): SVG grup `rotate` yüksek hızlı fan dönüşü.
- Bileşen 6 (İniş Takımı): SVG grup `rotate+translateY` açılıp katlanma hareketi.
- Bileşen 7 (Radar Ekranı): SVG grup `rotate` tarama huzmesi + `opacity` blip nabzı.
- Bileşen 8 (Hava Trafiği): SVG `offset-path` CSS motion-path ile kesişen iki rota.
- Bileşen 9 (Kargo Yükleme): SVG `translateX+opacity` gecikmeli kutu taşıma döngüsü.
- Bileşen 10 (Helikopter Pervanesi): SVG grup `rotate` yüksek hızlı rotor dönüşü.
- Bileşen 11 (Uçuş Rotası): SVG `offset-path` ile yay boyunca ilerleyen uçak işaretçisi.
- Bileşen 12 (Türbülans): SVG grup `translate+rotate` düzensiz sarsıntı animasyonu.
- Bileşen 13 (Hangar Kapısı): SVG `scaleX` çift kanatlı kapı açılma/kapanma animasyonu.
- Bileşen 14 (Pist Kenar Işıkları): SVG `opacity` sıralı yanan ışık dizisi.
- Bileşen 15 (Kanat Flapları): SVG grup `rotate` flap açılma hareketi.
- Bileşen 16 (Jet Motoru Egzozu): SVG `scaleX` titreşimli ısı dalgası, gecikmeli 3 katman.
- Bileşen 17 (Kule Beacon Işığı): SVG grup `rotate` dönen uyarı huzmesi.
- Bileşen 18 (Bulutlar Arasında Yükseliş): SVG grup `translate+rotate+opacity` yükseliş animasyonu.
- Bileşen 19 (Pilot Kumanda Kolu): SVG grup `rotate` ileri geri kontrol hareketi.
- Bileşen 20 (Helikopter Pist İnişi): SVG grup `translateY` iniş hareketi + `rotate` rotor dönüşü.

Genel notlar: Tüm bileşenler `transparent` kök arka plana sahiptir, dış kaynak/CDN/font/API kullanılmamıştır, tüm CSS sınıfları `sutol-havXX-` önekiyle kapsüllenmiştir, sabit metin içermezler ve her biri `prefers-reduced-motion: reduce` sorgusunda animasyon süresini belirgin şekilde uzatarak hareketi azaltır.
