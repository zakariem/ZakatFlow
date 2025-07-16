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
      <div className="lg:hidden fixed top-4 left-4 z-50">
        <button
          onClick={() => setIsOpen(true)}
          className="p-3 rounded-xl shadow-lg transition-all duration-200 hover:scale-105 focus:outline-none focus:ring-2 animate-scaleIn"
          style={{
            backgroundColor: dashboardColors.background.white,
            color: dashboardColors.primary.gold,
            boxShadow: dashboardColors.shadow.md,
            focusRingColor: dashboardColors.primary.lightGold
          }}
        >
          <FaBars size={20} />
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
        className={`lg:hidden fixed top-0 left-0 h-full w-80 z-50 transform transition-transform duration-300 ease-in-out animate-slideIn ${isOpen ? "translate-x-0" : "-translate-x-full"
          }`}
        style={{
          background: dashboardColors.gradient.primary,
          boxShadow: dashboardColors.shadow.xl
        }}
      >
        {/* Mobile Header */}
        <div className="flex items-center justify-between p-6" style={{ borderBottom: `1px solid ${dashboardColors.primary.lightGold}` }}>
          <div className="flex items-center">
            <div
              className="w-8 h-8 rounded-lg mr-3 flex items-center justify-center"
              style={{ backgroundColor: dashboardColors.background.white }}
            >
              <img
                src="/logo.png"
                alt="App Logo"
                className="w-6 h-6 object-contain"
              />
            </div>
            <span className="text-xl font-bold" style={{ color: dashboardColors.background.white }}>ZakatFlow</span>
          </div>
          <button
            onClick={() => setIsOpen(false)}
            className="p-2 rounded-lg transition-all duration-200 hover:scale-110"
            style={{ color: dashboardColors.background.white, backgroundColor: 'rgba(255,255,255,0.1)' }}
          >
            <FaTimes size={18} />
          </button>
        </div>

        {/* Mobile Navigation */}
        <nav className="mt-8 px-4">
          {menuItems.map((item) => (
            <button
              key={item.label}
              onClick={() => handleNavigation(item.path)}
              className={`flex items-center w-full px-4 py-4 mb-2 rounded-xl transition-all duration-200 text-left font-medium hover:scale-105 ${isActive(item.path)
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
              <span className="mr-4 text-lg">{item.icon}</span>
              <span className="text-base">{item.label}</span>
            </button>
          ))}
        </nav>

        {/* Mobile Footer */}
        <div className="absolute bottom-6 left-4 right-4">
          <div className="p-4 rounded-xl mb-4" style={{ backgroundColor: 'rgba(255,255,255,0.1)' }}>
            <p className="text-sm" style={{ color: dashboardColors.background.white, opacity: 0.8 }}>Admin Dashboard</p>
            <p className="text-xs mt-1" style={{ color: dashboardColors.background.white, opacity: 0.6 }}>Manage your Zakat operations</p>
          </div>
          <button
            onClick={handleLogout}
            className="w-full py-3 rounded-xl font-semibold transition-all duration-200 hover:scale-105"
            style={{ backgroundColor: dashboardColors.status.error, color: dashboardColors.background.white }}
          >
            Logout
          </button>
        </div>
      </div>

      {/* Desktop Sidebar */}
      <aside
        className="hidden lg:flex flex-col w-72 h-screen fixed left-0 top-0 z-30 transition-all duration-300 animate-slideIn"
        style={{
          background: dashboardColors.gradient.primary,
          boxShadow: dashboardColors.shadow.xl
        }}
      >
        {/* Desktop Header */}
        <div className="p-6 border-b" style={{ borderColor: dashboardColors.primary.lightGold }}>
          <div className="flex items-center">
          <div
              className="w-12 h-12 rounded-lg mr-3 flex items-center justify-center"
              style={{ backgroundColor: dashboardColors.background.white }}
            >
              <img
                src="/logo.png"
                alt="App Logo"
                className="w-29 h-29 object-contain"
              />
            </div>
            <div>
              <h1 className="text-2xl font-bold" style={{ color: dashboardColors.background.white }}>ZakatFlow</h1>
              <p className="text-sm opacity-80" style={{ color: dashboardColors.background.white }}>Admin Dashboard</p>
            </div>
          </div>
        </div>

        {/* Desktop Navigation */}
        <nav className="flex-1 p-6">
          <div className="space-y-2">
            {menuItems.map((item) => (
              <button
                key={item.label}
                onClick={() => handleNavigation(item.path)}
                className={`flex items-center w-full px-5 py-4 rounded-xl transition-all duration-200 text-left font-medium group hover:scale-105 ${isActive(item.path)
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
                <span className="mr-4 text-xl group-hover:scale-110 transition-transform duration-200">{item.icon}</span>
                <span className="text-lg">{item.label}</span>
                {isActive(item.path) && (
                  <div className="ml-auto w-2 h-2 rounded-full" style={{ backgroundColor: dashboardColors.primary.gold }} />
                )}
              </button>
            ))}
          </div>
        </nav>

        {/* Desktop Footer */}
        <div className="p-6">
          <div className="p-4 rounded-xl mb-4" style={{ backgroundColor: 'rgba(255,255,255,0.1)' }}>
            <div className="flex items-center">
              <div className="w-8 h-8 rounded-full mr-3 flex items-center justify-center" style={{ backgroundColor: dashboardColors.background.white }}>
                <span className="text-sm font-bold" style={{ color: dashboardColors.primary.gold }}>A</span>
              </div>
              <div>
                <p className="text-sm font-medium" style={{ color: dashboardColors.background.white }}>Admin User</p>
                <p className="text-xs opacity-80" style={{ color: dashboardColors.background.white }}>System Administrator</p>
              </div>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="w-full py-3 rounded-xl font-semibold transition-all duration-200 hover:scale-105"
            style={{ backgroundColor: dashboardColors.status.error, color: dashboardColors.background.white }}
          >
            Logout
          </button>
        </div>
      </aside>
    </>
  );
}

export default Sidebar;