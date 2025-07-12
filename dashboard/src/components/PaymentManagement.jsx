import React, { useState, useEffect } from "react";
import axios from "axios";
import { adminApi } from "../api/adminApi";
import { dashboardColors } from "../theme/dashboardColors";
import { FaMoneyBillWave, FaReceipt, FaCalendarDay, FaSearch, FaFilter, FaDownload, FaCalendarAlt, FaEye, FaFileExport } from "react-icons/fa";
import { FiTrendingUp } from 'react-icons/fi';

const filters = ["All", "Today", "This Week", "This Month"];

function PaymentManagement() {
  const [selectedFilter, setSelectedFilter] = useState("All");
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const paymentsResponse = await axios.get(adminApi.getPayments, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('authToken')}`
          }
        });
        let data = paymentsResponse.data;
        if (Array.isArray(data)) {
          setPayments(data);
        } else if (Array.isArray(data.data)) {
          setPayments(data.data);
        } else {
          setPayments([]);
        }
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  // Filtering logic
  const filteredPayments = payments.filter(payment => {
    if (!payment.paidAt) return false;
    const paidAt = new Date(payment.paidAt);
    if (isNaN(paidAt)) return false;

    const now = new Date();

    if (selectedFilter === "Today") {
      return paidAt.getFullYear() === now.getFullYear() &&
        paidAt.getMonth() === now.getMonth() &&
        paidAt.getDate() === now.getDate();
    } else if (selectedFilter === "This Week") {
      // Start of week (Monday)
      const weekStart = new Date(now);
      weekStart.setDate(now.getDate() - ((now.getDay() + 6) % 7)); // Monday as start
      weekStart.setHours(0, 0, 0, 0);
      // End of week (Sunday)
      const weekEnd = new Date(weekStart);
      weekEnd.setDate(weekStart.getDate() + 6);
      weekEnd.setHours(23, 59, 59, 999);
      return paidAt >= weekStart && paidAt <= weekEnd;
    } else if (selectedFilter === "This Month") {
      return paidAt.getFullYear() === now.getFullYear() &&
        paidAt.getMonth() === now.getMonth();
    }
    return true; // All
  });

  // Calculate summary values from payments
  const totalPayments = payments.length;
  const totalAmount = payments.reduce((sum, p) => sum + (parseFloat(p.actualZakatAmount) || 0), 0);
  const todaysPayments = payments.filter(p => {
    const paidAt = p.paidAt ? new Date(p.paidAt) : null;
    return paidAt &&
      paidAt.getFullYear() === new Date().getFullYear() &&
      paidAt.getMonth() === new Date().getMonth() &&
      paidAt.getDate() === new Date().getDate();
  }).length;

  console.log('Filtered Payments:', filteredPayments);

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2" style={{ borderColor: dashboardColors.primary.gold }}></div>
        <span className="ml-3 text-lg" style={{ color: dashboardColors.text.secondary }}>Loading payments...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center p-8">
        <div className="p-6 rounded-xl" style={{ backgroundColor: dashboardColors.status.error, color: dashboardColors.background.white }}>
          <h3 className="text-lg font-semibold mb-2">Error Loading Payments</h3>
          <p>{error}</p>
        </div>
      </div>
    );
  }

  const summaryCards = [
    {
      title: "Total Amount",
      value: `$${totalAmount.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
      icon: <FaMoneyBillWave />,
      gradient: dashboardColors.gradient.primary,

    },
    {
      title: "Total Payments",
      value: filteredPayments.length.toLocaleString(),
      icon: <FiTrendingUp />,
      gradient: dashboardColors.primary.lightGold,

    },
    {
      title: "Today's Payments",
      value: todaysPayments.toLocaleString(),
      icon: <FaCalendarAlt />,
      gradient: dashboardColors.primary.lightGold,


    }
  ];

  return (
    <div className="space-y-8 animate-fadeIn">
      {/* Enhanced Header */}
      <div className="relative overflow-hidden rounded-3xl p-8 mb-8" style={{ 
        background: `linear-gradient(135deg, ${dashboardColors.status.info}15 0%, ${dashboardColors.primary.lightGold}10 50%, ${dashboardColors.background.white} 100%)`,
        border: `1px solid ${dashboardColors.border.light}`,
        boxShadow: dashboardColors.shadow.lg
      }}>
        <div className="relative z-10">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
            <div className="text-center lg:text-left">
              <div className="flex items-center justify-center lg:justify-start gap-3 mb-4">
                <div className="w-12 h-12 rounded-xl flex items-center justify-center" style={{ background: `linear-gradient(135deg, ${dashboardColors.status.info} 0%, #2B6CB0 100%)` }}>
                  <FaMoneyBillWave className="text-white text-xl" />
                </div>
                <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold bg-gradient-to-r from-blue-600 to-blue-800 bg-clip-text text-transparent">
                  Payment Management
                </h1>
              </div>
              <p className="text-lg leading-relaxed" style={{ color: dashboardColors.text.secondary }}>
                Monitor and manage all Zakat payments with comprehensive tracking and analytics
              </p>
            </div>
            <div className="flex flex-col items-center lg:items-end gap-3">
              <div className="text-center lg:text-right">
                <p className="text-sm font-medium" style={{ color: dashboardColors.text.muted }}>Total Records</p>
                <p className="text-2xl font-bold" style={{ color: dashboardColors.status.info }}>
                  {filteredPayments.length.toLocaleString()}
                </p>
              </div>
            </div>
          </div>
        </div>
        {/* Decorative Elements */}
        <div className="absolute top-0 right-0 w-64 h-64 rounded-full opacity-5 transform translate-x-32 -translate-y-32" style={{ backgroundColor: dashboardColors.status.info }}></div>
        <div className="absolute bottom-0 left-0 w-48 h-48 rounded-full opacity-5 transform -translate-x-24 translate-y-24" style={{ backgroundColor: dashboardColors.primary.lightGold }}></div>
      </div>

      {/* Filter Buttons */}
      <div className="flex flex-wrap gap-3">
        {["All", "Today", "This Week", "This Month"].map((filter, index) => (
          <button
            key={filter}
            onClick={() => setSelectedFilter(filter)}
            className={`px-6 py-3 rounded-xl font-medium transition-all duration-200 hover:scale-105 ${selectedFilter === filter
                ? "shadow-lg transform scale-105"
                : "hover:shadow-md"
              }`}
            style={{
              backgroundColor: selectedFilter === filter ? dashboardColors.primary.gold : dashboardColors.background.white,
              color: selectedFilter === filter ? dashboardColors.background.white : dashboardColors.text.primary,
              border: `1px solid ${selectedFilter === filter ? dashboardColors.primary.gold : dashboardColors.border.light}`,
              boxShadow: selectedFilter === filter ? dashboardColors.shadow.lg : dashboardColors.shadow.sm
            }}
          >
            {filter}
          </button>
        ))}
      </div>

      {/* Enhanced Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {summaryCards.map((card, index) => (
          <div
            key={index}
            className="relative overflow-hidden rounded-2xl p-6 transition-all duration-300 hover:scale-105 hover:shadow-2xl animate-slideUp group cursor-pointer"
            style={{
              background: index === 0 ? `linear-gradient(135deg, ${dashboardColors.status.success} 0%, #38A169 100%)` :
                        index === 1 ? `linear-gradient(135deg, ${dashboardColors.status.info} 0%, #2B6CB0 100%)` :
                        `linear-gradient(135deg, ${dashboardColors.status.warning} 0%, #D69E2E 100%)`,
              boxShadow: dashboardColors.shadow.lg,
              animationDelay: `${index * 100}ms`,
              border: `1px solid ${dashboardColors.border.light}`
            }}
          >
            {/* Animated Background Elements */}
            <div className="absolute top-0 right-0 w-20 h-20 rounded-full opacity-10 transform translate-x-6 -translate-y-6 group-hover:scale-150 transition-transform duration-500" 
                 style={{ backgroundColor: dashboardColors.background.white }}></div>
            <div className="absolute bottom-0 left-0 w-16 h-16 rounded-full opacity-10 transform -translate-x-4 translate-y-4 group-hover:scale-125 transition-transform duration-700" 
                 style={{ backgroundColor: dashboardColors.background.white }}></div>
            
            <div className="relative z-10">
              <div className="flex items-center justify-between mb-4">
                <div className="p-3 rounded-xl" style={{ backgroundColor: 'rgba(255,255,255,0.2)' }}>
                  <span className="text-2xl text-white group-hover:scale-110 transition-transform duration-200">
                    {card.icon}
                  </span>
                </div>

              </div>
              <h3 className="text-white/90 text-sm font-medium mb-2">{card.title}</h3>
              <p className="text-white text-3xl font-bold group-hover:scale-105 transition-transform duration-200">
                {card.value}
              </p>
            </div>
            <div className="absolute top-0 right-0 w-32 h-32 rounded-full opacity-10 transform translate-x-16 -translate-y-8"
              style={{ backgroundColor: dashboardColors.background.white }}>
            </div>
          </div>
        ))}
      </div>
      {/* Payments Table */}
      <div
        className="rounded-2xl overflow-hidden transition-all duration-300 hover:shadow-2xl animate-slideUp"
        style={{
          backgroundColor: dashboardColors.background.white,
          boxShadow: dashboardColors.shadow.lg,
          animationDelay: '300ms'
        }}
      >
        <div className="p-6 border-b" style={{ borderColor: dashboardColors.border.light }}>
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <h2 className="text-2xl font-bold" style={{ color: dashboardColors.text.primary }}>Payment Records</h2>
            <div className="flex items-center gap-3">

            </div>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead style={{ backgroundColor: dashboardColors.background.light }}>
              <tr>
                <th className="text-left py-4 px-6 font-semibold" style={{ color: dashboardColors.text.primary }}>Payment ID</th>
                <th className="text-left py-4 px-6 font-semibold" style={{ color: dashboardColors.text.primary }}>Donor</th>
                <th className="text-left py-4 px-6 font-semibold" style={{ color: dashboardColors.text.primary }}>Amount</th>
                <th className="text-left py-4 px-6 font-semibold" style={{ color: dashboardColors.text.primary }}>Agent</th>
                <th className="text-left py-4 px-6 font-semibold" style={{ color: dashboardColors.text.primary }}>Date</th>
                <th className="text-left py-4 px-6 font-semibold" style={{ color: dashboardColors.text.primary }}>Status</th>

              </tr>
            </thead>
            <tbody>
              {filteredPayments.length > 0 ? (
                filteredPayments.map((payment, index) => (
                  <tr key={payment._id || index} className="border-b transition-all duration-200 hover:scale-[1.01] hover:shadow-md" style={{ borderColor: dashboardColors.border.light }}>
                    <td className="py-4 px-6">
                      <span className="font-mono text-sm px-2 py-1 rounded" style={{ backgroundColor: dashboardColors.background.light, color: dashboardColors.text.primary }}>
                        {payment._id || `PAY-${String(index + 1).padStart(4, '0')}`}
                      </span>
                    </td>
                    <td className="py-4 px-6">
                      <div>
                        <p className="font-medium" style={{ color: dashboardColors.text.primary }}>{payment.userFullName}</p>
                        <p className="text-sm" style={{ color: dashboardColors.text.secondary }}>{payment.userAccountNo || 'N/A'}</p>
                      </div>
                    </td>
                    <td className="py-4 px-6">
                      <span className="text-xl font-bold" style={{ color: dashboardColors.primary.gold }}>
                        {(payment.currency || '$') + ' ' + (parseFloat(payment.actualZakatAmount || 0).toLocaleString('en-US', { minimumFractionDigits: 2 }))}
                      </span>
                    </td>
                    <td className="py-4 px-6">
                      <div className="flex items-center">
                        <div className="w-8 h-8 rounded-full mr-2 flex items-center justify-center text-white text-sm font-bold" style={{ backgroundColor: dashboardColors.primary.gold }}>
                          {payment.agentName ? payment.agentName.charAt(0).toUpperCase() : 'N'}
                        </div>
                        <span style={{ color: dashboardColors.text.secondary }}>{payment.agentName || 'No Agent'}</span>
                      </div>
                    </td>
                    <td className="py-4 px-6" style={{ color: dashboardColors.text.secondary }}>
                      {payment.paidAt ? new Date(payment.paidAt).toLocaleDateString('en-US', {
                        year: 'numeric',
                        month: 'short',
                        day: 'numeric'
                      }) : 'N/A'}
                    </td>
                    <td className="py-4 px-6">
                      <span className={`px-3 py-1 rounded-full text-sm font-medium ${payment.waafiResponse && payment.waafiResponse.state === 'APPROVED'
                          ? 'bg-green-100 text-green-700'
                          : 'bg-orange-100 text-orange-700'
                        }`}>
                        {payment.waafiResponse && payment.waafiResponse.state || 'Completed'}
                      </span>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="7" className="py-12 text-center">
                    <div className="flex flex-col items-center">
                      <FaMoneyBillWave className="text-6xl mb-4" style={{ color: dashboardColors.text.muted }} />
                      <h3 className="text-xl font-semibold mb-2" style={{ color: dashboardColors.text.secondary }}>No Payments Found</h3>
                      <p style={{ color: dashboardColors.text.muted }}>No payments match your current filter criteria.</p>
                    </div>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

export default PaymentManagement;