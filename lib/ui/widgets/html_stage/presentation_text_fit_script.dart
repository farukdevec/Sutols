/// Shared fitting runtime for editor iframes, preview and standalone exports.
const String sutolTextFitScript = r'''
(function () {
  function textOverflows(element) {
    const widthOverflow = element.scrollWidth > element.clientWidth + 1;
    const heightOverflow = element.scrollHeight > element.clientHeight + 1;
    if (!element.classList.contains('is-title')) {
      return widthOverflow || heightOverflow;
    }
    let drawnOverflow = false;
    try {
      const range = document.createRange();
      range.selectNodeContents(element);
      const bounds = range.getBoundingClientRect();
      range.detach();
      const box = element.getBoundingClientRect();
      const inset = 3;
      drawnOverflow =
        bounds.top < box.top + inset ||
        bounds.bottom > box.bottom - inset ||
        bounds.left < box.left + inset ||
        bounds.right > box.right - inset;
    } catch (_) {}
    return widthOverflow || heightOverflow || drawnOverflow;
  }

  function fitText(element) {
    // Metin kutusu sahnenin güvenli alanını aşarsa yazı boyutunu kademeli
    // olarak küçültür. CSS'teki min değer okunabilirlik sınırını korur.
    if (!element.classList.contains('text-overflow-shrink') || !element.clientWidth) return;
    const authoredHeight = element.dataset.sutolAuthoredHeight !== undefined
      ? element.dataset.sutolAuthoredHeight
      : element.style.height;
    element.dataset.sutolAuthoredHeight = authoredHeight;
    element.style.height = authoredHeight;
    element.style.minHeight = '';
    element.style.removeProperty('font-size');
    const baseSize = parseFloat(window.getComputedStyle(element).fontSize) || 12;
    // Custom properties retain the authored `cqw` token here. Assign it to a
    // real property first so the browser resolves the minimum to pixels.
    element.style.fontSize = 'var(--sutol-min-font-size)';
    const resolvedMinimum =
      parseFloat(window.getComputedStyle(element).fontSize) || baseSize;
    const minimumSize = Math.min(baseSize, resolvedMinimum);
    element.style.fontSize = baseSize.toFixed(3) + 'px';

    if (textOverflows(element)) {
      element.style.fontSize = minimumSize.toFixed(3) + 'px';
      if (!textOverflows(element)) {
        // Match Flutter's 14-step binary search for the largest fitting size.
        let low = minimumSize;
        let high = baseSize;
        for (let index = 0; index < 14; index += 1) {
          const candidate = (low + high) / 2;
          element.style.fontSize = candidate.toFixed(3) + 'px';
          if (textOverflows(element)) high = candidate;
          else low = candidate;
        }
        element.style.fontSize = low.toFixed(3) + 'px';
      }
    }
    // The minimum font size is a readability guarantee, not a clipping
    // threshold. Grow beyond the authored height when the final line still
    // cannot fit, matching the Flutter editor/preview measurement.
    if (textOverflows(element)) {
      element.style.minHeight = authoredHeight;
      element.style.height = 'auto';
    }
  }

  function fitAllText() {
    document.querySelectorAll('.sutol-html-block').forEach(fitText);
  }


  window.SutolFitText = fitAllText;
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', fitAllText, { once: true });
  } else {
    fitAllText();
  }
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(fitAllText);
  window.addEventListener('resize', fitAllText);
  if (window.ResizeObserver) {
    const observer = new ResizeObserver(fitAllText);
    document.querySelectorAll('.sutol-html-stage').forEach(stage => observer.observe(stage));
  }
})();
''';

