/// Applies only inside a still/reduced-motion scene document, never to Flutter's
/// parent window. JS components receive the same preference as CSS and models.
const String sutolReducedMotionMediaScript = r'''
(function(){
  if(window.SutolReducedMotionMedia || typeof window.matchMedia!=='function')return;
  const nativeMatchMedia=window.matchMedia.bind(window);
  window.matchMedia=function(query){
    if(String(query).indexOf('prefers-reduced-motion')<0)return nativeMatchMedia(query);
    return {matches:/prefers-reduced-motion[ ]*:[ ]*reduce/.test(query),media:query,
      onchange:null,addListener:function(){},removeListener:function(){},
      addEventListener:function(){},removeEventListener:function(){},
      dispatchEvent:function(){return true;}};
  };
  window.SutolReducedMotionMedia=true;
})();
''';
