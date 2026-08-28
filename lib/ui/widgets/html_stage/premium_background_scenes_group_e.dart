import '../../../models/slide_model.dart';

final Map<PresentationBackgroundKind, String>
    sutolPremiumBackgroundScenesGroupE = <PresentationBackgroundKind, String>{
  PresentationBackgroundKind.studioSky: _studioSky,
  PresentationBackgroundKind.studioNightSky: _studioNightSky,
};

const String _studioSky = r'''<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Gökyüzü</title>
<style>
:root{
  --bg-primary:#69B9E8;
  --bg-surface:#AEDFF5;
  --bg-accent:#F7FCFF;
  --bg-accent-soft:rgba(255,255,255,.62);
  --bg-secondary:#DDF2FB;
}
*{box-sizing:border-box}
html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;background:var(--bg-primary)}
.scene{position:relative;width:100%;height:100%;aspect-ratio:16/9;overflow:hidden;background:linear-gradient(180deg,var(--bg-primary) 0%,var(--bg-surface) 64%,var(--bg-secondary) 100%)}
.scene::after{content:"";position:absolute;inset:0;background:radial-gradient(circle at 82% 12%,rgba(255,255,255,.28),transparent 30%);pointer-events:none}
.scene svg{display:block;width:100%;height:100%}
.cloud{fill:var(--bg-accent);filter:url(#cloud-soft);transform-box:fill-box;transform-origin:center;animation:cloud-drift 64s linear infinite,cloud-breathe 12s ease-in-out infinite;will-change:transform,opacity}
.cloud.far{opacity:.38;animation-duration:82s,15s}
.cloud.mid{opacity:.58;animation-duration:70s,13s;animation-delay:-31s,-5s}
.cloud.near{opacity:.72;animation-duration:58s,11s;animation-delay:-18s,-3s}
.cloud.small{opacity:.42;animation-duration:76s,14s;animation-delay:-52s,-8s}
@keyframes cloud-drift{0%{translate:-220px 0}100%{translate:220px 0}}
@keyframes cloud-breathe{0%,100%{opacity:.48}50%{opacity:.72}}
@media (prefers-reduced-motion:reduce){.cloud{animation:none!important}}
</style>
</head>
<body>
<main class="scene" aria-label="Mavi gökyüzünde hafifçe süzülen bulutlar">
<svg viewBox="0 0 1920 1080" preserveAspectRatio="xMidYMid slice" role="img" aria-label="Gökyüzü">
  <defs>
    <filter id="cloud-soft" x="-30%" y="-45%" width="160%" height="190%">
      <feGaussianBlur stdDeviation="7"/>
    </filter>
  </defs>

  <!-- Sol metin güvenli alanı: yalnızca çok uzakta, düşük kontrastlı bulut -->
  <g class="cloud far" transform="translate(70 165)">
    <ellipse cx="110" cy="50" rx="108" ry="35"/>
    <ellipse cx="65" cy="42" rx="52" ry="39"/>
    <ellipse cx="133" cy="25" rx="67" ry="48"/>
    <ellipse cx="200" cy="48" rx="64" ry="31"/>
  </g>

  <!-- Orta katman: az sayıda yumuşak bulut -->
  <g class="cloud mid" transform="translate(1210 190)">
    <ellipse cx="150" cy="64" rx="150" ry="48"/>
    <ellipse cx="78" cy="53" rx="76" ry="52"/>
    <ellipse cx="158" cy="28" rx="92" ry="66"/>
    <ellipse cx="250" cy="58" rx="90" ry="43"/>
  </g>
  <g class="cloud small" transform="translate(840 485)">
    <ellipse cx="92" cy="43" rx="90" ry="30"/>
    <ellipse cx="52" cy="38" rx="44" ry="34"/>
    <ellipse cx="110" cy="24" rx="53" ry="40"/>
    <ellipse cx="166" cy="42" rx="51" ry="27"/>
  </g>

  <!-- Ön katman: sağ altta tek, sakin vurgu -->
  <g class="cloud near" transform="translate(1450 760)">
    <ellipse cx="150" cy="66" rx="154" ry="50"/>
    <ellipse cx="73" cy="55" rx="74" ry="51"/>
    <ellipse cx="152" cy="30" rx="91" ry="67"/>
    <ellipse cx="250" cy="59" rx="94" ry="44"/>
  </g>
</svg>
</main>
</body>
</html>''';

const String _studioNightSky = r'''<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Gece Gökyüzü</title>
<style>
:root{
  --bg-primary:#01040D;
  --bg-surface:#07152B;
  --bg-accent:#FFFFFF;
  --bg-accent-soft:rgba(197,220,255,.72);
}
*{box-sizing:border-box}
html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;background:var(--bg-primary)}
.scene{position:relative;width:100%;height:100%;aspect-ratio:16/9;overflow:hidden;background:linear-gradient(180deg,var(--bg-primary) 0%,#030A1A 52%,var(--bg-surface) 100%)}
.scene svg{display:block;width:100%;height:100%;shape-rendering:geometricPrecision}
.star{
  fill:var(--bg-accent);
  opacity:.12;
  transform-box:fill-box;
  transform-origin:center;
  filter:drop-shadow(0 0 .8px rgba(255,255,255,.46));
  animation:twinkle var(--duration) ease-in-out var(--delay) infinite;
  will-change:opacity,transform;
}
.star.ice{fill:#CFE3FF;filter:drop-shadow(0 0 .9px rgba(164,204,255,.54))}
.shooting-star{
  opacity:0;
  transform-box:view-box;
  transform-origin:center;
  animation:shooting-star-pass 5s linear infinite;
  will-change:opacity,transform;
}
.shooting-star .trail{stroke:url(#shooting-star-trail);stroke-width:2;stroke-linecap:round}
.shooting-star .head{fill:#FFFFFF;filter:drop-shadow(0 0 2px rgba(207,227,255,.9))}
@keyframes twinkle{
  0%,100%{opacity:.10;transform:scale(.72)}
  50%{opacity:var(--peak);transform:scale(1.14)}
}
@keyframes shooting-star-pass{
  0%,64%{opacity:0;transform:translate(0,0)}
  66%{opacity:.88;transform:translate(-18px,11px)}
  76%{opacity:0;transform:translate(-430px,258px)}
  77%,100%{opacity:0;transform:translate(-430px,258px)}
}
@media (prefers-reduced-motion:reduce){.star{animation:none!important;opacity:.66;transform:none}.shooting-star{animation:none!important;display:none}}
</style>
</head>
<body>
<main class="scene" aria-label="Küçük yıldızların parladığı ve ara sıra bir yıldızın kaydığı gece gökyüzü">
  <svg viewBox="0 0 1920 1080" preserveAspectRatio="xMidYMid slice" role="img" aria-label="Gece gökyüzündeki yıldızlar">
    <defs>
      <linearGradient id="shooting-star-trail" x1="1548" y1="118" x2="1468" y2="166" gradientUnits="userSpaceOnUse">
        <stop offset="0" stop-color="#CFE3FF" stop-opacity="0"/>
        <stop offset=".72" stop-color="#EAF4FF" stop-opacity=".5"/>
        <stop offset="1" stop-color="#FFFFFF" stop-opacity=".96"/>
      </linearGradient>
    </defs>
    <g id="stars" aria-hidden="true"></g>
    <g class="shooting-star" aria-hidden="true">
      <line class="trail" x1="1548" y1="118" x2="1468" y2="166"/>
      <circle class="head" cx="1468" cy="166" r="2.2"/>
    </g>
  </svg>
</main>
<script>
(function () {
  const layer = document.getElementById('stars');
  const namespace = 'http://www.w3.org/2000/svg';
  const starCount = 170;
  let state = 739391;

  function random() {
    state = (state * 48271) % 2147483647;
    return state / 2147483647;
  }

  for (let index = 0; index < starCount; index += 1) {
    const star = document.createElementNS(namespace, 'circle');
    const bright = random() > .88;
    const radius = bright ? 1.35 + random() * .75 : .62 + random() * .78;
    const duration = 2.8 + random() * 5.4;
    star.setAttribute('cx', (random() * 1920).toFixed(2));
    star.setAttribute('cy', (random() * 1080).toFixed(2));
    star.setAttribute('r', radius.toFixed(2));
    star.setAttribute('class', random() > .76 ? 'star ice' : 'star');
    star.style.setProperty('--duration', duration.toFixed(2) + 's');
    star.style.setProperty('--delay', (-random() * duration).toFixed(2) + 's');
    star.style.setProperty('--peak', (.58 + random() * .42).toFixed(2));
    layer.appendChild(star);
  }
})();
</script>
</body>
</html>''';
