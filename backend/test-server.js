const express = require('express');
const app = express();

app.get('/health', (req, res) => {
  res.json({ status: 'OK' });
});

const PORT = 3000;
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`Test server running on port ${PORT}`);
  console.log(`Server address:`, server.address());
});

server.on('error', (err) => {
  console.error('Server error:', err);
});

// Keep the process alive
setInterval(() => {
  console.log('Server still running...');
}, 5000);
