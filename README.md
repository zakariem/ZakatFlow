<div align="center">
  <img src="dashboard/public/logo.png" alt="ZakatFlow Logo" width="120" height="126">
  
# 🌟 ZakatFlow
  
  **A Modern, Comprehensive Zakat Management System**
  
  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org)
  [![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
  [![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)](https://mongodb.com)
  
  [🚀 Live Demo](https://zakat-flow-beta.vercel.app) • [📱 Download APK](https://download1979.mediafire.com/75l3492290wg6Jl8996qeXbToSM0AOQ5ki-VSw-wFBvpgwebuzgYCXhk1DgSDSyEadO4jz5qUOEZLqv7pXiMwyFc8LRKiqzngrw4G4RcbYV6DeDp1Tq07Ffanc2VMyCtFi15UDW2JbgHo26S7b2KFluONTx6SscaKxRC18PnKsSVhA/kwmj2uh0l0hb44z/app-release.apk) • [📖 Documentation](#documentation)
  
</div>

---

## 🎯 About ZakatFlow

ZakatFlow is a cutting-edge, full-stack Zakat management platform designed to streamline Islamic charitable giving. Built with modern technologies, it provides a seamless experience for individuals, organizations, and agents to manage Zakat calculations, payments, and distributions efficiently.

### ✨ Key Features

- 🧮 **Smart Zakat Calculator** - Automated calculations for all types of Zakat (Mal, Fitr, Agricultural)
- 📱 **Cross-Platform Mobile App** - Beautiful Flutter app for iOS and Android
- 🖥️ **Admin Dashboard** - Comprehensive React-based management portal
- 👥 **Agent Management** - Complete agent network management system
- 📊 **Analytics & Reporting** - Real-time insights and detailed reports
- 🔐 **Secure Authentication** - JWT-based authentication with role management
- 🌐 **Multi-language Support** - Arabic and English interface
- 📈 **Payment Tracking** - Complete payment history and status tracking
- 🔄 **Real-time Sync** - Live data synchronization across all platforms
- 📋 **Islamic Compliance** - Calculations based on authentic Islamic jurisprudence

## 🏗️ Architecture

```
🌟 ZakatFlow Ecosystem
├── 📱 Mobile App (Flutter)
│   ├── Cross-platform iOS/Android
│   ├── Offline-first architecture
│   └── Real-time notifications
├── 🖥️ Admin Dashboard (React)
│   ├── Modern responsive design
│   ├── Advanced analytics
│   └── Agent management
└── ⚡ Backend API (Node.js)
    ├── RESTful API design
    ├── MongoDB database
    └── Cloudinary integration
```

## 🛠️ Tech Stack

### Frontend

- **Mobile**: Flutter 3.7+ with Riverpod state management
- **Web Dashboard**: React 18+ with Vite and Tailwind CSS
- **UI/UX**: Material Design 3, Custom golden theme

### Backend

- **Runtime**: Node.js 16+ with Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT with role-based access control
- **File Storage**: Cloudinary for image management
- **Security**: bcrypt, helmet, cors

### DevOps & Tools

- **Version Control**: Git with conventional commits
- **Package Management**: npm/yarn, pub
- **Code Quality**: ESLint, Prettier, Flutter Lints
- **Deployment**: Vercel (Dashboard), Manual APK distribution

## 🚀 Quick Start

### Prerequisites

Ensure you have the following installed:

- [Node.js](https://nodejs.org/) (v16 or higher)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.7 or higher)
- [MongoDB](https://www.mongodb.com/try/download/community) (local or Atlas)
- [Git](https://git-scm.com/)

### 🔧 Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/ZakatFlow.git
   cd ZakatFlow
   ```

2. **Backend Setup**

   ```bash
   cd backend
   npm install
   cp .env.example .env
   # Configure your .env file (see Environment Variables section)
   npm run dev
   ```

3. **Dashboard Setup**

   ```bash
   cd dashboard
   npm install
   cp .env.example .env
   # Configure VITE_API_URL in .env
   npm run dev
   ```

4. **Mobile App Setup**

   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```

### 🌐 Access Points

- **Backend API**: <http://localhost:5000>
- **Admin Dashboard**: <http://localhost:3000>
- **Mobile App**: Available on connected device/emulator

## ⚙️ Environment Variables

### Backend (.env)

```env
# Database
MONGO_URI=mongodb://localhost:27017/zakatflow

# Authentication
JWT_SECRET=your_super_secure_jwt_secret_key_here

# Server
PORT=5000
NODE_ENV=development
CLIENT_URL=http://localhost:3000

# Cloudinary (for file uploads)
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret
```

### Dashboard (.env)

```env
VITE_API_URL=http://localhost:5000
```

## 📱 Mobile App Features

- **Zakat Calculator**: Calculate Zakat for wealth, gold, silver, livestock, and agriculture
- **Payment Management**: Track and manage Zakat payments
- **Agent Directory**: Find and connect with verified Zakat agents
- **Islamic Calendar**: Hijri calendar integration
- **Hadith Collection**: Daily Islamic wisdom and guidance
- **Offline Support**: Core features work without internet
- **Multi-language**: Arabic and English support

## 🖥️ Dashboard Features

- **User Management**: Complete user and agent administration
- **Payment Analytics**: Comprehensive payment tracking and reporting
- **Agent Network**: Manage agent registrations and performance
- **System Monitoring**: Real-time system health and usage statistics
- **Content Management**: Manage app content and configurations
- **Security Controls**: Advanced security and access management

## 🔌 API Endpoints

### Authentication

- `POST /api/user/register` - User registration
- `POST /api/user/login` - User login
- `POST /api/user/refresh` - Token refresh

### User Management

- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update user profile
- `GET /api/user/agents` - Get all agents

### Payments

- `POST /api/payments/create` - Create payment
- `GET /api/payments/history` - Payment history
- `PUT /api/payments/:id/status` - Update payment status

## 🗄️ Database Schema

### User Model

```javascript
{
  name: String,
  email: String,
  phone: String,
  role: ['user', 'agent', 'admin'],
  profileImage: String,
  isVerified: Boolean,
  createdAt: Date
}
```

### Payment Model

```javascript
{
  userId: ObjectId,
  agentId: ObjectId,
  amount: Number,
  type: ['zakat_mal', 'zakat_fitr', 'sadaqah'],
  status: ['pending', 'completed', 'cancelled'],
  paymentMethod: String,
  createdAt: Date
}
```

## 🧪 Testing

```bash
# Backend tests
cd backend
npm test

# Frontend tests
cd frontend
flutter test

# Dashboard tests
cd dashboard
npm test
```

## 🚀 Deployment

### Backend (Node.js)

- Deploy to Heroku, Railway, or DigitalOcean
- Configure production environment variables
- Set up MongoDB Atlas for production database

### Dashboard (React)

- Deploy to Vercel, Netlify, or AWS S3
- Configure build environment variables
- Set up custom domain (optional)

### Mobile App (Flutter)

- **Android**: Build APK/AAB for Google Play Store
- **iOS**: Build IPA for Apple App Store
- Configure app signing and certificates

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### 🔄 How to Contribute

1. **Fork the repository**

   ```bash
   git clone https://github.com/yourusername/ZakatFlow.git
   ```

2. **Create a feature branch**

   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
   - Follow the existing code style
   - Add tests for new features
   - Update documentation as needed

4. **Commit your changes**

   ```bash
   git commit -m 'feat: add amazing feature'
   ```

5. **Push to your branch**

   ```bash
   git push origin feature/amazing-feature
   ```

6. **Open a Pull Request**
   - Provide a clear description of changes
   - Reference any related issues
   - Ensure all tests pass

### 🎯 Areas for Contribution

- 🐛 **Bug Fixes**: Help us identify and fix issues
- ✨ **New Features**: Implement new functionality
- 📚 **Documentation**: Improve docs and tutorials
- 🌍 **Localization**: Add support for more languages
- 🎨 **UI/UX**: Enhance user interface and experience
- ⚡ **Performance**: Optimize app performance
- 🧪 **Testing**: Add more comprehensive tests

### 📋 Development Guidelines

- Follow conventional commit messages
- Write clean, documented code
- Ensure responsive design for web components
- Test on multiple devices for mobile features
- Follow Islamic principles in feature development

## 🐛 Troubleshooting

### Common Issues

**Backend Issues**

- ❌ Port already in use → Change PORT in `.env`
- ❌ Database connection failed → Check MongoDB connection string
- ❌ JWT errors → Verify JWT_SECRET configuration

**Frontend Issues**

- ❌ Flutter build issues → Run `flutter clean && flutter pub get`
- ❌ iOS build problems → Update Xcode and CocoaPods
- ❌ Android build errors → Check Android SDK configuration

**Dashboard Issues**

- ❌ CORS errors → Verify CLIENT_URL in backend `.env`
- ❌ API connection issues → Check VITE_API_URL configuration
- ❌ Build failures → Clear node_modules and reinstall

### 🆘 Getting Help

- 📖 Check our [Documentation](#documentation)
- 🐛 [Report Issues](https://github.com/yourusername/ZakatFlow/issues)
- 💬 [Join Discussions](https://github.com/yourusername/ZakatFlow/discussions)
- 📧 Email: <support@zakatflow.com>

## 📄 License

This project is licensed under the **ISC License** - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Islamic scholars for Zakat calculation guidance
- Flutter and React communities for excellent frameworks
- All contributors who help improve ZakatFlow
- Beta testers and early adopters

## 🌟 Support the Project

If you find ZakatFlow helpful, please consider:

- ⭐ **Star this repository**
- 🍴 **Fork and contribute**
- 📢 **Share with others**
- 🐛 **Report issues**
- 💡 **Suggest features**

---

<div align="center">
  
  **Made with ❤️ for the Muslim community**
  
  [Website](https://zakatflow.com) • [Documentation](#) • [Support](mailto:support@zakatflow.com)
  
</div>
