document.addEventListener('DOMContentLoaded', () => {
  const replaceText = (selector, text) => {
    const element = document.getElementById(selector);
    if (element) element.innerText = text;
  };

  const setVersions = async () => {
    try {
      for (const dependency of ['chrome', 'node', 'electron']) {
        replaceText(`${dependency}-version`, process.versions[dependency]);
      }
    } catch (err) {
      console.error(err);
    }
  };

  setVersions()
    .catch(err => console.error(err));

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Nexus</title>
      <style>
        @font-face {
          font-family: 'Handwriting';
          src: url('fonts/Handwriting-Regular.otf') format('opentype');
          font-weight: normal;
          font-style: normal;
        }

        body {
          background-color: #2c2c54; /* Nebula purple */
          color: #dcdde1; /* Light text color */
          font-family: 'Handwriting';
        }

        h1 {
          color: #8c7ae6; /* Lighter purple for headings */
        }
      </style>
    </head>
    <body>
      <h1>Welcome to Nexus!</h1>
      <p>Versions:</p>
      <ul>
        <li>Chrome: <span id="chrome-version"></span></li>
        <li>Node: <span id="node-version"></span></li>
        <li>Electron: <span id="electron-version"></span></li>
      </ul>
      <script>
        (async () => {
          try {
            const versions = await Promise.all([
              navigator.userAgent.match(/Chrom(e|ium)\/([0-9]+(\.[0-9]+)?)/),
              Promise.resolve(process.versions.node),
              Promise.resolve(process.versions.electron),
            ]);
            document.getElementById('chrome-version').textContent = versions[0][2];
            document.getElementById('node-version').textContent = versions[1];
            document.getElementById('electron-version').textContent = versions[2];
          } catch (error) {
            console.error(error);
          }
        })();
      </script>
    </body>
    </html>
  `;

  document.body.innerHTML = html;
});

