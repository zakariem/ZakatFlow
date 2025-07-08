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

      {/* Hero Section */}
      <section className="relative px-4 sm:px-6 lg:px-8 py-20">
        <div className="max-w-7xl mx-auto text-center">
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
            className="text-5xl md:text-7xl font-extrabold mb-6 bg-gradient-to-r bg-clip-text text-transparent"
            style={{ 
              backgroundImage: `linear-gradient(135deg, ${dashboardColors.primary.gold} 0%, ${dashboardColors.primary.darkGold} 100%)` 
            }}
          >
            ZakatFlow
          </h1>
          <p 
            className="text-xl md:text-2xl mb-8 max-w-3xl mx-auto leading-relaxed"
            style={{ color: dashboardColors.text.secondary }}
          >
            The modern way to manage your Zakat obligations. Secure, transparent, and accessible from anywhere.
          </p>

          {/* Download Section */}
          <div className="relative inline-block mb-16">
            <button
              onClick={() => setShowDownloadDropdown(!showDownloadDropdown)}
              className="flex items-center space-x-3 px-8 py-4 rounded-xl font-semibold text-lg transition-all duration-200 hover:scale-105 focus:outline-none focus:ring-2 shadow-lg"
              style={{
                background: dashboardColors.gradient.primary,
                color: dashboardColors.background.white,
                boxShadow: dashboardColors.shadow.lg,
                focusRingColor: dashboardColors.primary.lightGold
              }}
            >
              <FaDownload className="text-xl" />
              <span>Download Mobile App</span>
              <FaChevronDown className={`transition-transform duration-200 ${showDownloadDropdown ? 'rotate-180' : ''}`} />
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

      {/* Features Section */}
      <section className="px-4 sm:px-6 lg:px-8 py-20" style={{ backgroundColor: dashboardColors.background.white }}>
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 
              className="text-4xl md:text-5xl font-bold mb-6"
              style={{ color: dashboardColors.primary.gold }}
            >
              Why Choose ZakatFlow?
            </h2>
            <p 
              className="text-xl max-w-3xl mx-auto"
              style={{ color: dashboardColors.text.secondary }}
            >
              Experience the future of Zakat management with our comprehensive platform designed for modern Muslims.
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature, index) => (
              <div 
                key={index}
                className="p-8 rounded-2xl text-center transition-all duration-300 hover:scale-105 hover:shadow-lg"
                style={{ 
                  backgroundColor: dashboardColors.background.card,
                  border: `1px solid ${dashboardColors.border.light}`,
                  boxShadow: dashboardColors.shadow.sm 
                }}
              >
                <div 
                  className="w-16 h-16 rounded-xl mx-auto mb-6 flex items-center justify-center"
                  style={{ 
                    background: `linear-gradient(135deg, ${dashboardColors.primary.lightGold}20, ${dashboardColors.primary.gold}20)`,
                    color: dashboardColors.primary.gold 
                  }}
                >
                  {feature.icon}
                </div>
                <h3 
                  className="text-xl font-bold mb-4"
                  style={{ color: dashboardColors.text.primary }}
                >
                  {feature.title}
                </h3>
                <p 
                  className="leading-relaxed"
                  style={{ color: dashboardColors.text.secondary }}
                >
                  {feature.description}
                </p>
              </div>
            ))}
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