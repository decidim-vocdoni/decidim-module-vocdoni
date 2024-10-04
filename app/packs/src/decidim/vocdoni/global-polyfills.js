// Adding this polyfill for `process` because `util.js` relies on `process.env.NODE_DEBUG`.
// This ensures compatibility in environments where `process` is not defined (e.g., browsers).
window.process = window.process || {
  env: {
    NODE_DEBUG: ""
  }
};
