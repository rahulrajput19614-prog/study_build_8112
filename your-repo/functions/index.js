const functions = require("firebase-functions");
const axios = require("axios");
require("dotenv").config();

exports.solveDoubt = functions.https.onRequest(async (req, res) => {
  const question = req.body.question;

  try {
    const response = await axios.post(
      "https://api.openai.com/v1/chat/completions",
      {
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: question }],
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
        },
      }
    );

    res.send(response.data.choices[0].message.content);
  } catch (error) {
    res.status(500).send("AI error: " + error.message);
  }
});
