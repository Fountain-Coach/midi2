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

  // wait for main UI ready (adjust selector to your fork). Try a few fallbacks.
  const startCandidates = [
    startSelector,
    'button:has-text("Run")',
    'button:has-text("Start")',
    'text=Run Tests',
    'text=Start Tests'
  ];
  let started = false;
  for (const sel of startCandidates) {
    try {
      await win.waitForSelector(sel, { timeout: 10000 });
      console.log(`[midi2-compliance] Starting suite with selector: ${sel}`);
      await win.click(sel);
      started = true;
      break;
    } catch (e) {
      // try next candidate
    }
  }
  if (!started) {
    throw new Error(`[midi2-compliance] Could not find start control. Tried: ${startCandidates.join(', ')}`);
  }

  // suite can take a while, then attempt export via a few selector fallbacks.
  const exportCandidates = [
    exportSelector,
    'button:has-text("Export")',
    'text=Export JSON',
    'text=Export Report'
  ];
  let exported = false;
  for (const sel of exportCandidates) {
    try {
      await win.waitForSelector(sel, { timeout: 15 * 60 * 1000 });
      console.log(`[midi2-compliance] Exporting JSON report with selector: ${sel}`);
      await win.click(sel);
      exported = true;
      break;
    } catch (e) {
      // try next candidate
    }
  }
  if (!exported) {
    throw new Error(`[midi2-compliance] Could not find export control. Tried: ${exportCandidates.join(', ')}`);
  }

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
