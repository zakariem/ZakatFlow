import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { FaTachometerAlt, FaMoneyCheckAlt, FaUsers, FaCog } from 'react-icons/fa';
import dashboardColors from '../theme/dashboardColors';

const navItems = [
  { to: '/dashboard/', label: 'Overview', icon: <FaTachometerAlt /> },
  { to: '/dashboard/paymentManagement', label: 'Payment Management', icon: <FaMoneyCheckAlt /> },
  { to: '/dashboard/agent-management', label: 'Agent Management', icon: <FaUsers /> },
];

const Sidebar = () => {
  const location = useLocation();
  return (
    <aside
      style={{ background: dashboardColors.primary.gold }}
      className="h-full w-64 fixed top-0 left-0 flex flex-col z-20 shadow-lg"
    >
      <div className="h-20 flex items-center justify-center font-extrabold text-2xl border-b border-gray-200 tracking-wide" style={{ color: dashboardColors.text.white }}>
        <span style={{ color: dashboardColors.primary.cream }}>ZakatFlow</span>
      </div>
      <nav className="flex-1 flex flex-col gap-2 p-6">
        {navItems.map((item) => (
          <Link
            key={item.to}
            to={item.to}
            className={`flex items-center gap-3 py-3 px-4 rounded-lg font-semibold transition-all duration-200 ${location.pathname === item.to ? 'bg-white text-gold-700 shadow' : 'hover:bg-[rgba(255,255,255,0.15)] text-white'}`}
            style={location.pathname === item.to ? { color: dashboardColors.primary.gold, background: dashboardColors.background.white } : {}}
          >
            <span className="text-xl">{item.icon}</span>
            <span>{item.label}</span>
          </Link>
        ))}
      </nav>
      <div className="p-6 mt-auto">
        <button
          onClick={() => {
            localStorage.removeItem('authToken');
            window.location.href = '/signup';
          }}
          className="w-full py-2 px-4 rounded-lg font-semibold text-white transition-all duration-200 bg-red-500 hover:bg-red-600 shadow"
        >
          Logout
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;