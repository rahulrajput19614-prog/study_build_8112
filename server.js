const express = require("express");
const { OAuth2Client } = require("google-auth-library");
const app = express();

app.use(express.json());

// 👇 yaha apna Google Client ID dalna
const CLIENT_ID = "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com";
const client = new OAuth2Client(CLIENT_ID);

// Default route
app.get("/", (req, res) => {
  res.send("✅ Google Login Backend is working on Render!");
});

// Google Login verify route
app.post("/google-login", async (req, res) => {
  const { token } = req.body;

  try {
    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: CLIENT_ID,
    });

    const payload = ticket.getPayload();
    const userid = payload["sub"];

    res.json({
      success: true,
      user: {
        id: userid,
        email: payload.email,
        name: payload.name,
        picture: payload.picture,
      },
    });
  } catch (error) {
    res.status(400).json({ success: false, message: "Invalid token" });
  }
});

// Render port
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

