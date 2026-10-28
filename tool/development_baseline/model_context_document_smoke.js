// QA-only public DOM/WebGL sensor; never injected into production documents.
(function () {
  const panel = document.createElement('pre');
  panel.style.cssText = 'position:fixed;left:8px;top:8px;z-index:99999;background:white;color:#172033;padding:12px;max-width:96%;max-height:35%;overflow:auto;font:14px monospace;white-space:pre-wrap';
  panel.textContent = 'Waiting for generated HTML model'; document.body.appendChild(panel);
  const model = document.querySelector('model-viewer');
  const data = { nativeLoss: false, nativeRestore: false, pageErrors: window.SutolQaPageErrors || [] };
  function pose() { const orbit = model.getCameraOrbit(), target = model.getCameraTarget();
    return { theta: orbit.theta, phi: orbit.phi, radius: orbit.radius, x: target.x,
      y: target.y, z: target.z, fov: model.getFieldOfView(), turntable: model.turntableRotation,
      time: model.currentTime, clip: model.animationName, paused: model.paused }; }
  function show(phase) { panel.textContent = phase + '\n' + JSON.stringify(data); }
  let attempts = 0;
  function ready() {
    const canvas = model.shadowRoot && model.shadowRoot.querySelector('canvas#webgl-canvas');
    if (!canvas || !model.loaded) { if (++attempts < 100) setTimeout(ready, 200); else show('FAILED: model readiness'); return; }
    setTimeout(function () {
      const context = canvas.getContext('webgl2'), extension = context.getExtension('WEBGL_lose_context');
      if (!extension) { show('SKIPPED: native extension unavailable'); return; }
      data.before = pose();
      canvas.addEventListener('webglcontextlost', function () {
        data.nativeLoss = true;
        setTimeout(function () {
          data.posterVisible = !model.nextElementSibling.nextElementSibling.hidden;
          data.viewerRetained = model.isConnected && !model.hidden;
          show('NATIVE HTML CONTEXT LOST: fallback visible');
        }, 50);
      }, {once:true});
      canvas.addEventListener('webglcontextrestored', function () {
        data.nativeRestore = true;
        setTimeout(function () {
          data.after = pose();
          data.fallbackHidden = model.nextElementSibling.nextElementSibling.hidden;
          data.contextRecovered = !context.isContextLost();
          const same = Object.keys(data.before).every(function (key) {
            return typeof data.before[key] === 'number' ? Math.abs(data.before[key] - data.after[key]) < .00001 : data.before[key] === data.after[key];
          });
          const expected = Math.abs(data.before.time - 1.5) < .00001 && data.before.clip === 'RotorSpin';
          data.passed = same && expected && data.nativeLoss && data.nativeRestore && data.posterVisible && data.viewerRetained && data.fallbackHidden && data.contextRecovered;
          show(data.passed ? 'PASS: generated HTML native GPU recovery and clip preserved' : 'FAILED: generated HTML recovery');
        }, 1800);
      }, {once:true});
      extension.loseContext(); setTimeout(function () { extension.restoreContext(); }, 12000);
    }, 2000);
  }
  ready();
})();
