/// Transient recovery for generated preview/export documents. Public SDK and
/// native canvas events only; nothing is persisted or sent to the parent.
const String sutolModelContextRecoveryScript = r'''
(function () {
  if (window.SutolModelContextRecovery) return;
  const records = new Map();
  let disposed = false;
  function active() {
    const lifecycle = window.SutolSceneLifecycle;
    return !document.hidden && (!lifecycle || lifecycle.snapshot().active);
  }
  function showPoster(model, show) {
    const status = model.nextElementSibling, fallback = status && status.nextElementSibling;
    if (!fallback || typeof fallback.querySelector !== 'function') return;
    const poster = fallback.querySelector('.sutol-3d-context-poster');
    const failure = fallback.querySelector('.sutol-3d-load-fallback');
    if (poster) poster.hidden = !show;
    if (failure) failure.hidden = show;
  }
  function clear(model) {
    showPoster(model, false);
    const record = records.get(model);
    if (record) record.canvas.removeEventListener('webglcontextrestored', record.restore);
    records.delete(model);
    model.removeAttribute('data-sutol-context-lost');
    model.removeAttribute('data-sutol-context-resume-playing');
    model.removeAttribute('data-sutol-context-resume-rotating');
    model.style.opacity = '';
    const status = model.nextElementSibling;
    if (status) ['zIndex', 'whiteSpace', 'top', 'bottom', 'width', 'maxWidth',
      'transform', 'fontSize', 'padding', 'color'].forEach(function (key) {
      status.style[key] = '';
    });
  }
  function loaded(model) {
    clear(model);
    const source = model.getAttribute('src');
    const time = Number(model.dataset.sutolAnimationTime);
    Promise.resolve(model.updateComplete).then(function () {
      if (disposed || !model.isConnected || model.getAttribute('src') !== source ||
          records.has(model)) return;
      if (Number.isFinite(time)) model.currentTime = time;
      if (!active() && typeof model.pause === 'function') model.pause();
    }).catch(function () {});
  }
  function handle(model, event) {
    if (!event.detail || event.detail.type !== 'webglcontextlost') return false;
    if (disposed || records.has(model)) return true;
    const source = model.getAttribute('src');
    const canvas = event.detail.sourceError && event.detail.sourceError.target;
    const status = model.nextElementSibling;
    const fallback = status && status.nextElementSibling;
    let pose;
    try {
      const orbit = model.getCameraOrbit(), target = model.getCameraTarget();
      pose = { theta: orbit.theta, phi: orbit.phi, radius: orbit.radius,
        x: target.x, y: target.y, z: target.z, fov: model.getFieldOfView(),
        turntable: model.turntableRotation, time: model.currentTime,
        clip: model.animationName, playing: model.paused === false,
        rotating: model.hasAttribute('auto-rotate') };
    } catch (_) {}
    model.setAttribute('data-sutol-context-lost', 'true');
    model.style.opacity = '0';
    model.removeAttribute('auto-rotate');
    if (typeof model.pause === 'function') model.pause();
    if (fallback) fallback.hidden = false;
    showPoster(model, true);
    if (status) {
      status.hidden = false;
      status.textContent = '3D görüntüleme durakladı. Düzenlemeleriniz korundu.';
      status.setAttribute('role', 'status');
      status.style.zIndex = '2';
      status.style.whiteSpace = 'normal';
      status.style.top = 'auto';
      status.style.bottom = '12px';
      status.style.width = 'calc(100% - 48px)';
      status.style.maxWidth = '32em';
      status.style.transform = 'translateX(-50%)';
      status.style.fontSize = 'clamp(12px, 1.8cqw, 20px)';
      status.style.padding = '8px 12px';
      status.style.color = '#fff';
    }
    if (!canvas || typeof canvas.addEventListener !== 'function') return true;
    const record = { canvas: canvas, restore: null };
    record.restore = function () {
      if (disposed || records.get(model) !== record || !model.isConnected ||
          model.getAttribute('src') !== source) return;
      canvas.removeEventListener('webglcontextrestored', record.restore);
      if (pose) model.animationName = pose.clip;
      Promise.resolve(model.updateComplete).then(function () {
        if (disposed || records.get(model) !== record || !model.isConnected ||
            model.getAttribute('src') !== source) return;
        if (pose) {
          if (Number.isFinite(pose.time)) model.currentTime = pose.time;
          model.cameraOrbit = `${pose.theta}rad ${pose.phi}rad ${pose.radius}m`;
          model.cameraTarget = `${pose.x}m ${pose.y}m ${pose.z}m`;
          model.fieldOfView = `${pose.fov}deg`;
          if (Number.isFinite(pose.turntable) && typeof model.resetTurntableRotation === 'function')
            model.resetTurntableRotation(pose.turntable);
          if (typeof model.jumpCameraToGoal === 'function') model.jumpCameraToGoal();
        }
        clear(model);
        model.hidden = false;
        if (status) status.hidden = true;
        if (fallback) fallback.hidden = true;
        if (pose && active()) {
          if (pose.rotating) model.setAttribute('auto-rotate', '');
          if (pose.playing && typeof model.play === 'function') model.play();
        } else {
          if (pose && pose.playing) model.setAttribute('data-sutol-context-resume-playing', 'true');
          if (pose && pose.rotating) model.setAttribute('data-sutol-context-resume-rotating', 'true');
          if (typeof model.pause === 'function') model.pause();
        }
      }).catch(function () {});
    };
    records.set(model, record);
    canvas.addEventListener('webglcontextrestored', record.restore);
    return true;
  }
  window.addEventListener('pagehide', function (event) {
    if (event.persisted) return;
    disposed = true;
    records.forEach(function (record) {
      record.canvas.removeEventListener('webglcontextrestored', record.restore);
    });
    records.clear();
  });
  window.SutolModelContextRecovery = { handle: handle, loaded: loaded };
})();
''';
