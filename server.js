const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const axios = require("axios");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

mongoose.connect("mongodb://localhost:27017/healthy_market", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const db = mongoose.connection;
db.on("error", console.error.bind(console, "MongoDB connection error:"));
db.once("open", () => {
  console.log("Connected to MongoDB");
});

// Product Schema
const productSchema = new mongoose.Schema({
  name: String,
  category: String,
  imageUrl: String,
  price: Number,
});

const Product = mongoose.model("Product", productSchema);

// 獲取所有商品
app.get("/api/products", async (req, res) => {
  try {
    const products = await Product.find();
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// 獲取商品的營養資訊（透過 ChatGPT）
app.post("/api/nutrition", async (req, res) => {
  const { productName } = req.body;

  try {
    const chatResponse = await axios.post("https://api.openai.com/v1/chat/completions", {
      model: "gpt-4",
      messages: [{ role: "user", content: `提供${productName}的營養價值` }],
    }, {
      headers: {
        "Authorization": `Bearer YOUR_OPENAI_API_KEY`,
        "Content-Type": "application/json"
      }
    });

    res.json({ nutrition: chatResponse.data.choices[0].message.content });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// 根據購物車提供推薦菜單（透過 ChatGPT）
app.post("/api/recommendations", async (req, res) => {
  const { cartItems } = req.body;
  const itemList = cartItems.join(", ");

  try {
    const chatResponse = await axios.post("https://api.openai.com/v1/chat/completions", {
      model: "gpt-4",
      messages: [{ role: "user", content: `請根據 ${itemList} 提供適合的菜單` }],
    }, {
      headers: {
        "Authorization": `Bearer YOUR_OPENAI_API_KEY`,
        "Content-Type": "application/json"
      }
    });

    res.json({ dishes: chatResponse.data.choices[0].message.content });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});