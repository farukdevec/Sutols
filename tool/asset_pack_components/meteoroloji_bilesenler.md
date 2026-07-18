# Meteoroloji & Hava Olayları Kategorisi — 20 Animasyonlu Bileşen

---

## Bileşen 1: Bulut Süzülmesi

**Etiketler (keyword eşleşmesi için):** bulut, hava tahmini
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Gökyüzünde yavaşça sağa doğru süzülen yumuşak bir bulut kümesi.

```html
<div class="sutol-mh-01-root">
  <style>
    .sutol-mh-01-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-01-cloud{position:absolute;top:35%;left:-20%;animation:sutol-mh-01-drift 10s linear infinite;}
    .sutol-mh-01-cloud svg{width:36vw;max-width:220px;height:auto;display:block;}
    @keyframes sutol-mh-01-drift{from{left:-30%;}to{left:110%;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-01-cloud{animation:none;left:35%;}
    }
  </style>
  <div class="sutol-mh-01-cloud">
    <svg viewBox="0 0 120 60">
      <ellipse cx="40" cy="38" rx="30" ry="18" fill="#e8edf2"/>
      <ellipse cx="70" cy="30" rx="26" ry="20" fill="#dbe3ea"/>
      <ellipse cx="55" cy="42" rx="34" ry="16" fill="#f2f5f8"/>
    </svg>
  </div>
</div>
```

---

## Bileşen 2: Yıldırım Çakması

**Etiketler (keyword eşleşmesi için):** yıldırım, fırtına, bulut
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Koyu bir fırtına bulutundan aniden çakan ve sönen bir yıldırım.

```html
<div class="sutol-mh-02-root">
  <style>
    .sutol-mh-02-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-02-root svg{width:100%;height:100%;}
    .sutol-mh-02-bolt{fill:#f2e94e;opacity:0;animation:sutol-mh-02-flash 3.5s ease-in-out infinite;}
    .sutol-mh-02-flashbg{fill:#f2e94e;opacity:0;animation:sutol-mh-02-glow 3.5s ease-in-out infinite;}
    @keyframes sutol-mh-02-flash{0%,55%{opacity:0;}58%,62%{opacity:1;}65%,68%{opacity:.2;}70%,74%{opacity:1;}78%,100%{opacity:0;}}
    @keyframes sutol-mh-02-glow{0%,55%{opacity:0;}60%,70%{opacity:.25;}78%,100%{opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-02-bolt{animation:none;opacity:.6;}
      .sutol-mh-02-flashbg{animation:none;opacity:0;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <rect class="sutol-mh-02-flashbg" x="0" y="0" width="200" height="200"/>
    <ellipse cx="100" cy="55" rx="55" ry="26" fill="#5a6472"/>
    <ellipse cx="70" cy="60" rx="35" ry="20" fill="#4a5462"/>
    <ellipse cx="130" cy="58" rx="32" ry="20" fill="#4a5462"/>
    <polygon class="sutol-mh-02-bolt" points="105,75 90,120 105,120 92,165 130,105 112,105 122,75"/>
  </svg>
</div>
```

---

## Bileşen 3: Gökkuşağı Belirmesi

**Etiketler (keyword eşleşmesi için):** gökkuşağı, nem oranı, hava tahmini
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Yağmurdan sonra yavaşça beliren, renk renk parlayan bir gökkuşağı.

```html
<div class="sutol-mh-03-root">
  <style>
    .sutol-mh-03-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-03-root svg{width:100%;height:100%;}
    .sutol-mh-03-arc{fill:none;stroke-width:6;stroke-dasharray:260;stroke-dashoffset:260;animation:sutol-mh-03-appear 6s ease-in-out infinite;}
    @keyframes sutol-mh-03-appear{0%,10%{stroke-dashoffset:260;opacity:0;}30%{opacity:1;}60%,85%{stroke-dashoffset:0;opacity:1;}100%{stroke-dashoffset:0;opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-03-arc{animation:none;stroke-dashoffset:0;opacity:.7;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-mh-03-arc" d="M20,170 A80,80 0 0,1 180,170" stroke="#d1453a" style="animation-delay:0s;"/>
    <path class="sutol-mh-03-arc" d="M30,170 A70,70 0 0,1 170,170" stroke="#f2a13c" style="animation-delay:.15s;"/>
    <path class="sutol-mh-03-arc" d="M40,170 A60,60 0 0,1 160,170" stroke="#f2e94e" style="animation-delay:.3s;"/>
    <path class="sutol-mh-03-arc" d="M50,170 A50,50 0 0,1 150,170" stroke="#6ea852" style="animation-delay:.45s;"/>
    <path class="sutol-mh-03-arc" d="M60,170 A40,40 0 0,1 140,170" stroke="#5f7fbf" style="animation-delay:.6s;"/>
    <path class="sutol-mh-03-arc" d="M70,170 A30,30 0 0,1 130,170" stroke="#9b72cf" style="animation-delay:.75s;"/>
  </svg>
</div>
```

---

## Bileşen 4: Kar Tanesi Düşüşü

**Etiketler (keyword eşleşmesi için):** kar tanesi, don olayı
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Yavaşça dönerek süzülüp yere düşen ince yapılı bir kar tanesi.

```html
<div class="sutol-mh-04-root">
  <style>
    .sutol-mh-04-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-04-flake{position:absolute;top:-10%;animation:sutol-mh-04-fall linear infinite;}
    .sutol-mh-04-flake svg{width:100%;height:100%;display:block;animation:sutol-mh-04-spin 4s linear infinite;}
    .sutol-mh-04-f1{left:20%;width:8%;animation-duration:6s;animation-delay:0s;}
    .sutol-mh-04-f2{left:50%;width:6%;animation-duration:7.5s;animation-delay:1.5s;}
    .sutol-mh-04-f3{left:75%;width:10%;animation-duration:5.5s;animation-delay:.8s;}
    @keyframes sutol-mh-04-fall{0%{top:-10%;opacity:0;}10%{opacity:.9;}90%{opacity:.9;}100%{top:105%;opacity:0;}}
    @keyframes sutol-mh-04-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-04-flake{animation:none;opacity:.6;}
      .sutol-mh-04-flake svg{animation:none;}
    }
  </style>
  <div class="sutol-mh-04-flake sutol-mh-04-f1"><svg viewBox="0 0 40 40"><g stroke="#bcd9ec" stroke-width="2" stroke-linecap="round"><line x1="20" y1="2" x2="20" y2="38"/><line x1="2" y1="20" x2="38" y2="20"/><line x1="7" y1="7" x2="33" y2="33"/><line x1="33" y1="7" x2="7" y2="33"/></g></svg></div>
  <div class="sutol-mh-04-flake sutol-mh-04-f2"><svg viewBox="0 0 40 40"><g stroke="#d8ecf7" stroke-width="2" stroke-linecap="round"><line x1="20" y1="2" x2="20" y2="38"/><line x1="2" y1="20" x2="38" y2="20"/><line x1="7" y1="7" x2="33" y2="33"/><line x1="33" y1="7" x2="7" y2="33"/></g></svg></div>
  <div class="sutol-mh-04-flake sutol-mh-04-f3"><svg viewBox="0 0 40 40"><g stroke="#bcd9ec" stroke-width="2" stroke-linecap="round"><line x1="20" y1="2" x2="20" y2="38"/><line x1="2" y1="20" x2="38" y2="20"/><line x1="7" y1="7" x2="33" y2="33"/><line x1="33" y1="7" x2="7" y2="33"/></g></svg></div>
</div>
```

---

## Bileşen 5: Dolu Yağışı

**Etiketler (keyword eşleşmesi için):** dolu, fırtına, bulut
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Bulutlardan düşen ve yere çarpınca hafifçe sıçrayan buz taneleri.

```html
<div class="sutol-mh-05-root">
  <style>
    .sutol-mh-05-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-05-cloud{position:absolute;top:8%;left:30%;width:40%;}
    .sutol-mh-05-cloud svg{width:100%;height:auto;display:block;}
    .sutol-mh-05-stone{position:absolute;top:26%;width:5%;aspect-ratio:1/1;border-radius:50%;background:radial-gradient(circle at 35% 30%,#fff,#c9d4e3);animation:sutol-mh-05-drop 1.8s ease-in infinite;}
    @keyframes sutol-mh-05-drop{0%{top:26%;opacity:0;}10%{opacity:1;}75%{top:78%;opacity:1;}82%{top:74%;}90%{top:78%;}100%{opacity:0;top:78%;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-05-stone{animation:none;opacity:.4;}
    }
  </style>
  <div class="sutol-mh-05-cloud"><svg viewBox="0 0 120 60"><ellipse cx="40" cy="38" rx="30" ry="18" fill="#7d8797"/><ellipse cx="70" cy="30" rx="26" ry="20" fill="#6c7684"/><ellipse cx="55" cy="42" rx="34" ry="16" fill="#8a94a2"/></svg></div>
  <div class="sutol-mh-05-stone" style="left:35%;animation-delay:0s;"></div>
  <div class="sutol-mh-05-stone" style="left:50%;animation-delay:.5s;"></div>
  <div class="sutol-mh-05-stone" style="left:60%;animation-delay:1s;"></div>
</div>
```

---

## Bileşen 6: Kasırga Girdabı

**Etiketler (keyword eşleşmesi için):** kasırga, fırtına, rüzgar gülü
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Yerden gökyüzüne doğru daralan, dönerek yükselen bir kasırga hunisi.

```html
<div class="sutol-mh-06-root">
  <style>
    .sutol-mh-06-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-06-root svg{width:100%;height:100%;}
    .sutol-mh-06-ring{fill:none;stroke:#6c7684;opacity:.5;transform-origin:100px 0px;animation:sutol-mh-06-spin linear infinite;}
    .sutol-mh-06-r1{animation-duration:1.2s;}
    .sutol-mh-06-r2{animation-duration:1s;}
    .sutol-mh-06-r3{animation-duration:.8s;}
    .sutol-mh-06-r4{animation-duration:.6s;}
    @keyframes sutol-mh-06-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-06-ring{animation:none;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <ellipse class="sutol-mh-06-ring sutol-mh-06-r1" cx="100" cy="40" rx="55" ry="10" stroke-width="4"/>
    <ellipse class="sutol-mh-06-ring sutol-mh-06-r2" cx="100" cy="80" rx="38" ry="8" stroke-width="4"/>
    <ellipse class="sutol-mh-06-ring sutol-mh-06-r3" cx="100" cy="120" rx="24" ry="6" stroke-width="4"/>
    <ellipse class="sutol-mh-06-ring sutol-mh-06-r4" cx="100" cy="155" rx="12" ry="4" stroke-width="4"/>
  </svg>
</div>
```

---

## Bileşen 7: Sis Katmanları

**Etiketler (keyword eşleşmesi için):** sis, nem oranı
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Farklı hızlarda yatay olarak kayan yarı saydam sis bantları.

```html
<div class="sutol-mh-07-root">
  <style>
    .sutol-mh-07-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-07-band{position:absolute;left:-30%;width:160%;height:12%;background:linear-gradient(90deg,transparent,rgba(220,228,235,.6),transparent);animation:sutol-mh-07-move linear infinite;}
    @keyframes sutol-mh-07-move{from{transform:translateX(-15%);}to{transform:translateX(15%);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-07-band{animation:none;}
    }
  </style>
  <div class="sutol-mh-07-band" style="top:25%;animation-duration:8s;"></div>
  <div class="sutol-mh-07-band" style="top:45%;animation-duration:6s;animation-direction:reverse;"></div>
  <div class="sutol-mh-07-band" style="top:62%;animation-duration:9s;"></div>
  <div class="sutol-mh-07-band" style="top:78%;animation-duration:7s;animation-direction:reverse;"></div>
</div>
```

---

## Bileşen 8: Çiy Damlası

**Etiketler (keyword eşleşmesi için):** çiy, nem oranı
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Bir yaprak ucunda yavaşça büyüyen ve parlayan bir çiy damlası.

```html
<div class="sutol-mh-08-root">
  <style>
    .sutol-mh-08-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-08-root svg{width:100%;height:100%;}
    .sutol-mh-08-drop{animation:sutol-mh-08-form 4s ease-in-out infinite;transform-origin:100px 120px;}
    @keyframes sutol-mh-08-form{0%,10%{transform:scale(.2);opacity:0;}40%,80%{transform:scale(1);opacity:.9;}95%,100%{transform:scale(.2);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-08-drop{animation:none;transform:scale(1);opacity:.7;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <path d="M100,150 C60,130 55,90 100,60 C145,90 140,130 100,150 Z" fill="#7fc25c" opacity="0.5"/>
    <path class="sutol-mh-08-drop" d="M100,105 C107,115 114,124 100,132 C86,124 93,115 100,105 Z" fill="#bcd9ec"/>
  </svg>
</div>
```

---

## Bileşen 9: Buzlanma Kristalleri

**Etiketler (keyword eşleşmesi için):** buzlanma, don olayı
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Bir yüzeyde kenarlardan içeri doğru büyüyen buz kristali dokusu.

```html
<div class="sutol-mh-09-root">
  <style>
    .sutol-mh-09-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-09-root svg{width:100%;height:100%;}
    .sutol-mh-09-branch{stroke:#cfe6f5;stroke-width:2;stroke-linecap:round;stroke-dasharray:40;stroke-dashoffset:40;animation:sutol-mh-09-grow 5s ease-in-out infinite;}
    @keyframes sutol-mh-09-grow{0%,10%{stroke-dashoffset:40;opacity:0;}40%,80%{stroke-dashoffset:0;opacity:.9;}95%,100%{stroke-dashoffset:40;opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-09-branch{animation:none;stroke-dashoffset:0;opacity:.6;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <line class="sutol-mh-09-branch" x1="30" y1="30" x2="55" y2="55" style="animation-delay:0s;"/>
    <line class="sutol-mh-09-branch" x1="170" y1="30" x2="145" y2="55" style="animation-delay:.3s;"/>
    <line class="sutol-mh-09-branch" x1="30" y1="170" x2="55" y2="145" style="animation-delay:.6s;"/>
    <line class="sutol-mh-09-branch" x1="170" y1="170" x2="145" y2="145" style="animation-delay:.9s;"/>
    <line class="sutol-mh-09-branch" x1="100" y1="10" x2="100" y2="45" style="animation-delay:.2s;"/>
    <line class="sutol-mh-09-branch" x1="10" y1="100" x2="45" y2="100" style="animation-delay:.5s;"/>
    <line class="sutol-mh-09-branch" x1="190" y1="100" x2="155" y2="100" style="animation-delay:.8s;"/>
    <line class="sutol-mh-09-branch" x1="100" y1="190" x2="100" y2="155" style="animation-delay:1.1s;"/>
  </svg>
</div>
```

---

## Bileşen 10: Hava Tahmini Döngüsü

**Etiketler (keyword eşleşmesi için):** hava tahmini, bulut
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Güneş, bulut ve yağmur simgeleri arasında sırayla geçiş yapan bir hava durumu göstergesi.

```html
<div class="sutol-mh-10-root">
  <style>
    .sutol-mh-10-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-10-icon{position:absolute;top:50%;left:50%;width:40%;transform:translate(-50%,-50%) scale(.5);opacity:0;animation:sutol-mh-10-cycle 6s ease-in-out infinite;}
    .sutol-mh-10-icon svg{width:100%;height:auto;display:block;}
    .sutol-mh-10-i1{animation-delay:0s;}
    .sutol-mh-10-i2{animation-delay:2s;}
    .sutol-mh-10-i3{animation-delay:4s;}
    @keyframes sutol-mh-10-cycle{0%,3%{opacity:0;transform:translate(-50%,-50%) scale(.5);}12%,25%{opacity:1;transform:translate(-50%,-50%) scale(1);}33%,100%{opacity:0;transform:translate(-50%,-50%) scale(.5);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-10-icon{animation:none;opacity:0;}
      .sutol-mh-10-i1{opacity:1;transform:translate(-50%,-50%) scale(1);}
    }
  </style>
  <div class="sutol-mh-10-icon sutol-mh-10-i1"><svg viewBox="0 0 60 60"><circle cx="30" cy="30" r="18" fill="#f2c14e"/></svg></div>
  <div class="sutol-mh-10-icon sutol-mh-10-i2"><svg viewBox="0 0 60 60"><ellipse cx="22" cy="34" rx="16" ry="10" fill="#c9d4e3"/><ellipse cx="38" cy="28" rx="14" ry="11" fill="#dbe3ea"/></svg></div>
  <div class="sutol-mh-10-icon sutol-mh-10-i3"><svg viewBox="0 0 60 60"><ellipse cx="30" cy="24" rx="18" ry="11" fill="#8a94a2"/><line x1="20" y1="42" x2="16" y2="52" stroke="#5f9bd3" stroke-width="3" stroke-linecap="round"/><line x1="30" y1="42" x2="26" y2="52" stroke="#5f9bd3" stroke-width="3" stroke-linecap="round"/><line x1="40" y1="42" x2="36" y2="52" stroke="#5f9bd3" stroke-width="3" stroke-linecap="round"/></svg></div>
</div>
```

---

## Bileşen 11: Barometre İbresi

**Etiketler (keyword eşleşmesi için):** barometre, hava tahmini
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Basınç değişimlerini takip ederek yavaşça salınan bir barometre ibresi.

```html
<div class="sutol-mh-11-root">
  <style>
    .sutol-mh-11-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-11-root svg{width:100%;height:100%;}
    .sutol-mh-11-needle{transform-origin:100px 110px;animation:sutol-mh-11-sway 6s ease-in-out infinite;}
    @keyframes sutol-mh-11-sway{0%,100%{transform:rotate(-40deg);}50%{transform:rotate(40deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-11-needle{animation:none;transform:rotate(0deg);}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <circle cx="100" cy="110" r="65" fill="none" stroke="#8a8f96" stroke-width="3" opacity="0.5"/>
    <line x1="100" y1="50" x2="100" y2="60" stroke="#8a8f96" stroke-width="2"/>
    <line x1="45" y1="110" x2="55" y2="110" stroke="#8a8f96" stroke-width="2"/>
    <line x1="155" y1="110" x2="145" y2="110" stroke="#8a8f96" stroke-width="2"/>
    <line class="sutol-mh-11-needle" x1="100" y1="110" x2="100" y2="60" stroke="#d1453a" stroke-width="4" stroke-linecap="round"/>
    <circle cx="100" cy="110" r="6" fill="#3d3d3d"/>
  </svg>
</div>
```

---

## Bileşen 12: Rüzgar Gülü Dönüşü

**Etiketler (keyword eşleşmesi için):** rüzgar gülü, fırtına
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Rüzgarın şiddetine göre hızlanıp yavaşlayan bir rüzgar gülü/gökyüzü fırıldağı.

```html
<div class="sutol-mh-12-root">
  <style>
    .sutol-mh-12-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-12-root svg{width:100%;height:100%;}
    .sutol-mh-12-blades{transform-origin:100px 90px;animation:sutol-mh-12-spin 5s ease-in-out infinite;}
    @keyframes sutol-mh-12-spin{
      0%{transform:rotate(0deg);animation-timing-function:ease-in;}
      40%{transform:rotate(540deg);animation-timing-function:ease-out;}
      70%{transform:rotate(630deg);}
      100%{transform:rotate(720deg);}
    }
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-12-blades{animation:none;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <line x1="100" y1="90" x2="100" y2="175" stroke="#8a8f96" stroke-width="3"/>
    <g class="sutol-mh-12-blades">
      <polygon points="100,90 100,45 130,68" fill="#e0637a"/>
      <polygon points="100,90 145,90 122,120" fill="#f2c14e"/>
      <polygon points="100,90 100,135 70,112" fill="#7fa8d9"/>
      <polygon points="100,90 55,90 78,60" fill="#6ea852"/>
    </g>
    <circle cx="100" cy="90" r="6" fill="#3d3d3d"/>
  </svg>
</div>
```

---

## Bileşen 13: Fırtına Bulutu

**Etiketler (keyword eşleşmesi için):** fırtına, yıldırım, rüzgar gülü
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Şiddetli yağmur ve rüzgar çizgileriyle birlikte kararan bir fırtına bulutu.

```html
<div class="sutol-mh-13-root">
  <style>
    .sutol-mh-13-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-13-cloud{position:absolute;top:14%;left:25%;width:50%;}
    .sutol-mh-13-cloud svg{width:100%;height:auto;display:block;}
    .sutol-mh-13-rain{position:absolute;width:1.5%;height:12%;background:linear-gradient(180deg,rgba(95,155,211,.8),transparent);animation:sutol-mh-13-fall 1s linear infinite;}
    @keyframes sutol-mh-13-fall{0%{top:38%;opacity:0;}15%{opacity:1;}90%{opacity:1;}100%{top:85%;opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-13-rain{animation:none;opacity:.4;}
    }
  </style>
  <div class="sutol-mh-13-cloud"><svg viewBox="0 0 120 60"><ellipse cx="40" cy="38" rx="30" ry="18" fill="#5a6472"/><ellipse cx="70" cy="30" rx="26" ry="20" fill="#4a5462"/><ellipse cx="55" cy="42" rx="34" ry="16" fill="#6c7684"/></svg></div>
  <div class="sutol-mh-13-rain" style="left:35%;animation-delay:0s;"></div>
  <div class="sutol-mh-13-rain" style="left:45%;animation-delay:.2s;"></div>
  <div class="sutol-mh-13-rain" style="left:55%;animation-delay:.4s;"></div>
  <div class="sutol-mh-13-rain" style="left:65%;animation-delay:.6s;"></div>
</div>
```

---

## Bileşen 14: Don Olayı Kristali

**Etiketler (keyword eşleşmesi için):** don olayı, buzlanma
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Bir yaprak üzerinde soğukla birlikte yavaşça beliren ince don kristalleri.

```html
<div class="sutol-mh-14-root">
  <style>
    .sutol-mh-14-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-14-root svg{width:100%;height:100%;}
    .sutol-mh-14-frost{stroke:#dcecf7;stroke-width:1.5;opacity:0;animation:sutol-mh-14-form 5s ease-in-out infinite;}
    @keyframes sutol-mh-14-form{0%,10%{opacity:0;}40%,80%{opacity:.9;}95%,100%{opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-14-frost{animation:none;opacity:.5;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <path d="M100,150 C60,130 55,90 100,60 C145,90 140,130 100,150 Z" fill="#6ea852" opacity="0.5"/>
    <line class="sutol-mh-14-frost" x1="80" y1="130" x2="90" y2="120" style="animation-delay:0s;"/>
    <line class="sutol-mh-14-frost" x1="100" y1="140" x2="105" y2="125" style="animation-delay:.3s;"/>
    <line class="sutol-mh-14-frost" x1="115" y1="128" x2="108" y2="115" style="animation-delay:.6s;"/>
    <line class="sutol-mh-14-frost" x1="90" y1="100" x2="98" y2="90" style="animation-delay:.9s;"/>
    <line class="sutol-mh-14-frost" x1="110" y1="95" x2="103" y2="85" style="animation-delay:1.2s;"/>
  </svg>
</div>
```

---

## Bileşen 15: Nem Oranı Göstergesi

**Etiketler (keyword eşleşmesi için):** nem oranı, sis, çiy
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** İçindeki seviye yavaşça yükselen ve alçalan bir nem oranı göstergesi.

```html
<div class="sutol-mh-15-root">
  <style>
    .sutol-mh-15-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-15-root svg{width:100%;height:100%;}
    .sutol-mh-15-fill{animation:sutol-mh-15-level 5s ease-in-out infinite;}
    @keyframes sutol-mh-15-level{0%,100%{transform:translateY(40px);}50%{transform:translateY(5px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-15-fill{animation:none;transform:translateY(20px);}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <defs>
      <clipPath id="sutol-mh-15-clip">
        <path d="M100,50 C100,50 65,105 65,135 A35,35 0 0,0 135,135 C135,105 100,50 100,50 Z"/>
      </clipPath>
    </defs>
    <path d="M100,50 C100,50 65,105 65,135 A35,35 0 0,0 135,135 C135,105 100,50 100,50 Z" fill="none" stroke="#5f9bd3" stroke-width="3"/>
    <g clip-path="url(#sutol-mh-15-clip)">
      <rect class="sutol-mh-15-fill" x="60" y="90" width="80" height="90" fill="#7fc2e0"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 16: Şimşek Ağı

**Etiketler (keyword eşleşmesi için):** yıldırım, fırtına
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Gökyüzünde dallanarak yayılan çatal biçimli bir şimşek deseni.

```html
<div class="sutol-mh-16-root">
  <style>
    .sutol-mh-16-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-16-root svg{width:100%;height:100%;}
    .sutol-mh-16-branch{stroke:#f2e94e;stroke-width:2.5;stroke-linecap:round;fill:none;stroke-dasharray:70;stroke-dashoffset:70;opacity:0;animation:sutol-mh-16-strike 4s ease-in-out infinite;}
    @keyframes sutol-mh-16-strike{0%,20%{stroke-dashoffset:70;opacity:0;}30%{opacity:1;}45%{stroke-dashoffset:0;opacity:1;}55%{opacity:.2;}62%{opacity:1;}75%,100%{opacity:0;stroke-dashoffset:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-16-branch{animation:none;opacity:.5;stroke-dashoffset:0;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-mh-16-branch" d="M100,30 L90,80 L105,80 L85,140" style="animation-delay:0s;"/>
    <path class="sutol-mh-16-branch" d="M90,80 L60,100" style="animation-delay:.1s;"/>
    <path class="sutol-mh-16-branch" d="M105,80 L135,95" style="animation-delay:.15s;"/>
  </svg>
</div>
```

---

## Bileşen 17: Rüzgar Akış Çizgileri

**Etiketler (keyword eşleşmesi için):** rüzgar gülü, fırtına, kasırga
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Ekrandan geçen, esintinin yönünü ve gücünü simgeleyen akış çizgileri.

```html
<div class="sutol-mh-17-root">
  <style>
    .sutol-mh-17-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-17-line{position:absolute;left:-30%;width:26%;height:2px;background:#8a8f96;opacity:.5;animation:sutol-mh-17-blow linear infinite;}
    @keyframes sutol-mh-17-blow{0%{left:-30%;opacity:0;}15%{opacity:.6;}85%{opacity:.6;}100%{left:110%;opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-17-line{animation:none;opacity:.25;}
    }
  </style>
  <div class="sutol-mh-17-line" style="top:25%;animation-duration:2.4s;animation-delay:0s;"></div>
  <div class="sutol-mh-17-line" style="top:40%;animation-duration:1.8s;animation-delay:.4s;"></div>
  <div class="sutol-mh-17-line" style="top:55%;animation-duration:2.2s;animation-delay:.8s;"></div>
  <div class="sutol-mh-17-line" style="top:70%;animation-duration:2s;animation-delay:1.2s;"></div>
</div>
```

---

## Bileşen 18: Kar Fırtınası

**Etiketler (keyword eşleşmesi için):** kar tanesi, kasırga
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Rüzgarla birlikte çapraz yönde savrularak düşen yoğun kar taneleri.

```html
<div class="sutol-mh-18-root">
  <style>
    .sutol-mh-18-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-18-flake{position:absolute;top:-5%;width:3%;aspect-ratio:1/1;border-radius:50%;background:#eaf4fb;animation:sutol-mh-18-blizzard linear infinite;}
    @keyframes sutol-mh-18-blizzard{
      0%{top:-5%;transform:translateX(0);opacity:0;}
      10%{opacity:.9;}
      100%{top:105%;transform:translateX(-60px);opacity:.3;}
    }
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-18-flake{animation:none;opacity:.3;}
    }
  </style>
  <div class="sutol-mh-18-flake" style="left:15%;animation-duration:2.4s;animation-delay:0s;"></div>
  <div class="sutol-mh-18-flake" style="left:30%;animation-duration:2s;animation-delay:.3s;"></div>
  <div class="sutol-mh-18-flake" style="left:45%;animation-duration:2.6s;animation-delay:.6s;"></div>
  <div class="sutol-mh-18-flake" style="left:60%;animation-duration:2.2s;animation-delay:.2s;"></div>
  <div class="sutol-mh-18-flake" style="left:75%;animation-duration:2.8s;animation-delay:.9s;"></div>
  <div class="sutol-mh-18-flake" style="left:88%;animation-duration:2.1s;animation-delay:.5s;"></div>
</div>
```

---

## Bileşen 19: Sis İçinde Güneş

**Etiketler (keyword eşleşmesi için):** sis, hava tahmini
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Kalın sisin arasından yavaşça belirip kaybolan sönük bir güneş.

```html
<div class="sutol-mh-19-root">
  <style>
    .sutol-mh-19-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-19-sun{position:absolute;top:30%;left:50%;width:26%;aspect-ratio:1/1;border-radius:50%;transform:translateX(-50%);background:radial-gradient(circle,#f2e0a0,#e0c060);animation:sutol-mh-19-glow 5s ease-in-out infinite;}
    .sutol-mh-19-fog{position:absolute;left:-20%;width:140%;height:14%;background:rgba(230,235,240,.55);animation:sutol-mh-19-drift linear infinite;}
    @keyframes sutol-mh-19-glow{0%,100%{opacity:.3;}50%{opacity:.8;}}
    @keyframes sutol-mh-19-drift{from{transform:translateX(-8%);}to{transform:translateX(8%);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-19-sun{animation:none;opacity:.5;}
      .sutol-mh-19-fog{animation:none;}
    }
  </style>
  <div class="sutol-mh-19-sun"></div>
  <div class="sutol-mh-19-fog" style="top:35%;animation-duration:7s;"></div>
  <div class="sutol-mh-19-fog" style="top:52%;animation-duration:5.5s;animation-direction:reverse;"></div>
  <div class="sutol-mh-19-fog" style="top:68%;animation-duration:8s;"></div>
</div>
```

---

## Bileşen 20: Buz Kristali Çiçeği

**Etiketler (keyword eşleşmesi için):** buzlanma, don olayı, kar tanesi
**Kategori:** Meteoroloji & Hava Olayları
**Açıklama:** Merkezden dışa doğru simetrik olarak büyüyen bir buz kristali deseni.

```html
<div class="sutol-mh-20-root">
  <style>
    .sutol-mh-20-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-mh-20-root svg{width:100%;height:100%;}
    .sutol-mh-20-group{transform-origin:100px 100px;animation:sutol-mh-20-spin 20s linear infinite;}
    .sutol-mh-20-arm{stroke:#cfe6f5;stroke-width:2;stroke-linecap:round;}
    @keyframes sutol-mh-20-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-mh-20-group{animation:none;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-mh-20-group">
      <line class="sutol-mh-20-arm" x1="100" y1="100" x2="100" y2="40"/>
      <line class="sutol-mh-20-arm" x1="100" y1="60" x2="85" y2="50"/>
      <line class="sutol-mh-20-arm" x1="100" y1="60" x2="115" y2="50"/>
      <g transform="rotate(60 100 100)"><line class="sutol-mh-20-arm" x1="100" y1="100" x2="100" y2="40"/><line class="sutol-mh-20-arm" x1="100" y1="60" x2="85" y2="50"/><line class="sutol-mh-20-arm" x1="100" y1="60" x2="115" y2="50"/></g>
      <g transform="rotate(120 100 100)"><line class="sutol-mh-20-arm" x1="100" y1="100" x2="100" y2="40"/><line class="sutol-mh-20-arm" x1="100" y1="60" x2="85" y2="50"/><line class="sutol-mh-20-arm" x1="100" y1="60" x2="115" y2="50"/></g>
      <g transform="rotate(180 100 100)"><line class="sutol-mh-20-arm" x1="100" y1="100" x2="100" y2="40"/><line class="sutol-mh-20-arm" x1="100" y1="60" x2="85" y2="50"/><line class="sutol-mh-20-arm" x1="100" y1="60" x2="115" y2="50"/></g>
      <g transform="rotate(240 100 100)"><line class="sutol-mh-20-arm" x1="100" y1="100" x2="100" y2="40"/><line class="sutol-mh-20-arm" x1="100" y1="60" x2="85" y2="50"/><line class="sutol-mh-20-arm" x1="100" y1="60" x2="115" y2="50"/></g>
      <g transform="rotate(300 100 100)"><line class="sutol-mh-20-arm" x1="100" y1="100" x2="100" y2="40"/><line class="sutol-mh-20-arm" x1="100" y1="60" x2="85" y2="50"/><line class="sutol-mh-20-arm" x1="100" y1="60" x2="115" y2="50"/></g>
    </g>
  </svg>
</div>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Bulut Süzülmesi): CSS `left` ile sürekli yatay bulut kayması.
- Bileşen 2 (Yıldırım Çakması): SVG `opacity` keyframe ile çakan şimşek ve ekran parıltısı.
- Bileşen 3 (Gökkuşağı Belirmesi): SVG `stroke-dashoffset`/`opacity` ile sıralı renk yayı çizimi.
- Bileşen 4 (Kar Tanesi Düşüşü): CSS `top`/`opacity` düşüş + iç `rotate` dönüş.
- Bileşen 5 (Dolu Yağışı): CSS `top`/`opacity` düşme ve zeminde hafif sıçrama.
- Bileşen 6 (Kasırga Girdabı): SVG çoklu `rotate` halka, farklı hızlarda huni görünümü.
- Bileşen 7 (Sis Katmanları): CSS `translateX` farklı yönlü/hızlı sis bantları.
- Bileşen 8 (Çiy Damlası): SVG `scale`/`opacity` damla oluşma nabzı.
- Bileşen 9 (Buzlanma Kristalleri): SVG `stroke-dashoffset`/`opacity` kenardan içe büyüyen kristaller.
- Bileşen 10 (Hava Tahmini Döngüsü): CSS `opacity`/`scale` ile sıralı simge geçişi.
- Bileşen 11 (Barometre İbresi): SVG `rotate` salınımlı ibre hareketi.
- Bileşen 12 (Rüzgar Gülü Dönüşü): SVG `rotate` hızlanan/yavaşlayan fırıldak.
- Bileşen 13 (Fırtına Bulutu): CSS `top`/`opacity` yağmur damlası düşüşü.
- Bileşen 14 (Don Olayı Kristali): SVG `opacity` keyframe ile beliren donuk kristal çizgileri.
- Bileşen 15 (Nem Oranı Göstergesi): SVG `clipPath` + `translateY` seviye animasyonu.
- Bileşen 16 (Şimşek Ağı): SVG `stroke-dashoffset`/`opacity` çatallı şimşek çakması.
- Bileşen 17 (Rüzgar Akış Çizgileri): CSS `left`/`opacity` yatay esinti çizgileri.
- Bileşen 18 (Kar Fırtınası): CSS `top`/`translateX` çapraz savrulan kar taneleri.
- Bileşen 19 (Sis İçinde Güneş): CSS `opacity` güneş parıltısı + `translateX` sis kayması.
- Bileşen 20 (Buz Kristali Çiçeği): SVG grup `rotate` simetrik kristal deseni.

Tüm bileşenler: tek dosya bağımsız HTML/CSS/SVG, şeffaf arka plan, `viewBox` veya % tabanlı ölçeklenebilir boyutlandırma, `prefers-reduced-motion` desteği, sandbox uyumlu (dış kaynak/localStorage/çerez/`window.top` erişimi yok), sabit dil metni içermeyen, kendine özgü `.sutol-mh-XX-` sınıf önekleriyle kapsüllenmiş CSS kullanır.
