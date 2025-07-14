import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import connectDB from './config/db.js';
import userRoutes from './routes/user_route.js';
import paymentRoutes from './routes/payment_routes.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000; 
connectDB();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS configuration
const corsOptions = {
  origin: process.env.CLIENT_URL || 'http://localhost:3000',
  credentials: true,
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

app.use('/api/user', userRoutes);
app.use('/api/payments', paymentRoutes);

app.get('/', (req, res) => {
    res.send('API is running...');
});

app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
});
