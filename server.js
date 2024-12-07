const express = require('express');
const bodyParser = require('body-parser');
const nodemailer = require('nodemailer');
const path = require('path');

const app = express();

// Middleware to parse JSON bodies
app.use(bodyParser.json());

// Serve static files (HTML, CSS, JS) from the current directory
app.use(express.static(path.join(__dirname)));

// Route for handling form submissions
app.post('/send', (req, res) => {
    const { name, email, message } = req.body;

    const transporter = nodemailer.createTransport({
        service: 'Gmail',
        auth: {
            user: 'zzz55york@gmail.com',
            pass: 'your-email-password', // Use app-specific password or env variable
        },
    });

    const mailOptions = {
        from: email,
        to: 'zzz55york@gmail.com',
        subject: `New Contact Form Submission from ${name}`,
        text: message,
    };

    transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
            return res.status(500).json({ message: 'Error sending email' });
        }
        res.status(200).json({ message: 'Email sent successfully' });
    });
});

// Start the server
const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
