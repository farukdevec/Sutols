## Bileşen 21: Toplantı — Yuvarlak Masa Bağlantısı

**Etiketler (keyword eşleşmesi için):** toplantı, ekip, işbirliği, iletişim
**Kategori:** Genel Sunum / İş
**Açıklama:** Merkezdeki yuvarlak masa etrafında dört katılımcı noktasının yörüngede dönerek bağlantı çizgileriyle titreşmesi.

```html
<div class="sutol-biz21-wrap">
  <svg class="sutol-biz21-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <circle class="sutol-biz21-table" cx="50" cy="50" r="16" fill="none" stroke="#3f6fb0" stroke-width="2"/>
    <g class="sutol-biz21-links">
      <line x1="50" y1="20" x2="50" y2="34" stroke="#3f6fb0" stroke-width="1" opacity="0.5"/>
      <line x1="80" y1="50" x2="66" y2="50" stroke="#3f6fb0" stroke-width="1" opacity="0.5"/>
      <line x1="50" y1="80" x2="50" y2="66" stroke="#3f6fb0" stroke-width="1" opacity="0.5"/>
      <line x1="20" y1="50" x2="34" y2="50" stroke="#3f6fb0" stroke-width="1" opacity="0.5"/>
    </g>
    <g class="sutol-biz21-orbit">
      <circle class="sutol-biz21-p" cx="50" cy="20" r="5" fill="#f2a541"/>
      <circle class="sutol-biz21-p" cx="80" cy="50" r="5" fill="#5bc48f"/>
      <circle class="sutol-biz21-p" cx="50" cy="80" r="5" fill="#e2607a"/>
      <circle class="sutol-biz21-p" cx="20" cy="50" r="5" fill="#8a6fd6"/>
    </g>
  </svg>
</div>

<style>
.sutol-biz21-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz21-wrap .sutol-biz21-svg{width:100%;height:100%;display:block;overflow:visible;}
.sutol-biz21-wrap .sutol-biz21-orbit{transform-origin:50px 50px;animation:sutol-biz21-spin 8s linear infinite;}
.sutol-biz21-wrap .sutol-biz21-table{animation:sutol-biz21-pulse 3s ease-in-out infinite;}
.sutol-biz21-wrap .sutol-biz21-links line{animation:sutol-biz21-flicker 2.4s ease-in-out infinite;}
@keyframes sutol-biz21-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
@keyframes sutol-biz21-pulse{0%,100%{stroke-opacity:0.5;}50%{stroke-opacity:1;}}
@keyframes sutol-biz21-flicker{0%,100%{opacity:0.3;}50%{opacity:0.9;}}
@media (prefers-reduced-motion: reduce){
  .sutol-biz21-wrap .sutol-biz21-orbit{animation-duration:24s;}
  .sutol-biz21-wrap .sutol-biz21-table,.sutol-biz21-wrap .sutol-biz21-links line{animation-duration:9s;}
}
</style>
```

---

## Bileşen 22: İletişim — Konuşma Balonu Değişimi

**Etiketler (keyword eşleşmesi için):** iletişim, sunum, işbirliği, geri bildirim
**Kategori:** Genel Sunum / İş
**Açıklama:** Sol ve sağ tarafta beliren iki konuşma balonunun sırayla belirip kaybolarak karşılıklı bir diyalog akışı canlandırması.

```html
<div class="sutol-biz22-wrap">
  <svg class="sutol-biz22-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-biz22-bubble sutol-biz22-b1" d="M10,30 h34 a6,6 0 0 1 6,6 v10 a6,6 0 0 1 -6,6 h-20 l-8,8 v-8 h-6 a6,6 0 0 1 -6,-6 v-10 a6,6 0 0 1 6,-6 z" fill="#3f6fb0"/>
    <path class="sutol-biz22-bubble sutol-biz22-b2" d="M90,70 h-34 a6,6 0 0 1 -6,-6 v-10 a6,6 0 0 1 6,-6 h20 l8,-8 v8 h6 a6,6 0 0 1 6,6 v10 a6,6 0 0 1 -6,6 z" fill="#5bc48f"/>
  </svg>
</div>

<style>
.sutol-biz22-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz22-wrap .sutol-biz22-svg{width:100%;height:100%;display:block;}
.sutol-biz22-wrap .sutol-biz22-b1{transform-origin:27px 44px;animation:sutol-biz22-in 3s ease-in-out infinite;}
.sutol-biz22-wrap .sutol-biz22-b2{transform-origin:73px 56px;animation:sutol-biz22-in 3s ease-in-out infinite 1.5s;}
@keyframes sutol-biz22-in{
  0%,10%{opacity:0;transform:scale(0.6) translateY(6px);}
  25%,45%{opacity:1;transform:scale(1) translateY(0);}
  60%,100%{opacity:0;transform:scale(0.6) translateY(-6px);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz22-wrap .sutol-biz22-b1,.sutol-biz22-wrap .sutol-biz22-b2{animation-duration:9s;}
}
</style>
```

---

## Bileşen 23: Karar — Yol Ayrımı (Kavşak)

**Etiketler (keyword eşleşmesi için):** karar, strateji, süreç, analiz
**Kategori:** Genel Sunum / İş
**Açıklama:** Ana yoldan gelen bir noktanın çatallanan iki yoldan birine girerek karar anını simgeleyen bir hareket çizmesi.

```html
<div class="sutol-biz23-wrap">
  <svg class="sutol-biz23-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-biz23-main" d="M50,8 V44" fill="none" stroke="#9aa5b1" stroke-width="2"/>
    <path class="sutol-biz23-branchA" d="M50,44 C50,60 20,60 20,92" fill="none" stroke="#5bc48f" stroke-width="2"/>
    <path class="sutol-biz23-branchB" d="M50,44 C50,60 80,60 80,92" fill="none" stroke="#c9d1da" stroke-width="2"/>
    <circle class="sutol-biz23-ball" r="4" fill="#f2a541" offset-path="path('M50,8 V44 C50,60 20,60 20,92')" offset-rotate="0deg"/>
  </svg>
</div>

<style>
.sutol-biz23-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz23-wrap .sutol-biz23-svg{width:100%;height:100%;display:block;overflow:visible;}
.sutol-biz23-wrap .sutol-biz23-ball{animation:sutol-biz23-move 3.2s ease-in-out infinite;}
.sutol-biz23-wrap .sutol-biz23-branchA{animation:sutol-biz23-light 3.2s ease-in-out infinite;}
@keyframes sutol-biz23-move{
  0%{offset-distance:0%;}
  100%{offset-distance:100%;}
}
@keyframes sutol-biz23-light{
  0%,55%{stroke-opacity:0.35;}
  60%,100%{stroke-opacity:1;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz23-wrap .sutol-biz23-ball,.sutol-biz23-wrap .sutol-biz23-branchA{animation-duration:10s;}
}
</style>
```

---

## Bileşen 24: Onay — Mühür Damgası

**Etiketler (keyword eşleşmesi için):** onay, sonuç, karar, süreç
**Kategori:** Genel Sunum / İş
**Açıklama:** Yukarıdan inen bir damganın kağıt üzerine vurup iz bırakması ve tekrar yukarı çekilmesi.

```html
<div class="sutol-biz24-wrap">
  <svg class="sutol-biz24-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <rect x="25" y="55" width="50" height="34" rx="3" fill="none" stroke="#9aa5b1" stroke-width="2"/>
    <circle class="sutol-biz24-mark" cx="50" cy="72" r="12" fill="none" stroke="#e2607a" stroke-width="3"/>
    <g class="sutol-biz24-stamp">
      <rect x="38" y="8" width="24" height="10" rx="2" fill="#3f6fb0"/>
      <rect x="45" y="18" width="10" height="14" fill="#3f6fb0"/>
      <circle cx="50" cy="34" r="14" fill="none" stroke="#3f6fb0" stroke-width="3"/>
    </g>
  </svg>
</div>

<style>
.sutol-biz24-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz24-wrap .sutol-biz24-svg{width:100%;height:100%;display:block;}
.sutol-biz24-wrap .sutol-biz24-stamp{transform-origin:50px 20px;animation:sutol-biz24-stamp 2.6s ease-in-out infinite;}
.sutol-biz24-wrap .sutol-biz24-mark{opacity:0;animation:sutol-biz24-mark 2.6s ease-in-out infinite;}
@keyframes sutol-biz24-stamp{
  0%,15%{transform:translateY(0);}
  35%{transform:translateY(30px) rotate(-4deg);}
  50%{transform:translateY(30px) rotate(2deg);}
  70%,100%{transform:translateY(0);}
}
@keyframes sutol-biz24-mark{
  0%,40%{opacity:0;transform:scale(0.6);}
  50%,80%{opacity:1;transform:scale(1);}
  95%,100%{opacity:0;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz24-wrap .sutol-biz24-stamp,.sutol-biz24-wrap .sutol-biz24-mark{animation-duration:8s;}
}
</style>
```

---

## Bileşen 25: Sertifika — Rozet ve Kurdele

**Etiketler (keyword eşleşmesi için):** sertifika, başarı, değerlendirme, onay
**Kategori:** Genel Sunum / İş
**Açıklama:** Yıldızlı madalyon rozetinin hafifçe nabız gibi büyüyüp küçülmesi ve altındaki iki kurdele ucunun dalga gibi sallanması.

```html
<div class="sutol-biz25-wrap">
  <svg class="sutol-biz25-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <path class="sutol-biz25-ribbon sutol-biz25-r1" d="M42,55 L30,92 L42,86 L48,95 L46,55 Z" fill="#e2607a"/>
    <path class="sutol-biz25-ribbon sutol-biz25-r2" d="M58,55 L70,92 L58,86 L52,95 L54,55 Z" fill="#3f6fb0"/>
    <g class="sutol-biz25-badge">
      <circle cx="50" cy="42" r="26" fill="#f2a541"/>
      <path d="M50,26 L54,38 L67,38 L57,46 L61,58 L50,50 L39,58 L43,46 L33,38 L46,38 Z" fill="#ffffff"/>
    </g>
  </svg>
</div>

<style>
.sutol-biz25-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz25-wrap .sutol-biz25-svg{width:100%;height:100%;display:block;}
.sutol-biz25-wrap .sutol-biz25-badge{transform-origin:50px 42px;animation:sutol-biz25-pulse 2.4s ease-in-out infinite;}
.sutol-biz25-wrap .sutol-biz25-r1{transform-origin:42px 55px;animation:sutol-biz25-wave 2.4s ease-in-out infinite;}
.sutol-biz25-wrap .sutol-biz25-r2{transform-origin:58px 55px;animation:sutol-biz25-wave 2.4s ease-in-out infinite 0.3s;}
@keyframes sutol-biz25-pulse{0%,100%{transform:scale(1);}50%{transform:scale(1.08);}}
@keyframes sutol-biz25-wave{0%,100%{transform:rotate(-4deg);}50%{transform:rotate(4deg);}}
@media (prefers-reduced-motion: reduce){
  .sutol-biz25-wrap .sutol-biz25-badge,.sutol-biz25-wrap .sutol-biz25-r1,.sutol-biz25-wrap .sutol-biz25-r2{animation-duration:8s;}
}
</style>
```

---

## Bileşen 26: İmza — Akan İmza Çizgisi

**Etiketler (keyword eşleşmesi için):** imza, onay, sözleşme, süreç
**Kategori:** Genel Sunum / İş
**Açıklama:** Kıvrımlı bir imza yolunun sanki bir kalemle çiziliyormuş gibi baştan sona belirmesi ve ardından silinip yeniden başlaması.

```html
<div class="sutol-biz26-wrap">
  <svg class="sutol-biz26-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <line x1="10" y1="70" x2="90" y2="70" stroke="#c9d1da" stroke-width="1"/>
    <path class="sutol-biz26-sig" d="M12,60 C22,40 28,75 36,55 C42,42 46,66 54,50 C60,38 64,64 72,48 C78,38 82,52 88,44" fill="none" stroke="#3f6fb0" stroke-width="2.5" stroke-linecap="round"/>
  </svg>
</div>

<style>
.sutol-biz26-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz26-wrap .sutol-biz26-svg{width:100%;height:100%;display:block;}
.sutol-biz26-wrap .sutol-biz26-sig{stroke-dasharray:220;stroke-dashoffset:220;animation:sutol-biz26-draw 3.6s ease-in-out infinite;}
@keyframes sutol-biz26-draw{
  0%{stroke-dashoffset:220;opacity:1;}
  55%{stroke-dashoffset:0;opacity:1;}
  80%,100%{stroke-dashoffset:0;opacity:0;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz26-wrap .sutol-biz26-sig{animation-duration:11s;}
}
</style>
```

---

## Bileşen 27: İş Akışı — Konveyör Hattı

**Etiketler (keyword eşleşmesi için):** iş akışı, süreç, verimlilik, üretim
**Kategori:** Genel Sunum / İş
**Açıklama:** Üç düğüm arasında hareket eden küçük paketlerin bir konveyör hattında ilerleyerek sürecin akışını canlandırması.

```html
<div class="sutol-biz27-wrap">
  <svg class="sutol-biz27-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <line x1="12" y1="50" x2="88" y2="50" stroke="#c9d1da" stroke-width="2"/>
    <circle cx="12" cy="50" r="6" fill="#3f6fb0"/>
    <circle cx="50" cy="50" r="6" fill="#5bc48f"/>
    <circle cx="88" cy="50" r="6" fill="#f2a541"/>
    <rect class="sutol-biz27-packet sutol-biz27-p1" x="0" y="45" width="8" height="8" rx="1.5" fill="#e2607a"/>
    <rect class="sutol-biz27-packet sutol-biz27-p2" x="0" y="45" width="8" height="8" rx="1.5" fill="#8a6fd6"/>
  </svg>
</div>

<style>
.sutol-biz27-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz27-wrap .sutol-biz27-svg{width:100%;height:100%;display:block;}
.sutol-biz27-wrap .sutol-biz27-p1{animation:sutol-biz27-run 3s linear infinite;}
.sutol-biz27-wrap .sutol-biz27-p2{animation:sutol-biz27-run 3s linear infinite 1.5s;}
@keyframes sutol-biz27-run{
  0%{transform:translateX(12px);opacity:1;}
  90%{transform:translateX(84px);opacity:1;}
  100%{transform:translateX(84px);opacity:0;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz27-wrap .sutol-biz27-p1,.sutol-biz27-wrap .sutol-biz27-p2{animation-duration:9s;}
}
</style>
```

---

## Bileşen 28: Verimlilik — Hız Göstergesi

**Etiketler (keyword eşleşmesi için):** verimlilik, performans, analiz, büyüme
**Kategori:** Genel Sunum / İş
**Açıklama:** Yarım daire şeklindeki bir gösterge üzerinde ibrenin düşük değerden yükseğe salınarak performans artışını temsil etmesi.

```html
<div class="sutol-biz28-wrap">
  <svg class="sutol-biz28-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <path d="M15,70 A35,35 0 0 1 85,70" fill="none" stroke="#c9d1da" stroke-width="6" stroke-linecap="round"/>
    <path d="M15,70 A35,35 0 0 1 50,35" fill="none" stroke="#5bc48f" stroke-width="6" stroke-linecap="round"/>
    <line class="sutol-biz28-needle" x1="50" y1="70" x2="50" y2="38" stroke="#e2607a" stroke-width="3" stroke-linecap="round"/>
    <circle cx="50" cy="70" r="4" fill="#3f6fb0"/>
  </svg>
</div>

<style>
.sutol-biz28-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz28-wrap .sutol-biz28-svg{width:100%;height:100%;display:block;}
.sutol-biz28-wrap .sutol-biz28-needle{transform-origin:50px 70px;animation:sutol-biz28-sweep 3s ease-in-out infinite;}
@keyframes sutol-biz28-sweep{
  0%,100%{transform:rotate(-55deg);}
  50%{transform:rotate(55deg);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz28-wrap .sutol-biz28-needle{animation-duration:9s;}
}
</style>
```

---

## Bileşen 29: Büyüme — Filizlenen Grafik

**Etiketler (keyword eşleşmesi için):** büyüme, istatistik, ilerleme, başarı
**Kategori:** Genel Sunum / İş
**Açıklama:** Sırayla yükselen üç çubuğun tepesinde beliren küçük bir filiz noktasının hafifçe zıplaması.

```html
<div class="sutol-biz29-wrap">
  <svg class="sutol-biz29-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <line x1="10" y1="90" x2="90" y2="90" stroke="#c9d1da" stroke-width="1.5"/>
    <rect class="sutol-biz29-bar sutol-biz29-b1" x="24" y="90" width="12" height="30" fill="#5bc48f"/>
    <rect class="sutol-biz29-bar sutol-biz29-b2" x="44" y="90" width="12" height="45" fill="#3f6fb0"/>
    <rect class="sutol-biz29-bar sutol-biz29-b3" x="64" y="90" width="12" height="60" fill="#f2a541"/>
    <circle class="sutol-biz29-sprout" cx="70" cy="26" r="4" fill="#5bc48f"/>
  </svg>
</div>

<style>
.sutol-biz29-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz29-wrap .sutol-biz29-svg{width:100%;height:100%;display:block;}
.sutol-biz29-wrap .sutol-biz29-bar{transform-box:fill-box;transform-origin:bottom;animation:sutol-biz29-grow 3.2s ease-in-out infinite;}
.sutol-biz29-wrap .sutol-biz29-b1{animation-delay:0s;}
.sutol-biz29-wrap .sutol-biz29-b2{animation-delay:0.25s;}
.sutol-biz29-wrap .sutol-biz29-b3{animation-delay:0.5s;}
.sutol-biz29-wrap .sutol-biz29-sprout{transform-box:fill-box;transform-origin:center;animation:sutol-biz29-bounce 1.6s ease-in-out infinite 0.9s;}
@keyframes sutol-biz29-grow{
  0%{transform:scaleY(0);}
  40%,100%{transform:scaleY(1);}
}
@keyframes sutol-biz29-bounce{
  0%,100%{transform:translateY(0);}
  50%{transform:translateY(-6px);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz29-wrap .sutol-biz29-bar,.sutol-biz29-wrap .sutol-biz29-sprout{animation-duration:9s;}
}
</style>
```

---

## Bileşen 30: Başarı — Zirve Bayrağı

**Etiketler (keyword eşleşmesi için):** başarı, hedef, ilerleme, strateji
**Kategori:** Genel Sunum / İş
**Açıklama:** Dağ şeklinin yamacında tırmanan bir noktanın zirveye ulaşması ve tepedeki bayrağın dalgalanması.

```html
<div class="sutol-biz30-wrap">
  <svg class="sutol-biz30-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <path d="M10,90 L50,20 L90,90 Z" fill="none" stroke="#9aa5b1" stroke-width="2"/>
    <line x1="50" y1="20" x2="50" y2="8" stroke="#3f3f3f" stroke-width="2"/>
    <path class="sutol-biz30-flag" d="M50,8 L64,12 L50,16 Z" fill="#e2607a"/>
    <circle class="sutol-biz30-climber" r="4" fill="#3f6fb0" offset-path="path('M14,86 L50,22')" offset-rotate="0deg"/>
  </svg>
</div>

<style>
.sutol-biz30-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz30-wrap .sutol-biz30-svg{width:100%;height:100%;display:block;overflow:visible;}
.sutol-biz30-wrap .sutol-biz30-climber{animation:sutol-biz30-climb 3.4s ease-in-out infinite;}
.sutol-biz30-wrap .sutol-biz30-flag{transform-origin:50px 8px;animation:sutol-biz30-wave 1.4s ease-in-out infinite;}
@keyframes sutol-biz30-climb{
  0%{offset-distance:0%;opacity:1;}
  85%{offset-distance:100%;opacity:1;}
  100%{offset-distance:100%;opacity:0;}
}
@keyframes sutol-biz30-wave{
  0%,100%{transform:skewY(-6deg);}
  50%{transform:skewY(6deg);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz30-wrap .sutol-biz30-climber{animation-duration:10s;}
  .sutol-biz30-wrap .sutol-biz30-flag{animation-duration:4.5s;}
}
</style>
```

---

## Bileşen 31: İlerleme — Dairesel Yükleme Halkası

**Etiketler (keyword eşleşmesi için):** ilerleme, süreç, hedef, verimlilik
**Kategori:** Genel Sunum / İş
**Açıklama:** Bir dairesel çizginin saat yönünde dolarak tamamlanması ve ardından sıfırlanıp yeniden başlaması.

```html
<div class="sutol-biz31-wrap">
  <svg class="sutol-biz31-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <circle cx="50" cy="50" r="34" fill="none" stroke="#e5e9ee" stroke-width="8"/>
    <circle class="sutol-biz31-ring" cx="50" cy="50" r="34" fill="none" stroke="#3f6fb0" stroke-width="8" stroke-linecap="round" stroke-dasharray="213.6" stroke-dashoffset="213.6"/>
  </svg>
</div>

<style>
.sutol-biz31-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz31-wrap .sutol-biz31-svg{width:100%;height:100%;display:block;transform:rotate(-90deg);}
.sutol-biz31-wrap .sutol-biz31-ring{animation:sutol-biz31-fill 3.5s ease-in-out infinite;}
@keyframes sutol-biz31-fill{
  0%{stroke-dashoffset:213.6;}
  70%,85%{stroke-dashoffset:0;}
  100%{stroke-dashoffset:213.6;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz31-wrap .sutol-biz31-ring{animation-duration:10.5s;}
}
</style>
```

---

## Bileşen 32: El Sıkışma — Anlaşma

**Etiketler (keyword eşleşmesi için):** el sıkışma, işbirliği, karar, onay
**Kategori:** Genel Sunum / İş
**Açıklama:** Ekranın iki yanından yaklaşan iki elin ortada buluşup hafifçe sallanarak anlaşmayı simgelemesi.

```html
<div class="sutol-biz32-wrap">
  <svg class="sutol-biz32-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-biz32-left" id="sutol-biz32-left-group">
      <rect x="6" y="46" width="34" height="12" rx="6" fill="#3f6fb0"/>
      <circle cx="42" cy="52" r="7" fill="#3f6fb0"/>
    </g>
    <g class="sutol-biz32-right" id="sutol-biz32-right-group">
      <rect x="60" y="46" width="34" height="12" rx="6" fill="#e2607a"/>
      <circle cx="58" cy="52" r="7" fill="#e2607a"/>
    </g>
  </svg>
</div>

<style>
.sutol-biz32-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz32-wrap .sutol-biz32-svg{width:100%;height:100%;display:block;}
</style>

<script>
(function(){
  var wrap = document.currentScript.previousElementSibling;
  var left = wrap.querySelector('#sutol-biz32-left-group');
  var right = wrap.querySelector('#sutol-biz32-right-group');
  var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var speed = reduced ? 0.2 : 0.7;
  var start = null;
  function frame(ts){
    if(!start) start = ts;
    var t = ((ts - start) / 1000) * speed;
    var cycle = t % 4;
    var moveX = 0, wobble = 0;
    if(cycle < 1.2){
      moveX = 8 * (cycle / 1.2);
    } else if(cycle < 3.2){
      wobble = Math.sin((cycle - 1.2) * 8) * 1.5;
      moveX = 8;
    } else {
      moveX = 8 * (1 - (cycle - 3.2) / 0.8);
    }
    left.setAttribute('transform', 'translate(' + moveX + ',' + wobble + ')');
    right.setAttribute('transform', 'translate(' + (-moveX) + ',' + (-wobble) + ')');
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);
})();
</script>
```

---

## Bileşen 33: Veri Görselleştirme — Gösterge Paneli

**Etiketler (keyword eşleşmesi için):** veri görselleştirme, analiz, istatistik, rapor
**Kategori:** Genel Sunum / İş
**Açıklama:** Bir kontrol panelindeki iki farklı ibreli göstergenin canvas üzerinde bağımsız hızlarda salınarak veri akışını simgelemesi.

```html
<div class="sutol-biz33-wrap">
  <canvas class="sutol-biz33-canvas" width="300" height="150"></canvas>
</div>

<style>
.sutol-biz33-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz33-wrap .sutol-biz33-canvas{width:100%;height:100%;display:block;}
</style>

<script>
(function(){
  var wrap = document.currentScript.previousElementSibling;
  var canvas = wrap.querySelector('.sutol-biz33-canvas');
  var ctx = canvas.getContext('2d');
  var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var speed = reduced ? 0.15 : 0.5;

  function resize(){
    var rect = canvas.getBoundingClientRect();
    canvas.width = Math.max(1, rect.width);
    canvas.height = Math.max(1, rect.height);
  }
  resize();
  window.addEventListener('resize', resize);

  function drawGauge(cx, cy, r, angle, color){
    ctx.beginPath();
    ctx.arc(cx, cy, r, Math.PI * 0.75, Math.PI * 2.25);
    ctx.strokeStyle = '#e5e9ee';
    ctx.lineWidth = r * 0.18;
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(cx, cy);
    ctx.lineTo(cx + Math.cos(angle) * r * 0.8, cy + Math.sin(angle) * r * 0.8);
    ctx.strokeStyle = color;
    ctx.lineWidth = r * 0.1;
    ctx.lineCap = 'round';
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(cx, cy, r * 0.08, 0, Math.PI * 2);
    ctx.fillStyle = color;
    ctx.fill();
  }

  var start = null;
  function frame(ts){
    if(!start) start = ts;
    var t = ((ts - start) / 1000) * speed;
    var w = canvas.width, h = canvas.height;
    ctx.clearRect(0, 0, w, h);
    var r = Math.min(w, h) * 0.35;
    var a1 = Math.PI * 0.75 + (Math.sin(t) * 0.5 + 0.5) * Math.PI * 1.5;
    var a2 = Math.PI * 0.75 + (Math.sin(t * 1.7 + 1) * 0.5 + 0.5) * Math.PI * 1.5;
    drawGauge(w * 0.32, h * 0.55, r, a1, '#3f6fb0');
    drawGauge(w * 0.68, h * 0.55, r, a2, '#5bc48f');
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);
})();
</script>
```

---

## Bileşen 34: Pazar Araştırması — Radar Taraması

**Etiketler (keyword eşleşmesi için):** pazar araştırması, analiz, veri, strateji
**Kategori:** Genel Sunum / İş
**Açıklama:** Halka şeklindeki radar ekranında dönen bir tarama kolunun ve rastgele yerleşmiş sinyal noktalarının yanıp sönmesi.

```html
<div class="sutol-biz34-wrap">
  <svg class="sutol-biz34-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <circle cx="50" cy="50" r="40" fill="none" stroke="#c9d1da" stroke-width="1"/>
    <circle cx="50" cy="50" r="26" fill="none" stroke="#c9d1da" stroke-width="1"/>
    <circle cx="50" cy="50" r="12" fill="none" stroke="#c9d1da" stroke-width="1"/>
    <g class="sutol-biz34-sweep">
      <path d="M50,50 L50,10 A40,40 0 0 1 78,22 Z" fill="#5bc48f" opacity="0.25"/>
      <line x1="50" y1="50" x2="50" y2="10" stroke="#5bc48f" stroke-width="1.5"/>
    </g>
    <circle class="sutol-biz34-blip sutol-biz34-blip1" cx="30" cy="35" r="2.5" fill="#e2607a"/>
    <circle class="sutol-biz34-blip sutol-biz34-blip2" cx="68" cy="60" r="2.5" fill="#f2a541"/>
    <circle class="sutol-biz34-blip sutol-biz34-blip3" cx="55" cy="70" r="2.5" fill="#3f6fb0"/>
  </svg>
</div>

<style>
.sutol-biz34-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz34-wrap .sutol-biz34-svg{width:100%;height:100%;display:block;}
.sutol-biz34-wrap .sutol-biz34-sweep{transform-origin:50px 50px;animation:sutol-biz34-rotate 4s linear infinite;}
.sutol-biz34-wrap .sutol-biz34-blip{animation:sutol-biz34-blip 4s ease-in-out infinite;}
.sutol-biz34-wrap .sutol-biz34-blip1{animation-delay:0.2s;}
.sutol-biz34-wrap .sutol-biz34-blip2{animation-delay:1.4s;}
.sutol-biz34-wrap .sutol-biz34-blip3{animation-delay:2.6s;}
@keyframes sutol-biz34-rotate{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
@keyframes sutol-biz34-blip{0%,85%,100%{opacity:0.15;}90%{opacity:1;}}
@media (prefers-reduced-motion: reduce){
  .sutol-biz34-wrap .sutol-biz34-sweep{animation-duration:14s;}
  .sutol-biz34-wrap .sutol-biz34-blip{animation-duration:12s;}
}
</style>
```

---

## Bileşen 35: Kullanıcı Geri Bildirimi — Yükselen Tepki Baloncukları

**Etiketler (keyword eşleşmesi için):** geri bildirim, değerlendirme, iletişim, analiz
**Kategori:** Genel Sunum / İş
**Açıklama:** Alt kenardan yükselen küçük yıldız ve kalp şekilli baloncukların yukarı doğru süzülüp sönmesi.

```html
<div class="sutol-biz35-wrap">
  <svg class="sutol-biz35-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <circle class="sutol-biz35-bub sutol-biz35-b1" cx="30" cy="90" r="4" fill="#e2607a"/>
    <circle class="sutol-biz35-bub sutol-biz35-b2" cx="50" cy="90" r="3.5" fill="#f2a541"/>
    <circle class="sutol-biz35-bub sutol-biz35-b3" cx="70" cy="90" r="4.5" fill="#5bc48f"/>
    <circle class="sutol-biz35-bub sutol-biz35-b4" cx="40" cy="90" r="3" fill="#8a6fd6"/>
    <circle class="sutol-biz35-bub sutol-biz35-b5" cx="60" cy="90" r="3.5" fill="#3f6fb0"/>
  </svg>
</div>

<style>
.sutol-biz35-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz35-wrap .sutol-biz35-svg{width:100%;height:100%;display:block;}
.sutol-biz35-wrap .sutol-biz35-bub{animation:sutol-biz35-rise 3.6s ease-in infinite;}
.sutol-biz35-wrap .sutol-biz35-b1{animation-delay:0s;}
.sutol-biz35-wrap .sutol-biz35-b2{animation-delay:0.6s;}
.sutol-biz35-wrap .sutol-biz35-b3{animation-delay:1.2s;}
.sutol-biz35-wrap .sutol-biz35-b4{animation-delay:1.8s;}
.sutol-biz35-wrap .sutol-biz35-b5{animation-delay:2.4s;}
@keyframes sutol-biz35-rise{
  0%{transform:translateY(0);opacity:0;}
  15%{opacity:1;}
  100%{transform:translateY(-70px);opacity:0;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz35-wrap .sutol-biz35-bub{animation-duration:11s;}
}
</style>
```

---

## Bileşen 36: Lansman — Roket Fırlatışı

**Etiketler (keyword eşleşmesi için):** lansman, başarı, hedef, ilerleme
**Kategori:** Genel Sunum / İş
**Açıklama:** Alevi titreşen bir roketin dumanlar bırakarak yukarı doğru fırlaması ve tekrar en alta dönmesi.

```html
<div class="sutol-biz36-wrap">
  <svg class="sutol-biz36-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-biz36-rocket">
      <path d="M50,10 C58,20 58,36 50,44 C42,36 42,20 50,10 Z" fill="#3f6fb0"/>
      <rect x="46" y="40" width="8" height="16" fill="#c9d1da"/>
      <path class="sutol-biz36-flame" d="M46,56 L50,70 L54,56 Z" fill="#f2a541"/>
    </g>
    <circle class="sutol-biz36-smoke sutol-biz36-s1" cx="46" cy="90" r="3" fill="#c9d1da"/>
    <circle class="sutol-biz36-smoke sutol-biz36-s2" cx="54" cy="90" r="3" fill="#c9d1da"/>
  </svg>
</div>

<style>
.sutol-biz36-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.sutol-biz36-wrap .sutol-biz36-svg{width:100%;height:100%;display:block;}
.sutol-biz36-wrap .sutol-biz36-rocket{animation:sutol-biz36-launch 3.2s ease-in infinite;}
.sutol-biz36-wrap .sutol-biz36-flame{transform-box:fill-box;transform-origin:top;animation:sutol-biz36-flicker 0.25s ease-in-out infinite alternate;}
.sutol-biz36-wrap .sutol-biz36-smoke{animation:sutol-biz36-puff 3.2s ease-out infinite;}
.sutol-biz36-wrap .sutol-biz36-s2{animation-delay:0.4s;}
@keyframes sutol-biz36-launch{
  0%{transform:translateY(0);opacity:1;}
  75%{transform:translateY(-90px);opacity:1;}
  85%{opacity:0;}
  86%{transform:translateY(0);opacity:0;}
  95%,100%{opacity:1;}
}
@keyframes sutol-biz36-flicker{from{transform:scaleY(0.8);}to{transform:scaleY(1.2);}}
@keyframes sutol-biz36-puff{
  0%{transform:translateY(0) scale(1);opacity:0.6;}
  80%{transform:translateY(10px) scale(1.8);opacity:0;}
  100%{opacity:0;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz36-wrap .sutol-biz36-rocket,.sutol-biz36-wrap .sutol-biz36-smoke{animation-duration:10s;}
  .sutol-biz36-wrap .sutol-biz36-flame{animation-duration:0.8s;}
}
</style>
```

---

## Bileşen 37: Vizyon — Ufukta Doğan Güneş

**Etiketler (keyword eşleşmesi için):** vizyon, strateji, hedef, gelecek
**Kategori:** Genel Sunum / İş
**Açıklama:** Ufuk çizgisinin ardından yavaşça yükselen bir güneşin arkasında dönen ışın çizgileriyle geleceğe bakışın simgelenmesi.

```html
<div class="sutol-biz37-wrap">
  <svg class="sutol-biz37-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <defs>
      <clipPath id="sutol-biz37-clip">
        <rect x="0" y="0" width="100" height="65"/>
      </clipPath>
    </defs>
    <g clip-path="url(#sutol-biz37-clip)">
      <g class="sutol-biz37-rays">
        <line x1="50" y1="65" x2="50" y2="20" stroke="#f2a541" stroke-width="1" opacity="0.5"/>
        <line x1="50" y1="65" x2="20" y2="35" stroke="#f2a541" stroke-width="1" opacity="0.5"/>
        <line x1="50" y1="65" x2="80" y2="35" stroke="#f2a541" stroke-width="1" opacity="0.5"/>
        <line x1="50" y1="65" x2="15" y2="60" stroke="#f2a541" stroke-width="1" opacity="0.5"/>
        <line x1="50" y1="65" x2="85" y2="60" stroke="#f2a541" stroke-width="1" opacity="0.5"/>
      </g>
      <circle class="sutol-biz37-sun" cx="50" cy="90" r="18" fill="#f2a541"/>
    </g>
    <line x1="6" y1="65" x2="94" y2="65" stroke="#3f6fb0" stroke-width="2"/>
  </svg>
</div>

<style>
.sutol-biz37-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz37-wrap .sutol-biz37-svg{width:100%;height:100%;display:block;}
.sutol-biz37-wrap .sutol-biz37-sun{animation:sutol-biz37-rise 4.5s ease-in-out infinite;}
.sutol-biz37-wrap .sutol-biz37-rays{transform-origin:50px 65px;animation:sutol-biz37-spin 12s linear infinite;}
@keyframes sutol-biz37-rise{
  0%{transform:translateY(0);}
  60%,80%{transform:translateY(-40px);}
  100%{transform:translateY(0);}
}
@keyframes sutol-biz37-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
@media (prefers-reduced-motion: reduce){
  .sutol-biz37-wrap .sutol-biz37-sun{animation-duration:14s;}
  .sutol-biz37-wrap .sutol-biz37-rays{animation-duration:36s;}
}
</style>
```

---

## Bileşen 38: Prototip — Döner 3B Küp

**Etiketler (keyword eşleşmesi için):** prototip, proje, inovasyon, tasarım
**Kategori:** Genel Sunum / İş
**Açıklama:** Perspektifli bir sahnede altı yüzden oluşan tel çerçeveli bir küpün sürekli olarak kendi ekseninde dönmesi.

```html
<div class="sutol-biz38-wrap">
  <div class="sutol-biz38-scene">
    <div class="sutol-biz38-cube">
      <div class="sutol-biz38-face sutol-biz38-front"></div>
      <div class="sutol-biz38-face sutol-biz38-back"></div>
      <div class="sutol-biz38-face sutol-biz38-left"></div>
      <div class="sutol-biz38-face sutol-biz38-right"></div>
      <div class="sutol-biz38-face sutol-biz38-top"></div>
      <div class="sutol-biz38-face sutol-biz38-bottom"></div>
    </div>
  </div>
</div>

<style>
.sutol-biz38-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz38-wrap .sutol-biz38-scene{width:40%;height:40%;perspective:400px;}
.sutol-biz38-wrap .sutol-biz38-cube{position:relative;width:100%;height:100%;transform-style:preserve-3d;animation:sutol-biz38-rotate 8s linear infinite;}
.sutol-biz38-wrap .sutol-biz38-face{position:absolute;width:100%;height:100%;border:2px solid #3f6fb0;background:rgba(63,111,176,0.08);box-sizing:border-box;}
.sutol-biz38-wrap .sutol-biz38-front{transform:translateZ(25%);}
.sutol-biz38-wrap .sutol-biz38-back{transform:translateZ(-25%) rotateY(180deg);}
.sutol-biz38-wrap .sutol-biz38-left{transform:rotateY(-90deg) translateZ(25%);}
.sutol-biz38-wrap .sutol-biz38-right{transform:rotateY(90deg) translateZ(25%);}
.sutol-biz38-wrap .sutol-biz38-top{transform:rotateX(90deg) translateZ(25%);}
.sutol-biz38-wrap .sutol-biz38-bottom{transform:rotateX(-90deg) translateZ(25%);}
@keyframes sutol-biz38-rotate{
  from{transform:rotateX(0deg) rotateY(0deg);}
  to{transform:rotateX(360deg) rotateY(360deg);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz38-wrap .sutol-biz38-cube{animation-duration:24s;}
}
</style>
```

---

## Bileşen 39: Yatırım — Yükselen Madeni Para Kulesi

**Etiketler (keyword eşleşmesi için):** yatırım, büyüme, verimlilik, ekonomi
**Kategori:** Genel Sunum / İş
**Açıklama:** Alt alta dizilmiş madeni para şekillerinin sırayla belirerek yükselen bir kule oluşturması ve ardından baştan başlaması.

```html
<div class="sutol-biz39-wrap">
  <svg class="sutol-biz39-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <line x1="15" y1="88" x2="85" y2="88" stroke="#c9d1da" stroke-width="1.5"/>
    <ellipse class="sutol-biz39-coin sutol-biz39-c1" cx="50" cy="84" rx="16" ry="6" fill="#f2a541"/>
    <ellipse class="sutol-biz39-coin sutol-biz39-c2" cx="50" cy="70" rx="16" ry="6" fill="#f7c56d"/>
    <ellipse class="sutol-biz39-coin sutol-biz39-c3" cx="50" cy="56" rx="16" ry="6" fill="#f2a541"/>
    <ellipse class="sutol-biz39-coin sutol-biz39-c4" cx="50" cy="42" rx="16" ry="6" fill="#f7c56d"/>
    <path class="sutol-biz39-arrow" d="M74,60 L84,44 L88,52 L74,60 M84,44 L74,42" fill="none" stroke="#5bc48f" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round"/>
  </svg>
</div>

<style>
.sutol-biz39-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz39-wrap .sutol-biz39-svg{width:100%;height:100%;display:block;}
.sutol-biz39-wrap .sutol-biz39-coin{transform-box:fill-box;transform-origin:center;animation:sutol-biz39-appear 4s ease-in-out infinite;opacity:0;}
.sutol-biz39-wrap .sutol-biz39-c1{animation-delay:0s;}
.sutol-biz39-wrap .sutol-biz39-c2{animation-delay:0.5s;}
.sutol-biz39-wrap .sutol-biz39-c3{animation-delay:1s;}
.sutol-biz39-wrap .sutol-biz39-c4{animation-delay:1.5s;}
.sutol-biz39-wrap .sutol-biz39-arrow{animation:sutol-biz39-fade 4s ease-in-out infinite 1.8s;opacity:0;}
@keyframes sutol-biz39-appear{
  0%{opacity:0;transform:scale(0.4) translateY(10px);}
  15%,85%{opacity:1;transform:scale(1) translateY(0);}
  100%{opacity:0;}
}
@keyframes sutol-biz39-fade{
  0%,100%{opacity:0;}
  20%,70%{opacity:1;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz39-wrap .sutol-biz39-coin,.sutol-biz39-wrap .sutol-biz39-arrow{animation-duration:12s;}
}
</style>
```

---

## Bileşen 40: Zaman Yönetimi — Kum Saati

**Etiketler (keyword eşleşmesi için):** zaman yönetimi, süreç, verimlilik, plan
**Kategori:** Genel Sunum / İş
**Açıklama:** Üstteki kum miktarı azalırken alttaki kum yığınının büyüdüğü ve periyodik olarak ters dönen bir kum saati.

```html
<div class="sutol-biz40-wrap">
  <svg class="sutol-biz40-svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid meet">
    <g class="sutol-biz40-glass">
      <path d="M30,10 H70 V22 L52,50 L70,78 V90 H30 V78 L48,50 L30,22 Z" fill="none" stroke="#3f3f3f" stroke-width="2"/>
      <clipPath id="sutol-biz40-topClip">
        <path d="M34,14 H66 V22 L50,44 L34,22 Z"/>
      </clipPath>
      <clipPath id="sutol-biz40-bottomClip">
        <path d="M34,86 H66 V78 L50,56 L34,78 Z"/>
      </clipPath>
      <rect class="sutol-biz40-sandTop" x="34" y="14" width="32" height="30" fill="#f2a541" clip-path="url(#sutol-biz40-topClip)"/>
      <rect class="sutol-biz40-sandBottom" x="34" y="56" width="32" height="30" fill="#f2a541" clip-path="url(#sutol-biz40-bottomClip)"/>
      <circle class="sutol-biz40-drop sutol-biz40-d1" cx="50" cy="50" r="1.4" fill="#f2a541"/>
      <circle class="sutol-biz40-drop sutol-biz40-d2" cx="50" cy="50" r="1.4" fill="#f2a541"/>
    </g>
  </svg>
</div>

<style>
.sutol-biz40-wrap{width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-biz40-wrap .sutol-biz40-svg{width:100%;height:100%;display:block;}
.sutol-biz40-wrap .sutol-biz40-glass{transform-box:fill-box;transform-origin:center;animation:sutol-biz40-flip 8s ease-in-out infinite;}
.sutol-biz40-wrap .sutol-biz40-sandTop{transform-box:fill-box;transform-origin:top;animation:sutol-biz40-drain 8s linear infinite;}
.sutol-biz40-wrap .sutol-biz40-sandBottom{transform-box:fill-box;transform-origin:bottom;animation:sutol-biz40-fillup 8s linear infinite;}
.sutol-biz40-wrap .sutol-biz40-drop{animation:sutol-biz40-fall 0.6s linear infinite;}
.sutol-biz40-wrap .sutol-biz40-d2{animation-delay:0.3s;}
@keyframes sutol-biz40-flip{
  0%,88%{transform:rotate(0deg);}
  94%,100%{transform:rotate(180deg);}
}
@keyframes sutol-biz40-drain{
  0%{transform:scaleY(1);}
  85%{transform:scaleY(0.05);}
  100%{transform:scaleY(0.05);}
}
@keyframes sutol-biz40-fillup{
  0%{transform:scaleY(0.05);}
  85%{transform:scaleY(1);}
  100%{transform:scaleY(1);}
}
@keyframes sutol-biz40-fall{
  0%{transform:translateY(-2px);opacity:0.9;}
  100%{transform:translateY(6px);opacity:0;}
}
@media (prefers-reduced-motion: reduce){
  .sutol-biz40-wrap .sutol-biz40-glass,.sutol-biz40-wrap .sutol-biz40-sandTop,.sutol-biz40-wrap .sutol-biz40-sandBottom{animation-duration:24s;}
  .sutol-biz40-wrap .sutol-biz40-drop{animation-duration:1.8s;}
}
</style>
```

---

===BULLETS===
- Bileşen 21 (Toplantı — Yuvarlak Masa Bağlantısı): CSS `transform: rotate()` ile grup döndürme, GPU dostu; sabit süreli infinite animasyon, düşük maliyetli.
- Bileşen 22 (İletişim — Konuşma Balonu Değişimi): CSS keyframes ile opacity/scale/translate, `animation-delay` ile senkronizasyon; DOM güncellemesi yok, hafif.
- Bileşen 23 (Karar — Yol Ayrımı): CSS `offset-path` (motion path) ile SVG üzerinde nokta hareketi; native tarayıcı motoru kullanır, JS gerektirmez.
- Bileşen 24 (Onay — Mühür Damgası): CSS `transform: translateY/rotate` keyframes ile damga düşüşü, eşzamanlı opacity ile iz animasyonu; tamamen CSS tabanlı.
- Bileşen 25 (Sertifika — Rozet ve Kurdele): `transform-origin` + keyframes scale/rotate; küçük SVG, düşük maliyetli sürekli döngü.
- Bileşen 26 (İmza — Akan İmza Çizgisi): SVG `stroke-dasharray`/`stroke-dashoffset` çizim animasyonu; GPU dostu, tek path.
- Bileşen 27 (İş Akışı — Konveyör Hattı): CSS `translateX` keyframes ile paket hareketi, `animation-delay` ile ardışıklık; DOM sabit, sadece transform güncellenir.
- Bileşen 28 (Verimlilik — Hız Göstergesi): CSS `transform: rotate()` ile ibre salınımı, `transform-origin` pivot noktası; tek eleman animasyonu, hafif.
- Bileşen 29 (Büyüme — Filizlenen Grafik): CSS `scaleY` keyframes (fill-box origin) ile çubuk büyümesi, staggered delay; GPU dostu transform kullanımı.
- Bileşen 30 (Başarı — Zirve Bayrağı): CSS `offset-path` ile tırmanma hareketi + `skewY` keyframes ile bayrak dalgalanması; düşük maliyetli, JS yok.
- Bileşen 31 (İlerleme — Dairesel Yükleme Halkası): SVG `stroke-dashoffset` keyframes ile halka dolumu; tek path, çok hafif.
- Bileşen 32 (El Sıkışma — Anlaşma): `requestAnimationFrame` ile hafif transform güncellemesi (sadece iki grup elemanına `transform` uygulanır), ağır DOM manipülasyonu yok.
- Bileşen 33 (Veri Görselleştirme — Gösterge Paneli): Canvas + `requestAnimationFrame` ile arc çizimi; her karede `clearRect` + yeniden çizim, boyut `%` ile responsive.
- Bileşen 34 (Pazar Araştırması — Radar Taraması): CSS `rotate()` ile sürekli tarama kolu dönüşü + opacity keyframes ile blip yanıp sönmesi; GPU dostu.
- Bileşen 35 (Kullanıcı Geri Bildirimi — Yükselen Tepki Baloncukları): CSS `translateY`/`opacity` keyframes, staggered `animation-delay`; çoklu eleman ama sadece transform/opacity.
- Bileşen 36 (Lansman — Roket Fırlatışı): CSS `translateY` keyframes (uçuş) + `scaleY` (alev titreşimi) + opacity (duman); tamamen CSS, JS yok.
- Bileşen 37 (Vizyon — Ufukta Doğan Güneş): CSS `translateY` (güneş doğuşu) + `rotate()` (ışın dönüşü) kombinasyonu, `clipPath` ile ufuk maskesi; GPU dostu.
- Bileşen 38 (Prototip — Döner 3B Küp): Saf CSS 3B `perspective`/`rotateX`/`rotateY`/`translateZ` ile küp; JS yok, tamamen GPU hızlandırmalı transform.
- Bileşen 39 (Yatırım — Yükselen Madeni Para Kulesi): CSS `scale`/`opacity` keyframes staggered delay ile sıralı belirme; hafif, DOM sabit.
- Bileşen 40 (Zaman Yönetimi — Kum Saati): CSS `scaleY` (kum akışı) + `rotate(180deg)` (çevirme) + opacity/translate (damla) keyframes; tamamen CSS, `clip-path` ile şekil sınırlama.
