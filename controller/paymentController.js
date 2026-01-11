// controllers/paymentController.js
const midtransClient = require('midtrans-client');
const Order = require('../models/Order');
const { v4: uuidv4 } = require('uuid');

exports.createTransaction = async (req, res) => {
    try {
        const { userId, items, totalAmount } = req.body;

        const orderId = `ORDER-${uuidv4()}`;

        const newOrder = new Order({
            userId: userId,
            orderId: orderId,
            items: items,
            totalAmount: totalAmount,
            status: 'pending' 
        });
        await newOrder.save();

        let snap = new midtransClient.Snap({
            isProduction: process.env.MIDTRANS_IS_PRODUCTION === 'true',
            serverKey: process.env.MIDTRANS_SERVER_KEY
        });

        let parameter = {
            transaction_details: {
                order_id: orderId,
                gross_amount: totalAmount
            },
            credit_card: {
                secure: true
            },
            customer_details: {
                first_name: "Customer", 
                email: "customer@example.com", 
            }
        };

        const transaction = await snap.createTransaction(parameter);
        
        res.status(200).json({
            message: "Token berhasil dibuat",
            token: transaction.token,
            redirect_url: transaction.redirect_url,
            orderId: orderId
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};