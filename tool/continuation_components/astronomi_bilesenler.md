# Astronomi / Uzay — 20 Animasyonlu HTML Bileşeni (Sutol)

---

## Bileşen 1: Pulsar (Nötron Yıldızı)

**Etiketler (keyword eşleşmesi için):** nötron yıldızı, pulsar, manyetosfer, kozmik arka plan ışıması
**Kategori:** Astronomi / Uzay
**Açıklama:** Etrafından dönen iki ışın huzmesiyle nabız atan yoğun bir nötron yıldızı çekirdeği.

```html
<div class="sutol-ast-01-root">
<style>
.sutol-ast-01-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-01-root svg{width:100%;height:100%;display:block}
.sutol-ast-01-beam{transform-origin:100px 100px;animation:sutol-ast-01-spin 3s linear infinite}
.sutol-ast-01-core{animation:sutol-ast-01-pulse 1.1s ease-in-out infinite}
@keyframes sutol-ast-01-spin{from{transform:rotate(0deg)}to{transform:rotate(360deg)}}
@keyframes sutol-ast-01-pulse{0%,100%{r:6;opacity:.85}50%{r:10;opacity:1}}
@media (prefers-reduced-motion: reduce){
  .sutol-ast-01-beam{animation-duration:14s}
  .sutol-ast-01-core{animation-duration:5s}
}
</style>
<svg viewBox="0 0 200 200">
<defs>
<linearGradient id="sutol-ast-01-g1" x1="0" y1="0" x2="0" y2="1">
<stop offset="0%" stop-color="#93c5fd" stop-opacity="0.55"/>
<stop offset="100%" stop-color="#93c5fd" stop-opacity="0"/>
</linearGradient>
</defs>
<g class="sutol-ast-01-beam">
<polygon points="100,100 66,4 134,4" fill="url(#sutol-ast-01-g1)"/>
<polygon points="100,100 66,196 134,196" fill="url(#sutol-ast-01-g1)"/>
</g>
<circle cx="100" cy="100" r="26" fill="none" stroke="#3b82f6" stroke-width="1" opacity="0.3"/>
<circle class="sutol-ast-01-core" cx="100" cy="100" r="7" fill="#eff6ff" stroke="#60a5fa" stroke-width="2"/>
</svg>
</div>
```

---

## Bileşen 2: Beyaz Cüce

**Etiketler:** beyaz cüce, sönümlenen yıldız, manyetosfer
**Kategori:** Astronomi / Uzay
**Açıklama:** Küçük, çok parlak ve yoğun bir yıldızın etrafında yavaşça sönümlenen ışık halkaları.

```html
<div class="sutol-ast-02-root">
<style>
.sutol-ast-02-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-02-root svg{width:100%;height:100%;display:block}
.sutol-ast-02-ring{animation:sutol-ast-02-fade 3s ease-out infinite}
.sutol-ast-02-ring:nth-child(2){animation-delay:1s}
.sutol-ast-02-ring:nth-child(3){animation-delay:2s}
.sutol-ast-02-core{animation:sutol-ast-02-glow 2.4s ease-in-out infinite}
@keyframes sutol-ast-02-fade{0%{r:10;opacity:.7;stroke-width:2}100%{r:70;opacity:0;stroke-width:.5}}
@keyframes sutol-ast-02-glow{0%,100%{filter:brightness(1)}50%{filter:brightness(1.3)}}
@media (prefers-reduced-motion: reduce){.sutol-ast-02-ring{animation-duration:9s}.sutol-ast-02-core{animation-duration:6s}}
</style>
<svg viewBox="0 0 200 200">
<g fill="none" stroke="#e2e8f0">
<circle class="sutol-ast-02-ring" cx="100" cy="100" r="10"/>
<circle class="sutol-ast-02-ring" cx="100" cy="100" r="10"/>
<circle class="sutol-ast-02-ring" cx="100" cy="100" r="10"/>
</g>
<circle class="sutol-ast-02-core" cx="100" cy="100" r="9" fill="#f8fafc" stroke="#cbd5e1" stroke-width="2"/>
</svg>
</div>
```

---

## Bileşen 3: Kırmızı Dev

**Etiketler:** kırmızı dev, yıldız, manyetosfer
**Kategori:** Astronomi / Uzay
**Açıklama:** Yavaşça genişleyip büzülen, sıcak turuncu-kırmızı tonlarda dev bir yıldız yüzeyi.

```html
<div class="sutol-ast-03-root">
<style>
.sutol-ast-03-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-03-root svg{width:100%;height:100%;display:block}
.sutol-ast-03-body{animation:sutol-ast-03-breathe 4s ease-in-out infinite;transform-origin:100px 100px}
.sutol-ast-03-flare{animation:sutol-ast-03-flicker 2.6s ease-in-out infinite}
@keyframes sutol-ast-03-breathe{0%,100%{transform:scale(1)}50%{transform:scale(1.08)}}
@keyframes sutol-ast-03-flicker{0%,100%{opacity:.5}50%{opacity:.9}}
@media (prefers-reduced-motion: reduce){.sutol-ast-03-body{animation-duration:10s}.sutol-ast-03-flare{animation-duration:8s}}
</style>
<svg viewBox="0 0 200 200">
<defs>
<radialGradient id="sutol-ast-03-g1" cx="40%" cy="35%" r="65%">
<stop offset="0%" stop-color="#fed7aa"/>
<stop offset="55%" stop-color="#f97316"/>
<stop offset="100%" stop-color="#b91c1c"/>
</radialGradient>
</defs>
<circle class="sutol-ast-03-flare" cx="100" cy="100" r="70" fill="#f97316" opacity="0.15"/>
<circle class="sutol-ast-03-body" cx="100" cy="100" r="50" fill="url(#sutol-ast-03-g1)"/>
</svg>
</div>
```

---

## Bileşen 4: Karanlık Madde Ağı

**Etiketler:** karanlık madde, galaksi, kozmik arka plan ışıması
**Kategori:** Astronomi / Uzay
**Açıklama:** Görünmez bir iskelet gibi birbirine bağlı, yavaşça titreşen kozmik ağ düğümleri.

```html
<div class="sutol-ast-04-root">
<style>
.sutol-ast-04-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-04-root svg{width:100%;height:100%;display:block}
.sutol-ast-04-node{animation:sutol-ast-04-pulse 3.5s ease-in-out infinite}
.sutol-ast-04-node:nth-child(2n){animation-delay:.6s}
.sutol-ast-04-node:nth-child(3n){animation-delay:1.2s}
.sutol-ast-04-link{stroke-dasharray:4 3;animation:sutol-ast-04-flow 6s linear infinite}
@keyframes sutol-ast-04-pulse{0%,100%{opacity:.4;r:3}50%{opacity:1;r:5}}
@keyframes sutol-ast-04-flow{to{stroke-dashoffset:-140}}
@media (prefers-reduced-motion: reduce){.sutol-ast-04-node,.sutol-ast-04-link{animation-duration:12s}}
</style>
<svg viewBox="0 0 200 200">
<g class="sutol-ast-04-link" stroke="#a78bfa" stroke-width="1" opacity="0.45" fill="none">
<path d="M30,40 L90,70 L150,35 L170,110 L110,150 L60,140 L30,40 M90,70 L60,140 M150,35 L110,150"/>
</g>
<g fill="#c4b5fd">
<circle class="sutol-ast-04-node" cx="30" cy="40" r="4"/>
<circle class="sutol-ast-04-node" cx="90" cy="70" r="4"/>
<circle class="sutol-ast-04-node" cx="150" cy="35" r="4"/>
<circle class="sutol-ast-04-node" cx="170" cy="110" r="4"/>
<circle class="sutol-ast-04-node" cx="110" cy="150" r="4"/>
<circle class="sutol-ast-04-node" cx="60" cy="140" r="4"/>
</g>
</svg>
</div>
```

---

## Bileşen 5: Karanlık Enerji — Genişleyen Evren

**Etiketler:** karanlık enerji, kırmızıya kayma, kozmik arka plan ışıması
**Kategori:** Astronomi / Uzay
**Açıklama:** Merkezden dışa doğru sürekli gerilip yayılan bir uzay-zaman ızgarası.

```html
<div class="sutol-ast-05-root">
<style>
.sutol-ast-05-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-ast-05-root svg{width:100%;height:100%;display:block}
.sutol-ast-05-grid{transform-origin:100px 100px;animation:sutol-ast-05-expand 3.2s ease-out infinite}
@keyframes sutol-ast-05-expand{0%{transform:scale(0.3);opacity:0}60%{opacity:.6}100%{transform:scale(1.6);opacity:0}}
.sutol-ast-05-grid:nth-child(2){animation-delay:1.6s}
@media (prefers-reduced-motion: reduce){.sutol-ast-05-grid{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<g class="sutol-ast-05-grid" fill="none" stroke="#22d3ee" stroke-width="1">
<path d="M20,20 L180,20 L180,180 L20,180 Z M20,60 L180,60 M20,100 L180,100 M20,140 L180,140 M60,20 L60,180 M100,20 L100,180 M140,20 L140,180"/>
</g>
<g class="sutol-ast-05-grid" fill="none" stroke="#67e8f9" stroke-width="1">
<path d="M20,20 L180,20 L180,180 L20,180 Z M20,60 L180,60 M20,100 L180,100 M20,140 L180,140 M60,20 L60,180 M100,20 L100,180 M140,20 L140,180"/>
</g>
</svg>
</div>
```

---

## Bileşen 6: Exoplanet ve Yaşanabilir Bölge

**Etiketler:** exoplanet, yaşanabilir bölge, güneş rüzgarı
**Kategori:** Astronomi / Uzay
**Açıklama:** Merkez yıldızın yeşil "yaşanabilir bölge" kuşağında yörüngede dönen küçük bir gezegen.

```html
<div class="sutol-ast-06-root">
<style>
.sutol-ast-06-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-06-root svg{width:100%;height:100%;display:block}
.sutol-ast-06-orbit{transform-origin:100px 100px;animation:sutol-ast-06-spin 6s linear infinite}
@keyframes sutol-ast-06-spin{from{transform:rotate(0deg)}to{transform:rotate(360deg)}}
.sutol-ast-06-star{animation:sutol-ast-06-glow 2.2s ease-in-out infinite}
@keyframes sutol-ast-06-glow{0%,100%{opacity:.8}50%{opacity:1}}
@media (prefers-reduced-motion: reduce){.sutol-ast-06-orbit{animation-duration:20s}}
</style>
<svg viewBox="0 0 200 200">
<circle cx="100" cy="100" r="55" fill="none" stroke="#4ade80" stroke-width="14" opacity="0.18"/>
<circle cx="100" cy="100" r="55" fill="none" stroke="#86efac" stroke-width="1" stroke-dasharray="3 4"/>
<circle class="sutol-ast-06-star" cx="100" cy="100" r="14" fill="#fde68a"/>
<g class="sutol-ast-06-orbit">
<circle cx="155" cy="100" r="6" fill="#2563eb"/>
</g>
</svg>
</div>
```

---

## Bileşen 7: Güneş Rüzgarı ve Manyetosfer

**Etiketler:** güneş rüzgarı, manyetosfer, exoplanet
**Kategori:** Astronomi / Uzay
**Açıklama:** Bir gezegeni koruyan eğri manyetik alan çizgileri boyunca akan parçacıkların saptırılması.

```html
<div class="sutol-ast-07-root">
<style>
.sutol-ast-07-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-ast-07-root svg{width:100%;height:100%;display:block}
.sutol-ast-07-particle{offset-rotate:0deg;animation:sutol-ast-07-move 3s linear infinite}
.sutol-ast-07-particle:nth-child(2){animation-delay:1s}
.sutol-ast-07-particle:nth-child(3){animation-delay:2s}
@keyframes sutol-ast-07-move{0%{offset-distance:0%;opacity:0}10%{opacity:1}90%{opacity:1}100%{offset-distance:100%;opacity:0}}
@media (prefers-reduced-motion: reduce){.sutol-ast-07-particle{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<path id="sutol-ast-07-path" d="M-10,100 C40,20 70,20 100,100 C130,180 160,180 210,100" fill="none" stroke="#38bdf8" stroke-width="1.5" opacity="0.45"/>
<circle cx="100" cy="100" r="22" fill="#1d4ed8"/>
<g fill="#7dd3fc">
<circle class="sutol-ast-07-particle" r="3" style="offset-path:path('M-10,100 C40,20 70,20 100,100 C130,180 160,180 210,100')"/>
<circle class="sutol-ast-07-particle" r="3" style="offset-path:path('M-10,100 C40,20 70,20 100,100 C130,180 160,180 210,100')"/>
<circle class="sutol-ast-07-particle" r="3" style="offset-path:path('M-10,100 C40,20 70,20 100,100 C130,180 160,180 210,100')"/>
</g>
</svg>
</div>
```

---

## Bileşen 8: Güneş Lekesi ve Alevlenme

**Etiketler:** güneş lekesi, güneş rüzgarı, manyetosfer
**Kategori:** Astronomi / Uzay
**Açıklama:** Yüzeyinde koyu lekeler beliren ve zaman zaman alevlenme fırlatan bir güneş diski.

```html
<div class="sutol-ast-08-root">
<style>
.sutol-ast-08-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-08-root svg{width:100%;height:100%;display:block}
.sutol-ast-08-sun{transform-origin:100px 100px;animation:sutol-ast-08-rotate 18s linear infinite}
@keyframes sutol-ast-08-rotate{from{transform:rotate(0)}to{transform:rotate(360deg)}}
.sutol-ast-08-spot{animation:sutol-ast-08-appear 4s ease-in-out infinite}
.sutol-ast-08-spot:nth-child(2){animation-delay:1.3s}
.sutol-ast-08-spot:nth-child(3){animation-delay:2.6s}
@keyframes sutol-ast-08-appear{0%,100%{opacity:.2}50%{opacity:.8}}
.sutol-ast-08-flare{animation:sutol-ast-08-burst 3s ease-out infinite}
@keyframes sutol-ast-08-burst{0%{transform:scale(0.4);opacity:0}30%{opacity:.7}100%{transform:scale(1.4);opacity:0}}
@media (prefers-reduced-motion: reduce){.sutol-ast-08-sun{animation-duration:40s}.sutol-ast-08-spot,.sutol-ast-08-flare{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<defs>
<radialGradient id="sutol-ast-08-g1" cx="50%" cy="50%" r="60%">
<stop offset="0%" stop-color="#fef08a"/>
<stop offset="100%" stop-color="#f59e0b"/>
</radialGradient>
</defs>
<g class="sutol-ast-08-sun">
<circle cx="100" cy="100" r="55" fill="url(#sutol-ast-08-g1)"/>
<ellipse class="sutol-ast-08-spot" cx="80" cy="90" rx="6" ry="4" fill="#7c2d12"/>
<ellipse class="sutol-ast-08-spot" cx="120" cy="110" rx="5" ry="3" fill="#7c2d12"/>
<ellipse class="sutol-ast-08-spot" cx="95" cy="125" rx="4" ry="3" fill="#7c2d12"/>
</g>
<circle class="sutol-ast-08-flare" cx="145" cy="80" r="10" fill="none" stroke="#fb923c" stroke-width="3"/>
</svg>
</div>
```

---

## Bileşen 9: Kuiper Kuşağı

**Etiketler:** kuiper kuşağı, oort bulutu, gezegen halkası
**Kategori:** Astronomi / Uzay
**Açıklama:** Güneş sisteminin dış kesiminde sabit bir yörüngede dönen buzlu cisimler kuşağı.

```html
<div class="sutol-ast-09-root">
<style>
.sutol-ast-09-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-09-root svg{width:100%;height:100%;display:block}
.sutol-ast-09-belt{transform-origin:100px 100px;animation:sutol-ast-09-spin 26s linear infinite}
@keyframes sutol-ast-09-spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}
@media (prefers-reduced-motion: reduce){.sutol-ast-09-belt{animation-duration:60s}}
</style>
<svg viewBox="0 0 200 200">
<circle cx="100" cy="100" r="16" fill="#fbbf24"/>
<circle cx="100" cy="100" r="65" fill="none" stroke="#94a3b8" stroke-width="1" opacity="0.35" stroke-dasharray="1 6"/>
<g class="sutol-ast-09-belt" fill="#cbd5e1">
<circle cx="165" cy="100" r="2.5"/><circle cx="155" cy="130" r="2"/><circle cx="120" cy="160" r="2.5"/>
<circle cx="80" cy="162" r="2"/><circle cx="45" cy="135" r="2.5"/><circle cx="35" cy="100" r="2"/>
<circle cx="48" cy="65" r="2.5"/><circle cx="82" cy="40" r="2"/><circle cx="120" cy="42" r="2.5"/><circle cx="155" cy="68" r="2"/>
</g>
</svg>
</div>
```

---

## Bileşen 10: Oort Bulutu

**Etiketler:** oort bulutu, kuiper kuşağı, karanlık madde
**Kategori:** Astronomi / Uzay
**Açıklama:** Güneş sistemini kuşatan geniş, dağınık ve çok yavaş dönen kürevi bir kuyrukluyıldız bulutu.

```html
<div class="sutol-ast-10-root">
<style>
.sutol-ast-10-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-10-root svg{width:100%;height:100%;display:block}
.sutol-ast-10-cloud{transform-origin:100px 100px;animation:sutol-ast-10-drift 40s linear infinite}
@keyframes sutol-ast-10-drift{from{transform:rotate(0)}to{transform:rotate(360deg)}}
.sutol-ast-10-tw{animation:sutol-ast-10-twinkle 3s ease-in-out infinite}
.sutol-ast-10-tw:nth-child(3n){animation-delay:.9s}
.sutol-ast-10-tw:nth-child(4n){animation-delay:1.8s}
@keyframes sutol-ast-10-twinkle{0%,100%{opacity:.25}50%{opacity:.75}}
@media (prefers-reduced-motion: reduce){.sutol-ast-10-cloud{animation-duration:80s}.sutol-ast-10-tw{animation-duration:7s}}
</style>
<svg viewBox="0 0 200 200">
<circle cx="100" cy="100" r="10" fill="#fbbf24"/>
<circle cx="100" cy="100" r="85" fill="none" stroke="#818cf8" stroke-width="1" opacity="0.15"/>
<g class="sutol-ast-10-cloud" fill="#a5b4fc">
<circle class="sutol-ast-10-tw" cx="100" cy="16" r="2"/><circle class="sutol-ast-10-tw" cx="160" cy="45" r="2"/>
<circle class="sutol-ast-10-tw" cx="184" cy="100" r="2"/><circle class="sutol-ast-10-tw" cx="160" cy="155" r="2"/>
<circle class="sutol-ast-10-tw" cx="100" cy="184" r="2"/><circle class="sutol-ast-10-tw" cx="40" cy="155" r="2"/>
<circle class="sutol-ast-10-tw" cx="16" cy="100" r="2"/><circle class="sutol-ast-10-tw" cx="40" cy="45" r="2"/>
<circle class="sutol-ast-10-tw" cx="130" cy="30" r="1.5"/><circle class="sutol-ast-10-tw" cx="170" cy="130" r="1.5"/>
<circle class="sutol-ast-10-tw" cx="70" cy="170" r="1.5"/><circle class="sutol-ast-10-tw" cx="30" cy="70" r="1.5"/>
</g>
</svg>
</div>
```

---

## Bileşen 11: Spiral Galaksi

**Etiketler:** spiral galaksi, galaksi çarpışması, karanlık madde
**Kategori:** Astronomi / Uzay
**Açıklama:** Merkezinde parlayan çekirdeği olan, yavaşça dönen bir spiral galaksi kolu.

```html
<div class="sutol-ast-11-root">
<style>
.sutol-ast-11-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-11-root svg{width:100%;height:100%;display:block}
.sutol-ast-11-spiral{transform-origin:100px 100px;animation:sutol-ast-11-spin 30s linear infinite}
@keyframes sutol-ast-11-spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}
.sutol-ast-11-core{animation:sutol-ast-11-glow 2.5s ease-in-out infinite}
@keyframes sutol-ast-11-glow{0%,100%{opacity:.8}50%{opacity:1}}
@media (prefers-reduced-motion: reduce){.sutol-ast-11-spiral{animation-duration:70s}}
</style>
<svg viewBox="0 0 200 200">
<g class="sutol-ast-11-spiral" fill="none" stroke="#c4b5fd" stroke-width="3" stroke-linecap="round" opacity="0.6">
<path d="M100,100 C130,90 150,60 130,35 C110,12 75,20 65,45"/>
<path d="M100,100 C70,110 50,140 70,165 C90,188 125,180 135,155"/>
</g>
<circle class="sutol-ast-11-core" cx="100" cy="100" r="10" fill="#f5f3ff"/>
</svg>
</div>
```

---

## Bileşen 12: Galaksi Çarpışması

**Etiketler:** galaksi çarpışması, spiral galaksi, karanlık madde
**Kategori:** Astronomi / Uzay
**Açıklama:** Birbirine yaklaşıp kesişerek yeniden ayrılan iki galaksi çekirdeğinin döngüsel dansı.

```html
<div class="sutol-ast-12-root">
<style>
.sutol-ast-12-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-ast-12-root svg{width:100%;height:100%;display:block}
.sutol-ast-12-a{animation:sutol-ast-12-move-a 6s ease-in-out infinite}
.sutol-ast-12-b{animation:sutol-ast-12-move-b 6s ease-in-out infinite}
@keyframes sutol-ast-12-move-a{0%,100%{transform:translate(-30px,0)}50%{transform:translate(10px,0)}}
@keyframes sutol-ast-12-move-b{0%,100%{transform:translate(30px,0)}50%{transform:translate(-10px,0)}}
@media (prefers-reduced-motion: reduce){.sutol-ast-12-a,.sutol-ast-12-b{animation-duration:16s}}
</style>
<svg viewBox="0 0 200 200">
<g class="sutol-ast-12-a" opacity="0.75">
<circle cx="100" cy="90" r="7" fill="#fbcfe8"/>
<ellipse cx="100" cy="90" rx="30" ry="10" fill="none" stroke="#f9a8d4" stroke-width="2"/>
</g>
<g class="sutol-ast-12-b" opacity="0.75">
<circle cx="100" cy="110" r="7" fill="#bfdbfe"/>
<ellipse cx="100" cy="110" rx="30" ry="10" fill="none" stroke="#93c5fd" stroke-width="2"/>
</g>
</svg>
</div>
```

---

## Bileşen 13: Kırmızıya Kayma (Redshift)

**Etiketler:** kırmızıya kayma, karanlık enerji, radyo teleskop
**Kategori:** Astronomi / Uzay
**Açıklama:** Kaynaktan uzaklaştıkça dalga boyu uzayan ve renk tonu maviden kırmızıya kayan ışık dalgaları.

```html
<div class="sutol-ast-13-root">
<style>
.sutol-ast-13-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-ast-13-root svg{width:100%;height:100%;display:block}
.sutol-ast-13-wave{animation:sutol-ast-13-travel 3.4s linear infinite}
.sutol-ast-13-wave:nth-child(2){animation-delay:1.1s}
.sutol-ast-13-wave:nth-child(3){animation-delay:2.2s}
@keyframes sutol-ast-13-travel{0%{transform:translateX(0) scaleX(1);opacity:0;stroke:#60a5fa}
20%{opacity:.8}
100%{transform:translateX(90px) scaleX(1.6);opacity:0;stroke:#ef4444}}
@media (prefers-reduced-motion: reduce){.sutol-ast-13-wave{animation-duration:10s}}
</style>
<svg viewBox="0 0 200 200">
<circle cx="35" cy="100" r="9" fill="#fde68a"/>
<g fill="none" stroke-width="2">
<path class="sutol-ast-13-wave" d="M50,100 Q60,80 70,100 Q80,120 90,100"/>
<path class="sutol-ast-13-wave" d="M50,100 Q60,80 70,100 Q80,120 90,100"/>
<path class="sutol-ast-13-wave" d="M50,100 Q60,80 70,100 Q80,120 90,100"/>
</g>
</svg>
</div>
```

---

## Bileşen 14: Kozmik Mikrodalga Arka Plan Işıması

**Etiketler:** kozmik arka plan ışıması, karanlık enerji, karanlık madde
**Kategori:** Astronomi / Uzay
**Açıklama:** Tüm evreni kaplayan, yavaşça dalgalanan benekli ilkel ışıma dokusu (canvas tabanlı gürültü).

```html
<div class="sutol-ast-14-root">
<style>
.sutol-ast-14-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;border-radius:8px;overflow:hidden}
.sutol-ast-14-root canvas{width:100%;height:100%;display:block}
@media (prefers-reduced-motion: reduce){.sutol-ast-14-root canvas{opacity:0.9}}
</style>
<canvas class="sutol-ast-14-cv" width="200" height="200"></canvas>
<script>
(function(){
  var root = document.currentScript.parentElement;
  var cv = root.querySelector('.sutol-ast-14-cv');
  var ctx = cv.getContext('2d');
  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var cols = 14, rows = 14, cw = 200/cols, ch = 200/rows;
  var seeds = [];
  for(var i=0;i<cols*rows;i++){ seeds.push(Math.random()*Math.PI*2); }
  var palette = ['#312e81','#4338ca','#6366f1','#818cf8','#c7d2fe'];
  var start = null;
  function frame(ts){
    if(start===null) start = ts;
    var t = reduced ? 0 : (ts-start)/1000;
    ctx.clearRect(0,0,200,200);
    for(var y=0;y<rows;y++){
      for(var x=0;x<cols;x++){
        var idx = y*cols+x;
        var v = (Math.sin(seeds[idx]+t*0.5)+1)/2;
        var c = palette[Math.floor(v*(palette.length-1))];
        ctx.fillStyle = c;
        ctx.globalAlpha = 0.35 + v*0.4;
        ctx.fillRect(x*cw, y*ch, cw+0.5, ch+0.5);
      }
    }
    ctx.globalAlpha = 1;
    if(!reduced) requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);
})();
</script>
</div>
```

---

## Bileşen 15: Radyo Teleskop

**Etiketler:** radyo teleskop, uydu takımyıldızı, kozmik arka plan ışıması
**Kategori:** Astronomi / Uzay
**Açıklama:** Uzaydan gelen sinyalleri yakalamak için yavaşça dönen ve halka dalgalar yayan bir çanak anten.

```html
<div class="sutol-ast-15-root">
<style>
.sutol-ast-15-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-15-root svg{width:100%;height:100%;display:block}
.sutol-ast-15-dish{transform-origin:100px 130px;animation:sutol-ast-15-tilt 5s ease-in-out infinite}
@keyframes sutol-ast-15-tilt{0%,100%{transform:rotate(-8deg)}50%{transform:rotate(8deg)}}
.sutol-ast-15-wave{animation:sutol-ast-15-out 2.6s ease-out infinite}
.sutol-ast-15-wave:nth-child(2){animation-delay:.9s}
.sutol-ast-15-wave:nth-child(3){animation-delay:1.8s}
@keyframes sutol-ast-15-out{0%{r:8;opacity:.7}100%{r:40;opacity:0}}
@media (prefers-reduced-motion: reduce){.sutol-ast-15-dish{animation-duration:14s}.sutol-ast-15-wave{animation-duration:8s}}
</style>
<svg viewBox="0 0 200 200">
<g fill="none" stroke="#5eead4" stroke-width="1.5">
<circle class="sutol-ast-15-wave" cx="70" cy="60" r="8"/>
<circle class="sutol-ast-15-wave" cx="70" cy="60" r="8"/>
<circle class="sutol-ast-15-wave" cx="70" cy="60" r="8"/>
</g>
<g class="sutol-ast-15-dish">
<path d="M60,130 C60,105 80,90 100,90 C120,90 140,105 140,130 Z" fill="#e2e8f0"/>
<line x1="100" y1="90" x2="100" y2="60" stroke="#94a3b8" stroke-width="3"/>
<circle cx="100" cy="58" r="4" fill="#94a3b8"/>
</g>
<line x1="100" y1="130" x2="100" y2="175" stroke="#64748b" stroke-width="6"/>
</svg>
</div>
```

---

## Bileşen 16: Kaçış Hızı

**Etiketler:** kaçış hızı, uzay yürüyüşü, uydu takımyıldızı
**Kategori:** Astronomi / Uzay
**Açıklama:** Bir gezegenin çekim alanından ateş izi bırakarak hızla uzaklaşan bir roket.

```html
<div class="sutol-ast-16-root">
<style>
.sutol-ast-16-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-ast-16-root svg{width:100%;height:100%;display:block}
.sutol-ast-16-rocket{animation:sutol-ast-16-launch 2.6s ease-in infinite}
@keyframes sutol-ast-16-launch{0%{transform:translate(0,0) rotate(-35deg);opacity:0}
10%{opacity:1}
90%{opacity:1}
100%{transform:translate(-70px,-130px) rotate(-35deg);opacity:0}}
@media (prefers-reduced-motion: reduce){.sutol-ast-16-rocket{animation-duration:9s}}
</style>
<svg viewBox="0 0 200 200">
<circle cx="100" cy="185" r="55" fill="#1e3a8a" opacity="0.5"/>
<g class="sutol-ast-16-rocket">
<g transform="translate(120,140)">
<path d="M0,-22 C8,-10 8,10 0,20 C-8,10 -8,-10 0,-22 Z" fill="#f1f5f9"/>
<path d="M0,20 L-6,30 L0,26 L6,30 Z" fill="#fb923c"/>
<circle cx="0" cy="-4" r="4" fill="#38bdf8"/>
</g>
</g>
</svg>
</div>
```

---

## Bileşen 17: Uzay Yürüyüşü

**Etiketler:** uzay yürüyüşü, kaçış hızı, uydu takımyıldızı
**Kategori:** Astronomi / Uzay
**Açıklama:** İpe bağlı halde boşlukta yavaşça süzülen bir astronot silüeti.

```html
<div class="sutol-ast-17-root">
<style>
.sutol-ast-17-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-17-root svg{width:100%;height:100%;display:block}
.sutol-ast-17-astro{animation:sutol-ast-17-float 5s ease-in-out infinite}
@keyframes sutol-ast-17-float{0%,100%{transform:translate(0,0) rotate(-4deg)}50%{transform:translate(6px,-10px) rotate(4deg)}}
.sutol-ast-17-tether{stroke-dasharray:3 3;animation:sutol-ast-17-flow 4s linear infinite}
@keyframes sutol-ast-17-flow{to{stroke-dashoffset:-40}}
@media (prefers-reduced-motion: reduce){.sutol-ast-17-astro{animation-duration:12s}.sutol-ast-17-tether{animation-duration:10s}}
</style>
<svg viewBox="0 0 200 200">
<path class="sutol-ast-17-tether" d="M40,170 C70,140 90,120 110,95" fill="none" stroke="#94a3b8" stroke-width="1.5"/>
<rect x="20" y="165" width="20" height="14" rx="2" fill="#475569"/>
<g class="sutol-ast-17-astro">
<circle cx="115" cy="85" r="16" fill="#f8fafc" stroke="#94a3b8" stroke-width="2"/>
<rect x="100" y="98" width="30" height="34" rx="10" fill="#e2e8f0" stroke="#94a3b8" stroke-width="2"/>
<circle cx="115" cy="85" r="9" fill="#38bdf8" opacity="0.5"/>
</g>
</svg>
</div>
```

---

## Bileşen 18: Uydu Takımyıldızı

**Etiketler:** uydu takımyıldızı, radyo teleskop, kaçış hızı
**Kategori:** Astronomi / Uzay
**Açıklama:** Bir gezegen etrafında farklı yörüngelerde eş zamanlı dönen küçük uydular ağı.

```html
<div class="sutol-ast-18-root">
<style>
.sutol-ast-18-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-18-root svg{width:100%;height:100%;display:block}
.sutol-ast-18-o1{transform-origin:100px 100px;animation:sutol-ast-18-spin 4s linear infinite}
.sutol-ast-18-o2{transform-origin:100px 100px;animation:sutol-ast-18-spin 6s linear infinite reverse}
.sutol-ast-18-o3{transform-origin:100px 100px;animation:sutol-ast-18-spin 8s linear infinite}
@keyframes sutol-ast-18-spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}
@media (prefers-reduced-motion: reduce){.sutol-ast-18-o1,.sutol-ast-18-o2,.sutol-ast-18-o3{animation-duration:20s}}
</style>
<svg viewBox="0 0 200 200">
<circle cx="100" cy="100" r="20" fill="#2563eb"/>
<circle cx="100" cy="100" r="40" fill="none" stroke="#93c5fd" stroke-width="1" opacity="0.4"/>
<circle cx="100" cy="100" r="60" fill="none" stroke="#93c5fd" stroke-width="1" opacity="0.3"/>
<circle cx="100" cy="100" r="80" fill="none" stroke="#93c5fd" stroke-width="1" opacity="0.2"/>
<g class="sutol-ast-18-o1"><circle cx="140" cy="100" r="4" fill="#fbbf24"/></g>
<g class="sutol-ast-18-o2"><circle cx="160" cy="100" r="4" fill="#f472b6"/></g>
<g class="sutol-ast-18-o3"><circle cx="180" cy="100" r="4" fill="#34d399"/></g>
</svg>
</div>
```

---

## Bileşen 19: Meteor Yağmuru

**Etiketler:** meteor yağmuru, ay kraterleri, gezegen halkası
**Kategori:** Astronomi / Uzay
**Açıklama:** Gece gökyüzünde birbiri ardına çizgiler halinde kayan meteorlar.

```html
<div class="sutol-ast-19-root">
<style>
.sutol-ast-19-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px;overflow:hidden}
.sutol-ast-19-root svg{width:100%;height:100%;display:block}
.sutol-ast-19-m{animation:sutol-ast-19-streak 2s linear infinite}
.sutol-ast-19-m:nth-child(2){animation-delay:.5s}
.sutol-ast-19-m:nth-child(3){animation-delay:1s}
.sutol-ast-19-m:nth-child(4){animation-delay:1.5s}
@keyframes sutol-ast-19-streak{0%{transform:translate(-40px,-40px);opacity:0}10%{opacity:1}55%{opacity:1}70%{transform:translate(70px,70px);opacity:0}100%{transform:translate(70px,70px);opacity:0}}
@media (prefers-reduced-motion: reduce){.sutol-ast-19-m{animation-duration:7s}}
</style>
<svg viewBox="0 0 200 200">
<g stroke-linecap="round">
<line class="sutol-ast-19-m" x1="30" y1="30" x2="55" y2="55" stroke="#fef08a" stroke-width="2"/>
<line class="sutol-ast-19-m" x1="80" y1="20" x2="105" y2="45" stroke="#fef08a" stroke-width="2"/>
<line class="sutol-ast-19-m" x1="120" y1="35" x2="145" y2="60" stroke="#fef08a" stroke-width="2"/>
<line class="sutol-ast-19-m" x1="150" y1="10" x2="175" y2="35" stroke="#fef08a" stroke-width="2"/>
</g>
</svg>
</div>
```

---

## Bileşen 20: Ay Kraterleri ve Gezegen Halkası

**Etiketler:** ay kraterleri, gezegen halkası, kuiper kuşağı
**Kategori:** Astronomi / Uzay
**Açıklama:** Kraterli bir ayın önünden, tozdan oluşan halkasıyla birlikte yavaşça dönen bir gezegen.

```html
<div class="sutol-ast-20-root">
<style>
.sutol-ast-20-root{position:relative;width:100%;height:100%;min-width:80px;min-height:80px}
.sutol-ast-20-root svg{width:100%;height:100%;display:block}
.sutol-ast-20-planet{transform-origin:120px 100px;animation:sutol-ast-20-rotate 22s linear infinite}
@keyframes sutol-ast-20-rotate{from{transform:rotate(0)}to{transform:rotate(360deg)}}
.sutol-ast-20-moon{animation:sutol-ast-20-drift 7s ease-in-out infinite}
@keyframes sutol-ast-20-drift{0%,100%{transform:translate(0,0)}50%{transform:translate(-6px,4px)}}
@media (prefers-reduced-motion: reduce){.sutol-ast-20-planet{animation-duration:50s}.sutol-ast-20-moon{animation-duration:14s}}
</style>
<svg viewBox="0 0 200 200">
<g class="sutol-ast-20-moon">
<circle cx="55" cy="130" r="26" fill="#cbd5e1"/>
<circle cx="46" cy="122" r="4" fill="#94a3b8" opacity="0.6"/>
<circle cx="62" cy="135" r="3" fill="#94a3b8" opacity="0.6"/>
<circle cx="50" cy="140" r="2.5" fill="#94a3b8" opacity="0.6"/>
</g>
<g class="sutol-ast-20-planet">
<ellipse cx="120" cy="100" rx="52" ry="14" fill="none" stroke="#fbbf24" stroke-width="5" opacity="0.55"/>
<circle cx="120" cy="100" r="30" fill="#fb923c"/>
<ellipse cx="120" cy="100" rx="52" ry="14" fill="none" stroke="#fde68a" stroke-width="2" opacity="0.8"/>
</g>
</svg>
</div>
```

---

## Kalite Kontrol Özeti

- Bileşen 1 (Pulsar): SVG `transform-origin` ile dönen ışın huzmesi + `r` özniteliği animasyonu; hafif, 60fps.
- Bileşen 2 (Beyaz Cüce): Kademeli gecikmeli `stroke`/`opacity` halka animasyonu; düşük maliyetli.
- Bileşen 3 (Kırmızı Dev): `transform: scale` nefes alma efekti, radyal gradyan; GPU dostu.
- Bileşen 4 (Karanlık Madde): `stroke-dasharray/dashoffset` akış animasyonu + düğüm nabzı; orta yoğunluk.
- Bileşen 5 (Karanlık Enerji): İç içe `scale` genişleme döngüsü; sade ızgara deseni.
- Bileşen 6 (Exoplanet): Dairesel `rotate` yörünge animasyonu; sabit maliyetli.
- Bileşen 7 (Güneş Rüzgarı): CSS `offset-path` ile eğri yol boyunca parçacık hareketi; modern tarayıcı özelliği.
- Bileşen 8 (Güneş Lekesi): Katmanlı rotasyon + opaklık titreşimi + patlama animasyonu; orta yoğunluk.
- Bileşen 9 (Kuiper Kuşağı): Grup halinde yavaş `rotate`; çok hafif.
- Bileşen 10 (Oort Bulutu): Geniş yarıçaplı yavaş rotasyon + titreşen yıldızlar; hafif.
- Bileşen 11 (Spiral Galaksi): SVG path spiral kollar + yavaş dönüş; hafif.
- Bileşen 12 (Galaksi Çarpışması): Karşıt `translate` döngüleri ile yaklaşma/uzaklaşma; hafif.
- Bileşen 13 (Kırmızıya Kayma): `translateX/scaleX` ile dalga gerilmesi ve renk geçişi; orta.
- Bileşen 14 (Kozmik Arka Plan Işıması): Tek JS/Canvas tabanlı bileşen, `requestAnimationFrame` ile gürültü deseni; `prefers-reduced-motion` durumunda döngü durur (en yoğun bileşen, düşük çözünürlüklü grid ile optimize edildi).
- Bileşen 15 (Radyo Teleskop): Çanak `rotate` sallanması + genişleyen dalga halkaları; hafif.
- Bileşen 16 (Kaçış Hızı): `translate + rotate` ile roket fırlatma döngüsü; hafif.
- Bileşen 17 (Uzay Yürüyüşü): Serbest `translate/rotate` süzülme + `dashoffset` halat akışı; hafif.
- Bileşen 18 (Uydu Takımyıldızı): Üç farklı hız/yönde eşzamanlı `rotate` yörüngeleri; hafif.
- Bileşen 19 (Meteor Yağmuru): Gecikmeli `translate` çizgi kayması, çoklu eleman; hafif.
- Bileşen 20 (Ay Kraterleri / Gezegen Halkası): Kombine `rotate` + `translate` iki katmanlı hareket; hafif.

Tüm bileşenler: tek dosya, şeffaf arka plan, `viewBox` tabanlı ölçeklenebilirlik, `prefers-reduced-motion` desteği, sandbox uyumlu (dış istek/localStorage/cookie yok), kapsüllenmiş `.sutol-ast-NN-*` sınıf adlandırması ile teslim edilmiştir.
