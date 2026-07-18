## Bileşen 21: Vinil Plak Oluk Işın Halkaları

**Etiketler (keyword eşleşmesi için):** plak, ses dalgası, akustik, rezonans
**Kategori:** Müzik
**Açıklama:** Merkezden dışa doğru genişleyen, plağın oluklarından yayılan ışın halkalarını simgeler.

```html
<div class="sutol-muz21-wrap">
<style>
.sutol-muz21-wrap{position:relative;width:100%;height:100%;background:transparent;overflow:hidden;}
.sutol-muz21-wrap svg{width:100%;height:100%;display:block;}
.sutol-muz21-ring{fill:none;stroke:#d4af37;stroke-width:1.5;transform-origin:50px 50px;animation:sutol-muz21-expand 2.4s ease-out infinite;}
.sutol-muz21-ring:nth-child(2){animation-delay:0.6s;}
.sutol-muz21-ring:nth-child(3){animation-delay:1.2s;}
.sutol-muz21-ring:nth-child(4){animation-delay:1.8s;}
.sutol-muz21-core{fill:#2b2b2b;}
@keyframes sutol-muz21-expand{
0%{transform:scale(0.2);opacity:0;}
15%{opacity:0.9;}
100%{transform:scale(1.6);opacity:0;}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz21-ring{animation-duration:7.2s;}
}
</style>
<svg viewBox="0 0 100 100" class="sutol-muz21-svg">
<circle class="sutol-muz21-core" cx="50" cy="50" r="6"/>
<circle class="sutol-muz21-ring" cx="50" cy="50" r="10"/>
<circle class="sutol-muz21-ring" cx="50" cy="50" r="10"/>
<circle class="sutol-muz21-ring" cx="50" cy="50" r="10"/>
<circle class="sutol-muz21-ring" cx="50" cy="50" r="10"/>
</svg>
</div>
```

---

## Bileşen 22: Kulaklık Ses Dalgası Yayılımı

**Etiketler (keyword eşleşmesi için):** ses, ses dalgası, frekans, dinleme
**Kategori:** Müzik
**Açıklama:** Bir kulaklığın kulak yastığından dışa doğru yayılan eşmerkezli ses halkalarını gösterir.

```html
<div class="sutol-muz22-wrap">
<style>
.sutol-muz22-wrap{position:relative;width:100%;height:100%;background:transparent;}
.sutol-muz22-wrap svg{width:100%;height:100%;display:block;}
.sutol-muz22-band{fill:none;stroke:#444;stroke-width:4;stroke-linecap:round;}
.sutol-muz22-cup{fill:#333;}
.sutol-muz22-wave{fill:none;stroke:#4fc3f7;stroke-width:1.5;opacity:0;animation:sutol-muz22-pulse 2s ease-out infinite;}
.sutol-muz22-wave.b{animation-delay:0.6s;}
.sutol-muz22-wave.c{animation-delay:1.2s;}
@keyframes sutol-muz22-pulse{
0%{opacity:0.8;transform:scale(0.6);}
100%{opacity:0;transform:scale(1.8);}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz22-wave{animation-duration:6s;}
}
</style>
<svg viewBox="0 0 100 100" class="sutol-muz22-svg">
<path class="sutol-muz22-band" d="M20,45 A30,30 0 0,1 80,45"/>
<rect class="sutol-muz22-cup" x="12" y="42" width="12" height="20" rx="5"/>
<rect class="sutol-muz22-cup" x="76" y="42" width="12" height="20" rx="5"/>
<g style="transform-origin:82px 52px;">
<circle class="sutol-muz22-wave" cx="82" cy="52" r="8"/>
<circle class="sutol-muz22-wave b" cx="82" cy="52" r="8"/>
<circle class="sutol-muz22-wave c" cx="82" cy="52" r="8"/>
</g>
</svg>
</div>
```

---

## Bileşen 23: Ksilofon Çubuk Sıçraması

**Etiketler (keyword eşleşmesi için):** enstrüman, ritim, tempo, performans
**Kategori:** Müzik
**Açıklama:** Farklı uzunluktaki ksilofon çubuklarının art arda zıplayarak vurulma hareketini canlandırır.

```html
<div class="sutol-muz23-wrap">
<style>
.sutol-muz23-wrap{position:relative;width:100%;height:100%;background:transparent;display:flex;align-items:flex-end;justify-content:center;gap:4%;padding:10% 5%;box-sizing:border-box;}
.sutol-muz23-bar{width:8%;background:linear-gradient(180deg,#e07a3f,#b85c28);border-radius:3px;animation:sutol-muz23-bounce 1.6s ease-in-out infinite;}
.sutol-muz23-bar:nth-child(1){height:40%;animation-delay:0s;}
.sutol-muz23-bar:nth-child(2){height:55%;animation-delay:0.15s;}
.sutol-muz23-bar:nth-child(3){height:70%;animation-delay:0.3s;}
.sutol-muz23-bar:nth-child(4){height:85%;animation-delay:0.45s;}
.sutol-muz23-bar:nth-child(5){height:65%;animation-delay:0.6s;}
.sutol-muz23-bar:nth-child(6){height:50%;animation-delay:0.75s;}
@keyframes sutol-muz23-bounce{
0%,100%{transform:translateY(0) scaleY(1);}
50%{transform:translateY(-15%) scaleY(0.92);}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz23-bar{animation-duration:4.8s;}
}
</style>
<div class="sutol-muz23-bar"></div>
<div class="sutol-muz23-bar"></div>
<div class="sutol-muz23-bar"></div>
<div class="sutol-muz23-bar"></div>
<div class="sutol-muz23-bar"></div>
<div class="sutol-muz23-bar"></div>
</div>
```

---

## Bileşen 24: Trompet Ses Huzmesi

**Etiketler (keyword eşleşmesi için):** enstrüman, performans, ses, sahne
**Kategori:** Müzik
**Açıklama:** Trompet ağzından dışa doğru üç yönde patlayan ses huzmesi ışınlarını gösterir.

```html
<div class="sutol-muz24-wrap">
<style>
.sutol-muz24-wrap{position:relative;width:100%;height:100%;background:transparent;}
.sutol-muz24-wrap svg{width:100%;height:100%;display:block;}
.sutol-muz24-body{fill:none;stroke:#c9a227;stroke-width:3;stroke-linecap:round;}
.sutol-muz24-bell{fill:#c9a227;}
.sutol-muz24-ray{stroke:#ffd66b;stroke-width:1.5;stroke-linecap:round;}
</style>
<svg viewBox="0 0 100 100" class="sutol-muz24-svg">
<path class="sutol-muz24-body" d="M10,50 L55,50"/>
<path class="sutol-muz24-body" d="M20,42 L20,58 M35,42 L35,58"/>
<path class="sutol-muz24-bell" d="M55,38 L80,50 L55,62 Z"/>
<line class="sutol-muz24-ray" x1="82" y1="50" x2="95" y2="50">
<animate attributeName="opacity" values="0;1;0" dur="1.4s" repeatCount="indefinite"/>
<animate attributeName="x2" values="82;98;82" dur="1.4s" repeatCount="indefinite"/>
</line>
<line class="sutol-muz24-ray" x1="80" y1="42" x2="93" y2="34">
<animate attributeName="opacity" values="0;1;0" dur="1.4s" begin="0.3s" repeatCount="indefinite"/>
<animate attributeName="x2" values="80;96;80" dur="1.4s" begin="0.3s" repeatCount="indefinite"/>
</line>
<line class="sutol-muz24-ray" x1="80" y1="58" x2="93" y2="66">
<animate attributeName="opacity" values="0;1;0" dur="1.4s" begin="0.6s" repeatCount="indefinite"/>
<animate attributeName="x2" values="80;96;80" dur="1.4s" begin="0.6s" repeatCount="indefinite"/>
</line>
</svg>
<script>
(function(){
var svg = document.currentScript.previousElementSibling;
if(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches){
if(svg && svg.pauseAnimations) svg.pauseAnimations();
}
})();
</script>
</div>
```

---

## Bileşen 25: Bateri Hi-Hat Çarpışması

**Etiketler (keyword eşleşmesi için):** davul, ritim, performans, tempo
**Kategori:** Müzik
**Açıklama:** İki zilin (hi-hat) 3B perspektifte açılıp kapanarak çarpışması ve etrafa saçılan kıvılcımları canlandırır.

```html
<div class="sutol-muz25-wrap">
<style>
.sutol-muz25-wrap{position:relative;width:100%;height:100%;background:transparent;perspective:300px;display:flex;align-items:center;justify-content:center;}
.sutol-muz25-stage{position:relative;width:60%;height:60%;transform-style:preserve-3d;}
.sutol-muz25-cymbal{position:absolute;top:50%;left:50%;width:90%;height:18%;margin:-9% 0 0 -45%;border-radius:50%;background:radial-gradient(circle,#e8d27a,#a8862f);}
.sutol-muz25-cymbal.top{animation:sutol-muz25-clash-top 1.2s ease-in-out infinite;}
.sutol-muz25-cymbal.bottom{animation:sutol-muz25-clash-bottom 1.2s ease-in-out infinite;}
.sutol-muz25-spark{position:absolute;top:50%;left:50%;width:4%;height:4%;background:#fff2b0;border-radius:50%;opacity:0;animation:sutol-muz25-spark 1.2s ease-out infinite;}
.sutol-muz25-spark:nth-child(3){animation-delay:0s;}
.sutol-muz25-spark:nth-child(4){animation-delay:0.05s;}
.sutol-muz25-spark:nth-child(5){animation-delay:0.1s;}
@keyframes sutol-muz25-clash-top{
0%,100%{transform:translateZ(20px) rotateX(20deg);}
50%{transform:translateZ(2px) rotateX(0deg);}
}
@keyframes sutol-muz25-clash-bottom{
0%,100%{transform:translateZ(-20px) rotateX(-20deg);}
50%{transform:translateZ(-2px) rotateX(0deg);}
}
@keyframes sutol-muz25-spark{
0%{opacity:0;transform:translate(-50%,-50%) scale(0.4);}
30%{opacity:1;}
100%{opacity:0;transform:translate(-50%,-50%) scale(1) translateX(60%) translateY(-40%);}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz25-cymbal,.sutol-muz25-spark{animation-duration:4.8s;}
}
</style>
<div class="sutol-muz25-stage">
<div class="sutol-muz25-cymbal bottom"></div>
<div class="sutol-muz25-cymbal top"></div>
<div class="sutol-muz25-spark"></div>
<div class="sutol-muz25-spark"></div>
<div class="sutol-muz25-spark"></div>
</div>
</div>
```

---

## Bileşen 26: Akordeon Körüğü Açılışı

**Etiketler (keyword eşleşmesi için):** enstrüman, halk müziği, performans, ritim
**Kategori:** Müzik
**Açıklama:** Akordeon körüğünün pililerinin nefes alır gibi açılıp kapanmasını canlandırır.

```html
<div class="sutol-muz26-wrap">
<style>
.sutol-muz26-wrap{position:relative;width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-muz26-box{display:flex;align-items:stretch;width:70%;height:50%;}
.sutol-muz26-end{width:15%;background:#5b3a29;border-radius:4px;}
.sutol-muz26-bellows{flex:1;display:flex;}
.sutol-muz26-pleat{flex:1;background:linear-gradient(120deg,#c94f4f,#8a2f2f);margin:0 1px;animation:sutol-muz26-breathe 2.4s ease-in-out infinite;transform-origin:center;}
.sutol-muz26-pleat:nth-child(odd){background:linear-gradient(120deg,#8a2f2f,#c94f4f);}
@keyframes sutol-muz26-breathe{
0%,100%{transform:scaleX(1);}
50%{transform:scaleX(0.4);}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz26-pleat{animation-duration:7.2s;}
}
</style>
<div class="sutol-muz26-box">
<div class="sutol-muz26-end"></div>
<div class="sutol-muz26-bellows">
<div class="sutol-muz26-pleat"></div>
<div class="sutol-muz26-pleat"></div>
<div class="sutol-muz26-pleat"></div>
<div class="sutol-muz26-pleat"></div>
<div class="sutol-muz26-pleat"></div>
<div class="sutol-muz26-pleat"></div>
</div>
<div class="sutol-muz26-end"></div>
</div>
</div>
```

---

## Bileşen 27: Org Borusu Yükselen Sesi

**Etiketler (keyword eşleşmesi için):** enstrüman, ses, akustik, tempo
**Kategori:** Müzik
**Açıklama:** Farklı yükseklikteki org borularının sırayla yükselip alçalarak nota çalma hissi vermesini gösterir.

```html
<div class="sutol-muz27-wrap">
<style>
.sutol-muz27-wrap{position:relative;width:100%;height:100%;background:transparent;}
.sutol-muz27-wrap svg{width:100%;height:100%;display:block;}
.sutol-muz27-pipe{fill:#8c8c8c;}
</style>
<svg viewBox="0 0 100 100" class="sutol-muz27-svg" preserveAspectRatio="none">
<rect class="sutol-muz27-pipe" x="15" y="55" width="8" height="35">
<animate attributeName="y" values="55;45;55" dur="2s" repeatCount="indefinite"/>
<animate attributeName="height" values="35;45;35" dur="2s" repeatCount="indefinite"/>
</rect>
<rect class="sutol-muz27-pipe" x="28" y="40" width="8" height="50">
<animate attributeName="y" values="40;25;40" dur="2s" begin="0.2s" repeatCount="indefinite"/>
<animate attributeName="height" values="50;65;50" dur="2s" begin="0.2s" repeatCount="indefinite"/>
</rect>
<rect class="sutol-muz27-pipe" x="41" y="30" width="8" height="60">
<animate attributeName="y" values="30;15;30" dur="2s" begin="0.4s" repeatCount="indefinite"/>
<animate attributeName="height" values="60;75;60" dur="2s" begin="0.4s" repeatCount="indefinite"/>
</rect>
<rect class="sutol-muz27-pipe" x="54" y="40" width="8" height="50">
<animate attributeName="y" values="40;25;40" dur="2s" begin="0.6s" repeatCount="indefinite"/>
<animate attributeName="height" values="50;65;50" dur="2s" begin="0.6s" repeatCount="indefinite"/>
</rect>
<rect class="sutol-muz27-pipe" x="67" y="55" width="8" height="35">
<animate attributeName="y" values="55;45;55" dur="2s" begin="0.8s" repeatCount="indefinite"/>
<animate attributeName="height" values="35;45;35" dur="2s" begin="0.8s" repeatCount="indefinite"/>
</rect>
</svg>
<script>
(function(){
var svg = document.currentScript.previousElementSibling;
if(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches){
if(svg && svg.pauseAnimations) svg.pauseAnimations();
}
})();
</script>
</div>
```

---

## Bileşen 28: Arp Teli Titreşim Dalgası

**Etiketler (keyword eşleşmesi için):** enstrüman, tel, akustik, klasik müzik
**Kategori:** Müzik
**Açıklama:** Arp çerçevesindeki tellerin sırayla ileri-geri titreyerek çalınma hareketini canlandırır.

```html
<div class="sutol-muz28-wrap">
<style>
.sutol-muz28-wrap{position:relative;width:100%;height:100%;background:transparent;}
.sutol-muz28-wrap svg{width:100%;height:100%;display:block;}
.sutol-muz28-frame{fill:none;stroke:#7a5230;stroke-width:2;}
.sutol-muz28-string{stroke:#d8d8d8;stroke-width:1;}
</style>
<svg viewBox="0 0 100 100" class="sutol-muz28-svg">
<path class="sutol-muz28-frame" d="M20,10 C40,15 60,15 80,10 L70,90 L30,90 Z"/>
<line class="sutol-muz28-string" x1="30" y1="20" x2="32" y2="85">
<animateTransform attributeName="transform" type="translate" values="0 0;3 0;0 0;-3 0;0 0" dur="1s" repeatCount="indefinite"/>
</line>
<line class="sutol-muz28-string" x1="40" y1="17" x2="41" y2="86">
<animateTransform attributeName="transform" type="translate" values="0 0;3 0;0 0;-3 0;0 0" dur="1s" begin="0.15s" repeatCount="indefinite"/>
</line>
<line class="sutol-muz28-string" x1="50" y1="15" x2="50" y2="87">
<animateTransform attributeName="transform" type="translate" values="0 0;3 0;0 0;-3 0;0 0" dur="1s" begin="0.3s" repeatCount="indefinite"/>
</line>
<line class="sutol-muz28-string" x1="60" y1="17" x2="59" y2="86">
<animateTransform attributeName="transform" type="translate" values="0 0;3 0;0 0;-3 0;0 0" dur="1s" begin="0.45s" repeatCount="indefinite"/>
</line>
<line class="sutol-muz28-string" x1="70" y1="20" x2="68" y2="85">
<animateTransform attributeName="transform" type="translate" values="0 0;3 0;0 0;-3 0;0 0" dur="1s" begin="0.6s" repeatCount="indefinite"/>
</line>
</svg>
<script>
(function(){
var svg = document.currentScript.previousElementSibling;
if(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches){
if(svg && svg.pauseAnimations) svg.pauseAnimations();
}
})();
</script>
</div>
```

---

## Bileşen 29: Müzik Kutusu Silindir Pimleri

**Etiketler (keyword eşleşmesi için):** melodi, mekanizma, performans, klasik müzik
**Kategori:** Müzik
**Açıklama:** Müzik kutusunun pimli silindirinin 3B eksende sürekli dönerek melodi üretme hareketini canlandırır.

```html
<div class="sutol-muz29-wrap">
<style>
.sutol-muz29-wrap{position:relative;width:100%;height:100%;background:transparent;perspective:400px;display:flex;align-items:center;justify-content:center;}
.sutol-muz29-cylinder{position:relative;width:40%;height:40%;transform-style:preserve-3d;animation:sutol-muz29-spin 6s linear infinite;}
.sutol-muz29-pin{position:absolute;top:50%;left:50%;width:6%;height:6%;margin:-3% 0 0 -3%;background:#c0c0c0;border-radius:50%;}
@keyframes sutol-muz29-spin{
0%{transform:rotateY(0deg);}
100%{transform:rotateY(360deg);}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz29-cylinder{animation-duration:18s;}
}
</style>
<div class="sutol-muz29-cylinder"></div>
<script>
(function(){
var cyl = document.currentScript.previousElementSibling;
var n = 12;
for(var i=0;i<n;i++){
var pin = document.createElement('div');
pin.className = 'sutol-muz29-pin';
var angle = (360/n)*i;
pin.style.transform = 'rotateY(' + angle + 'deg) translateZ(60px)';
cyl.appendChild(pin);
}
})();
</script>
</div>
```

---

## Bileşen 30: Ses Seviyesi VU Metre İğnesi

**Etiketler (keyword eşleşmesi için):** ses, kayıt, düzenleme, üretim
**Kategori:** Müzik
**Açıklama:** Analog bir ses seviyesi göstergesinin ibresinin sağa sola salınarak ses şiddetini göstermesini canlandırır.

```html
<div class="sutol-muz30-wrap">
<style>
.sutol-muz30-wrap{position:relative;width:100%;height:100%;background:transparent;}
.sutol-muz30-wrap svg{width:100%;height:100%;display:block;}
.sutol-muz30-arc{fill:none;stroke:#333;stroke-width:2;}
.sutol-muz30-tick{stroke:#666;stroke-width:1;}
.sutol-muz30-needle{stroke:#d43f3f;stroke-width:2;stroke-linecap:round;transform-origin:50px 70px;animation:sutol-muz30-swing 1.8s ease-in-out infinite;}
.sutol-muz30-pivot{fill:#222;}
@keyframes sutol-muz30-swing{
0%,100%{transform:rotate(-40deg);}
50%{transform:rotate(40deg);}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz30-needle{animation-duration:5.4s;}
}
</style>
<svg viewBox="0 0 100 100" class="sutol-muz30-svg">
<path class="sutol-muz30-arc" d="M20,70 A30,30 0 0,1 80,70"/>
<line class="sutol-muz30-tick" x1="20" y1="70" x2="24" y2="66"/>
<line class="sutol-muz30-tick" x1="35" y1="45" x2="38" y2="49"/>
<line class="sutol-muz30-tick" x1="65" y1="45" x2="62" y2="49"/>
<line class="sutol-muz30-tick" x1="80" y1="70" x2="76" y2="66"/>
<line class="sutol-muz30-needle" x1="50" y1="70" x2="50" y2="35"/>
<circle class="sutol-muz30-pivot" cx="50" cy="70" r="3"/>
</svg>
</div>
```

---

## Bileşen 31: Marakas Parçacık Sallanması

**Etiketler (keyword eşleşmesi için):** enstrüman, ritim, halk müziği, performans
**Kategori:** Müzik
**Açıklama:** İki marakasın karşılıklı sallanması ve içlerinden fırlayan tanecikleri canlandırır.

```html
<div class="sutol-muz31-wrap">
<style>
.sutol-muz31-wrap{position:relative;width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;gap:6%;}
.sutol-muz31-maraca{position:relative;width:14%;height:50%;animation:sutol-muz31-shake 0.6s ease-in-out infinite;}
.sutol-muz31-maraca.right{animation-delay:0.3s;}
.sutol-muz31-head{position:absolute;top:0;left:10%;width:80%;height:55%;background:radial-gradient(circle at 35% 30%,#e8b23f,#a3701c);border-radius:50%;}
.sutol-muz31-handle{position:absolute;bottom:0;left:35%;width:30%;height:45%;background:#6b4423;border-radius:4px;}
@keyframes sutol-muz31-shake{
0%,100%{transform:rotate(-12deg);}
50%{transform:rotate(12deg);}
}
.sutol-muz31-particle{position:absolute;width:3%;height:3%;background:#fff2b0;border-radius:50%;opacity:0;animation:sutol-muz31-fly 0.6s ease-out infinite;}
@keyframes sutol-muz31-fly{
0%{opacity:0;transform:translate(0,0);}
20%{opacity:1;}
100%{opacity:0;transform:translate(var(--dx,20px),var(--dy,-20px));}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz31-maraca{animation-duration:1.8s;}
.sutol-muz31-particle{animation-duration:1.8s;}
}
</style>
<div class="sutol-muz31-maraca left">
<div class="sutol-muz31-head"></div>
<div class="sutol-muz31-handle"></div>
<div class="sutol-muz31-particle" style="top:10%;left:80%;--dx:15px;--dy:-15px;"></div>
</div>
<div class="sutol-muz31-maraca right">
<div class="sutol-muz31-head"></div>
<div class="sutol-muz31-handle"></div>
<div class="sutol-muz31-particle" style="top:10%;left:0%;--dx:-15px;--dy:-15px;animation-delay:0.3s;"></div>
</div>
</div>
```

---

## Bileşen 32: Bas Hoparlör Membran Nabzı

**Etiketler (keyword eşleşmesi için):** ses, elektronik müzik, frekans, üretim
**Kategori:** Müzik
**Açıklama:** Bir bas hoparlörün konisinin nabız gibi büyüyüp küçülmesini ve etrafına yayılan ses halkalarını gösterir.

```html
<div class="sutol-muz32-wrap">
<style>
.sutol-muz32-wrap{position:relative;width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;}
.sutol-muz32-cone{width:45%;height:45%;border-radius:50%;background:radial-gradient(circle,#333 0%,#111 60%,#000 100%);animation:sutol-muz32-pulse 0.8s ease-in-out infinite;position:relative;}
.sutol-muz32-cone::before{content:"";position:absolute;inset:30%;border-radius:50%;background:#555;}
.sutol-muz32-ring{position:absolute;top:50%;left:50%;width:45%;height:45%;margin:-22.5% 0 0 -22.5%;border:2px solid #4fc3f7;border-radius:50%;opacity:0;animation:sutol-muz32-ripple 1.6s ease-out infinite;}
.sutol-muz32-ring.b{animation-delay:0.53s;}
.sutol-muz32-ring.c{animation-delay:1.06s;}
@keyframes sutol-muz32-pulse{
0%,100%{transform:scale(1);}
50%{transform:scale(1.15);}
}
@keyframes sutol-muz32-ripple{
0%{opacity:0.7;transform:scale(1);}
100%{opacity:0;transform:scale(2.4);}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz32-cone,.sutol-muz32-ring{animation-duration:3.2s;}
}
</style>
<div style="position:relative;width:60%;height:60%;display:flex;align-items:center;justify-content:center;">
<div class="sutol-muz32-ring"></div>
<div class="sutol-muz32-ring b"></div>
<div class="sutol-muz32-ring c"></div>
<div class="sutol-muz32-cone"></div>
</div>
</div>
```

---

## Bileşen 33: DJ Mikser Kaydırıcı Hareketi

**Etiketler (keyword eşleşmesi için):** elektronik müzik, düzenleme, ekolayzır, üretim
**Kategori:** Müzik
**Açıklama:** Bir DJ mikserinin crossfader kaydırıcısının uçtan uca kaymasını ve altındaki ekolayzır çubuklarının zıplamasını gösterir.

```html
<div class="sutol-muz33-wrap">
<style>
.sutol-muz33-wrap{position:relative;width:100%;height:100%;background:transparent;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:8%;}
.sutol-muz33-track{position:relative;width:70%;height:6%;background:#333;border-radius:3px;}
.sutol-muz33-knob{position:absolute;top:50%;left:0%;width:8%;aspect-ratio:1/1;background:#e0e0e0;border-radius:3px;transform:translate(0,-50%);animation:sutol-muz33-slide 2.4s ease-in-out infinite;}
@keyframes sutol-muz33-slide{
0%,100%{left:0%;}
50%{left:92%;}
}
.sutol-muz33-eq{display:flex;align-items:flex-end;gap:6%;width:50%;height:30%;}
.sutol-muz33-bar{flex:1;background:#4fc3f7;animation:sutol-muz33-bounce 0.8s ease-in-out infinite;}
.sutol-muz33-bar:nth-child(1){animation-delay:0s;}
.sutol-muz33-bar:nth-child(2){animation-delay:0.15s;}
.sutol-muz33-bar:nth-child(3){animation-delay:0.3s;}
.sutol-muz33-bar:nth-child(4){animation-delay:0.45s;}
@keyframes sutol-muz33-bounce{
0%,100%{height:30%;}
50%{height:100%;}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz33-knob,.sutol-muz33-bar{animation-duration:7.2s;}
}
</style>
<div class="sutol-muz33-track">
<div class="sutol-muz33-knob"></div>
</div>
<div class="sutol-muz33-eq">
<div class="sutol-muz33-bar"></div>
<div class="sutol-muz33-bar"></div>
<div class="sutol-muz33-bar"></div>
<div class="sutol-muz33-bar"></div>
</div>
</div>
```

---

## Bileşen 34: Üçgen Çalgı Titreşim Dalgaları

**Etiketler (keyword eşleşmesi için):** enstrüman, akustik, ritim, klasik müzik
**Kategori:** Müzik
**Açıklama:** Metal üçgen çalgının etrafında dolaşan bir tokmak ve vuruş anında yayılan titreşim dalgalarını gösterir.

```html
<div class="sutol-muz34-wrap">
<style>
.sutol-muz34-wrap{position:relative;width:100%;height:100%;background:transparent;}
.sutol-muz34-wrap svg{width:100%;height:100%;display:block;position:absolute;top:0;left:0;}
.sutol-muz34-tri{fill:none;stroke:#c0c0c0;stroke-width:2;}
.sutol-muz34-wave{fill:none;stroke:#99addd;stroke-width:1;opacity:0;animation:sutol-muz34-vibrate 1.2s ease-out infinite;}
.sutol-muz34-wave.b{animation-delay:0.4s;}
.sutol-muz34-wave.c{animation-delay:0.8s;}
@keyframes sutol-muz34-vibrate{
0%{opacity:0.8;transform:scale(1);}
100%{opacity:0;transform:scale(1.6);}
}
.sutol-muz34-mallet{width:6%;height:6%;background:#8a5a2b;border-radius:50%;position:absolute;offset-path:path("M50,10 L90,80 L10,80 Z");animation:sutol-muz34-orbit 3s linear infinite;}
@keyframes sutol-muz34-orbit{
0%{offset-distance:0%;}
100%{offset-distance:100%;}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz34-wave{animation-duration:3.6s;}
.sutol-muz34-mallet{animation-duration:9s;}
}
</style>
<svg viewBox="0 0 100 100" class="sutol-muz34-svg">
<path class="sutol-muz34-tri" d="M50,10 L90,80 L10,80 Z"/>
<g style="transform-origin:50px 50px;">
<circle class="sutol-muz34-wave" cx="50" cy="45" r="10"/>
<circle class="sutol-muz34-wave b" cx="50" cy="45" r="10"/>
<circle class="sutol-muz34-wave c" cx="50" cy="45" r="10"/>
</g>
</svg>
<div class="sutol-muz34-mallet"></div>
</div>
```

---

## Bileşen 35: 3D Frekans Spektrumu Küpleri

**Etiketler (keyword eşleşmesi için):** ekolayzır, frekans, elektronik müzik, ses
**Kategori:** Müzik
**Açıklama:** Perspektifli 3B sahnede yükselen ve alçalan frekans spektrumu küplerini canlandırır.

```html
<div class="sutol-muz35-wrap">
<style>
.sutol-muz35-wrap{position:relative;width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;perspective:400px;}
.sutol-muz35-stage{display:flex;align-items:flex-end;gap:6%;width:70%;height:60%;transform:rotateX(15deg) rotateY(-20deg);transform-style:preserve-3d;}
.sutol-muz35-cube{flex:1;background:linear-gradient(180deg,#7ee0ff,#2288aa);transform-origin:bottom;animation:sutol-muz35-grow 1.4s ease-in-out infinite;}
.sutol-muz35-cube:nth-child(1){animation-delay:0s;}
.sutol-muz35-cube:nth-child(2){animation-delay:0.2s;}
.sutol-muz35-cube:nth-child(3){animation-delay:0.4s;}
.sutol-muz35-cube:nth-child(4){animation-delay:0.6s;}
.sutol-muz35-cube:nth-child(5){animation-delay:0.8s;}
@keyframes sutol-muz35-grow{
0%,100%{height:20%;}
50%{height:100%;}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz35-cube{animation-duration:4.2s;}
}
</style>
<div class="sutol-muz35-stage">
<div class="sutol-muz35-cube"></div>
<div class="sutol-muz35-cube"></div>
<div class="sutol-muz35-cube"></div>
<div class="sutol-muz35-cube"></div>
<div class="sutol-muz35-cube"></div>
</div>
</div>
```

---

## Bileşen 36: Osiloskop Dalga Formu Taraması

**Etiketler (keyword eşleşmesi için):** ses dalgası, frekans, kayıt, akustik
**Kategori:** Müzik
**Açıklama:** Bir osiloskop ekranında sürekli akan sinüs dalga formunu canvas üzerinde çizerek canlandırır.

```html
<div class="sutol-muz36-wrap">
<style>
.sutol-muz36-wrap{position:relative;width:100%;height:100%;background:transparent;}
.sutol-muz36-canvas{width:100%;height:100%;display:block;}
</style>
<canvas class="sutol-muz36-canvas"></canvas>
<script>
(function(){
var container = document.currentScript.parentElement;
var canvas = container.querySelector('.sutol-muz36-canvas');
var ctx = canvas.getContext('2d');
var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
var t = 0;
function resize(){
canvas.width = container.clientWidth;
canvas.height = container.clientHeight;
}
resize();
window.addEventListener('resize', resize);
function draw(){
var w = canvas.width, h = canvas.height;
ctx.clearRect(0,0,w,h);
ctx.strokeStyle = '#39ff88';
ctx.lineWidth = Math.max(1, h*0.01);
ctx.beginPath();
for(var x=0;x<=w;x+=2){
var y = h/2 + Math.sin((x*0.04) + t) * (h*0.28) * Math.exp(-Math.pow((x/w-0.5)*2,2));
if(x===0){ ctx.moveTo(x,y); } else { ctx.lineTo(x,y); }
}
ctx.stroke();
t += reduced ? 0.01 : 0.06;
requestAnimationFrame(draw);
}
draw();
})();
</script>
</div>
```

---

## Bileşen 37: Ukulele Akort Anahtarı Dönüşü

**Etiketler (keyword eşleşmesi için):** enstrüman, tel, akort, halk müziği
**Kategori:** Müzik
**Açıklama:** Bir ukulele kafasındaki akort anahtarının sürekli dönerek teli sıkıştırma hareketini canlandırır.

```html
<div class="sutol-muz37-wrap">
<style>
.sutol-muz37-wrap{position:relative;width:100%;height:100%;background:transparent;}
.sutol-muz37-wrap svg{width:100%;height:100%;display:block;}
.sutol-muz37-head{fill:#caa06b;}
.sutol-muz37-neck{fill:#caa06b;}
.sutol-muz37-peg-post{fill:#555;}
.sutol-muz37-peg-knob{fill:#3a2a1a;transform-origin:80px 30px;animation:sutol-muz37-turn 2s linear infinite;}
.sutol-muz37-string{stroke:#eee;stroke-width:1;fill:none;}
@keyframes sutol-muz37-turn{
0%{transform:rotate(0deg);}
100%{transform:rotate(360deg);}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz37-peg-knob{animation-duration:6s;}
}
</style>
<svg viewBox="0 0 100 100" class="sutol-muz37-svg">
<path class="sutol-muz37-head" d="M40,10 C55,8 65,15 65,28 C65,38 55,42 45,40 L38,55 L25,50 Z"/>
<rect class="sutol-muz37-neck" x="35" y="45" width="10" height="50"/>
<path class="sutol-muz37-string" d="M38,50 L38,95"/>
<path class="sutol-muz37-string" d="M42,50 L42,95"/>
<circle class="sutol-muz37-peg-post" cx="55" cy="20" r="3"/>
<g class="sutol-muz37-peg-knob">
<rect x="76" y="26" width="8" height="3" rx="1"/>
</g>
</svg>
</div>
```

---

## Bileşen 38: Nota Origami Katlanması

**Etiketler (keyword eşleşmesi için):** nota, melodi, beste, sanatçı
**Kategori:** Müzik
**Açıklama:** Bir nota kartının 3B eksende sürekli katlanıp açılarak ön ve arka yüzünü göstermesini canlandırır.

```html
<div class="sutol-muz38-wrap">
<style>
.sutol-muz38-wrap{position:relative;width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;perspective:350px;}
.sutol-muz38-note{position:relative;width:35%;height:55%;transform-style:preserve-3d;animation:sutol-muz38-fold 3s ease-in-out infinite;}
.sutol-muz38-half{position:absolute;inset:0;backface-visibility:hidden;border-radius:6px;background:#2e2e2e;}
.sutol-muz38-half.back{transform:rotateY(180deg);background:#4a4a4a;}
.sutol-muz38-notehead{position:absolute;bottom:8%;left:15%;width:35%;height:22%;background:#f2f2f2;border-radius:50%;transform:rotate(-15deg);}
.sutol-muz38-stem{position:absolute;bottom:20%;left:47%;width:6%;height:65%;background:#f2f2f2;}
@keyframes sutol-muz38-fold{
0%,100%{transform:rotateY(0deg);}
50%{transform:rotateY(180deg);}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz38-note{animation-duration:9s;}
}
</style>
<div class="sutol-muz38-note">
<div class="sutol-muz38-half front">
<div class="sutol-muz38-notehead"></div>
<div class="sutol-muz38-stem"></div>
</div>
<div class="sutol-muz38-half back"></div>
</div>
</div>
```

---

## Bileşen 39: Ses Küresi 3D Nabzı

**Etiketler (keyword eşleşmesi için):** ses dalgası, frekans, elektronik müzik, rezonans
**Kategori:** Müzik
**Açıklama:** Uzayda yayılan sesi simgeleyen, 3B eksende yavaşça dönen ve nabız gibi parlayan bir nokta küresini gösterir.

```html
<div class="sutol-muz39-wrap">
<style>
.sutol-muz39-wrap{position:relative;width:100%;height:100%;background:transparent;display:flex;align-items:center;justify-content:center;perspective:400px;}
.sutol-muz39-sphere{position:relative;width:50%;height:50%;transform-style:preserve-3d;animation:sutol-muz39-rotate 8s linear infinite;}
.sutol-muz39-dot{position:absolute;top:50%;left:50%;width:8%;height:8%;margin:-4% 0 0 -4%;background:#7ee0ff;border-radius:50%;animation:sutol-muz39-pulse 1.6s ease-in-out infinite;}
@keyframes sutol-muz39-rotate{
0%{transform:rotateY(0deg) rotateX(10deg);}
100%{transform:rotateY(360deg) rotateX(10deg);}
}
@keyframes sutol-muz39-pulse{
0%,100%{opacity:0.4;}
50%{opacity:1;}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz39-sphere{animation-duration:24s;}
.sutol-muz39-dot{animation-duration:4.8s;}
}
</style>
<div class="sutol-muz39-sphere"></div>
<script>
(function(){
var sphere = document.currentScript.previousElementSibling;
var rows = 6, cols = 10, radius = 60;
for(var i=0;i<rows;i++){
var lat = (Math.PI * (i+0.5)/rows) - Math.PI/2;
for(var j=0;j<cols;j++){
var lon = (2*Math.PI*j/cols);
var x = radius*Math.cos(lat)*Math.cos(lon);
var y = radius*Math.sin(lat);
var z = radius*Math.cos(lat)*Math.sin(lon);
var dot = document.createElement('div');
dot.className = 'sutol-muz39-dot';
dot.style.transform = 'translate3d(' + x.toFixed(1) + 'px,' + y.toFixed(1) + 'px,' + z.toFixed(1) + 'px)';
dot.style.animationDelay = (Math.random()*1.6).toFixed(2)+'s';
sphere.appendChild(dot);
}
}
})();
</script>
</div>
```

---

## Bileşen 40: Tef Sallanma Parçacıkları

**Etiketler (keyword eşleşmesi için):** enstrüman, ritim, halk müziği, performans
**Kategori:** Müzik
**Açıklama:** Bir tefin sallanması ve çevresindeki küçük zil disklerinin titreşerek çınlamasını canlandırır.

```html
<div class="sutol-muz40-wrap">
<style>
.sutol-muz40-wrap{position:relative;width:100%;height:100%;background:transparent;}
.sutol-muz40-wrap svg{width:100%;height:100%;display:block;animation:sutol-muz40-shake 0.5s ease-in-out infinite;transform-origin:50px 50px;}
.sutol-muz40-frame{fill:none;stroke:#c9974a;stroke-width:4;}
.sutol-muz40-skin{fill:#f2e2c0;opacity:0.5;}
.sutol-muz40-jingle{fill:#e0c060;stroke:#8a6a2a;stroke-width:0.5;}
@keyframes sutol-muz40-shake{
0%,100%{transform:rotate(-4deg);}
50%{transform:rotate(4deg);}
}
@media (prefers-reduced-motion: reduce){
.sutol-muz40-wrap svg{animation-duration:1.5s;}
}
</style>
<svg viewBox="0 0 100 100" class="sutol-muz40-svg">
<circle class="sutol-muz40-skin" cx="50" cy="50" r="38"/>
<circle class="sutol-muz40-frame" cx="50" cy="50" r="38"/>
<circle class="sutol-muz40-jingle" cx="12" cy="50" r="4">
<animateMotion path="M0,0 a2,2 0 1,0 0.1,0" dur="0.3s" repeatCount="indefinite"/>
</circle>
<circle class="sutol-muz40-jingle" cx="50" cy="12" r="4">
<animateMotion path="M0,0 a2,2 0 1,0 0.1,0" dur="0.3s" begin="0.1s" repeatCount="indefinite"/>
</circle>
<circle class="sutol-muz40-jingle" cx="88" cy="50" r="4">
<animateMotion path="M0,0 a2,2 0 1,0 0.1,0" dur="0.3s" begin="0.2s" repeatCount="indefinite"/>
</circle>
<circle class="sutol-muz40-jingle" cx="50" cy="88" r="4">
<animateMotion path="M0,0 a2,2 0 1,0 0.1,0" dur="0.3s" begin="0.05s" repeatCount="indefinite"/>
</circle>
</svg>
<script>
(function(){
var svg = document.currentScript.previousElementSibling;
if(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches){
if(svg && svg.pauseAnimations) svg.pauseAnimations();
}
})();
</script>
</div>
```

===BULLETS===
- Bileşen 21 (Vinil Plak Oluk Işın Halkaları): SVG dairelerde CSS scale/opacity keyframe animasyonu; sadece transform/opacity kullanıldığı için GPU dostu ve hafif.
- Bileşen 22 (Kulaklık Ses Dalgası Yayılımı): SVG içinde CSS keyframe ile ölçekli halka animasyonu; düşük maliyetli, katman sayısı az.
- Bileşen 23 (Ksilofon Çubuk Sıçraması): Flex düzende gecikmeli CSS transform keyframe animasyonu; reflow yaratmadan sadece transform kullanır.
- Bileşen 24 (Trompet Ses Huzmesi): SVG native `<animate>` (SMIL) ile ışın çizgileri; `pauseAnimations()` ile reduced-motion desteği sağlanır.
- Bileşen 25 (Bateri Hi-Hat Çarpışması): CSS `perspective`/`rotateX`/`translateZ` ile 3B çarpışma efekti; tamamen transform tabanlı, düşük maliyetli.
- Bileşen 26 (Akordeon Körüğü Açılışı): CSS `scaleX` keyframe ile pili benzeri nefes animasyonu; basit ve performanslı.
- Bileşen 27 (Org Borusu Yükselen Sesi): SVG `<animate>` (SMIL) ile rect yükseklik/konum animasyonu; script ile `pauseAnimations()` reduced-motion desteği.
- Bileşen 28 (Arp Teli Titreşim Dalgası): SVG `<animateTransform>` ile gecikmeli tel titreşimi; `pauseAnimations()` ile erişilebilirlik sağlanır.
- Bileşen 29 (Müzik Kutusu Silindir Pimleri): CSS 3B `rotateY`/`translateZ` ile silindir simülasyonu, pimler JS ile programatik yerleştirilir; sadece transform animasyonu kullanır.
- Bileşen 30 (Ses Seviyesi VU Metre İğnesi): SVG üzerinde CSS `transform:rotate` keyframe animasyonu; transform-origin ile pivot noktası sabitlenmiş, hafif.
- Bileşen 31 (Marakas Parçacık Sallanması): CSS `rotate` keyframe + CSS custom property (`--dx`/`--dy`) ile parçacık uçuşu; düşük DOM yükü.
- Bileşen 32 (Bas Hoparlör Membran Nabzı): İç içe CSS `scale`/`opacity` keyframe halkaları; sade radial-gradient kullanımıyla performanslı.
- Bileşen 33 (DJ Mikser Kaydırıcı Hareketi): CSS `left` keyframe animasyonu + ekolayzır çubukları için `height` keyframe; yüzde tabanlı, duyarlı.
- Bileşen 34 (Üçgen Çalgı Titreşim Dalgaları): CSS `offset-path`/`offset-distance` (motion-path) ile tokmak hareketi, SVG halkalarla titreşim; farklı bir hareket tekniği sergiler.
- Bileşen 35 (3D Frekans Spektrumu Küpleri): Saf CSS `perspective`/`rotateX`/`rotateY` ile 3B ekolayzır sahnesi; sadece `height`/`transform` değişimi, GPU dostu.
- Bileşen 36 (Osiloskop Dalga Formu Taraması): Canvas + `requestAnimationFrame` ile sinüs dalgası çizimi; `resize` dinleyicisiyle duyarlı, reduced-motion'da yavaşlatılmış hız.
- Bileşen 37 (Ukulele Akort Anahtarı Dönüşü): CSS `transform:rotate` sürekli döngü animasyonu; tek katmanlı SVG, düşük maliyetli.
- Bileşen 38 (Nota Origami Katlanması): CSS 3B `rotateY`/`backface-visibility` ile katlama efekti; `preserve-3d` kullanılarak ön/arka yüz gösterimi sağlanır.
- Bileşen 39 (Ses Küresi 3D Nabzı): CSS 3B `perspective`/`translate3d` ile programatik küre noktaları (JS ile üretilir) ve `opacity` nabız animasyonu; GPU dostu transform kullanımı.
- Bileşen 40 (Tef Sallanma Parçacıkları): SVG native `<animateMotion>` (SMIL) ile zil disklerinin titreşimi + CSS `rotate` sallanma; `pauseAnimations()` ile reduced-motion desteği.
