const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

// Simple API route
app.get("/", (req, res) => {
  res.send("✅ Backend is working on Render!");
});

// Example login route
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  if (email === "test@example.com" && password === "123456") {
    return res.json({ success: true, message: "Login successful" });
  }

  res.status(401).json({ success: false, message: "Invalid credentials" });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
