document.addEventListener('DOMContentLoaded', function () {
  const truncate = new Map();

  const defaultMinWords = 10;
  const defaultMaxWords = 30;
  const defaultMinElemWidth = 300;
  const defaultMaxElemWidth = 500;

  // will apply a sliding scale between min and max words, i.e. 10 words at
  // 768px, 30 words at 1024px, and a linear scale in between

  /**
   * Linearly interpolate a value within a range.
   * @param {number} x The value to interpolate
   * @param {number} x0 The lower bound of the interpolation range
   * @param {number} x1 The upper bound of the interpolation range
   * @param {number} y0 The lower bound of the output range
   * @param {number} y1 The upper bound of the output range
   * @returns {number} The interpolated value
   */
  const lerp = (x, x0, x1, y0, y1) => {
    return y0 + ((x - x0) * (y1 - y0)) / (x1 - x0);
  };

  /**
   * Get a numeric value or a default if undefined.
   * @param {string | undefined} value The value to check
   * @param {number} defaultValue The default value
   * @returns {number} The value or the default
   */
  const val = (value, defaultValue) => {
    if (value === undefined) {
      return defaultValue;
    }

    const result = parseInt(value, 10);

    return isNaN(result) ? defaultValue : result;
  };

  /**
   * Truncate the text of an element.
   * @param {HTMLElement} elem The element to truncate
   * @returns {void}
   */
  const truncateText = (elem) => {
    const originalText = truncate.get(elem);
    const words = originalText.split(' ');

    const minWords = val(elem.dataset.minWords, defaultMinWords);
    const maxWords = val(elem.dataset.maxWords, defaultMaxWords);
    const minElemWidth = val(elem.dataset.minAtWidth, defaultMinElemWidth);
    const maxElemWidth = val(elem.dataset.maxAtWidth, defaultMaxElemWidth);

    const truncateTo = Math.max(
      Math.min(
        Math.round(
          lerp(elem.clientWidth, minElemWidth, maxElemWidth, minWords, maxWords)
        ),
        defaultMaxWords
      ),
      defaultMinWords
    );

    if (words.length <= truncateTo) {
      elem.textContent = originalText;
      return;
    }

    const truncatedText = `${words.slice(0, truncateTo).join(' ')}…`;
    elem.textContent = truncatedText;
  };

  const resizeObserver = new ResizeObserver((entries) => {
    for (const entry of entries) {
      const elem = entry.target;
      truncateText(elem);
    }
  });

  for (const elem of document.querySelectorAll('.auto-truncate')) {
    truncate.set(elem, elem.textContent.trim().replace(/\s+/g, ' '));
    resizeObserver.observe(elem);
    truncateText(elem);
  }
});
