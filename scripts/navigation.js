// scripts/navigation.js
document.getElementById('back').addEventListener('click', () => {
    window.history.back();
  });
  
  document.getElementById('forward').addEventListener('click', () => {
    window.history.forward();
  });
  
  document.getElementById('refresh').addEventListener('click', () => {
    window.location.reload();
  });
  
  document.getElementById('home').addEventListener('click', () => {
    window.location.href = 'index.html';
  });
  