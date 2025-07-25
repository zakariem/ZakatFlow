import React, { useState } from "react";
import { dashboardColors } from "../theme/dashboardColors";
import { FaBars, FaTimes, FaHome, FaMoneyCheckAlt, FaUserFriends } from "react-icons/fa";
import { useLocation, useNavigate } from "react-router-dom";
import axiosInstance from "../utils/axiosConfig";
import { adminApi } from "../api/adminApi";

const menuItems = [
  { label: "Overview", icon: <FaHome />, path: "/dashboard" },
  { label: "Payments", icon: <FaMoneyCheckAlt />, path: "/dashboard/paymentManagement" },
  { label: "Agents", icon: <FaUserFriends />, path: "/dashboard/agent-management" },
];

function Sidebar() {
  const [isOpen, setIsOpen] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      const token = localStorage.getItem('authToken');
      if (token) {
        // Call the logout API
        await axiosInstance.post(adminApi.logoutUser, {});
      }
    } catch (error) {
      console.error('Logout API call failed:', error);
      // Continue with local logout even if API call fails
    } finally {
      // Always remove token, role and navigate
      localStorage.removeItem('authToken');
      localStorage.removeItem('userRole');
      navigate('/');
    }
  };

  const handleNavigation = (path) => {
    navigate(path);
    setIsOpen(false);
  };

  const isActive = (path) => {
    if (path === "/dashboard" && location.pathname === "/dashboard") return true;
    if (path !== "/dashboard" && location.pathname.startsWith(path)) return true;
    return false;
  };

  return (
    <>
      {/* Mobile Hamburger Button */}
      <div className="lg:hidden fixed top-fluid-1 xs:top-4 left-fluid-1 xs:left-4 z-50">
        <button
          onClick={() => setIsOpen(true)}
          className="p-2.5 xs:p-3 rounded-lg xs:rounded-xl shadow-lg transition-all duration-200 hover:scale-105 focus:outline-none focus:ring-2 animate-scaleIn"
          style={{
            backgroundColor: dashboardColors.background.white,
            color: dashboardColors.primary.gold,
            boxShadow: dashboardColors.shadow.md,
            focusRingColor: dashboardColors.primary.lightGold
          }}
        >
          <FaBars className="text-lg xs:text-xl" />
        </button>
      </div>

      {/* Mobile Overlay */}
      {isOpen && (
        <div
          className="lg:hidden fixed inset-0 z-40 transition-opacity duration-300 animate-fadeIn"
          style={{ backgroundColor: dashboardColors.background.overlay }}
          onClick={() => setIsOpen(false)}
        />
      )}

      {/* Mobile Sidebar */}
      <div
        className={`lg:hidden fixed top-0 left-0 h-full w-72 xs:w-80 z-50 transform transition-transform duration-300 ease-in-out animate-slideIn ${isOpen ? "translate-x-0" : "-translate-x-full"
          }`}
        style={{
          background: dashboardColors.gradient.primary,
          boxShadow: dashboardColors.shadow.xl
        }}
      >
        {/* Mobile Header */}
        <div className="flex items-center justify-between p-fluid-2 xs:p-fluid-4 lg:p-6" style={{ borderBottom: `1px solid ${dashboardColors.primary.lightGold}` }}>
          <div className="flex items-center min-w-0 flex-1">
            <div
              className="w-7 h-7 xs:w-8 xs:h-8 rounded-lg mr-2 xs:mr-3 flex items-center justify-center flex-shrink-0"
              style={{ backgroundColor: dashboardColors.background.white }}
            >
              <img
                src="/logo.png"
                alt="App Logo"
                className="w-5 h-5 xs:w-6 xs:h-6 object-contain"
              />
            </div>
            <span className="text-fluid-lg xs:text-fluid-xl font-bold truncate" style={{ color: dashboardColors.background.white }}>ZakatFlow</span>
          </div>
          <button
            onClick={() => setIsOpen(false)}
            className="p-1.5 xs:p-2 rounded-lg transition-all duration-200 hover:scale-110 flex-shrink-0"
            style={{ color: dashboardColors.background.white, backgroundColor: 'rgba(255,255,255,0.1)' }}
          >
            <FaTimes className="text-base xs:text-lg" />
          </button>
        </div>

        {/* Mobile Navigation */}
        <nav className="mt-fluid-4 xs:mt-8 px-fluid-1 xs:px-4">
          {menuItems.map((item) => (
            <button
              key={item.label}
              onClick={() => handleNavigation(item.path)}
              className={`flex items-center w-full px-fluid-1 xs:px-4 py-3 xs:py-4 mb-1.5 xs:mb-2 rounded-lg xs:rounded-xl transition-all duration-200 text-left font-medium hover:scale-105 ${isActive(item.path)
                  ? "shadow-lg transform scale-105"
                  : "hover:shadow-md"
                }`}
              style={{
                backgroundColor: isActive(item.path)
                  ? dashboardColors.background.white
                  : 'rgba(255,255,255,0.1)',
                color: isActive(item.path)
                  ? dashboardColors.primary.gold
                  : dashboardColors.background.white,
                boxShadow: isActive(item.path) ? dashboardColors.shadow.md : 'none'
              }}
            >
              <span className="mr-3 xs:mr-4 text-base xs:text-lg flex-shrink-0">{item.icon}</span>
              <span className="text-fluid-sm xs:text-fluid-base truncate">{item.label}</span>
            </button>
          ))}
        </nav>

        {/* Mobile Footer */}
        <div className="absolute bottom-fluid-2 xs:bottom-6 left-fluid-1 xs:left-4 right-fluid-1 xs:right-4">
          <div className="p-fluid-1 xs:p-4 rounded-lg xs:rounded-xl mb-fluid-1 xs:mb-4" style={{ backgroundColor: 'rgba(255,255,255,0.1)' }}>
            <p className="text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.background.white, opacity: 0.8 }}>Admin Dashboard</p>
            <p className="text-fluid-xs mt-0.5 xs:mt-1" style={{ color: dashboardColors.background.white, opacity: 0.6 }}>Manage your Zakat operations</p>
          </div>
          <button
            onClick={handleLogout}
            className="w-full py-2.5 xs:py-3 rounded-lg xs:rounded-xl font-semibold transition-all duration-200 hover:scale-105 text-fluid-sm xs:text-fluid-base"
            style={{ backgroundColor: dashboardColors.status.error, color: dashboardColors.background.white }}
          >
            Logout
          </button>
        </div>
      </div>

      {/* Desktop Sidebar */}
      <aside
        className="hidden lg:flex flex-col w-64 xl:w-72 2xl:w-80 h-screen fixed left-0 top-0 z-30 transition-all duration-300 animate-slideIn"
        style={{
          background: dashboardColors.gradient.primary,
          boxShadow: dashboardColors.shadow.xl
        }}
      >
        {/* Desktop Header */}
        <div className="p-fluid-4 xl:p-6 border-b" style={{ borderColor: dashboardColors.primary.lightGold }}>
          <div className="flex items-center">
          <div
              className="w-10 h-10 xl:w-12 xl:h-12 rounded-lg mr-2 xl:mr-3 flex items-center justify-center flex-shrink-0"
              style={{ backgroundColor: dashboardColors.background.white }}
            >
              <img
                src="/logo.png"
                alt="App Logo"
                className="w-7 h-7 xl:w-8 xl:h-8 object-contain"
              />
            </div>
            <div className="min-w-0 flex-1">
              <h1 className="text-fluid-lg xl:text-fluid-2xl font-bold truncate" style={{ color: dashboardColors.background.white }}>ZakatFlow</h1>
              <p className="text-fluid-xs xl:text-fluid-sm opacity-80 truncate" style={{ color: dashboardColors.background.white }}>Admin Dashboard</p>
            </div>
          </div>
        </div>

        {/* Desktop Navigation */}
        <nav className="flex-1 p-fluid-4 xl:p-6">
          <div className="space-y-2">
            {menuItems.map((item) => (
              <button
                key={item.label}
                onClick={() => handleNavigation(item.path)}
                className={`flex items-center w-full px-fluid-1 xl:px-5 py-3 xl:py-4 rounded-lg xl:rounded-xl transition-all duration-200 text-left font-medium group hover:scale-105 ${isActive(item.path)
                    ? "shadow-lg transform scale-105"
                    : "hover:shadow-md"
                  }`}
                style={{
                  backgroundColor: isActive(item.path)
                    ? dashboardColors.background.white
                    : 'rgba(255,255,255,0.1)',
                  color: isActive(item.path)
                    ? dashboardColors.primary.gold
                    : dashboardColors.background.white,
                  boxShadow: isActive(item.path) ? dashboardColors.shadow.md : 'none'
                }}
              >
                <span className="mr-2 xl:mr-4 text-lg xl:text-xl flex-shrink-0 group-hover:scale-110 transition-transform duration-200">{item.icon}</span>
                <span className="text-fluid-sm xl:text-fluid-lg truncate">{item.label}</span>
                {isActive(item.path) && (
                  <div className="ml-auto w-2 h-2 rounded-full flex-shrink-0" style={{ backgroundColor: dashboardColors.primary.gold }} />
                )}
              </button>
            ))}
          </div>
        </nav>

        {/* Desktop Footer */}
        <div className="p-fluid-4 xl:p-6 border-t" style={{ borderColor: dashboardColors.primary.lightGold }}>
          <div className="p-fluid-1 xl:p-4 rounded-lg xl:rounded-xl mb-fluid-1 xl:mb-4" style={{ backgroundColor: 'rgba(255,255,255,0.1)' }}>
            <p className="text-fluid-xs xl:text-fluid-sm font-medium truncate" style={{ color: dashboardColors.background.white, opacity: 0.9 }}>Admin Dashboard</p>
            <p className="text-fluid-xs mt-0.5 xl:mt-1 truncate" style={{ color: dashboardColors.background.white, opacity: 0.7 }}>Manage your Zakat operations efficiently</p>
          </div>
          <button
            onClick={handleLogout}
            className="w-full py-2.5 xl:py-3 rounded-lg xl:rounded-xl font-semibold transition-all duration-200 hover:scale-105 group text-fluid-sm xl:text-fluid-base"
            style={{ backgroundColor: dashboardColors.status.error, color: dashboardColors.background.white }}
          >
            <span className="group-hover:scale-110 transition-transform duration-200">🚪</span>
            <span className="ml-2 truncate">Logout</span>
          </button>
        </div>
      </aside>
    </>
  );
}

export default Sidebar;