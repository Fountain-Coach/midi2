(() => {
  const root = document.documentElement;
  const button = document.querySelector('[data-theme-toggle]');
  const stored = localStorage.getItem('fountain-coach-theme');
  root.dataset.theme = stored || 'system';
  const sync = () => {
    if (!button) return;
    const mode = root.dataset.theme || 'system';
    button.textContent = `Theme: ${mode}`;
    button.setAttribute('aria-pressed', String(mode !== 'system'));
    button.setAttribute('aria-label', `Theme preference: ${mode}. Activate to change.`);
  };
  sync();
  button?.addEventListener('click', () => {
    const next = ({system: 'light', light: 'dark', dark: 'system'})[root.dataset.theme || 'system'];
    root.dataset.theme = next;
    localStorage.setItem('fountain-coach-theme', next);
    sync();
  });
  const menuButton = document.querySelector('[data-menu-button]');
  const index = document.querySelector('#reading-index');
  menuButton?.addEventListener('click', () => {
    const open = index?.dataset.open === 'true';
    if (index) index.dataset.open = String(!open);
    menuButton.setAttribute('aria-expanded', String(!open));
  });
})();
