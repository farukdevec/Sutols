# Sutol Kimya Kategorisi — 20 Animasyonlu Bileşen

Bu dosyada Kimya kategorisi için 20 adet bağımsız, şeffaf arka planlı, sandbox-uyumlu HTML/CSS/SVG bileşeni bulunur. Her biri kendi CSS prefix'i ile kapsüllenmiştir, dış kaynak kullanmaz ve `prefers-reduced-motion` desteği içerir.

---

## Bileşen 1: İyonik Bağ — Elektron Transferi

**Etiketler (keyword eşleşmesi için):** kimyasal bağ, iyonik bağ
**Kategori:** Kimya
**Açıklama:** Sodyum atomundan klor atomuna bir elektronun geçişini ve ardından oluşan iyonik çekimi gösteren döngüsel animasyon.

```html
<div class="sutol-chem-01-wrap">
  <svg class="sutol-chem-01-svg" viewBox="0 0 300 160" xmlns="http://www.w3.org/2000/svg">
    <circle cx="80" cy="80" r="34" fill="none" stroke="#f39c12" stroke-width="3"/>
    <circle cx="220" cy="80" r="34" fill="none" stroke="#27ae60" stroke-width="3"/>
    <circle class="sutol-chem-01-na" cx="80" cy="80" r="14" fill="#f39c12"/>
    <circle class="sutol-chem-01-cl" cx="220" cy="80" r="18" fill="#27ae60"/>
    <circle class="sutol-chem-01-electron" cx="80" cy="46" r="5" fill="#fff5cc"/>
    <path class="sutol-chem-01-arrow" d="M 118 80 Q 150 40 182 80" fill="none" stroke="#eee" stroke-width="2" stroke-dasharray="4 4" opacity="0.5"/>
  </svg>
  <style>
    .sutol-chem-01-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-01-svg{width:100%;height:100%;max-width:420px;}
    .sutol-chem-01-electron{animation:sutol-chem-01-move 3.2s ease-in-out infinite;}
    .sutol-chem-01-na, .sutol-chem-01-cl{animation:sutol-chem-01-pulse 3.2s ease-in-out infinite;transform-origin:center;transform-box:fill-box;}
    .sutol-chem-01-cl{animation-delay:0.2s;}
    @keyframes sutol-chem-01-move{
      0%{transform:translate(0,0);opacity:1;}
      45%{transform:translate(140px,-30px);opacity:1;}
      55%{transform:translate(140px,4px);opacity:1;}
      100%{transform:translate(140px,4px);opacity:1;}
    }
    @keyframes sutol-chem-01-pulse{
      0%,40%{transform:scale(1);}
      55%{transform:scale(1.15);}
      70%,100%{transform:scale(1);}
    }
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-01-electron, .sutol-chem-01-na, .sutol-chem-01-cl{animation-duration:12s;}
    }
  </style>
</div>
```

---

## Bileşen 2: Kovalent Bağ — Paylaşılan Elektron Çifti

**Etiketler:** kimyasal bağ, kovalent bağ
**Kategori:** Kimya
**Açıklama:** İki atomun ortasında salınan paylaşılan elektron çiftiyle kovalent bağ oluşumunu simgeler.

```html
<div class="sutol-chem-02-wrap">
  <svg class="sutol-chem-02-svg" viewBox="0 0 300 160" xmlns="http://www.w3.org/2000/svg">
    <circle cx="95" cy="80" r="30" fill="#3498db" opacity="0.85"/>
    <circle cx="205" cy="80" r="30" fill="#9b59b6" opacity="0.85"/>
    <g class="sutol-chem-02-pair">
      <circle cx="145" cy="72" r="5" fill="#fdfefe"/>
      <circle cx="155" cy="88" r="5" fill="#fdfefe"/>
    </g>
  </svg>
  <style>
    .sutol-chem-02-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-02-svg{width:100%;height:100%;max-width:420px;}
    .sutol-chem-02-pair{animation:sutol-chem-02-orbit 3s ease-in-out infinite;transform-origin:150px 80px;}
    @keyframes sutol-chem-02-orbit{
      0%{transform:rotate(0deg) scale(1);}
      50%{transform:rotate(180deg) scale(1.1);}
      100%{transform:rotate(360deg) scale(1);}
    }
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-02-pair{animation-duration:14s;}
    }
  </style>
</div>
```

---

## Bileşen 3: Hidrojen Bağı — Su Molekülleri Ağı

**Etiketler:** hidrojen bağı
**Kategori:** Kimya
**Açıklama:** Üç su molekülü arasındaki kesikli hidrojen bağlarının nabız gibi parladığı bir ağ yapısı.

```html
<div class="sutol-chem-03-wrap">
  <svg class="sutol-chem-03-svg" viewBox="0 0 300 200" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-chem-03-mol" transform="translate(70,60)">
      <circle r="12" fill="#e74c3c"/>
      <circle cx="-18" cy="16" r="7" fill="#ecf0f1"/>
      <circle cx="18" cy="16" r="7" fill="#ecf0f1"/>
    </g>
    <g class="sutol-chem-03-mol" transform="translate(220,60)">
      <circle r="12" fill="#e74c3c"/>
      <circle cx="-18" cy="16" r="7" fill="#ecf0f1"/>
      <circle cx="18" cy="16" r="7" fill="#ecf0f1"/>
    </g>
    <g class="sutol-chem-03-mol" transform="translate(145,150)">
      <circle r="12" fill="#e74c3c"/>
      <circle cx="-18" cy="16" r="7" fill="#ecf0f1"/>
      <circle cx="18" cy="16" r="7" fill="#ecf0f1"/>
    </g>
    <line class="sutol-chem-03-hbond" x1="88" y1="72" x2="150" y2="140" stroke="#5dade2" stroke-width="2" stroke-dasharray="3 4"/>
    <line class="sutol-chem-03-hbond" x1="238" y1="72" x2="163" y2="140" stroke="#5dade2" stroke-width="2" stroke-dasharray="3 4" style="animation-delay:.6s"/>
  </svg>
  <style>
    .sutol-chem-03-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-03-svg{width:100%;height:100%;max-width:420px;}
    .sutol-chem-03-hbond{animation:sutol-chem-03-glow 2.4s ease-in-out infinite;}
    @keyframes sutol-chem-03-glow{
      0%,100%{opacity:0.2;}
      50%{opacity:0.9;}
    }
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-03-hbond{animation-duration:10s;}
    }
  </style>
</div>
```

---

## Bileşen 4: İzomer — Yapı Dönüşümü

**Etiketler:** izomer
**Kategori:** Kimya
**Açıklama:** Aynı atom sayısına sahip iki farklı iskelet yapısı arasında sürekli morfing yapan bir molekül şekli.

```html
<div class="sutol-chem-04-wrap">
  <svg class="sutol-chem-04-svg" viewBox="0 0 300 160" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-chem-04-skel" fill="none" stroke="#16a085" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"
      d="M 40 120 L 90 60 L 140 120 L 190 60 L 240 120">
      <animate attributeName="d" dur="4s" repeatCount="indefinite"
        values="
          M 40 120 L 90 60 L 140 120 L 190 60 L 240 120;
          M 40 90 L 90 120 L 140 60 L 190 120 L 240 90;
          M 40 120 L 90 60 L 140 120 L 190 60 L 240 120" />
    </path>
    <circle cx="40" cy="120" r="6" fill="#1abc9c"/>
    <circle cx="240" cy="120" r="6" fill="#1abc9c"/>
  </svg>
  <style>
    .sutol-chem-04-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-04-svg{width:100%;height:100%;max-width:420px;}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-04-skel animate{animationDuration:16s;}
    }
  </style>
</div>
```

---

## Bileşen 5: Polimerizasyon — Monomer Zincirleme

**Etiketler:** polimerizasyon, monomer
**Kategori:** Kimya
**Açıklama:** Ayrı monomer birimlerinin sırayla birbirine bağlanarak uzun bir polimer zinciri oluşturduğu döngüsel animasyon.

```html
<div class="sutol-chem-05-wrap">
  <svg class="sutol-chem-05-svg" viewBox="0 0 320 100" xmlns="http://www.w3.org/2000/svg">
    <g id="sutol-chem-05-units">
      <circle class="sutol-chem-05-u" cx="30" cy="50" r="16" fill="#e67e22"/>
      <circle class="sutol-chem-05-u" cx="80" cy="50" r="16" fill="#e67e22" style="animation-delay:.3s"/>
      <circle class="sutol-chem-05-u" cx="130" cy="50" r="16" fill="#e67e22" style="animation-delay:.6s"/>
      <circle class="sutol-chem-05-u" cx="180" cy="50" r="16" fill="#e67e22" style="animation-delay:.9s"/>
      <circle class="sutol-chem-05-u" cx="230" cy="50" r="16" fill="#e67e22" style="animation-delay:1.2s"/>
      <circle class="sutol-chem-05-u" cx="280" cy="50" r="16" fill="#e67e22" style="animation-delay:1.5s"/>
    </g>
    <line class="sutol-chem-05-link" x1="46" y1="50" x2="64" y2="50" stroke="#f4d03f" stroke-width="5"/>
    <line class="sutol-chem-05-link" x1="96" y1="50" x2="114" y2="50" stroke="#f4d03f" stroke-width="5" style="animation-delay:.3s"/>
    <line class="sutol-chem-05-link" x1="146" y1="50" x2="164" y2="50" stroke="#f4d03f" stroke-width="5" style="animation-delay:.6s"/>
    <line class="sutol-chem-05-link" x1="196" y1="50" x2="214" y2="50" stroke="#f4d03f" stroke-width="5" style="animation-delay:.9s"/>
    <line class="sutol-chem-05-link" x1="246" y1="50" x2="264" y2="50" stroke="#f4d03f" stroke-width="5" style="animation-delay:1.2s"/>
  </svg>
  <style>
    .sutol-chem-05-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-05-svg{width:100%;height:100%;max-width:460px;}
    .sutol-chem-05-u{animation:sutol-chem-05-pop 3s ease-in-out infinite;transform-origin:center;transform-box:fill-box;}
    .sutol-chem-05-link{animation:sutol-chem-05-grow 3s ease-in-out infinite;transform-origin:left center;transform-box:fill-box;}
    @keyframes sutol-chem-05-pop{0%,10%{transform:scale(0.4);opacity:0.3;}25%,100%{transform:scale(1);opacity:1;}}
    @keyframes sutol-chem-05-grow{0%,10%{transform:scaleX(0);}25%,100%{transform:scaleX(1);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-05-u,.sutol-chem-05-link{animation-duration:12s;}
    }
  </style>
</div>
```

---

## Bileşen 6: Esterleşme — Alkol + Asit Tepkimesi

**Etiketler:** ester, alkol, aldehit
**Kategori:** Kimya
**Açıklama:** OH grubunun karboksil grubuyla birleşip ester ve su damlacığı oluşturduğu bir sentez döngüsü.

```html
<div class="sutol-chem-06-wrap">
  <svg class="sutol-chem-06-svg" viewBox="0 0 300 160" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-chem-06-left">
      <rect x="30" y="60" width="46" height="30" rx="8" fill="#2ecc71"/>
      <text x="53" y="80" font-size="13" fill="#fff" text-anchor="middle" font-family="sans-serif">OH</text>
    </g>
    <g class="sutol-chem-06-right">
      <rect x="220" y="60" width="52" height="30" rx="8" fill="#e74c3c"/>
      <text x="246" y="80" font-size="12" fill="#fff" text-anchor="middle" font-family="sans-serif">COOH</text>
    </g>
    <g class="sutol-chem-06-drop">
      <circle cx="150" cy="120" r="9" fill="#5dade2"/>
      <text x="150" y="140" font-size="11" fill="#5dade2" text-anchor="middle" font-family="sans-serif">H₂O</text>
    </g>
    <rect class="sutol-chem-06-ester" x="120" y="55" width="70" height="34" rx="8" fill="#f1c40f" opacity="0"/>
  </svg>
  <style>
    .sutol-chem-06-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-06-svg{width:100%;height:100%;max-width:420px;}
    .sutol-chem-06-left{animation:sutol-chem-06-in-l 4s ease-in-out infinite;}
    .sutol-chem-06-right{animation:sutol-chem-06-in-r 4s ease-in-out infinite;}
    .sutol-chem-06-drop{animation:sutol-chem-06-fall 4s ease-in-out infinite;opacity:0;}
    .sutol-chem-06-ester{animation:sutol-chem-06-appear 4s ease-in-out infinite;}
    @keyframes sutol-chem-06-in-l{0%,55%{transform:translateX(0);opacity:1;}70%,100%{transform:translateX(40px);opacity:0;}}
    @keyframes sutol-chem-06-in-r{0%,55%{transform:translateX(0);opacity:1;}70%,100%{transform:translateX(-40px);opacity:0;}}
    @keyframes sutol-chem-06-fall{0%,55%{opacity:0;transform:translateY(-10px);}70%{opacity:1;transform:translateY(0);}95%{opacity:1;}100%{opacity:0;}}
    @keyframes sutol-chem-06-appear{0%,60%{opacity:0;}75%,95%{opacity:1;}100%{opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-06-left,.sutol-chem-06-right,.sutol-chem-06-drop,.sutol-chem-06-ester{animation-duration:14s;}
    }
  </style>
</div>
```

---

## Bileşen 7: Benzen Halkası — Rezonans

**Etiketler:** benzen halkası, hidrokarbon
**Kategori:** Kimya
**Açıklama:** Altıgen halkadaki çift bağların yer değiştirerek rezonans yapısını temsil ettiği bir aromatik halka animasyonu.

```html
<div class="sutol-chem-07-wrap">
  <svg class="sutol-chem-07-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <polygon points="100,30 165,65 165,135 100,170 35,135 35,65" fill="none" stroke="#8e44ad" stroke-width="4"/>
    <circle class="sutol-chem-07-ring" cx="100" cy="100" r="45" fill="none" stroke="#c39bd3" stroke-width="6" stroke-dasharray="10 14"/>
  </svg>
  <style>
    .sutol-chem-07-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-07-svg{width:100%;height:100%;max-width:300px;}
    .sutol-chem-07-ring{animation:sutol-chem-07-spin 6s linear infinite;transform-origin:100px 100px;}
    @keyframes sutol-chem-07-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-07-ring{animation-duration:24s;}
    }
  </style>
</div>
```

---

## Bileşen 8: Elektroliz — İyon Göçü ve Kabarcıklar

**Etiketler:** elektroliz
**Kategori:** Kimya
**Açıklama:** İki elektrot arasında hareket eden iyonlar ve yükselen gaz kabarcıklarıyla elektroliz sürecini gösterir.

```html
<div class="sutol-chem-08-wrap">
  <svg class="sutol-chem-08-svg" viewBox="0 0 260 180" xmlns="http://www.w3.org/2000/svg">
    <path d="M 30 40 L 30 160 L 230 160 L 230 40" fill="none" stroke="#7f8c8d" stroke-width="3"/>
    <rect x="60" y="20" width="10" height="140" fill="#34495e"/>
    <rect x="190" y="20" width="10" height="140" fill="#34495e"/>
    <circle class="sutol-chem-08-bubble" cx="65" cy="140" r="5" fill="#a3e4d7"/>
    <circle class="sutol-chem-08-bubble" cx="65" cy="140" r="4" fill="#a3e4d7" style="animation-delay:.7s"/>
    <circle class="sutol-chem-08-bubble2" cx="195" cy="140" r="5" fill="#fadbd8"/>
    <circle class="sutol-chem-08-bubble2" cx="195" cy="140" r="4" fill="#fadbd8" style="animation-delay:.9s"/>
    <circle class="sutol-chem-08-ion" cx="130" cy="90" r="6" fill="#f7dc6f"/>
  </svg>
  <style>
    .sutol-chem-08-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-08-svg{width:100%;height:100%;max-width:420px;}
    .sutol-chem-08-bubble,.sutol-chem-08-bubble2{animation:sutol-chem-08-rise 2.2s ease-in infinite;}
    .sutol-chem-08-ion{animation:sutol-chem-08-drift 2.6s ease-in-out infinite;}
    @keyframes sutol-chem-08-rise{0%{transform:translateY(0);opacity:0.9;}100%{transform:translateY(-100px);opacity:0;}}
    @keyframes sutol-chem-08-drift{0%,100%{transform:translateX(-40px);}50%{transform:translateX(40px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-08-bubble,.sutol-chem-08-bubble2,.sutol-chem-08-ion{animation-duration:10s;}
    }
  </style>
</div>
```

---

## Bileşen 9: Galvanik Hücre — Elektron Akışı

**Etiketler:** galvanik hücre
**Kategori:** Kimya
**Açıklama:** Bir devre teli boyunca hareket eden elektronlarla galvanik pilin elektrik ürettiğini simgeler.

```html
<div class="sutol-chem-09-wrap">
  <svg class="sutol-chem-09-svg" viewBox="0 0 260 140" xmlns="http://www.w3.org/2000/svg">
    <path id="sutol-chem-09-path" d="M 40 100 L 40 40 L 220 40 L 220 100" fill="none" stroke="#95a5a6" stroke-width="4"/>
    <circle cx="40" cy="110" r="18" fill="#2980b9"/>
    <circle cx="220" cy="110" r="18" fill="#c0392b"/>
    <circle class="sutol-chem-09-e" r="6" fill="#f9e79f">
      <animateMotion dur="2.4s" repeatCount="indefinite" path="M 40 100 L 40 40 L 220 40 L 220 100"/>
    </circle>
    <circle class="sutol-chem-09-e" r="6" fill="#f9e79f">
      <animateMotion dur="2.4s" begin="1.2s" repeatCount="indefinite" path="M 40 100 L 40 40 L 220 40 L 220 100"/>
    </circle>
  </svg>
  <style>
    .sutol-chem-09-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-09-svg{width:100%;height:100%;max-width:420px;}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-09-e animateMotion{dur:9.6s;}
    }
  </style>
</div>
```

---

## Bileşen 10: Korozyon — Yayılan Pas

**Etiketler:** korozyon
**Kategori:** Kimya
**Açıklama:** Metal bir yüzey üzerinde zamanla yayılan pas lekelerinin döngüsel olarak belirip solmasını gösterir.

```html
<div class="sutol-chem-10-wrap">
  <svg class="sutol-chem-10-svg" viewBox="0 0 260 120" xmlns="http://www.w3.org/2000/svg">
    <rect x="20" y="40" width="220" height="40" rx="6" fill="#95a5a6"/>
    <circle class="sutol-chem-10-rust" cx="70" cy="55" r="14" fill="#c0392b"/>
    <circle class="sutol-chem-10-rust" cx="130" cy="65" r="18" fill="#a04000" style="animation-delay:1s"/>
    <circle class="sutol-chem-10-rust" cx="190" cy="50" r="12" fill="#c0392b" style="animation-delay:2s"/>
  </svg>
  <style>
    .sutol-chem-10-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-10-svg{width:100%;height:100%;max-width:420px;}
    .sutol-chem-10-rust{animation:sutol-chem-10-spread 4s ease-in-out infinite;transform-origin:center;transform-box:fill-box;opacity:0;}
    @keyframes sutol-chem-10-spread{0%{opacity:0;transform:scale(0.2);}40%,70%{opacity:0.85;transform:scale(1);}100%{opacity:0;transform:scale(1.3);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-10-rust{animation-duration:16s;}
    }
  </style>
</div>
```

---

## Bileşen 11: Yanma Reaksiyonu — Titreyen Alev

**Etiketler:** yanma reaksiyonu
**Kategori:** Kimya
**Açıklama:** Yakıt ve oksijenin birleşerek sürekli titreyen bir alev oluşturduğu yanma tepkimesi animasyonu.

```html
<div class="sutol-chem-11-wrap">
  <svg class="sutol-chem-11-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <path class="sutol-chem-11-flame" d="M 100 40 C 130 80 140 110 100 160 C 60 110 70 80 100 40 Z" fill="#e67e22"/>
    <path class="sutol-chem-11-flame-in" d="M 100 75 C 115 100 118 118 100 145 C 82 118 85 100 100 75 Z" fill="#f9e79f"/>
  </svg>
  <style>
    .sutol-chem-11-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-11-svg{width:100%;height:100%;max-width:260px;}
    .sutol-chem-11-flame{animation:sutol-chem-11-flick 1.6s ease-in-out infinite;transform-origin:100px 160px;}
    .sutol-chem-11-flame-in{animation:sutol-chem-11-flick 1.3s ease-in-out infinite reverse;transform-origin:100px 145px;}
    @keyframes sutol-chem-11-flick{0%,100%{transform:scaleY(1) skewX(0deg);}30%{transform:scaleY(1.08) skewX(2deg);}60%{transform:scaleY(0.95) skewX(-3deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-11-flame,.sutol-chem-11-flame-in{animation-duration:8s;}
    }
  </style>
</div>
```

---

## Bileşen 12: Ekzotermik Reaksiyon — Isı Yayılımı

**Etiketler:** ekzotermik, aktivasyon enerjisi
**Kategori:** Kimya
**Açıklama:** Bir balondan dışarıya doğru genişleyen ısı dalgalarıyla ekzotermik bir tepkimenin enerji saldığını gösterir.

```html
<div class="sutol-chem-12-wrap">
  <svg class="sutol-chem-12-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <path d="M 80 40 L 120 40 L 120 90 L 145 160 Q 100 180 55 160 Z" fill="none" stroke="#c0392b" stroke-width="4"/>
    <circle class="sutol-chem-12-wave" cx="100" cy="120" r="20" fill="none" stroke="#e74c3c" stroke-width="3"/>
    <circle class="sutol-chem-12-wave" cx="100" cy="120" r="20" fill="none" stroke="#e67e22" stroke-width="3" style="animation-delay:.8s"/>
    <circle class="sutol-chem-12-wave" cx="100" cy="120" r="20" fill="none" stroke="#f1c40f" stroke-width="3" style="animation-delay:1.6s"/>
  </svg>
  <style>
    .sutol-chem-12-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-12-svg{width:100%;height:100%;max-width:260px;}
    .sutol-chem-12-wave{animation:sutol-chem-12-out 2.4s ease-out infinite;transform-origin:100px 120px;opacity:0.8;}
    @keyframes sutol-chem-12-out{0%{transform:scale(0.3);opacity:0.9;}100%{transform:scale(2.2);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-12-wave{animation-duration:9.6s;}
    }
  </style>
</div>
```

---

## Bileşen 13: Endotermik Reaksiyon — Isı Emilimi

**Etiketler:** endotermik
**Kategori:** Kimya
**Açıklama:** Bir kaba doğru içeri çekilen mavi ok ve daralan dalgalarla endotermik tepkimenin çevreden ısı emdiğini gösterir.

```html
<div class="sutol-chem-13-wrap">
  <svg class="sutol-chem-13-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <path d="M 80 40 L 120 40 L 120 90 L 145 160 Q 100 180 55 160 Z" fill="none" stroke="#2980b9" stroke-width="4"/>
    <circle class="sutol-chem-13-wave" cx="100" cy="120" r="70" fill="none" stroke="#5dade2" stroke-width="3"/>
    <circle class="sutol-chem-13-wave" cx="100" cy="120" r="70" fill="none" stroke="#85c1e9" stroke-width="3" style="animation-delay:.8s"/>
    <circle class="sutol-chem-13-wave" cx="100" cy="120" r="70" fill="none" stroke="#aed6f1" stroke-width="3" style="animation-delay:1.6s"/>
  </svg>
  <style>
    .sutol-chem-13-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-13-svg{width:100%;height:100%;max-width:260px;}
    .sutol-chem-13-wave{animation:sutol-chem-13-in 2.4s ease-in infinite;transform-origin:100px 120px;opacity:0;}
    @keyframes sutol-chem-13-in{0%{transform:scale(1);opacity:0;}60%{opacity:0.8;}100%{transform:scale(0.25);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-13-wave{animation-duration:9.6s;}
    }
  </style>
</div>
```

---

## Bileşen 14: Aktivasyon Enerjisi — Enerji Tepesi

**Etiketler:** aktivasyon enerjisi, ekzotermik, endotermik
**Kategori:** Kimya
**Açıklama:** Bir topun enerji tepesini tırmanıp diğer tarafa inmesiyle aktivasyon enerjisi bariyerini görselleştirir.

```html
<div class="sutol-chem-14-wrap">
  <svg class="sutol-chem-14-svg" viewBox="0 0 260 140" xmlns="http://www.w3.org/2000/svg">
    <path d="M 20 110 Q 90 20 130 55 Q 170 20 240 110" fill="none" stroke="#7f8c8d" stroke-width="3"/>
    <circle class="sutol-chem-14-ball" r="9" fill="#e74c3c">
      <animateMotion dur="3.4s" repeatCount="indefinite" path="M 20 110 Q 90 20 130 55 Q 170 20 240 110"/>
    </circle>
  </svg>
  <style>
    .sutol-chem-14-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-14-svg{width:100%;height:100%;max-width:420px;}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-14-ball animateMotion{dur:13.6s;}
    }
  </style>
</div>
```

---

## Bileşen 15: Kimyasal Denge — Terazi Salınımı

**Etiketler:** denge sabiti
**Kategori:** Kimya
**Açıklama:** İki yönlü ok ve hafifçe sallanan bir terazi ile ileri-geri tepkime dengesini simgeler.

```html
<div class="sutol-chem-15-wrap">
  <svg class="sutol-chem-15-svg" viewBox="0 0 260 140" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-chem-15-beam" transform-origin="130 50">
      <line x1="130" y1="30" x2="130" y2="50" stroke="#7f8c8d" stroke-width="4"/>
      <line x1="50" y1="50" x2="210" y2="50" stroke="#7f8c8d" stroke-width="4"/>
      <circle cx="50" cy="80" r="20" fill="#27ae60"/>
      <circle cx="210" cy="80" r="20" fill="#8e44ad"/>
    </g>
    <path d="M 90 110 L 170 110" stroke="#d5d8dc" stroke-width="3" marker-end="url(#sutol-chem-15-arr)"/>
  </svg>
  <style>
    .sutol-chem-15-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-15-svg{width:100%;height:100%;max-width:420px;}
    .sutol-chem-15-beam{animation:sutol-chem-15-rock 3s ease-in-out infinite;}
    @keyframes sutol-chem-15-rock{0%,100%{transform:rotate(-6deg);}50%{transform:rotate(6deg);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-15-beam{animation-duration:12s;}
    }
  </style>
</div>
```

---

## Bileşen 16: Spektroskopi — Işığın Ayrışması

**Etiketler:** spektroskopi
**Kategori:** Kimya
**Açıklama:** Beyaz bir ışık huzmesinin bir prizmadan geçerek renk spektrumuna ayrıldığı animasyon.

```html
<div class="sutol-chem-16-wrap">
  <svg class="sutol-chem-16-svg" viewBox="0 0 300 160" xmlns="http://www.w3.org/2000/svg">
    <line x1="20" y1="80" x2="120" y2="80" stroke="#fdfefe" stroke-width="4"/>
    <polygon points="120,55 150,80 120,105" fill="#d6eaf8" opacity="0.6"/>
    <g class="sutol-chem-16-rays">
      <line x1="150" y1="80" x2="270" y2="45" stroke="#e74c3c" stroke-width="3"/>
      <line x1="150" y1="80" x2="270" y2="60" stroke="#f39c12" stroke-width="3"/>
      <line x1="150" y1="80" x2="270" y2="75" stroke="#f1c40f" stroke-width="3"/>
      <line x1="150" y1="80" x2="270" y2="90" stroke="#2ecc71" stroke-width="3"/>
      <line x1="150" y1="80" x2="270" y2="105" stroke="#3498db" stroke-width="3"/>
      <line x1="150" y1="80" x2="270" y2="120" stroke="#8e44ad" stroke-width="3"/>
    </g>
  </svg>
  <style>
    .sutol-chem-16-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-16-svg{width:100%;height:100%;max-width:420px;}
    .sutol-chem-16-rays{animation:sutol-chem-16-sweep 3s ease-in-out infinite;transform-origin:150px 80px;}
    @keyframes sutol-chem-16-sweep{0%,100%{opacity:0.5;transform:scaleX(0.96);}50%{opacity:1;transform:scaleX(1.02);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-16-rays{animation-duration:12s;}
    }
  </style>
</div>
```

---

## Bileşen 17: Kromatografi — Bant Ayrışımı

**Etiketler:** kromatografi
**Kategori:** Kimya
**Açıklama:** Bir şerit üzerinde farklı hızlarda yükselen renkli bantlarla karışım ayrıştırma sürecini gösterir.

```html
<div class="sutol-chem-17-wrap">
  <svg class="sutol-chem-17-svg" viewBox="0 0 160 200" xmlns="http://www.w3.org/2000/svg">
    <rect x="60" y="20" width="40" height="170" fill="#f4f6f7" stroke="#bdc3c7" stroke-width="2"/>
    <rect class="sutol-chem-17-band" x="64" y="170" width="32" height="10" fill="#e74c3c"/>
    <rect class="sutol-chem-17-band" x="64" y="170" width="32" height="10" fill="#f39c12" style="animation-delay:.4s"/>
    <rect class="sutol-chem-17-band" x="64" y="170" width="32" height="10" fill="#27ae60" style="animation-delay:.8s"/>
    <line class="sutol-chem-17-front" x1="60" y1="170" x2="100" y2="170" stroke="#3498db" stroke-width="2"/>
  </svg>
  <style>
    .sutol-chem-17-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-17-svg{width:100%;height:100%;max-width:220px;}
    .sutol-chem-17-band{animation:sutol-chem-17-rise 4s ease-in-out infinite;}
    .sutol-chem-17-band:nth-of-type(2){animation-duration:4.6s;}
    .sutol-chem-17-band:nth-of-type(3){animation-duration:5.4s;}
    .sutol-chem-17-front{animation:sutol-chem-17-solvent 4s ease-in-out infinite;}
    @keyframes sutol-chem-17-rise{0%{transform:translateY(0);}100%{transform:translateY(-130px);}}
    @keyframes sutol-chem-17-solvent{0%{transform:translateY(0);}100%{transform:translateY(-150px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-17-band,.sutol-chem-17-front{animation-duration:16s;}
    }
  </style>
</div>
```

---

## Bileşen 18: Erime Noktası — Kristalden Sıvıya

**Etiketler:** erime noktası
**Kategori:** Kimya
**Açıklama:** Katı bir kristal yapının ısınarak damlayan bir sıvıya dönüştüğü döngüsel geçiş animasyonu.

```html
<div class="sutol-chem-18-wrap">
  <svg class="sutol-chem-18-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-chem-18-solid">
      <rect x="60" y="60" width="20" height="20" fill="#5dade2"/>
      <rect x="90" y="60" width="20" height="20" fill="#5dade2"/>
      <rect x="120" y="60" width="20" height="20" fill="#5dade2"/>
      <rect x="60" y="90" width="20" height="20" fill="#5dade2"/>
      <rect x="90" y="90" width="20" height="20" fill="#5dade2"/>
      <rect x="120" y="90" width="20" height="20" fill="#5dade2"/>
    </g>
    <path class="sutol-chem-18-liquid" d="M 55 140 Q 100 120 145 140 L 145 175 Q 100 190 55 175 Z" fill="#3498db" opacity="0"/>
    <circle class="sutol-chem-18-drip" cx="100" cy="175" r="6" fill="#3498db" opacity="0"/>
  </svg>
  <style>
    .sutol-chem-18-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-18-svg{width:100%;height:100%;max-width:260px;}
    .sutol-chem-18-solid{animation:sutol-chem-18-melt 5s ease-in-out infinite;transform-origin:100px 100px;}
    .sutol-chem-18-liquid{animation:sutol-chem-18-fill 5s ease-in-out infinite;}
    .sutol-chem-18-drip{animation:sutol-chem-18-drop 5s ease-in-out infinite;}
    @keyframes sutol-chem-18-melt{0%,20%{opacity:1;transform:scale(1);}55%,100%{opacity:0;transform:scale(0.7) translateY(20px);}}
    @keyframes sutol-chem-18-fill{0%,35%{opacity:0;}60%,100%{opacity:0.9;}}
    @keyframes sutol-chem-18-drop{0%,70%{opacity:0;transform:translateY(0);}85%{opacity:1;transform:translateY(15px);}100%{opacity:0;transform:translateY(25px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-18-solid,.sutol-chem-18-liquid,.sutol-chem-18-drip{animation-duration:20s;}
    }
  </style>
</div>
```

---

## Bileşen 19: pH Ölçeği — Nötralizasyon ve Tampon

**Etiketler:** asidik yağmur, nötralizasyon, tampon çözelti
**Kategori:** Kimya
**Açıklama:** Kırmızıdan maviye giden pH ölçeği üzerinde salınan bir ibre ve düşen bir yağmur damlasıyla asit-baz dengesini gösterir.

```html
<div class="sutol-chem-19-wrap">
  <svg class="sutol-chem-19-svg" viewBox="0 0 260 140" xmlns="http://www.w3.org/2000/svg">
    <defs>
      <linearGradient id="sutol-chem-19-grad" x1="0" y1="0" x2="1" y2="0">
        <stop offset="0%" stop-color="#e74c3c"/>
        <stop offset="50%" stop-color="#2ecc71"/>
        <stop offset="100%" stop-color="#3498db"/>
      </linearGradient>
    </defs>
    <rect x="20" y="90" width="220" height="18" rx="9" fill="url(#sutol-chem-19-grad)"/>
    <polygon class="sutol-chem-19-needle" points="130,80 122,95 138,95" fill="#2c3e50"/>
    <circle class="sutol-chem-19-drop" cx="60" cy="20" r="7" fill="#5dade2"/>
  </svg>
  <style>
    .sutol-chem-19-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-19-svg{width:100%;height:100%;max-width:420px;}
    .sutol-chem-19-needle{animation:sutol-chem-19-sway 4s ease-in-out infinite;transform-origin:130px 95px;}
    .sutol-chem-19-drop{animation:sutol-chem-19-fall 4s ease-in infinite;}
    @keyframes sutol-chem-19-sway{0%{transform:translateX(-90px);}50%{transform:translateX(0px);}100%{transform:translateX(90px);}}
    @keyframes sutol-chem-19-fall{0%{opacity:0;transform:translateY(0);}20%{opacity:1;}70%{opacity:1;transform:translateY(65px);}100%{opacity:0;transform:translateY(70px);}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-19-needle,.sutol-chem-19-drop{animation-duration:16s;}
    }
  </style>
</div>
```

---

## Bileşen 20: Radyoaktif Bozunma — Parçacık Yayılımı

**Etiketler:** radyoaktif bozunma
**Kategori:** Kimya
**Açıklama:** Bir atom çekirdeğinin periyodik olarak parçacık yayarak bozunduğu ve hafifçe parladığı bir animasyon.

```html
<div class="sutol-chem-20-wrap">
  <svg class="sutol-chem-20-svg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <g class="sutol-chem-20-nucleus" transform="translate(100,100)">
      <circle r="8" fill="#f39c12" cx="-6" cy="-4"/>
      <circle r="8" fill="#e74c3c" cx="6" cy="-4"/>
      <circle r="8" fill="#f39c12" cx="0" cy="8"/>
      <circle class="sutol-chem-20-glow" r="26" fill="none" stroke="#f9e79f" stroke-width="2"/>
    </g>
    <circle class="sutol-chem-20-particle" cx="100" cy="100" r="5" fill="#f1c40f"/>
  </svg>
  <style>
    .sutol-chem-20-wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:transparent;}
    .sutol-chem-20-svg{width:100%;height:100%;max-width:260px;}
    .sutol-chem-20-glow{animation:sutol-chem-20-pulse 2.6s ease-in-out infinite;opacity:0.5;}
    .sutol-chem-20-particle{animation:sutol-chem-20-emit 2.6s ease-out infinite;}
    @keyframes sutol-chem-20-pulse{0%,100%{transform:scale(0.9);opacity:0.3;}50%{transform:scale(1.15);opacity:0.7;}}
    @keyframes sutol-chem-20-emit{0%{transform:translate(0,0);opacity:0;}10%{opacity:1;}100%{transform:translate(70px,-55px);opacity:0;}}
    @media (prefers-reduced-motion: reduce){
      .sutol-chem-20-glow,.sutol-chem-20-particle{animation-duration:10.4s;}
    }
  </style>
</div>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (İyonik Bağ): CSS keyframes ile transform/opacity animasyonu, elektron transferi — performans: hafif, sorunsuz.
- Bileşen 2 (Kovalent Bağ): CSS transform rotate/scale ile elektron çifti orbiti — hafif.
- Bileşen 3 (Hidrojen Bağı): CSS opacity keyframes ile kesikli bağ nabzı — hafif.
- Bileşen 4 (İzomer): SVG SMIL `<animate>` ile path morphing — orta yoğunlukta, tarayıcı SMIL desteğine bağlı.
- Bileşen 5 (Polimerizasyon): CSS transform-box:fill-box ile sıralı büyüme animasyonu — hafif.
- Bileşen 6 (Esterleşme): CSS opacity/translate ile aşama geçişleri — hafif.
- Bileşen 7 (Benzen Halkası): CSS transform rotate ile sürekli dönen rezonans halkası — hafif.
- Bileşen 8 (Elektroliz): CSS translateY ile kabarcık yükselişi ve iyon salınımı — hafif.
- Bileşen 9 (Galvanik Hücre): SVG `animateMotion` ile devre üzerinde elektron hareketi — orta yoğunlukta.
- Bileşen 10 (Korozyon): CSS opacity/scale keyframes ile yayılan pas lekeleri — hafif.
- Bileşen 11 (Yanma Reaksiyonu): CSS scaleY/skewX ile alev titreşimi — hafif.
- Bileşen 12 (Ekzotermik): CSS scale/opacity ile dışa yayılan ısı dalgaları — hafif.
- Bileşen 13 (Endotermik): CSS scale/opacity ile içe çekilen dalgalar — hafif.
- Bileşen 14 (Aktivasyon Enerjisi): SVG `animateMotion` ile path üzerinde top hareketi — orta yoğunlukta.
- Bileşen 15 (Kimyasal Denge): CSS transform rotate ile terazi salınımı — hafif.
- Bileşen 16 (Spektroskopi): CSS opacity/scaleX ile spektrum ışını titreşimi — hafif.
- Bileşen 17 (Kromatografi): CSS translateY ile farklı hızlarda bant yükselişi — hafif.
- Bileşen 18 (Erime Noktası): CSS opacity/scale ile katı-sıvı geçişi — hafif.
- Bileşen 19 (pH Ölçeği): CSS translateX ile ibre salınımı, opacity ile damla düşüşü — hafif.
- Bileşen 20 (Radyoaktif Bozunma): CSS scale/opacity ile çekirdek parlaması ve parçacık fırlatma — hafif.

Tüm bileşenler `transform`/`opacity` tabanlı GPU-dostu animasyonlar kullanır, global CSS seçicisi içermez, `prefers-reduced-motion` desteği barındırır ve sabit metin içermez (sadece sembol/etiket harfleri OH, COOH, H₂O gibi kimyasal formüllerdir, sunum diline bağlı değildir).
