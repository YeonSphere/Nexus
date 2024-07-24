document.addEventListener('DOMContentLoaded', () => {
    const tabs = document.querySelectorAll('.tab');
    tabs.forEach(tab => {
      tab.addEventListener('click', () => {
        document.querySelector('.tab.active').classList.remove('active');
        tab.classList.add('active');
      });
    });
  
    document.getElementById('minimize').addEventListener('click', () => {
      const remote = require('@electron/remote');
      remote.getCurrentWindow().minimize();
    });
  
    document.getElementById('maximize').addEventListener('click', () => {
      const remote = require('@electron/remote');
      const window = remote.getCurrentWindow();
      if (window.isMaximized()) {
        window.unmaximize();
      } else {
        window.maximize();
      }
    });
  
    document.getElementById('close').addEventListener('click', () => {
      const remote = require('@electron/remote');
      remote.getCurrentWindow().close();
    });
  });
  