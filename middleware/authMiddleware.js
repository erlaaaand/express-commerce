const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    const tokenHeader = req.headers['authorization'];

    if (!tokenHeader) {
        return res.status(403).json({ message: "Access denied!." });
    }

    try {
        const token = tokenHeader.split(' ')[1]; 
        
        const decoded = jwt.verify(token, process.env.JWT_SECRET); 

        req.user = decoded; 
        
        next();
    } catch (error) {
        return res.status(401).json({ message: "Token invalid" });
    }
};

module.exports = { verifyToken };