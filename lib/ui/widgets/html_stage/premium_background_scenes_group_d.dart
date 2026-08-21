import '../../../models/slide_model.dart';

final Map<PresentationBackgroundKind, String>
    sutolPremiumBackgroundScenesGroupD = <PresentationBackgroundKind, String>{
  PresentationBackgroundKind.studioEnvironmentSustainability: _buildScene(
    title: 'Çevre ve Sürdürülebilirlik',
    primary: '#061D1A',
    surface: '#0D3930',
    accent: '#73E2A7',
    accentSoft: 'rgba(115,226,167,.18)',
    secondary: '#53C7C1',
    texture: _sustainabilityTexture,
    motifs: <String>['leaf', 'drop', 'cycle'],
  ),
  PresentationBackgroundKind.studioReligionSpirituality: _buildScene(
    title: 'Din ve Maneviyat',
    primary: '#100D22',
    surface: '#28204A',
    accent: '#F2CE7E',
    accentSoft: 'rgba(242,206,126,.16)',
    secondary: '#A99BE8',
    texture: _spiritualityTexture,
    motifs: <String>['arch', 'ray', 'rosette'],
  ),
  PresentationBackgroundKind.studioPsychologyGrowth: _buildScene(
    title: 'Psikoloji ve Kişisel Gelişim',
    primary: '#151127',
    surface: '#312A50',
    accent: '#C6A7FF',
    accentSoft: 'rgba(198,167,255,.17)',
    secondary: '#71D6D1',
    texture: _psychologyTexture,
    motifs: <String>['neuron', 'thought', 'spark'],
  ),
  PresentationBackgroundKind.studioConstructionRealEstate: _buildScene(
    title: 'İnşaat ve Emlak',
    primary: '#111820',
    surface: '#263746',
    accent: '#FFB454',
    accentSoft: 'rgba(255,180,84,.16)',
    secondary: '#79C7D5',
    texture: _constructionTexture,
    motifs: <String>['plan', 'bracket', 'scaffold'],
  ),
  PresentationBackgroundKind.studioGamingEntertainment: _buildScene(
    title: 'Oyun ve Eğlence',
    primary: '#090A18',
    surface: '#20194A',
    accent: '#A6FF4D',
    accentSoft: 'rgba(166,255,77,.15)',
    secondary: '#A971FF',
    texture: _gamingTexture,
    motifs: <String>['pixel', 'score', 'control'],
  ),
};

String _buildScene({
  required String title,
  required String primary,
  required String surface,
  required String accent,
  required String accentSoft,
  required String secondary,
  required String texture,
  required List<String> motifs,
}) {
  const positions = <(int, int)>[
    (100, 130),
    (350, 260),
    (600, 110),
    (850, 310),
    (1100, 150),
    (1380, 270),
    (1660, 120),
    (1840, 350),
    (180, 520),
    (440, 710),
    (690, 500),
    (930, 760),
    (1180, 540),
    (1450, 710),
    (1720, 560),
    (90, 900),
    (370, 980),
    (650, 860),
    (900, 1010),
    (1130, 890),
    (1370, 990),
    (1590, 850),
    (1840, 970),
    (1040, 390),
    (1540, 430),
    (760, 930),
    (1260, 320),
    (1780, 760),
    (520, 410),
    (1500, 80),
  ];
  final field = <String>[];
  for (var i = 0; i < positions.length; i++) {
    final (x, y) = positions[i];
    final motif = motifs[i % motifs.length];
    final duration = 5 + (i % 5);
    final delay = -(i % 9);
    final opacity = x < 1050 ? .20 + (i % 3) * .03 : .34 + (i % 4) * .05;
    field.add(
      '<g transform="translate($x $y)"><use href="#$motif" class="motif m${i % 3}" '
      'style="animation-duration:${duration}s;animation-delay:${delay}s;opacity:$opacity"/></g>',
    );
  }

  return '''<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Sutols — $title</title><style>
:root{--bg-primary:$primary;--bg-surface:$surface;--bg-accent:$accent;--bg-accent-soft:$accentSoft;--bg-secondary:$secondary}
*{box-sizing:border-box}html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;background:var(--bg-primary)}
.scene{position:relative;width:100%;height:100%;aspect-ratio:16/9;overflow:hidden;background:radial-gradient(circle at 78% 28%,var(--bg-surface),transparent 43%),linear-gradient(132deg,var(--bg-primary),var(--bg-surface))}
svg{display:block;width:100%;height:100%}.texture{animation-name:texture-breathe;animation-duration:9s;animation-timing-function:ease-in-out;animation-iteration-count:infinite;transform-origin:center}
.motif{color:var(--bg-accent);fill:none;stroke:currentColor;stroke-width:2;vector-effect:non-scaling-stroke;transform-box:fill-box;transform-origin:center;animation-name:motif-drift;animation-timing-function:ease-in-out;animation-iteration-count:infinite}
.m1{color:var(--bg-secondary);animation-name:motif-pulse}.m2{animation-name:motif-turn}
@keyframes texture-breathe{0%,100%{transform:translate3d(0,0,0);opacity:.38}50%{transform:translate3d(12px,-8px,0);opacity:.62}}
@keyframes motif-drift{0%,100%{transform:translate3d(0,0,0) scale(.94);opacity:.24}50%{transform:translate3d(8px,-13px,0) scale(1.08);opacity:.78}}
@keyframes motif-pulse{0%,100%{transform:scale(.9);opacity:.22}50%{transform:scale(1.14);opacity:.82}}
@keyframes motif-turn{0%,100%{transform:translate3d(0,0,0) rotate(-4deg);opacity:.25}50%{transform:translate3d(-9px,8px,0) rotate(7deg);opacity:.72}}
@media(prefers-reduced-motion:reduce){.texture,.motif{animation:none!important}}
</style></head><body><div class="scene">
<svg viewBox="0 0 1920 1080" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
<defs>
<linearGradient id="safe" x1="0" x2="1"><stop stop-color="var(--bg-primary)" stop-opacity=".74"/><stop offset=".58" stop-color="var(--bg-primary)" stop-opacity=".18"/><stop offset="1" stop-color="var(--bg-primary)" stop-opacity="0"/></linearGradient>
$texture
</defs>
<!-- KATMAN 1 / ZEMİN -->
<rect width="1920" height="1080" fill="transparent"/>
<!-- KATMAN 2 / KONSEPTE ÖZGÜ DOKU -->
<rect class="texture" x="-30" y="-30" width="1980" height="1140" fill="url(#texturePattern)"/>
<!-- KATMAN 3 / MİKRO PARÇACIKLAR VE DOKUNUŞLAR -->
<g>${field.join()}</g>
<!-- TEXT-SAFE ZONE -->
<rect width="1220" height="1080" fill="url(#safe)"/>
</svg></div></body></html>''';
}

const String _sustainabilityTexture = '''
<pattern id="texturePattern" width="240" height="180" patternUnits="userSpaceOnUse"><path d="M-20 145C45 68 103 210 260 42" fill="none" stroke="var(--bg-secondary)" stroke-opacity=".16" stroke-width="2"/><circle cx="190" cy="34" r="3" fill="var(--bg-accent)" fill-opacity=".28"/></pattern>
<g id="leaf"><path d="M-22 18C-18-18 18-28 30-24C28 8 10 29-22 18Z"/><path d="M-17 14L23-19M1 1L-2-13M8-5L20 2"/></g>
<g id="drop"><path d="M0-27C17-7 23 3 23 15A23 23 0 01-23 15C-23 3-17-7 0-27Z"/><circle r="7" opacity=".35"/></g>
<g id="cycle"><path d="M-25 5A28 28 0 0117-20L24-11M25-5A28 28 0 01-17 20L-24 11"/><path d="M16-22L26-21L24-11M-16 22L-26 21L-24 11"/></g>''';

const String _spiritualityTexture = '''
<pattern id="texturePattern" width="180" height="180" patternUnits="userSpaceOnUse"><path d="M90 8L172 90L90 172L8 90ZM90 38L142 90L90 142L38 90Z" fill="none" stroke="var(--bg-accent)" stroke-opacity=".10"/><circle cx="90" cy="90" r="18" fill="none" stroke="var(--bg-secondary)" stroke-opacity=".12"/></pattern>
<g id="arch"><path d="M-24 28V0A24 24 0 010-24A24 24 0 0124 0V28M-14 28V2A14 14 0 010-12A14 14 0 0114 2V28"/></g>
<g id="ray"><path d="M0-29V29M-22-18L22 18M-29 0H29M-22 18L22-18" stroke-opacity=".65"/><circle r="7"/></g>
<g id="rosette"><path d="M0-27C8-16 16-13 27-14C20-3 20 3 27 14C15 13 8 16 0 27C-8 16-15 13-27 14C-20 3-20-3-27-14C-16-13-8-16 0-27Z"/></g>''';

const String _psychologyTexture = '''
<pattern id="texturePattern" width="270" height="190" patternUnits="userSpaceOnUse"><path d="M16 132C62 42 128 172 184 71S246 42 278 78" fill="none" stroke="var(--bg-secondary)" stroke-opacity=".14" stroke-width="2"/><circle cx="16" cy="132" r="4" fill="var(--bg-accent)" fill-opacity=".25"/><circle cx="184" cy="71" r="4" fill="var(--bg-accent)" fill-opacity=".25"/></pattern>
<g id="neuron"><circle r="10"/><path d="M-8-7L-29-23M8-6L29-18M10 4L31 14M-5 9L-18 30"/><circle cx="-29" cy="-23" r="3"/><circle cx="31" cy="14" r="3"/></g>
<g id="thought"><path d="M-27 4C-27-12-13-23 4-23S31-12 31 3S18 27 0 27H-17L-8 18C-20 15-27 11-27 4Z"/><circle cx="-18" cy="34" r="3"/></g>
<g id="spark"><path d="M0-28L5-6L26-13L9 2L24 18L3 10L-5 29L-7 8L-29 12L-11-2L-25-19L-4-10Z"/></g>''';

const String _constructionTexture = '''
<pattern id="texturePattern" width="260" height="200" patternUnits="userSpaceOnUse"><path d="M0 24H174V118H80V200M36 24V82H128V156H260M174 24L214 64V118" fill="none" stroke="var(--bg-secondary)" stroke-opacity=".16"/><path d="M10 184H70M10 176V192M70 176V192" stroke="var(--bg-accent)" stroke-opacity=".22"/></pattern>
<g id="plan"><path d="M-29-22H12V-6H29V23H-8V8H-29Z"/><path d="M-8-22V8M12-6H-8"/></g>
<g id="bracket"><path d="M-28-23V24H27M-18-23V14H27"/><path d="M12 14V24M-18-8H-28"/></g>
<g id="scaffold"><path d="M-26 27V-27M26 27V-27M-26-15H26M-26 2H26M-26 19H26M-26-15L26 2M26 2L-26 19"/></g>''';

const String _gamingTexture = '''
<pattern id="texturePattern" width="128" height="128" patternUnits="userSpaceOnUse"><path d="M0 0H32V32H0ZM96 32H128V64H96ZM32 96H64V128H32Z" fill="var(--bg-secondary)" fill-opacity=".07"/><path d="M0 64H18V82H0ZM72 14H86V28H72Z" fill="var(--bg-accent)" fill-opacity=".10"/></pattern>
<g id="pixel"><path d="M-24-24H-6V-6H12V12H30V30H12V18H-12V30H-30V6H-18V-12H-24Z"/></g>
<g id="score"><path d="M-31 19H31M-27 9H-8V-3H8V-17H27"/><circle cx="-27" cy="9" r="3"/><circle cx="27" cy="-17" r="3"/></g>
<g id="control"><path d="M-31 15L-22-14C-19-24-8-27 0-19C8-27 19-24 22-14L31 15C34 27 20 32 13 22L5 12H-5L-13 22C-20 32-34 27-31 15Z"/><path d="M-18-5V11M-26 3H-10M15-3H15M23 5H23"/></g>''';
