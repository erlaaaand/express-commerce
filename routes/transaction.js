const express = require('express');
const router = express.Router();
const Cart = require('../models/Cart');
const Order = require('../models/Order');
const Product = require('../models/Product');
const { verifyToken } = require('../middleware/authMiddleware');

router.post('/checkout', verifyToken, async (req, res) => {
    try {
        const { shippingAddress } = req.body;
        const cart = await Cart.findOne({ userId: req.user.id });

        if (!cart || cart.items.length === 0) {
            return res.status(400).json({ message: 'Cart is empty' });
        }

        const orderItems = [];
        let totalAmountCalculated = 0;

        for (const item of cart.items) {
            const productDB = await Product.findById(item.productId);
            
            if (!productDB) {
                return res.status(404).json({ message: `Product ${item.productName} not found` });
            }

            if (productDB.stock < item.quantity) {
                return res.status(400).json({ message: `Insufficient stock for ${item.productName}` });
            }

            productDB.stock -= item.quantity;
            await productDB.save();

            orderItems.push({
                productId: item.productId,
                productName: item.productName,
                priceAtPurchase: item.price,
                quantity: item.quantity,
                imageUrl: item.imageUrl
            });

            totalAmountCalculated += item.price * item.quantity;
        }

        const newOrder = new Order({
            userId: req.user.id,
            items: orderItems,
            totalAmount: totalAmountCalculated,
            shippingAddress: shippingAddress,
            status: 'Paid'
        });

        await newOrder.save();

        cart.items = [];
        cart.totalTemporaryAmount = 0;
        await cart.save();

        res.status(201).json({ message: 'Order created successfully', order: newOrder });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

router.get('/', verifyToken, async (req, res) => {
    try {
        const orders = await Order.find({ userId: req.user.id }).sort({ createdAt: -1 });
        res.status(200).json(orders);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

router.get('/:id', verifyToken, async (req, res) => {
    try {
        const order = await Order.findOne({ _id: req.params.id, userId: req.user.id });
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }
        res.status(200).json(order);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;