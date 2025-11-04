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
  const exportDir = path.dirname(exportPath);
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
  // Legit path: wait for Workbench to discover devices and open project
  console.log('[midi2-compliance] Refreshing UMP devices...');
  await win.evaluate(() => { try { require('electron').ipcRenderer.send('asynchronous-message', 'getAllUMPDevicesFunctionBlocks'); } catch (_) {} });
  await win.waitForSelector('[data-umpdev]', { timeout: 120000 });
  const umpDev = await win.evaluate(() => {
    const list = Array.from(document.querySelectorAll('[data-umpdev]')).map(el => el.getAttribute('data-umpdev'));
    return list && list.length ? list[0] : null;
  });
  if (!umpDev) {
    console.error('[midi2-compliance] No UMP devices discovered by Workbench. Attach a USB MIDI 2.0 device.');
    await app.close();
    process.exit(3);
  }
  console.log(`[midi2-compliance] Using device: ${umpDev}`);

  // Open project and generate PDF report (no DOM injection)
  await win.evaluate((d) => { try { require('electron').ipcRenderer.send('asynchronous-message', 'openMIDICI', { umpDev: d, group: 1, muid: -1 }); } catch (_) {} }, umpDev);
  const proj = await app.waitForEvent('window', { timeout: 60000 });
  await proj.waitForLoadState('domcontentloaded');
  console.log('[midi2-compliance] Project window opened');
  await proj.evaluate((d) => { try { require('electron').ipcRenderer.send('asynchronous-message', 'showCertification', { umpDev: d, group: 1, muid: -1, openMIDICI: true }); } catch (_) {} }, umpDev);
  await new Promise(r => setTimeout(r, 2000));
  await proj.evaluate((d) => { try { require('electron').ipcRenderer.send('asynchronous-message', 'generateReport', { umpDev: d, group: 1, muid: -1 }); } catch (_) {} }, umpDev);
  await new Promise(r => setTimeout(r, 4000));

  // Copy PDF to out/workbench.pdf; write logs and a minimal metadata json
  const os = require('os');
  const pdfPath = path.join(os.homedir(), 'midi2workbench', String(umpDev), 'report.pdf');
  fs.mkdirSync(exportDir, { recursive: true });
  const destPDF = path.join(exportDir, 'workbench.pdf');
  if (fs.existsSync(pdfPath)) {
    fs.copyFileSync(pdfPath, destPDF);
    console.log(`[midi2-compliance] PDF report copied to: ${destPDF}`);
  } else {
    console.warn(`[midi2-compliance] PDF not found at ${pdfPath}`);
  }
  const logPath = path.resolve(exportDir, 'workbench.log');
  fs.writeFileSync(logPath, logs.join('\n'));
  // Minimal metadata (pointer to PDF) to keep downstream steps simple
  const meta = { tool: 'MIDI2.0Workbench', device: umpDev, pdf: fs.existsSync(destPDF) ? 'workbench.pdf' : null };
  fs.writeFileSync(exportPath, JSON.stringify(meta, null, 2));
  console.log(`[midi2-compliance] Metadata saved to: ${exportPath}`);

  await app.close();
  process.exit(0);
})().catch(err => {
  console.error(err);
  process.exit(1);
});
