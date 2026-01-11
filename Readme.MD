# Kadai Erland - E-Commerce Backend API

Production-ready Node.js backend with clean architecture and comprehensive features.

## Architecture

```
├── src/
│   ├── config/          # Configuration files
│   ├── middleware/      # Express middleware
│   ├── models/          # Mongoose models
│   ├── controllers/     # Request handlers
│   ├── services/        # Business logic
│   ├── routes/          # API routes
│   ├── utils/           # Helper utilities
│   └── app.js           # Express app setup
├── .env.example         # Environment variables template
├── server.js            # Entry point
└── package.json         # Dependencies
```

## Features

### Authentication & Authorization
- JWT-based authentication
- Secure password hashing with bcrypt
- Protected routes with middleware
- Rate limiting for auth endpoints

### Product Management
- CRUD operations
- Category filtering
- Text search capability
- Stock management
- Soft delete functionality

### Shopping Cart
- Add/update/remove items
- Real-time stock validation
- Automatic total calculation
- User-specific carts

### Order Management
- Checkout process
- Order history
- Order cancellation
- Stock adjustment on order

### Payment Integration
- Midtrans payment gateway
- Payment notification handling
- Payment status checking
- Secure transaction flow

## Installation

```bash
npm install
```

## Environment Setup

Copy `.env.example` to `.env` and configure:

```env
NODE_ENV=development
PORT=5000
MONGODB_URI=your_mongodb_uri
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=7d
MIDTRANS_SERVER_KEY=your_midtrans_key
MIDTRANS_CLIENT_KEY=your_client_key
MIDTRANS_IS_PRODUCTION=false
```

## Running the Application

Development mode:
```bash
npm run dev
```

Production mode:
```bash
npm start
```

## API Endpoints

### Authentication
```
POST   /api/auth/register     # Register new user
POST   /api/auth/login        # Login user
GET    /api/auth/profile      # Get user profile (protected)
```

### Products
```
GET    /api/products          # Get all products
GET    /api/products/:id      # Get product by ID
POST   /api/products          # Create product (protected)
PUT    /api/products/:id      # Update product (protected)
DELETE /api/products/:id      # Delete product (protected)
```

### Cart
```
GET    /api/cart              # Get user cart (protected)
POST   /api/cart              # Add to cart (protected)
PATCH  /api/cart/:productId   # Update quantity (protected)
DELETE /api/cart/:productId   # Remove from cart (protected)
DELETE /api/cart              # Clear cart (protected)
```

### Orders
```
POST   /api/orders/checkout         # Checkout cart (protected)
GET    /api/orders                  # Get user orders (protected)
GET    /api/orders/:orderId         # Get order details (protected)
POST   /api/orders/:orderId/cancel  # Cancel order (protected)
```

### Payment
```
POST   /api/payment/notification    # Midtrans webhook
GET    /api/payment/status/:orderId # Check payment status (protected)
```

## Response Format

Success:
```json
{
  "status": "success",
  "message": "Operation successful",
  "data": {}
}
```

Error:
```json
{
  "status": "error",
  "message": "Error description",
  "errors": []
}
```

## Security Features

- Helmet.js for HTTP headers
- CORS configuration
- Rate limiting
- JWT authentication
- Input validation
- Error handling middleware
- SQL injection prevention
- XSS protection

## Best Practices

- Clean architecture with separation of concerns
- Service layer for business logic
- Validation middleware
- Centralized error handling
- Consistent response format
- Environment-based configuration
- Security-first approach
- Database indexing for performance

## Database Models

### User
- username, email, passwordHash
- Unique email constraint
- Soft delete support

### Product
- name, price, promoPrice, description
- imageUrl, stock, vendor, category
- Text search indexes

### Cart
- userId reference
- items array with product details
- Automatic total calculation

### Order
- userId reference, orderId
- items snapshot at purchase time
- status tracking
- payment information

## Error Handling

All errors are caught and processed through middleware:
- Validation errors → 400 Bad Request
- Authentication errors → 401 Unauthorized
- Not found errors → 404 Not Found
- Conflict errors → 409 Conflict
- Server errors → 500 Internal Server Error

## Production Deployment

1. Set `NODE_ENV=production`
2. Use strong `JWT_SECRET`
3. Configure production MongoDB
4. Set up Midtrans production keys
5. Enable HTTPS
6. Configure rate limiting
7. Set up monitoring
8. Enable logging

## Testing

Health check endpoint:
```
GET /health
```

Response:
```json
{
  "status": "success",
  "message": "Server is healthy",
  "timestamp": "2024-01-11T10:00:00.000Z"
}
```

## License

ISC