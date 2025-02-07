const mongoose = require('mongoose');
const Product = require('./models/Product');

mongoose.connect('mongodb://localhost:27017/healthy_market', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

async function seedDatabase() {
  try {
    // **清空 `products` 集合**
    await Product.deleteMany({});
    console.log("🗑️  所有產品已被刪除");

    // **新增新產品**
    const products = [
      {
        name: "Carrot",
        category: "Vegetables",
        imageUrl: "https://example.com/broccoli.jpg",
        price: 3.99
      },
      {
        name: "Chicken Breast",
        category: "Meat",
        imageUrl: "https://example.com/chicken.jpg",
        price: 5.99
      }
    ];

    await Product.insertMany(products);
    console.log("✅ 產品已成功新增到資料庫！");
  } catch (err) {
    console.log("❌ 錯誤：", err);
  } finally {
    mongoose.connection.close();
  }
}

// **執行 `seedDatabase`**
seedDatabase();