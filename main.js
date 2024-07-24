document.getElementById('go').addEventListener('click', () => {
    const url = document.getElementById('url').value;
    document.getElementById('webview').src = url;
});

document.getElementById('back').addEventListener('click', () => {
    document.getElementById('webview').contentWindow.history.back();
});

document.getElementById('forward').addEventListener('click', () => {
    document.getElementById('webview').contentWindow.history.forward();
});

document.getElementById('refresh').addEventListener('click', () => {
    document.getElementById('webview').contentWindow.location.reload();
});

document.getElementById('home').addEventListener('click', () => {
    document.getElementById('webview').src = 'about:blank';
});
