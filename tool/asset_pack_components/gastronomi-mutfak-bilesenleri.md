# Sutol – Gastronomi & Mutfak Kültürü Kategorisi Bileşen Paketi (20 Adet)

---

## Bileşen 1: Kaynayan Tencere

**Etiketler (keyword eşleşmesi için):** tencere, pişirme, ızgara, tarif
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** İçinden buhar yükselen, kapağı hafifçe titreyen kaynayan bir tencere.

```html
<div class="sutol-gas01-wrap">
  <style>
    .sutol-gas01-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas01-svg{width:100%;height:100%;max-width:260px;}
    .sutol-gas01-lid{animation:sutol-gas01-shake 0.4s ease-in-out infinite;transform-origin:center;}
    .sutol-gas01-s1{animation:sutol-gas01-rise 2.2s ease-in-out infinite;}
    .sutol-gas01-s2{animation:sutol-gas01-rise 2.2s ease-in-out infinite;animation-delay:.5s;}
    .sutol-gas01-s3{animation:sutol-gas01-rise 2.2s ease-in-out infinite;animation-delay:1s;}
    @keyframes sutol-gas01-shake{0%,100%{transform:translateY(0);}50%{transform:translateY(-2px);}}
    @keyframes sutol-gas01-rise{0%{transform:translateY(0);opacity:0;}30%{opacity:.8;}100%{transform:translateY(-30px);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas01-lid,.sutol-gas01-s1,.sutol-gas01-s2,.sutol-gas01-s3{animation:none;}
    }
  </style>
  <svg class="sutol-gas01-svg" viewBox="0 0 200 160">
    <path class="sutol-gas01-s1" d="M75,80 Q70,65 78,50" stroke="#dfe3ea" stroke-width="3" fill="none" stroke-linecap="round"/>
    <path class="sutol-gas01-s2" d="M100,80 Q95,65 103,50" stroke="#dfe3ea" stroke-width="3" fill="none" stroke-linecap="round"/>
    <path class="sutol-gas01-s3" d="M125,80 Q120,65 128,50" stroke="#dfe3ea" stroke-width="3" fill="none" stroke-linecap="round"/>
    <path d="M50,90 L60,140 Q100,150 140,140 L150,90 Z" fill="#8a8fa3"/>
    <rect x="30" y="80" width="140" height="14" rx="4" fill="#5a6072"/>
    <line x1="20" y1="86" x2="30" y2="86" stroke="#5a6072" stroke-width="6"/>
    <line x1="170" y1="86" x2="180" y2="86" stroke="#5a6072" stroke-width="6"/>
    <g class="sutol-gas01-lid">
      <ellipse cx="100" cy="80" rx="52" ry="10" fill="#c9cfd9"/>
      <rect x="95" y="65" width="10" height="12" rx="3" fill="#c9cfd9"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 2: Doğrama Tahtası

**Etiketler:** bıçak, doğrama tahtası, tarif, pişirme
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir doğrama tahtası üzerinde ritmik olarak inip kalkan bir şef bıçağı.

```html
<div class="sutol-gas02-wrap">
  <style>
    .sutol-gas02-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas02-svg{width:100%;height:100%;max-width:280px;}
    .sutol-gas02-knife{animation:sutol-gas02-chop 1s ease-in-out infinite;transform-origin:150px 60px;}
    @keyframes sutol-gas02-chop{0%,100%{transform:rotate(-18deg);}50%{transform:rotate(2deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas02-knife{animation:none;}
    }
  </style>
  <svg class="sutol-gas02-svg" viewBox="0 0 220 140">
    <rect x="20" y="100" width="180" height="18" rx="4" fill="#c9a876"/>
    <circle cx="70" cy="105" r="8" fill="#57c48b"/>
    <circle cx="95" cy="103" r="8" fill="#e6685a"/>
    <circle cx="120" cy="106" r="8" fill="#57c48b"/>
    <g class="sutol-gas02-knife">
      <polygon points="70,20 150,55 70,60" fill="#c9cfd9"/>
      <rect x="60" y="55" width="30" height="10" rx="3" fill="#5a6072"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 3: Mayalanan Hamur

**Etiketler:** mayalanma, hamur, ekmek, fırın
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir kâsedeki hamurun yavaşça şişip kabarmasını gösteren mayalanma döngüsü.

```html
<div class="sutol-gas03-wrap">
  <style>
    .sutol-gas03-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas03-svg{width:100%;height:100%;max-width:260px;}
    .sutol-gas03-dough{animation:sutol-gas03-rise 4s ease-in-out infinite;transform-origin:100px 110px;}
    @keyframes sutol-gas03-rise{0%,100%{transform:scale(1);}50%{transform:scale(1.25) translateY(-10px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas03-dough{animation:none;}
    }
  </style>
  <svg class="sutol-gas03-svg" viewBox="0 0 200 160">
    <path d="M40,110 Q40,150 100,150 Q160,150 160,110 Z" fill="#dfe3ea"/>
    <g class="sutol-gas03-dough">
      <ellipse cx="100" cy="105" rx="55" ry="35" fill="#f2e6c9"/>
      <path d="M70,100 Q100,85 130,100" stroke="#e4d6b8" stroke-width="2" fill="none"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 4: Fırın Sıcaklığı

**Etiketler:** fırın, ekmek, pişirme, tarif
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** İçinde ekmeğin piştiği bir fırının camından yayılan sıcak parıltı.

```html
<div class="sutol-gas04-wrap">
  <style>
    .sutol-gas04-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas04-svg{width:100%;height:100%;max-width:280px;}
    .sutol-gas04-glow{animation:sutol-gas04-pulse 2.2s ease-in-out infinite;}
    @keyframes sutol-gas04-pulse{0%,100%{opacity:.45;}50%{opacity:.85;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas04-glow{animation:none;}
    }
  </style>
  <svg class="sutol-gas04-svg" viewBox="0 0 200 160">
    <rect x="20" y="20" width="160" height="120" rx="8" fill="#3d4a6b"/>
    <rect x="35" y="35" width="130" height="90" rx="6" fill="#2b2f4a"/>
    <ellipse class="sutol-gas04-glow" cx="100" cy="90" rx="55" ry="30" fill="#f6c453"/>
    <ellipse cx="100" cy="92" rx="34" ry="16" fill="#c9a876"/>
    <circle cx="150" cy="55" r="5" fill="#8a8fa3"/>
  </svg>
</div>
```

---

## Bileşen 5: Izgara Şişi

**Etiketler:** ızgara, pişirme, street food, sos
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Kor ateş üzerinde dönen bir şiş ve titreşen alevlerin bulunduğu ızgara sahnesi.

```html
<div class="sutol-gas05-wrap">
  <style>
    .sutol-gas05-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas05-svg{width:100%;height:100%;max-width:280px;}
    .sutol-gas05-skewer{animation:sutol-gas05-spin 3s linear infinite;transform-origin:100px 70px;}
    .sutol-gas05-flame{animation:sutol-gas05-flick 0.8s ease-in-out infinite alternate;transform-origin:bottom;}
    @keyframes sutol-gas05-spin{to{transform:rotate(360deg);}}
    @keyframes sutol-gas05-flick{0%{transform:scaleY(1);}100%{transform:scaleY(1.25);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas05-skewer,.sutol-gas05-flame{animation:none;}
    }
  </style>
  <svg class="sutol-gas05-svg" viewBox="0 0 200 160">
    <rect x="20" y="110" width="160" height="16" fill="#5a6072"/>
    <g class="sutol-gas05-flame">
      <polygon points="60,110 70,80 80,110" fill="#f6c453"/>
      <polygon points="90,110 100,75 110,110" fill="#e6685a"/>
      <polygon points="120,110 130,80 140,110" fill="#f6c453"/>
    </g>
    <g class="sutol-gas05-skewer">
      <line x1="55" y1="70" x2="145" y2="70" stroke="#8a5a34" stroke-width="4"/>
      <circle cx="70" cy="70" r="9" fill="#e6a97a"/>
      <circle cx="95" cy="70" r="9" fill="#57c48b"/>
      <circle cx="120" cy="70" r="9" fill="#e6685a"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 6: Kavrulan Kahve Çekirdekleri

**Etiketler:** kahve çekirdeği, çay demleme, pişirme, tarif
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir kavurma tamburunda dönerek kararan kahve çekirdeklerinin animasyonu.

```html
<div class="sutol-gas06-wrap">
  <style>
    .sutol-gas06-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas06-svg{width:100%;height:100%;max-width:260px;}
    .sutol-gas06-drum{animation:sutol-gas06-spin 3.4s linear infinite;transform-origin:100px 90px;}
    @keyframes sutol-gas06-spin{to{transform:rotate(360deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas06-drum{animation:none;}
    }
  </style>
  <svg class="sutol-gas06-svg" viewBox="0 0 200 160">
    <g class="sutol-gas06-drum">
      <circle cx="100" cy="90" r="45" fill="#5a3a24"/>
      <ellipse cx="85" cy="80" rx="8" ry="5" fill="#3d2717"/>
      <ellipse cx="115" cy="95" rx="8" ry="5" fill="#3d2717"/>
      <ellipse cx="90" cy="105" rx="8" ry="5" fill="#3d2717"/>
      <ellipse cx="118" cy="70" rx="8" ry="5" fill="#3d2717"/>
    </g>
    <rect x="10" y="80" width="20" height="20" rx="4" fill="#8a8fa3"/>
  </svg>
</div>
```

---

## Bileşen 7: Demlenen Çay

**Etiketler:** çay demleme, sofra, tarif, ziyafet
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir bardağın içinde renk yayarak demlenen çayı gösteren difüzyon animasyonu.

```html
<div class="sutol-gas07-wrap">
  <style>
    .sutol-gas07-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas07-svg{width:100%;height:100%;max-width:220px;}
    .sutol-gas07-color{animation:sutol-gas07-steep 3.4s ease-in-out infinite;transform-origin:bottom;}
    .sutol-gas07-steam{animation:sutol-gas07-rise 2.2s ease-in-out infinite;}
    @keyframes sutol-gas07-steep{0%{transform:scaleY(0.15);opacity:.4;}100%{transform:scaleY(1);opacity:1;}}
    @keyframes sutol-gas07-rise{0%{transform:translateY(0);opacity:0;}30%{opacity:.7;}100%{transform:translateY(-24px);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas07-color,.sutol-gas07-steam{animation:none;}
    }
  </style>
  <svg class="sutol-gas07-svg" viewBox="0 0 140 180">
    <path class="sutol-gas07-steam" d="M55,90 Q50,75 58,60" stroke="#dfe3ea" stroke-width="3" fill="none" stroke-linecap="round"/>
    <path class="sutol-gas07-steam" d="M85,90 Q80,75 88,60" stroke="#dfe3ea" stroke-width="3" fill="none" stroke-linecap="round"/>
    <path d="M35,95 L45,150 Q70,160 95,150 L105,95 Z" fill="none" stroke="#c3cbdd" stroke-width="3"/>
    <clipPath id="sutol-gas07-clip"><path d="M35,95 L45,150 Q70,160 95,150 L105,95 Z"/></clipPath>
    <g clip-path="url(#sutol-gas07-clip)">
      <rect class="sutol-gas07-color" x="30" y="95" width="80" height="65" fill="#c9871f"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 8: Şarap Mahzeni

**Etiketler:** şarap mahzeni, sofra, ziyafet, tarif
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Raflardaki şişelerden birinin bardağa şarap doldurmasını gösteren mahzen sahnesi.

```html
<div class="sutol-gas08-wrap">
  <style>
    .sutol-gas08-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;overflow:hidden;}
    .sutol-gas08-svg{width:100%;height:100%;max-width:300px;}
    .sutol-gas08-bottle{animation:sutol-gas08-pour 3.6s ease-in-out infinite;transform-origin:150px 60px;}
    .sutol-gas08-stream{animation:sutol-gas08-flow 3.6s ease-in-out infinite;}
    .sutol-gas08-fill{animation:sutol-gas08-fillglass 3.6s ease-in-out infinite;transform-origin:bottom;}
    @keyframes sutol-gas08-pour{0%,25%{transform:rotate(0deg);}50%,70%{transform:rotate(-35deg);}100%{transform:rotate(0deg);}}
    @keyframes sutol-gas08-flow{0%,30%{opacity:0;}50%,70%{opacity:1;}80%,100%{opacity:0;}}
    @keyframes sutol-gas08-fillglass{0%,45%{transform:scaleY(0);}70%,100%{transform:scaleY(1);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas08-bottle,.sutol-gas08-stream,.sutol-gas08-fill{animation:none;}
    }
  </style>
  <svg class="sutol-gas08-svg" viewBox="0 0 240 140">
    <rect x="20" y="20" width="60" height="90" fill="#5a3a24"/>
    <rect x="90" y="20" width="60" height="90" fill="#5a3a24"/>
    <g class="sutol-gas08-bottle">
      <rect x="140" y="30" width="16" height="45" fill="#3f8f61"/>
      <rect x="145" y="18" width="6" height="14" fill="#3f8f61"/>
    </g>
    <line class="sutol-gas08-stream" x1="150" y1="75" x2="165" y2="105" stroke="#8a1f3b" stroke-width="3"/>
    <path d="M155,105 L180,105 L175,130 Q167,136 160,130 Z" fill="none" stroke="#c3cbdd" stroke-width="2"/>
    <g class="sutol-gas08-fill">
      <path d="M158,110 L177,110 L173,128 Q167,133 162,128 Z" fill="#8a1f3b"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 9: Dökülen Baharat

**Etiketler:** baharat, tatlandırıcı, tarif, sos
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir kavanozdan bir kâseye dökülen renkli baharat tanelerinin sürekli akışı.

```html
<div class="sutol-gas09-wrap">
  <style>
    .sutol-gas09-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas09-svg{width:100%;height:100%;max-width:260px;}
    .sutol-gas09-jar{animation:sutol-gas09-tilt 3.4s ease-in-out infinite;transform-origin:60px 60px;}
    .sutol-gas09-p1{animation:sutol-gas09-fall 1.4s ease-in infinite;}
    .sutol-gas09-p2{animation:sutol-gas09-fall 1.4s ease-in infinite;animation-delay:.3s;}
    .sutol-gas09-p3{animation:sutol-gas09-fall 1.4s ease-in infinite;animation-delay:.6s;}
    @keyframes sutol-gas09-tilt{0%,20%{transform:rotate(0deg);}50%,70%{transform:rotate(-40deg);}100%{transform:rotate(0deg);}}
    @keyframes sutol-gas09-fall{0%{transform:translateY(0);opacity:0;}20%{opacity:1;}100%{transform:translateY(50px);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas09-jar,.sutol-gas09-p1,.sutol-gas09-p2,.sutol-gas09-p3{animation:none;}
    }
  </style>
  <svg class="sutol-gas09-svg" viewBox="0 0 200 160">
    <g class="sutol-gas09-jar">
      <rect x="40" y="30" width="40" height="55" rx="6" fill="#e6685a"/>
      <rect x="48" y="20" width="24" height="12" fill="#5a6072"/>
    </g>
    <circle class="sutol-gas09-p1" cx="90" cy="75" r="3" fill="#f6c453"/>
    <circle class="sutol-gas09-p2" cx="95" cy="75" r="3" fill="#e6685a"/>
    <circle class="sutol-gas09-p3" cx="100" cy="75" r="3" fill="#8a5a34"/>
    <path d="M80,120 Q130,140 180,120 L175,100 Q130,115 85,100 Z" fill="#dfe3ea"/>
  </svg>
</div>
```

---

## Bileşen 10: Ziyafet Sofrası

**Etiketler:** sofra, ziyafet, tabak sunumu, tarif
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir masaya sırayla dizilen tabak, bardak ve çatal-bıçağın belirmesiyle sofra kurulumunu gösteren animasyon.

```html
<div class="sutol-gas10-wrap">
  <style>
    .sutol-gas10-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas10-svg{width:100%;height:100%;max-width:300px;}
    .sutol-gas10-i1{animation:sutol-gas10-in 4s ease-in-out infinite;}
    .sutol-gas10-i2{animation:sutol-gas10-in 4s ease-in-out infinite;animation-delay:.4s;}
    .sutol-gas10-i3{animation:sutol-gas10-in 4s ease-in-out infinite;animation-delay:.8s;}
    @keyframes sutol-gas10-in{0%,5%{opacity:0;transform:translateY(10px);}20%,85%{opacity:1;transform:translateY(0);}95%,100%{opacity:0;transform:translateY(10px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas10-i1,.sutol-gas10-i2,.sutol-gas10-i3{animation:none;opacity:1;transform:translateY(0);}
    }
  </style>
  <svg class="sutol-gas10-svg" viewBox="0 0 220 140">
    <rect x="10" y="90" width="200" height="8" rx="3" fill="#c9a876"/>
    <g class="sutol-gas10-i1">
      <circle cx="110" cy="70" r="30" fill="#eef1f7" stroke="#c3cbdd" stroke-width="2"/>
    </g>
    <g class="sutol-gas10-i2">
      <rect x="55" y="45" width="6" height="45" rx="2" fill="#8a8fa3"/>
      <rect x="53" y="45" width="4" height="15" fill="#8a8fa3"/>
      <rect x="59" y="45" width="4" height="15" fill="#8a8fa3"/>
    </g>
    <g class="sutol-gas10-i3">
      <rect x="158" y="45" width="6" height="45" rx="2" fill="#8a8fa3"/>
      <circle cx="180" cy="55" r="10" fill="none" stroke="#5aa9e6" stroke-width="3"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 11: Mutfak Robotu Karıştırma

**Etiketler:** mutfak robotu, hamur, tarif, pişirme
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir mikser kancasının kâse içinde dönerek karışım yapmasını gösteren animasyon.

```html
<div class="sutol-gas11-wrap">
  <style>
    .sutol-gas11-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas11-svg{width:100%;height:100%;max-width:260px;}
    .sutol-gas11-hook{animation:sutol-gas11-mix 1.6s linear infinite;transform-origin:100px 95px;}
    @keyframes sutol-gas11-mix{to{transform:rotate(360deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas11-hook{animation:none;}
    }
  </style>
  <svg class="sutol-gas11-svg" viewBox="0 0 200 160">
    <path d="M55,95 Q55,140 100,140 Q145,140 145,95 Z" fill="#eef1f7" stroke="#c3cbdd" stroke-width="2"/>
    <ellipse cx="100" cy="95" rx="45" ry="10" fill="#f2e6c9"/>
    <rect x="90" y="20" width="20" height="40" fill="#5a6072"/>
    <rect x="70" y="10" width="60" height="16" rx="4" fill="#3d4a6b"/>
    <g class="sutol-gas11-hook">
      <path d="M100,60 Q115,80 100,100 Q85,80 100,60" fill="none" stroke="#8a8fa3" stroke-width="4"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 12: Sos Damlatma

**Etiketler:** sos, tabak sunumu, tatlandırıcı, tarif
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir tabak üzerine zikzak çizerek dökülen sosun sürekli tekrarlanan sunumu.

```html
<div class="sutol-gas12-wrap">
  <style>
    .sutol-gas12-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas12-svg{width:100%;height:100%;max-width:280px;}
    .sutol-gas12-sauce{stroke-dasharray:140;animation:sutol-gas12-draw 3s ease-in-out infinite;}
    @keyframes sutol-gas12-draw{0%,10%{stroke-dashoffset:140;opacity:0;}20%{opacity:1;}60%,80%{stroke-dashoffset:0;opacity:1;}100%{opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas12-sauce{animation:none;stroke-dashoffset:0;opacity:.8;}
    }
  </style>
  <svg class="sutol-gas12-svg" viewBox="0 0 200 160">
    <circle cx="100" cy="90" r="65" fill="#eef1f7" stroke="#c3cbdd" stroke-width="3"/>
    <path class="sutol-gas12-sauce" d="M50,70 Q65,110 85,70 T120,70 T150,70" fill="none" stroke="#e6685a" stroke-width="5" stroke-linecap="round"/>
  </svg>
</div>
```

---

## Bileşen 13: Tabak Sunumu Garnitür

**Etiketler:** tabak sunumu, tarif, sos, füzyon mutfak
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir tabağın üzerine sırayla yerleşen ana yemek, garnitür ve yeşilliklerin şeflik sunumunu gösteren animasyon.

```html
<div class="sutol-gas13-wrap">
  <style>
    .sutol-gas13-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas13-svg{width:100%;height:100%;max-width:280px;}
    .sutol-gas13-main{animation:sutol-gas13-drop 4s ease-in-out infinite;}
    .sutol-gas13-side{animation:sutol-gas13-drop 4s ease-in-out infinite;animation-delay:.5s;}
    .sutol-gas13-herb{animation:sutol-gas13-drop 4s ease-in-out infinite;animation-delay:1s;}
    @keyframes sutol-gas13-drop{0%,10%{opacity:0;transform:translateY(-15px);}25%,85%{opacity:1;transform:translateY(0);}95%,100%{opacity:0;transform:translateY(-15px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas13-main,.sutol-gas13-side,.sutol-gas13-herb{animation:none;opacity:1;transform:translateY(0);}
    }
  </style>
  <svg class="sutol-gas13-svg" viewBox="0 0 200 160">
    <circle cx="100" cy="90" r="65" fill="#eef1f7" stroke="#c3cbdd" stroke-width="3"/>
    <ellipse class="sutol-gas13-main" cx="90" cy="90" rx="30" ry="18" fill="#e6a97a"/>
    <circle class="sutol-gas13-side" cx="135" cy="75" r="10" fill="#57c48b"/>
    <path class="sutol-gas13-herb" d="M70,60 Q80,50 90,60" stroke="#3f8f61" stroke-width="3" fill="none" stroke-linecap="round"/>
  </svg>
</div>
```

---

## Bileşen 14: Füzyon Mutfak

**Etiketler:** füzyon mutfak, tarif, sos, tabak sunumu
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Çubuklar ve çatalın orta noktada buluşup ayrılmasıyla iki mutfak kültürünün harmanlanmasını simgeleyen döngü.

```html
<div class="sutol-gas14-wrap">
  <style>
    .sutol-gas14-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas14-svg{width:100%;height:100%;max-width:280px;}
    .sutol-gas14-l{animation:sutol-gas14-l 3.8s ease-in-out infinite;}
    .sutol-gas14-r{animation:sutol-gas14-r 3.8s ease-in-out infinite;}
    @keyframes sutol-gas14-l{0%,20%{transform:translateX(-30px) rotate(-8deg);}50%,75%{transform:translateX(0) rotate(0deg);}100%{transform:translateX(-30px) rotate(-8deg);}}
    @keyframes sutol-gas14-r{0%,20%{transform:translateX(30px) rotate(8deg);}50%,75%{transform:translateX(0) rotate(0deg);}100%{transform:translateX(30px) rotate(8deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas14-l,.sutol-gas14-r{animation:none;}
    }
  </style>
  <svg class="sutol-gas14-svg" viewBox="0 0 220 140">
    <g class="sutol-gas14-l">
      <line x1="80" y1="30" x2="60" y2="110" stroke="#8a5a34" stroke-width="4"/>
      <line x1="90" y1="30" x2="70" y2="110" stroke="#c9a876" stroke-width="4"/>
    </g>
    <g class="sutol-gas14-r">
      <line x1="150" y1="30" x2="150" y2="80" stroke="#8a8fa3" stroke-width="4"/>
      <line x1="140" y1="30" x2="140" y2="80" stroke="#8a8fa3" stroke-width="3"/>
      <line x1="160" y1="30" x2="160" y2="80" stroke="#8a8fa3" stroke-width="3"/>
      <line x1="150" y1="80" x2="150" y2="110" stroke="#8a8fa3" stroke-width="4"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 15: Sokak Yemeği Arabası

**Etiketler:** street food, ızgara, ekmek, ziyafet
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir sokak yemeği arabasından yükselen buhar ve tekerleklerin hafif titreşimiyle canlı bir sokak sahnesi.

```html
<div class="sutol-gas15-wrap">
  <style>
    .sutol-gas15-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas15-svg{width:100%;height:100%;max-width:300px;}
    .sutol-gas15-steam{animation:sutol-gas15-rise 2.4s ease-in-out infinite;}
    @keyframes sutol-gas15-rise{0%{transform:translateY(0);opacity:0;}30%{opacity:.8;}100%{transform:translateY(-28px);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas15-steam{animation:none;}
    }
  </style>
  <svg class="sutol-gas15-svg" viewBox="0 0 220 140">
    <rect x="30" y="60" width="140" height="55" rx="8" fill="#e6685a"/>
    <rect x="45" y="45" width="60" height="20" rx="4" fill="#f6c453"/>
    <circle cx="60" cy="120" r="12" fill="#2b2f4a"/>
    <circle cx="140" cy="120" r="12" fill="#2b2f4a"/>
    <path class="sutol-gas15-steam" d="M100,60 Q95,45 103,30" stroke="#dfe3ea" stroke-width="3" fill="none" stroke-linecap="round"/>
    <path class="sutol-gas15-steam" d="M120,60 Q115,45 123,30" stroke="#dfe3ea" stroke-width="3" fill="none" stroke-linecap="round" style="animation-delay:.6s;"/>
  </svg>
</div>
```

---

## Bileşen 16: Fermente Gıda Kavanozu

**Etiketler:** fermente gıda, mayalanma, baharat, tarif
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** İçinde küçük kabarcıkların yükseldiği bir fermentasyon kavanozu.

```html
<div class="sutol-gas16-wrap">
  <style>
    .sutol-gas16-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas16-svg{width:100%;height:100%;max-width:220px;}
    .sutol-gas16-b1{animation:sutol-gas16-bubble 2.6s ease-in infinite;}
    .sutol-gas16-b2{animation:sutol-gas16-bubble 2.6s ease-in infinite;animation-delay:.8s;}
    .sutol-gas16-b3{animation:sutol-gas16-bubble 2.6s ease-in infinite;animation-delay:1.6s;}
    @keyframes sutol-gas16-bubble{0%{transform:translateY(0);opacity:0;}20%{opacity:.8;}100%{transform:translateY(-60px);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas16-b1,.sutol-gas16-b2,.sutol-gas16-b3{animation:none;}
    }
  </style>
  <svg class="sutol-gas16-svg" viewBox="0 0 140 180">
    <path d="M35,50 L30,150 Q70,165 110,150 L105,50 Z" fill="none" stroke="#c3cbdd" stroke-width="3"/>
    <clipPath id="sutol-gas16-clip"><path d="M35,50 L30,150 Q70,165 110,150 L105,50 Z"/></clipPath>
    <g clip-path="url(#sutol-gas16-clip)">
      <rect x="25" y="70" width="90" height="90" fill="#8a1f3b" opacity="0.6"/>
      <circle class="sutol-gas16-b1" cx="55" cy="150" r="4" fill="#f2c9a0"/>
      <circle class="sutol-gas16-b2" cx="75" cy="150" r="3" fill="#f2c9a0"/>
      <circle class="sutol-gas16-b3" cx="65" cy="150" r="5" fill="#f2c9a0"/>
    </g>
    <rect x="30" y="38" width="80" height="14" rx="3" fill="#5a6072"/>
  </svg>
</div>
```

---

## Bileşen 17: Tarif Kitabı

**Etiketler:** tarif, sofra, hamur, baharat
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Sayfaları sürekli açılıp kapanan bir tarif kitabının döngüsel çevirme animasyonu.

```html
<div class="sutol-gas17-wrap">
  <style>
    .sutol-gas17-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas17-svg{width:100%;height:100%;max-width:300px;}
    .sutol-gas17-right{transform-origin:100px 65px;transform-box:fill-box;animation:sutol-gas17-flip 4.4s ease-in-out infinite;}
    @keyframes sutol-gas17-flip{0%,15%{transform:scaleX(1);}50%{transform:scaleX(.05);}85%,100%{transform:scaleX(1);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas17-right{animation:none;}
    }
  </style>
  <svg class="sutol-gas17-svg" viewBox="0 0 200 140">
    <rect x="18" y="98" width="164" height="7" rx="3" fill="#8a5a34"/>
    <path d="M100,98 L28,88 L28,26 L100,36 Z" fill="#fdf6ec" stroke="#d9c7a8" stroke-width="1.5"/>
    <circle cx="55" cy="55" r="12" fill="#e6a97a"/>
    <path class="sutol-gas17-right" d="M100,98 L172,88 L172,26 L100,36 Z" fill="#ffffff" stroke="#d9c7a8" stroke-width="1.5"/>
    <line x1="112" y1="48" x2="162" y2="55" stroke="#c9b28a" stroke-width="1.4"/>
    <line x1="112" y1="60" x2="162" y2="67" stroke="#c9b28a" stroke-width="1.4"/>
    <line x1="112" y1="72" x2="162" y2="79" stroke="#c9b28a" stroke-width="1.4"/>
  </svg>
</div>
```

---

## Bileşen 18: Un Eleme

**Etiketler:** hamur, ekmek, fırın, tarif
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir elekten süzülerek aşağı düşen un tanelerinin sürekli akışı.

```html
<div class="sutol-gas18-wrap">
  <style>
    .sutol-gas18-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas18-svg{width:100%;height:100%;max-width:240px;}
    .sutol-gas18-sieve{animation:sutol-gas18-shake 0.5s ease-in-out infinite;transform-origin:center;}
    .sutol-gas18-p1{animation:sutol-gas18-fall 1.6s ease-in infinite;}
    .sutol-gas18-p2{animation:sutol-gas18-fall 1.6s ease-in infinite;animation-delay:.4s;}
    .sutol-gas18-p3{animation:sutol-gas18-fall 1.6s ease-in infinite;animation-delay:.8s;}
    @keyframes sutol-gas18-shake{0%,100%{transform:translateX(0);}50%{transform:translateX(3px);}}
    @keyframes sutol-gas18-fall{0%{transform:translateY(0);opacity:0;}20%{opacity:.9;}100%{transform:translateY(40px);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas18-sieve,.sutol-gas18-p1,.sutol-gas18-p2,.sutol-gas18-p3{animation:none;}
    }
  </style>
  <svg class="sutol-gas18-svg" viewBox="0 0 200 160">
    <g class="sutol-gas18-sieve">
      <ellipse cx="100" cy="55" rx="50" ry="14" fill="#dfe3ea" stroke="#8a8fa3" stroke-width="2"/>
      <line x1="60" y1="55" x2="140" y2="55" stroke="#8a8fa3" stroke-width="1"/>
    </g>
    <circle class="sutol-gas18-p1" cx="85" cy="70" r="2.5" fill="#f2e6c9"/>
    <circle class="sutol-gas18-p2" cx="100" cy="70" r="2.5" fill="#f2e6c9"/>
    <circle class="sutol-gas18-p3" cx="115" cy="70" r="2.5" fill="#f2e6c9"/>
    <ellipse cx="100" cy="130" rx="40" ry="10" fill="#f2e6c9"/>
  </svg>
</div>
```

---

## Bileşen 19: Mum Işığında Ziyafet

**Etiketler:** ziyafet, sofra, tarif, şarap mahzeni
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir masada titreşen mum ışığıyla aydınlanan bir ziyafet sofrası.

```html
<div class="sutol-gas19-wrap">
  <style>
    .sutol-gas19-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas19-svg{width:100%;height:100%;max-width:280px;}
    .sutol-gas19-flame{animation:sutol-gas19-flick 1s ease-in-out infinite alternate;transform-origin:bottom;}
    .sutol-gas19-glow{animation:sutol-gas19-pulse 1s ease-in-out infinite alternate;}
    @keyframes sutol-gas19-flick{0%{transform:scaleY(1) rotate(-2deg);}100%{transform:scaleY(1.15) rotate(2deg);}}
    @keyframes sutol-gas19-pulse{0%{opacity:.3;}100%{opacity:.55;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas19-flame,.sutol-gas19-glow{animation:none;}
    }
  </style>
  <svg class="sutol-gas19-svg" viewBox="0 0 220 160">
    <rect x="10" y="120" width="200" height="10" rx="3" fill="#c9a876"/>
    <circle cx="60" cy="105" r="20" fill="#eef1f7" stroke="#c3cbdd" stroke-width="2"/>
    <circle cx="160" cy="105" r="20" fill="#eef1f7" stroke="#c3cbdd" stroke-width="2"/>
    <rect x="105" y="80" width="10" height="40" fill="#f2e6c9"/>
    <circle class="sutol-gas19-glow" cx="110" cy="75" r="30" fill="#f6c453"/>
    <g class="sutol-gas19-flame">
      <path d="M110,80 Q104,65 110,55 Q116,65 110,80 Z" fill="#f6c453"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 20: Tatlı Üzerine Şeker Serpme

**Etiketler:** tatlandırıcı, tabak sunumu, sos, tarif
**Kategori:** Gastronomi & Mutfak Kültürü

**Açıklama:** Bir tatlının üzerine yukarıdan serpilen pudra şekeri tanelerinin sürekli tekrarlanan animasyonu.

```html
<div class="sutol-gas20-wrap">
  <style>
    .sutol-gas20-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-gas20-svg{width:100%;height:100%;max-width:260px;}
    .sutol-gas20-p1{animation:sutol-gas20-fall 2.2s ease-in infinite;}
    .sutol-gas20-p2{animation:sutol-gas20-fall 2.2s ease-in infinite;animation-delay:.4s;}
    .sutol-gas20-p3{animation:sutol-gas20-fall 2.2s ease-in infinite;animation-delay:.8s;}
    .sutol-gas20-p4{animation:sutol-gas20-fall 2.2s ease-in infinite;animation-delay:1.2s;}
    @keyframes sutol-gas20-fall{0%{transform:translateY(0);opacity:0;}20%{opacity:1;}100%{transform:translateY(55px);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-gas20-p1,.sutol-gas20-p2,.sutol-gas20-p3,.sutol-gas20-p4{animation:none;}
    }
  </style>
  <svg class="sutol-gas20-svg" viewBox="0 0 200 160">
    <ellipse cx="100" cy="130" rx="60" ry="14" fill="#eef1f7" stroke="#c3cbdd" stroke-width="2"/>
    <rect x="75" y="90" width="50" height="35" rx="6" fill="#8a5a34"/>
    <circle class="sutol-gas20-p1" cx="80" cy="45" r="2.5" fill="#ffffff"/>
    <circle class="sutol-gas20-p2" cx="100" cy="40" r="2.5" fill="#ffffff"/>
    <circle class="sutol-gas20-p3" cx="120" cy="45" r="2.5" fill="#ffffff"/>
    <circle class="sutol-gas20-p4" cx="90" cy="35" r="2" fill="#ffffff"/>
  </svg>
</div>
```

---

## Kalite Kontrol Özeti

- **Bileşen 1:** Buhar çizgilerinin gecikmeli `translateY/opacity` yükselişi + kapağın hafif `translateY` titreşimi; hafif.
- **Bileşen 2:** Bıçağın `rotate` ile inip kalkması; hafif.
- **Bileşen 3:** Hamurun `scale/translateY` ile şişmesi; hafif.
- **Bileşen 4:** Fırın camının opacity pulse'ı; çok hafif.
- **Bileşen 5:** Şişin sürekli `rotate` dönüşü + alevlerin `scaleY` titreşimi; hafif.
- **Bileşen 6:** Kavurma tamburunun `rotate` dönüşü; hafif.
- **Bileşen 7:** `clip-path` içinde renk dolgusunun `scaleY` ile yükselmesi + buhar çizgileri; hafif.
- **Bileşen 8:** Şişenin `rotate` ile eğilmesi + akışın opacity'si + bardağın `scaleY` dolumu; hafif.
- **Bileşen 9:** Kavanozun `rotate` eğilmesi + tanelerin gecikmeli `translateY` düşüşü; hafif.
- **Bileşen 10:** Üç sofra öğesinin gecikmeli fade/translate ile belirmesi; hafif.
- **Bileşen 11:** Mikser kancasının sürekli `rotate` dönüşü; hafif.
- **Bileşen 12:** Sosun `stroke-dashoffset` ile çizilip solması; hafif.
- **Bileşen 13:** Üç sunum öğesinin gecikmeli fade/translate döngüsü; hafif.
- **Bileşen 14:** Çubuk ve çatalın `translateX/rotate` ile yaklaşıp ayrılması; hafif.
- **Bileşen 15:** İki buhar çizgisinin gecikmeli `translateY` yükselişi; hafif.
- **Bileşen 16:** `clip-path` içinde kabarcıkların `translateY` ile yükselmesi; hafif.
- **Bileşen 17:** SVG `scaleX` sayfa çevirme; hafif.
- **Bileşen 18:** Eleğin hafif `translateX` titreşimi + tanelerin `translateY` düşüşü; hafif.
- **Bileşen 19:** Alevin `scaleY/rotate` titreşimi + parıltının opacity pulse'ı; hafif.
- **Bileşen 20:** Dört şeker tanesinin gecikmeli `translateY` düşüşü; hafif.

Tüm bileşenler `prefers-reduced-motion` desteği içerir, şeffaf arka plana sahiptir, sabit metin barındırmaz, viewBox tabanlı ölçeklenebilirlik kullanır ve dış kaynağa bağımlı değildir.
