const functions = require("firebase-functions");
const axios = require("axios");
require("dotenv").config();

exports.askAI = functions.https.onRequest(async (req, res) => {
  const question = req.body.question;
  try {
    const response = await axios.post(
      "https://api.openai.com/v1/chat/completions",
      {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "You are a helpful study assistant." },
          { role: "user", content: question },
        ],
        temperature: 0.7,
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
          "Content-Type": "application/json",
        },
      }
    );
    res.json({ answer: response.data.choices[0].message.content });
  } catch (error) {
    res.status(500).send(error.message);
  }
});
