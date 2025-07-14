import React from 'react';
import { useNavigate } from 'react-router-dom';
import { dashboardColors } from '../theme/dashboardColors';
import { FaHome, FaExclamationTriangle, FaArrowLeft } from 'react-icons/fa';

const NotFound = () => {
  const navigate = useNavigate();

  const handleGoHome = () => {
    navigate('/dashboard');
  };

  const handleGoBack = () => {
    navigate(-1);
  };

  return (
    <div 
      className="min-h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8 relative overflow-hidden"
      style={{ 
        background: `linear-gradient(135deg, ${dashboardColors.background.main} 0%, ${dashboardColors.primary.cream} 50%, ${dashboardColors.background.light} 100%)` 
      }}
    >
      {/* Animated Background Elements */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-20 left-20 w-32 h-32 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.lightGold, animationDelay: '0s' }}></div>
        <div className="absolute top-40 right-32 w-24 h-24 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.gold, animationDelay: '2s' }}></div>
        <div className="absolute bottom-32 left-1/4 w-20 h-20 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.darkGold, animationDelay: '1s' }}></div>
        <div className="absolute bottom-20 right-20 w-28 h-28 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.lightGold, animationDelay: '3s' }}></div>
      </div>

      <div className="relative z-10 max-w-2xl w-full text-center">
        {/* Error Icon */}
        <div className="mb-8">
          <div 
            className="w-32 h-32 mx-auto rounded-full flex items-center justify-center shadow-2xl animate-bounce"
            style={{ 
              background: dashboardColors.gradient.primary,
              boxShadow: dashboardColors.shadow.xl 
            }}
          >
            <FaExclamationTriangle className="text-white text-5xl" />
          </div>
        </div>

        {/* Error Code */}
        <div className="mb-6">
          <h1 
            className="text-8xl md:text-9xl font-extrabold mb-4 bg-gradient-to-r bg-clip-text text-transparent"
            style={{ 
              backgroundImage: `linear-gradient(135deg, ${dashboardColors.primary.gold} 0%, ${dashboardColors.primary.darkGold} 100%)` 
            }}
          >
            404
          </h1>
          <div className="w-24 h-1 mx-auto rounded-full" style={{ background: dashboardColors.gradient.primary }}></div>
        </div>

        {/* Error Message */}
        <div className="mb-12">
          <h2 
            className="text-3xl md:text-4xl font-bold mb-4"
            style={{ color: dashboardColors.text.primary }}
          >
            Page Not Found
          </h2>
          <p 
            className="text-lg md:text-xl leading-relaxed max-w-lg mx-auto"
            style={{ color: dashboardColors.text.secondary }}
          >
            The page you're looking for doesn't exist or has been moved. 
            <span className="font-semibold" style={{ color: dashboardColors.primary.darkGold }}>
              Let's get you back on track.
            </span>
          </p>
        </div>

        {/* Action Buttons */}
        <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
          <button
            onClick={handleGoHome}
            className="group flex items-center space-x-3 px-8 py-4 rounded-xl font-semibold text-lg transition-all duration-300 hover:scale-105 focus:outline-none focus:ring-2 shadow-lg"
            style={{
              background: dashboardColors.gradient.primary,
              color: dashboardColors.background.white,
              boxShadow: dashboardColors.shadow.md,
              focusRingColor: dashboardColors.primary.lightGold
            }}
          >
            <FaHome className="text-xl group-hover:rotate-12 transition-transform duration-200" />
            <span>Go to Dashboard</span>
          </button>

          <button
            onClick={handleGoBack}
            className="group flex items-center space-x-3 px-8 py-4 rounded-xl font-semibold text-lg transition-all duration-300 hover:scale-105 focus:outline-none focus:ring-2 border-2"
            style={{
              color: dashboardColors.primary.gold,
              backgroundColor: dashboardColors.background.white,
              borderColor: dashboardColors.primary.gold,
              boxShadow: dashboardColors.shadow.sm,
              focusRingColor: dashboardColors.primary.lightGold
            }}
            onMouseEnter={(e) => {
              e.target.style.backgroundColor = dashboardColors.primary.gold;
              e.target.style.color = dashboardColors.background.white;
            }}
            onMouseLeave={(e) => {
              e.target.style.backgroundColor = dashboardColors.background.white;
              e.target.style.color = dashboardColors.primary.gold;
            }}
          >
            <FaArrowLeft className="text-xl group-hover:-translate-x-1 transition-transform duration-200" />
            <span>Go Back</span>
          </button>
        </div>

        {/* Additional Help */}
        <div className="mt-12">
          <div 
            className="inline-flex items-center px-6 py-3 rounded-full border"
            style={{ 
              backgroundColor: `${dashboardColors.primary.lightGold}20`,
              borderColor: `${dashboardColors.primary.lightGold}40`,
              color: dashboardColors.primary.darkGold
            }}
          >
            <span className="text-sm font-medium">💡 Need help? Contact support or check the documentation</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default NotFound;