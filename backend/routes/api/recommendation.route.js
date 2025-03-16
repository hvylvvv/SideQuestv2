const express = require('express');
const axios = require('axios');
require('dotenv').config();

const router = express.Router();

router.post('/', async (req, res) => {
    try {
        const { latitude, longitude } = req.body;

        if (!latitude || !longitude) {
            return res.status(400).json({ message: "Location is required" });
        }

        // Call Google Places API
        const googleResponse = await axios.get(
            `https://maps.googleapis.com/maps/api/place/nearbysearch/json`,
            {
                params: {
                    location: `${latitude},${longitude}`,
                    radius: 20000, // 5km radius
                    type: 'restaurant',
                    key: process.env.GOOGLE_PLACES_API_KEY,
                }
            }
        );

        console.log("Google Places API Response:", googleResponse.data);

        const places = googleResponse.data.results
            .filter(place => place.types.includes("restaurant"))
            .slice(0, 5)
            .map(place => ({
                name: place.name,
                address: place.vicinity,
                rating: place.rating || "No rating",
                types: place.types,
                image: place.photos
                    ? `https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place.photos[0].photo_reference}&key=${process.env.GOOGLE_PLACES_API_KEY}`
                    : null,
            }));

        try {
            const chatGptResponse = await axios.post(
                'https://api.openai.com/v1/chat/completions',
                {
                    model: "gpt-4",
                    messages: [
                        { role: "system", content: "You are a travel assistant. Respond ONLY with valid JSON inside an object with a 'recommendations' key. No extra text or explanations." },
                        { role: "user", content: `Here is a list of restaurants: ${JSON.stringify(places)}. Recommend the best ones in JSON format.` }
                    ],
                },
                {
                    headers: {
                        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
                        'Content-Type': 'application/json'
                    }
                }
            );

            console.log("ChatGPT Response:", chatGptResponse.data);

            const gptData = chatGptResponse.data.choices[0].message.content;

            let recommendations;
            try {
                recommendations = JSON.parse(gptData);
            } catch (jsonError) {
                console.error("GPT Response is not valid JSON:", gptData);
                recommendations = { error: "Fallback: Unable to parse AI response, please try again." };
            }

            return res.json(recommendations);

        } catch (error) {
            console.error("OpenAI API Error:", error.response ? error.response.data : error.message);
            return res.status(500).json({ message: "Error processing OpenAI request", error: error.message });
        }

    } catch (error) {
        console.error("Google Places API Error:", error.response ? error.response.data : error.message);
        return res.status(500).json({ message: "Error retrieving places from Google", error: error.message });
    }
});

module.exports = router;
