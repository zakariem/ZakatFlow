import React, { useState, useEffect } from "react";
import axiosInstance from "../utils/axiosConfig";
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
        const paymentsResponse = await axiosInstance.get(adminApi.getPayments);
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
      <div className="relative overflow-hidden rounded-2xl xs:rounded-3xl p-fluid-4 xs:p-fluid-6 lg:p-8 mb-fluid-4 xs:mb-8" style={{ 
        background: `linear-gradient(135deg, ${dashboardColors.status.info}15 0%, ${dashboardColors.primary.lightGold}10 50%, ${dashboardColors.background.white} 100%)`,
        border: `1px solid ${dashboardColors.border.light}`,
        boxShadow: dashboardColors.shadow.lg
      }}>
        <div className="relative z-10">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-fluid-3 xs:gap-6">
            <div className="text-center lg:text-left">
              <div className="flex items-center justify-center lg:justify-start gap-2 xs:gap-3 mb-fluid-2 xs:mb-4">
                <div className="w-8 h-8 xs:w-10 xs:h-10 lg:w-12 lg:h-12 rounded-lg xs:rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: `linear-gradient(135deg, ${dashboardColors.status.info} 0%, #2B6CB0 100%)` }}>
                  <FaMoneyBillWave className="text-white text-sm xs:text-lg lg:text-xl" />
                </div>
                <h1 className="text-fluid-xl xs:text-fluid-2xl sm:text-fluid-3xl lg:text-fluid-4xl xl:text-fluid-5xl font-bold bg-gradient-to-r from-blue-600 to-blue-800 bg-clip-text text-transparent leading-tight">
                  Payment Management
                </h1>
              </div>
              <p className="text-fluid-sm xs:text-fluid-base lg:text-fluid-lg leading-relaxed" style={{ color: dashboardColors.text.secondary }}>
                Monitor and manage all Zakat payments with comprehensive tracking and analytics
              </p>
            </div>
            <div className="flex flex-col items-center lg:items-end gap-2 xs:gap-3">
              <div className="text-center lg:text-right">
                <p className="text-fluid-xs xs:text-fluid-sm font-medium" style={{ color: dashboardColors.text.muted }}>Total Records</p>
                <p className="text-fluid-lg xs:text-fluid-xl lg:text-fluid-2xl font-bold" style={{ color: dashboardColors.status.info }}>
                  {filteredPayments.length.toLocaleString()}
                </p>
              </div>
            </div>
          </div>
        </div>
        {/* Decorative Elements */}
        <div className="absolute top-0 right-0 w-32 h-32 xs:w-48 xs:h-48 lg:w-64 lg:h-64 rounded-full opacity-5 transform translate-x-16 xs:translate-x-24 lg:translate-x-32 -translate-y-16 xs:-translate-y-24 lg:-translate-y-32" style={{ backgroundColor: dashboardColors.status.info }}></div>
        <div className="absolute bottom-0 left-0 w-24 h-24 xs:w-36 xs:h-36 lg:w-48 lg:h-48 rounded-full opacity-5 transform -translate-x-12 xs:-translate-x-18 lg:-translate-x-24 translate-y-12 xs:translate-y-18 lg:translate-y-24" style={{ backgroundColor: dashboardColors.primary.lightGold }}></div>
      </div>

      {/* Filter Buttons */}
      <div className="flex flex-wrap gap-2 xs:gap-3">
        {["All", "Today", "This Week", "This Month"].map((filter, index) => (
          <button
            key={filter}
            onClick={() => setSelectedFilter(filter)}
            className={`px-fluid-2 xs:px-fluid-4 lg:px-6 py-2 xs:py-2.5 lg:py-3 rounded-lg xs:rounded-xl font-medium transition-all duration-200 hover:scale-105 text-fluid-xs xs:text-fluid-sm lg:text-fluid-base ${selectedFilter === filter
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
      <div className="grid grid-cols-1 xs:grid-cols-2 lg:grid-cols-3 gap-fluid-2 xs:gap-fluid-4 lg:gap-6">
        {summaryCards.map((card, index) => (
          <div
            key={index}
            className="relative overflow-hidden rounded-xl xs:rounded-2xl p-fluid-2 xs:p-fluid-4 lg:p-6 transition-all duration-300 hover:scale-105 hover:shadow-2xl animate-slideUp group cursor-pointer"
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
            <div className="absolute top-0 right-0 w-12 h-12 xs:w-16 xs:h-16 lg:w-20 lg:h-20 rounded-full opacity-10 transform translate-x-3 xs:translate-x-4 lg:translate-x-6 -translate-y-3 xs:-translate-y-4 lg:-translate-y-6 group-hover:scale-150 transition-transform duration-500" 
                 style={{ backgroundColor: dashboardColors.background.white }}></div>
            <div className="absolute bottom-0 left-0 w-10 h-10 xs:w-12 xs:h-12 lg:w-16 lg:h-16 rounded-full opacity-10 transform -translate-x-2 xs:-translate-x-3 lg:-translate-x-4 translate-y-2 xs:translate-y-3 lg:translate-y-4 group-hover:scale-125 transition-transform duration-700" 
                 style={{ backgroundColor: dashboardColors.background.white }}></div>
            
            <div className="relative z-10">
              <div className="flex items-center justify-between mb-2 xs:mb-3 lg:mb-4">
                <div className="p-2 xs:p-2.5 lg:p-3 rounded-lg xs:rounded-xl" style={{ backgroundColor: 'rgba(255,255,255,0.2)' }}>
                  <span className="text-lg xs:text-xl lg:text-2xl text-white group-hover:scale-110 transition-transform duration-200">
                    {card.icon}
                  </span>
                </div>

              </div>
              <h3 className="text-white/90 text-fluid-xs xs:text-fluid-sm font-medium mb-1 xs:mb-2">{card.title}</h3>
              <p className="text-white text-fluid-lg xs:text-fluid-xl lg:text-fluid-3xl font-bold group-hover:scale-105 transition-transform duration-200">
                {card.value}
              </p>
            </div>
            <div className="absolute top-0 right-0 w-20 h-20 xs:w-24 xs:h-24 lg:w-32 lg:h-32 rounded-full opacity-10 transform translate-x-10 xs:translate-x-12 lg:translate-x-16 -translate-y-5 xs:-translate-y-6 lg:-translate-y-8"
              style={{ backgroundColor: dashboardColors.background.white }}>
            </div>
          </div>
        ))}
      </div>
      {/* Payments Table */}
      <div
        className="rounded-xl xs:rounded-2xl overflow-hidden transition-all duration-300 hover:shadow-2xl animate-slideUp"
        style={{
          backgroundColor: dashboardColors.background.white,
          boxShadow: dashboardColors.shadow.lg,
          animationDelay: '300ms'
        }}
      >
        <div className="p-fluid-2 xs:p-fluid-4 lg:p-6 border-b" style={{ borderColor: dashboardColors.border.light }}>
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 xs:gap-4">
            <h2 className="text-fluid-lg xs:text-fluid-xl lg:text-fluid-2xl font-bold" style={{ color: dashboardColors.text.primary }}>Payment Records</h2>
            <div className="flex items-center gap-2 xs:gap-3">

            </div>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead style={{ backgroundColor: dashboardColors.background.light }}>
              <tr>
                <th className="text-left py-2 xs:py-3 lg:py-4 px-2 xs:px-4 lg:px-6 font-semibold text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.primary }}>Payment ID</th>
                <th className="text-left py-2 xs:py-3 lg:py-4 px-2 xs:px-4 lg:px-6 font-semibold text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.primary }}>Donor</th>
                <th className="text-left py-2 xs:py-3 lg:py-4 px-2 xs:px-4 lg:px-6 font-semibold text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.primary }}>Amount</th>
                <th className="text-left py-2 xs:py-3 lg:py-4 px-2 xs:px-4 lg:px-6 font-semibold text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.primary }}>Agent</th>
                <th className="text-left py-2 xs:py-3 lg:py-4 px-2 xs:px-4 lg:px-6 font-semibold text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.primary }}>Date</th>
                <th className="text-left py-2 xs:py-3 lg:py-4 px-2 xs:px-4 lg:px-6 font-semibold text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.primary }}>Status</th>

              </tr>
            </thead>
            <tbody>
              {filteredPayments.length > 0 ? (
                filteredPayments.map((payment, index) => (
                  <tr key={payment._id || index} className="border-b transition-all duration-200 hover:scale-[1.01] hover:shadow-md" style={{ borderColor: dashboardColors.border.light }}>
                    <td className="py-2 xs:py-3 lg:py-4 px-2 xs:px-4 lg:px-6">
                      <span className="font-mono text-fluid-xs xs:text-fluid-sm px-1.5 xs:px-2 py-0.5 xs:py-1 rounded" style={{ backgroundColor: dashboardColors.background.light, color: dashboardColors.text.primary }}>
                        {payment._id || `PAY-${String(index + 1).padStart(4, '0')}`}
                      </span>
                    </td>
                    <td className="py-2 xs:py-3 lg:py-4 px-2 xs:px-4 lg:px-6">
                      <div>
                        <p className="font-medium text-fluid-xs xs:text-fluid-sm truncate" style={{ color: dashboardColors.text.primary }}>{payment.userFullName}</p>
                        <p className="text-fluid-xs truncate" style={{ color: dashboardColors.text.secondary }}>{payment.userAccountNo || 'N/A'}</p>
                      </div>
                    </td>
                    <td className="py-2 xs:py-3 lg:py-4 px-2 xs:px-4 lg:px-6">
                      <span className="text-fluid-sm xs:text-fluid-base lg:text-fluid-xl font-bold" style={{ color: dashboardColors.primary.gold }}>
                        {(payment.currency || '$') + ' ' + (parseFloat(payment.actualZakatAmount || 0).toLocaleString('en-US', { minimumFractionDigits: 2 }))}
                      </span>
                    </td>
                    <td className="py-2 xs:py-3 lg:py-4 px-2 xs:px-4 lg:px-6">
                      <div className="flex items-center">
                        <div className="w-6 h-6 xs:w-7 xs:h-7 lg:w-8 lg:h-8 rounded-full mr-1.5 xs:mr-2 flex items-center justify-center text-white text-fluid-xs xs:text-fluid-sm font-bold flex-shrink-0" style={{ backgroundColor: dashboardColors.primary.gold }}>
                          {payment.agentName ? payment.agentName.charAt(0).toUpperCase() : 'N'}
                        </div>
                        <span className="text-fluid-xs xs:text-fluid-sm truncate" style={{ color: dashboardColors.text.secondary }}>{payment.agentName || 'No Agent'}</span>
                      </div>
                    </td>
                    <td className="py-2 xs:py-3 lg:py-4 px-2 xs:px-4 lg:px-6 text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.secondary }}>
                      {payment.paidAt ? new Date(payment.paidAt).toLocaleDateString('en-US', {
                        year: 'numeric',
                        month: 'short',
                        day: 'numeric'
                      }) : 'N/A'}
                    </td>
                    <td className="py-2 xs:py-3 lg:py-4 px-2 xs:px-4 lg:px-6">
                      <span className={`px-2 xs:px-3 py-0.5 xs:py-1 rounded-full text-fluid-xs xs:text-fluid-sm font-medium ${payment.waafiResponse && payment.waafiResponse.state === 'APPROVED'
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
                  <td colSpan="7" className="py-8 xs:py-10 lg:py-12 text-center">
                    <div className="flex flex-col items-center">
                      <FaMoneyBillWave className="text-fluid-3xl xs:text-fluid-4xl lg:text-6xl mb-2 xs:mb-3 lg:mb-4" style={{ color: dashboardColors.text.muted }} />
                      <h3 className="text-fluid-base xs:text-fluid-lg lg:text-fluid-xl font-semibold mb-1 xs:mb-2" style={{ color: dashboardColors.text.secondary }}>No Payments Found</h3>
                      <p className="text-fluid-xs xs:text-fluid-sm" style={{ color: dashboardColors.text.muted }}>No payments match your current filter criteria.</p>
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