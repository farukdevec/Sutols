# Sinema & Film Yapımı Kategorisi — 20 Animasyonlu Bileşen

---

## Bileşen 1: Kamera Odaklanması

**Etiketler (keyword eşleşmesi için):** kamera, ışık düzeni, film seti
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Netleşip bulanıklaşarak odak arayan bir kamera lensi.

```html
<div class="sutol-sf-01-root">
  <style>
    .sutol-sf-01-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-01-root svg{width:100%;height:100%;}
    .sutol-sf-01-ring{fill:none;stroke:#3d3d3d;}
    .sutol-sf-01-iris{animation:sutol-sf-01-focus 4s ease-in-out infinite;transform-origin:100px 100px;}
    @keyframes sutol-sf-01-focus{0%,100%{transform:scale(1);opacity:.5;}50%{transform:scale(.55);opacity:.95;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-01-iris{animation:none;opacity:.6;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <circle class="sutol-sf-01-ring" cx="100" cy="100" r="55" stroke-width="10"/>
    <circle class="sutol-sf-01-iris" cx="100" cy="100" r="30" fill="#5f7fbf"/>
    <circle cx="100" cy="100" r="10" fill="#1a1a1a"/>
  </svg>
</div>
```

---

## Bileşen 2: Klaket

**Etiketler (keyword eşleşmesi için):** klaket, film seti, sahne arkası
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Yukarı kalkıp sertçe kapanan, çekimi başlatan klasik bir klaket.

```html
<div class="sutol-sf-02-root">
  <style>
    .sutol-sf-02-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-02-root svg{width:100%;height:100%;}
    .sutol-sf-02-top{transform-origin:50px 70px;animation:sutol-sf-02-clap 3s ease-in-out infinite;}
    @keyframes sutol-sf-02-clap{0%,15%{transform:rotate(-28deg);}25%,55%{transform:rotate(0deg);}70%{transform:rotate(-28deg);}100%{transform:rotate(-28deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-02-top{animation:none;transform:rotate(-10deg);}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <rect x="50" y="70" width="100" height="80" fill="#2a2a2a"/>
    <line x1="60" y1="90" x2="80" y2="70" stroke="#fff" stroke-width="4"/>
    <line x1="90" y1="90" x2="110" y2="70" stroke="#fff" stroke-width="4"/>
    <line x1="120" y1="90" x2="140" y2="70" stroke="#fff" stroke-width="4"/>
    <g class="sutol-sf-02-top">
      <rect x="50" y="60" width="100" height="14" fill="#1a1a1a"/>
      <line x1="60" y1="74" x2="80" y2="60" stroke="#fff" stroke-width="4"/>
      <line x1="90" y1="74" x2="110" y2="60" stroke="#fff" stroke-width="4"/>
      <line x1="120" y1="74" x2="140" y2="60" stroke="#fff" stroke-width="4"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 3: Film Şeridi Akışı

**Etiketler (keyword eşleşmesi için):** film şeridi, kurgu masası, animasyon karesi
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Sürekli akan, karesi karesi kayan klasik bir 35mm film şeridi.

```html
<div class="sutol-sf-03-root">
  <style>
    .sutol-sf-03-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-03-strip{position:absolute;top:50%;left:-10%;width:220%;height:36%;transform:translateY(-50%);display:flex;animation:sutol-sf-03-scroll 6s linear infinite;}
    .sutol-sf-03-frame{flex:0 0 16%;height:100%;margin-right:2%;background:#1c1c1c;border:3px solid #3a3a3a;position:relative;}
    .sutol-sf-03-frame::before,.sutol-sf-03-frame::after{content:'';position:absolute;left:-6%;width:4%;height:14%;background:#3a3a3a;}
    .sutol-sf-03-frame::before{top:8%;}
    .sutol-sf-03-frame::after{bottom:8%;}
    .sutol-sf-03-pic{position:absolute;inset:12%;background:linear-gradient(135deg,#5f7fbf,#e0637a);opacity:.6;}
    @keyframes sutol-sf-03-scroll{from{transform:translateY(-50%) translateX(0);}to{transform:translateY(-50%) translateX(-18%);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-03-strip{animation:none;}
    }
  </style>
  <div class="sutol-sf-03-strip">
    <div class="sutol-sf-03-frame"><div class="sutol-sf-03-pic"></div></div>
    <div class="sutol-sf-03-frame"><div class="sutol-sf-03-pic"></div></div>
    <div class="sutol-sf-03-frame"><div class="sutol-sf-03-pic"></div></div>
    <div class="sutol-sf-03-frame"><div class="sutol-sf-03-pic"></div></div>
    <div class="sutol-sf-03-frame"><div class="sutol-sf-03-pic"></div></div>
    <div class="sutol-sf-03-frame"><div class="sutol-sf-03-pic"></div></div>
  </div>
</div>
```

---

## Bileşen 4: Projeksiyon Işığı

**Etiketler (keyword eşleşmesi için):** projeksiyon makinesi, ışık düzeni, film şeridi
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Bir projektörden titreşerek çıkan ve perdeye düşen ışık konisi.

```html
<div class="sutol-sf-04-root">
  <style>
    .sutol-sf-04-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-04-beam{position:absolute;left:14%;top:44%;width:60%;height:24%;background:linear-gradient(90deg,rgba(255,244,200,.7),rgba(255,244,200,0));clip-path:polygon(0 40%,0 60%,100% 100%,100% 0);animation:sutol-sf-04-flicker 2.5s ease-in-out infinite;}
    .sutol-sf-04-screen{position:absolute;right:6%;top:20%;width:22%;height:60%;background:rgba(255,255,255,.08);border:2px solid rgba(255,255,255,.2);}
    .sutol-sf-04-glow{position:absolute;right:8%;top:22%;width:18%;height:56%;background:radial-gradient(ellipse,rgba(255,244,200,.5),transparent 70%);animation:sutol-sf-04-flicker 2.5s ease-in-out infinite;}
    @keyframes sutol-sf-04-flicker{0%,100%{opacity:.7;}45%{opacity:.9;}55%{opacity:.6;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-04-beam,.sutol-sf-04-glow{animation:none;opacity:.7;}
    }
  </style>
  <div class="sutol-sf-04-beam"></div>
  <div class="sutol-sf-04-screen"></div>
  <div class="sutol-sf-04-glow"></div>
</div>
```

---

## Bileşen 5: Yönetmen Koltuğu

**Etiketler (keyword eşleşmesi için):** yönetmen koltuğu, film seti, sahne arkası
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Arkasında dönen bir film makarasıyla sahnede duran katlanır yönetmen koltuğu.

```html
<div class="sutol-sf-05-root">
  <style>
    .sutol-sf-05-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-05-root svg{width:100%;height:100%;}
    .sutol-sf-05-reel{transform-origin:145px 55px;animation:sutol-sf-05-spin 5s linear infinite;}
    @keyframes sutol-sf-05-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-05-reel{animation:none;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-sf-05-reel" opacity="0.5">
      <circle cx="145" cy="55" r="24" fill="none" stroke="#3d3d3d" stroke-width="4"/>
      <circle cx="145" cy="41" r="5" fill="#3d3d3d"/>
      <circle cx="159" cy="63" r="5" fill="#3d3d3d"/>
      <circle cx="131" cy="63" r="5" fill="#3d3d3d"/>
    </g>
    <path d="M55,180 L60,110 L140,110 L145,180" fill="none" stroke="#4a4a4a" stroke-width="4"/>
    <rect x="55" y="95" width="90" height="18" fill="#3d3d3d"/>
    <line x1="60" y1="110" x2="60" y2="180" stroke="#4a4a4a" stroke-width="6"/>
    <line x1="140" y1="110" x2="140" y2="180" stroke="#4a4a4a" stroke-width="6"/>
    <line x1="60" y1="180" x2="45" y2="180" stroke="#4a4a4a" stroke-width="6"/>
    <line x1="140" y1="180" x2="155" y2="180" stroke="#4a4a4a" stroke-width="6"/>
  </svg>
</div>
```

---

## Bileşen 6: Kurgu Zaman Çizelgesi

**Etiketler (keyword eşleşmesi için):** kurgu masası, film şeridi, film müziği
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Sırayla yerine yerleşen renkli klip bloklarından oluşan bir video kurgu zaman çizelgesi.

```html
<div class="sutol-sf-06-root">
  <style>
    .sutol-sf-06-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-06-track{position:absolute;left:8%;width:84%;height:12%;background:rgba(255,255,255,.06);border-radius:3px;}
    .sutol-sf-06-clip{position:absolute;top:10%;height:80%;border-radius:2px;opacity:0;animation:sutol-sf-06-place 5s ease-in-out infinite;}
    @keyframes sutol-sf-06-place{0%,8%{opacity:0;transform:translateY(-14px);}20%,85%{opacity:.9;transform:translateY(0);}95%,100%{opacity:0;transform:translateY(-14px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-06-clip{animation:none;opacity:.7;transform:translateY(0);}
    }
    .sutol-sf-06-playhead{position:absolute;top:22%;width:1.5%;height:56%;background:#e0637a;animation:sutol-sf-06-scan 5s linear infinite;}
    @keyframes sutol-sf-06-scan{0%{left:8%;}100%{left:88%;}}
  </style>
  <div class="sutol-sf-06-track" style="top:30%;"></div>
  <div class="sutol-sf-06-track" style="top:48%;"></div>
  <div class="sutol-sf-06-track" style="top:66%;"></div>
  <div class="sutol-sf-06-clip" style="top:31%;left:10%;width:18%;background:#5f7fbf;animation-delay:0s;"></div>
  <div class="sutol-sf-06-clip" style="top:49%;left:30%;width:22%;background:#e0637a;animation-delay:.4s;"></div>
  <div class="sutol-sf-06-clip" style="top:67%;left:55%;width:16%;background:#f2c14e;animation-delay:.8s;"></div>
  <div class="sutol-sf-06-playhead"></div>
</div>
```

---

## Bileşen 7: Storyboard Kareleri

**Etiketler (keyword eşleşmesi için):** storyboard, senaryo, animasyon karesi
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Sırayla beliren, bir sahnenin akışını anlatan storyboard kareleri.

```html
<div class="sutol-sf-07-root">
  <style>
    .sutol-sf-07-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-07-frame{position:absolute;top:32%;width:24%;height:36%;border:2px solid #8a8f96;border-radius:3px;opacity:0;animation:sutol-sf-07-reveal 6s ease-in-out infinite;background:rgba(255,255,255,.04);}
    .sutol-sf-07-sketch{position:absolute;inset:18%;border:1.5px solid #8a8f96;opacity:.5;}
    @keyframes sutol-sf-07-reveal{0%,8%{opacity:0;transform:scale(.85);}18%,80%{opacity:.9;transform:scale(1);}92%,100%{opacity:0;transform:scale(.85);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-07-frame{animation:none;opacity:.6;transform:scale(1);}
    }
  </style>
  <div class="sutol-sf-07-frame" style="left:6%;animation-delay:0s;"><div class="sutol-sf-07-sketch"></div></div>
  <div class="sutol-sf-07-frame" style="left:38%;animation-delay:1s;"><div class="sutol-sf-07-sketch"></div></div>
  <div class="sutol-sf-07-frame" style="left:70%;animation-delay:2s;"><div class="sutol-sf-07-sketch"></div></div>
</div>
```

---

## Bileşen 8: Sahne Arkası Işıkları

**Etiketler (keyword eşleşmesi için):** sahne arkası, ışık düzeni, film seti
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Bir ışık rayı üzerinde sırayla yanan stüdyo spot ışıkları.

```html
<div class="sutol-sf-08-root">
  <style>
    .sutol-sf-08-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-08-rail{position:absolute;top:15%;left:10%;width:80%;height:3%;background:#3d3d3d;border-radius:2px;}
    .sutol-sf-08-light{position:absolute;top:16%;width:8%;aspect-ratio:1/1;border-radius:50%;background:#2a2a2a;}
    .sutol-sf-08-glow{position:absolute;top:16%;width:8%;aspect-ratio:1/1;border-radius:50%;background:radial-gradient(circle,#fff4c8,transparent 70%);opacity:0;animation:sutol-sf-08-on 4.5s ease-in-out infinite;}
    @keyframes sutol-sf-08-on{0%,100%{opacity:0;}50%{opacity:1;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-08-glow{animation:none;opacity:.5;}
    }
  </style>
  <div class="sutol-sf-08-rail"></div>
  <div class="sutol-sf-08-light" style="left:16%;"></div>
  <div class="sutol-sf-08-glow" style="left:16%;animation-delay:0s;"></div>
  <div class="sutol-sf-08-light" style="left:42%;"></div>
  <div class="sutol-sf-08-glow" style="left:42%;animation-delay:1s;"></div>
  <div class="sutol-sf-08-light" style="left:68%;"></div>
  <div class="sutol-sf-08-glow" style="left:68%;animation-delay:2s;"></div>
</div>
```

---

## Bileşen 9: Aksiyon Patlaması

**Etiketler (keyword eşleşmesi için):** aksiyon sahnesi, film seti, ışık düzeni
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Merkezden dışa doğru genişleyen, dinamik bir aksiyon sahnesi patlama efekti.

```html
<div class="sutol-sf-09-root">
  <style>
    .sutol-sf-09-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-09-root svg{width:100%;height:100%;}
    .sutol-sf-09-burst{stroke:#f2994a;stroke-width:4;stroke-linecap:round;opacity:0;animation:sutol-sf-09-shoot 2.2s ease-out infinite;}
    .sutol-sf-09-core{fill:#f2c14e;animation:sutol-sf-09-pulse 2.2s ease-in-out infinite;}
    @keyframes sutol-sf-09-shoot{0%{opacity:0;stroke-dasharray:0 30;}20%{opacity:1;}60%{opacity:.8;stroke-dasharray:30 0;}100%{opacity:0;stroke-dasharray:30 0;}}
    @keyframes sutol-sf-09-pulse{0%,100%{transform:scale(1);}30%{transform:scale(1.4);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-09-burst{animation:none;opacity:.4;}
      .sutol-sf-09-core{animation:none;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <line class="sutol-sf-09-burst" x1="100" y1="100" x2="100" y2="50" style="animation-delay:0s;"/>
    <line class="sutol-sf-09-burst" x1="100" y1="100" x2="140" y2="65" style="animation-delay:.15s;"/>
    <line class="sutol-sf-09-burst" x1="100" y1="100" x2="150" y2="100" style="animation-delay:.3s;"/>
    <line class="sutol-sf-09-burst" x1="100" y1="100" x2="140" y2="135" style="animation-delay:.45s;"/>
    <line class="sutol-sf-09-burst" x1="100" y1="100" x2="100" y2="150" style="animation-delay:.6s;"/>
    <line class="sutol-sf-09-burst" x1="100" y1="100" x2="60" y2="135" style="animation-delay:.75s;"/>
    <line class="sutol-sf-09-burst" x1="100" y1="100" x2="50" y2="100" style="animation-delay:.9s;"/>
    <line class="sutol-sf-09-burst" x1="100" y1="100" x2="60" y2="65" style="animation-delay:1.05s;"/>
    <circle class="sutol-sf-09-core" cx="100" cy="100" r="12" style="transform-origin:100px 100px;"/>
  </svg>
</div>
```

---

## Bileşen 10: Gişe Rekoru Grafiği

**Etiketler (keyword eşleşmesi için):** gişe rekoru, kırmızı halı
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Sırayla yükselen çubuklarla bir filmin gişe başarısını gösteren grafik.

```html
<div class="sutol-sf-10-root">
  <style>
    .sutol-sf-10-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-10-bar{position:absolute;bottom:15%;width:9%;background:linear-gradient(180deg,#f2c14e,#d1953c);border-radius:3px 3px 0 0;transform-origin:bottom;animation:sutol-sf-10-rise 3.6s ease-in-out infinite;}
    .sutol-sf-10-star{position:absolute;bottom:82%;width:6%;aspect-ratio:1/1;opacity:0;animation:sutol-sf-10-pop 3.6s ease-in-out infinite;}
    @keyframes sutol-sf-10-rise{0%,10%{transform:scaleY(.1);}55%,80%{transform:scaleY(1);}100%{transform:scaleY(.1);}}
    @keyframes sutol-sf-10-pop{0%,50%{opacity:0;transform:scale(.4);}65%,80%{opacity:1;transform:scale(1);}100%{opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-10-bar{animation:none;transform:scaleY(.7);}
      .sutol-sf-10-star{animation:none;opacity:.6;}
    }
  </style>
  <div class="sutol-sf-10-bar" style="left:18%;height:28%;animation-delay:0s;"></div>
  <div class="sutol-sf-10-bar" style="left:34%;height:42%;animation-delay:.3s;"></div>
  <div class="sutol-sf-10-bar" style="left:50%;height:35%;animation-delay:.6s;"></div>
  <div class="sutol-sf-10-bar" style="left:66%;height:55%;animation-delay:.9s;"></div>
  <div class="sutol-sf-10-star" style="left:67%;animation-delay:.9s;">
    <svg viewBox="0 0 20 20"><polygon points="10,0 13,7 20,7 14,11 16,18 10,14 4,18 6,11 0,7 7,7" fill="#f2c14e"/></svg>
  </div>
</div>
```

---

## Bileşen 11: Film Müziği Dalgası

**Etiketler (keyword eşleşmesi için):** film müziği, kurgu masası
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Müziğin ritmine uyumlu şekilde sırayla yükselip alçalan bir ses dalgası çubuğu.

```html
<div class="sutol-sf-11-root">
  <style>
    .sutol-sf-11-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;display:flex;align-items:center;justify-content:center;gap:3%;}
    .sutol-sf-11-bar{width:4%;height:20%;background:linear-gradient(180deg,#7fa8d9,#3d6ea5);border-radius:3px;animation:sutol-sf-11-beat 1.2s ease-in-out infinite;}
    @keyframes sutol-sf-11-beat{0%,100%{height:15%;}50%{height:70%;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-11-bar{animation:none;height:40%;}
    }
  </style>
  <div class="sutol-sf-11-bar" style="animation-delay:0s;"></div>
  <div class="sutol-sf-11-bar" style="animation-delay:.15s;"></div>
  <div class="sutol-sf-11-bar" style="animation-delay:.3s;"></div>
  <div class="sutol-sf-11-bar" style="animation-delay:.45s;"></div>
  <div class="sutol-sf-11-bar" style="animation-delay:.6s;"></div>
  <div class="sutol-sf-11-bar" style="animation-delay:.75s;"></div>
  <div class="sutol-sf-11-bar" style="animation-delay:.9s;"></div>
</div>
```

---

## Bileşen 12: Animasyon Karesi

**Etiketler (keyword eşleşmesi için):** animasyon karesi, storyboard, film şeridi
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Ardışık karelerin hızla değişerek bir hareket illüzyonu oluşturduğu animasyon döngüsü.

```html
<div class="sutol-sf-12-root">
  <style>
    .sutol-sf-12-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-12-root svg{width:100%;height:100%;}
    .sutol-sf-12-ball{fill:#e0637a;offset-path:path('M40,150 Q100,40 160,150');animation:sutol-sf-12-bounce 1.6s steps(8) infinite;}
    @keyframes sutol-sf-12-bounce{0%{offset-distance:0%;}100%{offset-distance:100%;}}
    .sutol-sf-12-frame{fill:none;stroke:#8a8f96;stroke-width:2;stroke-dasharray:4 4;opacity:.4;}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-12-ball{animation:none;offset-distance:50%;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <rect class="sutol-sf-12-frame" x="20" y="30" width="160" height="140" rx="6"/>
    <path class="sutol-sf-12-frame" d="M40,150 Q100,40 160,150"/>
    <circle class="sutol-sf-12-ball" r="10"/>
  </svg>
</div>
```

---

## Bileşen 13: Kırmızı Halı

**Etiketler (keyword eşleşmesi için):** kırmızı halı, gişe rekoru
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Yavaşça açılan bir kırmızı halı ve çevresinde parlayan flaş ışıkları.

```html
<div class="sutol-sf-13-root">
  <style>
    .sutol-sf-13-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-13-carpet{position:absolute;left:50%;bottom:10%;width:16%;height:0%;transform:translateX(-50%);background:linear-gradient(180deg,#c9243a,#8f1626);animation:sutol-sf-13-roll 4s ease-out infinite;}
    @keyframes sutol-sf-13-roll{0%,10%{height:0%;}60%,100%{height:75%;}}
    .sutol-sf-13-flash{position:absolute;width:5%;aspect-ratio:1/1;border-radius:50%;background:#fff;opacity:0;animation:sutol-sf-13-pop 4s ease-in-out infinite;}
    @keyframes sutol-sf-13-pop{0%,100%{opacity:0;}45%,55%{opacity:.9;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-13-carpet{animation:none;height:75%;}
      .sutol-sf-13-flash{animation:none;opacity:.3;}
    }
  </style>
  <div class="sutol-sf-13-carpet"></div>
  <div class="sutol-sf-13-flash" style="left:20%;top:30%;animation-delay:0s;"></div>
  <div class="sutol-sf-13-flash" style="left:75%;top:25%;animation-delay:.6s;"></div>
  <div class="sutol-sf-13-flash" style="left:30%;top:60%;animation-delay:1.2s;"></div>
  <div class="sutol-sf-13-flash" style="left:70%;top:55%;animation-delay:1.8s;"></div>
</div>
```

---

## Bileşen 14: Senaryo Sayfası

**Etiketler (keyword eşleşmesi için):** senaryo, storyboard, kurgu masası
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Üzerinde satırların sırayla belirdiği açık bir senaryo sayfası.

```html
<div class="sutol-sf-14-root">
  <style>
    .sutol-sf-14-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-14-page{position:absolute;left:20%;top:12%;width:60%;height:76%;background:#f5f0e3;border-radius:4px;}
    .sutol-sf-14-line{position:absolute;left:12%;height:5%;background:#8a8f96;border-radius:2px;opacity:0;animation:sutol-sf-14-type 5s ease-in-out infinite;}
    @keyframes sutol-sf-14-type{0%,100%{opacity:0;width:0%;}30%,80%{opacity:.7;width:var(--w,70%);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-14-line{animation:none;opacity:.5;width:var(--w,70%);}
    }
  </style>
  <div class="sutol-sf-14-page"></div>
  <div class="sutol-sf-14-line" style="top:22%;--w:70%;animation-delay:0s;"></div>
  <div class="sutol-sf-14-line" style="top:32%;--w:55%;animation-delay:.5s;"></div>
  <div class="sutol-sf-14-line" style="top:42%;--w:65%;animation-delay:1s;"></div>
  <div class="sutol-sf-14-line" style="top:52%;--w:45%;animation-delay:1.5s;"></div>
  <div class="sutol-sf-14-line" style="top:62%;--w:60%;animation-delay:2s;"></div>
</div>
```

---

## Bileşen 15: Işık Düzeni Spotu

**Etiketler (keyword eşleşmesi için):** ışık düzeni, film seti, aksiyon sahnesi
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Sahneyi tarayan, sağdan sola süzülen bir spot ışığı konisi.

```html
<div class="sutol-sf-15-root">
  <style>
    .sutol-sf-15-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-15-spot{position:absolute;top:0;left:50%;width:40%;height:100%;background:linear-gradient(180deg,rgba(255,244,200,.5),transparent);clip-path:polygon(48% 0,52% 0,90% 100%,10% 100%);transform-origin:top center;animation:sutol-sf-15-sweep 5s ease-in-out infinite;}
    @keyframes sutol-sf-15-sweep{0%,100%{transform:translateX(-50%) rotate(-20deg);}50%{transform:translateX(-50%) rotate(20deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-15-spot{animation:none;transform:translateX(-50%) rotate(0deg);}
    }
  </style>
  <div class="sutol-sf-15-spot"></div>
</div>
```

---

## Bileşen 16: Klaket Sayacı

**Etiketler (keyword eşleşmesi için):** klaket, film seti, senaryo
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Sırayla küçülen dairelerle geriye sayan bir çekim başlangıç göstergesi.

```html
<div class="sutol-sf-16-root">
  <style>
    .sutol-sf-16-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-16-root svg{width:100%;height:100%;}
    .sutol-sf-16-ring{fill:none;stroke:#e0637a;stroke-width:6;stroke-linecap:round;stroke-dasharray:220;animation:sutol-sf-16-count 4s linear infinite;transform-origin:100px 100px;}
    @keyframes sutol-sf-16-count{0%{stroke-dashoffset:0;transform:rotate(-90deg);}100%{stroke-dashoffset:220;transform:rotate(-90deg);}}
    .sutol-sf-16-dot{fill:#fff;opacity:0;animation:sutol-sf-16-flash 4s linear infinite;}
    @keyframes sutol-sf-16-flash{0%,92%{opacity:0;}96%,100%{opacity:1;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-16-ring{animation:none;stroke-dashoffset:110;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <circle cx="100" cy="100" r="35" fill="none" stroke="#3a3a3a" stroke-width="6" opacity="0.4"/>
    <circle class="sutol-sf-16-ring" cx="100" cy="100" r="35"/>
    <circle class="sutol-sf-16-dot" cx="100" cy="100" r="10"/>
  </svg>
</div>
```

---

## Bileşen 17: Kamera Vinç Hareketi

**Etiketler (keyword eşleşmesi için):** kamera, film seti, sahne arkası
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Bir vinç kolu üzerinde yükselip alçalarak sahneyi tarayan sinema kamerası.

```html
<div class="sutol-sf-17-root">
  <style>
    .sutol-sf-17-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-17-root svg{width:100%;height:100%;}
    .sutol-sf-17-cam{animation:sutol-sf-17-move 6s ease-in-out infinite;}
    @keyframes sutol-sf-17-move{0%,100%{transform:translate(0,0);}50%{transform:translate(30px,-30px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-17-cam{animation:none;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <line x1="30" y1="170" x2="150" y2="60" stroke="#5a5a5a" stroke-width="5" stroke-linecap="round"/>
    <line x1="30" y1="170" x2="60" y2="170" stroke="#5a5a5a" stroke-width="5" stroke-linecap="round"/>
    <g class="sutol-sf-17-cam">
      <rect x="130" y="45" width="30" height="20" rx="3" fill="#2a2a2a"/>
      <circle cx="128" cy="55" r="8" fill="#1a1a1a"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 18: Projeksiyon Film Makarası

**Etiketler (keyword eşleşmesi için):** projeksiyon makinesi, film şeridi, kurgu masası
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Dönen iki film makarası arasında akan klasik bir sinema filmi şeridi.

```html
<div class="sutol-sf-18-root">
  <style>
    .sutol-sf-18-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-18-root svg{width:100%;height:100%;}
    .sutol-sf-18-reel{transform-origin:center;animation:sutol-sf-18-spin 3s linear infinite;}
    @keyframes sutol-sf-18-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
    .sutol-sf-18-film{stroke:#3a3a3a;stroke-width:6;fill:none;opacity:.6;}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-18-reel{animation:none;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-sf-18-film" d="M55,80 Q100,120 145,80"/>
    <g class="sutol-sf-18-reel" style="transform-origin:55px 80px;">
      <circle cx="55" cy="80" r="22" fill="none" stroke="#5f7fbf" stroke-width="4"/>
      <circle cx="55" cy="68" r="4" fill="#5f7fbf"/>
      <circle cx="66" cy="87" r="4" fill="#5f7fbf"/>
      <circle cx="44" cy="87" r="4" fill="#5f7fbf"/>
    </g>
    <g class="sutol-sf-18-reel" style="transform-origin:145px 80px;">
      <circle cx="145" cy="80" r="22" fill="none" stroke="#e0637a" stroke-width="4"/>
      <circle cx="145" cy="68" r="4" fill="#e0637a"/>
      <circle cx="156" cy="87" r="4" fill="#e0637a"/>
      <circle cx="134" cy="87" r="4" fill="#e0637a"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 19: Kurgu ve Müzik Senkronu

**Etiketler (keyword eşleşmesi için):** kurgu masası, film müziği, animasyon karesi
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Video klip bloğuyla senkronize hareket eden bir ses dalgası şeridi.

```html
<div class="sutol-sf-19-root">
  <style>
    .sutol-sf-19-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-19-clip{position:absolute;top:22%;left:10%;width:80%;height:24%;background:#5f7fbf;border-radius:3px;opacity:.5;}
    .sutol-sf-19-wave{position:absolute;top:58%;left:10%;width:80%;height:24%;display:flex;align-items:center;gap:2%;}
    .sutol-sf-19-bar{flex:1;background:#e0637a;border-radius:2px;animation:sutol-sf-19-beat 1s ease-in-out infinite;}
    @keyframes sutol-sf-19-beat{0%,100%{height:20%;}50%{height:90%;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-19-bar{animation:none;height:50%;}
    }
  </style>
  <div class="sutol-sf-19-clip"></div>
  <div class="sutol-sf-19-wave">
    <div class="sutol-sf-19-bar" style="animation-delay:0s;"></div>
    <div class="sutol-sf-19-bar" style="animation-delay:.1s;"></div>
    <div class="sutol-sf-19-bar" style="animation-delay:.2s;"></div>
    <div class="sutol-sf-19-bar" style="animation-delay:.3s;"></div>
    <div class="sutol-sf-19-bar" style="animation-delay:.4s;"></div>
    <div class="sutol-sf-19-bar" style="animation-delay:.5s;"></div>
    <div class="sutol-sf-19-bar" style="animation-delay:.6s;"></div>
    <div class="sutol-sf-19-bar" style="animation-delay:.7s;"></div>
  </div>
</div>
```

---

## Bileşen 20: Yıldız Işıltısı

**Etiketler (keyword eşleşmesi için):** gişe rekoru, kırmızı halı, film seti
**Kategori:** Sinema & Film Yapımı
**Açıklama:** Etrafında parlayan yıldızlarla kutlanan bir başarı anını simgeleyen ışıltı efekti.

```html
<div class="sutol-sf-20-root">
  <style>
    .sutol-sf-20-root{position:relative;width:100%;height:100%;overflow:hidden;background:transparent;}
    .sutol-sf-20-root svg{width:100%;height:100%;}
    .sutol-sf-20-center{fill:#f2c14e;animation:sutol-sf-20-pulse 3s ease-in-out infinite;transform-origin:100px 100px;}
    .sutol-sf-20-spark{fill:#fff4c8;opacity:0;animation:sutol-sf-20-twinkle 3s ease-in-out infinite;}
    @keyframes sutol-sf-20-pulse{0%,100%{transform:scale(1);}50%{transform:scale(1.15);}}
    @keyframes sutol-sf-20-twinkle{0%,100%{opacity:0;}50%{opacity:1;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-sf-20-center{animation:none;}
      .sutol-sf-20-spark{animation:none;opacity:.5;}
    }
  </style>
  <svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet">
    <polygon class="sutol-sf-20-center" points="100,60 112,90 145,90 118,110 128,142 100,122 72,142 82,110 55,90 88,90"/>
    <circle class="sutol-sf-20-spark" cx="60" cy="55" r="4" style="animation-delay:0s;"/>
    <circle class="sutol-sf-20-spark" cx="145" cy="60" r="3" style="animation-delay:.7s;"/>
    <circle class="sutol-sf-20-spark" cx="150" cy="130" r="4" style="animation-delay:1.4s;"/>
    <circle class="sutol-sf-20-spark" cx="55" cy="135" r="3" style="animation-delay:2.1s;"/>
  </svg>
</div>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Kamera Odaklanması): SVG `scale`/`opacity` iris odaklanma nabzı.
- Bileşen 2 (Klaket): SVG `transform-origin` rotate ile klaket kapanma hareketi.
- Bileşen 3 (Film Şeridi Akışı): CSS flex + `translateX` sürekli kayan şerit.
- Bileşen 4 (Projeksiyon Işığı): CSS `clip-path` + `opacity` titreşen ışık konisi.
- Bileşen 5 (Yönetmen Koltuğu): SVG statik sandalye + `rotate` dönen film makarası.
- Bileşen 6 (Kurgu Zaman Çizelgesi): CSS `opacity`/`translateY` sıralı klip yerleşimi + `left` playhead taraması.
- Bileşen 7 (Storyboard Kareleri): CSS `opacity`/`scale` sıralı kare belirmesi.
- Bileşen 8 (Sahne Arkası Işıkları): CSS `opacity` keyframe ile sıralı ışık yanması.
- Bileşen 9 (Aksiyon Patlaması): SVG `stroke-dasharray`/`opacity` sıralı patlama çizgileri + çekirdek `scale` nabzı.
- Bileşen 10 (Gişe Rekoru Grafiği): CSS `scaleY` çubuk yükselme + yıldız `opacity`/`scale` patlaması.
- Bileşen 11 (Film Müziği Dalgası): CSS `height` keyframe ile ritmik ses çubukları.
- Bileşen 12 (Animasyon Karesi): SVG `offset-path` + `steps()` ile kareli sıçrama illüzyonu.
- Bileşen 13 (Kırmızı Halı): CSS `height` açılma animasyonu + flaş `opacity` patlamaları.
- Bileşen 14 (Senaryo Sayfası): CSS `width`/`opacity` sıralı satır “yazılma” efekti.
- Bileşen 15 (Işık Düzeni Spotu): CSS `rotate` ile sahneyi tarayan spot ışığı.
- Bileşen 16 (Klaket Sayacı): SVG `stroke-dashoffset` geri sayım halkası + `opacity` flaş.
- Bileşen 17 (Kamera Vinç Hareketi): CSS `translate` ile vinç kolunda yukarı/aşağı kamera hareketi.
- Bileşen 18 (Projeksiyon Film Makarası): SVG çift `rotate` makara + sabit film eğrisi.
- Bileşen 19 (Kurgu ve Müzik Senkronu): CSS `height` keyframe ile klip/ses senkron animasyonu.
- Bileşen 20 (Yıldız Işıltısı): SVG `scale` nabız + `opacity` twinkle kıvılcımlar.

Tüm bileşenler: tek dosya bağımsız HTML/CSS/SVG, şeffaf arka plan, `viewBox` veya % tabanlı ölçeklenebilir boyutlandırma, `prefers-reduced-motion` desteği, sandbox uyumlu (dış kaynak/localStorage/çerez/`window.top` erişimi yok), sabit dil metni içermeyen, kendine özgü `.sutol-sf-XX-` sınıf önekleriyle kapsüllenmiş CSS kullanır.
