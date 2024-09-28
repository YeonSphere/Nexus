// AI interaction
const aiInput = document.getElementById('ai-input') as HTMLInputElement;
const aiOutput = document.getElementById('ai-output') as HTMLDivElement;

aiInput.addEventListener('keypress', async (event) => {
    if (event.key === 'Enter') {
        const input = aiInput.value;
        aiInput.value = '';
        const response = await window.api.aiProcessInput(input);
        aiOutput.innerHTML += `<p><strong>You:</strong> ${input}</p>`;
        aiOutput.innerHTML += `<p><strong>Seokjin:</strong> ${response}</p>`;
        aiOutput.scrollTop = aiOutput.scrollHeight;
    }
});

// Learn from current page
document.getElementById('learn-page-button')?.addEventListener('click', async () => {
    const currentUrl = await window.api.getCurrentUrl();
    await window.api.aiLearnFromPage(currentUrl);
    alert('Seokjin AI has learned from the current page.');
});
