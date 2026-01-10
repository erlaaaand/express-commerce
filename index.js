require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const productRoutes = require('./routes/product');
const cartRoutes = require('./routes/cart');
const transactionRoutes = require('./routes/transaction');

const app = express();

app.use(cors());
app.use(express.json());

const mongoURI = process.env.MONGO_URI;

mongoose.connect(mongoURI)
    .then(() => console.log('Connection Success!'))
    .catch(err => console.log('Failed to Connect:', err));

app.use('/api/auth', authRoutes);

app.use('/api/products', productRoutes); 

app.use('/api/cart', cartRoutes);

app.use('/api/orders', transactionRoutes); 

app.get('/', (req, res) => {
    res.send('Server Running Successfully!');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});