# Sutol – Evcil Hayvanlar & Hayvan Dünyası Kategorisi Bileşen Paketi (20 Adet)

---

## Bileşen 1: Patili İzler

**Etiketler (keyword eşleşmesi için):** patiler, hayvan izleri, doğal yaşam alanı, sürü davranışı
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Zeminde sırayla beliren pati izlerinin bir yürüyüş rotası oluşturduğu animasyon.

```html
<div class="sutol-ani01-wrap">
  <style>
    .sutol-ani01-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani01-svg{width:100%;height:100%;max-width:300px;}
    .sutol-ani01-p1{animation:sutol-ani01-step 3.6s ease-in-out infinite;}
    .sutol-ani01-p2{animation:sutol-ani01-step 3.6s ease-in-out infinite;animation-delay:.5s;}
    .sutol-ani01-p3{animation:sutol-ani01-step 3.6s ease-in-out infinite;animation-delay:1s;}
    .sutol-ani01-p4{animation:sutol-ani01-step 3.6s ease-in-out infinite;animation-delay:1.5s;}
    @keyframes sutol-ani01-step{0%,10%{opacity:0;}20%,80%{opacity:1;}95%,100%{opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani01-p1,.sutol-ani01-p2,.sutol-ani01-p3,.sutol-ani01-p4{animation:none;opacity:1;}
    }
  </style>
  <svg class="sutol-ani01-svg" viewBox="0 0 220 100">
    <g class="sutol-ani01-p1" fill="#8a5a34" transform="translate(30,60)">
      <circle r="6"/><circle cx="-8" cy="-9" r="3"/><circle cx="8" cy="-9" r="3"/><circle cx="-9" cy="4" r="3"/><circle cx="9" cy="4" r="3"/>
    </g>
    <g class="sutol-ani01-p2" fill="#8a5a34" transform="translate(75,40)">
      <circle r="6"/><circle cx="-8" cy="-9" r="3"/><circle cx="8" cy="-9" r="3"/><circle cx="-9" cy="4" r="3"/><circle cx="9" cy="4" r="3"/>
    </g>
    <g class="sutol-ani01-p3" fill="#8a5a34" transform="translate(125,60)">
      <circle r="6"/><circle cx="-8" cy="-9" r="3"/><circle cx="8" cy="-9" r="3"/><circle cx="-9" cy="4" r="3"/><circle cx="9" cy="4" r="3"/>
    </g>
    <g class="sutol-ani01-p4" fill="#8a5a34" transform="translate(170,40)">
      <circle r="6"/><circle cx="-8" cy="-9" r="3"/><circle cx="8" cy="-9" r="3"/><circle cx="-9" cy="4" r="3"/><circle cx="9" cy="4" r="3"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 2: Kanat Çırpan Kuş

**Etiketler:** kanat çırpma, tüy, göç eden kuşlar, doğal yaşam alanı
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Havada asılı kalmış gibi sürekli kanat çırpan stilize bir kuş.

```html
<div class="sutol-ani02-wrap">
  <style>
    .sutol-ani02-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani02-svg{width:100%;height:100%;max-width:260px;}
    .sutol-ani02-wingL{animation:sutol-ani02-flapL 0.6s ease-in-out infinite;transform-origin:100px 100px;}
    .sutol-ani02-wingR{animation:sutol-ani02-flapR 0.6s ease-in-out infinite;transform-origin:100px 100px;}
    @keyframes sutol-ani02-flapL{0%,100%{transform:rotate(-25deg);}50%{transform:rotate(15deg);}}
    @keyframes sutol-ani02-flapR{0%,100%{transform:rotate(25deg);}50%{transform:rotate(-15deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani02-wingL,.sutol-ani02-wingR{animation:none;}
    }
  </style>
  <svg class="sutol-ani02-svg" viewBox="0 0 200 160">
    <ellipse cx="100" cy="100" rx="20" ry="14" fill="#5aa9e6"/>
    <circle cx="118" cy="90" r="8" fill="#5aa9e6"/>
    <polygon points="126,90 138,93 126,96" fill="#f6c453"/>
    <g class="sutol-ani02-wingL">
      <path d="M100,100 Q60,80 40,105 Q65,105 100,105" fill="#3d6ee0"/>
    </g>
    <g class="sutol-ani02-wingR">
      <path d="M100,100 Q140,80 160,105 Q135,105 100,105" fill="#3d6ee0"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 3: Arı Kovanı

**Etiketler:** arı kovanı, sürü davranışı, doğal yaşam alanı, kanat çırpma
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Bir kovanın etrafında dairesel yörüngelerde uçuşan küçük arılar.

```html
<div class="sutol-ani03-wrap">
  <style>
    .sutol-ani03-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani03-svg{width:100%;height:100%;max-width:280px;}
    .sutol-ani03-b1{animation:sutol-ani03-orbit1 3s linear infinite;transform-origin:100px 90px;}
    .sutol-ani03-b2{animation:sutol-ani03-orbit2 4s linear infinite;transform-origin:100px 90px;}
    @keyframes sutol-ani03-orbit1{to{transform:rotate(360deg);}}
    @keyframes sutol-ani03-orbit2{to{transform:rotate(-360deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani03-b1,.sutol-ani03-b2{animation:none;}
    }
  </style>
  <svg class="sutol-ani03-svg" viewBox="0 0 200 180">
    <polygon points="100,140 60,120 60,80 100,60 140,80 140,120" fill="#f6c453"/>
    <ellipse cx="100" cy="100" rx="18" ry="10" fill="#8a5a34"/>
    <ellipse cx="100" cy="118" rx="14" ry="8" fill="#8a5a34"/>
    <g class="sutol-ani03-b1">
      <ellipse cx="145" cy="90" rx="6" ry="4" fill="#2b2f4a"/>
    </g>
    <g class="sutol-ani03-b2">
      <ellipse cx="60" cy="60" rx="5" ry="3.5" fill="#2b2f4a"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 4: Karınca Kolonisi Yürüyüşü

**Etiketler:** karınca kolonisi, sürü davranışı, hayvan izleri, doğal yaşam alanı
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Bir yuva girişinden çıkıp dolambaçlı bir rota izleyen karınca sırasının hareketi.

```html
<div class="sutol-ani04-wrap">
  <style>
    .sutol-ani04-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani04-svg{width:100%;height:100%;max-width:320px;}
    .sutol-ani04-a1{offset-path:path('M20,90 Q80,40 140,90 T220,60');animation:sutol-ani04-move 4s linear infinite;}
    .sutol-ani04-a2{offset-path:path('M20,90 Q80,40 140,90 T220,60');animation:sutol-ani04-move 4s linear infinite;animation-delay:1s;}
    .sutol-ani04-a3{offset-path:path('M20,90 Q80,40 140,90 T220,60');animation:sutol-ani04-move 4s linear infinite;animation-delay:2s;}
    @keyframes sutol-ani04-move{0%{offset-distance:0%;}100%{offset-distance:100%;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani04-a1,.sutol-ani04-a2,.sutol-ani04-a3{animation:none;}
    }
  </style>
  <svg class="sutol-ani04-svg" viewBox="0 0 240 120">
    <path d="M20,90 Q80,40 140,90 T220,60" fill="none" stroke="#c9b28a" stroke-width="1.5" stroke-dasharray="3 5"/>
    <circle cx="20" cy="90" r="10" fill="#3d2717"/>
    <g class="sutol-ani04-a1"><circle r="4" fill="#2b2f4a"/></g>
    <g class="sutol-ani04-a2"><circle r="4" fill="#2b2f4a"/></g>
    <g class="sutol-ani04-a3"><circle r="4" fill="#2b2f4a"/></g>
  </svg>
</div>
```

---

## Bileşen 5: Kuş Yuvası Beslenme

**Etiketler:** kuş yuvası, kanat çırpma, tüy, doğal yaşam alanı
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Bir dalda duran yuvadaki yavru kuşların periyodik olarak ağızlarını açıp kapamasını gösteren animasyon.

```html
<div class="sutol-ani05-wrap">
  <style>
    .sutol-ani05-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani05-svg{width:100%;height:100%;max-width:300px;}
    .sutol-ani05-beak{animation:sutol-ani05-open 2s ease-in-out infinite;transform-origin:bottom;}
    @keyframes sutol-ani05-open{0%,100%{transform:scaleY(1);}50%{transform:scaleY(1.8);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani05-beak{animation:none;}
    }
  </style>
  <svg class="sutol-ani05-svg" viewBox="0 0 220 140">
    <line x1="10" y1="100" x2="210" y2="100" stroke="#8a5a34" stroke-width="6"/>
    <path d="M70,100 Q110,70 150,100 Q110,120 70,100 Z" fill="#c9a876"/>
    <circle cx="90" cy="88" r="12" fill="#f2e6c9"/>
    <circle cx="130" cy="88" r="12" fill="#f2e6c9"/>
    <polygon class="sutol-ani05-beak" points="86,90 94,90 90,100" fill="#f6c453"/>
    <polygon class="sutol-ani05-beak" points="126,90 134,90 130,100" fill="#f6c453"/>
  </svg>
</div>
```

---

## Bileşen 6: Akvaryum Kabarcıkları

**Etiketler:** akvaryum, sürü davranışı, doğal yaşam alanı, kamuflaj
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Bir akvaryumda süzülen bir balık ve dipten yükselen hava kabarcıkları.

```html
<div class="sutol-ani06-wrap">
  <style>
    .sutol-ani06-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani06-svg{width:100%;height:100%;max-width:300px;}
    .sutol-ani06-fish{animation:sutol-ani06-swim 4s ease-in-out infinite;}
    .sutol-ani06-b1{animation:sutol-ani06-rise 2.2s ease-in infinite;}
    .sutol-ani06-b2{animation:sutol-ani06-rise 2.2s ease-in infinite;animation-delay:.7s;}
    @keyframes sutol-ani06-swim{0%{transform:translateX(-20px);}50%{transform:translateX(160px) scaleX(-1);}100%{transform:translateX(-20px);}}
    @keyframes sutol-ani06-rise{0%{transform:translateY(0);opacity:0;}20%{opacity:.8;}100%{transform:translateY(-70px);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani06-fish,.sutol-ani06-b1,.sutol-ani06-b2{animation:none;}
    }
  </style>
  <svg class="sutol-ani06-svg" viewBox="0 0 220 140">
    <rect x="10" y="10" width="200" height="120" rx="8" fill="#5aa9e6" opacity="0.15" stroke="#5aa9e6" stroke-width="2"/>
    <circle class="sutol-ani06-b1" cx="40" cy="110" r="3" fill="#eef4fa"/>
    <circle class="sutol-ani06-b2" cx="55" cy="110" r="2.5" fill="#eef4fa"/>
    <g class="sutol-ani06-fish">
      <ellipse cx="60" cy="70" rx="20" ry="12" fill="#f6c453"/>
      <polygon points="42,70 30,60 30,80" fill="#e6685a"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 7: Kuş Sürüsü Davranışı

**Etiketler:** sürü davranışı, göç eden kuşlar, kanat çırpma, doğal yaşam alanı
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Birbirine yakın hareket eden küçük kuş şekillerinin birlikte yön değiştirmesini gösteren sürü animasyonu.

```html
<div class="sutol-ani07-wrap">
  <style>
    .sutol-ani07-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani07-svg{width:100%;height:100%;max-width:320px;}
    .sutol-ani07-flock{animation:sutol-ani07-move 5s ease-in-out infinite;}
    @keyframes sutol-ani07-move{0%,100%{transform:translate(0,0) rotate(0deg);}50%{transform:translate(40px,-20px) rotate(6deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani07-flock{animation:none;}
    }
  </style>
  <svg class="sutol-ani07-svg" viewBox="0 0 240 140">
    <g class="sutol-ani07-flock" fill="#3d4a6b">
      <path d="M60,60 q10,-8 20,0 q10,-8 20,0"/>
      <path d="M100,80 q10,-8 20,0 q10,-8 20,0"/>
      <path d="M80,100 q10,-8 20,0 q10,-8 20,0"/>
      <path d="M140,60 q10,-8 20,0 q10,-8 20,0"/>
      <path d="M120,40 q10,-8 20,0 q10,-8 20,0"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 8: Göç Eden Kuşlar

**Etiketler:** göç eden kuşlar, sürü davranışı, kanat çırpma, doğal yaşam alanı
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** V formasyonunda uçarak yatay olarak ilerleyen bir göçmen kuş sürüsü.

```html
<div class="sutol-ani08-wrap">
  <style>
    .sutol-ani08-wrap{position:relative;width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;overflow:hidden;}
    .sutol-ani08-svg{width:100%;height:100%;max-width:320px;}
    .sutol-ani08-v{animation:sutol-ani08-fly 6s linear infinite;}
    @keyframes sutol-ani08-fly{0%{transform:translateX(-260px);}100%{transform:translateX(260px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani08-v{animation:none;}
    }
  </style>
  <svg class="sutol-ani08-svg" viewBox="0 0 240 100">
    <g class="sutol-ani08-v" fill="none" stroke="#3d4a6b" stroke-width="3" stroke-linecap="round">
      <path d="M100,50 L120,35 L140,50"/>
      <path d="M80,60 L100,45 L120,60"/>
      <path d="M120,60 L140,45 L160,60"/>
      <path d="M60,70 L80,55 L100,70"/>
      <path d="M140,70 L160,55 L180,70"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 9: Tilki-Tavşan Kovalamacası

**Etiketler:** avcı-av ilişkisi, hayvan izleri, doğal yaşam alanı, patiler
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Bir tilkinin bir tavşanı kovaladığı, ikisinin de aynı ritimde ileri geri koştuğu döngüsel sahne.

```html
<div class="sutol-ani09-wrap">
  <style>
    .sutol-ani09-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani09-svg{width:100%;height:100%;max-width:320px;}
    .sutol-ani09-rabbit{animation:sutol-ani09-run 3s ease-in-out infinite;}
    .sutol-ani09-fox{animation:sutol-ani09-run 3s ease-in-out infinite;animation-delay:.15s;}
    @keyframes sutol-ani09-run{0%,100%{transform:translateX(0);}50%{transform:translateX(60px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani09-rabbit,.sutol-ani09-fox{animation:none;}
    }
  </style>
  <svg class="sutol-ani09-svg" viewBox="0 0 240 120">
    <g class="sutol-ani09-rabbit" transform="translate(140,60)">
      <ellipse cx="0" cy="0" rx="16" ry="11" fill="#dfe3ea"/>
      <circle cx="14" cy="-8" r="7" fill="#dfe3ea"/>
      <rect x="10" y="-22" width="4" height="14" rx="2" fill="#dfe3ea"/>
      <rect x="18" y="-22" width="4" height="14" rx="2" fill="#dfe3ea"/>
    </g>
    <g class="sutol-ani09-fox" transform="translate(40,65)">
      <ellipse cx="0" cy="0" rx="22" ry="12" fill="#e6685a"/>
      <polygon points="18,-8 30,-2 18,3" fill="#e6685a"/>
      <path d="M-22,0 Q-32,5 -30,-8" fill="#e6685a"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 10: Bukalemun Kamuflajı

**Etiketler:** kamuflaj, doğal yaşam alanı, patiler, tüy
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Bir bukalemunun rengini yavaşça değiştirerek çevresine uyum sağlamasını gösteren animasyon.

```html
<div class="sutol-ani10-wrap">
  <style>
    .sutol-ani10-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani10-svg{width:100%;height:100%;max-width:280px;}
    .sutol-ani10-body{animation:sutol-ani10-color 5s ease-in-out infinite;}
    @keyframes sutol-ani10-color{0%,100%{fill:#57c48b;}33%{fill:#5aa9e6;}66%{fill:#f6c453;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani10-body{animation:none;}
    }
  </style>
  <svg class="sutol-ani10-svg" viewBox="0 0 220 140">
    <line x1="10" y1="110" x2="210" y2="110" stroke="#8a5a34" stroke-width="6"/>
    <path class="sutol-ani10-body" d="M60,110 Q60,70 100,65 Q140,60 150,90 Q160,95 155,100 Q150,90 140,95 Q120,80 100,85 Q75,90 60,110 Z" fill="#57c48b"/>
    <circle cx="145" cy="80" r="6" fill="#2b2f4a"/>
  </svg>
</div>
```

---

## Bileşen 11: Orman Yaşam Alanı

**Etiketler:** doğal yaşam alanı, kanat çırpma, sürü davranışı, göç eden kuşlar
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Ağaçların arasında uçan bir kuş ve hafifçe sallanan yapraklarla orman yaşam alanı sahnesi.

```html
<div class="sutol-ani11-wrap">
  <style>
    .sutol-ani11-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani11-svg{width:100%;height:100%;max-width:320px;}
    .sutol-ani11-tree{animation:sutol-ani11-sway 4s ease-in-out infinite;transform-origin:bottom;}
    .sutol-ani11-bird{animation:sutol-ani11-fly 4s ease-in-out infinite;}
    @keyframes sutol-ani11-sway{0%,100%{transform:rotate(-2deg);}50%{transform:rotate(2deg);}}
    @keyframes sutol-ani11-fly{0%{transform:translate(0,0);}50%{transform:translate(80px,-20px);}100%{transform:translate(0,0);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani11-tree,.sutol-ani11-bird{animation:none;}
    }
  </style>
  <svg class="sutol-ani11-svg" viewBox="0 0 240 160">
    <g class="sutol-ani11-tree">
      <rect x="45" y="90" width="14" height="60" fill="#8a5a34"/>
      <circle cx="52" cy="75" r="35" fill="#57c48b"/>
    </g>
    <g class="sutol-ani11-tree" style="animation-delay:.5s;" transform="translate(140,0)">
      <rect x="45" y="100" width="12" height="50" fill="#8a5a34"/>
      <circle cx="51" cy="88" r="28" fill="#3f8f61"/>
    </g>
    <g class="sutol-ani11-bird">
      <path d="M60,50 q8,-6 16,0 q8,-6 16,0" fill="none" stroke="#2b2f4a" stroke-width="3" stroke-linecap="round"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 12: Süzülen Tüy

**Etiketler:** tüy, kanat çırpma, doğal yaşam alanı, göç eden kuşlar
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Havada yavaşça sağa sola sallanarak süzülen bir tüyün yere iniş animasyonu.

```html
<div class="sutol-ani12-wrap">
  <style>
    .sutol-ani12-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani12-svg{width:100%;height:100%;max-width:220px;}
    .sutol-ani12-feather{animation:sutol-ani12-fall 4s ease-in-out infinite;}
    @keyframes sutol-ani12-fall{0%{transform:translate(-30px,-40px) rotate(-15deg);}50%{transform:translate(30px,10px) rotate(15deg);}100%{transform:translate(-30px,-40px) rotate(-15deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani12-feather{animation:none;}
    }
  </style>
  <svg class="sutol-ani12-svg" viewBox="0 0 160 200">
    <g class="sutol-ani12-feather">
      <path d="M80,20 Q110,60 80,140 Q50,60 80,20 Z" fill="#eef1f7" stroke="#c3cbdd" stroke-width="1.5"/>
      <line x1="80" y1="20" x2="80" y2="140" stroke="#c3cbdd" stroke-width="1.5"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 13: Kedi Patisi Oyunu

**Etiketler:** patiler, kamuflaj, doğal yaşam alanı, tüy
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Bir kedi patisinin bir yün yumağını sürekli dürtüp oynamasını gösteren animasyon.

```html
<div class="sutol-ani13-wrap">
  <style>
    .sutol-ani13-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani13-svg{width:100%;height:100%;max-width:280px;}
    .sutol-ani13-paw{animation:sutol-ani13-tap 1.6s ease-in-out infinite;transform-origin:100px 60px;}
    .sutol-ani13-yarn{animation:sutol-ani13-roll 1.6s ease-in-out infinite;}
    @keyframes sutol-ani13-tap{0%,20%{transform:rotate(0deg) translateY(0);}40%{transform:rotate(-25deg) translateY(-10px);}60%{transform:rotate(10deg) translateY(5px);}100%{transform:rotate(0deg) translateY(0);}}
    @keyframes sutol-ani13-roll{0%,50%{transform:translateX(0) rotate(0deg);}80%,100%{transform:translateX(20px) rotate(60deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani13-paw,.sutol-ani13-yarn{animation:none;}
    }
  </style>
  <svg class="sutol-ani13-svg" viewBox="0 0 200 140">
    <g class="sutol-ani13-yarn">
      <circle cx="130" cy="100" r="24" fill="#e6685a"/>
      <path d="M110,95 Q130,80 150,95 M112,105 Q130,120 148,105" stroke="#c0463b" stroke-width="2" fill="none"/>
    </g>
    <g class="sutol-ani13-paw">
      <ellipse cx="100" cy="60" rx="16" ry="12" fill="#f2c9a0"/>
      <circle cx="90" cy="50" r="5" fill="#f2c9a0"/>
      <circle cx="102" cy="47" r="5" fill="#f2c9a0"/>
      <circle cx="112" cy="52" r="5" fill="#f2c9a0"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 14: Köpek Kuyruk Sallama

**Etiketler:** patiler, tüy, doğal yaşam alanı, kamuflaj
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Mutlu bir köpeğin kuyruğunu sürekli sağa sola sallamasını gösteren sade animasyon.

```html
<div class="sutol-ani14-wrap">
  <style>
    .sutol-ani14-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani14-svg{width:100%;height:100%;max-width:280px;}
    .sutol-ani14-tail{animation:sutol-ani14-wag 0.6s ease-in-out infinite;transform-origin:150px 90px;}
    @keyframes sutol-ani14-wag{0%,100%{transform:rotate(-20deg);}50%{transform:rotate(20deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani14-tail{animation:none;}
    }
  </style>
  <svg class="sutol-ani14-svg" viewBox="0 0 220 160">
    <ellipse cx="110" cy="100" rx="45" ry="30" fill="#c9a876"/>
    <circle cx="70" cy="80" r="24" fill="#c9a876"/>
    <path d="M55,65 Q45,45 60,55 Z" fill="#8a5a34"/>
    <path d="M85,65 Q95,45 80,55 Z" fill="#8a5a34"/>
    <circle cx="63" cy="80" r="3" fill="#2b2f4a"/>
    <circle cx="78" cy="80" r="3" fill="#2b2f4a"/>
    <g class="sutol-ani14-tail">
      <path d="M150,90 Q185,75 190,50" fill="none" stroke="#8a5a34" stroke-width="9" stroke-linecap="round"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 15: Kelebek Kanat Çırpma

**Etiketler:** kanat çırpma, tüy, doğal yaşam alanı, kamuflaj
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Bir çiçek üzerinde kanatlarını sürekli açıp kapayan renkli bir kelebek.

```html
<div class="sutol-ani15-wrap">
  <style>
    .sutol-ani15-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani15-svg{width:100%;height:100%;max-width:260px;}
    .sutol-ani15-wingL{animation:sutol-ani15-flap 1s ease-in-out infinite;transform-origin:100px 70px;}
    .sutol-ani15-wingR{animation:sutol-ani15-flapR 1s ease-in-out infinite;transform-origin:100px 70px;}
    @keyframes sutol-ani15-flap{0%,100%{transform:scaleX(1) rotate(0deg);}50%{transform:scaleX(.3) rotate(-10deg);}}
    @keyframes sutol-ani15-flapR{0%,100%{transform:scaleX(1) rotate(0deg);}50%{transform:scaleX(.3) rotate(10deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani15-wingL,.sutol-ani15-wingR{animation:none;}
    }
  </style>
  <svg class="sutol-ani15-svg" viewBox="0 0 200 160">
    <line x1="100" y1="60" x2="100" y2="100" stroke="#2b2f4a" stroke-width="3"/>
    <g class="sutol-ani15-wingL" style="transform-box:fill-box;">
      <path d="M100,65 Q50,40 45,75 Q60,95 100,80 Z" fill="#e6685a"/>
    </g>
    <g class="sutol-ani15-wingR" style="transform-box:fill-box;">
      <path d="M100,65 Q150,40 155,75 Q140,95 100,80 Z" fill="#f6c453"/>
    </g>
    <line x1="60" y1="90" x2="20" y2="120" stroke="#c9a876" stroke-width="6"/>
  </svg>
</div>
```

---

## Bileşen 16: Akvaryum Balık Sürüsü

**Etiketler:** akvaryum, sürü davranışı, kamuflaj, doğal yaşam alanı
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Bir kavanoz akvaryumda birlikte yön değiştirerek yüzen küçük balık sürüsü.

```html
<div class="sutol-ani16-wrap">
  <style>
    .sutol-ani16-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani16-svg{width:100%;height:100%;max-width:280px;}
    .sutol-ani16-school{animation:sutol-ani16-move 4.6s ease-in-out infinite;}
    @keyframes sutol-ani16-move{0%{transform:translateX(-15px);}50%{transform:translateX(15px) scaleX(-1);}100%{transform:translateX(-15px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani16-school{animation:none;}
    }
  </style>
  <svg class="sutol-ani16-svg" viewBox="0 0 200 180">
    <path d="M40,60 Q40,20 100,20 Q160,20 160,60 L155,150 Q100,165 45,150 Z" fill="none" stroke="#c3cbdd" stroke-width="3"/>
    <g class="sutol-ani16-school" fill="#f6c453">
      <polygon points="80,110 96,104 96,116"/>
      <polygon points="80,110 68,105 68,115"/>
      <polygon points="110,130 126,124 126,136"/>
      <polygon points="110,130 98,125 98,135"/>
      <polygon points="95,90 111,84 111,96"/>
      <polygon points="95,90 83,85 83,95"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 17: Zıplayan Tavşan

**Etiketler:** patiler, hayvan izleri, doğal yaşam alanı, avcı-av ilişkisi
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Zemin üzerinde sürekli zıplayan bir tavşan figürü.

```html
<div class="sutol-ani17-wrap">
  <style>
    .sutol-ani17-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani17-svg{width:100%;height:100%;max-width:260px;}
    .sutol-ani17-rabbit{animation:sutol-ani17-hop 1.4s ease-in-out infinite;}
    @keyframes sutol-ani17-hop{0%,100%{transform:translateY(0) scaleY(1);}30%{transform:translateY(-30px) scaleY(1.05);}55%{transform:translateY(0) scaleY(.85);}70%{transform:translateY(0) scaleY(1);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani17-rabbit{animation:none;}
    }
  </style>
  <svg class="sutol-ani17-svg" viewBox="0 0 200 160">
    <line x1="20" y1="130" x2="180" y2="130" stroke="#c9b28a" stroke-width="2" stroke-dasharray="4 6"/>
    <g class="sutol-ani17-rabbit" transform="translate(100,100)">
      <ellipse cx="0" cy="0" rx="22" ry="16" fill="#eef1f7"/>
      <circle cx="18" cy="-12" r="10" fill="#eef1f7"/>
      <rect x="12" y="-32" width="5" height="20" rx="2.5" fill="#eef1f7"/>
      <rect x="22" y="-32" width="5" height="20" rx="2.5" fill="#eef1f7"/>
      <circle cx="22" cy="-14" r="2" fill="#2b2f4a"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 18: Gece Baykuşu Gözleri

**Etiketler:** doğal yaşam alanı, kamuflaj, göç eden kuşlar, kanat çırpma
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Karanlık bir dal üstünde oturan baykuşun gözlerinin periyodik olarak parlaması.

```html
<div class="sutol-ani18-wrap">
  <style>
    .sutol-ani18-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani18-svg{width:100%;height:100%;max-width:260px;}
    .sutol-ani18-eyes{animation:sutol-ani18-glow 3s ease-in-out infinite;}
    @keyframes sutol-ani18-glow{0%,100%{opacity:.5;}50%{opacity:1;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani18-eyes{animation:none;}
    }
  </style>
  <svg class="sutol-ani18-svg" viewBox="0 0 200 160">
    <line x1="10" y1="120" x2="190" y2="120" stroke="#5a3a24" stroke-width="8"/>
    <ellipse cx="100" cy="80" rx="45" ry="40" fill="#3d4a6b"/>
    <polygon points="70,45 82,60 60,60" fill="#3d4a6b"/>
    <polygon points="130,45 118,60 140,60" fill="#3d4a6b"/>
    <g class="sutol-ani18-eyes">
      <circle cx="82" cy="80" r="14" fill="#f6c453"/>
      <circle cx="118" cy="80" r="14" fill="#f6c453"/>
      <circle cx="82" cy="80" r="6" fill="#2b2f4a"/>
      <circle cx="118" cy="80" r="6" fill="#2b2f4a"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 19: Sallanan Papağan

**Etiketler:** tüy, kanat çırpma, doğal yaşam alanı, sürü davranışı
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Bir tünek üzerinde sağa sola sallanan renkli tüylü bir papağan.

```html
<div class="sutol-ani19-wrap">
  <style>
    .sutol-ani19-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani19-svg{width:100%;height:100%;max-width:260px;}
    .sutol-ani19-body{animation:sutol-ani19-sway 2.4s ease-in-out infinite;transform-origin:100px 110px;}
    @keyframes sutol-ani19-sway{0%,100%{transform:rotate(-6deg);}50%{transform:rotate(6deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani19-body{animation:none;}
    }
  </style>
  <svg class="sutol-ani19-svg" viewBox="0 0 200 160">
    <line x1="20" y1="120" x2="180" y2="120" stroke="#8a5a34" stroke-width="6"/>
    <g class="sutol-ani19-body">
      <ellipse cx="100" cy="90" rx="22" ry="32" fill="#57c48b"/>
      <circle cx="100" cy="55" r="16" fill="#57c48b"/>
      <polygon points="112,55 128,60 112,65" fill="#f6c453"/>
      <path d="M90,110 Q100,140 110,110" fill="#f6c453"/>
      <circle cx="106" cy="50" r="2.5" fill="#2b2f4a"/>
    </g>
  </svg>
</div>
```

---

## Bileşen 20: Yavaş Kaplumbağa

**Etiketler:** doğal yaşam alanı, kamuflaj, patiler, hayvan izleri
**Kategori:** Evcil Hayvanlar & Hayvan Dünyası

**Açıklama:** Zeminde yavaşça ilerleyen, başını ritmik olarak uzatıp geri çeken bir kaplumbağa.

```html
<div class="sutol-ani20-wrap">
  <style>
    .sutol-ani20-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-ani20-svg{width:100%;height:100%;max-width:300px;}
    .sutol-ani20-turtle{animation:sutol-ani20-walk 6s linear infinite;}
    .sutol-ani20-head{animation:sutol-ani20-peek 2.4s ease-in-out infinite;transform-origin:right center;}
    @keyframes sutol-ani20-walk{0%{transform:translateX(-30px);}100%{transform:translateX(30px);}}
    @keyframes sutol-ani20-peek{0%,100%{transform:scaleX(1);}50%{transform:scaleX(0.6);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-ani20-turtle,.sutol-ani20-head{animation:none;}
    }
  </style>
  <svg class="sutol-ani20-svg" viewBox="0 0 220 120">
    <line x1="10" y1="100" x2="210" y2="100" stroke="#c9b28a" stroke-width="2" stroke-dasharray="4 6"/>
    <g class="sutol-ani20-turtle" transform="translate(100,75)">
      <ellipse cx="0" cy="0" rx="40" ry="24" fill="#57c48b"/>
      <path d="M-30,10 Q0,25 30,10" fill="none" stroke="#3f8f61" stroke-width="2"/>
      <g class="sutol-ani20-head">
        <ellipse cx="45" cy="0" rx="12" ry="9" fill="#7bd39f"/>
      </g>
      <ellipse cx="-30" cy="18" rx="8" ry="5" fill="#7bd39f"/>
      <ellipse cx="30" cy="18" rx="8" ry="5" fill="#7bd39f"/>
    </g>
  </svg>
</div>
```

---

## Kalite Kontrol Özeti

- **Bileşen 1:** Dört pati izinin sıralı opacity belirip kaybolması; hafif.
- **Bileşen 2:** İki kanadın zıt yönlü `rotate` çırpınması; hafif.
- **Bileşen 3:** İki arının farklı yön ve hızda `rotate` yörüngesi; hafif.
- **Bileşen 4:** `offset-path` ile üç karıncanın rota üzerinde ilerlemesi; hafif (offset-path desteklemeyen tarayıcıda karıncalar sabit kalır).
- **Bileşen 5:** İki gaganın `scaleY` ile açılıp kapanması; hafif.
- **Bileşen 6:** Balığın `translateX/scaleX` yüzüşü + kabarcıkların gecikmeli yükselişi; hafif.
- **Bileşen 7:** Sürünün toplu `translate/rotate` yön değiştirmesi; hafif.
- **Bileşen 8:** V formasyonunun `translateX` ile yatay geçişi; hafif.
- **Bileşen 9:** İki karakterin senkronize gecikmeli `translateX` koşusu; hafif.
- **Bileşen 10:** Vücudun `fill` renk geçişi; hafif.
- **Bileşen 11:** İki ağacın `rotate` salınımı + kuşun `translate` uçuşu; hafif.
- **Bileşen 12:** Tüyün `translate/rotate` ile süzülerek düşmesi; hafif.
- **Bileşen 13:** Patinin `rotate/translateY` dürtme hareketi + yumağın `translateX/rotate` yuvarlanması; hafif.
- **Bileşen 14:** Kuyruğun `rotate` sallanması; hafif.
- **Bileşen 15:** İki kanadın `scaleX/rotate` ile çırpınması; hafif.
- **Bileşen 16:** Balık sürüsünün `translateX/scaleX` ile yön değiştirmesi; hafif.
- **Bileşen 17:** Tavşanın `translateY/scaleY` ile zıplaması; hafif.
- **Bileşen 18:** Gözlerin opacity pulse'ı; çok hafif.
- **Bileşen 19:** Papağan gövdesinin `rotate` salınımı; hafif.
- **Bileşen 20:** Kaplumbağanın `translateX` yürüyüşü + başın `scaleX` ile içeri çekilmesi; hafif.

Tüm bileşenler `prefers-reduced-motion` desteği içerir, şeffaf arka plana sahiptir, sabit metin barındırmaz, viewBox tabanlı ölçeklenebilirlik kullanır ve dış kaynağa bağımlı değildir.
