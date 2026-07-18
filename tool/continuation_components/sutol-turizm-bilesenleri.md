# Sutol Turizm / Seyahat Kategorisi — 20 Animasyonlu Bileşen

Kimya dosyasındaki aynı teknik kurallara (tek dosya, şeffaf arka plan, viewBox tabanlı ölçekleme, `prefers-reduced-motion`, prefixli CSS, sabit metin yok) uyularak hazırlanmıştır.

---

## Bileşen 1: Sürdürülebilir Turizm — Güneş Panelli Eko-Otel

**Etiketler:** sürdürülebilir turizm, butik otel deneyimi
**Kategori:** Turizm / Seyahat
**Açıklama:** Çatısındaki güneş panelinin parıldadığı ve enerji akışının eve doğru aktığı bir eko-otel simgesi.

```html
<div class="sutol-trvl-01-wrap">
  <svg class="sutol-trvl-01-svg" viewBox="0 0 220 180" xmlns="http://www.w3.org/2000/svg">
    <polygon points="30,90 110,30 190,90" fill="#8d6e63"/>
    <rect x="45" y="90" width="130" height="70" fill="#d7ccc8"/>
    <rect x="55" y="45" width="90" height="18" rx="2" fill="#1565c0" class="sutol-trvl-01-panel"/>
    <circle class="sutol-trvl-01-spark" cx="100" cy="50" r="3" fill="#ffd54f"/>
    <circle class="sutol-trvl-01-spark" cx="120" cy="54" r="3" fill="#ffd54f" style="animation-delay:.5s"/>
    <circle class="sutol-trvl-01-spark" cx="80" cy="54" r="3" fill="#ffd54f" style="animation-delay:1s"/>
  </svg>
  <style>
    .sutol-trvl-01-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-01-svg{width:100%;height:100%;max-width:340px;}
    .sutol-trvl-01-panel{animation:sutol-trvl-01-glow 3s ease-in-out infinite;}
    .sutol-trvl-01-spark{animation:sutol-trvl-01-rise 2.4s ease-in infinite;}
    @keyframes sutol-trvl-01-glow{0%,100%{opacity:0.7;}50%{opacity:1;filter:brightness(1.3);}}
    @keyframes sutol-trvl-01-rise{0%{transform:translateY(0);opacity:0.9;}100%{transform:translateY(-40px);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-01-panel,.sutol-trvl-01-spark{animation-duration:12s;}
    }
  </style>
</div>
```

---

## Bileşen 2: Sürdürülebilir Turizm — Fidan ve Karbon Döngüsü

**Etiketler:** sürdürülebilir turizm
**Kategori:** Turizm / Seyahat
**Açıklama:** Büyüyen bir fidanın etrafında dönen döngüsel bir yaprak akışıyla karbon nötr yaklaşımı simgeler.

```html
<div class="sutol-trvl-02-wrap">
  <svg class="sutol-trvl-02-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-trvl-02-stem" d="M 100 160 L 100 90" stroke="#6d4c41" stroke-width="5" stroke-linecap="round"/>
    <path class="sutol-trvl-02-leaf" d="M 100 90 Q 70 70 90 50 Q 110 70 100 90 Z" fill="#4caf50"/>
    <circle class="sutol-trvl-02-orbit" cx="100" cy="110" r="55" fill="none" stroke="#81c784" stroke-width="2" stroke-dasharray="6 10"/>
  </svg>
  <style>
    .sutol-trvl-02-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-02-svg{width:100%;height:100%;max-width:260px;}
    .sutol-trvl-02-leaf{animation:sutol-trvl-02-sway 3s ease-in-out infinite;transform-origin:100px 90px;}
    .sutol-trvl-02-orbit{animation:sutol-trvl-02-spin 8s linear infinite;transform-origin:100px 110px;}
    @keyframes sutol-trvl-02-sway{0%,100%{transform:rotate(-4deg);}50%{transform:rotate(4deg);}}
    @keyframes sutol-trvl-02-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-02-leaf,.sutol-trvl-02-orbit{animation-duration:24s;}
    }
  </style>
</div>
```

---

## Bileşen 3: Butik Otel Deneyimi — Sıcak Karşılama

**Etiketler:** butik otel deneyimi
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir anahtarın kapı üzerinde hafifçe sallanmasıyla butik otelin samimi karşılama hissini yansıtır.

```html
<div class="sutol-trvl-03-wrap">
  <svg class="sutol-trvl-03-svg" viewBox="0 0 180 180" xmlns="http://www.w3.org/2000/svg">
    <rect x="50" y="30" width="80" height="130" rx="6" fill="#a1887f"/>
    <circle cx="115" cy="95" r="4" fill="#fff3e0"/>
    <g class="sutol-trvl-03-key" transform="translate(140,95)">
      <circle r="10" fill="none" stroke="#ffca28" stroke-width="4"/>
      <line x1="9" y1="0" x2="26" y2="0" stroke="#ffca28" stroke-width="4"/>
      <line x1="22" y1="0" x2="22" y2="8" stroke="#ffca28" stroke-width="4"/>
    </g>
  </svg>
  <style>
    .sutol-trvl-03-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-03-svg{width:100%;height:100%;max-width:260px;}
    .sutol-trvl-03-key{animation:sutol-trvl-03-swing 2.6s ease-in-out infinite;transform-origin:140px 85px;}
    @keyframes sutol-trvl-03-swing{0%,100%{transform:translate(140px,95px) rotate(-14deg);}50%{transform:translate(140px,95px) rotate(14deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-03-key{animation-duration:10s;}
    }
  </style>
</div>
```

---

## Bileşen 4: Butik Otel Deneyimi — Balkon Manzarası

**Etiketler:** butik otel deneyimi
**Kategori:** Turizm / Seyahat
**Açıklama:** Rüzgarda hafifçe dalgalanan bir perde ve ardında beliren gün ışığıyla huzurlu bir otel odası hissi verir.

```html
<div class="sutol-trvl-04-wrap">
  <svg class="sutol-trvl-04-svg" viewBox="0 0 200 160" xmlns="http://www.w3.org/2000/svg">
    <circle class="sutol-trvl-04-sun" cx="150" cy="45" r="22" fill="#ffd54f"/>
    <rect x="20" y="20" width="160" height="120" fill="none" stroke="#8d6e63" stroke-width="6"/>
    <path class="sutol-trvl-04-curtain" d="M 30 25 Q 45 70 30 135 L 55 135 Q 40 70 55 25 Z" fill="#fbe9e7" opacity="0.85"/>
  </svg>
  <style>
    .sutol-trvl-04-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-04-svg{width:100%;height:100%;max-width:320px;}
    .sutol-trvl-04-curtain{animation:sutol-trvl-04-flow 3.4s ease-in-out infinite;transform-origin:30px 25px;}
    .sutol-trvl-04-sun{animation:sutol-trvl-04-glow 4s ease-in-out infinite;}
    @keyframes sutol-trvl-04-flow{0%,100%{transform:skewX(0deg);}50%{transform:skewX(6deg);}}
    @keyframes sutol-trvl-04-glow{0%,100%{opacity:0.7;}50%{opacity:1;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-04-curtain,.sutol-trvl-04-sun{animation-duration:14s;}
    }
  </style>
</div>
```

---

## Bileşen 5: Miras Turizmi — Antik Sütunlar

**Etiketler:** miras turizmi
**Kategori:** Turizm / Seyahat
**Açıklama:** Güneş ışığının antik sütunlar üzerinde yavaşça kayarak tarihi bir atmosfer oluşturduğu animasyon.

```html
<div class="sutol-trvl-05-wrap">
  <svg class="sutol-trvl-05-svg" viewBox="0 0 220 160" xmlns="http://www.w3.org/2000/svg">
    <rect x="30" y="40" width="14" height="90" fill="#d7ccc8"/>
    <rect x="70" y="40" width="14" height="90" fill="#d7ccc8"/>
    <rect x="110" y="40" width="14" height="90" fill="#d7ccc8"/>
    <rect x="150" y="40" width="14" height="90" fill="#d7ccc8"/>
    <rect x="20" y="30" width="160" height="10" fill="#bcaaa4"/>
    <rect x="20" y="130" width="160" height="10" fill="#bcaaa4"/>
    <rect class="sutol-trvl-05-light" x="0" y="20" width="40" height="120" fill="#fff9c4" opacity="0.35"/>
  </svg>
  <style>
    .sutol-trvl-05-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-05-svg{width:100%;height:100%;max-width:340px;}
    .sutol-trvl-05-light{animation:sutol-trvl-05-sweep 5s linear infinite;}
    @keyframes sutol-trvl-05-sweep{0%{transform:translateX(0);}100%{transform:translateX(200px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-05-light{animation-duration:20s;}
    }
  </style>
</div>
```

---

## Bileşen 6: Miras Turizmi — Eski Harita ve Pusula

**Etiketler:** miras turizmi, backpacking
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir pusula ibresinin sürekli döndüğü, eski bir harita üzerinde keşif temasını işleyen animasyon.

```html
<div class="sutol-trvl-06-wrap">
  <svg class="sutol-trvl-06-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <circle cx="100" cy="100" r="70" fill="#efebe0" stroke="#a1887f" stroke-width="4"/>
    <circle cx="100" cy="100" r="50" fill="none" stroke="#bcaaa4" stroke-width="2" stroke-dasharray="4 6"/>
    <g class="sutol-trvl-06-needle" transform-origin="100 100">
      <polygon points="100,55 108,100 100,108 92,100" fill="#c62828"/>
      <polygon points="100,145 108,100 100,92 92,100" fill="#455a64"/>
    </g>
  </svg>
  <style>
    .sutol-trvl-06-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-06-svg{width:100%;height:100%;max-width:280px;}
    .sutol-trvl-06-needle{animation:sutol-trvl-06-spin 6s ease-in-out infinite;}
    @keyframes sutol-trvl-06-spin{0%{transform:rotate(0deg);}25%{transform:rotate(30deg);}50%{transform:rotate(-15deg);}75%{transform:rotate(10deg);}100%{transform:rotate(0deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-06-needle{animation-duration:24s;}
    }
  </style>
</div>
```

---

## Bileşen 7: Sağlık Turizmi — Termal Kaplıca Buharı

**Etiketler:** sağlık turizmi
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir termal havuzdan yükselen buhar dumanlarıyla dinlendirici bir sağlık turizmi atmosferi verir.

```html
<div class="sutol-trvl-07-wrap">
  <svg class="sutol-trvl-07-svg" viewBox="0 0 220 160" xmlns="http://www.w3.org/2000/svg">
    <ellipse cx="110" cy="130" rx="90" ry="20" fill="#4fc3f7"/>
    <path class="sutol-trvl-07-steam" d="M 70 110 Q 60 80 75 55" fill="none" stroke="#e0f7fa" stroke-width="6" stroke-linecap="round" opacity="0.7"/>
    <path class="sutol-trvl-07-steam" d="M 110 110 Q 100 75 115 45" fill="none" stroke="#e0f7fa" stroke-width="6" stroke-linecap="round" opacity="0.7" style="animation-delay:.7s"/>
    <path class="sutol-trvl-07-steam" d="M 150 110 Q 140 80 155 55" fill="none" stroke="#e0f7fa" stroke-width="6" stroke-linecap="round" opacity="0.7" style="animation-delay:1.4s"/>
  </svg>
  <style>
    .sutol-trvl-07-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-07-svg{width:100%;height:100%;max-width:340px;}
    .sutol-trvl-07-steam{animation:sutol-trvl-07-rise 3s ease-in-out infinite;transform-origin:bottom center;}
    @keyframes sutol-trvl-07-rise{0%{opacity:0;transform:translateY(10px) scale(0.9);}40%{opacity:0.8;}100%{opacity:0;transform:translateY(-30px) scale(1.15);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-07-steam{animation-duration:12s;}
    }
  </style>
</div>
```

---

## Bileşen 8: Sağlık Turizmi — Nefes ve Denge

**Etiketler:** sağlık turizmi
**Kategori:** Turizm / Seyahat
**Açıklama:** Genişleyip daralan bir daire ile nefes egzersizi ritmini simgeleyen sakinleştirici bir sağlık/wellness animasyonu.

```html
<div class="sutol-trvl-08-wrap">
  <svg class="sutol-trvl-08-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <circle class="sutol-trvl-08-outer" cx="100" cy="100" r="40" fill="none" stroke="#80cbc4" stroke-width="3"/>
    <circle class="sutol-trvl-08-inner" cx="100" cy="100" r="26" fill="#4db6ac" opacity="0.6"/>
  </svg>
  <style>
    .sutol-trvl-08-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-08-svg{width:100%;height:100%;max-width:240px;}
    .sutol-trvl-08-outer,.sutol-trvl-08-inner{animation:sutol-trvl-08-breathe 5s ease-in-out infinite;transform-origin:100px 100px;}
    .sutol-trvl-08-inner{animation-delay:.15s;}
    @keyframes sutol-trvl-08-breathe{0%,100%{transform:scale(0.8);}50%{transform:scale(1.25);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-08-outer,.sutol-trvl-08-inner{animation-duration:14s;}
    }
  </style>
</div>
```

---

## Bileşen 9: Kruvaziyer Seyahati — Dalgalarda Gemi

**Etiketler:** kruvaziyer seyahati
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir okyanus gemisinin dalgalar üzerinde hafifçe yükselip alçaldığı bir kruvaziyer seyahati animasyonu.

```html
<div class="sutol-trvl-09-wrap">
  <svg class="sutol-trvl-09-svg" viewBox="0 0 260 160" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-trvl-09-ship">
      <rect x="90" y="60" width="80" height="35" rx="4" fill="#eceff1"/>
      <rect x="110" y="35" width="16" height="30" fill="#b0bec5"/>
      <polygon points="80,95 180,95 165,115 95,115" fill="#455a64"/>
    </g>
    <path class="sutol-trvl-09-wave" d="M 20 130 Q 50 115 80 130 T 140 130 T 200 130 T 260 130" fill="none" stroke="#4fc3f7" stroke-width="4"/>
  </svg>
  <style>
    .sutol-trvl-09-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-09-svg{width:100%;height:100%;max-width:400px;}
    .sutol-trvl-09-ship{animation:sutol-trvl-09-bob 3.2s ease-in-out infinite;}
    .sutol-trvl-09-wave{animation:sutol-trvl-09-drift 3.2s ease-in-out infinite;}
    @keyframes sutol-trvl-09-bob{0%,100%{transform:translateY(0);}50%{transform:translateY(-6px);}}
    @keyframes sutol-trvl-09-drift{0%,100%{transform:translateX(0);}50%{transform:translateX(-12px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-09-ship,.sutol-trvl-09-wave{animation-duration:12s;}
    }
  </style>
</div>
```

---

## Bileşen 10: Kruvaziyer Seyahati — Liman Durağı

**Etiketler:** kruvaziyer seyahati
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir liman feneri ışığının dönerek yanıp söndüğü, duraklama noktalarını simgeleyen bir animasyon.

```html
<div class="sutol-trvl-10-wrap">
  <svg class="sutol-trvl-10-svg" viewBox="0 0 160 200" xmlns="http://www.w3.org/2000/svg">
    <rect x="70" y="70" width="20" height="110" fill="#ef5350"/>
    <polygon points="60,70 100,70 90,45 70,45" fill="#eceff1"/>
    <circle class="sutol-trvl-10-light" cx="80" cy="50" r="10" fill="#fff59d"/>
    <path class="sutol-trvl-10-beam" d="M 80 50 L 30 20 L 30 40 Z" fill="#fff9c4" opacity="0.4"/>
  </svg>
  <style>
    .sutol-trvl-10-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-10-svg{width:100%;height:100%;max-width:220px;}
    .sutol-trvl-10-light{animation:sutol-trvl-10-blink 2s ease-in-out infinite;}
    .sutol-trvl-10-beam{animation:sutol-trvl-10-sweep 4s linear infinite;transform-origin:80px 50px;}
    @keyframes sutol-trvl-10-blink{0%,100%{opacity:0.5;}50%{opacity:1;}}
    @keyframes sutol-trvl-10-sweep{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-10-light,.sutol-trvl-10-beam{animation-duration:16s;}
    }
  </style>
</div>
```

---

## Bileşen 11: Backpacking — Dağ Patikası

**Etiketler:** backpacking
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir dağ silüeti önünde kesikli bir patika çizgisinin sürekli akarak yürüyüş rotasını simgelediği animasyon.

```html
<div class="sutol-trvl-11-wrap">
  <svg class="sutol-trvl-11-svg" viewBox="0 0 220 160" xmlns="http://www.w3.org/2000/svg">
    <polygon points="20,140 80,50 120,100 160,40 210,140" fill="#8d9ba8"/>
    <path class="sutol-trvl-11-trail" d="M 30 140 Q 90 110 130 130 T 210 130" fill="none" stroke="#ff8a65" stroke-width="4" stroke-dasharray="8 8"/>
  </svg>
  <style>
    .sutol-trvl-11-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-11-svg{width:100%;height:100%;max-width:340px;}
    .sutol-trvl-11-trail{animation:sutol-trvl-11-flow 1.6s linear infinite;}
    @keyframes sutol-trvl-11-flow{to{stroke-dashoffset:-32;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-11-trail{animation-duration:8s;}
    }
  </style>
</div>
```

---

## Bileşen 12: Backpacking — Sırt Çantası ve Çadır

**Etiketler:** backpacking
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir sırt çantasının hafifçe sallandığı, arka planda bir çadırın belirdiği macera temalı animasyon.

```html
<div class="sutol-trvl-12-wrap">
  <svg class="sutol-trvl-12-svg" viewBox="0 0 220 160" xmlns="http://www.w3.org/2000/svg">
    <polygon points="140,140 180,90 220,140" fill="#66bb6a" opacity="0.85"/>
    <g class="sutol-trvl-12-pack" transform="translate(70,90)">
      <rect x="-22" y="-10" width="44" height="55" rx="10" fill="#ff7043"/>
      <rect x="-14" y="-25" width="28" height="20" rx="6" fill="#f4511e"/>
      <line x1="-22" y1="10" x2="22" y2="10" stroke="#bf360c" stroke-width="3"/>
    </g>
  </svg>
  <style>
    .sutol-trvl-12-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-12-svg{width:100%;height:100%;max-width:340px;}
    .sutol-trvl-12-pack{animation:sutol-trvl-12-sway 2.6s ease-in-out infinite;transform-origin:70px 145px;}
    @keyframes sutol-trvl-12-sway{0%,100%{transform:translate(70px,90px) rotate(-3deg);}50%{transform:translate(70px,90px) rotate(3deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-12-pack{animation-duration:10s;}
    }
  </style>
</div>
```

---

## Bileşen 13: Gastronomi Turu — Sokak Lezzeti Buharı

**Etiketler:** gastronomi turu
**Kategori:** Turizm / Seyahat
**Açıklama:** Sıcak bir yemek tabağından yükselen buharla sokak lezzetleri ve gastronomi turu temasını işler.

```html
<div class="sutol-trvl-13-wrap">
  <svg class="sutol-trvl-13-svg" viewBox="0 0 200 160" xmlns="http://www.w3.org/2000/svg">
    <ellipse cx="100" cy="120" rx="70" ry="16" fill="#ffcc80"/>
    <ellipse cx="100" cy="112" rx="55" ry="10" fill="#ffe0b2"/>
    <path class="sutol-trvl-13-steam" d="M 80 95 Q 70 65 85 40" fill="none" stroke="#eeeeee" stroke-width="5" stroke-linecap="round" opacity="0.7"/>
    <path class="sutol-trvl-13-steam" d="M 110 95 Q 100 60 115 35" fill="none" stroke="#eeeeee" stroke-width="5" stroke-linecap="round" opacity="0.7" style="animation-delay:.6s"/>
  </svg>
  <style>
    .sutol-trvl-13-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-13-svg{width:100%;height:100%;max-width:320px;}
    .sutol-trvl-13-steam{animation:sutol-trvl-13-rise 2.6s ease-in-out infinite;}
    @keyframes sutol-trvl-13-rise{0%{opacity:0;transform:translateY(8px) scale(0.9);}40%{opacity:0.8;}100%{opacity:0;transform:translateY(-25px) scale(1.1);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-13-steam{animation-duration:10.4s;}
    }
  </style>
</div>
```

---

## Bileşen 14: Gastronomi Turu — Şarap Tadımı

**Etiketler:** gastronomi turu
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir kadehin içindeki şarabın hafifçe dalgalandığı, tadım anını simgeleyen zarif bir animasyon.

```html
<div class="sutol-trvl-14-wrap">
  <svg class="sutol-trvl-14-svg" viewBox="0 0 140 200" xmlns="http://www.w3.org/2000/svg">
    <line x1="70" y1="120" x2="70" y2="180" stroke="#8d6e63" stroke-width="4"/>
    <line x1="45" y1="180" x2="95" y2="180" stroke="#8d6e63" stroke-width="4"/>
    <path d="M 30 40 Q 30 100 70 120 Q 110 100 110 40 Z" fill="none" stroke="#bdbdbd" stroke-width="3"/>
    <path class="sutol-trvl-14-wine" d="M 34 70 Q 70 80 106 70 L 104 95 Q 70 108 36 95 Z" fill="#8e2436"/>
  </svg>
  <style>
    .sutol-trvl-14-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-14-svg{width:100%;height:100%;max-width:220px;}
    .sutol-trvl-14-wine{animation:sutol-trvl-14-swirl 3s ease-in-out infinite;transform-origin:70px 90px;}
    @keyframes sutol-trvl-14-swirl{0%,100%{transform:rotate(-3deg) scaleY(1);}50%{transform:rotate(3deg) scaleY(1.04);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-14-wine{animation-duration:12s;}
    }
  </style>
</div>
```

---

## Bileşen 15: Gastronomi Turu — Yerel Pazar Sepeti

**Etiketler:** gastronomi turu
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir sepetten taşan yerel ürünlerin hafifçe zıplayarak belirdiği canlı bir pazar yeri animasyonu.

```html
<div class="sutol-trvl-15-wrap">
  <svg class="sutol-trvl-15-svg" viewBox="0 0 200 160" xmlns="http://www.w3.org/2000/svg">
    <path d="M 50 90 L 150 90 L 140 150 L 60 150 Z" fill="#d7ccc8" stroke="#8d6e63" stroke-width="3"/>
    <circle class="sutol-trvl-15-item" cx="75" cy="80" r="14" fill="#e53935"/>
    <circle class="sutol-trvl-15-item" cx="105" cy="72" r="12" fill="#fb8c00" style="animation-delay:.4s"/>
    <circle class="sutol-trvl-15-item" cx="130" cy="82" r="13" fill="#7cb342" style="animation-delay:.8s"/>
  </svg>
  <style>
    .sutol-trvl-15-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-15-svg{width:100%;height:100%;max-width:320px;}
    .sutol-trvl-15-item{animation:sutol-trvl-15-bounce 2.4s ease-in-out infinite;transform-origin:center;transform-box:fill-box;}
    @keyframes sutol-trvl-15-bounce{0%,100%{transform:translateY(0);}50%{transform:translateY(-8px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-15-item{animation-duration:9.6s;}
    }
  </style>
</div>
```

---

## Bileşen 16: Karavan Seyahati — Yol Üstünde Karavan

**Etiketler:** karavan seyahati
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir karavanın uzayan yol çizgileri üzerinde ilerlediği, özgür bir yolculuk hissi veren animasyon.

```html
<div class="sutol-trvl-16-wrap">
  <svg class="sutol-trvl-16-svg" viewBox="0 0 260 150" xmlns="http://www.w3.org/2000/svg">
    <rect x="20" y="120" width="220" height="6" fill="#78909c"/>
    <line class="sutol-trvl-16-dash" x1="0" y1="123" x2="260" y2="123" stroke="#fff9c4" stroke-width="4" stroke-dasharray="14 14"/>
    <g class="sutol-trvl-16-van">
      <rect x="90" y="60" width="90" height="50" rx="8" fill="#fdd835"/>
      <rect x="100" y="70" width="24" height="18" fill="#b3e5fc"/>
      <circle cx="110" cy="112" r="10" fill="#37474f"/>
      <circle cx="165" cy="112" r="10" fill="#37474f"/>
    </g>
  </svg>
  <style>
    .sutol-trvl-16-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-16-svg{width:100%;height:100%;max-width:420px;}
    .sutol-trvl-16-dash{animation:sutol-trvl-16-move 1.4s linear infinite;}
    .sutol-trvl-16-van{animation:sutol-trvl-16-bump 0.6s ease-in-out infinite;}
    @keyframes sutol-trvl-16-move{to{stroke-dashoffset:-56;}}
    @keyframes sutol-trvl-16-bump{0%,100%{transform:translateY(0);}50%{transform:translateY(-2px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-16-dash,.sutol-trvl-16-van{animation-duration:7s;}
    }
  </style>
</div>
```

---

## Bileşen 17: Karavan Seyahati — Kamp Ateşi

**Etiketler:** karavan seyahati, backpacking
**Kategori:** Turizm / Seyahat
**Açıklama:** Gece göğünde parlayan yıldızlar ve titreyen bir kamp ateşiyle özgür kamp hayatını simgeler.

```html
<div class="sutol-trvl-17-wrap">
  <svg class="sutol-trvl-17-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <circle class="sutol-trvl-17-star" cx="50" cy="40" r="2.5" fill="#fff9c4"/>
    <circle class="sutol-trvl-17-star" cx="140" cy="30" r="2" fill="#fff9c4" style="animation-delay:.6s"/>
    <circle class="sutol-trvl-17-star" cx="100" cy="55" r="2" fill="#fff9c4" style="animation-delay:1.2s"/>
    <polygon points="80,170 120,170 105,140 95,140" fill="#5d4037"/>
    <path class="sutol-trvl-17-flame" d="M 100 140 C 112 125 116 112 100 95 C 84 112 88 125 100 140 Z" fill="#ff7043"/>
  </svg>
  <style>
    .sutol-trvl-17-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-17-svg{width:100%;height:100%;max-width:260px;}
    .sutol-trvl-17-star{animation:sutol-trvl-17-twinkle 2.4s ease-in-out infinite;}
    .sutol-trvl-17-flame{animation:sutol-trvl-17-flick 1.4s ease-in-out infinite;transform-origin:100px 140px;}
    @keyframes sutol-trvl-17-twinkle{0%,100%{opacity:0.3;}50%{opacity:1;}}
    @keyframes sutol-trvl-17-flick{0%,100%{transform:scaleY(1) skewX(0deg);}50%{transform:scaleY(1.1) skewX(3deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-17-star,.sutol-trvl-17-flame{animation-duration:9.6s;}
    }
  </style>
</div>
```

---

## Bileşen 18: Miras Turizmi — Müze Vitrini

**Etiketler:** miras turizmi
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir vitrin içindeki tarihi eser üzerine düşen spot ışığının yavaşça parladığı bir müze animasyonu.

```html
<div class="sutol-trvl-18-wrap">
  <svg class="sutol-trvl-18-svg" viewBox="0 0 180 180" xmlns="http://www.w3.org/2000/svg">
    <rect x="40" y="60" width="100" height="90" fill="none" stroke="#90a4ae" stroke-width="3"/>
    <ellipse cx="90" cy="130" rx="30" ry="8" fill="#cfd8dc"/>
    <path d="M 75 130 L 80 90 L 100 90 L 105 130 Z" fill="#d7ccc8" stroke="#8d6e63" stroke-width="2"/>
    <polygon class="sutol-trvl-18-spot" points="90,20 60,60 120,60" fill="#fff9c4" opacity="0.4"/>
  </svg>
  <style>
    .sutol-trvl-18-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-18-svg{width:100%;height:100%;max-width:260px;}
    .sutol-trvl-18-spot{animation:sutol-trvl-18-glow 3.4s ease-in-out infinite;}
    @keyframes sutol-trvl-18-glow{0%,100%{opacity:0.2;}50%{opacity:0.55;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-18-spot{animation-duration:13.6s;}
    }
  </style>
</div>
```

---

## Bileşen 19: Sağlık Turizmi — Damla ve İyileşme

**Etiketler:** sağlık turizmi
**Kategori:** Turizm / Seyahat
**Açıklama:** Suya düşen bir damlanın yaydığı genişleyen halkalarla sağlık turizmindeki huzur ve iyileşme hissini verir.

```html
<div class="sutol-trvl-19-wrap">
  <svg class="sutol-trvl-19-svg" viewBox="0 0 200 160" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="90" width="180" height="50" fill="#b3e5fc" opacity="0.6"/>
    <circle class="sutol-trvl-19-drop" cx="100" cy="30" r="7" fill="#4fc3f7"/>
    <circle class="sutol-trvl-19-ripple" cx="100" cy="95" r="10" fill="none" stroke="#4fc3f7" stroke-width="2"/>
  </svg>
  <style>
    .sutol-trvl-19-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-19-svg{width:100%;height:100%;max-width:320px;}
    .sutol-trvl-19-drop{animation:sutol-trvl-19-fall 2.8s ease-in infinite;}
    .sutol-trvl-19-ripple{animation:sutol-trvl-19-expand 2.8s ease-out infinite;transform-origin:100px 95px;}
    @keyframes sutol-trvl-19-fall{0%{opacity:1;transform:translateY(0);}55%{opacity:1;transform:translateY(60px);}60%,100%{opacity:0;}}
    @keyframes sutol-trvl-19-expand{0%,55%{opacity:0;transform:scale(0.3);}70%{opacity:0.8;}100%{opacity:0;transform:scale(2.6);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-19-drop,.sutol-trvl-19-ripple{animation-duration:11.2s;}
    }
  </style>
</div>
```

---

## Bileşen 20: Backpacking — Uçan Uçak ve Rota Noktaları

**Etiketler:** backpacking, kruvaziyer seyahati
**Kategori:** Turizm / Seyahat
**Açıklama:** Bir uçak simgesinin kesikli bir rota üzerinde uçarak farklı durak noktalarını gezdiği seyahat animasyonu.

```html
<div class="sutol-trvl-20-wrap">
  <svg class="sutol-trvl-20-svg" viewBox="0 0 260 140" xmlns="http://www.w3.org/2000/svg">
    <path d="M 20 100 Q 130 20 240 100" fill="none" stroke="#b0bec5" stroke-width="2" stroke-dasharray="5 8"/>
    <circle cx="20" cy="100" r="5" fill="#ef5350"/>
    <circle cx="240" cy="100" r="5" fill="#42a5f5"/>
    <g class="sutol-trvl-20-plane">
      <polygon points="0,-6 14,0 0,6 4,0" fill="#546e7a"/>
      <animateMotion dur="4s" repeatCount="indefinite" rotate="auto" path="M 20 100 Q 130 20 240 100"/>
    </g>
  </svg>
  <style>
    .sutol-trvl-20-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-trvl-20-svg{width:100%;height:100%;max-width:420px;}
    @media (prefers-reduced-motion: reduce){
      .sutol-trvl-20-plane animateMotion{dur:16s;}
    }
  </style>
</div>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Eko-Otel): CSS opacity/filter ile panel parıltısı, translateY ile enerji parçacıkları — hafif.
- Bileşen 2 (Fidan/Karbon Döngüsü): CSS rotate ile yaprak salınımı ve dönen döngü halkası — hafif.
- Bileşen 3 (Anahtar): CSS rotate ile sallanan anahtar — hafif.
- Bileşen 4 (Balkon): CSS skewX ile perde dalgalanması, opacity ile güneş parıltısı — hafif.
- Bileşen 5 (Antik Sütunlar): CSS translateX ile kayan ışık huzmesi — hafif.
- Bileşen 6 (Pusula): CSS rotate ile çok noktalı ibre salınımı — hafif.
- Bileşen 7 (Termal Buhar): CSS opacity/translateY/scale ile yükselen buhar katmanları — hafif.
- Bileşen 8 (Nefes/Denge): CSS scale ile nefes ritmi animasyonu — hafif.
- Bileşen 9 (Gemi): CSS translateY/translateX ile dalga üstü sallanma — hafif.
- Bileşen 10 (Liman Feneri): CSS opacity ve rotate ile ışık dönüşü — hafif.
- Bileşen 11 (Dağ Patikası): CSS stroke-dashoffset ile akan patika çizgisi — hafif.
- Bileşen 12 (Sırt Çantası): CSS rotate ile sallanan çanta — hafif.
- Bileşen 13 (Sokak Lezzeti): CSS opacity/translateY/scale ile buhar yükselişi — hafif.
- Bileşen 14 (Şarap Tadımı): CSS rotate/scaleY ile kadeh içi dalgalanma — hafif.
- Bileşen 15 (Pazar Sepeti): CSS translateY ile zıplayan ürünler — hafif.
- Bileşen 16 (Karavan): CSS stroke-dashoffset ile yol çizgisi akışı, translateY ile karavan sarsıntısı — hafif.
- Bileşen 17 (Kamp Ateşi): CSS opacity ile yıldız titreşimi, scaleY/skewX ile alev — hafif.
- Bileşen 18 (Müze Vitrini): CSS opacity ile spot ışığı nabzı — hafif.
- Bileşen 19 (Damla/İyileşme): CSS translateY/opacity ile damla düşüşü ve genişleyen halka — hafif.
- Bileşen 20 (Uçak Rotası): SVG `animateMotion` ile eğri rota üzerinde uçuş — orta yoğunlukta.

Tüm bileşenler `transform`/`opacity` tabanlı GPU-dostu animasyonlar kullanır, global CSS seçicisi içermez, `prefers-reduced-motion` desteği barındırır ve sabit metin içermez (yalnızca sembolik/görsel öğeler kullanılmıştır).
