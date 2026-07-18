# Spor Kategorisi — 20 Animasyonlu Bileşen

---

## Bileşen 1: İnterval Antrenman — Nabız Grafiği

**Etiketler (keyword eşleşmesi için):** interval antrenman, anaerobik eşik
**Kategori:** Spor
**Açıklama:** Zikzak bir nabız eğrisi boyunca ilerleyen, hızlı-yavaş tempo değişimlerini renk değişimiyle gösteren bir nokta.

```html
<div class="sutol-spor-01-root" style="width:100%;height:100%;">
<style>
.sutol-spor-01-root{position:relative;width:100%;height:100%;}
.sutol-spor-01-svg{width:100%;height:100%;display:block;}
.sutol-spor-01-dot{offset-path:path('M20,150 L60,150 L80,60 L110,60 L130,150 L160,150 L180,60 L210,60 L230,150 L260,150 L280,60');animation:sutol-spor-01-go 3.6s linear infinite,sutol-spor-01-color 3.6s linear infinite;}
@keyframes sutol-spor-01-go{0%{offset-distance:0%;}100%{offset-distance:100%;}}
@keyframes sutol-spor-01-color{0%,20%{fill:#22c55e;}45%,55%{fill:#f97316;}80%,100%{fill:#ef4444;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-01-dot{animation-duration:12s;}
}
</style>
<svg class="sutol-spor-01-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <path d="M20,150 L60,150 L80,60 L110,60 L130,150 L160,150 L180,60 L210,60 L230,150 L260,150 L280,60" fill="none" stroke="#cbd5e1" stroke-width="3"/>
  <circle class="sutol-spor-01-dot" r="8" fill="#22c55e"/>
</svg>
</div>
```

---

## Bileşen 2: Anaerobik Eşik — Laktat Çizgisi

**Etiketler (keyword eşleşmesi için):** anaerobik eşik, interval antrenman
**Kategori:** Spor
**Açıklama:** Yükselen bir performans eğrisinin eşik çizgisini aşarken renk değiştirmesiyle anaerobik bölgeye geçişi anlatır.

```html
<div class="sutol-spor-02-root" style="width:100%;height:100%;">
<style>
.sutol-spor-02-root{position:relative;width:100%;height:100%;}
.sutol-spor-02-svg{width:100%;height:100%;display:block;}
.sutol-spor-02-curve{stroke-dasharray:400;stroke-dashoffset:400;animation:sutol-spor-02-draw 3.2s ease-in-out infinite;}
@keyframes sutol-spor-02-draw{0%{stroke-dashoffset:400;}60%{stroke-dashoffset:0;}100%{stroke-dashoffset:0;opacity:0;}}
.sutol-spor-02-threshold{animation:sutol-spor-02-glow 3.2s ease-in-out infinite;}
@keyframes sutol-spor-02-glow{0%,55%{opacity:.4;}65%,100%{opacity:.9;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-02-curve{animation-duration:10s;}
  .sutol-spor-02-threshold{animation:none;opacity:.7;}
}
</style>
<svg class="sutol-spor-02-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <line class="sutol-spor-02-threshold" x1="20" y1="90" x2="280" y2="90" stroke="#f59e0b" stroke-width="2" stroke-dasharray="6 6"/>
  <path class="sutol-spor-02-curve" d="M20,170 C90,160 130,140 160,100 C190,70 230,40 280,30" fill="none" stroke="#ef4444" stroke-width="4" stroke-linecap="round"/>
</svg>
</div>
```

---

## Bileşen 3: Doping Kontrolü — Tarama Kalkanı

**Etiketler (keyword eşleşmesi için):** doping kontrolü, spor sponsorluğu
**Kategori:** Spor
**Açıklama:** Bir kalkan simgesi üzerinde sağdan sola geçen tarama çizgisi ve periyodik olarak beliren onay işareti.

```html
<div class="sutol-spor-03-root" style="width:100%;height:100%;">
<style>
.sutol-spor-03-root{position:relative;width:100%;height:100%;}
.sutol-spor-03-svg{width:100%;height:100%;display:block;}
.sutol-spor-03-scan{animation:sutol-spor-03-sweep 2.6s ease-in-out infinite;}
@keyframes sutol-spor-03-sweep{0%{transform:translateY(-55px);opacity:.2;}50%{transform:translateY(55px);opacity:.9;}100%{transform:translateY(-55px);opacity:.2;}}
.sutol-spor-03-check{animation:sutol-spor-03-pop 2.6s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
@keyframes sutol-spor-03-pop{0%,70%{opacity:0;transform:scale(.4);}85%,100%{opacity:1;transform:scale(1);}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-03-scan{animation-duration:8s;}
  .sutol-spor-03-check{animation:none;opacity:1;}
}
</style>
<svg class="sutol-spor-03-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <path d="M150,30 L200,50 L200,110 C200,150 175,175 150,185 C125,175 100,150 100,110 L100,50 Z" fill="none" stroke="#0ea5e9" stroke-width="3"/>
  <line class="sutol-spor-03-scan" x1="105" y1="105" x2="195" y2="105" stroke="#38bdf8" stroke-width="3"/>
  <path class="sutol-spor-03-check" d="M125,110 L145,130 L180,90" fill="none" stroke="#22c55e" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
</div>
```

---

## Bileşen 4: Video Yardımcı Hakem — Tekrar İnceleme

**Etiketler (keyword eşleşmesi için):** video yardımcı hakem, oyun kurgusu
**Kategori:** Spor
**Açıklama:** Bir ekran çerçevesi içinde tekrar oynatma tarama çizgisi ve inceleme kutusunun vurgulanması.

```html
<div class="sutol-spor-04-root" style="width:100%;height:100%;">
<style>
.sutol-spor-04-root{position:relative;width:100%;height:100%;}
.sutol-spor-04-svg{width:100%;height:100%;display:block;}
.sutol-spor-04-scan{animation:sutol-spor-04-sweep 2.2s linear infinite;}
@keyframes sutol-spor-04-sweep{0%{transform:translateX(0);}100%{transform:translateX(150px);}}
.sutol-spor-04-box{animation:sutol-spor-04-blink 2.2s ease-in-out infinite;}
@keyframes sutol-spor-04-blink{0%,100%{opacity:.3;}50%{opacity:1;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-04-scan{animation-duration:7s;}
  .sutol-spor-04-box{animation:none;opacity:.8;}
}
</style>
<svg class="sutol-spor-04-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="40" width="240" height="140" rx="10" fill="none" stroke="#64748b" stroke-width="3"/>
  <rect class="sutol-spor-04-box" x="110" y="80" width="60" height="60" fill="none" stroke="#facc15" stroke-width="3" stroke-dasharray="5 5"/>
  <line class="sutol-spor-04-scan" x1="30" y1="60" x2="30" y2="160" stroke="#38bdf8" stroke-width="3"/>
</svg>
</div>
```

---

## Bileşen 5: Oyun Kurgusu — Taktik Tahtası

**Etiketler (keyword eşleşmesi için):** oyun kurgusu, savunma düzeni
**Kategori:** Spor
**Açıklama:** Bir saha çizgisinde oyuncuları temsil eden noktaların önceden çizilmiş taktik yollar boyunca hareket etmesi.

```html
<div class="sutol-spor-05-root" style="width:100%;height:100%;">
<style>
.sutol-spor-05-root{position:relative;width:100%;height:100%;}
.sutol-spor-05-svg{width:100%;height:100%;display:block;}
.sutol-spor-05-p1{offset-path:path('M60,60 Q120,90 60,140');animation:sutol-spor-05-go 3.4s ease-in-out infinite alternate;}
.sutol-spor-05-p2{offset-path:path('M150,50 Q170,100 150,150');animation:sutol-spor-05-go 3.4s ease-in-out infinite alternate;animation-delay:.3s;}
.sutol-spor-05-p3{offset-path:path('M240,60 Q180,90 240,140');animation:sutol-spor-05-go 3.4s ease-in-out infinite alternate;animation-delay:.6s;}
@keyframes sutol-spor-05-go{0%{offset-distance:0%;}100%{offset-distance:100%;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-05-p1,.sutol-spor-05-p2,.sutol-spor-05-p3{animation-duration:10s;}
}
</style>
<svg class="sutol-spor-05-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="20" width="260" height="160" fill="none" stroke="#94a3b8" stroke-width="2"/>
  <line x1="150" y1="20" x2="150" y2="180" stroke="#94a3b8" stroke-width="2"/>
  <circle class="sutol-spor-05-p1" r="8" fill="#3b82f6"/>
  <circle class="sutol-spor-05-p2" r="8" fill="#3b82f6"/>
  <circle class="sutol-spor-05-p3" r="8" fill="#3b82f6"/>
</svg>
</div>
```

---

## Bileşen 6: Savunma Düzeni — Blok Formasyonu

**Etiketler (keyword eşleşmesi için):** savunma düzeni, takım kimyası
**Kategori:** Spor
**Açıklama:** Yatay bir çizgi hâlinde duran dört savunmacının senkronize biçimde sağa sola kayarak formasyonu koruması.

```html
<div class="sutol-spor-06-root" style="width:100%;height:100%;">
<style>
.sutol-spor-06-root{position:relative;width:100%;height:100%;}
.sutol-spor-06-svg{width:100%;height:100%;display:block;}
.sutol-spor-06-row{animation:sutol-spor-06-shift 3.6s ease-in-out infinite;}
@keyframes sutol-spor-06-shift{0%,100%{transform:translateX(-25px);}50%{transform:translateX(25px);}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-06-row{animation-duration:12s;}
}
</style>
<svg class="sutol-spor-06-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <line x1="20" y1="150" x2="280" y2="150" stroke="#cbd5e1" stroke-width="2" stroke-dasharray="4 6"/>
  <g class="sutol-spor-06-row">
    <circle cx="90" cy="100" r="12" fill="#0ea5e9"/>
    <circle cx="140" cy="100" r="12" fill="#0ea5e9"/>
    <circle cx="190" cy="100" r="12" fill="#0ea5e9"/>
    <circle cx="240" cy="100" r="12" fill="#0ea5e9"/>
  </g>
</svg>
</div>
```

---

## Bileşen 7: Oyuncu Transferi — Transfer Yayı

**Etiketler (keyword eşleşmesi için):** oyuncu transferi, spor sponsorluğu
**Kategori:** Spor
**Açıklama:** Bir formanın kesikli bir yay çizgisi boyunca bir kulüpten diğerine geçiş yapması.

```html
<div class="sutol-spor-07-root" style="width:100%;height:100%;">
<style>
.sutol-spor-07-root{position:relative;width:100%;height:100%;}
.sutol-spor-07-svg{width:100%;height:100%;display:block;}
.sutol-spor-07-jersey{offset-path:path('M60,150 Q150,40 240,150');animation:sutol-spor-07-go 3.2s ease-in-out infinite;}
@keyframes sutol-spor-07-go{0%{offset-distance:0%;}100%{offset-distance:100%;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-07-jersey{animation-duration:10s;}
}
</style>
<svg class="sutol-spor-07-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <path d="M60,150 Q150,40 240,150" fill="none" stroke="#cbd5e1" stroke-width="2" stroke-dasharray="6 6"/>
  <circle cx="60" cy="150" r="14" fill="none" stroke="#3b82f6" stroke-width="3"/>
  <circle cx="240" cy="150" r="14" fill="none" stroke="#ef4444" stroke-width="3"/>
  <path class="sutol-spor-07-jersey" d="M-10,-14 L10,-14 L14,-6 L8,-3 L8,14 L-8,14 L-8,-3 L-14,-6 Z" fill="#f59e0b"/>
</svg>
</div>
```

---

## Bileşen 8: Spor Sponsorluğu — Ortaklık Rozeti

**Etiketler (keyword eşleşmesi için):** spor sponsorluğu, takım kimyası
**Kategori:** Spor
**Açıklama:** Merkezdeki bir rozetten dışa doğru genişleyen nabız halkaları, marka ortaklığının etkisini simgeler.

```html
<div class="sutol-spor-08-root" style="width:100%;height:100%;">
<style>
.sutol-spor-08-root{position:relative;width:100%;height:100%;}
.sutol-spor-08-svg{width:100%;height:100%;display:block;}
.sutol-spor-08-ring{transform-box:fill-box;transform-origin:center;animation:sutol-spor-08-pulse 3s ease-out infinite;}
.sutol-spor-08-ring:nth-child(2){animation-delay:1s;}
.sutol-spor-08-ring:nth-child(3){animation-delay:2s;}
@keyframes sutol-spor-08-pulse{0%{transform:scale(.5);opacity:.8;}100%{transform:scale(1.5);opacity:0;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-08-ring{animation:none;opacity:.25;}
}
</style>
<svg class="sutol-spor-08-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <circle class="sutol-spor-08-ring" cx="150" cy="150" r="50" fill="none" stroke="#facc15" stroke-width="3"/>
  <circle class="sutol-spor-08-ring" cx="150" cy="150" r="50" fill="none" stroke="#facc15" stroke-width="3"/>
  <circle class="sutol-spor-08-ring" cx="150" cy="150" r="50" fill="none" stroke="#facc15" stroke-width="3"/>
  <path d="M150,120 L160,145 L188,145 L165,162 L174,188 L150,172 L126,188 L135,162 L112,145 L140,145 Z" fill="#f59e0b"/>
</svg>
</div>
```

---

## Bileşen 9: E-Spor Turnuvası — Eşleşme Ağacı

**Etiketler (keyword eşleşmesi için):** e-spor turnuvası, oyuncu transferi
**Kategori:** Spor
**Açıklama:** Bir turnuva ağacındaki eşleşme çizgilerinin soldan sağa doğru sırayla aydınlanarak final noktasına ulaşması.

```html
<div class="sutol-spor-09-root" style="width:100%;height:100%;">
<style>
.sutol-spor-09-root{position:relative;width:100%;height:100%;}
.sutol-spor-09-svg{width:100%;height:100%;display:block;}
.sutol-spor-09-seg{stroke-dasharray:60;stroke-dashoffset:60;animation:sutol-spor-09-draw 3s ease-in-out infinite;}
.sutol-spor-09-seg:nth-child(1){animation-delay:0s;}
.sutol-spor-09-seg:nth-child(2){animation-delay:.4s;}
.sutol-spor-09-seg:nth-child(3){animation-delay:.8s;}
.sutol-spor-09-seg:nth-child(4){animation-delay:1.2s;}
@keyframes sutol-spor-09-draw{0%{stroke-dashoffset:60;opacity:.3;}40%{stroke-dashoffset:0;opacity:1;}80%,100%{opacity:.3;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-09-seg{animation:none;stroke-dashoffset:0;opacity:.7;}
}
</style>
<svg class="sutol-spor-09-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <g fill="none" stroke="#a78bfa" stroke-width="3">
    <path class="sutol-spor-09-seg" d="M20,40 L80,40 L80,90"/>
    <path class="sutol-spor-09-seg" d="M20,140 L80,140 L80,90"/>
    <path class="sutol-spor-09-seg" d="M80,90 L160,90 L160,110"/>
    <path class="sutol-spor-09-seg" d="M160,110 L240,110"/>
  </g>
  <circle cx="240" cy="110" r="8" fill="#7c3aed"/>
</svg>
</div>
```

---

## Bileşen 10: Paralimpik — Tekerlekli Yarış

**Etiketler (keyword eşleşmesi için):** paralimpik, ekstrem spor
**Kategori:** Spor
**Açıklama:** Hızla dönen bir yarış tekerleğinin ardında bırakılan hız çizgileriyle temsil edilen paralimpik atletizm.

```html
<div class="sutol-spor-10-root" style="width:100%;height:100%;">
<style>
.sutol-spor-10-root{position:relative;width:100%;height:100%;}
.sutol-spor-10-svg{width:100%;height:100%;display:block;}
.sutol-spor-10-wheel{transform-box:fill-box;transform-origin:center;animation:sutol-spor-10-spin 1.4s linear infinite;}
@keyframes sutol-spor-10-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
.sutol-spor-10-speed{animation:sutol-spor-10-fade 1.4s ease-in-out infinite;}
@keyframes sutol-spor-10-fade{0%,100%{opacity:.2;}50%{opacity:.8;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-10-wheel{animation-duration:6s;}
  .sutol-spor-10-speed{animation:none;opacity:.4;}
}
</style>
<svg class="sutol-spor-10-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <line class="sutol-spor-10-speed" x1="20" y1="90" x2="120" y2="90" stroke="#94a3b8" stroke-width="3"/>
  <line class="sutol-spor-10-speed" x1="20" y1="110" x2="100" y2="110" stroke="#94a3b8" stroke-width="3"/>
  <g class="sutol-spor-10-wheel" stroke="#0ea5e9" stroke-width="3" fill="none">
    <circle cx="190" cy="100" r="45"/>
    <line x1="190" y1="55" x2="190" y2="145"/>
    <line x1="145" y1="100" x2="235" y2="100"/>
    <line x1="160" y1="65" x2="220" y2="135"/>
    <line x1="220" y1="65" x2="160" y2="135"/>
  </g>
</svg>
</div>
```

---

## Bileşen 11: Ekstrem Spor — Yamaç Paraşütü

**Etiketler (keyword eşleşmesi için):** ekstrem spor, triatlon
**Kategori:** Spor
**Açıklama:** Rüzgâr akım çizgileri arasında süzülen bir yamaç paraşütü kanadının yumuşak sallanma hareketi.

```html
<div class="sutol-spor-11-root" style="width:100%;height:100%;">
<style>
.sutol-spor-11-root{position:relative;width:100%;height:100%;}
.sutol-spor-11-svg{width:100%;height:100%;display:block;}
.sutol-spor-11-wing{animation:sutol-spor-11-sway 3.4s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
@keyframes sutol-spor-11-sway{0%,100%{transform:translateY(0) rotate(-2deg);}50%{transform:translateY(14px) rotate(2deg);}}
.sutol-spor-11-wind{stroke-dasharray:8 8;animation:sutol-spor-11-flow 2s linear infinite;}
@keyframes sutol-spor-11-flow{to{stroke-dashoffset:-16;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-11-wing{animation-duration:12s;}
  .sutol-spor-11-wind{animation:none;}
}
</style>
<svg class="sutol-spor-11-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <line class="sutol-spor-11-wind" x1="20" y1="60" x2="280" y2="60" stroke="#7dd3fc" stroke-width="2" opacity=".5"/>
  <line class="sutol-spor-11-wind" x1="20" y1="150" x2="280" y2="150" stroke="#7dd3fc" stroke-width="2" opacity=".5"/>
  <g class="sutol-spor-11-wing">
    <path d="M90,90 Q150,60 210,90 Q150,105 90,90 Z" fill="#f97316"/>
    <line x1="110" y1="95" x2="130" y2="140" stroke="#475569" stroke-width="2"/>
    <line x1="190" y1="95" x2="170" y2="140" stroke="#475569" stroke-width="2"/>
    <circle cx="150" cy="145" r="8" fill="#1e293b"/>
  </g>
</svg>
</div>
```

---

## Bileşen 12: Tırmanış — Duvar Tırmanışı

**Etiketler (keyword eşleşmesi için):** tırmanış, ekstrem spor
**Kategori:** Spor
**Açıklama:** Bir tırmanıcının zikzak tutamaklar boyunca duvarı yukarı doğru sürekli tırmanması.

```html
<div class="sutol-spor-12-root" style="width:100%;height:100%;">
<style>
.sutol-spor-12-root{position:relative;width:100%;height:100%;}
.sutol-spor-12-svg{width:100%;height:100%;display:block;}
.sutol-spor-12-climber{offset-path:path('M240,180 L200,150 L240,120 L200,90 L240,60 L200,30');animation:sutol-spor-12-go 4s ease-in-out infinite;}
@keyframes sutol-spor-12-go{0%{offset-distance:0%;}100%{offset-distance:100%;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-12-climber{animation-duration:14s;}
}
</style>
<svg class="sutol-spor-12-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <rect x="60" y="10" width="20" height="180" fill="#e2e8f0" opacity=".4"/>
  <circle cx="240" cy="180" r="6" fill="#94a3b8"/>
  <circle cx="200" cy="150" r="6" fill="#94a3b8"/>
  <circle cx="240" cy="120" r="6" fill="#94a3b8"/>
  <circle cx="200" cy="90" r="6" fill="#94a3b8"/>
  <circle cx="240" cy="60" r="6" fill="#94a3b8"/>
  <circle cx="200" cy="30" r="6" fill="#94a3b8"/>
  <circle class="sutol-spor-12-climber" r="10" fill="#dc2626"/>
</svg>
</div>
```

---

## Bileşen 13: Triatlon — Üçlü Disiplin Döngüsü

**Etiketler (keyword eşleşmesi için):** triatlon, interval antrenman
**Kategori:** Spor
**Açıklama:** Yüzme-bisiklet-koşu bölümlerine ayrılmış dairesel bir pist üzerinde sürekli dönen bir nokta.

```html
<div class="sutol-spor-13-root" style="width:100%;height:100%;">
<style>
.sutol-spor-13-root{position:relative;width:100%;height:100%;}
.sutol-spor-13-svg{width:100%;height:100%;display:block;}
.sutol-spor-13-dot{offset-path:path('M150,60 A90,90 0 1,1 149,60');animation:sutol-spor-13-go 6s linear infinite;}
@keyframes sutol-spor-13-go{0%{offset-distance:0%;}100%{offset-distance:100%;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-13-dot{animation-duration:18s;}
}
</style>
<svg class="sutol-spor-13-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <path d="M150,60 A90,90 0 0,1 227,150" fill="none" stroke="#0ea5e9" stroke-width="8"/>
  <path d="M227,150 A90,90 0 0,1 118,232" fill="none" stroke="#f97316" stroke-width="8"/>
  <path d="M118,232 A90,90 0 0,1 150,60" fill="none" stroke="#22c55e" stroke-width="8"/>
  <circle class="sutol-spor-13-dot" r="9" fill="#1e293b"/>
</svg>
</div>
```

---

## Bileşen 14: Takım Kimyası — Bağ Ağı

**Etiketler (keyword eşleşmesi için):** takım kimyası, savunma düzeni
**Kategori:** Spor
**Açıklama:** Birbirine bağlı düğümlerin senkronize biçimde nabız gibi parlayarak takım uyumunu simgelemesi.

```html
<div class="sutol-spor-14-root" style="width:100%;height:100%;">
<style>
.sutol-spor-14-root{position:relative;width:100%;height:100%;}
.sutol-spor-14-svg{width:100%;height:100%;display:block;}
.sutol-spor-14-node{animation:sutol-spor-14-pulse 2.4s ease-in-out infinite;transform-box:fill-box;transform-origin:center;}
.sutol-spor-14-node:nth-child(2){animation-delay:.3s;}
.sutol-spor-14-node:nth-child(3){animation-delay:.6s;}
.sutol-spor-14-node:nth-child(4){animation-delay:.9s;}
.sutol-spor-14-node:nth-child(5){animation-delay:1.2s;}
@keyframes sutol-spor-14-pulse{0%,100%{transform:scale(1);}50%{transform:scale(1.35);}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-14-node{animation:none;}
}
</style>
<svg class="sutol-spor-14-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <g stroke="#94a3b8" stroke-width="2" opacity=".6">
    <line x1="150" y1="150" x2="90" y2="90"/>
    <line x1="150" y1="150" x2="210" y2="90"/>
    <line x1="150" y1="150" x2="90" y2="210"/>
    <line x1="150" y1="150" x2="210" y2="210"/>
  </g>
  <circle class="sutol-spor-14-node" cx="150" cy="150" r="14" fill="#7c3aed"/>
  <circle class="sutol-spor-14-node" cx="90" cy="90" r="10" fill="#a78bfa"/>
  <circle class="sutol-spor-14-node" cx="210" cy="90" r="10" fill="#a78bfa"/>
  <circle class="sutol-spor-14-node" cx="90" cy="210" r="10" fill="#a78bfa"/>
  <circle class="sutol-spor-14-node" cx="210" cy="210" r="10" fill="#a78bfa"/>
</svg>
</div>
```

---

## Bileşen 15: İnterval Antrenman — Kronometre Ritmi

**Etiketler (keyword eşleşmesi için):** interval antrenman, anaerobik eşik
**Kategori:** Spor
**Açıklama:** Bir kronometre kadranındaki ibrenin dönüş hızının hızlı ve yavaş segmentler arasında değişmesi.

```html
<div class="sutol-spor-15-root" style="width:100%;height:100%;">
<style>
.sutol-spor-15-root{position:relative;width:100%;height:100%;}
.sutol-spor-15-svg{width:100%;height:100%;display:block;}
.sutol-spor-15-hand{transform-box:fill-box;transform-origin:150px 150px;animation:sutol-spor-15-tick 4s cubic-bezier(.6,0,.4,1) infinite;}
@keyframes sutol-spor-15-tick{
  0%{transform:rotate(0deg);}
  40%{transform:rotate(300deg);}
  50%{transform:rotate(300deg);}
  100%{transform:rotate(660deg);}
}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-15-hand{animation-duration:14s;}
}
</style>
<svg class="sutol-spor-15-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <circle cx="150" cy="150" r="80" fill="none" stroke="#94a3b8" stroke-width="4"/>
  <circle cx="150" cy="90" r="3" fill="#64748b"/>
  <circle cx="150" cy="210" r="3" fill="#64748b"/>
  <circle cx="90" cy="150" r="3" fill="#64748b"/>
  <circle cx="210" cy="150" r="3" fill="#64748b"/>
  <line class="sutol-spor-15-hand" x1="150" y1="150" x2="150" y2="85" stroke="#0ea5e9" stroke-width="5" stroke-linecap="round"/>
  <circle cx="150" cy="150" r="6" fill="#0ea5e9"/>
</svg>
</div>
```

---

## Bileşen 16: Anaerobik Eşik — Hız Kapısı

**Etiketler (keyword eşleşmesi için):** anaerobik eşik, ekstrem spor
**Kategori:** Spor
**Açıklama:** Giderek yoğunlaşan hız çizgilerinin bir eşik kapısından geçerken renk değiştirmesi.

```html
<div class="sutol-spor-16-root" style="width:100%;height:100%;">
<style>
.sutol-spor-16-root{position:relative;width:100%;height:100%;}
.sutol-spor-16-svg{width:100%;height:100%;display:block;}
.sutol-spor-16-line{stroke-dasharray:30 20;animation:sutol-spor-16-move 1.6s linear infinite;}
@keyframes sutol-spor-16-move{to{stroke-dashoffset:-50;}}
.sutol-spor-16-gate{animation:sutol-spor-16-flash 1.6s ease-in-out infinite;}
@keyframes sutol-spor-16-flash{0%,100%{opacity:.4;}50%{opacity:1;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-16-line{animation:none;}
  .sutol-spor-16-gate{animation:none;opacity:.7;}
}
</style>
<svg class="sutol-spor-16-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <line class="sutol-spor-16-gate" x1="200" y1="30" x2="200" y2="170" stroke="#f59e0b" stroke-width="4"/>
  <line class="sutol-spor-16-line" x1="20" y1="70" x2="180" y2="70" stroke="#3b82f6" stroke-width="4"/>
  <line class="sutol-spor-16-line" x1="20" y1="100" x2="180" y2="100" stroke="#3b82f6" stroke-width="4"/>
  <line class="sutol-spor-16-line" x1="20" y1="130" x2="180" y2="130" stroke="#3b82f6" stroke-width="4"/>
</svg>
</div>
```

---

## Bileşen 17: Savunma Düzeni — Kalkan Orbiti

**Etiketler (keyword eşleşmesi için):** savunma düzeni, paralimpik
**Kategori:** Spor
**Açıklama:** Merkezi bir kale noktasının etrafında dönen savunmacıların koruyucu bir yörünge oluşturması.

```html
<div class="sutol-spor-17-root" style="width:100%;height:100%;">
<style>
.sutol-spor-17-root{position:relative;width:100%;height:100%;}
.sutol-spor-17-svg{width:100%;height:100%;display:block;}
.sutol-spor-17-orbit{transform-box:fill-box;transform-origin:150px 150px;animation:sutol-spor-17-spin 5s linear infinite;}
@keyframes sutol-spor-17-spin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-17-orbit{animation-duration:16s;}
}
</style>
<svg class="sutol-spor-17-svg" viewBox="0 0 300 300" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <circle cx="150" cy="150" r="14" fill="#0ea5e9"/>
  <g class="sutol-spor-17-orbit">
    <circle cx="150" cy="80" r="9" fill="#1e293b"/>
    <circle cx="220" cy="150" r="9" fill="#1e293b"/>
    <circle cx="150" cy="220" r="9" fill="#1e293b"/>
    <circle cx="80" cy="150" r="9" fill="#1e293b"/>
    <circle cx="199" cy="99" r="9" fill="#1e293b"/>
    <circle cx="199" cy="201" r="9" fill="#1e293b"/>
  </g>
</svg>
</div>
```

---

## Bileşen 18: Oyuncu Transferi — Forma Değişimi

**Etiketler (keyword eşleşmesi için):** oyuncu transferi, e-spor turnuvası
**Kategori:** Spor
**Açıklama:** Bir figürün kesikli bir sınır çizgisini geçerken forma renginin bir takımdan diğerine dönüşmesi.

```html
<div class="sutol-spor-18-root" style="width:100%;height:100%;">
<style>
.sutol-spor-18-root{position:relative;width:100%;height:100%;}
.sutol-spor-18-svg{width:100%;height:100%;display:block;}
.sutol-spor-18-figure{offset-path:path('M50,150 L250,150');animation:sutol-spor-18-move 3.4s ease-in-out infinite,sutol-spor-18-color 3.4s ease-in-out infinite;}
@keyframes sutol-spor-18-move{0%{offset-distance:0%;}100%{offset-distance:100%;}}
@keyframes sutol-spor-18-color{0%,45%{fill:#3b82f6;}55%,100%{fill:#ef4444;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-18-figure{animation-duration:12s;}
}
</style>
<svg class="sutol-spor-18-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <line x1="150" y1="30" x2="150" y2="170" stroke="#cbd5e1" stroke-width="2" stroke-dasharray="6 6"/>
  <rect class="sutol-spor-18-figure" x="-14" y="-16" width="28" height="32" rx="6" fill="#3b82f6"/>
</svg>
</div>
```

---

## Bileşen 19: Tırmanış — İp ve Karabina

**Etiketler (keyword eşleşmesi için):** tırmanış, doping kontrolü
**Kategori:** Spor
**Açıklama:** Dikey bir ip boyunca sallanarak yukarı ilerleyen bir karabina halkasının güvenli yükselişi.

```html
<div class="sutol-spor-19-root" style="width:100%;height:100%;">
<style>
.sutol-spor-19-root{position:relative;width:100%;height:100%;}
.sutol-spor-19-svg{width:100%;height:100%;display:block;}
.sutol-spor-19-clip{offset-path:path('M150,190 L150,20');animation:sutol-spor-19-go 4.2s linear infinite;}
@keyframes sutol-spor-19-go{0%{offset-distance:0%;}100%{offset-distance:100%;}}
.sutol-spor-19-sway{animation:sutol-spor-19-wob 1.2s ease-in-out infinite;transform-box:fill-box;transform-origin:top center;}
@keyframes sutol-spor-19-wob{0%,100%{transform:rotate(-6deg);}50%{transform:rotate(6deg);}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-19-clip{animation-duration:14s;}
  .sutol-spor-19-sway{animation:none;}
}
</style>
<svg class="sutol-spor-19-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <line x1="150" y1="10" x2="150" y2="190" stroke="#94a3b8" stroke-width="3" stroke-dasharray="2 6"/>
  <g class="sutol-spor-19-clip">
    <g class="sutol-spor-19-sway">
      <circle r="10" fill="none" stroke="#f59e0b" stroke-width="4"/>
    </g>
  </g>
</svg>
</div>
```

---

## Bileşen 20: Ekstrem Spor — Dalga Sörfü

**Etiketler (keyword eşleşmesi için):** ekstrem spor, triatlon
**Kategori:** Spor
**Açıklama:** Yükselen ve alçalan bir dalga eğrisi üzerinde kayan bir sörf tahtasının sürekli hareketi.

```html
<div class="sutol-spor-20-root" style="width:100%;height:100%;">
<style>
.sutol-spor-20-root{position:relative;width:100%;height:100%;}
.sutol-spor-20-svg{width:100%;height:100%;display:block;}
.sutol-spor-20-wave{stroke-dasharray:10 6;animation:sutol-spor-20-flow 2s linear infinite;}
@keyframes sutol-spor-20-flow{to{stroke-dashoffset:-16;}}
.sutol-spor-20-board{offset-path:path('M30,120 Q90,80 150,120 T270,120');animation:sutol-spor-20-ride 3.6s ease-in-out infinite;}
@keyframes sutol-spor-20-ride{0%{offset-distance:0%;}100%{offset-distance:100%;}}
@media (prefers-reduced-motion: reduce){
  .sutol-spor-20-wave{animation:none;}
  .sutol-spor-20-board{animation-duration:12s;}
}
</style>
<svg class="sutol-spor-20-svg" viewBox="0 0 300 200" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">
  <path class="sutol-spor-20-wave" d="M30,120 Q90,80 150,120 T270,120" fill="none" stroke="#0ea5e9" stroke-width="3"/>
  <ellipse class="sutol-spor-20-board" rx="16" ry="5" fill="#f97316"/>
</svg>
</div>
```

---

## Kalite Kontrol Özeti

- **01 İnterval Antrenman:** `offset-path` + eşzamanlı `fill` renk döngüsü; hafif, 60fps uyumlu.
- **02 Anaerobik Eşik:** `stroke-dashoffset` çizim efekti + eşik çizgisi `opacity` nabzı; hafif.
- **03 Doping Kontrolü:** `translateY` tarama çizgisi + gecikmeli onay işareti `scale`; hafif.
- **04 VAR:** `translateX` tarama + kutu `opacity` nabzı; çok hafif.
- **05 Oyun Kurgusu:** Üç `offset-path` (alternate) oyuncu hareketi; orta.
- **06 Savunma Düzeni:** Grup `translateX` senkron kayma; çok hafif.
- **07 Oyuncu Transferi:** Tek `offset-path` yay geçişi; hafif.
- **08 Spor Sponsorluğu:** Üç gecikmeli halka `scale/opacity`; hafif.
- **09 E-Spor Turnuvası:** Dört gecikmeli `stroke-dashoffset` çizim animasyonu; orta.
- **10 Paralimpik:** Tekerlek `rotate` + iki hız çizgisi `opacity`; hafif.
- **11 Ekstrem Spor (Yamaç Paraşütü):** `translateY/rotate` sallanma + `stroke-dashoffset` rüzgâr çizgileri; hafif.
- **12 Tırmanış:** Zikzak `offset-path` tırmanış; hafif.
- **13 Triatlon:** Dairesel `offset-path` döngü; çok hafif.
- **14 Takım Kimyası:** Beş gecikmeli düğüm `scale` nabzı; hafif.
- **15 İnterval Antrenman (Kronometre):** `cubic-bezier` ile değişken hızlı ibre `rotate`; hafif.
- **16 Anaerobik Eşik (Hız Kapısı):** `stroke-dashoffset` akışı + kapı `opacity` flaşı; hafif.
- **17 Savunma Düzeni (Kalkan Orbiti):** Grup `rotate` yörünge; çok hafif.
- **18 Oyuncu Transferi (Forma Değişimi):** `offset-path` + eşzamanlı `fill` renk geçişi; hafif.
- **19 Tırmanış (İp ve Karabina):** Dikey `offset-path` + iç grup `rotate` salınımı; hafif.
- **20 Ekstrem Spor (Dalga Sörfü):** `stroke-dashoffset` dalga akışı + `offset-path` tahta sürüşü; orta.

Tüm bileşenler `prefers-reduced-motion` desteği içerir, şeffaf arka plana sahiptir, `viewBox` ile ölçeklenir, dış kaynak kullanmaz ve benzersiz `sutol-spor-NN-` sınıf önekleriyle kapsüllenmiştir.
