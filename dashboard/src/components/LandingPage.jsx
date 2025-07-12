import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { dashboardColors } from "../theme/dashboardColors";
import { FaDownload, FaApple, FaGooglePlay, FaChevronDown, FaShieldAlt, FaMobile, FaUsers, FaChartLine } from "react-icons/fa";

const LandingPage = () => {
  const [showDownloadDropdown, setShowDownloadDropdown] = useState(false);
  const navigate = useNavigate();

  const handleAdminAccess = () => {
    const token = localStorage.getItem("authToken");
    if (token) {
      navigate("/dashboard");
    } else {
      navigate("/login");
    }
  };

  const features = [
    {
      icon: <FaShieldAlt className="text-3xl" />,
      title: "Secure Zakat Management",
      description: "Manage your Zakat payments securely with enterprise-grade encryption and protection."
    },
    {
      icon: <FaMobile className="text-3xl" />,
      title: "Mobile First Design",
      description: "Access your Zakat management tools anywhere, anytime with our mobile-optimized platform."
    },
    {
      icon: <FaUsers className="text-3xl" />,
      title: "Agent Network",
      description: "Connect with verified Zakat agents and manage distributions efficiently."
    },
    {
      icon: <FaChartLine className="text-3xl" />,
      title: "Analytics & Reporting",
      description: "Track your Zakat contributions and view detailed reports of your charitable giving."
    }
  ];

  return (
    <div className="min-h-screen" style={{ background: 'linear-gradient(135deg, #FAF9F6 0%, #F4F6FA 50%, #FFFDE4 100%)' }}>

      {/* Enhanced Hero Section */}
      <section className="relative px-4 sm:px-6 lg:px-8 py-24 overflow-hidden">
        {/* Animated Background Elements */}
        <div className="absolute inset-0 opacity-15">
          <div className="absolute top-10 left-10 w-20 h-20 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.lightGold, animationDelay: '0s' }}></div>
          <div className="absolute top-32 right-20 w-16 h-16 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.gold, animationDelay: '1s' }}></div>
          <div className="absolute bottom-20 left-1/4 w-12 h-12 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.darkGold, animationDelay: '2s' }}></div>
          <div className="absolute bottom-32 right-1/3 w-24 h-24 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.lightGold, animationDelay: '0.5s' }}></div>
          <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-32 h-32 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.cream, animationDelay: '1.5s' }}></div>
        </div>
        
        <div className="relative z-10 max-w-7xl mx-auto text-center">
          {/* Trust Badge */}
          <div className="mb-8">
            <div className="inline-flex items-center px-6 py-3 rounded-full mb-6 border" style={{ 
              backgroundColor: `${dashboardColors.primary.lightGold}20`,
              borderColor: `${dashboardColors.primary.lightGold}40`,
              color: dashboardColors.primary.darkGold
            }}>
              <span className="text-sm font-semibold">✨ Trusted by 1000+ Organizations</span>
            </div>
          </div>
          
          {/* Main Logo */}
          <div className="mb-8">
            <div 
              className="w-32 h-32 rounded-full mx-auto mb-6 flex items-center justify-center shadow-2xl animate-pulse"
              style={{ 
                background: dashboardColors.gradient.primary,
                boxShadow: dashboardColors.shadow.xl 
              }}
            >
              <img src="/logo.png" alt="ZakatFlow Logo" className="w-20 h-20 object-contain" />
            </div>
          </div>

          {/* Hero Text */}
          <h1 
            className="text-6xl md:text-7xl font-extrabold mb-8 bg-gradient-to-r bg-clip-text text-transparent relative"
            style={{ 
              backgroundImage: `linear-gradient(135deg, ${dashboardColors.primary.gold} 0%, ${dashboardColors.primary.darkGold} 100%)` 
            }}
          >
            ZakatFlow
            <div className="absolute -bottom-2 left-1/2 transform -translate-x-1/2 w-32 h-1 rounded-full" style={{ background: dashboardColors.gradient.primary, opacity: 0.3 }}></div>
          </h1>
          <p 
            className="text-xl md:text-2xl mb-12 max-w-4xl mx-auto leading-relaxed"
            style={{ color: dashboardColors.text.secondary }}
          >
            Transform your Zakat management with our intelligent platform. 
            <span className="font-semibold" style={{ color: dashboardColors.primary.darkGold }}>Streamline operations, track payments, and manage agents</span> all in one secure place.
          </p>

          {/* Enhanced Action Buttons */}
          <div className="flex flex-col sm:flex-row gap-6 justify-center items-center mb-16">
            <button 
              onClick={handleAdminAccess}
              className="group px-10 py-5 rounded-2xl text-white font-bold text-lg transition-all duration-300 transform hover:scale-105 hover:shadow-2xl relative overflow-hidden"
              style={{ 
                background: dashboardColors.gradient.primary,
                boxShadow: dashboardColors.shadow.xl 
              }}
            >
              <span className="relative z-10 flex items-center gap-3">
                Get Started Now
                <svg className="w-5 h-5 transition-transform duration-300 group-hover:translate-x-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clipRule="evenodd" />
                </svg>
              </span>
              <div className="absolute inset-0 bg-white opacity-0 group-hover:opacity-10 transition-opacity duration-300"></div>
            </button>
          </div>

          {/* Download Section */}
          <div className="relative inline-block mb-16">
            <button
              onClick={() => setShowDownloadDropdown(!showDownloadDropdown)}
              className="group flex items-center space-x-3 px-10 py-5 rounded-2xl font-bold text-lg transition-all duration-300 hover:scale-105 focus:outline-none focus:ring-2 shadow-lg border-2 relative overflow-hidden"
              style={{
                color: dashboardColors.primary.gold,
                backgroundColor: dashboardColors.background.white,
                borderColor: dashboardColors.primary.gold,
                boxShadow: dashboardColors.shadow.lg,
                focusRingColor: dashboardColors.primary.lightGold
              }}
            >
              <span className="relative z-10 flex items-center gap-3">
                <FaDownload className="text-xl" />
                <span>📱 Download Mobile App</span>
                <FaChevronDown className={`transition-transform duration-200 ${showDownloadDropdown ? 'rotate-180' : ''}`} />
              </span>
              <div className="absolute inset-0 opacity-0 group-hover:opacity-5 transition-opacity duration-300" style={{ background: dashboardColors.gradient.primary }}></div>
            </button>

            {/* Download Dropdown */}
            {showDownloadDropdown && (
              <div 
                className="absolute top-full left-1/2 transform -translate-x-1/2 mt-2 w-64 rounded-xl shadow-xl border-2 overflow-hidden animate-fadeIn"
                style={{ 
                  backgroundColor: dashboardColors.background.white,
                  borderColor: dashboardColors.border.light,
                  boxShadow: dashboardColors.shadow.xl 
                }}
              >
                {/* Android Option */}
                <button 
                  className="w-full flex items-center space-x-4 px-6 py-4 transition-all duration-200 hover:scale-105"
                  style={{ 
                    backgroundColor: dashboardColors.background.white,
                    color: dashboardColors.text.primary,
                    borderBottom: `1px solid ${dashboardColors.border.light}`
                  }}
                  onMouseEnter={(e) => e.target.style.backgroundColor = dashboardColors.background.light}
                  onMouseLeave={(e) => e.target.style.backgroundColor = dashboardColors.background.white}
                >
                  <FaGooglePlay className="text-2xl" style={{ color: '#34A853' }} />
                  <div className="text-left">
                    <p className="font-semibold">Download for Android</p>
                    <p className="text-sm" style={{ color: dashboardColors.text.secondary }}>Available on Google Play</p>
                  </div>
                </button>

                {/* iOS Option (Disabled) */}
                <div 
                  className="w-full flex items-center space-x-4 px-6 py-4 opacity-50 cursor-not-allowed"
                  style={{ 
                    backgroundColor: dashboardColors.background.light,
                    color: dashboardColors.text.muted 
                  }}
                >
                  <FaApple className="text-2xl" style={{ color: dashboardColors.text.muted }} />
                  <div className="text-left">
                    <p className="font-semibold">Download for iOS</p>
                    <p className="text-sm">Coming Soon</p>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </section>

      {/* Enhanced Features Section */}
      <section className="px-4 sm:px-6 lg:px-8 py-24 relative overflow-hidden" style={{ backgroundColor: dashboardColors.background.white }}>
        {/* Background Pattern */}
        <div className="absolute inset-0 opacity-5">
          <div className="absolute top-0 left-0 w-full h-full" style={{ 
            backgroundImage: `radial-gradient(circle at 25% 25%, ${dashboardColors.primary.lightGold} 2px, transparent 2px), radial-gradient(circle at 75% 75%, ${dashboardColors.primary.gold} 1px, transparent 1px)`,
            backgroundSize: '50px 50px'
          }}></div>
        </div>
        
        <div className="relative z-10 max-w-7xl mx-auto">
          <div className="text-center mb-20">
            <div className="inline-flex items-center px-4 py-2 rounded-full mb-6" style={{ 
              backgroundColor: `${dashboardColors.primary.lightGold}15`,
              color: dashboardColors.primary.darkGold
            }}>
              <span className="text-sm font-semibold">🚀 POWERFUL FEATURES</span>
            </div>
            
            <h2 className="text-5xl md:text-6xl font-bold mb-8" style={{ color: dashboardColors.text.primary }}>
              Why Choose <span className="bg-gradient-to-r bg-clip-text text-transparent relative" style={{ backgroundImage: dashboardColors.gradient.primary }}>
                ZakatFlow
                <div className="absolute -bottom-1 left-0 right-0 h-1 rounded-full" style={{ background: dashboardColors.gradient.primary, opacity: 0.3 }}></div>
              </span>?
            </h2>
            <p className="text-xl md:text-2xl max-w-3xl mx-auto leading-relaxed" style={{ color: dashboardColors.text.secondary }}>
              Experience the future of Zakat management with our comprehensive, intelligent platform designed for modern organizations
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature, index) => (
              <div 
                key={index}
                className="group p-10 rounded-3xl text-center transition-all duration-500 hover:scale-105 hover:shadow-2xl relative overflow-hidden"
                style={{ 
                  backgroundColor: dashboardColors.background.card,
                  border: `1px solid ${dashboardColors.border.light}`,
                  boxShadow: dashboardColors.shadow.lg 
                }}
              >
                <div className="absolute inset-0 opacity-0 group-hover:opacity-10 transition-opacity duration-500" style={{ background: dashboardColors.gradient.primary }}></div>
                
                <div className="relative z-10">
                  <div 
                    className="w-20 h-20 rounded-2xl mx-auto mb-8 flex items-center justify-center transition-all duration-300 group-hover:scale-110 group-hover:rotate-3"
                    style={{ 
                      background: dashboardColors.gradient.primary,
                      boxShadow: dashboardColors.shadow.lg,
                      color: 'white'
                    }}
                  >
                    {feature.icon}
                  </div>
                  <h3 
                    className="text-2xl font-bold mb-6 transition-colors duration-300"
                    style={{ color: dashboardColors.text.primary }}
                  >
                    {feature.title}
                  </h3>
                  <p 
                    className="text-lg leading-relaxed"
                    style={{ color: dashboardColors.text.secondary }}
                  >
                    {feature.description}
                  </p>
                  
                  {/* Feature highlights */}
                  <div className="mt-6 space-y-2">
                    <div className="flex items-center justify-center gap-2 text-sm" style={{ color: dashboardColors.primary.darkGold }}>
                      <div className="w-2 h-2 rounded-full" style={{ backgroundColor: dashboardColors.primary.gold }}></div>
                      <span>Enterprise Grade</span>
                    </div>
                    <div className="flex items-center justify-center gap-2 text-sm" style={{ color: dashboardColors.primary.darkGold }}>
                      <div className="w-2 h-2 rounded-full" style={{ backgroundColor: dashboardColors.primary.gold }}></div>
                      <span>24/7 Support</span>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
          
          {/* Additional Features Grid */}
          <div className="mt-20 grid grid-cols-2 md:grid-cols-4 gap-6">
            <div className="text-center p-6 rounded-2xl border transition-all duration-300 hover:scale-105" style={{ 
              backgroundColor: dashboardColors.background.white,
              borderColor: dashboardColors.border.light,
              boxShadow: dashboardColors.shadow.sm
            }}>
              <div className="text-2xl mb-3">⚡</div>
              <div className="text-sm font-semibold" style={{ color: dashboardColors.text.primary }}>Lightning Fast</div>
            </div>
            <div className="text-center p-6 rounded-2xl border transition-all duration-300 hover:scale-105" style={{ 
              backgroundColor: dashboardColors.background.white,
              borderColor: dashboardColors.border.light,
              boxShadow: dashboardColors.shadow.sm
            }}>
              <div className="text-2xl mb-3">🔄</div>
              <div className="text-sm font-semibold" style={{ color: dashboardColors.text.primary }}>Auto Sync</div>
            </div>
            <div className="text-center p-6 rounded-2xl border transition-all duration-300 hover:scale-105" style={{ 
              backgroundColor: dashboardColors.background.white,
              borderColor: dashboardColors.border.light,
              boxShadow: dashboardColors.shadow.sm
            }}>
              <div className="text-2xl mb-3">🌍</div>
              <div className="text-sm font-semibold" style={{ color: dashboardColors.text.primary }}>Global Access</div>
            </div>
            <div className="text-center p-6 rounded-2xl border transition-all duration-300 hover:scale-105" style={{ 
              backgroundColor: dashboardColors.background.white,
              borderColor: dashboardColors.border.light,
              boxShadow: dashboardColors.shadow.sm
            }}>
              <div className="text-2xl mb-3">🎯</div>
              <div className="text-sm font-semibold" style={{ color: dashboardColors.text.primary }}>Smart Targeting</div>
            </div>
          </div>
        </div>
      </section>

      {/* About Section */}
      <section className="px-4 sm:px-6 lg:px-8 py-20" style={{ backgroundColor: dashboardColors.background.light }}>
        <div className="max-w-4xl mx-auto text-center">
          <h2 
            className="text-4xl md:text-5xl font-bold mb-8"
            style={{ color: dashboardColors.primary.gold }}
          >
            About ZakatFlow
          </h2>
          <div className="space-y-6 text-lg leading-relaxed" style={{ color: dashboardColors.text.secondary }}>
            <p>
              ZakatFlow is a comprehensive digital platform designed to simplify and modernize Zakat management. 
              Our mission is to make charitable giving more accessible, transparent, and efficient for Muslims worldwide.
            </p>
            <p>
              Built with cutting-edge technology and Islamic principles at its core, ZakatFlow provides a secure 
              environment for calculating, tracking, and distributing Zakat obligations. Whether you're an individual 
              looking to fulfill your religious duties or an organization managing large-scale distributions, 
              ZakatFlow has the tools you need.
            </p>
            <p>
              Join thousands of users who trust ZakatFlow to manage their charitable giving with confidence, 
              transparency, and ease.
            </p>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="px-4 sm:px-6 lg:px-8 py-12" style={{ backgroundColor: dashboardColors.primary.gold }}>
        <div className="max-w-7xl mx-auto text-center">
          <div className="flex items-center justify-center space-x-3 mb-6">
            <div 
              className="w-10 h-10 rounded-lg flex items-center justify-center"
              style={{ backgroundColor: dashboardColors.background.white }}
            >
              <img src="/logo.png" alt="ZakatFlow Logo" className="w-6 h-6 object-contain" />
            </div>
            <h3 className="text-2xl font-bold" style={{ color: dashboardColors.background.white }}>ZakatFlow</h3>
          </div>
          <p 
            className="text-lg mb-4"
            style={{ color: dashboardColors.background.white, opacity: 0.9 }}
          >
            Empowering charitable giving through technology
          </p>
          <p 
            className="text-sm"
            style={{ color: dashboardColors.background.white, opacity: 0.7 }}
          >
            © {new Date().getFullYear()} ZakatFlow. All rights reserved. | Protected by enterprise-grade security
          </p>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage;