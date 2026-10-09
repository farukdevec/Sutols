import '../../../models/development_features.dart';

/// Shared, scene-local lifecycle. Never wraps the parent Flutter scheduler.
const String sutolSceneLifecycleScript = sutolVisibleScenesEnabled
    ? r'''
(function () {
  if (window.SutolSceneLifecycle) return;
  const raf = window.requestAnimationFrame.bind(window);
  const caf = window.cancelAnimationFrame.bind(window);
  const pending = new Map();
  const pausedAnimations = new Set();
  const pausedModels = new Map();
  const pausedSvgs = new Set();
  let sequence = 0, visible = true, enabled = true, disposed = false;
  let active = !document.hidden, suspendedAt = active ? null : performance.now();
  let suspendedTime = 0, callbacks = 0;
  let observer;

  function schedule(id, entry) {
    if (!active || disposed || entry.native != null) return;
    entry.native = raf(function (timestamp) {
      entry.native = null;
      if (!active || disposed) return;
      pending.delete(id);
      callbacks++;
      entry.callback(timestamp - suspendedTime);
    });
  }
  window.requestAnimationFrame = function (callback) {
    if (disposed) return 0;
    const id = ++sequence;
    const entry = { callback: callback, native: null };
    pending.set(id, entry);
    schedule(id, entry);
    return id;
  };
  window.cancelAnimationFrame = function (id) {
    const entry = pending.get(id);
    if (!entry) return;
    if (entry.native != null) caf(entry.native);
    pending.delete(id);
  };

  function freeze() {
    document.querySelectorAll('svg').forEach(function (svg) {
      if (typeof svg.pauseAnimations === 'function' && !svg.animationsPaused()) {
        pausedSvgs.add(svg); svg.pauseAnimations();
      }
    });
    if (document.getAnimations) document.getAnimations().forEach(function (animation) {
      if (animation.playState === 'running') {
        pausedAnimations.add(animation);
        animation.pause();
      }
    });
    document.querySelectorAll('model-viewer').forEach(function (model) {
      const previous = pausedModels.get(model);
      const rotating = model.hasAttribute('auto-rotate');
      const playing = model.paused === false;
      pausedModels.set(model, { rotating: rotating || Boolean(previous && previous.rotating), playing: playing || Boolean(previous && previous.playing) });
      model.removeAttribute('auto-rotate');
      if (playing && typeof model.pause === 'function') model.pause();
    });
  }
  function resume() {
    pausedSvgs.forEach(function (svg) { if (svg.isConnected) svg.unpauseAnimations(); });
    pausedSvgs.clear();
    pausedAnimations.forEach(function (animation) {
      if (animation.playState === 'paused') animation.play();
    });
    pausedAnimations.clear();
    pausedModels.forEach(function (state, model) {
      if (!model.isConnected || model.hasAttribute('data-sutol-context-lost')) return;
      const rotating = state.rotating || model.hasAttribute('data-sutol-context-resume-rotating');
      const playing = state.playing || model.hasAttribute('data-sutol-context-resume-playing');
      model.removeAttribute('data-sutol-context-resume-rotating');
      model.removeAttribute('data-sutol-context-resume-playing');
      if (rotating) model.setAttribute('auto-rotate', '');
      if (playing && typeof model.play === 'function') model.play();
    });
    pausedModels.clear();
  }
  function update() {
    const next = !disposed && enabled && visible && !document.hidden;
    if (next === active) return;
    active = next;
    const now = performance.now();
    if (!active) {
      suspendedAt = now;
      pending.forEach(function (entry) {
        if (entry.native != null) caf(entry.native);
        entry.native = null;
      });
      freeze();
    } else {
      if (suspendedAt != null) suspendedTime += now - suspendedAt;
      suspendedAt = null;
      resume();
      pending.forEach(function (entry, id) { schedule(id, entry); });
    }
    document.documentElement.setAttribute('data-sutol-scene-active', String(active));
  }
  function onMessage(event) {
    if (event.source !== window.parent || !event.data ||
        event.data.type !== 'sutol-scene-active' ||
        typeof event.data.active !== 'boolean') return;
    enabled = event.data.active;
    update();
  }
  function start() {
    // IntersectionObserver does not account for an ancestor hidden with
    // opacity/visibility. Export uses explicit page identity as well.
    try {
      const slide = window.frameElement && window.frameElement.closest('.sutol-export-slide');
      if (slide) enabled = slide.classList.contains('is-active');
    } catch (_) {}
    update();
    document.documentElement.setAttribute('data-sutol-scene-active', String(active));
    if (typeof IntersectionObserver !== 'undefined') {
      observer = new IntersectionObserver(function (entries) {
        if (!entries.length) return;
        visible = entries[entries.length - 1].isIntersecting;
        update();
      });
      observer.observe(document.documentElement);
    }
    if (!active) freeze();
  }
  function dispose() {
    disposed = true;
    update();
    pending.clear();
    pausedAnimations.clear();
    pausedModels.clear();
    pausedSvgs.clear();
    if (observer) observer.disconnect();
    document.removeEventListener('visibilitychange', update);
    document.removeEventListener('load', onLateLoad, true);
    window.removeEventListener('message', onMessage);
  }
  function onLateLoad() { if (!active && !disposed) freeze(); }
  document.addEventListener('load', onLateLoad, true);
  document.addEventListener('visibilitychange', update);
  window.addEventListener('message', onMessage);
  // pagehide may enter back/forward cache; pageshow must be able to resume.
  window.addEventListener('pagehide', function (event) {
    if (event.persisted) { enabled = false; update(); } else dispose();
  });
  window.addEventListener('pageshow', function (event) {
    if (event.persisted) { enabled = true; update(); }
  });
  window.SutolSceneLifecycle = {
    setActive: function (value) { enabled = Boolean(value); update(); },
    snapshot: function () {
      return { active: active, callbacks: callbacks, pending: pending.size,
        disposed: disposed };
    }
  };
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start, { once: true });
  } else start();
})();
'''
    : '';
