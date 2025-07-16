# ZakatFlow - Local Development Setup

ZakatFlow is a comprehensive Zakat management system with a Flutter mobile app, React dashboard, and Node.js backend.

## Project Structure

```
ZakatFlow/
├── backend/          # Node.js Express API server
├── dashboard/        # React admin dashboard
├── frontend/         # Flutter mobile application
└── README.md         # This file
```

## Prerequisites

- Node.js (v16 or higher)
- npm or yarn
- MongoDB (local installation or MongoDB Atlas)
- Flutter SDK (for mobile app development)
- Git

## Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create environment file:
   ```bash
   cp .env.example .env
   ```

4. Update the `.env` file with your configuration:
   ```
   MONGO_URI=mongodb://localhost:27017/zakatflow
   JWT_SECRET=your_jwt_secret_key_here
   PORT=5000
   NODE_ENV=development
   CLIENT_URL=http://localhost:3000
   CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
   CLOUDINARY_API_KEY=your_cloudinary_api_key
   CLOUDINARY_API_SECRET=your_cloudinary_api_secret
   ```

5. Start the development server:
   ```bash
   npm run dev
   ```

   The backend will be available at `http://localhost:5000`

## Dashboard Setup

1. Navigate to the dashboard directory:
   ```bash
   cd dashboard
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create environment file:
   ```bash
   cp .env.example .env
   ```

4. Update the `.env` file:
   ```
   VITE_API_URL=http://localhost:5000
   ```

5. Start the development server:
   ```bash
   npm run dev
   ```

   The dashboard will be available at `http://localhost:3000`

## Frontend (Flutter App) Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the Flutter app:
   ```bash
   flutter run
   ```

## Development Workflow

1. **Start Backend**: Run `npm run dev` in the `backend` directory
2. **Start Dashboard**: Run `npm run dev` in the `dashboard` directory
3. **Start Mobile App**: Run `flutter run` in the `frontend` directory

## API Endpoints

Once the backend is running, the API will be available at:
- Base URL: `http://localhost:5000`
- User routes: `http://localhost:5000/api/user`
- Payment routes: `http://localhost:5000/api/payments`

## Database Setup

### Local MongoDB
1. Install MongoDB locally
2. Start MongoDB service
3. Use connection string: `mongodb://localhost:27017/zakatflow`

### MongoDB Atlas (Cloud)
1. Create a MongoDB Atlas account
2. Create a new cluster
3. Get your connection string
4. Update the `MONGO_URI` in your `.env` file

## Troubleshooting

### Common Issues

1. **Port already in use**: Change the PORT in backend `.env` file
2. **Database connection failed**: Check your MongoDB connection string
3. **CORS errors**: Ensure `CLIENT_URL` in backend `.env` matches your dashboard URL
4. **Flutter build issues**: Run `flutter clean` and `flutter pub get`

### Environment Variables

Make sure all required environment variables are set in your `.env` files:
- Backend: Check `backend/.env.example` for required variables
- Dashboard: Check `dashboard/.env.example` for required variables

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## License

This project is licensed under the ISC License.