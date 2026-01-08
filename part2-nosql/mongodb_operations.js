
// MongoDB Operations for FlexiMart Product Catalog

// Operation 1: Load Data (1 mark)
// Import the provided JSON file into collection 'products'
// Run this command in terminal:
// mongoimport --db fleximart --collection products --file products_catalog.json --jsonArray

// Or use this script to load data:
use fleximart;

// Clear existing data
db.products.deleteMany({});

// Load sample data (paste the JSON array from products_catalog.json)
db.products.insertMany([
  // ... paste JSON data here
]);

print("Data loaded successfully. Total products: " + db.products.countDocuments());


// Operation 2: Basic Query (2 marks)
// Find all products in "Electronics" category with price less than 50000
// Return only: name, price, stock

db.products.find(
  {
    category: "Electronics",
    price: { $lt: 50000 }
  },
  {
    _id: 0,
    name: 1,
    price: 1,
    stock: 1
  }
).pretty();


// Operation 3: Review Analysis (2 marks)
// Find all products that have average rating >= 4.0
// Use aggregation to calculate average from reviews array

db.products.aggregate([
  {
    $match: {
      reviews: { $exists: true, $ne: [] }
    }
  },
  {
    $addFields: {
      avg_rating: { $avg: "$reviews.rating" }
    }
  },
  {
    $match: {
      avg_rating: { $gte: 4.0 }
    }
  },
  {
    $project: {
      _id: 0,
      product_id: 1,
      name: 1,
      category: 1,
      price: 1,
      avg_rating: { $round: ["$avg_rating", 2] },
      review_count: { $size: "$reviews" }
    }
  },
  {
    $sort: { avg_rating: -1 }
  }
]).pretty();


// Operation 4: Update Operation (2 marks)
// Add a new review to product "ELEC001"
// Review: {user: "U999", rating: 4, comment: "Good value", date: ISODate()}

db.products.updateOne(
  { product_id: "ELEC001" },
  {
    $push: {
      reviews: {
        user_id: "U999",
        username: "NewUser999",
        rating: 4,
        comment: "Good value",
        date: new Date().toISOString().split('T')[0]
      }
    },
    $set: {
      updated_at: new Date()
    }
  }
);

print("Review added successfully");

// Verify the update
db.products.findOne(
  { product_id: "ELEC001" },
  { name: 1, reviews: { $slice: -1 } }
).pretty();


// Operation 5: Complex Aggregation (3 marks)
// Calculate average price by category
// Return: category, avg_price, product_count
// Sort by avg_price descending

db.products.aggregate([
  {
    $group: {
      _id: "$category",
      avg_price: { $avg: "$price" },
      product_count: { $sum: 1 },
      total_stock: { $sum: "$stock" }
    }
  },
  {
    $project: {
      _id: 0,
      category: "$_id",
      avg_price: { $round: ["$avg_price", 2] },
      product_count: 1,
      total_stock: 1
    }
  },
  {
    $sort: { avg_price: -1 }
  }
]).pretty();


// Additional useful queries for analysis:

// Find products with most reviews
db.products.aggregate([
  {
    $addFields: {
      review_count: { $size: { $ifNull: ["$reviews", []] } }
    }
  },
  {
    $sort: { review_count: -1 }
  },
  {
    $limit: 5
  },
  {
    $project: {
      _id: 0,
      product_id: 1,
      name: 1,

