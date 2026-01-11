require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const productRoutes = require('./routes/product');
const cartRoutes = require('./routes/cart');
const transactionRoutes = require('./routes/transaction');
const paymentRoutes = require('./routes/payment');

const app = express();

app.use(cors());
app.use(express.json());

const mongoURI = process.env.MONGO_URI;
const PORT = process.env.PORT || 3000;

if (!mongoURI) {
    console.error("❌ FATAL ERROR: MONGO_URI is undefined. Cek tab Variables di Railway!");
    process.exit(1);
}

mongoose.connect(mongoURI)
    .then(() => {
        console.log('✅ Database Connection Success!');
        
        app.use('/api/auth', authRoutes);
        app.use('/api/products', productRoutes); 
        app.use('/api/cart', cartRoutes);
        app.use('/api/orders', transactionRoutes); 
        app.use('/api/payment', paymentRoutes);

        app.get('/', (req, res) => {
            res.send('Server Running Successfully!');
        });

        app.listen(PORT, () => {
            console.log(`🚀 Server running on port ${PORT}`);
        });
    })
    .catch(err => {
        console.error('❌ Failed to Connect to Database:', err);
    });