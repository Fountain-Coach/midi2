if (process.env.MIDI2_HEADLESS_STUB === '1') {
  try {
    console.log('[midi2-compliance] Headless shims active');
  } catch (_) {
    // console might not be ready very early in Electron startup.
  }
  const Module = require('module');
  const path = require('path');

  const replacements = new Map([
    ['midi', path.join(__dirname, 'stub-midi.js')],
    ['usb_midi_2', path.join(__dirname, 'stub-usb-midi.js')],
  ]);

  const originalLoad = Module._load;
  Module._load = function patchedLoad(request, parent, isMain) {
    if (replacements.has(request)) {
      const replacementPath = replacements.get(request);
      return originalLoad(replacementPath, parent, isMain);
    }
    return originalLoad.apply(this, arguments);
  };
}
