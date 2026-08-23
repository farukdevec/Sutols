import '../../../models/slide_model.dart';

final Map<PresentationBackgroundKind, String>
    sutolPremiumBackgroundScenesGroupE = <PresentationBackgroundKind, String>{
  PresentationBackgroundKind.studioSky: _studioSky,
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
