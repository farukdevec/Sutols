# Fizik Kategorisi — 20 Animasyonlu Bileşen

---

## Bileşen 1: Zaman Genişlemesi

**Etiketler (keyword eşleşmesi için):** görelilik, zaman genişlemesi, uzay-zaman
**Kategori:** Fizik
**Açıklama:** İki saat, biri hızlı biri yavaş dönen akrepleriyle, göreli zaman akışındaki farkı simgeler.

```html
<div class="sutol-fiz-01-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-01-root{position:relative;width:100%;height:100%;}
.sutol-fiz-01-svg{width:100%;height:100%;display:block;}
.sutol-fiz-01-hand{transform-box:fill-box;transform-origin:center;}
.sutol-fiz-01-h1{animation:sutol-fiz-01-spin 2s linear infinite;}
.sutol-fiz-01-h2{animation:sutol-fiz-01-spin 6s linear infinite;}
.sutol-fiz-01-ring{animation:sutol-fiz-01-pulse 4s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
@keyframes sutol-fiz-01-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
@keyframes sutol-fiz-01-pulse{0%,100%{opacity:.55;}50%{opacity:1;}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-01-h1,.sutol-fiz-01-h2{animation-duration:16s;}
  .sutol-fiz-01-ring{animation:none;opacity:.8;}
}
</style>
<svg class="sutol-fiz-01-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <circle class="sutol-fiz-01-ring" cx="90" cy="100" r="55" fill="none" stroke="#7dd3fc" stroke-width="4"/>
  <circle cx="90" cy="100" r="45" fill="none" stroke="#0ea5e9" stroke-width="3"/>
  <line class="sutol-fiz-01-hand sutol-fiz-01-h1" x1="90" y1="100" x2="90" y2="65" stroke="#0369a1" stroke-width="4" stroke-linecap="round"/>
  <circle cx="90" cy="100" r="4" fill="#0369a1"/>

  <circle class="sutol-fiz-01-ring" cx="210" cy="100" r="55" fill="none" stroke="#fca5a5" stroke-width="4"/>
  <circle cx="210" cy="100" r="45" fill="none" stroke="#ef4444" stroke-width="3"/>
  <line class="sutol-fiz-01-hand sutol-fiz-01-h2" x1="210" y1="100" x2="210" y2="70" stroke="#991b1b" stroke-width="4" stroke-linecap="round"/>
  <circle cx="210" cy="100" r="4" fill="#991b1b"/>
</svg>
</div>
```

---

## Bileşen 2: Uzay-Zaman Eğriliği ve Kütle Çekim Dalgaları

**Etiketler (keyword eşleşmesi için):** uzay-zaman, kütle çekim dalgası, görelilik
**Kategori:** Fizik
**Açıklama:** Merkezdeki kütlenin büktüğü bir ızgara ve dışa doğru yayılan çekim dalgası halkaları.

```html
<div class="sutol-fiz-02-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-02-root{position:relative;width:100%;height:100%;}
.sutol-fiz-02-svg{width:100%;height:100%;display:block;}
.sutol-fiz-02-wave{transform-box:fill-box;transform-origin:center;animation:sutol-fiz-02-ripple 3.6s ease-out infinite;}
.sutol-fiz-02-wave:nth-child(1){animation-delay:0s;}
.sutol-fiz-02-wave:nth-child(2){animation-delay:1.2s;}
.sutol-fiz-02-wave:nth-child(3){animation-delay:2.4s;}
.sutol-fiz-02-core{animation:sutol-fiz-02-glow 2.4s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
@keyframes sutol-fiz-02-ripple{0%{transform:scale(.15);opacity:.9;}100%{transform:scale(1.4);opacity:0;}}
@keyframes sutol-fiz-02-glow{0%,100%{opacity:.7;}50%{opacity:1;}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-02-wave{animation:none;opacity:.25;}
  .sutol-fiz-02-core{animation:none;}
}
</style>
<svg class="sutol-fiz-02-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#a78bfa" stroke-width="1.4" fill="none" opacity=".5">
    <path d="M20,150 Q150,190 280,150"/>
    <path d="M20,110 Q150,160 280,110"/>
    <path d="M20,190 Q150,220 280,190"/>
    <path d="M60,40 Q100,150 60,260"/>
    <path d="M240,40 Q200,150 240,260"/>
    <path d="M150,40 Q150,150 150,260"/>
  </g>
  <circle class="sutol-fiz-02-wave" cx="150" cy="150" r="30" fill="none" stroke="#c4b5fd" stroke-width="2.5"/>
  <circle class="sutol-fiz-02-wave" cx="150" cy="150" r="30" fill="none" stroke="#c4b5fd" stroke-width="2.5"/>
  <circle class="sutol-fiz-02-wave" cx="150" cy="150" r="30" fill="none" stroke="#c4b5fd" stroke-width="2.5"/>
  <circle class="sutol-fiz-02-core" cx="150" cy="150" r="16" fill="#7c3aed"/>
</svg>
</div>
```

---

## Bileşen 3: Kara Cisim Işıması

**Etiketler (keyword eşleşmesi için):** kara cisim ışıması, ısı transferi, foton
**Kategori:** Fizik
**Açıklama:** Isıtıldıkça kırmızıdan beyaza dönen parlayan bir küre, sıcaklığa bağlı renk değişimini gösterir.

```html
<div class="sutol-fiz-03-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-03-root{position:relative;width:100%;height:100%;}
.sutol-fiz-03-svg{width:100%;height:100%;display:block;}
.sutol-fiz-03-orb{animation:sutol-fiz-03-heat 6s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
.sutol-fiz-03-halo{animation:sutol-fiz-03-halo 6s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
@keyframes sutol-fiz-03-heat{
  0%{fill:#7f1d1d;}
  30%{fill:#f97316;}
  60%{fill:#fde047;}
  85%{fill:#eff6ff;}
  100%{fill:#7f1d1d;}
}
@keyframes sutol-fiz-03-halo{
  0%{opacity:.15;transform:scale(1);}
  60%{opacity:.55;transform:scale(1.35);}
  100%{opacity:.15;transform:scale(1);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-03-orb{animation-duration:18s;}
  .sutol-fiz-03-halo{animation:none;opacity:.25;}
}
</style>
<svg class="sutol-fiz-03-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <circle class="sutol-fiz-03-halo" cx="150" cy="150" r="80" fill="#fb923c"/>
  <circle class="sutol-fiz-03-orb" cx="150" cy="150" r="50" fill="#f97316"/>
</svg>
</div>
```

---

## Bileşen 4: Foton — Dalga-Parçacık İkiliği

**Etiketler (keyword eşleşmesi için):** foton, dalga fonksiyonu, kırılma indisi
**Kategori:** Fizik
**Açıklama:** Sinüs eğrisi boyunca ilerleyen bir ışık parçacığı, dalga ve parçacık doğasını birlikte gösterir.

```html
<div class="sutol-fiz-04-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-04-root{position:relative;width:100%;height:100%;}
.sutol-fiz-04-svg{width:100%;height:100%;display:block;}
.sutol-fiz-04-photon{offset-path:path('M10,150 C60,60 90,240 140,150 S220,60 250,150 S290,150 290,150');animation:sutol-fiz-04-move 3.2s linear infinite;}
@keyframes sutol-fiz-04-move{0%{offset-distance:0%;}100%{offset-distance:100%;}}
.sutol-fiz-04-wave{stroke-dasharray:6 6;animation:sutol-fiz-04-dash 2.4s linear infinite;}
@keyframes sutol-fiz-04-dash{to{stroke-dashoffset:-24;}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-04-photon{animation-duration:12s;}
  .sutol-fiz-04-wave{animation:none;}
}
</style>
<svg class="sutol-fiz-04-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <path class="sutol-fiz-04-wave" d="M10,150 C60,60 90,240 140,150 S220,60 250,150 S290,150 290,150" fill="none" stroke="#38bdf8" stroke-width="2.5" opacity=".6"/>
  <circle class="sutol-fiz-04-photon" r="9" fill="#facc15"/>
</svg>
</div>
```

---

## Bileşen 5: Parçacık Hızlandırıcı

**Etiketler (keyword eşleşmesi için):** parçacık hızlandırıcı, higgs bozonu, kuark
**Kategori:** Fizik
**Açıklama:** Dairesel bir tünel içinde zıt yönlerde hızlanan iki parçacığın çarpışma noktasına ulaşması.

```html
<div class="sutol-fiz-05-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-05-root{position:relative;width:100%;height:100%;}
.sutol-fiz-05-svg{width:100%;height:100%;display:block;}
.sutol-fiz-05-p1{offset-path:path('M150,50 A100,100 0 1,1 149,50');animation:sutol-fiz-05-go 2.4s linear infinite;}
.sutol-fiz-05-p2{offset-path:path('M150,50 A100,100 0 1,0 149,50');animation:sutol-fiz-05-go 2.4s linear infinite;}
@keyframes sutol-fiz-05-go{0%{offset-distance:0%;}100%{offset-distance:100%;}}
.sutol-fiz-05-flash{animation:sutol-fiz-05-flash 2.4s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
@keyframes sutol-fiz-05-flash{0%,92%,100%{opacity:0;transform:scale(.3);}96%{opacity:1;transform:scale(1.6);}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-05-p1,.sutol-fiz-05-p2{animation-duration:9s;}
  .sutol-fiz-05-flash{animation:none;opacity:0;}
}
</style>
<svg class="sutol-fiz-05-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <circle cx="150" cy="150" r="100" fill="none" stroke="#94a3b8" stroke-width="3" stroke-dasharray="4 6" opacity=".55"/>
  <circle class="sutol-fiz-05-p1" r="7" fill="#22d3ee"/>
  <circle class="sutol-fiz-05-p2" r="7" fill="#f472b6"/>
  <circle class="sutol-fiz-05-flash" cx="150" cy="50" r="18" fill="#fde047"/>
</svg>
</div>
```

---

## Bileşen 6: Higgs Bozonu Çarpışması

**Etiketler (keyword eşleşmesi için):** higgs bozonu, parçacık hızlandırıcı, string teorisi
**Kategori:** Fizik
**Açıklama:** Merkezde çarpışan iki parçacığın enerji salarak dışa doğru ışınlar yaydığı bir patlama döngüsü.

```html
<div class="sutol-fiz-06-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-06-root{position:relative;width:100%;height:100%;}
.sutol-fiz-06-svg{width:100%;height:100%;display:block;}
.sutol-fiz-06-l{animation:sutol-fiz-06-inl 3s ease-in-out infinite;}
.sutol-fiz-06-r{animation:sutol-fiz-06-inr 3s ease-in-out infinite;}
@keyframes sutol-fiz-06-inl{0%{transform:translateX(0);}45%{transform:translateX(90px);}50%,100%{transform:translateX(0);opacity:0;}0%{opacity:1;}}
@keyframes sutol-fiz-06-inr{0%{transform:translateX(0);opacity:1;}45%{transform:translateX(-90px);}50%,100%{transform:translateX(0);opacity:0;}}
.sutol-fiz-06-ray{transform-box:fill-box;transform-origin:center;animation:sutol-fiz-06-burst 3s ease-out infinite;opacity:0;}
@keyframes sutol-fiz-06-burst{0%,48%{opacity:0;transform:scale(.2);}55%{opacity:1;}75%{opacity:0;transform:scale(1.6);}100%{opacity:0;}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-06-l,.sutol-fiz-06-r{animation-duration:9s;}
  .sutol-fiz-06-ray{animation:none;opacity:0;}
}
</style>
<svg class="sutol-fiz-06-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <g class="sutol-fiz-06-ray" stroke="#fbbf24" stroke-width="2">
    <line x1="150" y1="100" x2="150" y2="40"/>
    <line x1="150" y1="100" x2="150" y2="160"/>
    <line x1="150" y1="100" x2="90" y2="100"/>
    <line x1="150" y1="100" x2="210" y2="100"/>
    <line x1="150" y1="100" x2="110" y2="60"/>
    <line x1="150" y1="100" x2="190" y2="140"/>
  </g>
  <circle class="sutol-fiz-06-l" cx="60" cy="100" r="10" fill="#60a5fa"/>
  <circle class="sutol-fiz-06-r" cx="240" cy="100" r="10" fill="#f87171"/>
</svg>
</div>
```

---

## Bileşen 7: Kuark Üçlüsü

**Etiketler (keyword eşleşmesi için):** kuark, higgs bozonu, string teorisi
**Kategori:** Fizik
**Açıklama:** Üç renkli kuarkın birbirine dalgalı gluon çizgileriyle bağlı biçimde dönerek proton oluşturması.

```html
<div class="sutol-fiz-07-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-07-root{position:relative;width:100%;height:100%;}
.sutol-fiz-07-svg{width:100%;height:100%;display:block;}
.sutol-fiz-07-grp{transform-box:fill-box;transform-origin:150px 150px;animation:sutol-fiz-07-spin 8s linear infinite;}
@keyframes sutol-fiz-07-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
.sutol-fiz-07-q{animation:sutol-fiz-07-pulse 2.2s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
.sutol-fiz-07-q:nth-child(1){animation-delay:0s;}
.sutol-fiz-07-q:nth-child(2){animation-delay:.7s;}
.sutol-fiz-07-q:nth-child(3){animation-delay:1.4s;}
@keyframes sutol-fiz-07-pulse{0%,100%{transform:scale(1);}50%{transform:scale(1.25);}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-07-grp{animation-duration:24s;}
  .sutol-fiz-07-q{animation:none;}
}
</style>
<svg class="sutol-fiz-07-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <g class="sutol-fiz-07-grp">
    <path d="M150,110 Q120,150 150,190 Q180,150 210,190" fill="none" stroke="#a3e635" stroke-width="2" opacity=".6"/>
    <path d="M150,110 Q180,150 90,190" fill="none" stroke="#a3e635" stroke-width="2" opacity=".6"/>
    <circle class="sutol-fiz-07-q" cx="150" cy="110" r="14" fill="#ef4444"/>
    <circle class="sutol-fiz-07-q" cx="210" cy="190" r="14" fill="#22c55e"/>
    <circle class="sutol-fiz-07-q" cx="90" cy="190" r="14" fill="#3b82f6"/>
  </g>
</svg>
</div>
```

---

## Bileşen 8: String Teorisi Titreşimi

**Etiketler (keyword eşleşmesi için):** string teorisi, dalga fonksiyonu, belirsizlik ilkesi
**Kategori:** Fizik
**Açıklama:** Kapalı bir ilmeğin sürekli titreşerek biçim değiştirmesiyle temsil edilen titreşen bir kuantum sicimi.

```html
<div class="sutol-fiz-08-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-08-root{position:relative;width:100%;height:100%;}
.sutol-fiz-08-svg{width:100%;height:100%;display:block;}
.sutol-fiz-08-loop{animation:sutol-fiz-08-vibe 2.6s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
@keyframes sutol-fiz-08-vibe{
  0%,100%{d:path('M150,80 C210,80 220,140 220,150 C220,160 210,220 150,220 C90,220 80,160 80,150 C80,140 90,80 150,80 Z');}
  50%{d:path('M150,60 C230,90 240,130 210,150 C240,170 230,240 150,240 C70,240 60,170 90,150 C60,130 70,90 150,60 Z');}
}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-08-loop{animation:none;}
}
</style>
<svg class="sutol-fiz-08-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <path class="sutol-fiz-08-loop" d="M150,80 C210,80 220,140 220,150 C220,160 210,220 150,220 C90,220 80,160 80,150 C80,140 90,80 150,80 Z" fill="none" stroke="#f472b6" stroke-width="3"/>
</svg>
</div>
```

---

## Bileşen 9: Belirsizlik İlkesi

**Etiketler (keyword eşleşmesi için):** belirsizlik ilkesi, dalga fonksiyonu, kuark
**Kategori:** Fizik
**Açıklama:** Konumu bulanıklaşan bir parçacık ile netleşen momentum okunun sürekli yer değiştirmesi.

```html
<div class="sutol-fiz-09-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-09-root{position:relative;width:100%;height:100%;}
.sutol-fiz-09-svg{width:100%;height:100%;display:block;}
.sutol-fiz-09-blur{animation:sutol-fiz-09-b 3.4s ease-in-out infinite;}
.sutol-fiz-09-arrow{animation:sutol-fiz-09-a 3.4s ease-in-out infinite;transform-box:fill-box;transform-origin:left center;}
@keyframes sutol-fiz-09-b{0%,100%{opacity:.2;r:45;}50%{opacity:.8;r:14;}}
@keyframes sutol-fiz-09-a{0%,100%{opacity:.9;transform:scaleX(.3);}50%{opacity:.2;transform:scaleX(1.4);}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-09-blur,.sutol-fiz-09-arrow{animation-duration:12s;}
}
</style>
<svg class="sutol-fiz-09-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <circle class="sutol-fiz-09-blur" cx="150" cy="90" r="30" fill="#c084fc" filter="blur(3px)"/>
  <line class="sutol-fiz-09-arrow" x1="80" y1="150" x2="220" y2="150" stroke="#0ea5e9" stroke-width="4"/>
  <path class="sutol-fiz-09-arrow" d="M210,142 L226,150 L210,158 Z" fill="#0ea5e9"/>
</svg>
</div>
```

---

## Bileşen 10: Dalga Fonksiyonu Çöküşü

**Etiketler (keyword eşleşmesi için):** dalga fonksiyonu, girişim, belirsizlik ilkesi
**Kategori:** Fizik
**Açıklama:** Yayılı bir olasılık dalgasının periyodik olarak tek bir noktaya çökmesi.

```html
<div class="sutol-fiz-10-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-10-root{position:relative;width:100%;height:100%;}
.sutol-fiz-10-svg{width:100%;height:100%;display:block;}
.sutol-fiz-10-spread{animation:sutol-fiz-10-s 3.6s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
.sutol-fiz-10-point{animation:sutol-fiz-10-p 3.6s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
@keyframes sutol-fiz-10-s{0%,70%{opacity:.7;transform:scaleY(1);}90%,100%{opacity:0;transform:scaleY(.05);}}
@keyframes sutol-fiz-10-p{0%,80%{opacity:0;transform:scale(.2);}92%,100%{opacity:1;transform:scale(1);}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-10-spread,.sutol-fiz-10-point{animation-duration:14s;}
}
</style>
<svg class="sutol-fiz-10-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <path class="sutol-fiz-10-spread" d="M30,100 Q90,40 150,100 Q210,160 270,100" fill="none" stroke="#34d399" stroke-width="3"/>
  <circle class="sutol-fiz-10-point" cx="150" cy="100" r="9" fill="#059669"/>
</svg>
</div>
```

---

## Bileşen 11: Çift Yarık Girişimi

**Etiketler (keyword eşleşmesi için):** girişim, foton, dalga fonksiyonu
**Kategori:** Fizik
**Açıklama:** İki noktadan yayılan dalgaların üst üste binerek girişim saçaklarını oluşturması.

```html
<div class="sutol-fiz-11-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-11-root{position:relative;width:100%;height:100%;}
.sutol-fiz-11-svg{width:100%;height:100%;display:block;}
.sutol-fiz-11-w{transform-box:fill-box;transform-origin:center;animation:sutol-fiz-11-r 3s ease-out infinite;}
.sutol-fiz-11-w1{animation-delay:0s;}
.sutol-fiz-11-w2{animation-delay:1s;}
.sutol-fiz-11-w3{animation-delay:2s;}
@keyframes sutol-fiz-11-r{0%{transform:scale(.1);opacity:.9;}100%{transform:scale(2.6);opacity:0;}}
.sutol-fiz-11-fringe{animation:sutol-fiz-11-f 3s ease-in-out infinite;}
@keyframes sutol-fiz-11-f{0%,100%{opacity:.15;}50%{opacity:.5;}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-11-w{animation:none;opacity:.2;}
  .sutol-fiz-11-fringe{animation:none;opacity:.3;}
}
</style>
<svg class="sutol-fiz-11-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <g class="sutol-fiz-11-fringe" stroke="#fbcfe8" stroke-width="10" opacity=".3">
    <line x1="260" y1="60" x2="260" y2="240"/>
    <line x1="230" y1="60" x2="230" y2="240"/>
    <line x1="200" y1="60" x2="200" y2="240"/>
  </g>
  <circle class="sutol-fiz-11-w sutol-fiz-11-w1" cx="60" cy="110" r="30" fill="none" stroke="#f472b6" stroke-width="1.8"/>
  <circle class="sutol-fiz-11-w sutol-fiz-11-w2" cx="60" cy="110" r="30" fill="none" stroke="#f472b6" stroke-width="1.8"/>
  <circle class="sutol-fiz-11-w sutol-fiz-11-w3" cx="60" cy="110" r="30" fill="none" stroke="#f472b6" stroke-width="1.8"/>
  <circle class="sutol-fiz-11-w sutol-fiz-11-w1" cx="60" cy="190" r="30" fill="none" stroke="#f472b6" stroke-width="1.8"/>
  <circle class="sutol-fiz-11-w sutol-fiz-11-w2" cx="60" cy="190" r="30" fill="none" stroke="#f472b6" stroke-width="1.8"/>
  <circle class="sutol-fiz-11-w sutol-fiz-11-w3" cx="60" cy="190" r="30" fill="none" stroke="#f472b6" stroke-width="1.8"/>
  <rect x="50" y="60" width="8" height="35" fill="#94a3b8"/>
  <rect x="50" y="205" width="8" height="35" fill="#94a3b8"/>
  <rect x="50" y="140" width="8" height="20" fill="#94a3b8"/>
</svg>
</div>
```

---

## Bileşen 12: Kırınım Deseni

**Etiketler (keyword eşleşmesi için):** kırınım, girişim, foton
**Kategori:** Fizik
**Açıklama:** Bir engelin kenarından geçerken bükülen dalga cephelerinin sürekli yayılması.

```html
<div class="sutol-fiz-12-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-12-root{position:relative;width:100%;height:100%;}
.sutol-fiz-12-svg{width:100%;height:100%;display:block;}
.sutol-fiz-12-arc{transform-box:fill-box;transform-origin:60px 150px;animation:sutol-fiz-12-r 3.2s ease-out infinite;}
.sutol-fiz-12-arc:nth-child(2){animation-delay:.8s;}
.sutol-fiz-12-arc:nth-child(3){animation-delay:1.6s;}
.sutol-fiz-12-arc:nth-child(4){animation-delay:2.4s;}
@keyframes sutol-fiz-12-r{0%{transform:scale(.2);opacity:.9;}100%{transform:scale(2.2);opacity:0;}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-12-arc{animation:none;opacity:.25;}
}
</style>
<svg class="sutol-fiz-12-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <rect x="150" y="20" width="10" height="90" fill="#64748b"/>
  <path class="sutol-fiz-12-arc" d="M60,90 A60,60 0 0 1 60,210" fill="none" stroke="#fbbf24" stroke-width="2"/>
  <path class="sutol-fiz-12-arc" d="M60,90 A60,60 0 0 1 60,210" fill="none" stroke="#fbbf24" stroke-width="2"/>
  <path class="sutol-fiz-12-arc" d="M60,90 A60,60 0 0 1 60,210" fill="none" stroke="#fbbf24" stroke-width="2"/>
  <path class="sutol-fiz-12-arc" d="M60,90 A60,60 0 0 1 60,210" fill="none" stroke="#fbbf24" stroke-width="2"/>
</svg>
</div>
```

---

## Bileşen 13: Polarizasyon Filtresi

**Etiketler (keyword eşleşmesi için):** polarizasyon, foton, kırılma indisi
**Kategori:** Fizik
**Açıklama:** Rastgele titreşen ışık dalgasının dikey bir filtreden geçtikten sonra tek yönde titreşmesi.

```html
<div class="sutol-fiz-13-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-13-root{position:relative;width:100%;height:100%;}
.sutol-fiz-13-svg{width:100%;height:100%;display:block;}
.sutol-fiz-13-before{transform-box:fill-box;transform-origin:60px 150px;animation:sutol-fiz-13-rot 2.4s linear infinite;}
@keyframes sutol-fiz-13-rot{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
.sutol-fiz-13-after{animation:sutol-fiz-13-pulse 2.4s ease-in-out infinite;transform-box:fill-box;transform-origin:240px 150px;}
@keyframes sutol-fiz-13-pulse{0%,100%{transform:scaleY(1);}50%{transform:scaleY(.15);}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-13-before{animation-duration:10s;}
  .sutol-fiz-13-after{animation:none;}
}
</style>
<svg class="sutol-fiz-13-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <line class="sutol-fiz-13-before" x1="60" y1="120" x2="60" y2="180" stroke="#38bdf8" stroke-width="4" stroke-linecap="round"/>
  <rect x="140" y="90" width="12" height="120" fill="#475569"/>
  <line class="sutol-fiz-13-after" x1="240" y1="120" x2="240" y2="180" stroke="#38bdf8" stroke-width="4" stroke-linecap="round"/>
</svg>
</div>
```

---

## Bileşen 14: Isı Konveksiyon Hücresi

**Etiketler (keyword eşleşmesi için):** ısı transferi, konveksiyon, akışkan dinamiği
**Kategori:** Fizik
**Açıklama:** Ortada yükselen sıcak akım ve kenarlardan alçalan soğuk akımdan oluşan döngüsel bir konveksiyon hücresi.

```html
<div class="sutol-fiz-14-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-14-root{position:relative;width:100%;height:100%;}
.sutol-fiz-14-svg{width:100%;height:100%;display:block;}
.sutol-fiz-14-p{offset-path:path('M150,240 C130,190 130,140 150,60 C190,90 210,120 220,150 C210,180 190,210 150,240 C110,210 90,180 80,150 C90,120 110,90 150,60');animation:sutol-fiz-14-go 5s linear infinite;}
@keyframes sutol-fiz-14-go{0%{offset-distance:0%;}100%{offset-distance:100%;}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-14-p{animation-duration:18s;}
}
</style>
<svg class="sutol-fiz-14-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <path d="M150,240 C130,190 130,140 150,60 C190,90 210,120 220,150 C210,180 190,210 150,240 C110,210 90,180 80,150 C90,120 110,90 150,60" fill="none" stroke="#fb923c" stroke-width="2" opacity=".4"/>
  <circle class="sutol-fiz-14-p" r="8" fill="#f97316"/>
</svg>
</div>
```

---

## Bileşen 15: İletken ve Yalıtkan

**Etiketler (keyword eşleşmesi için):** iletkenlik, yalıtkan, akışkan dinamiği
**Kategori:** Fizik
**Açıklama:** Bir çubukta serbestçe akan elektronlar ile diğerinde yerinde sabit kalan elektronların karşılaştırması.

```html
<div class="sutol-fiz-15-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-15-root{position:relative;width:100%;height:100%;}
.sutol-fiz-15-svg{width:100%;height:100%;display:block;}
.sutol-fiz-15-e{offset-path:path('M40,130 L40,170');animation:sutol-fiz-15-go 1.6s linear infinite;}
@keyframes sutol-fiz-15-go{0%{offset-distance:0%;}100%{offset-distance:100%;}}
.sutol-fiz-15-e2{animation-delay:.5s;}
.sutol-fiz-15-e3{animation-delay:1s;}
.sutol-fiz-15-static{animation:sutol-fiz-15-jit 2s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
@keyframes sutol-fiz-15-jit{0%,100%{transform:translate(0,0);}50%{transform:translate(1px,-1px);}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-15-e{animation-duration:6s;}
  .sutol-fiz-15-static{animation:none;}
}
</style>
<svg class="sutol-fiz-15-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="60" width="40" height="80" rx="6" fill="#bfdbfe"/>
  <circle class="sutol-fiz-15-e" cx="40" cy="130" r="4" fill="#1d4ed8"/>
  <circle class="sutol-fiz-15-e sutol-fiz-15-e2" cx="40" cy="130" r="4" fill="#1d4ed8"/>
  <circle class="sutol-fiz-15-e sutol-fiz-15-e3" cx="40" cy="130" r="4" fill="#1d4ed8"/>

  <rect x="240" y="60" width="40" height="80" rx="6" fill="#fecaca"/>
  <circle class="sutol-fiz-15-static" cx="255" cy="85" r="4" fill="#b91c1c"/>
  <circle class="sutol-fiz-15-static" cx="265" cy="105" r="4" fill="#b91c1c"/>
  <circle class="sutol-fiz-15-static" cx="255" cy="125" r="4" fill="#b91c1c"/>
</svg>
</div>
```

---

## Bileşen 16: Kapasitör Şarj/Deşarj Döngüsü

**Etiketler (keyword eşleşmesi için):** kapasitör, iletkenlik, alternatif akım
**Kategori:** Fizik
**Açıklama:** İki paralel plaka arasında biriken ve boşalan yük yoğunluğunun döngüsel değişimi.

```html
<div class="sutol-fiz-16-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-16-root{position:relative;width:100%;height:100%;}
.sutol-fiz-16-svg{width:100%;height:100%;display:block;}
.sutol-fiz-16-field{animation:sutol-fiz-16-charge 4s ease-in-out infinite;}
@keyframes sutol-fiz-16-charge{0%,100%{opacity:0;}50%{opacity:.9;}}
.sutol-fiz-16-field:nth-child(2){animation-delay:.15s;}
.sutol-fiz-16-field:nth-child(3){animation-delay:.3s;}
.sutol-fiz-16-field:nth-child(4){animation-delay:.45s;}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-16-field{animation-duration:12s;}
}
</style>
<svg class="sutol-fiz-16-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <rect x="110" y="40" width="10" height="120" fill="#0ea5e9"/>
  <rect x="180" y="40" width="10" height="120" fill="#0ea5e9"/>
  <line class="sutol-fiz-16-field" x1="120" y1="65" x2="180" y2="65" stroke="#38bdf8" stroke-width="2"/>
  <line class="sutol-fiz-16-field" x1="120" y1="90" x2="180" y2="90" stroke="#38bdf8" stroke-width="2"/>
  <line class="sutol-fiz-16-field" x1="120" y1="115" x2="180" y2="115" stroke="#38bdf8" stroke-width="2"/>
  <line class="sutol-fiz-16-field" x1="120" y1="140" x2="180" y2="140" stroke="#38bdf8" stroke-width="2"/>
</svg>
</div>
```

---

## Bileşen 17: İndüktör ve Transformatör

**Etiketler (keyword eşleşmesi için):** indüktör, transformatör, alternatif akım, rezonans
**Kategori:** Fizik
**Açıklama:** Bir bobinden geçen akımın oluşturduğu manyetik alanın nabız gibi genişleyip komşu bobine enerji aktarması.

```html
<div class="sutol-fiz-17-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-17-root{position:relative;width:100%;height:100%;}
.sutol-fiz-17-svg{width:100%;height:100%;display:block;}
.sutol-fiz-17-field{transform-box:fill-box;transform-origin:center;animation:sutol-fiz-17-pulse 2.6s ease-in-out infinite;}
@keyframes sutol-fiz-17-pulse{0%,100%{transform:scale(.7);opacity:.2;}50%{transform:scale(1.25);opacity:.85;}}
.sutol-fiz-17-field:nth-child(2){animation-delay:.3s;}
.sutol-fiz-17-field:nth-child(3){animation-delay:.6s;}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-17-field{animation-duration:10s;}
}
</style>
<svg class="sutol-fiz-17-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <path d="M40,60 q15,-25 30,0 q15,25 30,0 q15,-25 30,0" fill="none" stroke="#f59e0b" stroke-width="4" stroke-linecap="round"/>
  <path d="M40,140 q15,-25 30,0 q15,25 30,0 q15,-25 30,0" fill="none" stroke="#f59e0b" stroke-width="4" stroke-linecap="round"/>
  <ellipse class="sutol-fiz-17-field" cx="130" cy="100" rx="20" ry="45" fill="none" stroke="#fbbf24" stroke-width="2"/>
  <ellipse class="sutol-fiz-17-field" cx="130" cy="100" rx="20" ry="45" fill="none" stroke="#fbbf24" stroke-width="2"/>
  <ellipse class="sutol-fiz-17-field" cx="130" cy="100" rx="20" ry="45" fill="none" stroke="#fbbf24" stroke-width="2"/>
  <path d="M200,60 q15,-25 30,0 q15,25 30,0 q15,-25 30,0" fill="none" stroke="#f59e0b" stroke-width="4" stroke-linecap="round"/>
  <path d="M200,140 q15,-25 30,0 q15,25 30,0 q15,-25 30,0" fill="none" stroke="#f59e0b" stroke-width="4" stroke-linecap="round"/>
</svg>
</div>
```

---

## Bileşen 18: Doppler Etkisi

**Etiketler (keyword eşleşmesi için):** doppler etkisi, foton, kütle çekim dalgası
**Kategori:** Fizik
**Açıklama:** Hareket eden bir kaynağın önünde sıkışan, arkasında seyrelen dalga cepheleri.

```html
<div class="sutol-fiz-18-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-18-root{position:relative;width:100%;height:100%;}
.sutol-fiz-18-svg{width:100%;height:100%;display:block;}
.sutol-fiz-18-src{offset-path:path('M40,150 L260,150');animation:sutol-fiz-18-move 4s linear infinite;}
@keyframes sutol-fiz-18-move{0%{offset-distance:0%;}100%{offset-distance:100%;}}
.sutol-fiz-18-w{transform-box:fill-box;transform-origin:center;animation:sutol-fiz-18-ring 4s linear infinite;opacity:0;}
@keyframes sutol-fiz-18-ring{0%{transform:scale(0);opacity:.8;}100%{transform:scale(2.4);opacity:0;}}
.sutol-fiz-18-w1{animation-delay:0s;}
.sutol-fiz-18-w2{animation-delay:.8s;}
.sutol-fiz-18-w3{animation-delay:1.6s;}
.sutol-fiz-18-w4{animation-delay:2.4s;}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-18-src{animation-duration:14s;}
  .sutol-fiz-18-w{animation:none;opacity:0;}
}
</style>
<svg class="sutol-fiz-18-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <circle class="sutol-fiz-18-w sutol-fiz-18-w1" cx="40" cy="150" r="20" fill="none" stroke="#22d3ee" stroke-width="2"/>
  <circle class="sutol-fiz-18-w sutol-fiz-18-w2" cx="40" cy="150" r="20" fill="none" stroke="#22d3ee" stroke-width="2"/>
  <circle class="sutol-fiz-18-w sutol-fiz-18-w3" cx="40" cy="150" r="20" fill="none" stroke="#22d3ee" stroke-width="2"/>
  <circle class="sutol-fiz-18-w sutol-fiz-18-w4" cx="40" cy="150" r="20" fill="none" stroke="#22d3ee" stroke-width="2"/>
  <circle class="sutol-fiz-18-src" cx="40" cy="150" r="8" fill="#0891b2"/>
</svg>
</div>
```

---

## Bileşen 19: Kırılma İndisi — Prizma

**Etiketler (keyword eşleşmesi için):** kırılma indisi, foton, polarizasyon
**Kategori:** Fizik
**Açıklama:** Beyaz bir ışın üçgen prizmadan geçerken renk tayfına ayrılıp farklı açılarla kırılması.

```html
<div class="sutol-fiz-19-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-19-root{position:relative;width:100%;height:100%;}
.sutol-fiz-19-svg{width:100%;height:100%;display:block;}
.sutol-fiz-19-in{stroke-dasharray:8 6;animation:sutol-fiz-19-flow 1.4s linear infinite;}
@keyframes sutol-fiz-19-flow{to{stroke-dashoffset:-14;}}
.sutol-fiz-19-ray{animation:sutol-fiz-19-fade 3s ease-in-out infinite;}
@keyframes sutol-fiz-19-fade{0%,100%{opacity:.35;}50%{opacity:1;}}
.sutol-fiz-19-ray:nth-child(4){animation-delay:.1s;}
.sutol-fiz-19-ray:nth-child(5){animation-delay:.2s;}
.sutol-fiz-19-ray:nth-child(6){animation-delay:.3s;}
.sutol-fiz-19-ray:nth-child(7){animation-delay:.4s;}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-19-in{animation:none;}
  .sutol-fiz-19-ray{animation:none;opacity:.85;}
}
</style>
<svg class="sutol-fiz-19-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <polygon points="150,40 110,150 190,150" fill="#e2e8f0" opacity=".5" stroke="#94a3b8" stroke-width="2"/>
  <line class="sutol-fiz-19-in" x1="20" y1="100" x2="135" y2="110" stroke="#f8fafc" stroke-width="3"/>
  <line class="sutol-fiz-19-ray" x1="160" y1="120" x2="280" y2="70" stroke="#ef4444" stroke-width="2"/>
  <line class="sutol-fiz-19-ray" x1="160" y1="120" x2="280" y2="90" stroke="#f97316" stroke-width="2"/>
  <line class="sutol-fiz-19-ray" x1="160" y1="120" x2="280" y2="110" stroke="#facc15" stroke-width="2"/>
  <line class="sutol-fiz-19-ray" x1="160" y1="120" x2="280" y2="130" stroke="#22c55e" stroke-width="2"/>
  <line class="sutol-fiz-19-ray" x1="160" y1="120" x2="280" y2="150" stroke="#3b82f6" stroke-width="2"/>
  <line class="sutol-fiz-19-ray" x1="160" y1="120" x2="280" y2="170" stroke="#8b5cf6" stroke-width="2"/>
</svg>
</div>
```

---

## Bileşen 20: Serbest Düşme, Elastik Çarpışma ve Akışkan Dinamiği

**Etiketler (keyword eşleşmesi için):** serbest düşme, elastik çarpışma, akışkan dinamiği, türbülans, viskozite, kaldırma kuvveti
**Kategori:** Fizik
**Açıklama:** Düşerek zeminde elastik biçimde sekip yükselirken arkasında türbülanslı akış çizgileri bırakan bir top.

```html
<div class="sutol-fiz-20-root" style="width:100%;height:100%;">
<style>
.sutol-fiz-20-root{position:relative;width:100%;height:100%;}
.sutol-fiz-20-svg{width:100%;height:100%;display:block;}
.sutol-fiz-20-ball{animation:sutol-fiz-20-bounce 2.2s cubic-bezier(.5,0,.5,1) infinite;transform-box:fill-box;transform-origin:center;}
@keyframes sutol-fiz-20-bounce{
  0%{transform:translateY(0) scale(1,1);}
  40%{transform:translateY(120px) scale(1.15,.85);}
  46%{transform:translateY(126px) scale(1.3,.7);}
  55%{transform:translateY(40px) scale(.95,1.05);}
  75%{transform:translateY(0) scale(1,1);}
  100%{transform:translateY(0) scale(1,1);}
}
.sutol-fiz-20-flow{stroke-dasharray:10 8;animation:sutol-fiz-20-stream 1.6s linear infinite;}
@keyframes sutol-fiz-20-stream{to{stroke-dashoffset:-18;}}
@media (prefers-reduced-motion: reduce){
  .sutol-fiz-20-ball{animation-duration:8s;}
  .sutol-fiz-20-flow{animation:none;}
}
</style>
<svg class="sutol-fiz-20-svg" viewBox="0 0 300 220" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <line x1="40" y1="190" x2="260" y2="190" stroke="#94a3b8" stroke-width="3"/>
  <path class="sutol-fiz-20-flow" d="M90,70 Q120,60 150,70 T210,70" fill="none" stroke="#38bdf8" stroke-width="2" opacity=".55"/>
  <path class="sutol-fiz-20-flow" d="M90,90 Q120,78 150,90 T210,90" fill="none" stroke="#38bdf8" stroke-width="2" opacity=".4"/>
  <circle class="sutol-fiz-20-ball" cx="150" cy="70" r="16" fill="#fb7185"/>
</svg>
</div>
```

---

## Kalite Kontrol Özeti

- **01 Zaman Genişlemesi:** CSS `transform:rotate()` ile farklı sürelerde akrep dönüşü; GPU dostu; sorun yok.
- **02 Uzay-Zaman Eğriliği:** Statik eğik ızgara + `scale/opacity` ile gecikmeli halka animasyonu; hafif.
- **03 Kara Cisim Işıması:** `fill` renk geçişi + halo `scale/opacity`; renk animasyonu düşük maliyetli.
- **04 Foton:** `offset-path` ile SVG yol boyunca hareket; modern tarayıcı desteği gerekli, akıcı.
- **05 Parçacık Hızlandırıcı:** İki zıt `offset-path` döngüsü + gecikmeli flaş; performanslı.
- **06 Higgs Bozonu:** `translateX` yaklaşma + gecikmeli ışın patlaması; orta karmaşıklık.
- **07 Kuark Üçlüsü:** Grup `rotate` + nokta `scale` nabzı; hafif.
- **08 String Teorisi:** CSS `d` path morph animasyonu (modern tarayıcı gerekir); tek eleman, düşük maliyet.
- **09 Belirsizlik İlkesi:** `r`/`scaleX` animasyonu; basit ve performanslı.
- **10 Dalga Fonksiyonu Çöküşü:** `scaleY`/`scale` geçişleri; hafif.
- **11 Çift Yarık Girişimi:** Çoklu gecikmeli `scale/opacity` halkaları; orta yoğunluk, hâlâ 60fps uyumlu.
- **12 Kırınım:** Dört gecikmeli yay `scale/opacity`; hafif.
- **13 Polarizasyon:** `rotate` + `scaleY` birleşimi; düşük maliyet.
- **14 Konveksiyon Hücresi:** Tek parçacık `offset-path` döngüsü; çok hafif.
- **15 İletken/Yalıtkan:** Üç gecikmeli `offset-path` elektronu + hafif `translate` titreşim; hafif.
- **16 Kapasitör:** Dört çizginin gecikmeli `opacity` nabzı; çok hafif.
- **17 İndüktör/Transformatör:** Üç gecikmeli elips `scale/opacity`; hafif.
- **18 Doppler Etkisi:** `offset-path` kaynak hareketi + dört gecikmeli halka; orta.
- **19 Kırılma İndisi:** `stroke-dashoffset` akışı + altı ışının gecikmeli `opacity` nabzı; orta.
- **20 Serbest Düşme/Akışkan:** `cubic-bezier` sekme eğrisi (squash&stretch) + iki akış çizgisi `stroke-dashoffset`; orta.

Tüm bileşenler `prefers-reduced-motion` desteği içerir, şeffaf arka plana sahiptir, `viewBox` ile ölçeklenir, dış kaynak kullanmaz ve benzersiz `sutol-fiz-NN-` sınıf önekleriyle kapsüllenmiştir.
