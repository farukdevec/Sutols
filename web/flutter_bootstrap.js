{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Flutter motorunu gstatic yerine proje içinden yükle. Bu, ağ/kurumsal
    // filtre nedeniyle gstatic erişilemediğinde web uygulamasının açılmasını sağlar.
    // Flutter uygun CanvasKit paketini tarayıcıya göre seçer: Chromium için
    // küçültülmüş sürüm, Firefox/Safari için standart sürüm. `chromium`
    // sürümünü zorlamak Firefox'ta uygulamanın daha ilk kareden çökmesine
    // neden olur.
    canvasKitBaseUrl: 'canvaskit/',
  },
});
