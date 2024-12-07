document.getElementById('contactForm').addEventListener('submit', function (event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    
    fetch('/send', {
        method: 'POST',
        body: JSON.stringify(Object.fromEntries(formData)),
        headers: { 'Content-Type': 'application/json' },
    })
    .then(response => response.json())
    .then(data => alert(data.message))
    .catch(error => alert('An error occurred.'));
});
