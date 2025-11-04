// Headless controller for the MIDI 2.0 Workbench (Electron app)
//
// Usage:
//   node ci/run-workbench-tests.js --export ./out/report.json
//
// Assumptions for your forked Workbench UI:
// - A "Run Tests" button with id="start-tests"
// - An "Export JSON" button with id="export-json" that sets window.__MIDI2_LAST_REPORT__
// Adjust selectors if your fork differs.

const fs = require('fs');
const path = require('path');
const { _electron: electron } = require('playwright');

function getArg(name, defVal) {
  const idx = process.argv.indexOf(name);
  if (idx >= 0 && process.argv[idx+1]) return process.argv[idx+1];
  return defVal;
}

(async () => {
  const exportPath = getArg('--export', path.resolve(process.cwd(), 'out/report.json'));
  const workbenchCwd = process.cwd();
  const startSelector = process.env.MIDI2_START_SELECTOR || '#start-tests';
  const exportSelector = process.env.MIDI2_EXPORT_SELECTOR || '#export-json';

  console.log(`[midi2-compliance] Launching Workbench (cwd=${workbenchCwd})`);
  let executablePath = process.env.ELECTRON_PATH || null;
  if (!executablePath) {
    try {
      // Resolve electron from the workbench tree
      const { createRequire } = require('module');
      const wbRequire = createRequire(path.join(workbenchCwd, 'package.json'));
      executablePath = wbRequire('electron');
    } catch (e) {
      try { executablePath = require('electron'); } catch (e2) { /* ignore */ }
    }
  }
  const launchOpts = { args: ['.'], cwd: workbenchCwd, env: { MIDI2_HEADLESS: 'true' } };
  if (executablePath) launchOpts.executablePath = executablePath;
  const app = await electron.launch(launchOpts);
  const win = await app.firstWindow();
  const logs = [];
  win.on('console', msg => {
    const line = msg.text();
    logs.push(line);
    if (process.env.MIDI2_LOG_CONSOLE === '1') console.log(`[wb] ${line}`);
  });

  // Headless path: drive Workbench via IPC to open CI views and build report
  // 1) refresh devices and wait for UMP device cards
  console.log('[midi2-compliance] Refreshing UMP devices...');
  await win.evaluate(() => {
    try { require('electron').ipcRenderer.send('asynchronous-message', 'getAllUMPDevicesFunctionBlocks'); } catch (_) {}
  });
  // wait until at least one UMP device card appears
  await win.waitForSelector('[data-umpdev]', { timeout: 120000 });
  const umpDevs = await win.evaluate(() => Array.from(document.querySelectorAll('[data-umpdev]')).map(el => el.getAttribute('data-umpdev')));
  if (!umpDevs || umpDevs.length === 0) throw new Error('No UMP devices discovered');
  const umpDev = umpDevs[0];
  console.log(`[midi2-compliance] Using device: ${umpDev}`);

  // 2) open MIDI-CI project window (auto-pick MUID with -1)
  await win.evaluate((d) => {
    try { require('electron').ipcRenderer.send('asynchronous-message', 'openMIDICI', { umpDev: d, group: 1, muid: -1 }); } catch (_) {}
  }, umpDev);
  const proj = await app.waitForEvent('window', { timeout: 60000 });
  await proj.waitForLoadState('domcontentloaded');
  console.log('[midi2-compliance] Project window opened');

  // 3) show certification (builds devData) and open report window for rendering
  await proj.evaluate((d) => {
    try { require('electron').ipcRenderer.send('asynchronous-message', 'showCertification', { umpDev: d, group: 1, muid: -1, openMIDICI: true }); } catch (_) {}
  }, umpDev);
  // allow devData to build
  await new Promise(r => setTimeout(r, 2000));
  await proj.evaluate((d) => {
    try { require('electron').ipcRenderer.send('asynchronous-message', 'openReport', { umpDev: d, group: 1, muid: -1 }); } catch (_) {}
  }, umpDev);
  const reportWin = await app.waitForEvent('window', { timeout: 60000 });
  await reportWin.waitForLoadState('domcontentloaded');
  console.log('[midi2-compliance] Report window opened');

  // 4) Extract a simple JSON summary from the report DOM (checked items)
  const summary = await reportWin.evaluate(() => {
    const checks = [];
    document.querySelectorAll('input[type="checkbox"][data-path]').forEach((el) => {
      const path = el.getAttribute('data-path');
      const passed = !!el.checked;
      checks.push({ path, passed });
    });
    const device = {
      manufacturer: document.querySelector('[data-pathText="/device/manufacturer"]')?.textContent?.trim() || '',
      model: document.querySelector('[data-pathText="/device/model"]')?.textContent?.trim() || ''
    };
    const passed = checks.some(c => c.passed);
    const result = { device, passed, checks };
    window.__MIDI2_LAST_REPORT__ = result;
    return result;
  });
  console.log(`[midi2-compliance] Extracted summary: ${JSON.stringify(summary).slice(0,200)}...`);

  // no explicit export control needed; JSON is placed on window.__MIDI2_LAST_REPORT__

  // fetch report object from window (ensure fork sets this global)
  const json = await win.evaluate(() => {
    return typeof window.__MIDI2_LAST_REPORT__ !== 'undefined' ? window.__MIDI2_LAST_REPORT__ : null;
  });

  if (!json) {
    console.error("[midi2-compliance] No JSON report found (window.__MIDI2_LAST_REPORT__ is null).");
    await app.close();
    process.exit(2);
  }

  fs.mkdirSync(path.dirname(exportPath), { recursive: true });
  fs.writeFileSync(exportPath, JSON.stringify(json, null, 2));
  // also dump console logs
  const logPath = path.resolve(path.dirname(exportPath), 'workbench.log');
  fs.writeFileSync(logPath, logs.join('\n'));
  console.log(`[midi2-compliance] Report saved to: ${exportPath}`);

  await app.close();
  process.exit(0);
})().catch(err => {
  console.error(err);
  process.exit(1);
});
