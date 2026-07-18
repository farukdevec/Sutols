# Sutol — Ulaşım & Lojistik Kategorisi Animasyonlu Bileşenleri (20 Adet)

Aşağıda "Ulaşım & Lojistik" kategorisi için üretilmiş, her biri tek dosya/tek `<div>` kökünde çalışan, dış kaynak kullanmayan, şeffaf arka planlı 20 animasyonlu HTML bileşeni bulunmaktadır. Her bileşen `sutol-loj-NN-...` öneki ile kapsüllenmiştir, `prefers-reduced-motion` desteği içerir ve sandbox'a uyumludur.

---

## Bileşen 1: Açık Denizde Kargo Gemisi

**Etiketler (keyword eşleşmesi için):** kargo gemisi, konteyner, liman, teslimat rotası
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Üzerinde renkli konteynerler taşıyan, dalgalarda hafifçe sallanarak ilerleyen bir kargo gemisi.

```html
<div class="sutol-loj-01-gemi">
  <svg viewBox="0 0 200 140" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-loj-01-wave" d="M0,110 Q25,102 50,110 T100,110 T150,110 T200,110 V140 H0 Z" fill="#5b9bd6" opacity="0.7"/>
    <g class="sutol-loj-01-ship">
      <path d="M40,95 L160,95 L145,110 L55,110 Z" fill="#3d4d78"/>
      <rect x="60" y="70" width="16" height="25" fill="#d65b5b"/>
      <rect x="80" y="70" width="16" height="25" fill="#5bd68a"/>
      <rect x="100" y="70" width="16" height="25" fill="#e0a05b"/>
      <rect x="120" y="70" width="16" height="25" fill="#5b8ad6"/>
      <rect x="45" y="80" width="10" height="15" fill="#8a5bd6"/>
    </g>
  </svg>
</div>
<style>
.sutol-loj-01-gemi{width:100%;height:100%;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-loj-01-gemi svg{width:100%;height:100%;}
.sutol-loj-01-ship{animation:sutolLoj01Bob 3s ease-in-out infinite;}
.sutol-loj-01-wave{animation:sutolLoj01Move 6s linear infinite;}
@keyframes sutolLoj01Bob{0%,100%{transform:translateY(0) rotate(0deg);}50%{transform:translateY(-3px) rotate(0.6deg);}}
@keyframes sutolLoj01Move{from{transform:translateX(0);}to{transform:translateX(-50px);}}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-01-ship,.sutol-loj-01-wave{animation-duration:24s;}
}
</style>
```

---

## Bileşen 2: Konteyner Yükleyen Liman Vinci

**Etiketler (keyword eşleşmesi için):** liman, konteyner, kargo gemisi, palet
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Kancasıyla bir konteyneri yukarı kaldırıp yana taşıyan bir liman yükleme vinci (crane).

```html
<div class="sutol-loj-02-vinc">
  <svg viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="20" y="150" width="160" height="8" fill="#5f5f6a"/>
    <rect x="35" y="30" width="10" height="120" fill="#e0a05b"/>
    <rect x="20" y="20" width="150" height="10" fill="#e0a05b"/>
    <g class="sutol-loj-02-trolley">
      <rect x="-4" y="0" width="8" height="8" fill="#5f5f6a"/>
      <line class="sutol-loj-02-cable" x1="0" y1="8" x2="0" y2="60" stroke="#5f5f6a" stroke-width="2"/>
      <rect class="sutol-loj-02-container" x="-20" y="60" width="40" height="26" rx="3" fill="#5bd68a" stroke="#3a8f5c" stroke-width="2"/>
    </g>
  </svg>
</div>
<style>
.sutol-loj-02-vinc{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-02-vinc svg{width:100%;height:100%;}
.sutol-loj-02-trolley{transform:translate(100px,22px);animation:sutolLoj02Slide 6s ease-in-out infinite;}
.sutol-loj-02-cable,.sutol-loj-02-container{animation:sutolLoj02Lift 6s ease-in-out infinite;transform-box:fill-box;}
@keyframes sutolLoj02Slide{
  0%,20%{transform:translate(60px,22px);}
  50%,70%{transform:translate(140px,22px);}
  100%{transform:translate(60px,22px);}
}
@keyframes sutolLoj02Lift{
  0%,15%{transform:scaleY(1);}
  30%,55%{transform:scaleY(0.55);}
  75%,100%{transform:scaleY(1);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-02-trolley,.sutol-loj-02-cable,.sutol-loj-02-container{animation-duration:26s;}
}
</style>
```

---
## Bileşen 3: İstiflenen Konteynerler

**Etiketler (keyword eşleşmesi için):** konteyner, liman, dağıtım merkezi, palet
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Limanda alt alta ve yan yana dizilerek sırayla parlayan renkli konteyner yığınları.

```html
<div class="sutol-loj-03-istif">
  <svg viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="20" y="110" width="45" height="30" rx="3" fill="#d65b5b" class="sutol-loj-03-c sutol-loj-03-c1"/>
    <rect x="70" y="110" width="45" height="30" rx="3" fill="#5bd68a" class="sutol-loj-03-c sutol-loj-03-c2"/>
    <rect x="120" y="110" width="45" height="30" rx="3" fill="#5b8ad6" class="sutol-loj-03-c sutol-loj-03-c3"/>
    <rect x="20" y="76" width="45" height="30" rx="3" fill="#e0a05b" class="sutol-loj-03-c sutol-loj-03-c4"/>
    <rect x="70" y="76" width="45" height="30" rx="3" fill="#8a5bd6" class="sutol-loj-03-c sutol-loj-03-c5"/>
    <rect x="45" y="42" width="45" height="30" rx="3" fill="#d6a05b" class="sutol-loj-03-c sutol-loj-03-c6"/>
  </svg>
</div>
<style>
.sutol-loj-03-istif{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-03-istif svg{width:100%;height:100%;}
.sutol-loj-03-c{animation:sutolLoj03Glow 6s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
.sutol-loj-03-c2{animation-delay:0.5s;}
.sutol-loj-03-c3{animation-delay:1s;}
.sutol-loj-03-c4{animation-delay:1.5s;}
.sutol-loj-03-c5{animation-delay:2s;}
.sutol-loj-03-c6{animation-delay:2.5s;}
@keyframes sutolLoj03Glow{0%,100%{opacity:0.75;transform:scale(1);}20%,30%{opacity:1;transform:scale(1.04);}}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-03-c{animation-duration:26s;}
}
</style>
```

---

## Bileşen 4: Raylarda İlerleyen Kargo Treni

**Etiketler (keyword eşleşmesi için):** tren rayı, konteyner, dağıtım merkezi, teslimat rotası
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Ray hattı üzerinde konteyner vagonlarını çekerek soldan sağa ilerleyen bir kargo treni. (Teknik: SVG SMIL `animateMotion`)

```html
<div class="sutol-loj-04-tren">
  <svg viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <line x1="0" y1="95" x2="200" y2="95" stroke="#8a8a8a" stroke-width="3"/>
    <g stroke="#8a8a8a" stroke-width="2">
      <line x1="10" y1="90" x2="10" y2="100"/>
      <line x1="40" y1="90" x2="40" y2="100"/>
      <line x1="70" y1="90" x2="70" y2="100"/>
      <line x1="100" y1="90" x2="100" y2="100"/>
      <line x1="130" y1="90" x2="130" y2="100"/>
      <line x1="160" y1="90" x2="160" y2="100"/>
      <line x1="190" y1="90" x2="190" y2="100"/>
    </g>
    <g class="sutol-loj-04-train">
      <animateMotion dur="7s" repeatCount="indefinite" path="M-40,0 L240,0"/>
      <rect x="-30" y="-24" width="26" height="20" rx="3" fill="#5b8ad6"/>
      <rect x="0" y="-20" width="26" height="16" rx="2" fill="#e0a05b"/>
      <rect x="30" y="-20" width="26" height="16" rx="2" fill="#5bd68a"/>
    </g>
  </svg>
</div>
<style>
.sutol-loj-04-tren{width:100%;height:100%;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-loj-04-tren svg{width:100%;height:100%;}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-04-train animateMotion{dur:30s;}
}
</style>
```

---
## Bileşen 5: Otoyolda Akan Trafik

**Etiketler (keyword eşleşmesi için):** otoyol, teslimat rotası, filo yönetimi, GPS takip
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Çok şeritli bir otoyol üzerinde farklı hızlarda ilerleyen araçlarla canlı bir trafik akışı.

```html
<div class="sutol-loj-05-otoyol">
  <svg viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="30" width="200" height="60" fill="#4a4a52"/>
    <line x1="0" y1="60" x2="200" y2="60" stroke="#f0d24a" stroke-width="2" stroke-dasharray="10 8"/>
    <rect x="-20" y="38" width="26" height="12" rx="3" fill="#d65b5b" class="sutol-loj-05-car sutol-loj-05-c1"/>
    <rect x="-20" y="70" width="26" height="12" rx="3" fill="#5b8ad6" class="sutol-loj-05-car sutol-loj-05-c2"/>
    <rect x="-20" y="38" width="26" height="12" rx="3" fill="#5bd68a" class="sutol-loj-05-car sutol-loj-05-c3"/>
    <rect x="-20" y="70" width="26" height="12" rx="3" fill="#e0a05b" class="sutol-loj-05-car sutol-loj-05-c4"/>
  </svg>
</div>
<style>
.sutol-loj-05-otoyol{width:100%;height:100%;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-loj-05-otoyol svg{width:100%;height:100%;}
.sutol-loj-05-car{animation:sutolLoj05Move 3s linear infinite;}
.sutol-loj-05-c2{animation-duration:4s;animation-delay:0.5s;}
.sutol-loj-05-c3{animation-delay:1.5s;}
.sutol-loj-05-c4{animation-duration:4s;animation-delay:2s;}
@keyframes sutolLoj05Move{from{transform:translateX(0);}to{transform:translateX(240px);}}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-05-car{animation-duration:18s !important;}
}
</style>
```

---

## Bileşen 6: Kavşakta Trafik Işığı

**Etiketler (keyword eşleşmesi için):** kavşak, trafik ışığı, otoyol, filo yönetimi
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Kırmızı-sarı-yeşil sırasıyla değişen bir trafik ışığı ve ona göre duran/hareket eden bir araç.

```html
<div class="sutol-loj-06-kavsak">
  <svg viewBox="0 0 200 140" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="80" width="200" height="40" fill="#4a4a52"/>
    <rect x="150" y="30" width="16" height="40" rx="4" fill="#2a2a2a"/>
    <circle cx="158" cy="40" r="5" class="sutol-loj-06-light sutol-loj-06-red" fill="#d65b5b"/>
    <circle cx="158" cy="52" r="5" class="sutol-loj-06-light sutol-loj-06-yellow" fill="#e0c04a"/>
    <circle cx="158" cy="64" r="5" class="sutol-loj-06-light sutol-loj-06-green" fill="#5bd68a"/>
    <rect class="sutol-loj-06-car" x="0" y="92" width="26" height="14" rx="3" fill="#5b8ad6"/>
  </svg>
</div>
<style>
.sutol-loj-06-kavsak{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-06-kavsak svg{width:100%;height:100%;}
.sutol-loj-06-light{opacity:0.25;}
.sutol-loj-06-red{animation:sutolLoj06Red 6s ease-in-out infinite;}
.sutol-loj-06-yellow{animation:sutolLoj06Yellow 6s ease-in-out infinite;}
.sutol-loj-06-green{animation:sutolLoj06Green 6s ease-in-out infinite;}
.sutol-loj-06-car{animation:sutolLoj06Car 6s ease-in-out infinite;}
@keyframes sutolLoj06Red{0%,33%{opacity:1;}34%,100%{opacity:0.25;}}
@keyframes sutolLoj06Yellow{0%,32%{opacity:0.25;}33%,42%{opacity:1;}43%,100%{opacity:0.25;}}
@keyframes sutolLoj06Green{0%,42%{opacity:0.25;}43%,95%{opacity:1;}96%,100%{opacity:0.25;}}
@keyframes sutolLoj06Car{
  0%,40%{transform:translateX(0);}
  95%,100%{transform:translateX(110px);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-06-light,.sutol-loj-06-car{animation-duration:26s;}
}
</style>
```

---

## Bileşen 7: Gökyüzünde Hava Kargo Uçağı

**Etiketler (keyword eşleşmesi için):** hava kargo, teslimat rotası, GPS takip, gümrük
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Bulutların arasından geçerek belirlenmiş rota üzerinde uçan bir hava kargo uçağı. (Teknik: SVG SMIL `animateMotion`)

```html
<div class="sutol-loj-07-havakargo">
  <svg viewBox="0 0 200 140" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <path d="M20,90 Q100,40 180,90" fill="none" stroke="#cfe0f5" stroke-width="1.5" stroke-dasharray="4 6" opacity="0.6"/>
    <ellipse cx="50" cy="30" rx="14" ry="8" fill="#e6eef7" opacity="0.8"/>
    <ellipse cx="150" cy="55" rx="18" ry="9" fill="#e6eef7" opacity="0.8"/>
    <g class="sutol-loj-07-plane">
      <animateMotion dur="6s" repeatCount="indefinite" path="M20,90 Q100,40 180,90" rotate="auto"/>
      <path d="M-18,0 L18,0 L10,-6 L-10,-6 Z" fill="#5b7bd6"/>
      <path d="M0,-3 L-6,-14 L2,-14 L6,-3 Z" fill="#3d5aa0"/>
      <rect x="8" y="-3" width="6" height="4" fill="#e0a05b"/>
    </g>
  </svg>
</div>
<style>
.sutol-loj-07-havakargo{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-07-havakargo svg{width:100%;height:100%;}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-07-plane animateMotion{dur:30s;}
}
</style>
```

---

## Bileşen 8: Dağıtım Merkezinde Bant Sistemi

**Etiketler (keyword eşleşmesi için):** dağıtım merkezi, palet, konteyner, forklift
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Kutuların sürekli bir konveyör bandı üzerinde soldan sağa ilerleyip sıralandığı bir dağıtım merkezi sahnesi.

```html
<div class="sutol-loj-08-dagitim">
  <svg viewBox="0 0 200 120" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="80" width="180" height="10" fill="#5f5f6a"/>
    <circle cx="20" cy="90" r="6" fill="#3a3a42"/>
    <circle cx="180" cy="90" r="6" fill="#3a3a42"/>
    <rect class="sutol-loj-08-box sutol-loj-08-b1" x="-20" y="58" width="22" height="22" rx="2" fill="#e0a05b"/>
    <rect class="sutol-loj-08-box sutol-loj-08-b2" x="-20" y="58" width="22" height="22" rx="2" fill="#5b8ad6"/>
    <rect class="sutol-loj-08-box sutol-loj-08-b3" x="-20" y="58" width="22" height="22" rx="2" fill="#5bd68a"/>
  </svg>
</div>
<style>
.sutol-loj-08-dagitim{width:100%;height:100%;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-loj-08-dagitim svg{width:100%;height:100%;}
.sutol-loj-08-box{animation:sutolLoj08Move 4.5s linear infinite;}
.sutol-loj-08-b2{animation-delay:1.5s;}
.sutol-loj-08-b3{animation-delay:3s;}
@keyframes sutolLoj08Move{from{transform:translateX(0);}to{transform:translateX(220px);}}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-08-box{animation-duration:22s;}
}
</style>
```

---
## Bileşen 9: Forklift Palet Taşıyor

**Etiketler (keyword eşleşmesi için):** forklift, palet, dağıtım merkezi, konteyner
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Çatalıyla bir paleti kaldırıp indiren, ileri geri hareket eden bir forklift.

```html
<div class="sutol-loj-09-forklift">
  <svg viewBox="0 0 200 140" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="120" width="200" height="6" fill="#8a8a8a"/>
    <g class="sutol-loj-09-truck">
      <rect x="20" y="85" width="45" height="28" rx="4" fill="#e0c04a"/>
      <circle cx="30" cy="115" r="7" fill="#2a2a2a"/>
      <circle cx="55" cy="115" r="7" fill="#2a2a2a"/>
      <rect x="60" y="60" width="6" height="55" fill="#5f5f6a"/>
      <g class="sutol-loj-09-fork">
        <rect x="55" y="0" width="18" height="6" fill="#5f5f6a"/>
        <rect class="sutol-loj-09-pallet" x="50" y="-24" width="28" height="18" rx="2" fill="#a08055"/>
      </g>
    </g>
  </svg>
</div>
<style>
.sutol-loj-09-forklift{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-09-forklift svg{width:100%;height:100%;}
.sutol-loj-09-truck{animation:sutolLoj09Drive 6s ease-in-out infinite;}
.sutol-loj-09-fork{transform-box:fill-box;transform-origin:bottom;animation:sutolLoj09Lift 6s ease-in-out infinite;}
@keyframes sutolLoj09Drive{0%,20%{transform:translateX(0);}50%,70%{transform:translateX(60px);}100%{transform:translateX(0);}}
@keyframes sutolLoj09Lift{0%,15%{transform:translateY(0);}35%,60%{transform:translateY(-30px);}80%,100%{transform:translateY(0);}}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-09-truck,.sutol-loj-09-fork{animation-duration:26s;}
}
</style>
```

---

## Bileşen 10: Haritada Teslimat Rotası

**Etiketler (keyword eşleşmesi için):** teslimat rotası, GPS takip, otoyol, filo yönetimi
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Bir dağıtım merkezinden müşteriye kadar kıvrılan bir yol üzerinde ilerleyen bir teslimat aracı. (Teknik: CSS `offset-path`)

```html
<div class="sutol-loj-10-teslimatrota">
  <svg viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <path d="M30,130 C60,90 40,60 80,50 C120,40 130,80 170,40"
          fill="none" stroke="#cfd6e0" stroke-width="8" stroke-linecap="round"/>
    <path d="M30,130 C60,90 40,60 80,50 C120,40 130,80 170,40"
          fill="none" stroke="#eef2f6" stroke-width="2" stroke-dasharray="6 6"/>
    <circle cx="30" cy="130" r="7" fill="#5b8ad6"/>
    <circle cx="170" cy="40" r="7" fill="#d65b8a"/>
  </svg>
  <div class="sutol-loj-10-truck"></div>
</div>
<style>
.sutol-loj-10-teslimatrota{position:relative;width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-10-teslimatrota svg{width:100%;height:100%;}
.sutol-loj-10-truck::before{
  content:'';position:absolute;width:14px;height:10px;border-radius:2px;background:#e0a05b;
  offset-path:path('M30,130 C60,90 40,60 80,50 C120,40 130,80 170,40');
  offset-rotate:auto;
  animation:sutolLoj10Move 5s ease-in-out infinite;
}
@keyframes sutolLoj10Move{
  0%{offset-distance:0%;}
  100%{offset-distance:100%;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-10-truck::before{animation-duration:22s;}
}
</style>
```

---

## Bileşen 11: GPS Konum Takibi

**Etiketler (keyword eşleşmesi için):** GPS takip, filo yönetimi, teslimat rotası, otoyol
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Bir harita üzerinde sabit bir konum işaretinin etrafına dairesel bir radar taraması yaydığı bir GPS takip animasyonu.

```html
<div class="sutol-loj-11-gps">
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="20" y="20" width="160" height="160" rx="10" fill="#eef3fa" stroke="#cfd8e6" stroke-width="2"/>
    <path d="M20,80 L90,60 L140,90 L180,70 M20,140 L70,130 L130,150 L180,130" stroke="#cfd8e6" stroke-width="2" fill="none"/>
    <circle cx="100" cy="100" r="55" fill="none" stroke="#5b8ad6" stroke-width="2" class="sutol-loj-11-radar sutol-loj-11-r1"/>
    <circle cx="100" cy="100" r="55" fill="none" stroke="#5b8ad6" stroke-width="2" class="sutol-loj-11-radar sutol-loj-11-r2"/>
    <path d="M100,80 C112,80 120,90 120,100 C120,112 100,132 100,132 C100,132 80,112 80,100 C80,90 88,80 100,80 Z" fill="#d65b5b"/>
    <circle cx="100" cy="99" r="7" fill="#fff"/>
  </svg>
</div>
<style>
.sutol-loj-11-gps{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-11-gps svg{width:100%;height:100%;}
.sutol-loj-11-radar{transform-origin:100px 100px;animation:sutolLoj11Sweep 3s ease-out infinite;}
.sutol-loj-11-r2{animation-delay:1.5s;}
@keyframes sutolLoj11Sweep{0%{transform:scale(0.3);opacity:0.9;}100%{transform:scale(1);opacity:0;}}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-11-radar{animation-duration:14s;}
}
</style>
```

---

## Bileşen 12: Filo Yönetim Panosu

**Etiketler (keyword eşleşmesi için):** filo yönetimi, GPS takip, teslimat rotası, otoyol
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Bir yol ağı üzerinde birden fazla aracın eş zamanlı olarak izlendiği canlı bir filo yönetim haritası. (Teknik: Canvas + `requestAnimationFrame`)

```html
<div class="sutol-loj-12-filo">
  <canvas class="sutol-loj-12-canvas"></canvas>
</div>
<style>
.sutol-loj-12-filo{width:100%;height:100%;position:relative;}
.sutol-loj-12-canvas{width:100%;height:100%;display:block;}
</style>
<script>
(function(){
  var root = document.currentScript.previousElementSibling;
  var canvas = root.querySelector('.sutol-loj-12-canvas');
  var ctx = canvas.getContext('2d');
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function resize(){
    var rect = root.getBoundingClientRect();
    canvas.width = Math.max(rect.width,1) * (window.devicePixelRatio || 1);
    canvas.height = Math.max(rect.height,1) * (window.devicePixelRatio || 1);
  }
  resize();
  window.addEventListener('resize', resize);

  var roads = [
    {a:{x:0.1,y:0.3}, b:{x:0.9,y:0.3}},
    {a:{x:0.1,y:0.7}, b:{x:0.9,y:0.7}},
    {a:{x:0.3,y:0.1}, b:{x:0.3,y:0.9}},
    {a:{x:0.7,y:0.1}, b:{x:0.7,y:0.9}}
  ];
  var vehicles = [
    {road:0, phase:0, color:'#d65b5b'},
    {road:1, phase:0.4, color:'#5b8ad6'},
    {road:2, phase:0.2, color:'#5bd68a'},
    {road:3, phase:0.6, color:'#e0a05b'}
  ];
  var t = 0;
  var speed = reduceMotion ? 0.0015 : 0.005;

  function draw(){
    var w = canvas.width, h = canvas.height;
    ctx.clearRect(0,0,w,h);
    ctx.strokeStyle = 'rgba(150,160,180,0.4)';
    ctx.lineWidth = w*0.012;
    roads.forEach(function(r){
      ctx.beginPath();
      ctx.moveTo(r.a.x*w,r.a.y*h);
      ctx.lineTo(r.b.x*w,r.b.y*h);
      ctx.stroke();
    });
    vehicles.forEach(function(v){
      var r = roads[v.road];
      var frac = (t + v.phase) % 1;
      var pf = frac < 0.5 ? frac*2 : (1-frac)*2;
      var x = r.a.x + (r.b.x-r.a.x)*pf;
      var y = r.a.y + (r.b.y-r.a.y)*pf;
      ctx.fillStyle = v.color;
      ctx.beginPath();
      ctx.arc(x*w,y*h,w*0.02,0,Math.PI*2);
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
## Bileşen 13: Gümrük Kontrol Noktası

**Etiketler (keyword eşleşmesi için):** gümrük, konteyner, kargo gemisi, liman
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Bir konteynerin geçişine izin vermek için sürekli açılıp kapanan bir gümrük kontrol bariyeri.

```html
<div class="sutol-loj-13-gumruk">
  <svg viewBox="0 0 200 140" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="0" y="100" width="200" height="10" fill="#8a8a8a"/>
    <rect x="30" y="50" width="10" height="55" fill="#3d4d78"/>
    <g class="sutol-loj-13-bariyer" transform="translate(35,55)">
      <rect x="0" y="-4" width="80" height="8" rx="3" fill="#e0546f"/>
      <rect x="0" y="-4" width="15" height="8" fill="#fff"/>
      <rect x="25" y="-4" width="15" height="8" fill="#fff"/>
      <rect x="50" y="-4" width="15" height="8" fill="#fff"/>
    </g>
    <rect class="sutol-loj-13-konteyner" x="-30" y="82" width="34" height="20" rx="2" fill="#5b8ad6"/>
  </svg>
</div>
<style>
.sutol-loj-13-gumruk{width:100%;height:100%;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-loj-13-gumruk svg{width:100%;height:100%;}
.sutol-loj-13-bariyer{transform-origin:0 55px;animation:sutolLoj13Gate 6s ease-in-out infinite;}
.sutol-loj-13-konteyner{animation:sutolLoj13Pass 6s ease-in-out infinite;}
@keyframes sutolLoj13Gate{
  0%,20%{transform:rotate(0deg);}
  35%,65%{transform:rotate(-70deg);}
  80%,100%{transform:rotate(0deg);}
}
@keyframes sutolLoj13Pass{
  0%,25%{transform:translateX(0);}
  75%,100%{transform:translateX(220px);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-13-bariyer,.sutol-loj-13-konteyner{animation-duration:26s;}
}
</style>
```

---

## Bileşen 14: Liman Sahasında Hareketli Vinç

**Etiketler (keyword eşleşmesi için):** liman, konteyner, kargo gemisi, dağıtım merkezi
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Raylar üzerinde yatay olarak ileri geri hareket eden geniş bir liman sahası vinci (gantry crane).

```html
<div class="sutol-loj-14-gantry">
  <svg viewBox="0 0 200 140" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <line x1="0" y1="130" x2="200" y2="130" stroke="#8a8a8a" stroke-width="4"/>
    <rect x="10" y="105" width="45" height="25" rx="2" fill="#5b8ad6"/>
    <rect x="60" y="105" width="45" height="25" rx="2" fill="#5bd68a"/>
    <rect x="110" y="105" width="45" height="25" rx="2" fill="#e0a05b"/>
    <g class="sutol-loj-14-crane">
      <rect x="-3" y="20" width="6" height="90" fill="#e0546f"/>
      <rect x="47" y="20" width="6" height="90" fill="#e0546f"/>
      <rect x="-10" y="15" width="70" height="8" fill="#e0546f"/>
      <line x1="25" y1="23" x2="25" y2="55" stroke="#5f5f6a" stroke-width="2"/>
      <rect x="12" y="55" width="26" height="16" rx="2" fill="#d6d6d6" stroke="#5f5f6a" stroke-width="1.5"/>
    </g>
  </svg>
</div>
<style>
.sutol-loj-14-gantry{width:100%;height:100%;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-loj-14-gantry svg{width:100%;height:100%;}
.sutol-loj-14-crane{animation:sutolLoj14Slide 8s ease-in-out infinite;}
@keyframes sutolLoj14Slide{
  0%,15%{transform:translateX(0);}
  45%,55%{transform:translateX(90px);}
  85%,100%{transform:translateX(0);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-14-crane{animation-duration:32s;}
}
</style>
```

---

## Bileşen 15: Depo Koridorunda Forklift

**Etiketler (keyword eşleşmesi için):** forklift, dağıtım merkezi, palet, konteyner
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Raflar arasındaki dar bir depo koridorunda ileri geri gidip gelerek palet taşıyan bir forklift.

```html
<div class="sutol-loj-15-depo">
  <svg viewBox="0 0 200 140" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="20" width="30" height="100" fill="#c9c9d2" stroke="#8a8a94" stroke-width="2"/>
    <rect x="160" y="20" width="30" height="100" fill="#c9c9d2" stroke="#8a8a94" stroke-width="2"/>
    <rect x="14" y="30" width="22" height="16" fill="#e0a05b"/>
    <rect x="14" y="55" width="22" height="16" fill="#5b8ad6"/>
    <rect x="164" y="30" width="22" height="16" fill="#5bd68a"/>
    <rect x="164" y="55" width="22" height="16" fill="#d65b8a"/>
    <g class="sutol-loj-15-forklift">
      <rect x="0" y="100" width="24" height="16" rx="3" fill="#e0c04a"/>
      <rect x="24" y="88" width="4" height="28" fill="#5f5f6a"/>
      <rect x="24" y="86" width="10" height="4" fill="#5f5f6a"/>
      <rect x="26" y="82" width="14" height="10" fill="#a08055"/>
    </g>
  </svg>
</div>
<style>
.sutol-loj-15-depo{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-15-depo svg{width:100%;height:100%;}
.sutol-loj-15-forklift{animation:sutolLoj15Move 5s ease-in-out infinite;}
@keyframes sutolLoj15Move{
  0%,15%{transform:translateX(0);}
  50%,65%{transform:translateX(120px);}
  100%{transform:translateX(0);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-15-forklift{animation-duration:22s;}
}
</style>
```

---

## Bileşen 16: Otoyol Kavşağı Kuşbakışı

**Etiketler (keyword eşleşmesi için):** kavşak, otoyol, GPS takip, teslimat rotası
**Kategori:** Ulaşım & Lojistik
**Açıklama:** İç içe geçmiş rampalarıyla bir otoyol kavşağının kuşbakışı görünümü ve üzerinde ilerleyen bir araç. (Teknik: `stroke-dasharray` yol çizimi + CSS `offset-path`)

```html
<div class="sutol-loj-16-kavsakust">
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-loj-16-ramp" d="M20,100 L80,100 C110,100 110,60 80,60 C50,60 50,20 80,20 L180,20"
          fill="none" stroke="#8a8a94" stroke-width="10" stroke-linecap="round"/>
    <path d="M20,140 L120,140 C150,140 150,180 120,180 L180,180"
          fill="none" stroke="#8a8a94" stroke-width="10" stroke-linecap="round"/>
  </svg>
  <div class="sutol-loj-16-car"></div>
</div>
<style>
.sutol-loj-16-kavsakust{position:relative;width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-16-kavsakust svg{width:100%;height:100%;}
.sutol-loj-16-ramp{
  stroke-dasharray:340;
  stroke-dashoffset:340;
  animation:sutolLoj16Draw 6s ease-in-out infinite;
}
.sutol-loj-16-car::before{
  content:'';position:absolute;width:8px;height:8px;border-radius:50%;background:#d65b5b;
  offset-path:path('M20,100 L80,100 C110,100 110,60 80,60 C50,60 50,20 80,20 L180,20');
  animation:sutolLoj16Move 6s ease-in-out infinite;
}
@keyframes sutolLoj16Draw{
  0%{stroke-dashoffset:340;}
  60%,100%{stroke-dashoffset:0;}
}
@keyframes sutolLoj16Move{
  0%{offset-distance:0%;opacity:0;}
  10%{opacity:1;}
  90%{opacity:1;}
  100%{offset-distance:100%;opacity:0;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-16-ramp{animation-duration:26s;}
  .sutol-loj-16-car::before{animation-duration:26s;}
}
</style>
```

---
## Bileşen 17: Depoda Barkod Tarama

**Etiketler (keyword eşleşmesi için):** dağıtım merkezi, konteyner, palet, GPS takip
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Bir kutunun üzerindeki barkodu yukarıdan aşağıya tarayan kırmızı bir lazer çizgisi.

```html
<div class="sutol-loj-17-barkod">
  <svg viewBox="0 0 200 140" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="60" y="40" width="80" height="60" rx="4" fill="#e0c88a" stroke="#a08055" stroke-width="2"/>
    <g stroke="#4a3a25" stroke-width="3">
      <line x1="75" y1="55" x2="75" y2="85"/>
      <line x1="83" y1="55" x2="83" y2="85"/>
      <line x1="93" y1="55" x2="93" y2="85"/>
      <line x1="100" y1="55" x2="100" y2="85"/>
      <line x1="110" y1="55" x2="110" y2="85"/>
      <line x1="120" y1="55" x2="120" y2="85"/>
    </g>
    <line class="sutol-loj-17-scan" x1="60" y1="45" x2="140" y2="45" stroke="#d65b5b" stroke-width="3"/>
  </svg>
</div>
<style>
.sutol-loj-17-barkod{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-17-barkod svg{width:100%;height:100%;}
.sutol-loj-17-scan{animation:sutolLoj17Scan 2.4s ease-in-out infinite;filter:drop-shadow(0 0 3px rgba(214,91,91,0.8));}
@keyframes sutolLoj17Scan{
  0%,100%{transform:translateY(0);opacity:0.9;}
  50%{transform:translateY(50px);opacity:1;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-17-scan{animation-duration:12s;}
}
</style>
```

---

## Bileşen 18: Deniz-Kara-Hava Bağlantısı (İntermodal Taşımacılık)

**Etiketler (keyword eşleşmesi için):** kargo gemisi, tren rayı, hava kargo, teslimat rotası
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Aynı yükün gemi, tren ve uçak arasında sırayla el değiştirdiği bir çok modlu (intermodal) taşımacılık döngüsü.

```html
<div class="sutol-loj-18-intermodal">
  <svg viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-loj-18-mode sutol-loj-18-m1">
      <path d="M40,100 L160,100 L145,115 L55,115 Z" fill="#3d4d78"/>
      <rect x="70" y="80" width="18" height="20" fill="#e0a05b"/>
      <rect x="95" y="80" width="18" height="20" fill="#5bd68a"/>
    </g>
    <g class="sutol-loj-18-mode sutol-loj-18-m2">
      <rect x="60" y="90" width="30" height="22" rx="3" fill="#5b8ad6"/>
      <rect x="95" y="94" width="30" height="18" rx="2" fill="#e0a05b"/>
      <circle cx="70" cy="112" r="5" fill="#2a2a2a"/>
      <circle cx="105" cy="112" r="5" fill="#2a2a2a"/>
    </g>
    <g class="sutol-loj-18-mode sutol-loj-18-m3">
      <path d="M40,100 L160,100 L145,90 L120,90 L110,100 L90,100 L82,88 L60,88 Z" fill="#e6eef7" stroke="#8fa8d6" stroke-width="1.5"/>
    </g>
  </svg>
</div>
<style>
.sutol-loj-18-intermodal{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-18-intermodal svg{width:100%;height:100%;}
.sutol-loj-18-mode{opacity:0;animation:sutolLoj18Cycle 9s ease-in-out infinite;}
.sutol-loj-18-m2{animation-delay:3s;}
.sutol-loj-18-m3{animation-delay:6s;}
@keyframes sutolLoj18Cycle{
  0%,4%{opacity:0;}
  8%,25%{opacity:1;}
  30%,100%{opacity:0;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-18-mode{animation-duration:36s;}
}
</style>
```

---

## Bileşen 19: Otomatik Depo Robot Kolu

**Etiketler (keyword eşleşmesi için):** dağıtım merkezi, palet, konteyner, filo yönetimi
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Kutuları tek tek kavrayıp bir bant üzerine yerleştiren otomatik bir depo robot kolu.

```html
<div class="sutol-loj-19-robotkol">
  <svg viewBox="0 0 200 160" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <rect x="70" y="140" width="60" height="12" rx="3" fill="#5f5f6a"/>
    <rect x="90" y="120" width="20" height="20" fill="#e0a05b"/>
    <g class="sutol-loj-19-arm1" transform="translate(100,140)">
      <rect x="-6" y="-45" width="12" height="45" rx="4" fill="#5b7bd6"/>
      <g class="sutol-loj-19-arm2" transform="translate(0,-45)">
        <rect x="-5" y="-40" width="10" height="40" rx="4" fill="#7fa0f0"/>
        <g class="sutol-loj-19-gripper" transform="translate(0,-40)">
          <rect x="-14" y="-6" width="10" height="14" rx="2" fill="#3d4d78"/>
          <rect x="4" y="-6" width="10" height="14" rx="2" fill="#3d4d78"/>
        </g>
      </g>
    </g>
  </svg>
</div>
<style>
.sutol-loj-19-robotkol{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-19-robotkol svg{width:100%;height:100%;}
.sutol-loj-19-arm1{animation:sutolLoj19Base 5s ease-in-out infinite;transform-origin:100px 140px;}
.sutol-loj-19-arm2{animation:sutolLoj19Elbow 5s ease-in-out infinite;transform-origin:0 -45px;}
.sutol-loj-19-gripper{animation:sutolLoj19Grip 5s ease-in-out infinite;transform-origin:0 -40px;}
@keyframes sutolLoj19Base{0%,20%{transform:translate(100px,140px) rotate(-20deg);}50%,70%{transform:translate(100px,140px) rotate(20deg);}100%{transform:translate(100px,140px) rotate(-20deg);}}
@keyframes sutolLoj19Elbow{0%,20%{transform:translate(0,-45px) rotate(10deg);}50%,70%{transform:translate(0,-45px) rotate(-25deg);}100%{transform:translate(0,-45px) rotate(10deg);}}
@keyframes sutolLoj19Grip{0%,15%,85%,100%{transform:translate(0,-40px) scale(1);}25%,60%{transform:translate(0,-40px) scale(0.85);}}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-19-arm1,.sutol-loj-19-arm2,.sutol-loj-19-gripper{animation-duration:24s;}
}
</style>
```

---

## Bileşen 20: Teslimat İlerleme Çubuğu

**Etiketler (keyword eşleşmesi için):** teslimat rotası, GPS takip, hava kargo, otoyol
**Kategori:** Ulaşım & Lojistik
**Açıklama:** Başlangıçtan varış noktasına kadar dolan bir çubuk üzerinde ilerleyen küçük bir teslimat aracı simgesiyle kargonun teslimat durumunu gösteren bir ilerleme göstergesi.

```html
<div class="sutol-loj-20-ilerleme">
  <svg viewBox="0 0 200 100" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
    <circle cx="25" cy="60" r="8" fill="#5b8ad6"/>
    <circle cx="175" cy="60" r="8" fill="#d65b8a"/>
    <line x1="25" y1="60" x2="175" y2="60" stroke="#dfe4ea" stroke-width="8" stroke-linecap="round"/>
    <line class="sutol-loj-20-fill" x1="25" y1="60" x2="175" y2="60" stroke="#5bd68a" stroke-width="8" stroke-linecap="round"
          stroke-dasharray="150" stroke-dashoffset="150"/>
    <g class="sutol-loj-20-van">
      <rect x="-12" y="-8" width="24" height="14" rx="3" fill="#e0a05b"/>
      <circle cx="-6" cy="8" r="3.5" fill="#2a2a2a"/>
      <circle cx="6" cy="8" r="3.5" fill="#2a2a2a"/>
    </g>
  </svg>
</div>
<style>
.sutol-loj-20-ilerleme{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
.sutol-loj-20-ilerleme svg{width:100%;height:100%;}
.sutol-loj-20-fill{animation:sutolLoj20Fill 5s ease-in-out infinite;}
.sutol-loj-20-van{animation:sutolLoj20Van 5s ease-in-out infinite;transform:translate(25px,52px);}
@keyframes sutolLoj20Fill{
  0%{stroke-dashoffset:150;}
  90%,100%{stroke-dashoffset:0;}
}
@keyframes sutolLoj20Van{
  0%{transform:translate(25px,52px);}
  90%,100%{transform:translate(175px,52px);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-loj-20-fill,.sutol-loj-20-van{animation-duration:24s;}
}
</style>
```

---

## Kalite Kontrol Özeti

1. **Açık Denizde Kargo Gemisi** — CSS keyframes (gemi sallanması + dalga `translateX` döngüsü).
2. **Liman Vinci** — CSS keyframes (troli kayması + kablo/konteyner `scaleY` kaldırma).
3. **İstiflenen Konteynerler** — CSS keyframes sıralı `opacity`/`scale` parıltısı.
4. **Kargo Treni** — SVG SMIL `animateMotion` (düz rota boyunca sürekli hareket).
5. **Otoyolda Akan Trafik** — CSS keyframes çoklu şerit `translateX`, farklı hız/gecikmeler.
6. **Kavşakta Trafik Işığı** — CSS keyframes sıralı renk döngüsü + araç dur/kalk hareketi.
7. **Hava Kargo Uçağı** — SVG SMIL `animateMotion` (`rotate="auto"` ile rotaya hizalanan uçuş).
8. **Dağıtım Merkezi Bant Sistemi** — CSS keyframes kutu `translateX` konveyör döngüsü.
9. **Forklift Palet Taşıma** — CSS keyframes gövde hareketi + çatal `translateY` kaldırma.
10. **Haritada Teslimat Rotası** — CSS `offset-path` (`offset-rotate:auto` ile yöne dönük araç).
11. **GPS Konum Takibi** — CSS keyframes radar `scale`/`opacity` taraması.
12. **Filo Yönetim Panosu** — Canvas + `requestAnimationFrame`, çoklu araç, DPI ölçekli.
13. **Gümrük Kontrol Noktası** — CSS keyframes bariyer `rotate` + konteyner geçiş `translateX`.
14. **Liman Sahası Vinci** — CSS keyframes yatay `translateX` gantry hareketi.
15. **Depo Koridorunda Forklift** — CSS keyframes ileri-geri `translateX` hareketi.
16. **Otoyol Kavşağı Kuşbakışı** — `stroke-dasharray` yol çizimi + CSS `offset-path` araç hareketi.
17. **Depoda Barkod Tarama** — CSS keyframes `translateY` lazer tarama çizgisi.
18. **İntermodal Taşımacılık** — CSS keyframes 3 aşamalı `opacity` çapraz geçiş döngüsü.
19. **Otomatik Depo Robot Kolu** — CSS keyframes iç içe `transform-origin` zincirleme rotasyon + kavrama `scale`.
20. **Teslimat İlerleme Çubuğu** — CSS keyframes `stroke-dashoffset` dolum + araç ikonu `translateX` senkronu.

**Genel performans notu:** Tüm bileşenler `transform`, `opacity` ve `stroke-dash*` gibi GPU dostu özellikleri kullanır; `setInterval` kullanılmamıştır. Canvas tabanlı bileşen (12) `devicePixelRatio` ile ölçeklenir ve `resize` olayına duyarlıdır. Tüm bileşenlerde `prefers-reduced-motion: reduce` sorgusu animasyon sürelerini belirgin biçimde uzatarak hareketi en aza indirir. Hiçbir bileşen dış kaynak, sabit metin veya global CSS seçici içermez; tüm sınıflar `sutol-loj-NN-...` öneki ile kapsüllenmiştir.
