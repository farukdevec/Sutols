# Sutol — Teknoloji / Bilgisayar Bileşenleri (20 adet)

---

## Bileşen 1: Kuantum Küre

**Etiketler (keyword eşleşmesi için):** kuantum bilgisayar, kuantum, qubit, süperpozisyon
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Merkezi bir küre etrafında farklı yörüngelerde dönen parçacıkların süperpozisyon halini temsil ettiği bir kuantum bilgisayar animasyonu.

```html
<div class="sutol-tech-01-quantum" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;max-width:400px;">
    <defs>
      <radialGradient id="qcore" cx="50%" cy="50%" r="50%">
        <stop offset="0%" stop-color="#7dd3fc"/>
        <stop offset="100%" stop-color="#3b82f6"/>
      </radialGradient>
    </defs>
    <circle cx="100" cy="100" r="14" fill="url(#qcore)">
      <animate attributeName="r" values="12;16;12" dur="3s" repeatCount="indefinite"/>
    </circle>
    <g stroke="#93c5fd" fill="none" stroke-width="1" opacity="0.5">
      <ellipse cx="100" cy="100" rx="70" ry="26"/>
      <ellipse cx="100" cy="100" rx="70" ry="26" transform="rotate(60 100 100)"/>
      <ellipse cx="100" cy="100" rx="70" ry="26" transform="rotate(120 100 100)"/>
    </g>
    <g fill="#a78bfa">
      <circle r="5" cx="0" cy="0">
        <animateMotion dur="4s" repeatCount="indefinite" path="M 30,100 A 70,26 0 1,1 170,100 A 70,26 0 1,1 30,100"/>
      </circle>
      <circle r="5" cx="0" cy="0" fill="#f472b6">
        <animateMotion dur="5s" repeatCount="indefinite" path="M 100,74 A 70,26 0 1,1 100,126 A 70,26 0 1,1 100,74" rotate="0" keyPoints="0;1" keyTimes="0;1"/>
        <animateTransform attributeName="transform" type="rotate" from="60 100 100" to="60 100 100" dur="1s"/>
      </circle>
      <circle r="5" cx="0" cy="0" fill="#34d399">
        <animateMotion dur="3.5s" repeatCount="indefinite" path="M 30,100 A 70,26 0 1,1 170,100 A 70,26 0 1,1 30,100" rotate="auto"/>
        <animateTransform attributeName="transform" type="rotate" from="120 100 100" to="120 100 100" dur="1s"/>
      </circle>
    </g>
  </svg>
  <style>
    .sutol-tech-01-quantum svg circle { transform-origin: center; }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-01-quantum animate, .sutol-tech-01-quantum animateMotion { display: none; }
    }
  </style>
</div>
```

---

## Bileşen 2: Kenar Düğümleri

**Etiketler (keyword eşleşmesi için):** edge computing, kenar sunucu, dağıtık işlem, kenar ağı
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Merkezi bir bulut sunucudan çevredeki kenar düğümlerine veri akan nabız animasyonu.

```html
<div class="sutol-tech-02-edge" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;max-width:400px;">
    <g stroke="#5eead4" stroke-width="1.5" fill="none" opacity="0.6">
      <line x1="100" y1="100" x2="40" y2="50"/>
      <line x1="100" y1="100" x2="160" y2="50"/>
      <line x1="100" y1="100" x2="40" y2="150"/>
      <line x1="100" y1="100" x2="160" y2="150"/>
      <line x1="100" y1="100" x2="30" y2="100"/>
      <line x1="100" y1="100" x2="170" y2="100"/>
    </g>
    <circle cx="100" cy="100" r="18" fill="#0d9488"/>
    <g fill="#2dd4bf">
      <circle cx="40" cy="50" r="9"/>
      <circle cx="160" cy="50" r="9"/>
      <circle cx="40" cy="150" r="9"/>
      <circle cx="160" cy="150" r="9"/>
      <circle cx="30" cy="100" r="9"/>
      <circle cx="170" cy="100" r="9"/>
    </g>
    <g fill="#ccfbf1">
      <circle r="3.5"><animateMotion dur="2s" repeatCount="indefinite" path="M100,100 L40,50"/></circle>
      <circle r="3.5"><animateMotion dur="2.4s" repeatCount="indefinite" path="M100,100 L160,50"/></circle>
      <circle r="3.5"><animateMotion dur="1.8s" repeatCount="indefinite" path="M100,100 L40,150"/></circle>
      <circle r="3.5"><animateMotion dur="2.2s" repeatCount="indefinite" path="M100,100 L160,150"/></circle>
      <circle r="3.5"><animateMotion dur="2.6s" repeatCount="indefinite" path="M100,100 L30,100"/></circle>
      <circle r="3.5"><animateMotion dur="2s" repeatCount="indefinite" path="M100,100 L170,100"/></circle>
    </g>
  </svg>
  <style>
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-02-edge animateMotion { display: none; }
    }
  </style>
</div>
```

---

## Bileşen 3: Mikroservis Altıgenleri

**Etiketler (keyword eşleşmesi için):** mikroservis, servis mimarisi, API, modüler yapı
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Birbirine bağlanıp ayrılan altıgen mikroservis bloklarının nabız gibi büyüyüp küçüldüğü bir animasyon.

```html
<div class="sutol-tech-03-micro" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;max-width:400px;">
    <g stroke="#fbbf24" stroke-width="1" opacity="0.5" fill="none">
      <line x1="100" y1="80" x2="70" y2="130"/>
      <line x1="100" y1="80" x2="130" y2="130"/>
      <line x1="70" y1="130" x2="130" y2="130"/>
    </g>
    <g class="sutol-tech-03-hex">
      <polygon points="100,65 113,72.5 113,87.5 100,95 87,87.5 87,72.5" fill="#f59e0b"/>
    </g>
    <g class="sutol-tech-03-hex" style="animation-delay:-0.6s">
      <polygon points="70,115 83,122.5 83,137.5 70,145 57,137.5 57,122.5" fill="#fb923c"/>
    </g>
    <g class="sutol-tech-03-hex" style="animation-delay:-1.2s">
      <polygon points="130,115 143,122.5 143,137.5 130,145 117,137.5 117,122.5" fill="#f97316"/>
    </g>
  </svg>
  <style>
    .sutol-tech-03-hex { transform-origin: center; transform-box: fill-box; animation: sutol-tech-03-pulse 3s ease-in-out infinite; }
    @keyframes sutol-tech-03-pulse {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.18); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-03-hex { animation: none; }
    }
  </style>
</div>
```

---

## Bileşen 4: Konteyner İstifleme

**Etiketler (keyword eşleşmesi için):** container orkestrasyon, konteyner, kubernetes, dağıtım
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Küçük konteyner kutularının bir düzenleyici tarafından sırayla istiflenip yerleştirildiği CSS animasyonu.

```html
<div class="sutol-tech-04-container" style="width:100%;height:100%;position:relative;display:flex;align-items:flex-end;justify-content:center;gap:6%;padding-bottom:10%;box-sizing:border-box;">
  <div class="sutol-tech-04-box" style="animation-delay:0s;background:#60a5fa;"></div>
  <div class="sutol-tech-04-box" style="animation-delay:0.3s;background:#818cf8;"></div>
  <div class="sutol-tech-04-box" style="animation-delay:0.6s;background:#38bdf8;"></div>
  <div class="sutol-tech-04-box" style="animation-delay:0.9s;background:#6366f1;"></div>
  <style>
    .sutol-tech-04-box {
      width: 14%;
      height: 22%;
      border-radius: 10%;
      animation: sutol-tech-04-stack 3.2s ease-in-out infinite;
      transform-origin: bottom center;
    }
    @keyframes sutol-tech-04-stack {
      0% { transform: translateY(-40%) scale(0.85); opacity: 0.3; }
      35% { transform: translateY(0) scale(1); opacity: 1; }
      70% { transform: translateY(0) scale(1); opacity: 1; }
      100% { transform: translateY(-40%) scale(0.85); opacity: 0.3; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-04-box { animation: none; opacity: 1; transform: none; }
    }
  </style>
</div>
```

---

## Bileşen 5: Veri Gölü Damlaları

**Etiketler (keyword eşleşmesi için):** veri gölü, big data, veri depolama, ham veri
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Farklı veri parçacıklarının bir göle damlayıp dalga dalga yayıldığı bir animasyon.

```html
<div class="sutol-tech-05-lake" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;max-width:400px;">
    <ellipse cx="100" cy="140" rx="80" ry="24" fill="#0369a1" opacity="0.35"/>
    <g fill="none" stroke="#38bdf8" stroke-width="1.5" opacity="0.7">
      <ellipse cx="100" cy="140" rx="20" ry="6">
        <animate attributeName="rx" values="10;60;10" dur="3s" repeatCount="indefinite"/>
        <animate attributeName="ry" values="3;18;3" dur="3s" repeatCount="indefinite"/>
        <animate attributeName="opacity" values="0.8;0;0.8" dur="3s" repeatCount="indefinite"/>
      </ellipse>
    </g>
    <g fill="#7dd3fc">
      <path d="M95,20 Q95,45 100,50 Q105,45 105,20 Z">
        <animateTransform attributeName="transform" type="translate" values="0,0;0,90" dur="1.6s" repeatCount="indefinite"/>
        <animate attributeName="opacity" values="1;1;0" dur="1.6s" repeatCount="indefinite"/>
      </path>
      <path d="M75,10 Q75,30 80,35 Q85,30 85,10 Z" opacity="0.7">
        <animateTransform attributeName="transform" type="translate" values="0,0;0,100" dur="2s" repeatCount="indefinite" begin="0.4s"/>
        <animate attributeName="opacity" values="0.7;0.7;0" dur="2s" repeatCount="indefinite" begin="0.4s"/>
      </path>
      <path d="M120,15 Q120,35 125,40 Q130,35 130,15 Z" opacity="0.6">
        <animateTransform attributeName="transform" type="translate" values="0,0;0,95" dur="1.8s" repeatCount="indefinite" begin="0.8s"/>
        <animate attributeName="opacity" values="0.6;0.6;0" dur="1.8s" repeatCount="indefinite" begin="0.8s"/>
      </path>
    </g>
  </svg>
  <style>
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-05-lake animate, .sutol-tech-05-lake animateTransform { display: none; }
    }
  </style>
</div>
```

---

## Bileşen 6: Akış Boru Hattı

**Etiketler (keyword eşleşmesi için):** akış işleme, veri akışı, streaming, gerçek zamanlı
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Bir borudan geçen renkli veri paketlerinin kesintisiz aktığı akış işleme animasyonu.

```html
<div class="sutol-tech-06-stream" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 100" style="width:100%;height:100%;max-width:420px;">
    <path d="M10,50 Q60,20 100,50 T190,50" fill="none" stroke="#a3a3a3" stroke-width="3" opacity="0.35" stroke-linecap="round"/>
    <g fill="#22d3ee">
      <circle r="5"><animateMotion dur="2.2s" repeatCount="indefinite" path="M10,50 Q60,20 100,50 T190,50"/></circle>
    </g>
    <g fill="#a78bfa">
      <circle r="5"><animateMotion dur="2.2s" repeatCount="indefinite" begin="0.5s" path="M10,50 Q60,20 100,50 T190,50"/></circle>
    </g>
    <g fill="#fb7185">
      <circle r="5"><animateMotion dur="2.2s" repeatCount="indefinite" begin="1s" path="M10,50 Q60,20 100,50 T190,50"/></circle>
    </g>
    <g fill="#facc15">
      <circle r="5"><animateMotion dur="2.2s" repeatCount="indefinite" begin="1.5s" path="M10,50 Q60,20 100,50 T190,50"/></circle>
    </g>
  </svg>
  <style>
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-06-stream animateMotion { display: none; }
    }
  </style>
</div>
```

---

## Bileşen 7: Dil Analiz Balonları

**Etiketler (keyword eşleşmesi için):** doğal dil işleme, NLP, metin analizi, dilbilim
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Bir konuşma balonunun küçük sembolik jetonlara (token) ayrıştığı doğal dil işleme animasyonu.

```html
<div class="sutol-tech-07-nlp" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 160" style="width:100%;height:100%;max-width:400px;">
    <path d="M40,40 h90 a10,10 0 0 1 10,10 v40 a10,10 0 0 1 -10,10 h-60 l-15,15 v-15 h-15 a10,10 0 0 1 -10,-10 v-40 a10,10 0 0 1 10,-10 z"
      fill="#6366f1" opacity="0.85">
      <animate attributeName="opacity" values="0.85;0.3;0.85" dur="3s" repeatCount="indefinite"/>
    </path>
    <g fill="#c7d2fe">
      <rect x="55" y="128" width="12" height="12" rx="3">
        <animate attributeName="y" values="60;128;128" dur="3s" repeatCount="indefinite"/>
        <animate attributeName="opacity" values="0;1;1" dur="3s" repeatCount="indefinite"/>
      </rect>
      <rect x="75" y="128" width="18" height="12" rx="3">
        <animate attributeName="y" values="60;128;128" dur="3s" repeatCount="indefinite" begin="0.1s"/>
        <animate attributeName="opacity" values="0;1;1" dur="3s" repeatCount="indefinite" begin="0.1s"/>
      </rect>
      <rect x="100" y="128" width="10" height="12" rx="3">
        <animate attributeName="y" values="60;128;128" dur="3s" repeatCount="indefinite" begin="0.2s"/>
        <animate attributeName="opacity" values="0;1;1" dur="3s" repeatCount="indefinite" begin="0.2s"/>
      </rect>
      <rect x="118" y="128" width="22" height="12" rx="3">
        <animate attributeName="y" values="60;128;128" dur="3s" repeatCount="indefinite" begin="0.3s"/>
        <animate attributeName="opacity" values="0;1;1" dur="3s" repeatCount="indefinite" begin="0.3s"/>
      </rect>
    </g>
  </svg>
  <style>
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-07-nlp animate { display: none; }
    }
  </style>
</div>
```

---

## Bileşen 8: Görü Tarama Çerçevesi

**Etiketler (keyword eşleşmesi için):** bilgisayarlı görü, görüntü işleme, nesne tanıma, kamera
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Bir tarama çerçevesinin geometrik şekillerin üzerinde gezip onları tespit ettiği bilgisayarlı görü animasyonu.

```html
<div class="sutol-tech-08-vision" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 160" style="width:100%;height:100%;max-width:400px;">
    <circle cx="60" cy="60" r="16" fill="#34d399" opacity="0.8"/>
    <rect x="120" y="90" width="34" height="34" rx="4" fill="#60a5fa" opacity="0.8"/>
    <polygon points="60,110 78,140 42,140" fill="#f472b6" opacity="0.8"/>
    <g class="sutol-tech-08-scanner">
      <rect x="0" y="0" width="44" height="44" fill="none" stroke="#facc15" stroke-width="3" rx="6"/>
      <line x1="0" y1="10" x2="44" y2="10" stroke="#facc15" stroke-width="1" opacity="0.6"/>
    </g>
  </svg>
  <style>
    .sutol-tech-08-scanner {
      offset-path: path('M40,40 L140,60 L60,110 L140,90 L40,40');
      animation: sutol-tech-08-move 6s linear infinite;
    }
    @keyframes sutol-tech-08-move {
      0% { offset-distance: 0%; }
      100% { offset-distance: 100%; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-08-scanner { animation: none; offset-distance: 0%; }
    }
  </style>
</div>
```

---

## Bileşen 9: Dijital İkiz Küpler

**Etiketler (keyword eşleşmesi için):** dijital ikiz, simülasyon, senkronizasyon, fiziksel model
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Gerçek bir nesneyi temsil eden küpün, yanındaki şeffaf dijital ikizi ile eş zamanlı döndüğü animasyon.

```html
<div class="sutol-tech-09-twin" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;gap:12%;perspective:600px;">
  <div class="sutol-tech-09-cube sutol-tech-09-solid"></div>
  <div class="sutol-tech-09-cube sutol-tech-09-ghost"></div>
  <style>
    .sutol-tech-09-cube {
      width: 22%;
      aspect-ratio: 1;
      position: relative;
      transform-style: preserve-3d;
      animation: sutol-tech-09-spin 6s linear infinite;
    }
    .sutol-tech-09-solid { background: linear-gradient(135deg,#0ea5e9,#0369a1); border-radius: 8%; }
    .sutol-tech-09-ghost { background: rgba(14,165,233,0.15); border: 1.5px solid #38bdf8; border-radius: 8%; }
    @keyframes sutol-tech-09-spin {
      0% { transform: rotateY(0deg) rotateX(15deg); }
      100% { transform: rotateY(360deg) rotateX(15deg); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-09-cube { animation: none; transform: rotateY(30deg) rotateX(15deg); }
    }
  </style>
</div>
```

---

## Bileşen 10: Federe Öğrenme Yıldızı

**Etiketler (keyword eşleşmesi için):** federe öğrenme, makine öğrenmesi, dağıtık yapay zeka, model paylaşımı
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Merkezi model ile çevresindeki cihazlar arasında karşılıklı öğrenme güncellemelerinin gidip geldiği animasyon.

```html
<div class="sutol-tech-10-federated" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;max-width:400px;">
    <g stroke="#c084fc" stroke-width="1" opacity="0.4" fill="none">
      <line x1="100" y1="100" x2="100" y2="35"/>
      <line x1="100" y1="100" x2="160" y2="70"/>
      <line x1="100" y1="100" x2="160" y2="130"/>
      <line x1="100" y1="100" x2="100" y2="165"/>
      <line x1="100" y1="100" x2="40" y2="130"/>
      <line x1="100" y1="100" x2="40" y2="70"/>
    </g>
    <circle cx="100" cy="100" r="16" fill="#9333ea"/>
    <g fill="#d8b4fe">
      <circle cx="100" cy="35" r="8"/>
      <circle cx="160" cy="70" r="8"/>
      <circle cx="160" cy="130" r="8"/>
      <circle cx="100" cy="165" r="8"/>
      <circle cx="40" cy="130" r="8"/>
      <circle cx="40" cy="70" r="8"/>
    </g>
    <g fill="#f0abfc">
      <circle r="3"><animateMotion dur="2s" repeatCount="indefinite" path="M100,35 L100,100"/></circle>
      <circle r="3"><animateMotion dur="2s" repeatCount="indefinite" begin="0.3s" path="M100,100 L160,70"/></circle>
      <circle r="3"><animateMotion dur="2s" repeatCount="indefinite" begin="0.6s" path="M160,130 L100,100"/></circle>
      <circle r="3"><animateMotion dur="2s" repeatCount="indefinite" begin="0.9s" path="M100,100 L100,165"/></circle>
      <circle r="3"><animateMotion dur="2s" repeatCount="indefinite" begin="1.2s" path="M40,130 L100,100"/></circle>
      <circle r="3"><animateMotion dur="2s" repeatCount="indefinite" begin="1.5s" path="M100,100 L40,70"/></circle>
    </g>
  </svg>
  <style>
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-10-federated animateMotion { display: none; }
    }
  </style>
</div>
```

---

## Bileşen 11: Sıfır Güven Katmanları

**Etiketler (keyword eşleşmesi için):** sıfır güven mimarisi, siber güvenlik, kimlik doğrulama, erişim kontrolü
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** İç içe geçmiş kalkan katmanlarının merkezdeki veriyi sırayla doğrulayıp koruduğu bir güvenlik animasyonu.

```html
<div class="sutol-tech-11-zerotrust" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;max-width:400px;">
    <g fill="none" stroke-width="3">
      <path class="sutol-tech-11-ring" d="M100,20 L160,45 V95 C160,135 135,165 100,180 C65,165 40,135 40,95 V45 Z" stroke="#f87171" style="animation-delay:0s;"/>
      <path class="sutol-tech-11-ring" d="M100,40 L145,60 V95 C145,125 125,148 100,160 C75,148 55,125 55,95 V60 Z" stroke="#fb923c" style="animation-delay:0.4s;"/>
      <path class="sutol-tech-11-ring" d="M100,60 L130,74 V95 C130,116 116,132 100,140 C84,132 70,116 70,95 V74 Z" stroke="#fbbf24" style="animation-delay:0.8s;"/>
    </g>
    <circle cx="100" cy="100" r="10" fill="#fef3c7"/>
  </svg>
  <style>
    .sutol-tech-11-ring {
      transform-origin: 100px 100px;
      animation: sutol-tech-11-check 2.4s ease-in-out infinite;
    }
    @keyframes sutol-tech-11-check {
      0%, 100% { opacity: 0.35; }
      50% { opacity: 1; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-11-ring { animation: none; opacity: 0.8; }
    }
  </style>
</div>
```

---

## Bileşen 12: Parmak İzi Tarayıcı

**Etiketler (keyword eşleşmesi için):** biyometrik tanıma, parmak izi, kimlik doğrulama, güvenlik
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Bir parmak izi deseninin üzerinden aşağı yukarı geçen tarayıcı ışığının biyometrik doğrulamayı temsil ettiği animasyon.

```html
<div class="sutol-tech-12-finger" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;max-width:360px;">
    <g fill="none" stroke="#34d399" stroke-width="3" stroke-linecap="round">
      <path d="M60,150 C60,110 60,70 100,50 C140,70 140,110 140,150"/>
      <path d="M75,155 C75,120 78,85 100,72 C122,85 125,120 125,155"/>
      <path d="M90,158 C90,130 92,105 100,98 C108,105 110,130 110,158"/>
    </g>
    <rect x="45" y="45" width="110" height="6" rx="3" fill="#a7f3d0" class="sutol-tech-12-scan"/>
  </svg>
  <style>
    .sutol-tech-12-scan {
      animation: sutol-tech-12-sweep 2.4s ease-in-out infinite;
      transform-origin: center;
    }
    @keyframes sutol-tech-12-sweep {
      0% { transform: translateY(0); opacity: 0.9; }
      50% { transform: translateY(110px); opacity: 0.9; }
      100% { transform: translateY(0); opacity: 0.9; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-12-scan { animation: none; }
    }
  </style>
</div>
```

---

## Bileşen 13: Yüz Tanıma Izgarası

**Etiketler (keyword eşleşmesi için):** yüz tanıma, biyometrik tanıma, kimlik doğrulama, tanıma sistemi
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Basit bir yüz silüetinin üzerinde belirip kaybolan tanıma noktalarının ve çerçevenin olduğu bir animasyon.

```html
<div class="sutol-tech-13-face" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;max-width:360px;">
    <rect x="55" y="40" width="90" height="110" rx="20" fill="none" stroke="#38bdf8" stroke-width="2.5"/>
    <circle cx="55" cy="40" r="4" fill="#38bdf8"/>
    <circle cx="145" cy="40" r="4" fill="#38bdf8"/>
    <circle cx="55" cy="150" r="4" fill="#38bdf8"/>
    <circle cx="145" cy="150" r="4" fill="#38bdf8"/>
    <ellipse cx="100" cy="95" rx="34" ry="42" fill="#bae6fd" opacity="0.5"/>
    <g fill="#0ea5e9" class="sutol-tech-13-points">
      <circle cx="85" cy="85" r="2.5"/>
      <circle cx="115" cy="85" r="2.5"/>
      <circle cx="100" cy="98" r="2.5"/>
      <circle cx="88" cy="112" r="2.5"/>
      <circle cx="112" cy="112" r="2.5"/>
      <circle cx="100" cy="118" r="2.5"/>
    </g>
  </svg>
  <style>
    .sutol-tech-13-points { animation: sutol-tech-13-blink 2.2s ease-in-out infinite; }
    @keyframes sutol-tech-13-blink {
      0%, 100% { opacity: 0.25; }
      50% { opacity: 1; }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-13-points { animation: none; opacity: 0.8; }
    }
  </style>
</div>
```

---

## Bileşen 14: Akıllı Sözleşme Zinciri

**Etiketler (keyword eşleşmesi için):** akıllı sözleşme, blockchain, dağıtık defter, otomasyon
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Ardışık blokların birbirine kilitlenip onaylandığı, halka zincir şeklinde bir akıllı sözleşme animasyonu.

```html
<div class="sutol-tech-14-contract" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;gap:4%;">
  <div class="sutol-tech-14-block" style="animation-delay:0s;"></div>
  <div class="sutol-tech-14-block" style="animation-delay:0.3s;"></div>
  <div class="sutol-tech-14-block" style="animation-delay:0.6s;"></div>
  <div class="sutol-tech-14-block" style="animation-delay:0.9s;"></div>
  <style>
    .sutol-tech-14-block {
      width: 16%;
      aspect-ratio: 1;
      background: linear-gradient(135deg,#4ade80,#16a34a);
      border-radius: 15%;
      position: relative;
      animation: sutol-tech-14-link 2.4s ease-in-out infinite;
    }
    .sutol-tech-14-block::after {
      content:"";
      position:absolute; top:50%; right:-14%;
      width: 14%; height: 3px; background: #86efac;
      transform: translateY(-50%);
    }
    .sutol-tech-14-block:last-child::after { display:none; }
    @keyframes sutol-tech-14-link {
      0%, 100% { transform: scale(1); box-shadow: 0 0 0 rgba(74,222,128,0); }
      50% { transform: scale(1.12); box-shadow: 0 0 14px rgba(74,222,128,0.6); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-14-block { animation: none; }
    }
  </style>
</div>
```

---

## Bileşen 15: Dağıtık Defter Ağı

**Etiketler (keyword eşleşmesi için):** dağıtık defter, blockchain, senkronizasyon, düğüm ağı
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Canvas üzerinde çizilen düğümlerin sürekli birbirine veri gönderip senkronize olduğu, JS ile hareket ettirilen bir ağ animasyonu.

```html
<div class="sutol-tech-15-ledger" style="width:100%;height:100%;position:relative;">
  <canvas class="sutol-tech-15-canvas" style="width:100%;height:100%;display:block;"></canvas>
  <script>
    (function(){
      var root = document.currentScript.closest('.sutol-tech-15-ledger');
      var canvas = root.querySelector('.sutol-tech-15-canvas');
      var ctx = canvas.getContext('2d');
      var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      var W,H;
      function resize(){
        var r = canvas.getBoundingClientRect();
        W = canvas.width = r.width; H = canvas.height = r.height;
      }
      resize();
      window.addEventListener('resize', resize);
      var nodes = [];
      var n = 6;
      for (var i=0;i<n;i++){
        var ang = (i/n)*Math.PI*2;
        nodes.push({ang: ang, phase: Math.random()*Math.PI*2});
      }
      var pulses = [];
      var t = 0;
      function frame(){
        t += reduce ? 0 : 0.02;
        ctx.clearRect(0,0,W,H);
        var cx = W/2, cy = H/2, R = Math.min(W,H)*0.32;
        var pts = nodes.map(function(nd){
          return { x: cx + Math.cos(nd.ang)*R, y: cy + Math.sin(nd.ang)*R };
        });
        ctx.strokeStyle = 'rgba(129,140,248,0.25)';
        ctx.lineWidth = 1;
        for (var i=0;i<pts.length;i++){
          for (var j=i+1;j<pts.length;j++){
            ctx.beginPath();
            ctx.moveTo(pts[i].x, pts[i].y);
            ctx.lineTo(pts[j].x, pts[j].y);
            ctx.stroke();
          }
        }
        if (!reduce && Math.random() < 0.03) {
          var a = Math.floor(Math.random()*n);
          var b = Math.floor(Math.random()*n);
          if (a !== b) pulses.push({a:a, b:b, p:0});
        }
        ctx.fillStyle = '#a78bfa';
        pulses.forEach(function(pl){
          pl.p += 0.03;
          var x = pts[pl.a].x + (pts[pl.b].x - pts[pl.a].x)*pl.p;
          var y = pts[pl.a].y + (pts[pl.b].y - pts[pl.a].y)*pl.p;
          ctx.beginPath(); ctx.arc(x,y,3,0,Math.PI*2); ctx.fill();
        });
        pulses = pulses.filter(function(pl){ return pl.p < 1; });
        pts.forEach(function(p){
          ctx.beginPath();
          ctx.arc(p.x, p.y, 8, 0, Math.PI*2);
          ctx.fillStyle = '#6366f1';
          ctx.fill();
        });
        requestAnimationFrame(frame);
      }
      requestAnimationFrame(frame);
    })();
  </script>
</div>
```

---

## Bileşen 16: Mesh Network Düğümleri

**Etiketler (keyword eşleşmesi için):** mesh network, kablosuz ağ, düğüm bağlantısı, iletişim
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Birbirine eşit şekilde bağlı düğümlerin sırayla parladığı, hiyerarşisiz mesh ağ yapısını temsil eden animasyon.

```html
<div class="sutol-tech-16-mesh" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;max-width:400px;">
    <g stroke="#38bdf8" stroke-width="1" opacity="0.35" fill="none">
      <line x1="40" y1="40" x2="160" y2="40"/>
      <line x1="40" y1="40" x2="100" y2="100"/>
      <line x1="160" y1="40" x2="100" y2="100"/>
      <line x1="40" y1="40" x2="40" y2="160"/>
      <line x1="160" y1="40" x2="160" y2="160"/>
      <line x1="100" y1="100" x2="40" y2="160"/>
      <line x1="100" y1="100" x2="160" y2="160"/>
      <line x1="40" y1="160" x2="160" y2="160"/>
    </g>
    <g fill="#0ea5e9">
      <circle cx="40" cy="40" r="8" class="sutol-tech-16-node" style="animation-delay:0s;"/>
      <circle cx="160" cy="40" r="8" class="sutol-tech-16-node" style="animation-delay:0.4s;"/>
      <circle cx="100" cy="100" r="9" class="sutol-tech-16-node" style="animation-delay:0.8s;"/>
      <circle cx="40" cy="160" r="8" class="sutol-tech-16-node" style="animation-delay:1.2s;"/>
      <circle cx="160" cy="160" r="8" class="sutol-tech-16-node" style="animation-delay:1.6s;"/>
    </g>
  </svg>
  <style>
    .sutol-tech-16-node {
      animation: sutol-tech-16-glow 3s ease-in-out infinite;
      transform-origin: center;
      transform-box: fill-box;
    }
    @keyframes sutol-tech-16-glow {
      0%, 100% { opacity: 0.5; transform: scale(1); }
      50% { opacity: 1; transform: scale(1.3); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-16-node { animation: none; opacity: 0.85; }
    }
  </style>
</div>
```

---

## Bileşen 17: 5G Sinyal Dalgaları

**Etiketler (keyword eşleşmesi için):** 5g teknolojisi, kablosuz iletişim, sinyal, baz istasyonu
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Bir baz istasyonu simgesinden dışa doğru yayılan eş merkezli sinyal dalgalarının olduğu animasyon.

```html
<div class="sutol-tech-17-5g" style="width:100%;height:100%;position:relative;display:flex;align-items:flex-end;justify-content:center;">
  <svg viewBox="0 0 200 200" style="width:100%;height:100%;max-width:360px;">
    <polygon points="100,110 92,170 108,170" fill="#f97316"/>
    <rect x="97" y="90" width="6" height="24" fill="#f97316"/>
    <circle cx="100" cy="80" r="6" fill="#fb923c"/>
    <g fill="none" stroke="#fdba74" stroke-width="3" stroke-linecap="round">
      <path class="sutol-tech-17-wave" d="M75,80 A30,30 0 0 1 125,80" style="animation-delay:0s;"/>
      <path class="sutol-tech-17-wave" d="M60,80 A45,45 0 0 1 140,80" style="animation-delay:0.5s;"/>
      <path class="sutol-tech-17-wave" d="M45,80 A60,60 0 0 1 155,80" style="animation-delay:1s;"/>
    </g>
  </svg>
  <style>
    .sutol-tech-17-wave {
      transform-origin: 100px 80px;
      animation: sutol-tech-17-pulse 2.4s ease-out infinite;
    }
    @keyframes sutol-tech-17-pulse {
      0% { opacity: 0; transform: scale(0.85); }
      30% { opacity: 1; }
      100% { opacity: 0; transform: scale(1.1); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-17-wave { animation: none; opacity: 0.6; }
    }
  </style>
</div>
```

---

## Bileşen 18: Sunucusuz Fonksiyon Patlamaları

**Etiketler (keyword eşleşmesi için):** sunucusuz mimari, serverless, fonksiyon, bulut bilişim
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Bir bulut şeklinin içinde rastgele ortaya çıkıp kaybolan küçük fonksiyon ikonlarının olduğu sunucusuz mimari animasyonu.

```html
<div class="sutol-tech-18-serverless" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <svg viewBox="0 0 200 160" style="width:100%;height:100%;max-width:400px;">
    <path d="M55,110 a30,30 0 0 1 0,-60 a38,38 0 0 1 74,-8 a28,28 0 0 1 16,54 a30,30 0 0 1 -8,14 z"
      fill="#818cf8" opacity="0.5"/>
    <g fill="#4f46e5">
      <rect x="65" y="65" width="14" height="14" rx="3" class="sutol-tech-18-fn" style="animation-delay:0s;"/>
      <rect x="95" y="55" width="14" height="14" rx="3" class="sutol-tech-18-fn" style="animation-delay:0.6s;"/>
      <rect x="120" y="75" width="14" height="14" rx="3" class="sutol-tech-18-fn" style="animation-delay:1.2s;"/>
      <rect x="80" y="90" width="14" height="14" rx="3" class="sutol-tech-18-fn" style="animation-delay:1.8s;"/>
    </g>
  </svg>
  <style>
    .sutol-tech-18-fn {
      animation: sutol-tech-18-pop 2.8s ease-in-out infinite;
      transform-origin: center;
      transform-box: fill-box;
    }
    @keyframes sutol-tech-18-pop {
      0%, 20% { opacity: 0; transform: scale(0.3); }
      35%, 65% { opacity: 1; transform: scale(1); }
      85%, 100% { opacity: 0; transform: scale(0.3); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-18-fn { animation: none; opacity: 0.9; transform: scale(1); }
    }
  </style>
</div>
```

---

## Bileşen 19: Hipervizör Sanal Makineler

**Etiketler (keyword eşleşmesi için):** hipervizör, sanallaştırma, sanal makine, fiziksel sunucu
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Tek bir fiziksel sunucu üzerinde birden fazla sanal makinenin katman katman canlanıp nabız attığı animasyon.

```html
<div class="sutol-tech-19-hyper" style="width:100%;height:100%;position:relative;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:4%;">
  <div class="sutol-tech-19-vm" style="animation-delay:0s;background:#f472b6;"></div>
  <div class="sutol-tech-19-vm" style="animation-delay:0.4s;background:#e879f9;"></div>
  <div class="sutol-tech-19-vm" style="animation-delay:0.8s;background:#c084fc;"></div>
  <div class="sutol-tech-19-host"></div>
  <style>
    .sutol-tech-19-vm {
      width: 46%;
      height: 14%;
      border-radius: 10%;
      animation: sutol-tech-19-pulse 2.4s ease-in-out infinite;
    }
    .sutol-tech-19-host {
      width: 60%;
      height: 8%;
      background: #581c87;
      border-radius: 10%;
    }
    @keyframes sutol-tech-19-pulse {
      0%, 100% { opacity: 0.4; transform: scaleX(0.92); }
      50% { opacity: 1; transform: scaleX(1); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-19-vm { animation: none; opacity: 0.85; }
    }
  </style>
</div>
```

---

## Bileşen 20: GPU Hızlandırma Çekirdekleri

**Etiketler (keyword eşleşmesi için):** GPU hızlandırma, paralel işlem, grafik işlemci, hesaplama gücü
**Kategori:** Teknoloji / Bilgisayar
**Açıklama:** Çok sayıda küçük çekirdeğin eş zamanlı ve dalga şeklinde yanıp söndüğü, paralel işlem gücünü temsil eden GPU animasyonu.

```html
<div class="sutol-tech-20-gpu" style="width:100%;height:100%;position:relative;display:flex;align-items:center;justify-content:center;">
  <div class="sutol-tech-20-grid">
    <div class="sutol-tech-20-core" style="animation-delay:0.0s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.1s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.2s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.3s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.1s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.2s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.3s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.4s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.2s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.3s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.4s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.5s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.3s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.4s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.5s;"></div>
    <div class="sutol-tech-20-core" style="animation-delay:0.6s;"></div>
  </div>
  <style>
    .sutol-tech-20-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 8%;
      width: 60%;
      aspect-ratio: 1;
    }
    .sutol-tech-20-core {
      background: #22c55e;
      border-radius: 20%;
      animation: sutol-tech-20-flicker 1.6s ease-in-out infinite;
    }
    @keyframes sutol-tech-20-flicker {
      0%, 100% { opacity: 0.25; transform: scale(0.85); }
      50% { opacity: 1; transform: scale(1); }
    }
    @media (prefers-reduced-motion: reduce) {
      .sutol-tech-20-core { animation: none; opacity: 0.8; }
    }
  </style>
</div>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Kuantum Küre): SVG `animateMotion` ile yörünge hareketi — GPU dostu, hafif.
- Bileşen 2 (Kenar Düğümleri): SVG `animateMotion` ile düğümler arası veri paketi akışı — hafif.
- Bileşen 3 (Mikroservis Altıgenleri): CSS `transform: scale()` keyframe nabzı — GPU hızlandırmalı.
- Bileşen 4 (Konteyner İstifleme): CSS `translateY` + `scale` keyframe — GPU hızlandırmalı.
- Bileşen 5 (Veri Gölü Damlaları): SVG `animate`/`animateTransform` ile damla düşüşü ve dalga genişlemesi.
- Bileşen 6 (Akış Boru Hattı): SVG `animateMotion` ile eğrisel yol boyunca akış — hafif.
- Bileşen 7 (Dil Analiz Balonları): SVG `animate` ile konum/opaklık geçişi.
- Bileşen 8 (Görü Tarama Çerçevesi): CSS `offset-path` ile modern yol boyunca hareket (destekleyen tarayıcılarda).
- Bileşen 9 (Dijital İkiz Küpler): CSS 3D `rotateY/rotateX` — `transform-style: preserve-3d`, GPU hızlandırmalı.
- Bileşen 10 (Federe Öğrenme Yıldızı): SVG `animateMotion` ile çift yönlü veri alışverişi.
- Bileşen 11 (Sıfır Güven Katmanları): CSS `opacity` keyframe döngüsü, katmanlı gecikme.
- Bileşen 12 (Parmak İzi Tarayıcı): CSS `translateY` tarama çizgisi — düşük maliyetli.
- Bileşen 13 (Yüz Tanıma Izgarası): CSS `opacity` blink animasyonu — minimal DOM.
- Bileşen 14 (Akıllı Sözleşme Zinciri): CSS `scale` + `box-shadow` nabız, sıralı gecikmeler.
- Bileşen 15 (Dağıtık Defter Ağı): Canvas + `requestAnimationFrame` — tek JS bileşeni, `prefers-reduced-motion` JS içinde kontrol edilir.
- Bileşen 16 (Mesh Network Düğümleri): CSS `scale`/`opacity` nabız, `transform-box: fill-box` ile SVG uyumlu.
- Bileşen 17 (5G Sinyal Dalgaları): CSS `scale`+`opacity` genişleyen dalga animasyonu.
- Bileşen 18 (Sunucusuz Fonksiyon Patlamaları): CSS `scale`+`opacity` pop-in/out döngüsü.
- Bileşen 19 (Hipervizör Sanal Makineler): CSS `scaleX`+`opacity` nabız, dikey istif düzeni.
- Bileşen 20 (GPU Hızlandırma Çekirdekleri): CSS grid + `scale`/`opacity` dalga flicker efekti, 16 öğe ile paralellik hissi.

Tüm bileşenler: tek dosya bağımsız yapı, şeffaf arka plan, `viewBox`/yüzde tabanlı ölçekleme, `prefers-reduced-motion` desteği, sabit metin içermez, global CSS seçici kullanılmaz, dış kaynak/CDN/API çağrısı yoktur.
