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

  console.log(`[midi2-compliance] Launching Workbench (cwd=${workbenchCwd})`);
  const app = await electron.launch({ args: ['.'], cwd: workbenchCwd, env: { MIDI2_HEADLESS: 'true' } });
  const win = await app.firstWindow();

  // wait for main UI ready (adjust selector to your fork)
  await win.waitForSelector('#start-tests', { timeout: 60000 });

  console.log("[midi2-compliance] Starting full compliance suite...");
  await win.click('#start-tests');

  // suite can take a while
  await win.waitForSelector('#export-json', { timeout: 10 * 60 * 1000 });

  console.log("[midi2-compliance] Exporting JSON report...");
  await win.click('#export-json');

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
  console.log(`[midi2-compliance] Report saved to: ${exportPath}`);

  await app.close();
  process.exit(0);
})().catch(err => {
  console.error(err);
  process.exit(1);
});
