# Sağlık / Tıp — 20 Animasyonlu HTML Bileşeni (Sutol)

---

## Bileşen 1: Biyopsi — Doku Örneklemesi

**Etiketler (keyword eşleşmesi için):** biyopsi, klinik deney, onkoloji
**Kategori:** Sağlık / Tıp
**Açıklama:** Bir dokudan örnek alan ve geri çekilen soyut bir biyopsi iğnesi döngüsü.

```html
<div class="sutol-med-01-root">
<style>
.sutol-med-01-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-med-01-root svg{width:100%;height:100%;display:block}
.sutol-med-01-needle{animation:sutol-med-01-jab 3s ease-in-out infinite}
@keyframes sutol-med-01-jab{0%,20%{transform:translateY(0)}35%{transform:translateY(30px)}55%,100%{transform:translateY(0)}}
.sutol-med-01-sample{animation:sutol-med-01-glow 3s ease-in-out infinite}
@keyframes sutol-med-01-glow{0%,45%{opacity:.3}60%,80%{opacity:.9}100%{opacity:.3}}
@media (prefers-reduced-motion: reduce){.sutol-med-01-needle,.sutol-med-01-sample{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<circle cx="100" cy="150" r="34" fill="#bbf7d0" opacity="0.5"/>
<circle class="sutol-med-01-sample" cx="100" cy="150" r="6" fill="#059669"/>
<g class="sutol-med-01-needle">
<line x1="100" y1="20" x2="100" y2="110" stroke="#64748b" stroke-width="4" stroke-linecap="round"/>
<rect x="90" y="6" width="20" height="18" rx="3" fill="#94a3b8"/>
</g>
</svg>
</div>
```

---

## Bileşen 2: Cerrahi Robot

**Etiketler:** cerrahi robot, klinik deney, kişiselleştirilmiş tıp
**Kategori:** Sağlık / Tıp
**Açıklama:** Hassas bir hareketle çalışan, eklemli çok kollu bir cerrahi robot kolu.

```html
<div class="sutol-med-02-root">
<style>
.sutol-med-02-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-02-root svg{width:100%;height:100%;display:block}
.sutol-med-02-arm1{transform-origin:100px 60px;animation:sutol-med-02-swing1 4s ease-in-out infinite}
.sutol-med-02-arm2{transform-origin:70px 100px;animation:sutol-med-02-swing2 4s ease-in-out infinite}
@keyframes sutol-med-02-swing1{0%,100%{transform:rotate(-10deg)}50%{transform:rotate(12deg)}}
@keyframes sutol-med-02-swing2{0%,100%{transform:rotate(8deg)}50%{transform:rotate(-14deg)}}
.sutol-med-02-tip{animation:sutol-med-02-blink 2s ease-in-out infinite}
@keyframes sutol-med-02-blink{0%,100%{opacity:.5}50%{opacity:1}}
@media (prefers-reduced-motion: reduce){.sutol-med-02-arm1,.sutol-med-02-arm2,.sutol-med-02-tip{animation-duration:10s}}
</style>
<svg viewBox="0 0 200 200">
<rect x="90" y="20" width="20" height="30" rx="4" fill="#475569"/>
<g class="sutol-med-02-arm1">
<line x1="100" y1="60" x2="130" y2="100" stroke="#64748b" stroke-width="8" stroke-linecap="round"/>
</g>
<g class="sutol-med-02-arm2">
<line x1="70" y1="100" x2="60" y2="150" stroke="#64748b" stroke-width="8" stroke-linecap="round"/>
</g>
<circle class="sutol-med-02-tip" cx="130" cy="100" r="4" fill="#22d3ee"/>
<circle class="sutol-med-02-tip" cx="60" cy="150" r="4" fill="#22d3ee"/>
</svg>
</div>
```

---

## Bileşen 3: Organ Nakli — Kalp Sembolü

**Etiketler:** organ nakli, cerrahi robot, resüsitasyon
**Kategori:** Sağlık / Tıp
**Açıklama:** İki taraf arasında bağlantı kuran, yumuşakça atan soyut bir kalp/organ sembolü.

```html
<div class="sutol-med-03-root">
<style>
.sutol-med-03-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-03-root svg{width:100%;height:100%;display:block}
.sutol-med-03-heart{transform-origin:100px 100px;animation:sutol-med-03-beat 1.6s ease-in-out infinite}
@keyframes sutol-med-03-beat{0%,100%{transform:scale(1)}20%{transform:scale(1.12)}35%{transform:scale(1)}}
.sutol-med-03-link{stroke-dasharray:4 4;animation:sutol-med-03-flow 3s linear infinite}
@keyframes sutol-med-03-flow{to{stroke-dashoffset:-40}}
@media (prefers-reduced-motion: reduce){.sutol-med-03-heart{animation-duration:6s}.sutol-med-03-link{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<line class="sutol-med-03-link" x1="30" y1="100" x2="80" y2="100" stroke="#94a3b8" stroke-width="2"/>
<line class="sutol-med-03-link" x1="120" y1="100" x2="170" y2="100" stroke="#94a3b8" stroke-width="2"/>
<circle cx="30" cy="100" r="8" fill="#93c5fd"/>
<circle cx="170" cy="100" r="8" fill="#86efac"/>
<path class="sutol-med-03-heart" d="M100,120 C70,95 60,70 80,58 C92,50 100,60 100,68 C100,60 108,50 120,58 C140,70 130,95 100,120 Z" fill="#f87171"/>
</svg>
</div>
```

---

## Bileşen 4: Organ Bağış Zinciri

**Etiketler:** organ nakli, telemedikal hizmet, epidemiyoloji
**Kategori:** Sağlık / Tıp
**Açıklama:** Birbirine bağlanan düğümler arasında dolaşan bir bağış/aktarım zinciri.

```html
<div class="sutol-med-04-root">
<style>
.sutol-med-04-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-04-root svg{width:100%;height:100%;display:block}
.sutol-med-04-dot{animation:sutol-med-04-move 3.6s linear infinite;offset-path:path('M30,100 C60,40 140,40 170,100 C140,160 60,160 30,100');}
@keyframes sutol-med-04-move{0%{offset-distance:0%}100%{offset-distance:100%}}
.sutol-med-04-node{animation:sutol-med-04-pulse 3s ease-in-out infinite}
.sutol-med-04-node:nth-child(2){animation-delay:.7s}
.sutol-med-04-node:nth-child(3){animation-delay:1.4s}
@keyframes sutol-med-04-pulse{0%,100%{opacity:.5}50%{opacity:1}}
@media (prefers-reduced-motion: reduce){.sutol-med-04-dot{animation-duration:10s}.sutol-med-04-node{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<path d="M30,100 C60,40 140,40 170,100 C140,160 60,160 30,100" fill="none" stroke="#a7f3d0" stroke-width="2" opacity="0.5"/>
<g fill="#10b981">
<circle class="sutol-med-04-node" cx="30" cy="100" r="7"/>
<circle class="sutol-med-04-node" cx="100" cy="42" r="7"/>
<circle class="sutol-med-04-node" cx="170" cy="100" r="7"/>
</g>
<circle class="sutol-med-04-dot" r="5" fill="#065f46"/>
</svg>
</div>
```

---

## Bileşen 5: Gen Tedavisi — DNA Onarımı

**Etiketler:** gen tedavisi, kişiselleştirilmiş tıp, onkoloji
**Kategori:** Sağlık / Tıp
**Açıklama:** Kırık bir noktası onarılan, dönerek yenilenen bir DNA sarmalı.

```html
<div class="sutol-med-05-root">
<style>
.sutol-med-05-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-05-root svg{width:100%;height:100%;display:block}
.sutol-med-05-rung{animation:sutol-med-05-twist 2.4s ease-in-out infinite}
.sutol-med-05-rung:nth-child(2){animation-delay:.2s}
.sutol-med-05-rung:nth-child(3){animation-delay:.4s}
.sutol-med-05-rung:nth-child(4){animation-delay:.6s}
.sutol-med-05-rung:nth-child(5){animation-delay:.8s}
@keyframes sutol-med-05-twist{0%,100%{transform:scaleX(1)}50%{transform:scaleX(-1)}}
@media (prefers-reduced-motion: reduce){.sutol-med-05-rung{animation-duration:8s}}
</style>
<svg viewBox="0 0 200 200">
<path d="M70,20 C110,50 30,90 70,120 C110,150 30,170 70,190" fill="none" stroke="#38bdf8" stroke-width="3"/>
<path d="M130,20 C90,50 170,90 130,120 C90,150 170,170 130,190" fill="none" stroke="#a78bfa" stroke-width="3"/>
<g stroke-width="3" stroke-linecap="round">
<line class="sutol-med-05-rung" x1="75" y1="40" x2="125" y2="40" stroke="#34d399" transform-origin="100 40"/>
<line class="sutol-med-05-rung" x1="55" y1="75" x2="145" y2="75" stroke="#fbbf24" transform-origin="100 75"/>
<line class="sutol-med-05-rung" x1="75" y1="105" x2="125" y2="105" stroke="#34d399" transform-origin="100 105"/>
<line class="sutol-med-05-rung" x1="55" y1="140" x2="145" y2="140" stroke="#fbbf24" transform-origin="100 140"/>
<line class="sutol-med-05-rung" x1="75" y1="170" x2="125" y2="170" stroke="#34d399" transform-origin="100 170"/>
</g>
</svg>
</div>
```

---

## Bileşen 6: CRISPR — Gen Kesme/Yapıştırma

**Etiketler:** gen tedavisi, kişiselleştirilmiş tıp, immünoloji
**Kategori:** Sağlık / Tıp
**Açıklama:** Bir DNA şeridi üzerinde belirli bir bölgeyi kesip yerine yenisini ekleyen soyut makas sembolü.

```html
<div class="sutol-med-06-root">
<style>
.sutol-med-06-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-06-root svg{width:100%;height:100%;display:block}
.sutol-med-06-scissor{animation:sutol-med-06-snip 3s ease-in-out infinite}
@keyframes sutol-med-06-snip{0%,20%{transform:translateY(0) rotate(0deg)}30%{transform:translateY(6px) rotate(8deg)}45%{transform:translateY(0) rotate(0deg)}100%{transform:translateY(0) rotate(0deg)}}
.sutol-med-06-gap{animation:sutol-med-06-fill 3s ease-in-out infinite}
@keyframes sutol-med-06-fill{0%,45%{opacity:0;transform:scale(.4)}65%,100%{opacity:1;transform:scale(1)}}
@media (prefers-reduced-motion: reduce){.sutol-med-06-scissor,.sutol-med-06-gap{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<line x1="20" y1="100" x2="180" y2="100" stroke="#94a3b8" stroke-width="6" stroke-linecap="round"/>
<g class="sutol-med-06-gap" transform-origin="100 100">
<rect x="88" y="88" width="24" height="24" rx="4" fill="#f472b6"/>
</g>
<g class="sutol-med-06-scissor" transform-origin="100 70">
<path d="M90,40 L100,70 L110,40" fill="none" stroke="#0ea5e9" stroke-width="5" stroke-linecap="round"/>
</g>
</svg>
</div>
```

---

## Bileşen 7: Kişiselleştirilmiş Tıp — Genetik Profil

**Etiketler:** kişiselleştirilmiş tıp, gen tedavisi, epidemiyoloji
**Kategori:** Sağlık / Tıp
**Açıklama:** Bireysel veri noktalarının bir profil etrafında yavaşça beliren bir genetik harita.

```html
<div class="sutol-med-07-root">
<style>
.sutol-med-07-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-07-root svg{width:100%;height:100%;display:block}
.sutol-med-07-ring{transform-origin:100px 100px;animation:sutol-med-07-spin 16s linear infinite}
@keyframes sutol-med-07-spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}
.sutol-med-07-mark{animation:sutol-med-07-appear 3.6s ease-in-out infinite}
.sutol-med-07-mark:nth-child(2){animation-delay:.6s}
.sutol-med-07-mark:nth-child(3){animation-delay:1.2s}
.sutol-med-07-mark:nth-child(4){animation-delay:1.8s}
@keyframes sutol-med-07-appear{0%,100%{opacity:.25}50%{opacity:1}}
@media (prefers-reduced-motion: reduce){.sutol-med-07-ring{animation-duration:40s}.sutol-med-07-mark{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<circle cx="100" cy="100" r="40" fill="#e0e7ff"/>
<circle cx="100" cy="100" r="28" fill="#818cf8"/>
<g class="sutol-med-07-ring">
<circle class="sutol-med-07-mark" cx="100" cy="35" r="5" fill="#6366f1"/>
<circle class="sutol-med-07-mark" cx="165" cy="100" r="5" fill="#a855f7"/>
<circle class="sutol-med-07-mark" cx="100" cy="165" r="5" fill="#ec4899"/>
<circle class="sutol-med-07-mark" cx="35" cy="100" r="5" fill="#22d3ee"/>
</g>
</svg>
</div>
```

---

## Bileşen 8: Telemedikal Hizmet

**Etiketler:** telemedikal hizmet, kişiselleştirilmiş tıp, epidemiyoloji
**Kategori:** Sağlık / Tıp
**Açıklama:** Bir ekran üzerinden akan nabız sinyaliyle kurulan uzaktan sağlık bağlantısı.

```html
<div class="sutol-med-08-root">
<style>
.sutol-med-08-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-med-08-root svg{width:100%;height:100%;display:block}
.sutol-med-08-pulse{stroke-dasharray:220;animation:sutol-med-08-draw 2.6s linear infinite}
@keyframes sutol-med-08-draw{0%{stroke-dashoffset:220}100%{stroke-dashoffset:-220}}
.sutol-med-08-signal{animation:sutol-med-08-wave 2.4s ease-out infinite}
.sutol-med-08-signal:nth-child(2){animation-delay:.8s}
@keyframes sutol-med-08-wave{0%{opacity:.6;transform:scale(1)}100%{opacity:0;transform:scale(1.6)}}
@media (prefers-reduced-motion: reduce){.sutol-med-08-pulse{animation-duration:9s}.sutol-med-08-signal{animation-duration:8s}}
</style>
<svg viewBox="0 0 200 200">
<rect x="40" y="50" width="120" height="90" rx="10" fill="#e2e8f0"/>
<rect x="52" y="62" width="96" height="66" rx="4" fill="#0f172a"/>
<polyline class="sutol-med-08-pulse" points="55,95 75,95 85,75 95,115 105,95 148,95" fill="none" stroke="#34d399" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<circle class="sutol-med-08-signal" cx="170" cy="40" r="6" fill="none" stroke="#38bdf8" stroke-width="2"/>
<circle class="sutol-med-08-signal" cx="170" cy="40" r="6" fill="none" stroke="#38bdf8" stroke-width="2"/>
</svg>
</div>
```

---

## Bileşen 9: Klinik Deney — Laboratuvar Tüpleri

**Etiketler:** klinik deney, gen tedavisi, immünoloji
**Kategori:** Sağlık / Tıp
**Açıklama:** İçinde sıvı seviyesi yavaşça değişen, kaynayan üç deney tüpü sırası.

```html
<div class="sutol-med-09-root">
<style>
.sutol-med-09-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-09-root svg{width:100%;height:100%;display:block}
.sutol-med-09-liquid{animation:sutol-med-09-bubble 2.8s ease-in-out infinite}
.sutol-med-09-liquid:nth-child(2){animation-delay:.4s}
.sutol-med-09-liquid:nth-child(3){animation-delay:.8s}
@keyframes sutol-med-09-bubble{0%,100%{transform:translateY(0)}50%{transform:translateY(-4px)}}
@media (prefers-reduced-motion: reduce){.sutol-med-09-liquid{animation-duration:8s}}
</style>
<svg viewBox="0 0 200 200">
<g>
<path d="M60,40 L60,110 C60,135 90,135 90,110 L90,40" fill="none" stroke="#94a3b8" stroke-width="3"/>
<clipPath id="sutol-med-09-clip1"><path d="M60,90 L60,110 C60,135 90,135 90,110 L90,90 Z"/></clipPath>
<rect class="sutol-med-09-liquid" x="58" y="80" width="34" height="60" fill="#5eead4" clip-path="url(#sutol-med-09-clip1)"/>
</g>
<g>
<path d="M95,55 L95,110 C95,135 125,135 125,110 L125,55" fill="none" stroke="#94a3b8" stroke-width="3"/>
<clipPath id="sutol-med-09-clip2"><path d="M95,95 L95,110 C95,135 125,135 125,110 L125,95 Z"/></clipPath>
<rect class="sutol-med-09-liquid" x="93" y="85" width="34" height="60" fill="#a78bfa" clip-path="url(#sutol-med-09-clip2)"/>
</g>
<g>
<path d="M130,45 L130,110 C130,135 160,135 160,110 L160,45" fill="none" stroke="#94a3b8" stroke-width="3"/>
<clipPath id="sutol-med-09-clip3"><path d="M130,92 L130,110 C130,135 160,135 160,110 L160,92 Z"/></clipPath>
<rect class="sutol-med-09-liquid" x="128" y="82" width="34" height="60" fill="#fca5a5" clip-path="url(#sutol-med-09-clip3)"/>
</g>
</svg>
</div>
```

---

## Bileşen 10: Klinik Deney — Veri İzleme Grafiği

**Etiketler:** klinik deney, epidemiyoloji, kişiselleştirilmiş tıp
**Kategori:** Sağlık / Tıp
**Açıklama:** Sürekli güncellenen çubuklarla ilerleyen bir klinik veri/sonuç grafiği.

```html
<div class="sutol-med-10-root">
<style>
.sutol-med-10-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-10-root svg{width:100%;height:100%;display:block}
.sutol-med-10-bar{transform-origin:bottom;animation:sutol-med-10-grow 3s ease-in-out infinite}
.sutol-med-10-bar:nth-child(2){animation-delay:.3s}
.sutol-med-10-bar:nth-child(3){animation-delay:.6s}
.sutol-med-10-bar:nth-child(4){animation-delay:.9s}
.sutol-med-10-bar:nth-child(5){animation-delay:1.2s}
@keyframes sutol-med-10-grow{0%,100%{transform:scaleY(0.5)}50%{transform:scaleY(1)}}
@media (prefers-reduced-motion: reduce){.sutol-med-10-bar{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<line x1="30" y1="160" x2="180" y2="160" stroke="#cbd5e1" stroke-width="2"/>
<g fill="#0ea5e9">
<rect class="sutol-med-10-bar" x="40" y="100" width="18" height="60" transform-origin="49 160"/>
<rect class="sutol-med-10-bar" x="68" y="80" width="18" height="80" transform-origin="77 160"/>
<rect class="sutol-med-10-bar" x="96" y="60" width="18" height="100" transform-origin="105 160"/>
<rect class="sutol-med-10-bar" x="124" y="90" width="18" height="70" transform-origin="133 160"/>
<rect class="sutol-med-10-bar" x="152" y="70" width="18" height="90" transform-origin="161 160"/>
</g>
</svg>
</div>
```

---

## Bileşen 11: Resüsitasyon — Defibrilatör Nabzı

**Etiketler:** resüsitasyon, yoğun bakım, cerrahi robot
**Kategori:** Sağlık / Tıp
**Açıklama:** Ekranda düzenli olarak akan, umut veren bir kalp atış hattı (EKG) çizgisi.

```html
<div class="sutol-med-11-root">
<style>
.sutol-med-11-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-med-11-root svg{width:100%;height:100%;display:block}
.sutol-med-11-line{stroke-dasharray:400;animation:sutol-med-11-draw 2.4s linear infinite}
@keyframes sutol-med-11-draw{0%{stroke-dashoffset:400}100%{stroke-dashoffset:0}}
.sutol-med-11-dot{animation:sutol-med-11-blink 2.4s ease-in-out infinite}
@keyframes sutol-med-11-blink{0%,100%{opacity:.3}50%{opacity:1}}
@media (prefers-reduced-motion: reduce){.sutol-med-11-line{animation-duration:9s}.sutol-med-11-dot{animation-duration:6s}}
</style>
<svg viewBox="0 0 200 200">
<rect x="20" y="70" width="160" height="60" rx="8" fill="#0f172a"/>
<polyline class="sutol-med-11-line" points="30,100 60,100 70,80 80,120 90,60 100,140 110,100 170,100" fill="none" stroke="#4ade80" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
<circle class="sutol-med-11-dot" cx="100" cy="45" r="5" fill="#f87171"/>
</svg>
</div>
```

---

## Bileşen 12: Yoğun Bakım — Vital Bulgular Monitörü

**Etiketler:** yoğun bakım, resüsitasyon, geriatri
**Kategori:** Sağlık / Tıp
**Açıklama:** Nabız, oksijen ve tansiyon değerlerini gösteren sakin ve düzenli izleme ekranı.

```html
<div class="sutol-med-12-root">
<style>
.sutol-med-12-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-med-12-root svg{width:100%;height:100%;display:block}
.sutol-med-12-l1{stroke-dasharray:180;animation:sutol-med-12-d1 3s linear infinite}
.sutol-med-12-l2{stroke-dasharray:180;animation:sutol-med-12-d2 3.6s linear infinite}
@keyframes sutol-med-12-d1{to{stroke-dashoffset:-180}}
@keyframes sutol-med-12-d2{to{stroke-dashoffset:-180}}
@media (prefers-reduced-motion: reduce){.sutol-med-12-l1,.sutol-med-12-l2{animation-duration:10s}}
</style>
<svg viewBox="0 0 200 200">
<rect x="25" y="45" width="150" height="110" rx="10" fill="#0f172a"/>
<polyline class="sutol-med-12-l1" points="35,90 60,90 68,70 78,100 88,90 165,90" fill="none" stroke="#38bdf8" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
<polyline class="sutol-med-12-l2" points="35,125 80,125 90,110 100,140 110,125 165,125" fill="none" stroke="#facc15" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
</div>
```

---

## Bileşen 13: Palyatif Bakım — Şefkat Sembolü

**Etiketler:** palyatif bakım, geriatri, immünoloji
**Kategori:** Sağlık / Tıp
**Açıklama:** Bir kalbi nazikçe saran ve koruyan iki el şeklinde, yumuşak ışıyan bir bakım sembolü.

```html
<div class="sutol-med-13-root">
<style>
.sutol-med-13-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-13-root svg{width:100%;height:100%;display:block}
.sutol-med-13-glow{animation:sutol-med-13-breathe 4s ease-in-out infinite}
@keyframes sutol-med-13-breathe{0%,100%{opacity:.35;transform:scale(1)}50%{opacity:.7;transform:scale(1.08)}}
.sutol-med-13-heart{animation:sutol-med-13-soft 4s ease-in-out infinite}
@keyframes sutol-med-13-soft{0%,100%{transform:scale(1)}50%{transform:scale(1.05)}}
@media (prefers-reduced-motion: reduce){.sutol-med-13-glow,.sutol-med-13-heart{animation-duration:10s}}
</style>
<svg viewBox="0 0 200 200">
<circle class="sutol-med-13-glow" cx="100" cy="100" r="60" fill="#fde68a" transform-origin="100 100"/>
<path class="sutol-med-13-heart" d="M100,115 C80,95 72,78 86,68 C94,62 100,70 100,76 C100,70 106,62 114,68 C128,78 120,95 100,115 Z" fill="#fb7185" transform-origin="100 100"/>
<path d="M40,140 C60,110 60,90 80,90" fill="none" stroke="#f59e0b" stroke-width="6" stroke-linecap="round" opacity="0.6"/>
<path d="M160,140 C140,110 140,90 120,90" fill="none" stroke="#f59e0b" stroke-width="6" stroke-linecap="round" opacity="0.6"/>
</svg>
</div>
```

---

## Bileşen 14: Geriatri — Yaşam Döngüsü Saati

**Etiketler:** geriatri, palyatif bakım, epidemiyoloji
**Kategori:** Sağlık / Tıp
**Açıklama:** Yavaşça dönen ibresiyle yaşam evrelerini sembolize eden zarif bir saat çemberi.

```html
<div class="sutol-med-14-root">
<style>
.sutol-med-14-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-14-root svg{width:100%;height:100%;display:block}
.sutol-med-14-hand{transform-origin:100px 100px;animation:sutol-med-14-tick 12s linear infinite}
@keyframes sutol-med-14-tick{from{transform:rotate(0)}to{transform:rotate(360deg)}}
@media (prefers-reduced-motion: reduce){.sutol-med-14-hand{animation-duration:40s}}
</style>
<svg viewBox="0 0 200 200">
<circle cx="100" cy="100" r="65" fill="none" stroke="#c4b5fd" stroke-width="3"/>
<g stroke="#a78bfa" stroke-width="2">
<line x1="100" y1="35" x2="100" y2="45"/>
<line x1="165" y1="100" x2="155" y2="100"/>
<line x1="100" y1="165" x2="100" y2="155"/>
<line x1="35" y1="100" x2="45" y2="100"/>
</g>
<line class="sutol-med-14-hand" x1="100" y1="100" x2="100" y2="55" stroke="#7c3aed" stroke-width="4" stroke-linecap="round"/>
<circle cx="100" cy="100" r="6" fill="#6d28d9"/>
</svg>
</div>
```

---

## Bileşen 15: Onkoloji — Hücre Bölünmesi

**Etiketler:** onkoloji, gen tedavisi, immünoloji
**Kategori:** Sağlık / Tıp
**Açıklama:** İki yeni hücreye ayrılan ve tekrar birleşen döngüsel bir hücre bölünmesi animasyonu.

```html
<div class="sutol-med-15-root">
<style>
.sutol-med-15-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-15-root svg{width:100%;height:100%;display:block}
.sutol-med-15-a{animation:sutol-med-15-split-a 4s ease-in-out infinite}
.sutol-med-15-b{animation:sutol-med-15-split-b 4s ease-in-out infinite}
@keyframes sutol-med-15-split-a{0%,15%{transform:translateX(0)}60%,100%{transform:translateX(-24px)}}
@keyframes sutol-med-15-split-b{0%,15%{transform:translateX(0)}60%,100%{transform:translateX(24px)}}
@media (prefers-reduced-motion: reduce){.sutol-med-15-a,.sutol-med-15-b{animation-duration:10s}}
</style>
<svg viewBox="0 0 200 200">
<circle class="sutol-med-15-a" cx="100" cy="100" r="26" fill="#fca5a5" opacity="0.85"/>
<circle class="sutol-med-15-b" cx="100" cy="100" r="26" fill="#fdba74" opacity="0.85"/>
</svg>
</div>
```

---

## Bileşen 16: Onkoloji — Hedefli Tedavi

**Etiketler:** onkoloji, immünoloji, kişiselleştirilmiş tıp
**Kategori:** Sağlık / Tıp
**Açıklama:** Bir hedefe doğru yönlenip kilitlenen soyut bir tedavi molekülü.

```html
<div class="sutol-med-16-root">
<style>
.sutol-med-16-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-med-16-root svg{width:100%;height:100%;display:block}
.sutol-med-16-mol{offset-path:path('M20,20 C80,60 60,120 100,100');animation:sutol-med-16-move 3s ease-in infinite}
@keyframes sutol-med-16-move{0%{offset-distance:0%;opacity:0}15%{opacity:1}90%{opacity:1}100%{offset-distance:100%;opacity:0}}
.sutol-med-16-target{animation:sutol-med-16-ring 3s ease-in-out infinite}
@keyframes sutol-med-16-ring{0%,80%,100%{r:22;opacity:.4}90%{r:26;opacity:.9}}
@media (prefers-reduced-motion: reduce){.sutol-med-16-mol,.sutol-med-16-target{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<circle class="sutol-med-16-target" cx="100" cy="100" r="22" fill="none" stroke="#ef4444" stroke-width="3"/>
<circle cx="100" cy="100" r="10" fill="#dc2626"/>
<circle class="sutol-med-16-mol" r="6" fill="#3b82f6"/>
</svg>
</div>
```

---

## Bileşen 17: İmmünoloji — Antikor Bağlanması

**Etiketler:** immünoloji, gen tedavisi, epidemiyoloji
**Kategori:** Sağlık / Tıp
**Açıklama:** Y şeklindeki bir antikorun bir antijene yaklaşıp kilitlendiği döngüsel animasyon.

```html
<div class="sutol-med-17-root">
<style>
.sutol-med-17-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-17-root svg{width:100%;height:100%;display:block}
.sutol-med-17-ab{animation:sutol-med-17-approach 3.2s ease-in-out infinite}
@keyframes sutol-med-17-approach{0%,20%{transform:translate(-30px,-20px) rotate(-15deg)}55%,100%{transform:translate(0,0) rotate(0deg)}}
@media (prefers-reduced-motion: reduce){.sutol-med-17-ab{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<circle cx="110" cy="120" r="20" fill="#fb923c"/>
<g class="sutol-med-17-ab" transform-origin="90 80">
<line x1="90" y1="80" x2="90" y2="110" stroke="#2563eb" stroke-width="4" stroke-linecap="round"/>
<line x1="90" y1="80" x2="72" y2="58" stroke="#2563eb" stroke-width="4" stroke-linecap="round"/>
<line x1="90" y1="80" x2="108" y2="58" stroke="#2563eb" stroke-width="4" stroke-linecap="round"/>
</g>
</svg>
</div>
```

---

## Bileşen 18: İmmünoloji — Bağışıklık Hücresi Devriyesi

**Etiketler:** immünoloji, epidemiyoloji, yoğun bakım
**Kategori:** Sağlık / Tıp
**Açıklama:** Damar benzeri bir yol boyunca dolaşan koruyucu bir bağışıklık hücresi.

```html
<div class="sutol-med-18-root">
<style>
.sutol-med-18-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-med-18-root svg{width:100%;height:100%;display:block}
.sutol-med-18-cell{offset-path:path('M20,140 C60,60 140,60 180,140');animation:sutol-med-18-patrol 4s linear infinite alternate}
@keyframes sutol-med-18-patrol{0%{offset-distance:0%}100%{offset-distance:100%}}
@media (prefers-reduced-motion: reduce){.sutol-med-18-cell{animation-duration:12s}}
</style>
<svg viewBox="0 0 200 200">
<path d="M20,140 C60,60 140,60 180,140" fill="none" stroke="#fecaca" stroke-width="10" opacity="0.4"/>
<circle class="sutol-med-18-cell" r="9" fill="#f472b6"/>
</svg>
</div>
```

---

## Bileşen 19: Epidemiyoloji — Hastalık Yayılım Ağı

**Etiketler:** epidemiyoloji, immünoloji, telemedikal hizmet
**Kategori:** Sağlık / Tıp
**Açıklama:** Bir merkezden dışa doğru sırayla aydınlanan, ağ üzerinde yayılan soyut bir bulaş modeli.

```html
<div class="sutol-med-19-root">
<style>
.sutol-med-19-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-med-19-root svg{width:100%;height:100%;display:block}
.sutol-med-19-n{animation:sutol-med-19-spread 3.6s ease-in-out infinite}
.sutol-med-19-n:nth-child(2){animation-delay:.3s}
.sutol-med-19-n:nth-child(3){animation-delay:.6s}
.sutol-med-19-n:nth-child(4){animation-delay:.9s}
.sutol-med-19-n:nth-child(5){animation-delay:1.2s}
.sutol-med-19-n:nth-child(6){animation-delay:1.5s}
@keyframes sutol-med-19-spread{0%,100%{opacity:.25;r:3}40%{opacity:1;r:6}}
@media (prefers-reduced-motion: reduce){.sutol-med-19-n{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<g stroke="#fca5a5" stroke-width="1" opacity="0.4">
<line x1="100" y1="100" x2="100" y2="40"/>
<line x1="100" y1="100" x2="155" y2="70"/>
<line x1="100" y1="100" x2="155" y2="130"/>
<line x1="100" y1="100" x2="100" y2="160"/>
<line x1="100" y1="100" x2="45" y2="130"/>
<line x1="100" y1="100" x2="45" y2="70"/>
</g>
<circle cx="100" cy="100" r="7" fill="#dc2626"/>
<g fill="#f87171">
<circle class="sutol-med-19-n" cx="100" cy="40" r="4"/>
<circle class="sutol-med-19-n" cx="155" cy="70" r="4"/>
<circle class="sutol-med-19-n" cx="155" cy="130" r="4"/>
<circle class="sutol-med-19-n" cx="100" cy="160" r="4"/>
<circle class="sutol-med-19-n" cx="45" cy="130" r="4"/>
<circle class="sutol-med-19-n" cx="45" cy="70" r="4"/>
</g>
</svg>
</div>
```

---

## Bileşen 20: Epidemiyoloji — Salgın Eğrisi

**Etiketler:** epidemiyoloji, klinik deney, telemedikal hizmet
**Kategori:** Sağlık / Tıp
**Açıklama:** Yükselip düzleşen ve tekrar başa dönen, sakinleştirici bir salgın eğrisi çizgisi.

```html
<div class="sutol-med-20-root">
<style>
.sutol-med-20-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-med-20-root svg{width:100%;height:100%;display:block}
.sutol-med-20-curve{stroke-dasharray:300;animation:sutol-med-20-draw 4s ease-in-out infinite}
@keyframes sutol-med-20-draw{0%{stroke-dashoffset:300}55%{stroke-dashoffset:0}100%{stroke-dashoffset:-300}}
.sutol-med-20-dot{offset-path:path('M25,150 C60,150 70,60 100,60 C130,60 140,150 175,150');animation:sutol-med-20-move 4s ease-in-out infinite}
@keyframes sutol-med-20-move{0%{offset-distance:0%;opacity:0}10%{opacity:1}90%{opacity:1}100%{offset-distance:100%;opacity:0}}
@media (prefers-reduced-motion: reduce){.sutol-med-20-curve,.sutol-med-20-dot{animation-duration:11s}}
</style>
<svg viewBox="0 0 200 200">
<line x1="25" y1="150" x2="175" y2="150" stroke="#cbd5e1" stroke-width="2"/>
<path class="sutol-med-20-curve" d="M25,150 C60,150 70,60 100,60 C130,60 140,150 175,150" fill="none" stroke="#0891b2" stroke-width="3"/>
<circle class="sutol-med-20-dot" r="5" fill="#0e7490"/>
</svg>
</div>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Biyopsi): `translateY` iğne hareketi + gecikmeli örnek parlaması; hafif.
- Bileşen 2 (Cerrahi Robot): Çift eklemli `rotate` animasyonu, farklı fazlarda; hafif.
- Bileşen 3 (Organ Nakli/Kalp): `scale` nabız atışı + `stroke-dashoffset` akış çizgisi; hafif.
- Bileşen 4 (Bağış Zinciri): `offset-path` ile eğri yol boyunca hareket eden aktarım noktası; modern tarayıcı özelliği.
- Bileşen 5 (Gen Tedavisi/DNA): Kademeli `scaleX` ters çevirme ile 3B sarmal illüzyonu; orta yoğunluk.
- Bileşen 6 (CRISPR): `rotate/translateY` makas hareketi + gecikmeli `scale` doldurma; hafif.
- Bileşen 7 (Kişiselleştirilmiş Tıp): Grup `rotate` + kademeli opaklık nabzı; hafif.
- Bileşen 8 (Telemedikal Hizmet): `stroke-dashoffset` ile EKG çizgisi çizimi + genişleyen sinyal halkaları; hafif.
- Bileşen 9 (Klinik Deney/Tüpler): `clip-path` + `translateY` ile kaynayan sıvı efekti; orta yoğunluk.
- Bileşen 10 (Klinik Deney/Grafik): Kademeli gecikmeli `scaleY` çubuk büyümesi; hafif.
- Bileşen 11 (Resüsitasyon): `stroke-dashoffset` ile sürekli akan EKG çizgisi; hafif.
- Bileşen 12 (Yoğun Bakım): İki bağımsız hızda akan monitör çizgisi; hafif.
- Bileşen 13 (Palyatif Bakım): Yumuşak `scale` nefes alma + sabit soyut sembolizm; hafif, rahatsız edici içerik yok.
- Bileşen 14 (Geriatri): Tek yönlü yavaş `rotate` saat ibresi; çok hafif.
- Bileşen 15 (Onkoloji/Bölünme): Karşıt yönlü `translateX` ayrışma döngüsü; hafif.
- Bileşen 16 (Onkoloji/Hedefli Tedavi): `offset-path` molekül hareketi + `r` genişlemesi; hafif.
- Bileşen 17 (İmmünoloji/Antikor): `translate+rotate` yaklaşma animasyonu; hafif.
- Bileşen 18 (İmmünoloji/Devriye): `offset-path` ile `alternate` gidiş-geliş hareketi; hafif.
- Bileşen 19 (Epidemiyoloji/Ağ): Kademeli gecikmeli `r/opacity` yayılma nabzı; hafif.
- Bileşen 20 (Epidemiyoloji/Eğri): `stroke-dashoffset` eğri çizimi + `offset-path` takip noktası; hafif.

Tüm bileşenler: tek dosya, şeffaf arka plan, `viewBox` tabanlı ölçeklenebilirlik, `prefers-reduced-motion` desteği, sandbox uyumlu (dış istek/localStorage/cookie yok), kapsüllenmiş `.sutol-med-NN-*` sınıf adlandırması ile teslim edilmiştir. Hassas temalar (resüsitasyon, yoğun bakım, palyatif bakım) bilinçli olarak soyut/sembolik biçimde, klinik açıdan rahatsız edici detaylardan kaçınılarak tasarlanmıştır.
