import React, { useState, useEffect } from "react";
import axios from "axios";
import { adminApi } from "../api/adminApi";
import { dashboardColors } from "../theme/dashboardColors";
import { FaCrown } from "react-icons/fa";
import { Line, Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
);

const Overview = () => {
  const [payments, setPayments] = useState([]);
  const [agents, setAgents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [paymentsRes, agentsRes] = await Promise.all([
          axios.get(adminApi.getPayments, {
            headers: { 'Authorization': `Bearer ${localStorage.getItem('authToken')}` }
          }),
          axios.get(adminApi.getAgents, {
            headers: { 'Authorization': `Bearer ${localStorage.getItem('authToken')}` }
          })
        ]);
        let paymentsData = paymentsRes.data;
        let agentsData = agentsRes.data;
        setPayments(Array.isArray(paymentsData) ? paymentsData : paymentsData.data || []);
        setAgents(Array.isArray(agentsData) ? agentsData : agentsData.data || []);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  // Calculate summary values
  const totalPayments = payments.length;
  const totalAmount = payments.reduce((sum, p) => sum + (parseFloat(p.amount) || 0), 0);
  const today = new Date();
  const todaysPayments = payments.filter(p => {
    const paidAt = new Date(p.paidAt || p.date);
    return paidAt.getFullYear() === today.getFullYear() &&
      paidAt.getMonth() === today.getMonth() &&
      paidAt.getDate() === today.getDate();
  });
  const todaysPaymentsCount = todaysPayments.length;
  const todaysAmount = todaysPayments.reduce((sum, p) => sum + (parseFloat(p.amount) || 0), 0);

  // Prepare chart data
  const last7Days = Array.from({ length: 7 }, (_, i) => {
    const date = new Date();
    date.setDate(date.getDate() - i);
    return date;
  }).reverse();

  const dailyPayments = last7Days.map(date => ({
    date: date.toLocaleDateString('en-US', { weekday: 'short' }),
    amount: payments
      .filter(p => {
        const paidAt = new Date(p.paidAt || p.date);
        return paidAt.getDate() === date.getDate() &&
               paidAt.getMonth() === date.getMonth() &&
               paidAt.getFullYear() === date.getFullYear();
      })
      .reduce((sum, p) => sum + (parseFloat(p.amount) || 0), 0),
    count: payments
      .filter(p => {
        const paidAt = new Date(p.paidAt || p.date);
        return paidAt.getDate() === date.getDate() &&
               paidAt.getMonth() === date.getMonth() &&
               paidAt.getFullYear() === date.getFullYear();
      }).length
  }));

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top',
      },
    },
  };

  const amountChartData = {
    labels: dailyPayments.map(day => day.date),
    datasets: [
      {
        label: 'Daily Amount ($)',
        data: dailyPayments.map(day => day.amount),
        borderColor: dashboardColors.primary.gold,
        backgroundColor: dashboardColors.primary.lightGold,
        fill: true,
      },
    ],
  };

  const paymentsChartData = {
    labels: dailyPayments.map(day => day.date),
    datasets: [
      {
        label: 'Number of Payments',
        data: dailyPayments.map(day => day.count),
        backgroundColor: dashboardColors.primary.gold,
      },
    ],
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2" style={{ borderColor: dashboardColors.primary.gold }}></div>
        <span className="ml-3 text-lg" style={{ color: dashboardColors.text.secondary }}>Loading dashboard...</span>
      </div>
    );
  }
  
  if (error) {
    return (
      <div className="text-center p-8">
        <div className="p-6 rounded-xl" style={{ backgroundColor: dashboardColors.status.error, color: dashboardColors.background.white }}>
          <h3 className="text-lg font-semibold mb-2">Error Loading Data</h3>
          <p>{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-fadeIn">
      {/* Header */}
      <div className="text-center lg:text-left">
        <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold mb-2 bg-gradient-to-r from-yellow-600 to-yellow-800 bg-clip-text text-transparent">
          Dashboard Overview
        </h1>
        <p className="text-lg" style={{ color: dashboardColors.text.secondary }}>
          Welcome back! Here's what's happening with your Zakat operations today.
        </p>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Amount Chart */}
        <div 
          className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl"
          style={{ 
            backgroundColor: dashboardColors.background.white,
            boxShadow: dashboardColors.shadow.lg
          }}
        >
          <h3 className="text-xl font-semibold mb-4" style={{ color: dashboardColors.text.primary }}>Payment Amounts Trend</h3>
          <div className="h-80">
            <Line options={chartOptions} data={amountChartData} />
          </div>
        </div>

        {/* Payments Count Chart */}
        <div 
          className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl"
          style={{ 
            backgroundColor: dashboardColors.background.white,
            boxShadow: dashboardColors.shadow.lg
          }}
        >
          <h3 className="text-xl font-semibold mb-4" style={{ color: dashboardColors.text.primary }}>Number of Payments</h3>
          <div className="h-80">
            <Bar options={chartOptions} data={paymentsChartData} />
          </div>
        </div>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
        <div 
          className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl"
          style={{ 
            background: dashboardColors.gradient.primary,
            boxShadow: dashboardColors.shadow.lg
          }}
        >
          <h3 className="text-white/90 text-sm font-medium mb-2">Total Payments</h3>
          <p className="text-white text-3xl font-bold">{totalPayments.toLocaleString()}</p>
        </div>

        <div 
          className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl"
          style={{ 
            background: dashboardColors.gradient.primary,
            boxShadow: dashboardColors.shadow.lg
          }}
        >
          <h3 className="text-white/90 text-sm font-medium mb-2">Total Amount</h3>
          <p className="text-white text-3xl font-bold">
            ${totalAmount.toLocaleString('en-US', { minimumFractionDigits: 2 })}
          </p>
        </div>

        <div 
          className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl"
          style={{ 
            background: dashboardColors.gradient.primary,
            boxShadow: dashboardColors.shadow.lg
          }}
        >
          <h3 className="text-white/90 text-sm font-medium mb-2">Today's Payments</h3>
          <p className="text-white text-3xl font-bold">{todaysPaymentsCount.toLocaleString()}</p>
        </div>

        <div 
          className="p-6 rounded-2xl transition-all duration-300 hover:shadow-2xl"
          style={{ 
            background: dashboardColors.gradient.primary,
            boxShadow: dashboardColors.shadow.lg
          }}
        >
          <h3 className="text-white/90 text-sm font-medium mb-2">Today's Amount</h3>
          <p className="text-white text-3xl font-bold">
            ${todaysAmount.toLocaleString('en-US', { minimumFractionDigits: 2 })}
          </p>
        </div>
      </div>

      {/* Top Agents Section */}
      <div 
        className="rounded-2xl p-8 transition-all duration-300 hover:shadow-2xl animate-slideUp"
        style={{ 
          backgroundColor: dashboardColors.background.white,
          boxShadow: dashboardColors.shadow.lg,
          animationDelay: '400ms'
        }}
      >
        <div className="flex items-center mb-8">
          <div className="p-3 rounded-xl mr-4" style={{ backgroundColor: dashboardColors.primary.lightGold }}>
            <FaCrown className="text-2xl" style={{ color: dashboardColors.primary.gold }} />
          </div>
          <div>
            <h2 className="text-3xl font-bold" style={{ color: dashboardColors.text.primary }}>Top Performing Agents</h2>
            <p className="text-lg" style={{ color: dashboardColors.text.secondary }}>Our highest collecting agents this period</p>
          </div>
        </div>
        
        {agents.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[...agents]
              .sort((a, b) => (b.totalDonation || 0) - (a.totalDonation || 0))
              .slice(0, 3)
              .map((agent, index) => (
                <div 
                  key={agent._id || agent.id || index} 
                  className="relative p-6 rounded-xl transition-all duration-200 hover:scale-105 group cursor-pointer"
                  style={{ 
                    backgroundColor: index === 0 ? dashboardColors.primary.lightGold : dashboardColors.background.light,
                    border: `1px solid ${dashboardColors.border.light}`,
                    boxShadow: dashboardColors.shadow.md
                  }}
                >
                  {index === 0 && (
                    <FaCrown className="absolute -top-2 -right-2 text-yellow-500 text-xl" />
                  )}
                  <div className="flex items-center mb-4">
                    <div className="relative mr-4">
                      <div 
                        className="w-16 h-16 rounded-full flex items-center justify-center text-white font-bold text-xl overflow-hidden"
                        style={{ 
                          background: index === 0 ? dashboardColors.gradient.primary : dashboardColors.gradient.secondary
                        }}
                      >
                        {agent.profileImage || agent.profileImageUrl || agent.image ? (
                          <img
                            src={agent.profileImage || agent.profileImageUrl || agent.image}
                            alt={agent.fullName}
                            className="w-full h-full object-cover rounded-full"
                          />
                        ) : (
                          agent.fullName ? agent.fullName.charAt(0).toUpperCase() : '?'
                        )}
                      </div>
                      <div 
                        className="absolute -bottom-1 -right-1 w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold text-white"
                        style={{ backgroundColor: dashboardColors.primary.gold }}
                      >
                        #{index + 1}
                      </div>
                    </div>
                    <div className="flex-1">
                      <h4 className="font-semibold text-lg mb-1" style={{ color: dashboardColors.text.primary }}>
                        {agent.fullName}
                      </h4>
                      <p className="text-sm" style={{ color: dashboardColors.text.secondary }}>
                        {agent.email}
                      </p>
                    </div>
                  </div>
                  <div className="text-center p-4 rounded-lg" style={{ backgroundColor: 'rgba(255,255,255,0.5)' }}>
                    <p className="text-2xl font-bold" style={{ color: dashboardColors.primary.gold }}>
                      ${(agent.totalDonation || 0).toLocaleString('en-US', { minimumFractionDigits: 2 })}
                    </p>
                    <p className="text-sm" style={{ color: dashboardColors.text.secondary }}>Total Collected</p>
                  </div>
                </div>
              ))}
          </div>
        ) : (
          <div className="text-center p-8" style={{ color: dashboardColors.text.secondary }}>
            No agents data available
          </div>
        )}
      </div>
    </div>
  );
};

export default Overview;