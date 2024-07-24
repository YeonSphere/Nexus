// scripts/adblocker.js
const fs = require('fs');
const path = require('path');

const hostsFilePath = path.join(__dirname, 'hosts.txt');

fs.readFile(hostsFilePath, 'utf8', (err, data) => {
  if (err) {
    console.error('Error reading hosts file:', err);
    return;
  }

  const hosts = data.split('\n').filter(line => line && !line.startsWith('#'));
  const blockedHosts = hosts.map(host => `0.0.0.0 ${host}`).join('\n');

  fs.writeFile('/etc/hosts', blockedHosts, 'utf8', (err) => {
    if (err) {
      console.error('Error writing to hosts file:', err);
    } else {
      console.log('Adblocker hosts file updated successfully.');
    }
  });
});
